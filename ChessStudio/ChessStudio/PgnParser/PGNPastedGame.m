//
//  PGNPastedGame.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 11/11/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PGNPastedGame.h"
#import "PGNGame.h"

#define sevenTagRoster [NSArray arrayWithObjects: @"Event",@"Site", @"Date", @"Round", @"White", @"Black", @"Result",  nil]
#define risultati [NSArray arrayWithObjects: @"1-0",@"0-1", @"1/2-1/2", @"*", nil]


NSUInteger const PARTITA_INDEFINITA = 0;
NSUInteger const PARTITA_CON_TAG_E_MOSSE = 100;
NSUInteger const PARTITA_SENZA_TAG_CON_MOSSE = 200;
NSUInteger const PARTITA_CON_TAG_SENZA_MOSSE = 300;
NSUInteger const PARTITA_CON_TAG_INCOMPLETI_CON_MOSSE = 400;

@interface PGNPastedGame() {

    NSString *tags;
    NSString *moves;
    NSString *game;
    
    
    
    NSString *tagPattern;

    
    NSMutableDictionary *sevenTag;
    NSMutableDictionary *supplementalTag;
    NSMutableArray *supplementalTagArray;
    
    NSMutableArray *finalPastedGames;
    
    NSUInteger evaluation;
    
    NSMutableDictionary *evaluationDictionary;
}

@end


@implementation PGNPastedGame

- (id) initWithPastedString:(NSString *)pastedString {
    self = [super init];
    if (self) {
        
        //NSLog(@"%@\n", pastedString);
        
        evaluation = PARTITA_INDEFINITA;
        tagPattern = @"(\\[\\s*(\\w+)\\s*\"([^\"]*)\"\\s*\\]\\s*)+";
        [self initSevenTag];
        
        
        
        NSString *newPastedString = [self compattaPastedString:pastedString];
        //NSLog(@"%@", newPastedString);
        
        //[self parsePastedStringForAll:pastedString];
        [self parsePastedStringForAll:newPastedString];
        
        //NSLog(@"ESEGUITO PARSEPASTEDSTRING");
        //NSLog(@"%@", finalPastedGames);
        
        
        [self validatePastedGames];
        
        [self validateTagsValues];
        
        //evaluation = PARTITA_CON_TAG_E_MOSSE;
        
        /*
        [self parsePastedStringWithEventTag:pastedString];
        if (finalPastedGames.count == 0) {
            NSLog(@"Siccome non ho ottenuto niente con il primo parsing provo con il secondo");
            [self parsePastedStringWithoutEventTag:pastedString];
            if (finalPastedGames.count>0) {
                NSLog(@"Il testo copiato sembra contenbere tag (senza evento) + partite");
                evaluation = PARTITA_CON_TAG_INCOMPLETI_CON_MOSSE;
                [self validateTags];
            }
            else {
                NSLog(@"Con il secondo parsing non ho trovato nulla; provo a vedere se ci sono solo tags");
                [self parsePastedStringOnlyForTags:pastedString];
                if (finalPastedGames.count > 0) {
                    NSLog(@"Il testo copiato sembra contenere solo tag senza mosse");
                    NSLog(@"Ora devo validare i tags");
                    evaluation = PARTITA_CON_TAG_SENZA_MOSSE;
                    [self validateTags];
                    //[self completaTagsAndMosse];
                }
                else {
                    NSLog(@"Questa copiata non contiene solo tag; provo a vedere se è solo una partita");
                    [self parsePastedStringOnlyForMoves:pastedString];
                    if (finalPastedGames.count > 0) {
                        NSLog(@"Il testo copiato sembra contenere solo mosse senza tag");
                        NSLog(@"Controllo i tags");
                        evaluation = PARTITA_SENZA_TAG_CON_MOSSE;
                        [self validateTags];
                    }
                }
            }
        }
        else {
            NSLog(@"Il testo copiato sembra contenere tag (Event) + partite");
            NSLog(@"Ora devo validare i tags");
            evaluation = PARTITA_CON_TAG_E_MOSSE;
            [self validateTags];
        }*/
    }
    return self;
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

- (void) aggiungiTuttiTag {
    NSMutableString *allTags = [[NSMutableString alloc] init];
    for (NSString *tag in sevenTagRoster) {
        NSString *tagValue = [sevenTag objectForKey:tag];
        [allTags appendString:@"["];
        [allTags appendString:tag];
        [allTags appendString:@" "];
        [allTags appendString:@"\""];
        [allTags appendString:tagValue];
        [allTags appendString:@"\""];
        [allTags appendString:@"]"];
        [allTags appendString:separator];
    }
    for (int i=0; i<finalPastedGames.count; i++) {
        NSMutableString *newGame = [[NSMutableString alloc] initWithString:allTags];
        [newGame appendString:[finalPastedGames objectAtIndex:i]];
        [finalPastedGames replaceObjectAtIndex:i withObject:newGame];
    }
    evaluation = PARTITA_CON_TAG_E_MOSSE;
}

- (NSString *)getGamesForTextView {
    NSMutableString *gamesForTextView = [[NSMutableString alloc] init];
    for (int i=0; i<finalPastedGames.count; i++) {
        NSString *newGame = [finalPastedGames objectAtIndex:i];
        NSArray *gameArray = [newGame componentsSeparatedByString:separator];
        if (i>0) {
            [gamesForTextView appendString:@"\n"];
        }
        for (NSString *compGame in gameArray) {
            if ([compGame hasPrefix:@"["]) {
                [gamesForTextView appendString:compGame];
                [gamesForTextView appendString:@"\n"];
            }
            else {
                [gamesForTextView appendString:@"\n"];
                [gamesForTextView appendString:compGame];
                [gamesForTextView appendString:@"\n"];
            }
        }
    }
    return gamesForTextView;
}

+ (NSString *) getGameForTextView:(NSString *)selectedGame {
    NSMutableString *gameForTextView = [[NSMutableString alloc] init];
    NSArray *gameArray = [selectedGame componentsSeparatedByString:separator];
    for (NSString *compGame in gameArray) {
        if ([compGame hasPrefix:@"["]) {
            [gameForTextView appendString:compGame];
            [gameForTextView appendString:@"\n"];
        }
        else {
            [gameForTextView appendString:@"\n"];
            [gameForTextView appendString:compGame];
            [gameForTextView appendString:@"\n"];
        }
    }
    return gameForTextView;
}

- (NSString *) getGameAsString:(NSArray *)gameArray {
    NSMutableString *gameString = [[NSMutableString alloc] init];
    for (NSString *c in gameArray) {
        [gameString appendString:c];
        if (![[gameArray lastObject] isEqualToString:c]) {
            [gameString appendString:separator];
        }
    }
    return gameString;
}

- (NSString *) getGameForTableView:(NSString *)selectedGame {
    NSInteger eval = [[evaluationDictionary objectForKey:selectedGame] integerValue];
    NSLog(@"%@", selectedGame);
    if (eval == 0) {
        NSArray *gameArray = [selectedGame componentsSeparatedByString:separator];
        
        NSString *w = @"";
        NSString *b = @"";
        
        for (NSString *tag in gameArray) {
            if ([tag hasPrefix:@"[White "]) {
                w = [[tag componentsSeparatedByString:@"\""] objectAtIndex:1];
            }
            if ([tag hasPrefix:@"[Black "]) {
                b = [[tag componentsSeparatedByString:@"\""] objectAtIndex:1];
            }
        }
        
        //NSString *w = [[[gameArray objectAtIndex:4] componentsSeparatedByString:@"\""] objectAtIndex:1];
        //NSString *b = [[[gameArray objectAtIndex:5] componentsSeparatedByString:@"\""] objectAtIndex:1];
        
        return [[w stringByAppendingString:@" - "] stringByAppendingString:b];
    }
    else if (eval == 1) {
        return  selectedGame;
    }
    else {
        NSArray *gameArray = [selectedGame componentsSeparatedByString:separator];
        NSMutableString *gameForCellTable = [[NSMutableString alloc] init];
        for (int i=0; i<gameArray.count; i++) {
            NSString *tag = [gameArray objectAtIndex:i];
            if ([tag hasPrefix:@"["]) {
                NSString *tagName = [self extractTagName:tag];
                NSString *tagValue = [self extractTagValue:tag];
                [gameForCellTable appendString:tagName];
                [gameForCellTable appendString:@":"];
                [gameForCellTable appendString:tagValue];
                [gameForCellTable appendString:@"  "];
            }

        }
        return gameForCellTable;
    }
    return selectedGame;
}

- (NSString *) getGameDetailForTableView:(NSString *)selectedGame {
    NSInteger eval = [[evaluationDictionary objectForKey:selectedGame] integerValue];
    if (eval == 0) {
        return NSLocalizedString(@"PASTED_GAME_0", nil);
    }
    else if (eval == 1) {
        return NSLocalizedString(@"PASTED_GAME_1", nil);
    }
    else if (eval == 2) {
        return NSLocalizedString(@"PASTED_GAME_2", nil);
    }
    else if (eval == 3) {
        return NSLocalizedString(@"PASTED_GAME_3", nil);
    }
    else if (eval == 4) {
        return NSLocalizedString(@"PASTED_GAME_4", nil);
    }
    else if (eval == 5) {
        return NSLocalizedString(@"PASTED_GAME_5", nil);
    }
    else if (eval == 6) {
        return NSLocalizedString(@"PASTED_GAME_5", nil);
    }
    return selectedGame;
}

- (void) parsePastedStringOld:(NSString *)pastedString {
    
    //NSLog(@"***************** INIZIO PARTITA COPIATA *************************");
    //NSLog(@"%@", pastedString);
    //NSLog(@"***************** FINE  PARTITA  COPIATA *************************");
    
    NSCharacterSet *newLineSeparator = [NSCharacterSet newlineCharacterSet];
    NSArray *pasteGameComponents = [pastedString componentsSeparatedByCharactersInSet:newLineSeparator];
    
    NSMutableString *tag = [[NSMutableString alloc] init];
    NSMutableString *mosse = [[NSMutableString alloc] init];
    for (NSString *s in pasteGameComponents) {
        if ([s hasPrefix:@"["]) {
            NSString *tg = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [tag appendString:tg];
        }
        else {
            NSString *tk = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *tk2 = [tk stringByAppendingString:@" "];
            [mosse appendString:tk2];
        }
    }
    NSString  *mosseFinali = [mosse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    game = [tag stringByAppendingString:mosseFinali];

    //NSLog(@"%@", game);
    
    tags = tag;
    moves = mosseFinali;
    
    //[self validatePastedGame:game];
    
    [self checkForSevenTagRoster];
}

- (void) parsePastedStringWithEventTag:(NSString *)pastedString {  //Variante nel caso di due o più partite
    
    //NSLog(@"***************** INIZIO PARTITA COPIATA *************************");
    //NSLog(@"%@", pastedString);
    //NSLog(@"***************** FINE  PARTITA  COPIATA *************************");
    
    if (!finalPastedGames) {
        finalPastedGames = [[NSMutableArray alloc] init];
    }
    
    NSCharacterSet *newLineSeparator = [NSCharacterSet newlineCharacterSet];
    NSArray *pastedStringComponents = [pastedString componentsSeparatedByCharactersInSet:newLineSeparator];
    
    NSMutableString *tag = nil;
    NSMutableString *mosse = nil;
    
    for (NSString *riga in pastedStringComponents) {
        
        //NSLog(@"RIGA: %@", riga);
        
        NSString *line = [riga stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (line.length > 0) {
            if ([line hasPrefix:@"[Event "] && !mosse) {
                tag = [[NSMutableString alloc] initWithString:line];
                [tag appendString:separator];
            }
            else if ([line hasPrefix:@"["]  && ![line hasPrefix:@"[Event "] && !mosse) {
                [tag appendString:line];
                [tag appendString:separator];
            }
            else if (!mosse) {
                mosse = [[NSMutableString alloc] initWithString:line];
            }
            else {
                [mosse appendString:@" "];
                [mosse appendString:line];
            }
            
            if (tag) {
                if (mosse) {
                    if ([mosse hasSuffix:@"1-0"] || [mosse hasSuffix:@"0-1"] || [mosse hasSuffix:@"1/2-1/2"] || [mosse hasSuffix:@"*"]) {
                        [tag appendString:mosse];
                        [finalPastedGames addObject:tag];
                        tag = nil;
                        mosse= nil;
                    }
                }
            }
            
        }
        else {
            if (tag) {
                if (mosse) {
                    if ([mosse hasSuffix:@"1-0"] || [mosse hasSuffix:@"0-1"] || [mosse hasSuffix:@"1/2-1/2"] || [mosse hasSuffix:@"*"]) {
                        [tag appendString:mosse];
                        [finalPastedGames addObject:tag];
                        tag = nil;
                        mosse= nil;
                    }
                }
            }
        }
    }
}

- (void) parsePastedStringWithoutEventTag:(NSString *)pastedString {
    
    if (!finalPastedGames) {
        finalPastedGames = [[NSMutableArray alloc] init];
    }
    
    NSCharacterSet *newLineSeparator = [NSCharacterSet newlineCharacterSet];
    NSArray *pastedStringComponents = [pastedString componentsSeparatedByCharactersInSet:newLineSeparator];
    
    NSMutableString *tag = nil;
    NSMutableString *mosse = nil;
    
    for (NSString *riga in pastedStringComponents) {
        NSString *line = [riga stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (line.length > 0) {
            if ([line hasPrefix:@"["] && !mosse && !tag) {
                tag = [[NSMutableString alloc] initWithString:line];
                [tag appendString:separator];
            }
            else if ([line hasPrefix:@"["] && !mosse && tag) {
                [tag appendString:line];
                [tag appendString:separator];
            }
            else if (!mosse) {
                mosse = [[NSMutableString alloc] initWithString:line];
            }
            else {
                [mosse appendString:@" "];
                [mosse appendString:line];
            }
            
            if (tag) {
                if (mosse) {
                    if ([mosse hasSuffix:@"1-0"] || [mosse hasSuffix:@"0-1"] || [mosse hasSuffix:@"1/2-1/2"] || [mosse hasSuffix:@"*"]) {
                        [tag appendString:mosse];
                        [finalPastedGames addObject:tag];
                        tag = nil;
                        mosse= nil;
                    }
                }
            }
        }
        else {
            if (tag) {
                if (mosse) {
                    if ([mosse hasSuffix:@"1-0"] || [mosse hasSuffix:@"0-1"] || [mosse hasSuffix:@"1/2-1/2"] || [mosse hasSuffix:@"*"]) {
                        [tag appendString:mosse];
                        [finalPastedGames addObject:tag];
                        tag = nil;
                        mosse= nil;
                    }
                }
            }
        }
    }
}

- (void) parsePastedStringOnlyForTags:(NSString *)pastedString {
    if (!finalPastedGames) {
        finalPastedGames = [[NSMutableArray alloc] init];
    }
    
    NSCharacterSet *newLineSeparator = [NSCharacterSet newlineCharacterSet];
    NSArray *pastedStringComponents = [pastedString componentsSeparatedByCharactersInSet:newLineSeparator];
    
    NSMutableString *tag = [[NSMutableString alloc] init];
    
    for (NSString *riga in pastedStringComponents) {
        NSString *line = [riga stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (line.length > 0) {
            if ([line hasPrefix:@"["]) {
                [tag appendString:line];
                [tag appendString:separator];
            }
        }
    }
    
    if ([tag length]>0) {
        [finalPastedGames addObject:tag];
        //NSLog(@"Trovato solo tag = %@", tag);
    }
}

- (void) parsePastedStringOnlyForMoves:(NSString *)pastedString {
    if (!finalPastedGames) {
        finalPastedGames = [[NSMutableArray alloc] init];
    }
    
    NSCharacterSet *newLineSeparator = [NSCharacterSet newlineCharacterSet];
    NSArray *pastedStringComponents = [pastedString componentsSeparatedByCharactersInSet:newLineSeparator];
    
    NSMutableString *mosse = nil;
    
    for (NSString *riga in pastedStringComponents) {
        NSString *line = [riga stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (line.length > 0) {
            if (![line hasPrefix:@"["]) {
                if (!mosse) {
                    mosse = [[NSMutableString alloc] initWithString:line];
                }
                else {
                    [mosse appendString:@" "];
                    [mosse appendString:line];
                }
                if (mosse) {
                    if ([mosse hasSuffix:@"1-0"] || [mosse hasSuffix:@"0-1"] || [mosse hasSuffix:@"1/2-1/2"] || [mosse hasSuffix:@"*"]) {
                        [finalPastedGames addObject:mosse];
                        mosse = nil;
                    }
                }
            }
        }
    }
}

- (void) parsePastedStringForAll:(NSString *)pastedString {
    if (!finalPastedGames) {
        finalPastedGames = [[NSMutableArray alloc] init];
    }
    
    NSCharacterSet *newLineSeparator = [NSCharacterSet newlineCharacterSet];
    NSArray *pastedStringComponents = [pastedString componentsSeparatedByCharactersInSet:newLineSeparator];
    
//    for (NSString *riga in pastedStringComponents) {
//        if (riga.length>0) {
//            NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^     %@", riga);
//        }
//        else {
//            NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^    RIGA VUOTA");
//        }
//        
//    }
    
    NSMutableString *tag = nil;
    NSMutableString *mosse = nil;
    
    int numeroLineeVuoteDopoTag = 0;
    
    for (NSString *riga in pastedStringComponents) {
        NSString *line = [riga stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (line.length > 0) {
            
            if ([line hasPrefix:@"["] && !mosse && !tag) {
                tag = [[NSMutableString alloc] initWithString:line];
                [tag appendString:separator];
            }
            else if ([line hasPrefix:@"["] && !mosse && tag  && numeroLineeVuoteDopoTag==0) {
                [tag appendString:line];
                [tag appendString:separator];
            }
            else if ([line hasPrefix:@"["] && !mosse && tag && numeroLineeVuoteDopoTag>0) {
                [finalPastedGames addObject:tag];
                numeroLineeVuoteDopoTag = 0;
                tag = [[NSMutableString alloc] initWithString:line];
                [tag appendString:separator];
            }
            else if ([line hasPrefix:@"["] && mosse && tag) {
                if (![mosse hasSuffix:@"1-0"] && ![mosse hasSuffix:@"0-1"] && ![mosse hasSuffix:@"1/2-1/2"] && ![mosse hasSuffix:@"*"]) {
                    [mosse appendString:@" *"];
                }
                [tag appendString:mosse];
                [finalPastedGames addObject:tag];
                tag = nil;
                mosse= nil;
            }
            else if ([line hasPrefix:@"["] && mosse && !tag) {
                if (![mosse hasSuffix:@"1-0"] && ![mosse hasSuffix:@"0-1"] && ![mosse hasSuffix:@"1/2-1/2"] && ![mosse hasSuffix:@"*"]) {
                    [mosse appendString:@" *"];
                }
                [finalPastedGames addObject:mosse];
                tag = nil;
                mosse= nil;
            }
            else if (!mosse) {
                mosse = [[NSMutableString alloc] initWithString:line];
                if (numeroLineeVuoteDopoTag>0) {
                    numeroLineeVuoteDopoTag = 0;
                }
            }
            else {
                [mosse appendString:@" "];
                [mosse appendString:line];
            }
            if (tag) {
                if (mosse) {
                    if ([mosse hasSuffix:@"1-0"] || [mosse hasSuffix:@"0-1"] || [mosse hasSuffix:@"1/2-1/2"] || [mosse hasSuffix:@"*"]) {
                        [tag appendString:mosse];
                        [finalPastedGames addObject:tag];
                        tag = nil;
                        mosse= nil;
                    }
                }
            }
            
            if (mosse && !tag) {
                if ([mosse hasSuffix:@"1-0"] || [mosse hasSuffix:@"0-1"] || [mosse hasSuffix:@"1/2-1/2"] || [mosse hasSuffix:@"*"]) {
                    //[tag appendString:mosse];
                    [finalPastedGames addObject:mosse];
                    tag = nil;
                    mosse= nil;
                }
            }
            if (tag && !mosse && numeroLineeVuoteDopoTag>0) {
                [finalPastedGames addObject:tag];
                tag = nil;
                mosse = nil;
            }
        }
        else {
            if (tag && !mosse) {
                numeroLineeVuoteDopoTag++;
            }
            else if (tag && mosse && ![mosse hasSuffix:@"1-0"] && ![mosse hasSuffix:@"0-1"] && ![mosse hasSuffix:@"1/2-1/2"] && ![mosse hasSuffix:@"*"]) {
                [mosse appendString:@" *"];
                [tag appendString:mosse];
                [finalPastedGames addObject:tag];
                tag = nil;
                mosse= nil;
            }
            else if (!tag && mosse && ![mosse hasSuffix:@"1-0"] && ![mosse hasSuffix:@"0-1"] && ![mosse hasSuffix:@"1/2-1/2"] && ![mosse hasSuffix:@"*"]) {
                [mosse appendString:@" *"];
                [finalPastedGames addObject:mosse];
                tag = nil;
                mosse= nil;
            }
        }
    }
    if (tag && !mosse) {
        [finalPastedGames addObject:tag];
    }
}

- (void) validatePastedGames {
    if (finalPastedGames) {
        evaluationDictionary = [[NSMutableDictionary alloc] init];
        for (int i=0; i<finalPastedGames.count; i++) {
            NSString *gamePasted = [finalPastedGames objectAtIndex:i];
            NSNumber *evaluationNumber = [NSNumber numberWithInteger:[self getGameEvaluation:gamePasted]];
            [evaluationDictionary setValue:evaluationNumber forKey:gamePasted];
        }
    }
}

- (NSInteger) getGameEvaluation:(NSString *)pastedGame {
    if (!pastedGame) {
        return NO;
    }
    int numOfTag = 0;
    BOOL gameOk = NO;
    
    BOOL sevenTagRosterArePresent = [self checkForSevenTagRoster:pastedGame];
    
    if (sevenTagRosterArePresent) {
        NSLog(@"Ci sono tutti i 7 tag");
    }
    else {
        NSLog(@"Alcuni tag fondamentali non sono presenti");
    }
    
    NSArray *pastedGameArray = [pastedGame componentsSeparatedByString:separator];
    for (NSString *comp in pastedGameArray) {
        if ([comp hasPrefix:@"["] && [comp hasSuffix:@"]"]) {
            numOfTag++;
        }
        else if ([comp hasSuffix:@"1-0"] || [comp hasSuffix:@"0-1"] || [comp hasSuffix:@"1/2-1/2"] || [comp hasSuffix:@"*"]) {
            gameOk = YES;
        }
    }
    if ((numOfTag >= 7) && gameOk) {
        if (sevenTagRosterArePresent) {
            return 0; //La partita è OK
        }
        else return 5;  //Manca qualcuno dei 7 tag
    }
    else if ((numOfTag == 0) && gameOk) {
        return 1; //Partita senza tag con mosse
    }
    else if ((numOfTag < 7) && gameOk) {
        return 2; //Partita con tag ridotti con mosse
    }
    else if ((numOfTag >= 7) && !gameOk) {
        if (sevenTagRosterArePresent) {
            return 3; //partita con tag senza mosse
        }
        else return 6; //partita senza mosse dove manca qualcuno dei 7 tag;
    }
    else if ((numOfTag<7) && !gameOk) {
        return 4; //partita con pochi tag senza mosse
    }
    return -1;
}

- (NSString *) correctGame:(NSString *)selectedGame {
    NSInteger eval = [[evaluationDictionary objectForKey:selectedGame] integerValue];
    //NSLog(@"Eval = %d", eval);
    if (eval == 1) {
        NSMutableString *allTags = [[NSMutableString alloc] init];
        for (NSString *tag in sevenTagRoster) {
            NSString *tagValue = [sevenTag objectForKey:tag];
            [allTags appendString:@"["];
            [allTags appendString:tag];
            [allTags appendString:@" "];
            [allTags appendString:@"\""];
            [allTags appendString:tagValue];
            [allTags appendString:@"\""];
            [allTags appendString:@"]"];
            [allTags appendString:separator];
        }
        NSMutableString *newGame = [[NSMutableString alloc] initWithString:allTags];
        [newGame appendString:selectedGame];
        [evaluationDictionary removeObjectForKey:selectedGame];
        [evaluationDictionary setObject:[NSNumber numberWithInteger:0] forKey:newGame];
        [finalPastedGames replaceObjectAtIndex:[finalPastedGames indexOfObject:selectedGame] withObject:newGame];
        
        //NSLog(@"%@", newGame);
        return newGame;
    }
    if (eval == 3) {
        NSMutableString *newGame = [[NSMutableString alloc] initWithString:selectedGame];
        [newGame appendString:@"*"];
        [evaluationDictionary removeObjectForKey:selectedGame];
        [evaluationDictionary setObject:[NSNumber numberWithInteger:0] forKey:newGame];
        [finalPastedGames replaceObjectAtIndex:[finalPastedGames indexOfObject:selectedGame] withObject:newGame];
        //NSLog(@"%@", newGame);
        return newGame;
    }
    if (eval == 5 || eval == 6 || eval == 4 || eval == 2) {
        NSMutableArray *gameArray = [[selectedGame componentsSeparatedByString:separator] mutableCopy];
        NSMutableArray *tagNonEsistenti = [[NSMutableArray alloc] init];
        BOOL trovato = NO;
        for (int i=0; i<[sevenTagRoster count]; i++) {
            trovato = NO;
            NSString *t = [[@"[" stringByAppendingString:[sevenTagRoster objectAtIndex:i]] stringByAppendingString:@" "];
            for (NSString *t2 in gameArray) {
                if ([t2 hasPrefix:t]) {
                    //NSLog(@"Il tag %@ esiste", t2);
                    trovato = YES;
                }
            }
            if (!trovato) {
                [tagNonEsistenti addObject:[NSNumber numberWithInt:i]];
                trovato = NO;
                //NSLog(@"Non ho trovato %@", [sevenTagRoster objectAtIndex:i]);
            }
        }
        for (NSNumber *n in tagNonEsistenti) {
            int nt = [n intValue];
            NSMutableString *tagMancante = [[NSMutableString alloc] initWithString:@"["];
            [tagMancante appendString:[sevenTagRoster objectAtIndex:nt]];
            [tagMancante appendString:@" "];
            [tagMancante appendString:@"\""];
            [tagMancante appendString:[sevenTag objectForKey:[sevenTagRoster objectAtIndex:nt]]];
            [tagMancante appendString:@"\""];
            [tagMancante appendString:@"]"];
            [gameArray insertObject:tagMancante atIndex:nt];
        }
        NSString *newGame = [self getGameAsString:gameArray];
        [evaluationDictionary removeObjectForKey:selectedGame];
        [evaluationDictionary setObject:[NSNumber numberWithInteger:0] forKey:newGame];
        [finalPastedGames replaceObjectAtIndex:[finalPastedGames indexOfObject:selectedGame] withObject:newGame];
        return newGame;
    }
    return nil;
}

- (void) replaceGame:(NSString *)oldGame :(NSString *)newGame {
    NSCharacterSet *newLineSeparator = [NSCharacterSet newlineCharacterSet];
    NSArray *gameArray = [newGame componentsSeparatedByCharactersInSet:newLineSeparator];
    NSMutableString *newNewGame = [[NSMutableString alloc] init];
    for (NSString *r  in gameArray) {
        [newNewGame appendString:r];
        [newNewGame appendString:separator];
    }
    NSLog(@"%@", newNewGame);
}

- (BOOL) checkForSevenTagRoster:(NSString *)pastedGame {
    //NSError *error = NULL;
    //NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:tagPattern options:NSRegularExpressionCaseInsensitive error:&error];
    //if (error) {
    //    NSLog(@"ERROR = %@", error);
    //}
    NSMutableArray *sevenTagTrovati = [[NSMutableArray alloc] init];
    NSArray *tagArray = [pastedGame componentsSeparatedByString:separator];
    for (NSString *tag in tagArray) {
        //NSUInteger numberOfMatch = [regex numberOfMatchesInString:tag options:0 range:NSMakeRange(0, [tag length])];
        if ([self isSevenTagRoster:tag]) {
            [sevenTagTrovati addObject:tag];
        }
    }
    if ([sevenTagTrovati count] == 7) {
        return YES;
    }
    return NO;
}

- (NSDictionary *) getEvaluationDictionary {
    return evaluationDictionary;
}

- (NSArray *) gamesToSave {
    NSMutableArray *gameToSave = [[NSMutableArray alloc] init];
    for (NSString *g in finalPastedGames) {
        if ([[evaluationDictionary objectForKey:g] integerValue] == 0) {
            [gameToSave addObject:g];
        }
    }
    return gameToSave;
}



- (void) validateTags {
    for (NSString *finalGame in finalPastedGames) {
        [self validatePastedTags:finalGame];
    }
}

- (void) validatePastedTags:(NSString *)pastedGame {
    NSRange sevenTagRange;
    
    sevenTagRange = [pastedGame rangeOfString:@"[Event "];
    if (sevenTagRange.location == NSNotFound) {
        //NSLog(@"La partita non contiene il tag Event");
    }
    
    sevenTagRange = [pastedGame rangeOfString:@"[Site "];
    if (sevenTagRange.location == NSNotFound) {
        //NSLog(@"La partita non contiene il tag Site");
    }
    
    sevenTagRange = [pastedGame rangeOfString:@"[Date "];
    if (sevenTagRange.location == NSNotFound) {
        //NSLog(@"La partita non contiene il tag Date");
    }
    
    sevenTagRange = [pastedGame rangeOfString:@"[Round "];
    if (sevenTagRange.location == NSNotFound) {
        //NSLog(@"La partita non contiene il tag Round");
    }
    
    sevenTagRange = [pastedGame rangeOfString:@"[White "];
    if (sevenTagRange.location == NSNotFound) {
        //NSLog(@"La partita non contiene il tag White");
    }
    
    sevenTagRange = [pastedGame rangeOfString:@"[Black "];
    if (sevenTagRange.location == NSNotFound) {
        //NSLog(@"La partita non contiene il tag Black");
    }
    
    sevenTagRange = [pastedGame rangeOfString:@"[Result "];
    if (sevenTagRange.location == NSNotFound) {
        //NSLog(@"La partita non contiene il tag Result");
    }
}

- (void) completaTagsAndMosse {
    for (NSString *finalGame in finalPastedGames) {
        [self validatePastedTags:finalGame];
    }
}

- (void) checkForSevenTagRoster {
    
    //NSError *error = NULL;
    //NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:tagPattern options:NSRegularExpressionCaseInsensitive error:&error];
    //if (error) {
    //    NSLog(@"ERROR = %@", error);
    //}
    
    NSString *tagsConSeparatore = [tags stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    NSArray *tagArray = [tagsConSeparatore componentsSeparatedByString:separator];
    for (NSString *tag in tagArray) {
        
        NSLog(@"tag = %@", tag);
        //NSUInteger numberOfMatch = [regex numberOfMatchesInString:tag options:0 range:NSMakeRange(0, [tag length])];
        //NSLog(@"Numero match = %d", numberOfMatch);
        
        if ([self isSevenTagRoster:tag]) {
            
            //NSLog(@"TAG = %@  È UN SEVEN TAG", tag);
            NSString *tagName = [self extractTagName:tag];
            NSString *tagValue = [self extractTagValue:tag];
            //NSLog(@"TAG NAME = %@", tagName);
            //NSLog(@"TAG VALUE = %@", tagValue);
            [sevenTag objectForKey:tagName];
            [sevenTag setObject:tagValue forKey:tagName];
        }
        else {
            if (!supplementalTag) {
                supplementalTag = [[NSMutableDictionary alloc] init];
                supplementalTagArray = [[NSMutableArray alloc] init];
            }
            NSString *tagName = [self extractTagName:tag];
            NSString *tagValue = [self extractTagValue:tag];
            if (tagName && tagValue) {
                [supplementalTag setObject:tagValue forKey:tagName];
                [supplementalTagArray addObject:tagName];
            }
        }
    }
}



- (NSString *) extractTagName:(NSString *)tag {
    NSArray *tagValueArray = [tag componentsSeparatedByString:@"\""];
    NSString *tagName = nil;
    if ([tagValueArray count]>1) {
        tagName = [tagValueArray objectAtIndex:0];
        tagName = [tagName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        tagName = [tagName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"["]];
    }
    return tagName;
}

- (NSString *) extractTagValue:(NSString *)tag {
    NSArray *tagValueArray = [tag componentsSeparatedByString:@"\""];
    NSString *tagValue = nil;
    if ([tagValueArray count]>1) {
        tagValue = [tagValueArray objectAtIndex:1];
    }
    return tagValue;
}

- (BOOL) isSevenTagRoster:(NSString *)tag {
    NSRange sevenTagRange;
    sevenTagRange = [tag rangeOfString:@"[Event "];
    if (sevenTagRange.location != NSNotFound) {
        return true;
    }
    
    sevenTagRange = [tag rangeOfString:@"[Site "];
    if (sevenTagRange.location != NSNotFound) {
        return true;
    }
    
    sevenTagRange = [tag rangeOfString:@"[Date "];
    if (sevenTagRange.location != NSNotFound) {
        return true;
    }
    
    sevenTagRange = [tag rangeOfString:@"[Round "];
    if (sevenTagRange.location != NSNotFound) {
        return true;
    }
    
    sevenTagRange = [tag rangeOfString:@"[White "];
    if (sevenTagRange.location != NSNotFound) {
        return true;
    }
    
    sevenTagRange = [tag rangeOfString:@"[Black "];
    if (sevenTagRange.location != NSNotFound) {
        return true;
    }
    
    sevenTagRange = [tag rangeOfString:@"[Result "];
    if (sevenTagRange.location != NSNotFound) {
        return true;
    }
    
    return NO;
}


- (void) validateTagsValues {
    
    for (int i=0; i<finalPastedGames.count; i++) {
        NSString *gamePasted = [finalPastedGames objectAtIndex:i];
        PGNGame *pgnGame = [[PGNGame alloc] initWithPgn:gamePasted];
        NSString *tagValue = [pgnGame getTagValueByTagName:@"Date"];
        NSLog(@"DATE = %@", tagValue);
    }
    
    
    
    
    
    
    /*
    for (int i=0; i<finalPastedGames.count; i++) {
        NSString *gamePasted = [finalPastedGames objectAtIndex:i];
        NSArray *pastedGameArray = [gamePasted componentsSeparatedByString:separator];
        for (NSString *comp in pastedGameArray) {
            if ([comp hasPrefix:@"["] && [comp hasSuffix:@"]"]) {
                NSLog(@">>>>>>>>>>>>>>>>>>>     %@", comp);
                NSArray *tagArray = [comp componentsSeparatedByString:@" \""];
                NSLog(@"%@       %@", [tagArray objectAtIndex:0], [tagArray objectAtIndex:1]);
            }
        }
    }
    */
    

}

- (void) stampaTags {
    return;
    
    for (int i=0; i<[sevenTagRoster count]; i++) {
        NSMutableString *tag = [[NSMutableString alloc] init];
        NSString *tagName = [sevenTagRoster objectAtIndex:i];
        NSString *tagValue = [sevenTag objectForKey:tagName];
        [tag appendString:@"["];
        [tag appendString:tagName];
        [tag appendString:@" \""];
        [tag appendString:tagValue];
        [tag appendString:@"\"]"];
        NSLog(@"%@", tag);
    }
    
    for (int i=0; i<[supplementalTagArray count]; i++) {
        NSMutableString *tag = [[NSMutableString alloc] init];
        NSString *tagName = [supplementalTagArray objectAtIndex:i];
        NSString *tagValue = [supplementalTag objectForKey:tagName];
        [tag appendString:@"["];
        [tag appendString:tagName];
        [tag appendString:@" \""];
        [tag appendString:tagValue];
        [tag appendString:@"\"]"];
        NSLog(@"%@", tag);
    }
}

- (void) stampaMoves {
    NSLog(@"%@", moves);
}

- (NSArray *) getFinalPastedGames {
    return finalPastedGames;
}

- (NSUInteger) getEvaluation {
    return evaluation;
}

- (NSInteger) getEvaluationForGame:(NSString *)selectedGame {
    return [[evaluationDictionary objectForKey:selectedGame] integerValue];
}

- (NSString *) compattaPastedString:(NSString *) pastedString {
    NSMutableString *newPastedString = [[NSMutableString alloc] init];
    NSCharacterSet *newLineSeparator = [NSCharacterSet newlineCharacterSet];
    NSArray *pastedStringComponents = [pastedString componentsSeparatedByCharactersInSet:newLineSeparator];
    for (NSString *riga in pastedStringComponents) {
        
        NSString *newRiga = nil;
        if ([riga hasPrefix:@"%"]) {
            newRiga = [NSString stringWithFormat:@"{%@}", riga];
        }
        NSString *line = nil;
        if (newRiga) {
            line = [newRiga stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            line = [riga stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        if (line.length>0) {
            [newPastedString appendString:line];
            [newPastedString appendString:@"\n"];
        }
    }
    return newPastedString;
}

@end
