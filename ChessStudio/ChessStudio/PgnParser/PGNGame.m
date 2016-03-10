//
//  PGNGame.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 11/12/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "PGNGame.h"
#import "PGNUtil.h"

#define sevenTagRoster [NSArray arrayWithObjects: @"Event",@"Site", @"Date", @"Round", @"White", @"Black", @"Result",  nil]
#define risultati [NSArray arrayWithObjects: @"1-0",@"0-1", @"1/2-1/2", @"*", nil]

NSUInteger const GAME_WITH_MOVES = 100;
NSUInteger const GAME_WITHOUT_MOVES = 200;
NSUInteger const POSITION_WITH_MOVES = 300;
NSUInteger const POSITION_WITHOUT_MOVES = 400;

@interface PGNGame() {
    
    NSMutableCharacterSet *setQuadre;
    NSMutableCharacterSet *setDoppiApici;
    NSMutableCharacterSet *setPunti;
    
    NSMutableDictionary *sevenTag;
    NSMutableDictionary *supplementalTag;
    NSMutableArray *supplementalTagArray;
    
    NSString *originalPgn;
    
    NSString *result;
    FENParser *fenParser;
    NSUInteger gameType;
    
    NSString *copiaMosse;
    NSMutableDictionary *copiaSevenTag;
    NSMutableDictionary *copiaSupplementalTag;
    NSMutableArray *copiaSupplementalTagArray;
}

@end

@implementation PGNGame

static NSString *temporaryFen;

//@synthesize gameNumber = _gameNumber;

- (id) init {
    self = [super init];
    if (self) {
        //tags = [[NSMutableDictionary alloc] init];
        //moves = [[NSMutableArray alloc] init];
        //pgnGame = [[NSMutableString alloc] init];
        
        //movesByPlycount = [[NSMutableDictionary alloc] init];
        //plyCount = 0;
        
        //numeroTags = 0;
        
        setQuadre = [[NSMutableCharacterSet alloc] init];
        [setQuadre addCharactersInString:@"[]"];
        setDoppiApici = [[NSMutableCharacterSet alloc] init];
        [setDoppiApici addCharactersInString:@"\""];
        setPunti = [[NSMutableCharacterSet alloc] init];
        [setPunti addCharactersInString:@"."];
        [self initEmptyGame];
    }
    return self;
}

- (id) initWithPgn:(NSString *)pgn {
    self = [self init];
    if (self) {
        originalPgn = pgn;
        
        _checkMate = NO;
        
        //if ([self gameIsPositionWithRegularFen:pgn]) {
        [self parseGame];
        //[self parseMoves0];
        [self parseMoves];
        
        _editMode = NO;
        _modified = NO;
        //}
        //else {
        //    [NSException raise:@"WRONG_FEN_EXCEPTION_2" format:@"FEN Not Ok"];
        //}
        //[self parseGame];
        //NSArray *pgnArray = [pgn componentsSeparatedByString:separator];
        //for (NSString *tag in pgnArray) {
        //    [self addCompleteTag:tag];
        //}
        //if ([self isPosition]) {
        //    fenParser = [[FENParser alloc] initWithFen:[self getTagValueByTagName:@"FEN"]];
        //}
        
        
        //NSLog(@"%@", originalPgn);
    }
    return self;
}

- (id) initWithFen:(NSString *)fen {
    self = [self init];
    if (self) {
        [self addSupplementalTag:@"SetUp" andTagValue:@"1"];
        [self addSupplementalTag:@"FEN" andTagValue:fen];
        
        _checkMate = NO;
        
        fenParser = [[FENParser alloc] initWithFen:[self getTagValueByTagName:@"FEN"]];
        _editMode = NO;
        _modified = NO;
        if ([risultati containsObject:_moves]) {
            if ([self isPosition]) {
                gameType = POSITION_WITHOUT_MOVES;
            }
            else {
                gameType = GAME_WITHOUT_MOVES;
            }
            result = _moves;
        }
        else {
            if ([_moves hasSuffix:@"*"]) {
                result = @"*";
            }
            else if ([_moves hasSuffix:@"-0"]) {
                result = @"1-0";
            }
            else if ([_moves hasSuffix:@"-1"]) {
                result = @"0-1";
            }
            else if ([_moves hasSuffix:@"-1/2"]) {
                result = @"1/2-1/2";
            }
            
            if ([self isPosition]) {
                //NSLog(@"Ho trovato una posizione con mosse");
                gameType = POSITION_WITH_MOVES;
            }
            else {
                //NSLog(@"HO trovato una partita con mosse");
                gameType = GAME_WITH_MOVES;
            }
        }
    }
    return self;
}


- (void) initEmptyGame {
    [self initSevenTag];
    _moves = @"*";
    _indexInAllGamesAllTags = -1;
    _editMode = YES;
    _modified = NO;
    _checkMate = NO;
}


- (void) initSevenTag {
    sevenTag = [[NSMutableDictionary alloc] init];
    [sevenTag setValue:@"?" forKey:@"Event"];
    [sevenTag setValue:@"?" forKey:@"Site"];
    [sevenTag setValue:@"????.??.??" forKey:@"Date"];
    [sevenTag setValue:@"?" forKey:@"Round"];
    [sevenTag setValue:@"?" forKey:@"White"];
    [sevenTag setValue:@"?" forKey:@"Black"];
    [sevenTag setValue:@"*" forKey:@"Result"];
}

- (void) setTag:(NSString *)tagName andTagValue:(NSString *)tagValue {
    [sevenTag setValue:tagValue forKey:tagName];
}


- (void) resetTag {
    NSString *oldResult = [sevenTag objectForKey:@"Result"];
    [sevenTag setValue:@"?" forKey:@"Event"];
    [sevenTag setValue:@"?" forKey:@"Site"];
    [sevenTag setValue:@"????.??.??" forKey:@"Date"];
    [sevenTag setValue:@"?" forKey:@"Round"];
    [sevenTag setValue:@"?" forKey:@"White"];
    [sevenTag setValue:@"?" forKey:@"Black"];
    [sevenTag setValue:@"*" forKey:@"Result"];
    if (supplementalTagArray) {
        for (NSString *st in supplementalTagArray) {
            if (![st isEqualToString:@"FEN"] && ![st isEqualToString:@"SetUp"]) {
                if ([st hasSuffix:@"Date"]) {
                    [supplementalTag setObject:@"????.??.??" forKey:st];
                }
                else {
                    [supplementalTag setObject:@"?" forKey:st];
                }
            }
        }
    }
    
    _moves = [_moves stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange range = [_moves rangeOfString:oldResult];
    _moves = [_moves substringToIndex:range.location];
    _moves = [_moves stringByAppendingString:@"*"];
}

- (void) resetTagExceptResult {
    [sevenTag setValue:@"?" forKey:@"Event"];
    [sevenTag setValue:@"?" forKey:@"Site"];
    [sevenTag setValue:@"????.??.??" forKey:@"Date"];
    [sevenTag setValue:@"?" forKey:@"Round"];
    [sevenTag setValue:@"?" forKey:@"White"];
    [sevenTag setValue:@"?" forKey:@"Black"];
    if (supplementalTagArray) {
        for (NSString *st in supplementalTagArray) {
            if (![st isEqualToString:@"FEN"] && ![st isEqualToString:@"SetUp"]) {
                if ([st hasSuffix:@"Date"]) {
                    [supplementalTag setObject:@"????.??.??" forKey:st];
                }
                else {
                    [supplementalTag setObject:@"?" forKey:st];
                }
            }
        }
    }
}

- (BOOL) gameIsPositionWithRegularFen:(NSString *) game {
    NSArray *pgnArray = [originalPgn componentsSeparatedByString:separator];
    for (NSString *tag in pgnArray) {
        if ([tag hasPrefix:@"[FEN"]) {
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:setQuadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            //NSString *tagName = [tagArray objectAtIndex:0];
            NSString *tagValue = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:setDoppiApici];
            //NSLog(@"Tag name = %@      tagvalue = %@", tagName, tagValue);
            NSArray *fenArray = [tagValue componentsSeparatedByString:@" "];
            NSString *numeroMossaString = [fenArray lastObject];
            NSInteger numeroMossa = [numeroMossaString integerValue];
            if (numeroMossa > 1) {
                return NO;
            }
        }
    }
    return YES;
}


- (void) parseGame {
    NSArray *pgnArray = [originalPgn componentsSeparatedByString:separator];
    for (NSString *tag in pgnArray) {
        [self addCompleteTag:tag];
    }
    if ([self isPosition]) {
        fenParser = [[FENParser alloc] initWithFen:[self getTagValueByTagName:@"FEN"]];
    }
}

- (void) parseMoves0 {
    BOOL continua = NO;
    for (int i=0; i<_moves.length; i++) {
        unichar ch = [_moves characterAtIndex:i];
        NSString *car = [NSString stringWithCharacters:&ch length:1];
        if ([car isEqualToString:@"{"]) {
            if (!continua) {
                continua = YES;
            }
        }
        else {
            if (continua) {
                continue;
            }
        }
    }
}

- (void) parseMoves {
    
    
    //NSLog(@"*********PGNGAME PARSEMOVES********");
    
    if ([risultati containsObject:_moves]) {
        if ([self isPosition]) {
            //NSLog(@"HO TROVATO UNA POSIZIONE SENZA MOSSE E SENZA COMMENTO");
            gameType = POSITION_WITHOUT_MOVES;
            return;
        }
        else {
            gameType = GAME_WITHOUT_MOVES;
            //NSLog(@"HO TROVATO UNA PARTITA SENZA MOSSE E SENZA COMMENTO");
            return;
        }
    }
    
    
    //Sostituisco annotazione non regolari con nag
    /*
    NSRange range = [_moves rangeOfString:@"!"];
    if (range.location != NSNotFound) {
        _moves = [_moves stringByReplacingOccurrencesOfString:@"!" withString:@" $1"];
    }
    range = [_moves rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        _moves = [_moves stringByReplacingOccurrencesOfString:@"?" withString:@" $2"];
    }
    range = [_moves rangeOfString:@"!!"];
    if (range.location != NSNotFound) {
        _moves = [_moves stringByReplacingOccurrencesOfString:@"!!" withString:@" $3"];
    }
    range = [_moves rangeOfString:@"??"];
    if (range.location != NSNotFound) {
        _moves = [_moves stringByReplacingOccurrencesOfString:@"??" withString:@" $4"];
    }
    range = [_moves rangeOfString:@"!?"];
    if (range.location != NSNotFound) {
        _moves = [_moves stringByReplacingOccurrencesOfString:@"!?" withString:@" $5"];
    }
    range = [_moves rangeOfString:@"?!"];
    if (range.location != NSNotFound) {
        _moves = [_moves stringByReplacingOccurrencesOfString:@"?!" withString:@" $6"];
    }
    */
    
    
    BOOL mosseContengonoCommento = ([_moves rangeOfString:@"{"].location != NSNotFound) && ([_moves rangeOfString:@"}"].location != NSNotFound);
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    NSString *primoCarattere = [NSString stringWithFormat:@"%c", [_moves characterAtIndex:0]];
    BOOL primoCarattereNumerico = [nf numberFromString:primoCarattere] != nil;
    
    
    if (primoCarattereNumerico) {
        if ([self isPosition]) {
            if (mosseContengonoCommento) {
                //NSLog(@"HO TROVATO UNA POSIZIONE CON MOSSE E COMMENTI");
                gameType = POSITION_WITH_MOVES;
            }
            else {
                gameType = POSITION_WITH_MOVES;
                //NSLog(@"HO TROVATO UNA POSIZIONE CON MOSSE SENZA COMMENTI");
            }
        }
        else {
            if (mosseContengonoCommento) {
                gameType = GAME_WITH_MOVES;
                //NSLog(@"HO TROVATO UNA PARTITA CON MOSSE E COMMENTI");
            }
            else {
                gameType = GAME_WITH_MOVES;
                //NSLog(@"HO TROVATO UNA PARTITA CON MOSSE SENZA COMMENTI");
            }
        }
    }
    else {
        NSArray *movesArray = [_moves componentsSeparatedByString:@"} "];
        //NSArray *movesArray = [_moves componentsSeparatedByString:@"}"];
        NSString *primoCarattereDiOgniOggettoArray;
        BOOL primoCarattereNumericoDiOgniOggettoArray = NO;
        for (NSString *t in movesArray) {
            
            NSString *tSenzaBianchi = [t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            
            //NSLog(@"MOVES ARRAY    %@", tSenzaBianchi);
            
            
            
            if ([risultati containsObject:tSenzaBianchi]) {
                primoCarattereNumericoDiOgniOggettoArray = NO;
            }
            else {
                primoCarattereDiOgniOggettoArray = [NSString stringWithFormat:@"%c", [tSenzaBianchi characterAtIndex:0]];
                primoCarattereNumericoDiOgniOggettoArray = [nf numberFromString:primoCarattereDiOgniOggettoArray] != nil;
                if (primoCarattereNumericoDiOgniOggettoArray) {
                    break;
                }
            }
        }
        if (primoCarattereNumericoDiOgniOggettoArray) {
            if ([self isPosition]) {
                //NSLog(@"HO TROVATO UNA POSIZIONE CON MOSSE E COMMENTO INIZIALE");
                gameType = POSITION_WITH_MOVES;
                return;
            }
            else {
                gameType = GAME_WITH_MOVES;
                //NSLog(@"HO TROVATO UNA PARTITA CON MOSSE E COMMENTO INIZIALE");
                return;
            }
        }
        else {
            if ([self isPosition]) {
                gameType = POSITION_WITHOUT_MOVES;
               // NSLog(@"HO TROVATO UNA POSIZIONE SENZA MOSSE E COMMENTO INIZIALE");
                return;
            }
            else {
                gameType = GAME_WITHOUT_MOVES;
                //NSLog(@"HO TROVATO UNA PARTITA SENZA MOSSE E COMMENTO INIZIALE");
                return;
            }
        }
    }

    //for (int i=0; i<_moves.length; i++) {
    //    NSString *ichar  = [NSString stringWithFormat:@"%c", [_moves characterAtIndex:i]];
    //    NSLog(@"%@", ichar);
    //}
}

- (void) parseFen {
    
}

- (void) stampaSevenTag {
    //for (NSString *tag in sevenTagRoster) {
        //NSString *tagValue = [sevenTag objectForKey:tag];
        //NSLog(@"[%@ \"%@\"]", tag, tagValue);
    //}
}

- (void) addEcoTags:(NSDictionary *)ecoDictionary {
    if (!supplementalTag) {
        supplementalTag = [[NSMutableDictionary alloc] init];
        supplementalTagArray = [[NSMutableArray alloc] init];
    }
    
    [self removeEcoTags];
    
    for (NSString *ecoKey in [ecoDictionary allKeys]) {
        if (![supplementalTagArray containsObject:ecoKey]) {
            [supplementalTagArray addObject:ecoKey];
        }
        [supplementalTag setValue:[ecoDictionary objectForKey:ecoKey] forKey:ecoKey];
    }
}

- (void) removeEcoTags {
    [self removeTag:@"ECO"];
    [self removeTag:@"Opening"];
    [self removeTag:@"Variation"];
    [self removeTag:@"SubVariation"];
}

- (void) addSupplementalTag:(NSString *)suppTag andTagValue:(NSString *)suppTagValue {
    if (!supplementalTag) {
        supplementalTag = [[NSMutableDictionary alloc] init];
        supplementalTagArray = [[NSMutableArray alloc] init];
    }
    if (![supplementalTagArray containsObject:suppTag]) {
        [supplementalTagArray addObject:suppTag];
    }
    [supplementalTag setValue:suppTagValue forKey:suppTag];
}

- (void) saveSupplementalTag:(NSDictionary *)suppTagDictionary {
    supplementalTag = [[NSMutableDictionary alloc] init];
    supplementalTagArray = [[NSMutableArray alloc] init];
    for (NSString *tag in suppTagDictionary.allKeys) {
        NSString *tagValue = [suppTagDictionary objectForKey:tag];
        [supplementalTagArray addObject:tag];
        [supplementalTag setValue:tagValue forKey:tag];
    }
}

- (void) savePositionTag:(NSDictionary *)positionTagDictionary {
    [self addSupplementalTag:@"SetUp" andTagValue:[positionTagDictionary objectForKey:@"SetUp"]];
    [self addSupplementalTag:@"FEN" andTagValue:[positionTagDictionary objectForKey:@"FEN"]];
}

- (NSUInteger) getNumberOfSupplementalTag {
    return supplementalTagArray.count;
}

- (NSString *) getSupplementalTagValueByIndex:(NSUInteger)index {
    NSString *key = [supplementalTagArray objectAtIndex:index];
    //NSString *risu = [[key stringByAppendingString:@": "] stringByAppendingString:[supplementalTag objectForKey:key]];
    return [supplementalTag objectForKey:key];
}

- (NSString *) getSupplementalTagByIndex:(NSUInteger)index {
    return [supplementalTagArray objectAtIndex:index];
}

- (BOOL) supplementalTagIsPresent:(NSString *)supplementalTagName {
    if ([supplementalTagArray containsObject:supplementalTagName]) {
        return YES;
    }
    return NO;
}

- (void) stampaTag {
    [self stampaSevenTag];
    //for (NSString *tagKey in [supplementalTag allKeys]) {
        //NSString *tagValue = [supplementalTag objectForKey:tagKey];
        //NSLog(@"[%@ \"%@\"]", tagKey, tagValue);
    //}
}

- (void) printGame {
    [self stampaTag];
    //NSLog(@"%@", _moves);
}

- (void) printCompleteGame {
    NSMutableString *completeGame = [[NSMutableString alloc] init];
    for (NSString *tag in sevenTagRoster) {
        NSString *tagValue = [sevenTag objectForKey:tag];
        NSString *t = [NSString stringWithFormat:@"[%@ \"%@\"]", tag, tagValue];
        [completeGame appendString:t];
        [completeGame appendString:@"\n"];
    }
    for (NSString *k in supplementalTagArray) {
        NSString *st = [supplementalTag objectForKey:k];
        NSString *t = [NSString stringWithFormat:@"[%@ \"%@\"]", k, st];
        [completeGame appendString:t];
        [completeGame appendString:@"\n"];
    }
    [completeGame appendString:@"\n"];
    [completeGame appendString:_moves];
    [completeGame appendString:@"\n"];
    //NSLog(@"%@", completeGame);
}

- (NSString *) getCompleteGame {
    NSMutableString *completeGame = [[NSMutableString alloc] init];
    for (NSString *tag in sevenTagRoster) {
        NSString *tagValue = [sevenTag objectForKey:tag];
        NSString *t = [NSString stringWithFormat:@"[%@ \"%@\"]", tag, tagValue];
        [completeGame appendString:t];
        [completeGame appendString:@"\n"];
    }
    [completeGame appendString:@"\n"];
    [completeGame appendString:_moves];
    [completeGame appendString:@"\n"];
    return completeGame;
}

- (NSString *) getTagValueByTagName:(NSString *)tagName {
    if ([sevenTagRoster containsObject:tagName]) {
        NSString *tagValue = [sevenTag objectForKey:tagName];
        //tagValue = [self getTagvalueSenzaPuntiInterrogativi:tagValue];
        return tagValue;
    }
    return [supplementalTag objectForKey:tagName];
}

- (NSString *) getTagValueByTagName:(NSString *)tagName withQuotes:(BOOL)quotes {
    NSString *tagValue = [self getTagValueByTagName:tagName];
    if (quotes) {
        NSString *tagValueWithQuotes = [NSString stringWithFormat:@"\"%@\"", tagValue];
        return tagValueWithQuotes;
    }
    return tagValue;
}

- (NSString *) getTagInBrackets:(NSString *)tagName {
    NSString *tagValue = [self getTagValueByTagName:tagName withQuotes:YES];
    NSString *tagInBrackets = [NSString stringWithFormat:@"[%@ %@]", tagName, tagValue];
    return tagInBrackets;
}


- (void) addCompleteTag2:(NSString *)completeTag {  //Metodo aggiunto per sostituire il metodo addCompleteTag che poneva il numero mosse = 1 nel tag FEN
    if ([completeTag hasPrefix:@"["]) {
        NSString *tagSenzaQuadre = [completeTag stringByTrimmingCharactersInSet:setQuadre];
        NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
        NSString *tagName = [tagArray objectAtIndex:0];
        NSString *tagValue = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:setDoppiApici];
        tagValue = [tagValue stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        tagValue = [self checkTagValue:tagName :tagValue];
        
        if ([sevenTagRoster containsObject:tagName]) {
            [self setTag:tagName andTagValue:tagValue];
        }
        else {
            [self addSupplementalTag:tagName andTagValue:tagValue];
        }
    }
    else if ([risultati containsObject:completeTag]) {
        if ([self isPosition]) {
            //NSLog(@"Ho trovato una posizione senza mosse");
            gameType = POSITION_WITHOUT_MOVES;
        }
        else {
            //NSLog(@"HO trovato una partita senza mosse");
            gameType = GAME_WITHOUT_MOVES;
        }
        result = completeTag;
        _moves = completeTag;
    }
    else {
        if ([completeTag hasSuffix:@"*"]) {
            result = @"*";
        }
        else if ([completeTag hasSuffix:@"-0"]) {
            result = @"1-0";
        }
        else if ([completeTag hasSuffix:@"-1"]) {
            result = @"0-1";
        }
        else if ([completeTag hasSuffix:@"-1/2"]) {
            result = @"1/2-1/2";
        }
            
        if ([self isPosition]) {
            //NSLog(@"Ho trovato una posizione con mosse");
            gameType = POSITION_WITH_MOVES;
        }
        else {
            //NSLog(@"HO trovato una partita con mosse");
            gameType = GAME_WITH_MOVES;
        }
        _moves = completeTag;
        }
}

- (void) addCompleteTag:(NSString *)completeTag {
    
    [self addCompleteTag2:completeTag];
    return;
    
    //NSLog(@"COMPLETE TAG = %@", completeTag);
    
    if ([completeTag hasPrefix:@"["]) {
        NSString *tagSenzaQuadre = [completeTag stringByTrimmingCharactersInSet:setQuadre];
        NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
        NSString *tagName = [tagArray objectAtIndex:0];
        NSString *tagValue = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:setDoppiApici];
        tagValue = [tagValue stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        //NSLog(@"PGN_GAME:   TagName:%@      TagValue:%@", tagName, tagValue);
        
        tagValue = [self checkTagValue:tagName :tagValue];
        
        
        
        if ([sevenTagRoster containsObject:tagName]) {
            [self setTag:tagName andTagValue:tagValue];
        }
        else {
            if ([tagName isEqualToString:@"FEN"]) {
                //NSLog(@"Devo controllare FEN = %@", tagValue);
                NSArray *fenArray = [tagValue componentsSeparatedByString:@" "];
                NSString *numeroMossaString = [fenArray lastObject];
                NSInteger numeroMossa = [numeroMossaString integerValue];
                if (numeroMossa > 1) {
                    
                    //[NSException raise:@"WRONG_FEN_EXCEPTION" format:@"FEN Not Ok"];
                    //return;
                    
                    
                    NSMutableString *newFenValue = [[NSMutableString alloc] init];
                    for (int i=0; i<fenArray.count-1; i++) {
                        if (i==0) {
                            [newFenValue appendString:[fenArray objectAtIndex:i]];
                        }
                        else {
                            [newFenValue appendString:@" "];
                            [newFenValue appendString:[fenArray objectAtIndex:i]];
                        }
                    }
                    [newFenValue appendString:@" "];
                    [newFenValue appendString:@"1"];
                    //NSLog(@"VECCHIO FEN = %@", tagValue);
                    tagValue = newFenValue;
                    //NSLog(@"NUOVO FEN = %@", tagValue);
                }
            }
            [self addSupplementalTag:tagName andTagValue:tagValue];
        }
    }
    else if ([risultati containsObject:completeTag]) {
        if ([self isPosition]) {
            //NSLog(@"Ho trovato una posizione senza mosse");
            gameType = POSITION_WITHOUT_MOVES;
        }
        else {
            //NSLog(@"HO trovato una partita senza mosse");
            gameType = GAME_WITHOUT_MOVES;
        }
        result = completeTag;
        _moves = completeTag;
    }
    //else if ([completeTag hasPrefix:@"{"]) {
        
    //}
    else {
        if ([completeTag hasSuffix:@"*"]) {
            result = @"*";
        }
        else if ([completeTag hasSuffix:@"-0"]) {
            result = @"1-0";
        }
        else if ([completeTag hasSuffix:@"-1"]) {
            result = @"0-1";
        }
        else if ([completeTag hasSuffix:@"-1/2"]) {
            result = @"1/2-1/2";
        }
        
        if ([self isPosition]) {
            //NSLog(@"Ho trovato una posizione con mosse");
            gameType = POSITION_WITH_MOVES;
        }
        else {
            //NSLog(@"HO trovato una partita con mosse");
            gameType = GAME_WITH_MOVES;
        }
        _moves = completeTag;
    }
    
    //NSLog(@"Tag = %@", tagName);
    //NSLog(@"Tag Value = %@", tagValue);
}


- (NSString *)checkTagValue:(NSString *)tagName :(NSString *)tagValue {
    
    if ([tagName hasSuffix:@"Date"]) {
        
        NSDateFormatter *regularFormatter = [[NSDateFormatter alloc] init];
        regularFormatter.dateFormat = @"yyyy.MM.dd";
        
        
        if (tagValue.length == 10) {
            //NSLog(@"La data è corretta");
            NSDate *date = [regularFormatter dateFromString:tagValue];
            if (date) {
                return tagValue;
            }
        }
        else {
            //NSLog(@"La data non è corretta");
            NSArray *dataArray = [tagValue componentsSeparatedByString:@"."];
            if (dataArray.count == 1) {
                NSString *s = [dataArray objectAtIndex:0];
                if (s.length == 4) {
                    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
                    yearFormatter.dateFormat = @"yyyy";
                    NSDate *yearDate = [yearFormatter dateFromString:s];
                    if (yearDate) {
                        NSString *newDate = [regularFormatter stringFromDate:yearDate];
                        return newDate;
                    }
                }
            }
            else if (dataArray.count == 2) {
                NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
                yearFormatter.dateFormat = @"yyyy.MM";
                NSDate *yearDate = [yearFormatter dateFromString:tagValue];
                if (yearDate) {
                    NSString *newDate = [regularFormatter stringFromDate:yearDate];
                    return newDate;
                }
            }
        }
        //return @"????.??.??";
    }
    
    return tagValue;
}



- (void) removeTag:(NSString *)tagName {
    [supplementalTagArray removeObject:tagName];
    [supplementalTag removeObjectForKey:tagName];
}

- (NSString *) getOriginalPgn {
    return originalPgn;
}

- (NSString *) getTagvalueSenzaPuntiInterrogativi:(NSString *)tagValue {
    tagValue = [tagValue stringByReplacingOccurrencesOfString:@"?" withString:@""];
    tagValue = [tagValue stringByTrimmingCharactersInSet:setPunti];
    return tagValue;
}

- (BOOL) isNewGame {
    
    if (_indexInAllGamesAllTags > -1) {
        return NO;
    }
    
    NSString *white = [self getTagValueByTagName:@"White"];
    NSString *black = [self getTagValueByTagName:@"Black"];
    if ([white hasSuffix:@"?"] && [black hasSuffix:@"?"]) {
        return YES;
    }
    if ((white.length == 0) && (black.length == 0)) {
        return YES;
    }
    return NO;
}

- (BOOL) isPosition {
    if ([supplementalTagArray containsObject:@"FEN"] && [supplementalTagArray containsObject:@"SetUp"]) {
        if ([[self getTagValueByTagName:@"SetUp"] isEqualToString:@"1"]) {
            return YES;
        }
    }
    return NO;
}


- (NSString *) getGameForFile {
    NSMutableString *gameForFile = [[NSMutableString alloc] init];
    for (NSString *tag in sevenTagRoster) {
        NSString *tagValue = [sevenTag objectForKey:tag];
        NSString *t = [NSString stringWithFormat:@"[%@ \"%@\"]", tag, tagValue];
        [gameForFile appendString:t];
        [gameForFile appendString:separator];
    }
    if (_moves) {
        [gameForFile appendString:_moves];
    }
    return gameForFile;
}

- (NSString *) getGameForCopy {
    NSMutableString *gameForCopy = [[NSMutableString alloc] init];
    for (NSString *tag in sevenTagRoster) {
        NSString *tagValue = [sevenTag objectForKey:tag];
        NSString *t = [NSString stringWithFormat:@"[%@ \"%@\"]", tag, tagValue];
        [gameForCopy appendString:t];
        [gameForCopy appendString:@"\n"];
    }
    for (NSString *k in supplementalTagArray) {
        NSString *st = [supplementalTag objectForKey:k];
        NSString *t = [NSString stringWithFormat:@"[%@ \"%@\"]", k, st];
        [gameForCopy appendString:t];
        [gameForCopy appendString:@"\n"];
    }
    if (_moves) {
        [gameForCopy appendString:@"\n"];
        [gameForCopy appendString:_moves];
    }
    return gameForCopy;
}

- (NSString *) getGameForMail {
    NSMutableString *gameForFile = [[NSMutableString alloc] init];
    for (NSString *tag in sevenTagRoster) {
        NSString *tagValue = [sevenTag objectForKey:tag];
        NSString *t = [NSString stringWithFormat:@"[%@ \"%@\"]", tag, tagValue];
        [gameForFile appendString:t];
        [gameForFile appendString:@"\n"];
    }
    for (NSString *k in supplementalTagArray) {
        NSString *st = [supplementalTag objectForKey:k];
        NSString *t = [NSString stringWithFormat:@"[%@ \"%@\"]", k, st];
        [gameForFile appendString:t];
        [gameForFile appendString:@"\n"];
    }
    if (_moves) {
        [gameForFile appendString:@"\n"];
        NSString *mosseSenzaXXX = [_moves stringByReplacingOccurrencesOfString:@"1. XXX" withString:@"1..."];
        [gameForFile appendString:mosseSenzaXXX];
    }
    return gameForFile;
}

- (NSString *) getGameMovesForPreview {
    NSMutableString *gameMovesForPreview = [[NSMutableString alloc] init];
    if (_moves) {
        [gameMovesForPreview appendString:@"\n"];
        NSString *mosseSenzaXXX = [_moves stringByReplacingOccurrencesOfString:@"1. XXX" withString:@"1..."];
        [gameMovesForPreview appendString:mosseSenzaXXX];
    }
    return gameMovesForPreview;
}

- (NSString *) getGameForAllGamesAndAllTags {
    NSMutableString *gameForAllGamesAndAllTags = [[NSMutableString alloc] init];
    for (NSString *tag in sevenTagRoster) {
        NSString *tagValue = [sevenTag objectForKey:tag];
        NSString *t = [NSString stringWithFormat:@"[%@ \"%@\"]", tag, tagValue];
        [gameForAllGamesAndAllTags appendString:t];
        [gameForAllGamesAndAllTags appendString:separator];
    }
    for (NSString *k in supplementalTagArray) {
        NSString *st = [supplementalTag objectForKey:k];
        NSString *t = [NSString stringWithFormat:@"[%@ \"%@\"]", k, st];
        [gameForAllGamesAndAllTags appendString:t];
        [gameForAllGamesAndAllTags appendString:separator];
    }
    if (_moves) {
        [gameForAllGamesAndAllTags appendString:_moves];
    }
    return gameForAllGamesAndAllTags;
}

- (NSArray *) getOriginalGameArray {
    NSString *game = originalPgn;
    if ([game rangeOfString:separator].length == 0) {
        game = [originalPgn stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    }
    return [game componentsSeparatedByString:separator];
}

- (NSArray *) getGameArray {
    NSMutableArray *gameArray = [[NSMutableArray alloc] init];
    for (NSString *tag in sevenTagRoster) {
        NSString *tagValue = [sevenTag objectForKey:tag];
        NSString *finalTagValue = [NSString stringWithFormat:@"[%@ \"%@\"]", tag, tagValue];
        [gameArray addObject:finalTagValue];
    }
    for (NSString *key in supplementalTagArray) {
        NSString *tagValue = [supplementalTag objectForKey:key];
        NSString *finalTagValue = [NSString stringWithFormat:@"[%@ \"%@\"]", key, tagValue];
        [gameArray addObject:finalTagValue];
    }
    if (_moves) {
        [gameArray addObject:_moves];
    }
    return gameArray;
}

- (NSMutableDictionary *) getSevenTag {
    NSMutableDictionary *tagDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *tag in sevenTagRoster) {
        NSString *tagValue = [sevenTag objectForKey:tag];
        [tagDictionary setObject:tagValue forKey:tag];
    }
    return tagDictionary;
}

- (NSMutableDictionary *) getSupplementalTag {
    NSMutableDictionary *tagDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *tag in supplementalTagArray) {
        NSString *tagValue = [supplementalTag objectForKey:tag];
        [tagDictionary setObject:tagValue forKey:tag];
    }
    return tagDictionary;
}

- (NSMutableDictionary *) getSupplementalTagApp {
    NSMutableDictionary *tagDictionary = [[NSMutableDictionary alloc] init];
    NSArray *orderedSuppTags = [UtilToView getOrderedSuppTags];
    for (NSString *tag in supplementalTagArray) {
        if ([orderedSuppTags containsObject:tag]) {
            NSString *tagValue = [supplementalTag objectForKey:tag];
            [tagDictionary setObject:tagValue forKey:tag];
        }
    }
    return tagDictionary;
}

- (NSMutableDictionary *) getOtherTagApp {
    NSMutableDictionary *tagDictionary = [[NSMutableDictionary alloc] init];
    NSArray *orderedSuppTags = [UtilToView getOrderedSuppTags];
    NSArray *positionTags = [UtilToView getPositionTags];
    for (NSString *tag in supplementalTagArray) {
        if (![orderedSuppTags containsObject:tag] && ![positionTags containsObject:tag]) {
            NSString *tagValue = [supplementalTag objectForKey:tag];
            [tagDictionary setObject:tagValue forKey:tag];
        }
    }
    return tagDictionary;
}

- (NSMutableDictionary *) getPositionTagDict {
    NSMutableDictionary *tagDictionary = [[NSMutableDictionary alloc] init];
    if ([self isPosition]) {
        NSString *setupValue = [supplementalTag objectForKey:@"SetUp"];
        NSString *fenValue = [supplementalTag objectForKey:@"FEN"];
        [tagDictionary setObject:setupValue forKey:@"SetUp"];
        [tagDictionary setObject:fenValue forKey:@"FEN"];
    }
    return tagDictionary;
}

- (NSMutableArray *) getOrderedSuppTag {
    NSMutableArray *orderedSuppTag = [[NSMutableArray alloc] init];
    for (NSString *tag in supplementalTagArray) {
        [orderedSuppTag addObject:tag];
    }
    return orderedSuppTag;
}

- (NSString *) getFenPosition {
    return [self getTagValueByTagName:@"FEN"];
}

- (void) aggiornaOrdineTagArray:(NSArray *)tagArray {
    for (int i=0; i<tagArray.count; i++) {
        if (i>6) {
            NSString *vecchioTag = [supplementalTagArray objectAtIndex:i-7];
            NSLog(@"Posizione Vecchio %d  tag = %@", i-7, vecchioTag);
            NSString *nuovoTag = [[[[tagArray objectAtIndex:i] componentsSeparatedByString:@"\""] objectAtIndex:0]stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
            NSLog(@"Posizione Nuovo %d  tag = %@", i-7, nuovoTag);
            [supplementalTagArray replaceObjectAtIndex:i-7 withObject:nuovoTag];
        }
    }
}

- (void) replaceTagAndTagValue:(NSString *)tagName :(NSString *)tagValue {
    //NSLog(@"Sto eseguendo replaceTagAndTagVAlue");
    if ([sevenTagRoster containsObject:tagName]) {
        if ([tagName isEqualToString:@"Result"]) {
            NSString *oldResult = [sevenTag objectForKey:@"Result"];
            //NSLog(@"Old Result = %@", oldResult);
            [sevenTag setObject:tagValue forKey:tagName];
            //NSLog(@"Mosse prima di aggiornamento risultato: %@", _moves);
            _moves = [_moves stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSRange range = [_moves rangeOfString:oldResult];
            //NSLog(@"Location %d    Length %d", range.location, range.length);
            
            if (range.location > _moves.length) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Non posso aggiornare" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [av show];
                return;
            }
            
            _moves = [_moves substringToIndex:range.location];
            _moves = [_moves stringByAppendingString:tagValue];
            result = tagValue;
            //NSLog(@"Mosse dopo di aggiornamento risultato: %@", _moves);
        }
        else {
            [sevenTag setObject:tagValue forKey:tagName];
        }
    }
    else if ([supplementalTagArray containsObject:tagName]) {
        [supplementalTag setObject:tagValue forKey:tagName];
    }
    //NSLog(@"Ho eseguito replaceTagAndTagValue");
}

- (void) replaceOnlyTagAndTagValue:(NSString *)tagName :(NSString *)tagValue {
    if ([sevenTagRoster containsObject:tagName]) {
        [sevenTag setObject:tagValue forKey:tagName];
        if ([tagName isEqualToString:@"Result"]) {
            result = tagValue;
        }
    }
}

- (BOOL) userCanEditGameData {
    if (_moves.length>0) {
        return YES;
    }
    return NO;
}

- (BOOL) sevenTagsAreAllEmpty {
    for (NSString *tag in [sevenTag allKeys]) {
        NSString *tagValue = [sevenTag objectForKey:tag];
        if ([tag isEqualToString:@"Result"]) {
            if (![tagValue isEqualToString:@"*"]) {
                return NO;
            }
        }
        else if (![tagValue hasPrefix:@"?"]) {
            return NO;
        }
    }
    return YES;
}

- (NSUInteger) getGameType {
    if ([self isPosition]) {
        if ([risultati containsObject:_moves]) {
            gameType = POSITION_WITHOUT_MOVES;
        }
        else {
            gameType = POSITION_WITH_MOVES;
        }
    }
    else {
        if ([risultati containsObject:_moves]) {
            gameType = GAME_WITHOUT_MOVES;
        }
        else {
            gameType = GAME_WITH_MOVES;
        }
    }
    return gameType;
}


- (void) stampaMosse {
    NSLog(@"%@", _moves);
}

- (NSString *) moves {
    
    for (NSString *r in risultati) {
        _moves = [_moves stringByReplacingOccurrencesOfString:r withString:@""];
    }
    
    switch ([self getGameType]) {
        case POSITION_WITHOUT_MOVES:
            NSLog(@"Devo restituire le mosse per posizione senza mosse");
            //NSLog(@"Dovrei restituire %@", _moves);
            if ([_moves hasPrefix:@"{"]) {
                NSArray *mArray = [_moves componentsSeparatedByString:@"}"];
                NSString *commento = [[mArray objectAtIndex:0] stringByAppendingString:@"}"];
                //NSString *risultato = [mArray objectAtIndex:1];
                //NSLog(@">>>>%@", commento);
                //NSLog(@">>>>%@", risultato);
                
                if ([fenParser whiteHasToMove]) {
                    return [[commento stringByAppendingString:@" "] stringByAppendingString:result];
                }
                else {
                    return [[commento stringByAppendingString:@" 1. XXX "] stringByAppendingString:result];
                }
                
                //return _moves;
            }
            if ([fenParser whiteHasToMove]) {
                return result;
                //return _moves;
            }
            else {
                return [@"1. XXX " stringByAppendingString:result];
            }
            break;
        case POSITION_WITH_MOVES:
            //NSLog(@"Devo restituire le mosse per posizione con mosse");
            //return _moves;
            _moves = [_moves stringByAppendingString:result];
            return _moves;
        case GAME_WITHOUT_MOVES:
            //NSLog(@"Devo restituire le mosse per partita senza mosse");
            return [self getMovesInGameWithoutMoves];
        case GAME_WITH_MOVES:
            //NSLog(@"Devo restituire le mosse per partita con mosse");
            //NSLog(@"Dovrei restituire %@  con result = %@", _moves, result);
            _moves = [_moves stringByAppendingString:result];
            //NSLog(@"Dovrei restituire %@", _moves);
            return _moves;
            //return [_moves stringByAppendingString:result];
        default:
            break;
    }
    _moves = [_moves stringByAppendingString:result];
    return _moves;
}



- (NSString *) getMovesInPositionWithoutMoves {
    if (_movesInPositionWithoutMoves) {
        return _movesInPositionWithoutMoves;
    }
    NSString *movesAndResult = [[fenParser getNumeroMossaToDisplay] stringByAppendingString:result];
    return movesAndResult;
}

- (NSString *) getMovesInGameWithoutMoves {
    return _moves;
}

- (NSString *) getMovesForPreview {
    switch ([self getGameType]) {
        case POSITION_WITHOUT_MOVES:
            //NSLog(@"Devo restituire le mosse per posizione senza mosse");
            //return result;
            return _moves;
            break;
        case POSITION_WITH_MOVES:
            //NSLog(@"Devo restituire le mosse per posizione con mosse");
            return _moves;
        case GAME_WITHOUT_MOVES:
            //NSLog(@"Devo restituire le mosse per partita senza mosse");
            return result;
        case GAME_WITH_MOVES:
            //NSLog(@"Devo restituire le mosse per partita con mosse");
            return _moves;
        default:
            break;
    }
    return nil;
}

- (FENParser *) getFenParser {
    return fenParser;
}

- (NSUInteger) getStartPlycount {
    if ([self isPosition]) {
        return [fenParser getNumeroSemiMossa] - 1;
    }
    return 0;
}

- (NSString *) getTitleWhiteAndBlack {
    NSString *w = [self getTagValueByTagName:@"White"];
    NSString *b = [self getTagValueByTagName:@"Black"];
    return [[w stringByAppendingString:@"-"] stringByAppendingString:b];
}


#pragma mark = Metodo statico utilizzato per porre a 1 il valore della mossa iniziale quando è presente una posizione con FEN

+ (BOOL) gameIsPositionWithRegularFen2:(NSString *)gameSel {  //Metodo inserito per risolvere il problema della numerazione delle mosse in una posizione
    NSMutableCharacterSet *quadre = [[NSMutableCharacterSet alloc] init];
    [quadre addCharactersInString:@"[]"];
    NSMutableCharacterSet *doppiApici = [[NSMutableCharacterSet alloc] init];
    [doppiApici addCharactersInString:@"\""];
    
    NSArray *pgnArray = [gameSel componentsSeparatedByString:separator];
    
    for (NSString *tag in pgnArray) {
        if ([tag hasPrefix:@"[FEN"]) {
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:quadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            NSString *tagValue = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:doppiApici];
            temporaryFen = tagValue;
            NSArray *fenArray = [tagValue componentsSeparatedByString:@" "];
            NSString *numeroMossaString = [fenArray lastObject];
            NSInteger numeroMossa = [numeroMossaString integerValue];
            if (numeroMossa > 1) {
                NSLog(@"La posizione inizia con un numero mossa > 1");
            }
            return YES;
        }
    }
    return YES;
}

+ (NSInteger) getMoveNumberInFen:(NSString *)gameSel {
    NSMutableCharacterSet *quadre = [[NSMutableCharacterSet alloc] init];
    [quadre addCharactersInString:@"[]"];
    NSMutableCharacterSet *doppiApici = [[NSMutableCharacterSet alloc] init];
    [doppiApici addCharactersInString:@"\""];
    NSArray *pgnArray = [gameSel componentsSeparatedByString:separator];
    for (NSString *tag in pgnArray) {
        if ([tag hasPrefix:@"[FEN"]) {
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:quadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            NSString *tagValue = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:doppiApici];
            NSLog(@"TAG = %@", tagValue);
            temporaryFen = tagValue;
            NSArray *fenArray = [tagValue componentsSeparatedByString:@" "];
            NSString *numeroMossaString = [fenArray lastObject];
            NSInteger numeroMossa = [numeroMossaString integerValue];
            return numeroMossa;
        }
    }
    return 0;
}

+ (NSInteger) getMoveNumberInGame:(NSString *)gameSel {
    NSArray *pgnArray = [gameSel componentsSeparatedByString:separator];
    NSString *moves = [pgnArray lastObject];
    //NSLog(@"Devo analizzare %@", moves);
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    NSString *primoCarattere = [NSString stringWithFormat:@"%c", [moves characterAtIndex:0]];
    BOOL primoCarattereNumerico = [nf numberFromString:primoCarattere] != nil;
    
    if (primoCarattereNumerico) {
        NSInteger numeroMossa = [primoCarattere integerValue];
        return numeroMossa;
    }
    else {
        NSArray *movesArray = [moves componentsSeparatedByString:@"} "];
        NSString *primoCarattereDiOgniOggettoArray;
        BOOL primoCarattereNumericoDiOgniOggettoArray = NO;
        for (NSString *t in movesArray) {
            NSString *tSenzaBianchi = [t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            
            if ([risultati containsObject:tSenzaBianchi]) {
                primoCarattereNumericoDiOgniOggettoArray = NO;
            }
            else {
                primoCarattereDiOgniOggettoArray = [NSString stringWithFormat:@"%c", [tSenzaBianchi characterAtIndex:0]];
                primoCarattereNumericoDiOgniOggettoArray = [nf numberFromString:primoCarattereDiOgniOggettoArray] != nil;
                if (primoCarattereNumericoDiOgniOggettoArray) {
                    break;
                }
            }
        }
        if (primoCarattereNumericoDiOgniOggettoArray) {
            NSInteger numeroMossa = [primoCarattereDiOgniOggettoArray integerValue];
            return numeroMossa;
        }
        
    }
    return 0;
}

+ (NSString *) getCorrectedGame:(NSString *)gameSel {
    NSMutableCharacterSet *quadre = [[NSMutableCharacterSet alloc] init];
    [quadre addCharactersInString:@"[]"];
    NSMutableCharacterSet *doppiApici = [[NSMutableCharacterSet alloc] init];
    [doppiApici addCharactersInString:@"\""];
    NSString *fen = nil;
    NSString *setup = nil;
    NSArray *pgnAr = [gameSel componentsSeparatedByString:separator];
    for (NSString *tag in pgnAr) {
        if ([tag hasPrefix:@"[FEN"]) {
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:quadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            fen = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:doppiApici];
        }
        else if ([tag hasPrefix:@"[SetUp"]) {
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:quadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            setup = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:doppiApici];
        }
    }
    //NSArray *fenArray = [fen componentsSeparatedByString:@" "];
    NSMutableString *fenMutable = [[NSMutableString alloc] initWithString:fen];
    
    if ([fen hasSuffix:@"-"]) {
        [fenMutable appendString:@" "];
        [fenMutable appendString:@"0"];
        [fenMutable appendString:@" "];
        NSInteger nm = [self getMoveNumberInGame:gameSel];
        [fenMutable appendString:[NSString stringWithFormat:@"%ld", (long)nm]];
    }
    
    NSString *newSetup = @"[SetUp \"1\"]";
    NSString *newFen = [NSString stringWithFormat:@"[FEN \"%@\"]", fenMutable];
    
    NSMutableString *posizioneCorretta = [[NSMutableString alloc] init];
    for (NSString *t in pgnAr) {
        if ([t hasPrefix:@"[FEN"]) {
            if (!setup) {
                [posizioneCorretta appendString:newSetup];
                [posizioneCorretta appendString:separator];
            }
            [posizioneCorretta appendString:newFen];
            [posizioneCorretta appendString:separator];
        }
        else {
            [posizioneCorretta appendString:t];
            [posizioneCorretta appendString:separator];
            //if (![pgnAr indexOfObject:t] == pgnAr.count - 1) {
                //[posizioneCorretta appendString:separator];
            //}
        }
    }
    
    NSString *game = [posizioneCorretta stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:separator]];
    //NSLog(@"%@", game);
    return game;
}


+ (BOOL) gameIsPositionWithRegularFen3:(NSString *)gameSel {
    NSMutableCharacterSet *quadre = [[NSMutableCharacterSet alloc] init];
    [quadre addCharactersInString:@"[]"];
    NSMutableCharacterSet *doppiApici = [[NSMutableCharacterSet alloc] init];
    [doppiApici addCharactersInString:@"\""];
    
    NSString *fen = nil;
    NSString *setup = nil;
    NSArray *pgnAr = [gameSel componentsSeparatedByString:separator];
    for (NSString *tag in pgnAr) {
        if ([tag hasPrefix:@"[FEN"]) {
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:quadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            fen = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:doppiApici];
        }
        else if ([tag hasPrefix:@"[SetUp"]) {
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:quadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            setup = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:doppiApici];
        }
    }
    
    if (!fen && !setup) {
        //NSLog(@"La partita non è una posizione!");
        return YES;
    }
    
    if (fen) {
        NSArray *fenArray = [fen componentsSeparatedByString:@" "];
        if ([fenArray count] < 6) {
            //NSLog(@"Posizione con FEN non corretto");
            
            
            NSMutableString *fenMutable = [[NSMutableString alloc] initWithString:fen];
            if ([fen hasSuffix:@"-"]) {
                [fenMutable appendString:@" "];
                [fenMutable appendString:@"0"];
                [fenMutable appendString:@" "];
                NSInteger nm = [self getMoveNumberInGame:gameSel];
                [fenMutable appendString:[NSString stringWithFormat:@"%ld", (long)nm]];
            }
            
            //NSLog(@"NUOVO FEN:%@", fenMutable);
            
            NSString *newSetup = @"[SetUp \"1\"]";
            NSString *newFen = [NSString stringWithFormat:@"[FEN \"%@\"]", fenMutable];
            
            NSMutableString *posizioneCorretta = [[NSMutableString alloc] init];
            for (NSString *t in pgnAr) {
                if ([t hasPrefix:@"[FEN"]) {
                    if (!setup) {
                        [posizioneCorretta appendString:newSetup];
                        [posizioneCorretta appendString:separator];
                    }
                    [posizioneCorretta appendString:newFen];
                    [posizioneCorretta appendString:separator];
                }
                else {
                    [posizioneCorretta appendString:t];
                    [posizioneCorretta appendString:separator];
                }
            }
            
            
            //NSLog(@"NUOVO GAME:%@", posizioneCorretta);
            
            return NO;
            
            //NSInteger numeroMossaFen = [self getMoveNumberInFen:gameSel];
            //NSInteger numeroMossaGame = [self getMoveNumberInGame:gameSel];
            
            //NSLog(@"Numero Prima Mossa in FEN = %ld", (long)numeroMossaFen);
            //NSLog(@"Numero Prima Mossa in Game = %ld", (long)numeroMossaGame);
            
            return NO;
        }
    }
    return @"NO";
}


+ (BOOL) gameIsPositionWithRegularFen:(NSString *)gameSel {
    
    //NSInteger numeroMossaFen = [self getMoveNumberInFen:gameSel];
    //NSInteger numeroMossaGame = [self getMoveNumberInGame:gameSel];
    
    //NSLog(@"Numero Prima Mossa in FEN = %ld", (long)numeroMossaFen);
    //NSLog(@"Numero Prima Mossa in Game = %ld", (long)numeroMossaGame);
    
    BOOL checkNumber3 = [self gameIsPositionWithRegularFen3:gameSel];
    if (checkNumber3) {
        //NSLog(@"Game is not a position or it is a correct position.");
        return YES;
    }
    else {
        //NSLog(@"Game is not a correct position");
        return NO;
    }
    
    return [self gameIsPositionWithRegularFen2:gameSel];
    
    
    
    
    
    
    //Controllo validità FEN
    NSMutableCharacterSet *quadre = [[NSMutableCharacterSet alloc] init];
    [quadre addCharactersInString:@"[]"];
    NSMutableCharacterSet *doppiApici = [[NSMutableCharacterSet alloc] init];
    [doppiApici addCharactersInString:@"\""];
    NSString *fen = nil;
    NSString *setup = nil;
    NSArray *pgnAr = [gameSel componentsSeparatedByString:separator];
    for (NSString *tag in pgnAr) {
        if ([tag hasPrefix:@"[FEN"]) {
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:quadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            fen = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:doppiApici];
        }
        else if ([tag hasPrefix:@"[SetUp"]) {
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:quadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            setup = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:doppiApici];
        }
    }
    
    //FENParser *fenParser = [[FENParser alloc] initWithFen:fen];
    
    NSLog(@"Ho trovato questo FEN: %@", fen);
    NSArray *fenArray = [fen componentsSeparatedByString:@" "];
    if (fenArray.count<6) {
        NSLog(@"FEN NON CORRETTO");
    }
    else {
        NSLog(@"FEN CORRETTO");
    }
    if (setup) {
        NSLog(@"Tag setup OK");
    }
    else {
        NSLog(@"TAG SETUP MANCANTE");
    }
    
    NSMutableString *fenMutable = [[NSMutableString alloc] initWithString:fen];
    
    if ([fen hasSuffix:@"-"]) {
        [fenMutable appendString:@" "];
        [fenMutable appendString:@"0"];
        [fenMutable appendString:@" "];
        NSInteger nm = [self getMoveNumberInGame:gameSel];
        [fenMutable appendString:[NSString stringWithFormat:@"%ld", (long)nm]];
    }
    
    //NSLog(@"NUOVO FEN:%@", fenMutable);
    
    NSString *newSetup = @"[SetUp \"1\"]";
    NSString *newFen = [NSString stringWithFormat:@"[FEN \"%@\"]", fenMutable];
    
    NSMutableString *posizioneCorretta = [[NSMutableString alloc] init];
    for (NSString *t in pgnAr) {
        if ([t hasPrefix:@"[FEN"]) {
            if (!setup) {
                [posizioneCorretta appendString:newSetup];
                [posizioneCorretta appendString:separator];
            }
            [posizioneCorretta appendString:newFen];
            [posizioneCorretta appendString:separator];
        }
        else {
            [posizioneCorretta appendString:t];
            [posizioneCorretta appendString:separator];
        }
    }
    
    
    
    //NSInteger numeroMossaFen = [self getMoveNumberInFen:gameSel];
    //NSInteger numeroMossaGame = [self getMoveNumberInGame:gameSel];
    
    //NSLog(@"Numero Prima Mossa in FEN = %ld", (long)numeroMossaFen);
    //NSLog(@"Numero Prima Mossa in Game = %ld", (long)numeroMossaGame);
    
    return [self gameIsPositionWithRegularFen2:gameSel];
    
    NSArray *pgnArray = [gameSel componentsSeparatedByString:separator];
    for (NSString *tag in pgnArray) {
        if ([tag hasPrefix:@"[FEN"]) {
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:quadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            //NSString *tagName = [tagArray objectAtIndex:0];
            NSString *tagValue = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:doppiApici];
            //NSLog(@"Tag name = %@      tagvalue = %@", tagName, tagValue);
            temporaryFen = tagValue;
            NSArray *fenArray = [tagValue componentsSeparatedByString:@" "];
            NSString *numeroMossaString = [fenArray lastObject];
            NSInteger numeroMossa = [numeroMossaString integerValue];
            if (numeroMossa > 1) {
                [NSException raise:@"WRONG_FEN_EXCEPTION_2" format:@"FEN Not Ok"];
                //return NO;
            }
        }
    }
    return YES;
}

#pragma mark = Metodo statico utilizzato per porre verificare che la numerazione delle mosse nella posizione parta da 1

+ (BOOL) gameIsPositionWithRegularNumbering:(NSString *)gameSel {
    NSArray *pgnArray = [gameSel componentsSeparatedByString:separator];
    NSString *moves = [pgnArray lastObject];
    //NSLog(@"Devo analizzare %@", moves);
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    NSString *primoCarattere = [NSString stringWithFormat:@"%c", [moves characterAtIndex:0]];
    BOOL primoCarattereNumerico = [nf numberFromString:primoCarattere] != nil;
    
    if (primoCarattereNumerico) {
        if (![primoCarattere isEqualToString:@"1"]) {
            //[NSException raise:@"WRONG_GAME_NUMBERING" format:@"Numbering KO!"];
            //NSLog(@"PGNGame:La numerazione non inizia da 1 ma continuo lo stesso");
        }
    }
    else {
        NSArray *movesArray = [moves componentsSeparatedByString:@"} "];
        NSString *primoCarattereDiOgniOggettoArray;
        BOOL primoCarattereNumericoDiOgniOggettoArray = NO;
        for (NSString *t in movesArray) {
            NSString *tSenzaBianchi = [t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            
            if ([risultati containsObject:tSenzaBianchi]) {
                primoCarattereNumericoDiOgniOggettoArray = NO;
            }
            else {
                primoCarattereDiOgniOggettoArray = [NSString stringWithFormat:@"%c", [tSenzaBianchi characterAtIndex:0]];
                primoCarattereNumericoDiOgniOggettoArray = [nf numberFromString:primoCarattereDiOgniOggettoArray] != nil;
                if (primoCarattereNumericoDiOgniOggettoArray) {
                    break;
                }
            }
        }
        if (primoCarattereNumericoDiOgniOggettoArray) {
            if (![primoCarattereDiOgniOggettoArray isEqualToString:@"1"]) {
                //[NSException raise:@"WRONG_GAME_NUMBERING" format:@"Numbering KO!"];
                NSLog(@"PGNGame:La numerazione non inizia da 1 ma continuo lo stesso");
            }
        }
        
    }
    return YES;
}


+ (NSString *) getGameWithNumberOfMoveInFenCorrected:(NSString *)gameSel {
    
    NSMutableCharacterSet *quadre = [[NSMutableCharacterSet alloc] init];
    [quadre addCharactersInString:@"[]"];
    NSMutableCharacterSet *doppiApici = [[NSMutableCharacterSet alloc] init];
    [doppiApici addCharactersInString:@"\""];
    
    NSUInteger indexFen;
    NSMutableString *newFenValue = [[NSMutableString alloc] init];
    NSMutableString *newFenTag;
    NSMutableArray *pgnArray = [[gameSel componentsSeparatedByString:separator] mutableCopy];
    for (NSString *tag in pgnArray) {
        if ([tag hasPrefix:@"[FEN"]) {
            indexFen = [pgnArray indexOfObject:tag];
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:quadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            //NSString *tagName = [tagArray objectAtIndex:0];
            NSString *tagValue = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:doppiApici];
            NSArray *fenArray = [tagValue componentsSeparatedByString:@" "];
            NSString *numeroMossaString = [fenArray lastObject];
            NSInteger numeroMossa = [numeroMossaString integerValue];
            if (numeroMossa > 1) {
                for (int i=0; i<fenArray.count-1; i++) {
                    if (i==0) {
                        [newFenValue appendString:[fenArray objectAtIndex:i]];
                    }
                    else {
                        [newFenValue appendString:@" "];
                        [newFenValue appendString:[fenArray objectAtIndex:i]];
                    }
                }
                [newFenValue appendString:@" "];
                [newFenValue appendString:@"1"];
                //NSLog(@"VECCHIO FEN = %@", tagValue);
                tagValue = newFenValue;
                //NSLog(@"NUOVO FEN = %@", tagValue);
                newFenTag = [[NSMutableString alloc] initWithString:@"[FEN \""];
                [newFenTag appendString:newFenValue];
                [newFenTag appendString:@"\"]"];
            }
        }
    }
    [pgnArray replaceObjectAtIndex:indexFen withObject:newFenTag];
    NSMutableString *newGame = [[NSMutableString alloc] init];
    for (int i=0; i<pgnArray.count; i++) {
        if (i==0) {
            [newGame appendString:[pgnArray objectAtIndex:i]];
        }
        else {
            [newGame appendString:separator];
            [newGame appendString:[pgnArray objectAtIndex:i]];
        }
    }
    return newGame;
}


#pragma mark = Metodo statico utilizzato per verificare che il colore che muove indicato nel FEN corrisponda a quello delle mosse

+ (NSString *) checkStartColorAndFirstMove:(NSString *)gameSel {
    NSMutableArray *gameArray = [[gameSel componentsSeparatedByString:separator] mutableCopy];
    //NSString *last = [gameArray lastObject];
    NSString *fen = [self extractFen:gameSel];
    
    if (!fen) {
        return gameSel;
    }
    
    
    
    NSArray *fenArray = [fen componentsSeparatedByString:@" "];
    NSString *colorToMove = [fenArray objectAtIndex:1];
    NSString *numMove = [fenArray lastObject];
    //NSLog(@"COLOR TO MOVE = %@  NumberMove = %@", colorToMove, numMove);
    
    NSString *expectedFirstMove = nil;
    
    //NSLog(@"%@", gameArray);
    
    if ([colorToMove isEqualToString:@"w"]) {
        
        expectedFirstMove = @"*";
        
        return gameSel;
        
        //NSLog(@"Mi aspetto una situazione del tipo: *");
        //[gameArray replaceObjectAtIndex:([gameArray count]-1) withObject:@"*"];
    }
    else {
        //if ([numMove isEqualToString:@"1"]) {
        
        expectedFirstMove = [NSString stringWithFormat:@"%@...", numMove];
        NSString *realFirstMove = [gameArray lastObject];
        if ([realFirstMove hasPrefix:expectedFirstMove]) {
            return gameSel;
        }
        
        //NSLog(@"Mi aspetto una situazione del tipo: %@... *", numMove);
        NSString *last = [NSString stringWithFormat:@"%@... *", numMove];
        [gameArray replaceObjectAtIndex:([gameArray count]-1) withObject:last];
    }
    
    NSMutableString *newGame = [[NSMutableString alloc] init];
    
    for (NSString *s in gameArray) {
        [newGame appendString:s];
        [newGame appendString:separator];
    }
    
    gameSel = [newGame stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:separator]];
    
    
    return gameSel;
}

+ (NSString *) extractFen:(NSString *)gameSel {
    NSMutableCharacterSet *quadre = [[NSMutableCharacterSet alloc] init];
    [quadre addCharactersInString:@"[]"];
    NSMutableCharacterSet *doppiApici = [[NSMutableCharacterSet alloc] init];
    [doppiApici addCharactersInString:@"\""];
    
    NSString *fen = nil;
    NSString *setup = nil;
    NSArray *pgnAr = [gameSel componentsSeparatedByString:separator];
    for (NSString *tag in pgnAr) {
        if ([tag hasPrefix:@"[FEN"]) {
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:quadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            fen = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:doppiApici];
        }
        else if ([tag hasPrefix:@"[SetUp"]) {
            NSString *tagSenzaQuadre = [tag stringByTrimmingCharactersInSet:quadre];
            NSArray *tagArray = [tagSenzaQuadre componentsSeparatedByString:@" \""];
            setup = [[tagArray objectAtIndex:1] stringByTrimmingCharactersInSet:doppiApici];
        }
    }
    return fen;
}

+ (NSString *) getTemporaryFen {
    return temporaryFen;
}


- (void) backupMoves {
    copiaMosse = [_moves mutableCopy];
    copiaSevenTag = [sevenTag mutableCopy];
    copiaSupplementalTag = [supplementalTag mutableCopy];
    copiaSupplementalTagArray = [supplementalTagArray mutableCopy];
    //NSLog(@"BACKUP MOSSE = %@", _moves);
    //NSLog(@"BACKUP COPIA MOSSE = %@", copiaMosse);
    //NSLog(@"BACKUP SUPP TAG = %@", copiaSupplementalTag);
    //NSLog(@"BACKUP SEVEN TAG = %@", copiaSevenTag);
}

- (void) restoreMoves {
    _moves = [copiaMosse mutableCopy];
    sevenTag = [copiaSevenTag mutableCopy];
    supplementalTag = [copiaSupplementalTag mutableCopy];
    supplementalTagArray = [copiaSupplementalTagArray mutableCopy];
    copiaMosse = nil;
    copiaSevenTag = nil;
    copiaSupplementalTag = nil;
    copiaSupplementalTagArray = nil;
    //NSLog(@"MOSSE = %@", _moves);
    //NSLog(@"COPIA MOSSE = %@", copiaMosse);
}


#pragma mark = Metodi per la formattazione delle informazioni sulla partita che devono essere visualizzati in una cella nelle table che elencano le partite

- (NSString *) getCellTextLabel {
    NSString *w = [self getTagValueByTagName:@"White"];
    NSString *b = [self getTagValueByTagName:@"Black"];
    return [[w stringByAppendingString:@" - "] stringByAppendingString:b];
}

- (NSString *) getCellDetailTextLabel {
    NSMutableString *detail = [[NSMutableString alloc] init];
    [detail appendString:[self getTagValueByTagName:@"Result"]];
    NSString *eco = [self getTagValueByTagName:@"ECO"];
    if (eco) {
        [detail appendString:@" "];
        [detail appendString:eco];
    }
    NSString *event = [self getTagValueByTagName:@"Event"];
    if (event) {
        [detail appendString:@" "];
        [detail appendString:event];
    }
    NSString *site = [self getTagValueByTagName:@"Site"];
    if (site) {
        [detail appendString:@" "];
        [detail appendString:site];
    }
    NSString *date = [self getTagValueByTagName:@"Date"];
    if (date) {
        [detail appendString:@" "];
        [detail appendString:date];
    }
    
    /*
    for (NSString *tn in supplementalTag.allKeys) {
        if (![tn isEqualToString:@"ECO"]) {
            NSString *tv = [self getTagValueByTagName:tn];
            [detail appendString:@" "];
            [detail appendString:tv];
        }
    }
    */
    return detail;
}

+ (NSString *) getMovesWithoutGraffe:(NSString *) game {
    NSArray *componenti = [game componentsSeparatedByString:separator];
    NSString *mosse = [componenti lastObject];
    
    int numGraffe = 0;
    NSMutableString *mosseSenzaGraffe = [[NSMutableString alloc] init];
    
    for (int i=0; i<mosse.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *car = [mosse substringWithRange:range];
        if ([car isEqualToString:@"{"]) {
            numGraffe++;
        }
        else if ([car isEqualToString:@"}"]) {
            numGraffe--;
        }
        else {
            if (numGraffe == 0) {
                [mosseSenzaGraffe appendString:car];
            }
        }
        NSLog(@"%@", car);
    }
    return [mosseSenzaGraffe stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSMutableAttributedString *) getMovesWithAttributed:(NSString *) game {
    int numGraffe = 0;
    NSArray *pezzi = [NSArray arrayWithObjects:@"K", @"Q", @"R", @"B", @"N", nil];
    NSDictionary *attributoPezzo = @{NSFontAttributeName:[UIFont fontWithName:@"SemFigBold" size:12.0]};
    NSDictionary *attributoAltro = @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:13.0], NSForegroundColorAttributeName:[UIColor orangeColor]};
    NSDictionary *attributoMosse = @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:13.0]};
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    for (int i=0; i<game.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *car = [game substringWithRange:range];
        if ([car isEqualToString:@"{"]) {
            numGraffe++;
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:car attributes:attributoAltro];
            [attributedText appendAttributedString:attrString];
        }
        else if ([car isEqualToString:@"}"]) {
            numGraffe--;
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:car attributes:attributoAltro];
            [attributedText appendAttributedString:attrString];
        }
        else {
            if (numGraffe == 0) {
                if ([pezzi containsObject:car]) {
                    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:car attributes:attributoPezzo];
                    [attributedText appendAttributedString:attrString];
                }
                else {
                    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:car attributes:attributoMosse];
                    [attributedText appendAttributedString:attrString];
                }
            }
            else {
                NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:car attributes:attributoAltro];
                [attributedText appendAttributedString:attrString];
            }
        }
    }
    return attributedText;
}


- (NSMutableAttributedString *) getAttributedGameMoves {
    int numGraffe = 0;
    BOOL isAnnotation = NO;
    NSAttributedString *attrString;
    NSArray *pezzi = [NSArray arrayWithObjects:@"K", @"Q", @"R", @"B", @"N", nil];
    //NSDictionary *attributoPezzo = @{NSFontAttributeName:[UIFont fontWithName:@"SemFigNormal" size:12.0]};
    NSDictionary *attributoAltro = @{NSFontAttributeName:[UIFont fontWithName:@"Figgeorg" size:13.0], NSForegroundColorAttributeName:[UIColor orangeColor]};
    NSDictionary *attributoMosse = @{NSFontAttributeName:[UIFont fontWithName:@"Figgeorg" size:13.0]};
    NSDictionary *attributoAnnotation = @{NSFontAttributeName:[UIFont fontWithName:@"ISChess" size:12.0]};
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    NSMutableString *annotation = nil;
    for (int i=0; i<_moves.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *car = [_moves substringWithRange:range];
        if (([car isEqualToString:@" "]||[car isEqualToString:@")"]||[car isEqualToString:@"}"]) && (isAnnotation)) {
            isAnnotation = NO;
            NSString *convertedAnnotation = [PGNUtil nagToSymbolForAttributedTextMoves:annotation];
            
            if ([annotation isEqualToString:@"$142"] || [annotation isEqualToString:@"$140"]) {
                //NSLog(@"Devo inserire questa annotazione prima della mossa: %@.", annotation);
                //NSLog(@"Per farlo devo recuperare l'ultima mossa inserita");
                //NSLog(@"%@", attributedText.string);
                annotation = nil;
            }
            else {
                NSAttributedString *attributedAnnotation = [[NSAttributedString alloc] initWithString:convertedAnnotation attributes:attributoAnnotation];
                [attributedText appendAttributedString:attributedAnnotation];
                annotation = nil;
            }
        }
        if (isAnnotation) {
            [annotation appendString:car];
        }
        else if ([car isEqualToString:@"$"]) {
            isAnnotation = YES;
            annotation = [[NSMutableString alloc] initWithString:@"$"];
        }
        else if ([car isEqualToString:@"{"]) {
            numGraffe++;
            attrString = [[NSAttributedString alloc] initWithString:car attributes:attributoAltro];
            [attributedText appendAttributedString:attrString];
        }
        else if ([car isEqualToString:@"}"]) {
            numGraffe--;
            attrString = [[NSAttributedString alloc] initWithString:car attributes:attributoAltro];
            [attributedText appendAttributedString:attrString];
        }
        else {
            if (numGraffe == 0) {
                if ([pezzi containsObject:car]) {
                    //attrString = [[NSAttributedString alloc] initWithString:car attributes:attributoPezzo];
                    attrString = [self getAttributedPiece:car];
                    [attributedText appendAttributedString:attrString];
                }
                else {
                    attrString = [[NSAttributedString alloc] initWithString:car attributes:attributoMosse];
                    [attributedText appendAttributedString:attrString];
                }
            }
            else {
                attrString = [[NSAttributedString alloc] initWithString:car attributes:attributoAltro];
                [attributedText appendAttributedString:attrString];
            }
        }
    }
    return attributedText;
}

- (NSAttributedString *) getAttributedPiece:(NSString *)piece {
    NSString *fontName = @"SemFigNormal";
    NSArray *pezzi = [NSArray arrayWithObjects:@"K", @"Q", @"R", @"B", @"N", nil];
    if ([pezzi containsObject:piece]) {
        if ([fontName isEqualToString:@"SemFigNormal"]) {
            NSDictionary *attributoPezzo = @{NSFontAttributeName:[UIFont fontWithName:fontName size:12.0]};
            return [[NSAttributedString alloc] initWithString:piece attributes:attributoPezzo];
        }
        else if ([fontName isEqualToString:@"ISChess"]) {
            NSDictionary *attributoPezzo = @{NSFontAttributeName:[UIFont fontWithName:fontName size:12.0]};
            if ([piece isEqualToString:@"Q"]) {
                return [[NSAttributedString alloc] initWithString:@"I" attributes:attributoPezzo];
            }
            else if ([piece isEqualToString:@"K"]) {
                return [[NSAttributedString alloc] initWithString:@"K" attributes:attributoPezzo];
            }
            else if ([piece isEqualToString:@"R"]) {
                return [[NSAttributedString alloc] initWithString:@"G" attributes:attributoPezzo];
            }
            else if ([piece isEqualToString:@"B"]) {
                return [[NSAttributedString alloc] initWithString:@"E" attributes:attributoPezzo];
            }
            else if ([piece isEqualToString:@"N"]) {
                return [[NSAttributedString alloc] initWithString:@"C" attributes:attributoPezzo];
            }
        }
        else if ([fontName isEqualToString:@"Linares"]) {
            NSDictionary *attributoPezzo = @{NSFontAttributeName:[UIFont fontWithName:fontName size:12.0]};
            if ([piece isEqualToString:@"Q"]) {
                return [[NSAttributedString alloc] initWithString:@"\u00BD" attributes:attributoPezzo];
            }
            else if ([piece isEqualToString:@"K"]) {
                return [[NSAttributedString alloc] initWithString:@"\u00BE" attributes:attributoPezzo];
            }
            else if ([piece isEqualToString:@"R"]) {
                return [[NSAttributedString alloc] initWithString:@"\u00BC" attributes:attributoPezzo];
            }
            else if ([piece isEqualToString:@"B"]) {
                return [[NSAttributedString alloc] initWithString:@"\u00BA" attributes:attributoPezzo];
            }
            else if ([piece isEqualToString:@"N"]) {
                return [[NSAttributedString alloc] initWithString:@"\u00BB" attributes:attributoPezzo];
            }
        }
        else if ([fontName isEqualToString:@"Dialast"]) {
            NSDictionary *attributoPezzo = @{NSFontAttributeName:[UIFont fontWithName:fontName size:12.0]};
            if ([piece isEqualToString:@"B"]) {
                return [[NSAttributedString alloc] initWithString:@"L" attributes:attributoPezzo];
            }
            else {
                return [[NSAttributedString alloc] initWithString:piece attributes:attributoPezzo];
            }
        }
        else if ([fontName isEqualToString:@"DiagramTTLeipzig"]) {
            NSDictionary *attributoPezzo = @{NSFontAttributeName:[UIFont fontWithName:fontName size:12.0]};
            if ([piece isEqualToString:@"B"]) {
                return [[NSAttributedString alloc] initWithString:@"L" attributes:attributoPezzo];
            }
            else {
                return [[NSAttributedString alloc] initWithString:piece attributes:attributoPezzo];
            }
        }
        else if ([fontName isEqualToString:@"Verfig"]) {
            NSDictionary *attributoPezzo = @{NSFontAttributeName:[UIFont fontWithName:fontName size:12.0]};
            return [[NSAttributedString alloc] initWithString:piece attributes:attributoPezzo];
        }
        else if ([fontName isEqualToString:@"Figgeorg"]) {
            NSDictionary *attributoPezzo = @{NSFontAttributeName:[UIFont fontWithName:fontName size:12.0]};
            return [[NSAttributedString alloc] initWithString:piece attributes:attributoPezzo];
        }
    }
    return nil;
}


@end
