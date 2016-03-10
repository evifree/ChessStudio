//
//  PGNAnalyzer.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 16/04/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PGNAnalyzer.h"
#import "PGNUtil.h"

@interface PGNAnalyzer() {

    NSUInteger indexToken;
    
    NSString *gameToAnalayze;
    
    
    NSMutableArray *tokenArray;
    
    
    
    PGNMove *firstMove;
    PGNMove *move;
    PGNMove *prevMove;
    
    
    NSString *patternMossa;
    NSRegularExpression *regexPatternMossa;
    
    NSArray *risultato;
    
    NSMutableArray *parsedGameArray;
    
    
    
    PGNMove *radice;
    
    BOOL numerazioneModificata;
    
}

@end

@implementation PGNAnalyzer

- (id) initWithGame:(NSString *)game {
    self = [super init];
    if (self) {
        gameToAnalayze = game;
        [self initGameAnalyzer];
    }
    return self;
}

- (id) initWithPosition:(NSString *)position {
    self = [super init];
    if (self) {
        gameToAnalayze = position;
        [self initPositionAnalyzer];
    }
    return self;
}


- (void) initGameAnalyzer {
    firstMove = nil;
    move = nil;
    prevMove = nil;
    indexToken = 0;
    
    NSError *error = NULL;
    //patternMossa = @"(?:[PNBRQK]?[a-h]?[1-8]?x?[a-h][1-8](?:=[PNBRQK])?|O(-?O){1,2})[\\+#]?(\\s*[!\?]+)?";  //In questo patterno non sono inclusi gli arrocchi con gli zeri
    patternMossa = @"(?:[PNBRQK]?[a-h]?[1-8]?x?[a-h][1-8](?:=[PNBRQK])?|O(-?O){1,2}|0(-?0){1,2})[\\+#]?(\\s*[!\?]+)?";  //In questo pattern sono inclusi gli arrocchi con gli zeri
    regexPatternMossa = [[NSRegularExpression alloc] initWithPattern:patternMossa options:0 error:&error];
    
    risultato = [NSArray arrayWithObjects:@"1-0", @"0-1", @"1/2-1/2", @"*", nil];
    
    
    radice = [[PGNMove alloc] initWithFullMove:nil];
}

- (void) initPositionAnalyzer {
    firstMove = nil;
    move = nil;
    prevMove = nil;
    indexToken = 0;
    
    NSError *error = NULL;
    //patternMossa = @"(?:[PNBRQK]?[a-h]?[1-8]?x?[a-h][1-8](?:=[PNBRQK])?|O(-?O){1,2})[\\+#]?(\\s*[!\?]+)?";   //In questo patterno non sono inclusi gli arrocchi con gli zeri
    patternMossa = @"(?:[PNBRQK]?[a-h]?[1-8]?x?[a-h][1-8](?:=[PNBRQK])?|O(-?O){1,2}|0(-?0){1,2})[\\+#]?(\\s*[!\?]+)?";   //In questo pattern sono inclusi gli arrocchi con gli zeri
    regexPatternMossa = [[NSRegularExpression alloc] initWithPattern:patternMossa options:0 error:&error];
    
    risultato = [NSArray arrayWithObjects:@"1-0", @"0-1", @"1/2-1/2", @"*", nil];
    
    
    radice = [[PGNMove alloc] initWithFullMove:nil];
}


- (NSString *) readToken {
    if (indexToken == tokenArray.count) {
        return nil;
    }
    return [tokenArray objectAtIndex:indexToken++];
}


- (void) parseGameToTokenArray {
    NSArray *colonne = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", nil];
    NSArray *pezzi = [NSArray arrayWithObjects:@"K", @"Q", @"R", @"B", @"N", @"O", nil];
    
    NSMutableString *token = [[NSMutableString alloc] init];
    tokenArray = [[NSMutableArray alloc] init];
    
    NSString *prevCar;
    NSUInteger numGraffeAperte = 0;
    
    for (NSUInteger i=0; i<gameToAnalayze.length; i++) {
        NSString *car = [gameToAnalayze substringWithRange:NSMakeRange(i, 1)];
        if ([car isEqualToString:@" "]) {
            if (numGraffeAperte>0) {
                [token appendString:car];
            }
            else {
                if (token.length > 0) {
                    [tokenArray addObject:token];
                }
                token = [[NSMutableString alloc] init];
                prevCar = car;
            }
        }
        else if ([car isEqualToString:@"("] && numGraffeAperte==0) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            [tokenArray addObject:car];
            token = [[NSMutableString alloc] init];
            prevCar = car;
        }
        else if ([car isEqualToString:@")"] && numGraffeAperte==0) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            [tokenArray addObject:car];
            token = [[NSMutableString alloc] init];
            prevCar = car;
        }
        else if ([car isEqualToString:@"{"]) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            token = [[NSMutableString alloc] init];
            prevCar = car;
            numGraffeAperte++;
            [token appendString:car];
        }
        else if ([car isEqualToString:@"}"]) {
            [token appendString:car];
            [tokenArray addObject:token];
            token = [[NSMutableString alloc] init];
            numGraffeAperte--;
        }
        else {
            if ([prevCar isEqualToString:@"."] && ([colonne containsObject:car] || [pezzi containsObject:car])) {
                [tokenArray addObject:token];
                token = [[NSMutableString alloc] init];
            }
            [token appendString:car];
            prevCar = car;
        }
        
        if (i == gameToAnalayze.length - 1) {
            [tokenArray addObject:token];
        }
    }
    
    /*
    NSLog(@"INIZIO STAMPA DATI PRODOTTA DA ANALYSE GAME");
    for (NSString *tk in tokenArray) {
        if ([tk hasSuffix:@"..."]) {
            NSLog(@"TOKEN = %@  da eliminare", tk);
        }
        else {
            NSLog(@"TOKEN = %@", tk);
        }
    }
    NSLog(@"FINE   STAMPA DATI PRODOTTA DA ANALYSE GAME");
    */
}


- (void) parseGameToExtractMainMoves {
    
    //[self parsePositionToTokenArrayWithGraffa3];
    
    NSArray *colonne = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", nil];
    NSArray *pezzi = [NSArray arrayWithObjects:@"K", @"Q", @"R", @"B", @"N", @"O", nil];
    
    NSMutableString *token = [[NSMutableString alloc] init];
    tokenArray = [[NSMutableArray alloc] init];
    
    NSString *prevCar;
    NSUInteger numGraffeAperte = 0;
    
    BOOL comment = NO;
    BOOL variante = NO;
    
    for (NSUInteger i=0; i<gameToAnalayze.length; i++) {
        NSString *car = [gameToAnalayze substringWithRange:NSMakeRange(i, 1)];
        
        if ([car isEqualToString:@" "]) {
            if (comment) {
                //[token appendString:car];
            }
            else {
                if (token.length > 0) {
                    [tokenArray addObject:token];
                }
                token = [[NSMutableString alloc] init];
                prevCar = car;
            }
        }
        else if ([car isEqualToString:@"("] && numGraffeAperte==0) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            //[tokenArray addObject:car];
            token = [[NSMutableString alloc] init];
            prevCar = car;
            variante = YES;
        }
        else if ([car isEqualToString:@")"] && numGraffeAperte==0) {
            if (token.length > 0) {
                //[tokenArray addObject:token];
            }
            //[tokenArray addObject:car];
            token = [[NSMutableString alloc] init];
            prevCar = car;
        }
        else if ([car isEqualToString:@"{"]) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            token = [[NSMutableString alloc] init];
            prevCar = car;
            numGraffeAperte++;
            comment = YES;
            //[token appendString:car];
        }
        else if ([car isEqualToString:@"}"]) {
            //[token appendString:car];
            //[tokenArray addObject:token];
            token = [[NSMutableString alloc] init];
            numGraffeAperte--;
            comment = NO;
        }
        else {
            if (comment) {
                //[token appendString:car];
            }
            else {
                if ([prevCar isEqualToString:@"."] && ([colonne containsObject:car] || [pezzi containsObject:car])) {
                    [tokenArray addObject:token];
                    token = [[NSMutableString alloc] init];
                }
                [token appendString:car];
                prevCar = car;
            }
        }
        
        if (i == gameToAnalayze.length - 1) {
            [tokenArray addObject:token];
        }
    }
    
    
    //Esamina se nella mossa ci sono punti escalamativi o interrogativi piuttosto che i nag
    
    for (int i=0; i<tokenArray.count; i++) {
        NSString *tk = [tokenArray objectAtIndex:i];
        if (![tk hasPrefix:@"{"]) {
            NSRange range = [tk rangeOfString:@"!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                //[tokenArray insertObject:@"$1" atIndex:i+1];
            }
            range = [tk rangeOfString:@"?"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"?" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                //[tokenArray insertObject:@"$2" atIndex:i+1];
            }
            range = [tk rangeOfString:@"!!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                //[tokenArray insertObject:@"$3" atIndex:i+1];
            }
            range = [tk rangeOfString:@"??"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"??" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                //[tokenArray insertObject:@"$4" atIndex:i+1];
            }
            range = [tk rangeOfString:@"!?"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!?" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                //[tokenArray insertObject:@"$5" atIndex:i+1];
            }
            range = [tk rangeOfString:@"?!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"?!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                //[tokenArray insertObject:@"$6" atIndex:i+1];
            }
        }
    }
    
    [self parseGameToDeleteTrePunti];
    
    
    
    NSLog(@"INIZIO STAMPA DATI PRODOTTA DA ANALYSE GAME PARSE WITH GRAFFA");
    for (NSString *tk in tokenArray) {
        
        if ([tk hasSuffix:@"..."]) {
            NSLog(@"TOKEN = %@  da eliminare", tk);
        }
        else {
            NSLog(@"TOKEN = %@", tk);
        }
    }
    NSLog(@"FINE   STAMPA DATI PRODOTTA DA ANALYSE GAME PARSE WITH GRAFFA");
    
}


- (void) parseGameToTokenArrayWithGraffa {
    
    //[self parsePositionToTokenArrayWithGraffa3];
    
    NSArray *colonne = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", nil];
    NSArray *pezzi = [NSArray arrayWithObjects:@"K", @"Q", @"R", @"B", @"N", @"O", nil];
    
    NSMutableString *token = [[NSMutableString alloc] init];
    tokenArray = [[NSMutableArray alloc] init];
    
    NSString *prevCar;
    NSUInteger numGraffeAperte = 0;
    
    BOOL comment = NO;
    
    for (NSUInteger i=0; i<gameToAnalayze.length; i++) {
        NSString *car = [gameToAnalayze substringWithRange:NSMakeRange(i, 1)];
        
        if ([car isEqualToString:@" "]) {
            if (comment) {
                [token appendString:car];
            }
            else {
                if (token.length > 0) {
                    [tokenArray addObject:token];
                }
                token = [[NSMutableString alloc] init];
                prevCar = car;
            }
        }
        else if ([car isEqualToString:@"("] && numGraffeAperte==0) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            [tokenArray addObject:car];
            token = [[NSMutableString alloc] init];
            prevCar = car;
        }
        else if ([car isEqualToString:@")"] && numGraffeAperte==0) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            [tokenArray addObject:car];
            token = [[NSMutableString alloc] init];
            prevCar = car;
        }
        else if ([car isEqualToString:@"{"]) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            token = [[NSMutableString alloc] init];
            prevCar = car;
            numGraffeAperte++;
            comment = YES;
            [token appendString:car];
        }
        else if ([car isEqualToString:@"}"]) {
            [token appendString:car];
            [tokenArray addObject:token];
            token = [[NSMutableString alloc] init];
            numGraffeAperte--;
            comment = NO;
        }
        else {
            if (comment) {
                [token appendString:car];
            }
            else {
                if ([prevCar isEqualToString:@"."] && ([colonne containsObject:car] || [pezzi containsObject:car])) {
                    [tokenArray addObject:token];
                    token = [[NSMutableString alloc] init];
                }
                [token appendString:car];
                prevCar = car;
            }
        }
        
        if (i == gameToAnalayze.length - 1) {
            [tokenArray addObject:token];
        }
    }
    
    
    //Esamina se nella mossa ci sono punti escalamativi o interrogativi piuttosto che i nag
    
    for (int i=0; i<tokenArray.count; i++) {
        NSString *tk = [tokenArray objectAtIndex:i];
        if (![tk hasPrefix:@"{"]) {
            NSRange range = [tk rangeOfString:@"!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$1" atIndex:i+1];
            }
            range = [tk rangeOfString:@"?"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"?" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$2" atIndex:i+1];
            }
            range = [tk rangeOfString:@"!!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$3" atIndex:i+1];
            }
            range = [tk rangeOfString:@"??"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"??" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$4" atIndex:i+1];
            }
            range = [tk rangeOfString:@"!?"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!?" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$5" atIndex:i+1];
            }
            range = [tk rangeOfString:@"?!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"?!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$6" atIndex:i+1];
            }
        }
    }
    
    
    /*
    NSLog(@"INIZIO STAMPA DATI PRODOTTA DA ANALYSE GAME PARSE WITH GRAFFA");
    for (NSString *tk in tokenArray) {
     
     if ([tk hasSuffix:@"..."]) {
         NSLog(@"TOKEN = %@  da eliminare", tk);
     }
     else {
         NSLog(@"TOKEN = %@", tk);
    }
     }
     NSLog(@"FINE   STAMPA DATI PRODOTTA DA ANALYSE GAME PARSE WITH GRAFFA");
    */
}

- (void) parsePositionToTokenArray {
    
    //if ([risultato containsObject:gameToAnalayze]) {
    //    NSLog(@"Non analizzo un cavolo perchè non ci sono mosse");
    //    return;
    //}
    //else {
    //    NSLog(@"GAME TO ANALYZE = %@", gameToAnalayze);
    //}
    
    NSArray *colonne = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", nil];
    NSArray *pezzi = [NSArray arrayWithObjects:@"K", @"Q", @"R", @"B", @"N", @"O", nil];
    
    NSMutableString *token = [[NSMutableString alloc] init];
    tokenArray = [[NSMutableArray alloc] init];
    
    NSString *prevCar;
    NSUInteger numGraffeAperte = 0;
    
    for (NSUInteger i=0; i<gameToAnalayze.length; i++) {
        NSString *car = [gameToAnalayze substringWithRange:NSMakeRange(i, 1)];
        if ([car isEqualToString:@" "]) {
            if (numGraffeAperte>0) {
                [token appendString:car];
            }
            else {
                if (token.length > 0) {
                    [tokenArray addObject:token];
                }
                token = [[NSMutableString alloc] init];
                prevCar = car;
            }
        }
        else if ([car isEqualToString:@"("] && numGraffeAperte==0) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            [tokenArray addObject:car];
            token = [[NSMutableString alloc] init];
            prevCar = car;
        }
        else if ([car isEqualToString:@")"] && numGraffeAperte==0) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            [tokenArray addObject:car];
            token = [[NSMutableString alloc] init];
            prevCar = car;
        }
        else if ([car isEqualToString:@"{"]) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            token = [[NSMutableString alloc] init];
            prevCar = car;
            numGraffeAperte++;
            [token appendString:car];
        }
        else if ([car isEqualToString:@"}"]) {
            [token appendString:car];
            [tokenArray addObject:token];
            token = [[NSMutableString alloc] init];
            numGraffeAperte--;
        }
        else {
            if ([prevCar isEqualToString:@"."] && ([colonne containsObject:car] || [pezzi containsObject:car])) {
                [tokenArray addObject:token];
                token = [[NSMutableString alloc] init];
            }
            [token appendString:car];
            prevCar = car;
        }
        
        if (i == gameToAnalayze.length - 1) {
            [tokenArray addObject:token];
        }
    }
    
    /*
    NSLog(@"INIZIO STAMPA DATI PRODOTTA DA ANALYSE GAME");
    NSUInteger numParentesiAperte = 0;
    BOOL primaMossaProcessata = NO;
    for (NSString *tk in tokenArray) {
        if ([tk hasPrefix:@"("]) {
            numParentesiAperte++;
        }
        if ([tk hasPrefix:@")"]) {
            numParentesiAperte--;
        }
        
        if ([tk hasPrefix:@"1..."] && primaMossaProcessata) {
            NSLog(@"TOKEN = %@  da eliminare", tk);
        }
        else {
            if ([tk hasSuffix:@"..."] && ((numParentesiAperte>0) || (![tk hasPrefix:@"1."]))) {
                NSLog(@"TOKEN = %@  da eliminare", tk);
            }
            else {
                NSLog(@"TOKEN = %@", tk);
            }
            if ([tk hasPrefix:@"1."] && !primaMossaProcessata) {
                primaMossaProcessata = YES;
            }
        }
    }
    NSLog(@"FINE   STAMPA DATI PRODOTTA DA ANALYSE GAME");
    */
}

/*
- (void) parsePositionToTokenArrayWithGraffa3 {
    
    NSString *bianco = @" ";
    NSString *punto = @".";
    NSString *puntiDue = @"..";
    NSString *dollaro = @"$";
    
    NSString *parentesiTondaAperta = @"(";
    NSString *parentesiTondaChiusa = @")";
    NSString *parentesiGraffaAperta = @"{";
    NSString *parentesiGraffaChiusa = @"}";
    
    NSUInteger numParentesiTondeAperte = 0;
    NSUInteger numParentesiGraffeAperte = 0;
    
    NSString *patternNumerazioneMossa = @"^\\d+\\.";
    NSError *error = NULL;
    NSRegularExpression *regexPatternNumerazioneMossa = [[NSRegularExpression alloc] initWithPattern:patternNumerazioneMossa options:0 error:&error];
    
    NSMutableArray *tokensList = [[NSMutableArray alloc] init];
    
    gameToAnalayze = [gameToAnalayze stringByReplacingOccurrencesOfString:@"(" withString:@" ( "];
    gameToAnalayze = [gameToAnalayze stringByReplacingOccurrencesOfString:@")" withString:@" ) "];
    gameToAnalayze = [gameToAnalayze stringByReplacingOccurrencesOfString:@"{" withString:@" { "];
    gameToAnalayze = [gameToAnalayze stringByReplacingOccurrencesOfString:@"}" withString:@" } "];
    
    NSArray *tokenArray3 = [gameToAnalayze componentsSeparatedByString:bianco];
    
    NSLog(@"************* INIZIO STAMPA DATI INIZIALE TO TOKEN ARRAY WITH GRAFFA 3");
    for (NSString *tk in tokenArray3) {
        NSLog(@"token:%@", tk);
    }
    NSLog(@"************** FINE   STAMPA DATI INIZIALE TO TOKEN ARRAY WITH GRAFFA 3");
    
    
    for (NSString *tk1 in tokenArray3) {
        
        NSString *tk = [tk1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (tk.length == 0) {
            continue;
        }
        
        if ([tk isEqualToString:parentesiGraffaChiusa]) {
            NSLog(@"Questo token rappresenta la fine di un commento scritto n.%d", numParentesiGraffeAperte);
            numParentesiGraffeAperte--;
            
            NSString *lastToken = [tokensList lastObject];
            lastToken = [lastToken stringByAppendingFormat:@" %@", tk];
            [tokensList replaceObjectAtIndex:tokensList.count - 1 withObject:lastToken];
            //[tokensList addObject:tk];
            continue;
        }
        
        if (numParentesiGraffeAperte > 0) {
            NSLog(@"Questo token viene inserito in parentesi graffa:%@", tk);
            
            NSString *lastToken = [tokensList lastObject];
            lastToken = [lastToken stringByAppendingFormat:@" %@", tk];
            [tokensList replaceObjectAtIndex:tokensList.count - 1 withObject:lastToken];
            //[tokensList addObject:tk];
            continue;
        }
        
        NSArray *matches = [regexPatternNumerazioneMossa matchesInString:tk options:0 range:NSMakeRange(0, [tk length])];
        
        if (matches.count > 0) {
            for (NSTextCheckingResult *match in matches) {
                NSRange matchRange = [match range];
                NSString *subString = [tk substringWithRange:matchRange];
                NSLog(@"REGEX INIZIALE:%@", subString);
                [tokensList addObject:subString];
                NSRange range = NSMakeRange(matchRange.location + matchRange.length, tk.length - matchRange.length);
                NSString *endString = [tk substringWithRange:range];
                NSLog(@"REGEX FINALE:%@", endString);
                if (endString.length>0) {
                    [tokensList addObject:endString];
                }
            }
        }
        else if ([regexPatternNumerazioneMossa numberOfMatchesInString:tk options:0 range:NSMakeRange(0, [tk length])] > 0) {
            NSLog(@"Questo token rappresenta la numerazione mosse con REGEX:%@", tk);
            [tokensList addObject:tk];
        }
        else if ([tk hasSuffix:punto] && isnumber([tk characterAtIndex:0])) {
            NSLog(@"Questo token rappresenta il numero mossa:%@", tk);
            [tokensList addObject:tk];
        }
        else if ([tk hasPrefix:punto] && [tk hasSuffix:punto]) {
            NSLog(@"Questo token rappresenta un certo numero di punti:%@", tk);
            [tokensList addObject:puntiDue];
        }
        else if ([tk hasPrefix:dollaro] && isnumber([tk characterAtIndex:(tk.length - 1)])) {
            NSLog(@"Questo token rappresenta il commento ad una mossa:%@", tk);
            [tokensList addObject:tk];
        }
        else if ([tk isEqualToString:parentesiTondaAperta]) {
            numParentesiTondeAperte++;
            NSLog(@"Questo Token rappresenta l'inizio della variante %d", numParentesiTondeAperte);
            [tokensList addObject:tk];
        }
        else if ([tk isEqualToString:parentesiTondaChiusa]) {
            NSLog(@"Questo Token rappresenta la fine della variante %d", numParentesiTondeAperte);
            numParentesiTondeAperte--;
            [tokensList addObject:tk];
        }
        else if ([tk isEqualToString:parentesiGraffaAperta]) {
            numParentesiGraffeAperte++;
            NSLog(@"Questo token rappresenta l'inizio di un commento scritto n.%d", numParentesiGraffeAperte);
            [tokensList addObject:tk];
        }
        //else if ([tk isEqualToString:parentesiGraffaChiusa]) {
        //    NSLog(@"Questo token rappresenta la fine di un commento scritto n.%d", numParentesiGraffeAperte);
        //    numParentesiGraffeAperte--;
        //    [tokensList addObject:tk];
        //}
        else if ([tk hasPrefix:parentesiGraffaAperta] && [tk hasSuffix:parentesiGraffaChiusa]) {
            NSLog(@"Questo Token rappresenta un commento scritto compreso di parentesi:%@", tk);
            [tokensList addObject:tk];
        }
        else if ([risultato containsObject:tk]) {
            NSLog(@"Questo token rappresenta il risultato finale:%@", tk);
            [tokensList addObject:tk];
        }
        else if ([regexPatternMossa numberOfMatchesInString:tk options:0 range:NSMakeRange(0, [tk length])] > 0) {
            NSLog(@"Questo token rappresenta una mossa:%@", tk);
            [tokensList addObject:tk];
        }
        else {
            NSLog(@"Questo token non lo conosco:%@", tk);
            [tokensList addObject:tk];
        }
    }
    
    
    
    
    
    NSLog(@"************* INIZIO STAMPA DATI PRODOTTA DA ANALYSE POSITION TO TOKEN ARRAY WITH GRAFFA 3");
    for (NSString *tk in tokensList) {
        NSLog(@"TOKEN:%@", tk);
    }
    NSLog(@"************** FINE   STAMPA DATI PRODOTTA DA ANALYSE POSITION TO TOKEN ARRAY WITH GRAFFA 3");
    
    
    NSLog(@"************* INIZIO STAMPA SENZA COMMENTI TESTUALI DATI PRODOTTA DA ANALYSE POSITION TO TOKEN ARRAY WITH GRAFFA 3");
    for (NSString *tk in tokensList) {
        if (![tk hasPrefix:parentesiGraffaAperta]) {
            NSLog(@"PARTITA:%@", tk);
        }
    }
    
    NSLog(@"************** FINE STAMPA SENZA COMMENTI TESTUALI DATI PRODOTTA DA ANALYSE POSITION TO TOKEN ARRAY WITH GRAFFA 3");
}
*/

/*
- (void) parsePositionToTokenArrayWithGraffa2 {
    
    //NSCharacterSet *numericSet = [NSCharacterSet decimalDigitCharacterSet];
    
    NSString *punto = @".";
    NSString *bianco = @" ";
    NSString *parentesiTondaAperta = @"(";
    NSString *parentesiTondaChiusa = @")";
    NSUInteger numParentesiTondeAperte = 0;
    NSString *parentesiGraffaAperta = @"{";
    NSString *parentesiGraffaChiusa = @"}";
    NSUInteger numParentesiGraffeAperte = 0;
    NSString *dollaro = @"$";
    
    NSArray *numeri = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    
    NSArray *colonne = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", nil];
    NSArray *pezzi = [NSArray arrayWithObjects:@"K", @"Q", @"R", @"B", @"N", @"O", nil];
    
    NSMutableString *token = [[NSMutableString alloc] init];
    tokenArray = [[NSMutableArray alloc] init];
    
    NSString *prevCar;
    //NSUInteger numGraffeAperte = 0;
    
    //BOOL comment = NO;
    BOOL isDigit = NO;
    BOOL commentoMossa = NO;
    
    for (NSUInteger i=0; i<gameToAnalayze.length; i++) {
        NSString *car = [gameToAnalayze substringWithRange:NSMakeRange(i, 1)];
        
        NSString *nextCar = nil;
        if (i<gameToAnalayze.length - 1) {
            nextCar = [gameToAnalayze substringWithRange:NSMakeRange(i + 1, 1)];
        }
        
        NSLog(@"CAR = %@ --- NEXT CAR = %@  >>>>> Token:%@", car, nextCar, token);
        
        isDigit = [numeri containsObject:car];
        
        if (isDigit) {
            if (numParentesiTondeAperte>0 || numParentesiGraffeAperte>0) {
                continue;
            }
            if (commentoMossa) {
                [token appendString:car];
                prevCar = car;
                continue;
            }
            [token appendString:car];
            prevCar = car;
            [self stampaToken:token];
        }
        else if ([car isEqualToString:punto]) {
            if (numParentesiTondeAperte>0 || numParentesiGraffeAperte>0) {
                continue;
            }
            [token appendString:car];
            [self stampaToken:token];
            
            if (![prevCar isEqualToString:punto]) {
                [tokenArray addObject:token];
                token = [[NSMutableString alloc] init];
            }
            
            if (![nextCar isEqualToString:punto]) {
                [tokenArray addObject:token];
                token = [[NSMutableString alloc] init];
            }
            
            
            prevCar = car;
        }
        else if ([car isEqualToString:bianco]) {
            [self stampaToken:token];
            if (numParentesiTondeAperte>0 || numParentesiGraffeAperte>0) {
                prevCar = car;
                continue;
            }
            
            if ([nextCar isEqualToString:punto]) {
                NSLog(@"Prossimo carattere Punto, carattere attuale Bianco");
                prevCar = car;
                continue;
            }
            
            if ([prevCar isEqualToString:punto]) {
                NSLog(@"Precedente carattere Punto, carattere attuale Bianco");
                prevCar = car;
                continue;
            }
            
            
            if (token.length>0) {
                if ([token hasSuffix:@".."]) {
                    NSArray *tkarray = [token componentsSeparatedByString:punto];
                    token = [[NSMutableString alloc] initWithString:[tkarray objectAtIndex:0]];
                    [token appendString:@"..."];
                }
                [tokenArray addObject:token];
            }
            
            token = [[NSMutableString alloc] init];
            prevCar = car;
        }
        else if ([pezzi containsObject:car]) {
            if (numParentesiTondeAperte>0 || numParentesiGraffeAperte>0) {
                prevCar = car;
                continue;
            }
            [token appendString:car];
            prevCar = car;
            [self stampaToken:token];
        }
        else if ([colonne containsObject:car]) {
            if (numParentesiTondeAperte>0 || numParentesiGraffeAperte>0) {
                continue;
            }
            [token appendString:car];
            prevCar = car;
        }
        else if ([car isEqualToString:parentesiTondaAperta]) {
            numParentesiTondeAperte++;
        }
        else if ([car isEqualToString:parentesiTondaChiusa]) {
            numParentesiTondeAperte--;
        }
        else if ([car isEqualToString:parentesiGraffaAperta]) {
            numParentesiGraffeAperte++;
        }
        else if ([car isEqualToString:parentesiGraffaChiusa]) {
            numParentesiGraffeAperte--;
        }
        else if ([car isEqualToString:dollaro]) {
            if (numParentesiTondeAperte>0 || numParentesiGraffeAperte>0) {
                continue;
            }
            commentoMossa = YES;
            [token appendString:car];
            prevCar = car;
        }
    }
    
    
    
    NSLog(@"************* INIZIO STAMPA DATI PRODOTTA DA ANALYSE POSITION TO TOKEN ARRAY WITH GRAFFA 2");
    for (NSString *tk in tokenArray) {
        if ([tk hasSuffix:@"..."]) {
            NSLog(@"TOKEN = %@", tk);
        }
        else {
            NSLog(@"TOKEN = %@", tk);
        }
    }
    NSLog(@"************** FINE   STAMPA DATI PRODOTTA DA ANALYSE POSITION TO TOKEN ARRAY WITH GRAFFA 2");
    
    return;
    
    
    //Provo a togliere le annotazioni non congrue con la notazione PGN
    
     //NSMutableCharacterSet *setAnnotation = [[NSMutableCharacterSet alloc] init];
     //[setAnnotation addCharactersInString:@"!"];
     //[setAnnotation addCharactersInString:@"?"];
     //[setAnnotation addCharactersInString:@"!!"];
     //[setAnnotation addCharactersInString:@"??"];
     //[setAnnotation addCharactersInString:@"!?"];
     //[setAnnotation addCharactersInString:@"?!"];
     
     //for (int i=0; i<tokenArray.count; i++) {
     //NSString *tk = [tokenArray objectAtIndex:i];
     //NSString *tkNew = [tk stringByTrimmingCharactersInSet:setAnnotation];
     //[tokenArray replaceObjectAtIndex:i withObject:tkNew];
     //}
    
    //Esamina se nella mossa ci sono punti escalamativi o interrogativi piuttosto che i nag
    
    for (int i=0; i<tokenArray.count; i++) {
        NSString *tk = [tokenArray objectAtIndex:i];
        if (![tk hasPrefix:@"{"]) {
            NSRange range = [tk rangeOfString:@"!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$1" atIndex:i+1];
            }
            range = [tk rangeOfString:@"?"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"?" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$2" atIndex:i+1];
            }
            range = [tk rangeOfString:@"!!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$3" atIndex:i+1];
            }
            range = [tk rangeOfString:@"??"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"??" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$4" atIndex:i+1];
            }
            range = [tk rangeOfString:@"!?"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!?" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$5" atIndex:i+1];
            }
            range = [tk rangeOfString:@"?!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"?!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$6" atIndex:i+1];
            }
        }
    }
    
    
    
    
    
    //Esamina se la prima mossa inizia con un numero maggiore di uno
    
    
    BOOL modificaNumerazione = NO;
    
    for (NSString *tk in tokenArray) {
        if ([tk hasPrefix:@"1"]) {
            modificaNumerazione = NO;
            break;
        }
        else if ([tk hasPrefix:@"{"]) {
            continue;
        }
        else {
            modificaNumerazione = YES;
            break;
        }
    }
    
    if (!modificaNumerazione) {
        NSLog(@"Non devo modificare la numerazione");
        numerazioneModificata = NO;
        return;
    }
    else {
        NSLog(@"Devo modificare la numerazione");
        numerazioneModificata = YES;
    }
    
    
    NSUInteger numeroMossa = 0;
    
    for (int i=0; i<tokenArray.count; i++) {
        NSString *tk = [tokenArray objectAtIndex:i];
        if ([tk hasSuffix:@"..."]) {
            //NSLog(@"Questo numero è da cambiare  %@", tk);
            
            if (i==0) {
                numeroMossa++;
            }
            //numeroMossa++;
            NSString *numeroMossaString = [NSString stringWithFormat:@"%d...", numeroMossa];
            [tokenArray replaceObjectAtIndex:i withObject:numeroMossaString];
        }
        else {
            if ([tk hasSuffix:@"."]) {
                numeroMossa++;
                NSString *numeroMossaString = [NSString stringWithFormat:@"%d.", numeroMossa];
                [tokenArray replaceObjectAtIndex:i withObject:numeroMossaString];
            }
        }
    }
    
    
    
    NSLog(@"$$$$$$$$$$$$$$ INIZIO STAMPA DATI PRODOTTA DA ANALYSE POSITION TO TOKEN ARRAY WITH GRAFFA");
    for (NSString *tk in tokenArray) {
        if ([tk hasSuffix:@"..."]) {
            NSLog(@"TOKEN = %@", tk);
        }
        else {
            NSLog(@"TOKEN = %@", tk);
        }
    }
    NSLog(@"$$$$$$$$$$$$$$ FINE   STAMPA DATI PRODOTTA DA ANALYSE POSITION TO TOKEN ARRAY WITH GRAFFA");
}
*/


/*
- (void) stampaToken:(NSString *)token {
    NSLog(@"TOKEN:%@", token);
}
*/


- (void) parsePositionToTokenArrayWithGraffaWithStartNumberGreaterOne {  //Metodo che gestisce il numero iniziale della posizione maggiore di 1
    NSArray *colonne = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", nil];
    NSArray *pezzi = [NSArray arrayWithObjects:@"K", @"Q", @"R", @"B", @"N", @"O", nil];
    
    NSMutableString *token = [[NSMutableString alloc] init];
    tokenArray = [[NSMutableArray alloc] init];
    
    NSString *prevCar;
    NSUInteger numGraffeAperte = 0;
    
    BOOL comment = NO;
    
    for (NSUInteger i=0; i<gameToAnalayze.length; i++) {
        NSString *car = [gameToAnalayze substringWithRange:NSMakeRange(i, 1)];
        
        if ([car isEqualToString:@" "]) {
            if (comment) {
                [token appendString:car];
            }
            else {
                if (token.length > 0) {
                    [tokenArray addObject:token];
                }
                token = [[NSMutableString alloc] init];
                prevCar = car;
            }
        }
        else if ([car isEqualToString:@"("] && numGraffeAperte==0) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            [tokenArray addObject:car];
            token = [[NSMutableString alloc] init];
            prevCar = car;
        }
        else if ([car isEqualToString:@")"] && numGraffeAperte==0) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            [tokenArray addObject:car];
            token = [[NSMutableString alloc] init];
            prevCar = car;
        }
        else if ([car isEqualToString:@"{"]) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            token = [[NSMutableString alloc] init];
            prevCar = car;
            numGraffeAperte++;
            comment = YES;
            [token appendString:car];
        }
        else if ([car isEqualToString:@"}"]) {
            [token appendString:car];
            [tokenArray addObject:token];
            token = [[NSMutableString alloc] init];
            numGraffeAperte--;
            comment = NO;
        }
        else {
            if (comment) {
                [token appendString:car];
            }
            else {
                if ([prevCar isEqualToString:@"."] && ([colonne containsObject:car] || [pezzi containsObject:car])) {
                    [tokenArray addObject:token];
                    token = [[NSMutableString alloc] init];
                }
                [token appendString:car];
                prevCar = car;
            }
        }
        
        if (i == gameToAnalayze.length - 1) {
            [tokenArray addObject:token];
        }
    }
    
    //Esamina se nella mossa ci sono punti escalamativi o interrogativi piuttosto che i nag
    
    for (int i=0; i<tokenArray.count; i++) {
        NSString *tk = [tokenArray objectAtIndex:i];
        if (![tk hasPrefix:@"{"]) {
            NSRange range = [tk rangeOfString:@"!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$1" atIndex:i+1];
            }
            range = [tk rangeOfString:@"?"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"?" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$2" atIndex:i+1];
            }
            range = [tk rangeOfString:@"!!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$3" atIndex:i+1];
            }
            range = [tk rangeOfString:@"??"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"??" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$4" atIndex:i+1];
            }
            range = [tk rangeOfString:@"!?"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!?" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$5" atIndex:i+1];
            }
            range = [tk rangeOfString:@"?!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"?!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$6" atIndex:i+1];
            }
        }
    }
    
    /*
    NSLog(@"************* INIZIO STAMPA DATI PRODOTTA DA PARSE POSITION TO TOKEN ARRAY WITH GRAFFA WITH START NUMBER GREATER ONE");
    for (NSString *tk in tokenArray) {
        if ([tk hasSuffix:@"..."]) {
            NSLog(@"TOKEN = %@", tk);
        }
        else {
            NSLog(@"TOKEN = %@", tk);
        }
    }
    NSLog(@"************** FINE   STAMPA DATI PRODOTTA DA PARSE POSITION TO TOKEN ARRAY WITH GRAFFA WITH START NUMBER GREATER ONE");
    */
}


- (void) parsePositionToTokenArrayWithGraffa {
    
    [self parsePositionToTokenArrayWithGraffaWithStartNumberGreaterOne];
    return;
    
    //[self parsePositionToTokenArrayWithGraffa3];
    //return;
    
    
    //NSCharacterSet *numericSet = [NSCharacterSet decimalDigitCharacterSet];
    
    //NSArray *numeri = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    
    NSArray *colonne = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", nil];
    NSArray *pezzi = [NSArray arrayWithObjects:@"K", @"Q", @"R", @"B", @"N", @"O", nil];
    
    NSMutableString *token = [[NSMutableString alloc] init];
    tokenArray = [[NSMutableArray alloc] init];
    
    NSString *prevCar;
    NSUInteger numGraffeAperte = 0;
    
    BOOL comment = NO;
    
    for (NSUInteger i=0; i<gameToAnalayze.length; i++) {
        NSString *car = [gameToAnalayze substringWithRange:NSMakeRange(i, 1)];
        
        if ([car isEqualToString:@" "]) {
            if (comment) {
                [token appendString:car];
            }
            else {
                if (token.length > 0) {
                    [tokenArray addObject:token];
                }
                token = [[NSMutableString alloc] init];
                prevCar = car;
            }
        }
        else if ([car isEqualToString:@"("] && numGraffeAperte==0) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            [tokenArray addObject:car];
            token = [[NSMutableString alloc] init];
            prevCar = car;
        }
        else if ([car isEqualToString:@")"] && numGraffeAperte==0) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            [tokenArray addObject:car];
            token = [[NSMutableString alloc] init];
            prevCar = car;
        }
        else if ([car isEqualToString:@"{"]) {
            if (token.length > 0) {
                [tokenArray addObject:token];
            }
            token = [[NSMutableString alloc] init];
            prevCar = car;
            numGraffeAperte++;
            comment = YES;
            [token appendString:car];
        }
        else if ([car isEqualToString:@"}"]) {
            [token appendString:car];
            [tokenArray addObject:token];
            token = [[NSMutableString alloc] init];
            numGraffeAperte--;
            comment = NO;
        }
        else {
            if (comment) {
                [token appendString:car];
            }
            else {
                if ([prevCar isEqualToString:@"."] && ([colonne containsObject:car] || [pezzi containsObject:car])) {
                    [tokenArray addObject:token];
                    token = [[NSMutableString alloc] init];
                }
                [token appendString:car];
                prevCar = car;
            }
        }
        
        if (i == gameToAnalayze.length - 1) {
            [tokenArray addObject:token];
        }
    
    }
    
    
    /*
     NSLog(@"************* INIZIO STAMPA DATI PRODOTTA DA ANALYSE POSITION TO TOKEN ARRAY WITH GRAFFA");
     for (NSString *tk in tokenArray) {
     if ([tk hasSuffix:@"..."]) {
     NSLog(@"TOKEN = %@", tk);
     }
     else {
     NSLog(@"TOKEN = %@", tk);
     }
     }
     NSLog(@"************** FINE   STAMPA DATI PRODOTTA DA ANALYSE POSITION TO TOKEN ARRAY WITH GRAFFA");
    */
    
    //Provo a togliere le annotazioni non congrue con la notazione PGN
    /*
    NSMutableCharacterSet *setAnnotation = [[NSMutableCharacterSet alloc] init];
    [setAnnotation addCharactersInString:@"!"];
    [setAnnotation addCharactersInString:@"?"];
    [setAnnotation addCharactersInString:@"!!"];
    [setAnnotation addCharactersInString:@"??"];
    [setAnnotation addCharactersInString:@"!?"];
    [setAnnotation addCharactersInString:@"?!"];
    
    for (int i=0; i<tokenArray.count; i++) {
        NSString *tk = [tokenArray objectAtIndex:i];
        NSString *tkNew = [tk stringByTrimmingCharactersInSet:setAnnotation];
        [tokenArray replaceObjectAtIndex:i withObject:tkNew];
    }*/
    
    //Esamina se nella mossa ci sono punti escalamativi o interrogativi piuttosto che i nag
    
    for (int i=0; i<tokenArray.count; i++) {
        NSString *tk = [tokenArray objectAtIndex:i];
        if (![tk hasPrefix:@"{"]) {
            NSRange range = [tk rangeOfString:@"!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$1" atIndex:i+1];
            }
            range = [tk rangeOfString:@"?"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"?" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$2" atIndex:i+1];
            }
            range = [tk rangeOfString:@"!!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$3" atIndex:i+1];
            }
            range = [tk rangeOfString:@"??"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"??" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$4" atIndex:i+1];
            }
            range = [tk rangeOfString:@"!?"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"!?" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$5" atIndex:i+1];
            }
            range = [tk rangeOfString:@"?!"];
            if (range.location != NSNotFound) {
                NSString *newMove = [tk stringByReplacingOccurrencesOfString:@"?!" withString:@""];
                [tokenArray replaceObjectAtIndex:i withObject:newMove];
                [tokenArray insertObject:@"$6" atIndex:i+1];
            }
        }
    }
    
    
    
    //Esamina se la prima mossa inizia con un numero maggiore di uno
    
    
    BOOL modificaNumerazione = NO;
    
    for (NSString *tk in tokenArray) {
        if ([tk hasPrefix:@"1"]) {
            modificaNumerazione = NO;
            break;
        }
        else if ([tk hasPrefix:@"{"]) {
            continue;
        }
        else {
            modificaNumerazione = YES;
            break;
        }
    }
    
    if (!modificaNumerazione) {
        NSLog(@"Non devo modificare la numerazione");
        numerazioneModificata = NO;
        return;
    }
    else {
        NSLog(@"Devo modificare la numerazione");
        numerazioneModificata = YES;
    }
    
    
    NSUInteger numeroMossa = 0;
    
    for (int i=0; i<tokenArray.count; i++) {
        NSString *tk = [tokenArray objectAtIndex:i];
        if ([tk hasSuffix:@"..."]) {
            //NSLog(@"Questo numero è da cambiare  %@", tk);
            
            if (i==0) {
                numeroMossa++;
            }
            //numeroMossa++;
            NSString *numeroMossaString = [NSString stringWithFormat:@"%ld...", (long)numeroMossa];
            [tokenArray replaceObjectAtIndex:i withObject:numeroMossaString];
        }
        else {
            if ([tk hasSuffix:@"."]) {
                numeroMossa++;
                NSString *numeroMossaString = [NSString stringWithFormat:@"%ld.", (long)numeroMossa];
                [tokenArray replaceObjectAtIndex:i withObject:numeroMossaString];
            }
        }
    }
    
    
    /*
    NSLog(@"$$$$$$$$$$$$$$ INIZIO STAMPA DATI PRODOTTA DA ANALYSE POSITION TO TOKEN ARRAY WITH GRAFFA");
    for (NSString *tk in tokenArray) {
        if ([tk hasSuffix:@"..."]) {
            NSLog(@"TOKEN = %@", tk);
        }
        else {
            NSLog(@"TOKEN = %@", tk);
        }
    }
    NSLog(@"$$$$$$$$$$$$$$ FINE   STAMPA DATI PRODOTTA DA ANALYSE POSITION TO TOKEN ARRAY WITH GRAFFA");
    */
}

- (BOOL) numerazioneMosseModificata {
    return numerazioneModificata;
}

- (void) parseGameToDeleteTrePunti {
    
    NSMutableArray *discardedMoves = [[NSMutableArray alloc] init];
    for (NSString *tk in tokenArray) {

        if ([tk hasSuffix:@"..."]) {
            [discardedMoves addObject:tk];
        }
    }
    [tokenArray removeObjectsInArray:discardedMoves];
    
    
    /*
    
    NSLog(@"INIZIO STAMPA DATI PRODOTTA DA ANALYSE GAME DOPO ELIMINAZIONE TRE PUNTI");
    for (NSString *tk in tokenArray) {
        if ([tk hasSuffix:@"..."]) {
            NSLog(@"TOKEN = %@", tk);
        }
        else {
            NSLog(@"TOKEN = %@", tk);
        }
    }
    NSLog(@"FINE   STAMPA DATI PRODOTTA DA ANALYSE GAME DOPO ELIMINAZIONE TRE PUNTI");
   */
}

- (void) parsePositionToDeleteTrePuntiWithStartNumberGreaterOne {
    NSUInteger numParentesiAperte = 0;
    
    BOOL primaMossaProcessata = NO;
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    
    NSString *primaMossaSenzaPunti = [_fenParser getPrimaMossaConUnPunto];
    NSString *primaMossaConPunti = [_fenParser getPrimaMossaConTrePunti];
    
    NSLog(@"%@", primaMossaConPunti);
    NSLog(@"%@", primaMossaSenzaPunti);
    
    for (int i=0; i<tokenArray.count; i++) {
        NSString *tk = [tokenArray objectAtIndex:i];
        if ([tk hasPrefix:@"("]) {
            numParentesiAperte++;
        }
        if ([tk hasPrefix:@")"]) {
            numParentesiAperte--;
        }
        
        if ([tk hasPrefix:primaMossaConPunti] && primaMossaProcessata) {
            [indexes addIndex:i];
        }
        else {
            if ([tk hasSuffix:@"..."] && ((numParentesiAperte>0) || (![tk hasPrefix:primaMossaSenzaPunti]))) {
                [indexes addIndex:i];
            }
            if ([tk hasPrefix:primaMossaSenzaPunti] && !primaMossaProcessata) {
                primaMossaProcessata = YES;
            }
        }
    }
    
    [tokenArray removeObjectsAtIndexes:indexes];
    
    
    NSInteger index = -1;
    for (NSString *tk in tokenArray) {
        if ([tk isEqualToString:@"("]) {
            numParentesiAperte++;
        }
        if ([tk isEqualToString:@")"]) {
            numParentesiAperte--;
        }
        if ([tk hasSuffix:@"..."] && (numParentesiAperte==0) && ([tk hasPrefix:primaMossaSenzaPunti])) {
            index = [tokenArray indexOfObject:tk];
            break;
        }
    }
    
    if (index > -1) {
        NSString *prima = [tokenArray objectAtIndex:index];
        prima = [prima stringByReplacingOccurrencesOfString:primaMossaConPunti withString:primaMossaConPunti];
        [tokenArray replaceObjectAtIndex:index withObject:prima];
        [tokenArray insertObject:@"XXX" atIndex:index + 1];
    }
    
    
    /*
    NSLog(@"INIZIO STAMPA DATI PRODOTTA DA PARSE POSITION TO DELETE TRE PUNTI WITH START NUMBER GREATER ONE");
    for (NSString *tk in tokenArray) {
        if ([tk hasSuffix:@"..."]) {
            NSLog(@"TOKEN = %@", tk);
        }
        else {
            NSLog(@"TOKEN = %@", tk);
        }
    }
    NSLog(@"FINE   STAMPA DATI PRODOTTA DA PARSE POSITION TO DELETE TRE PUNTI WITH START NUMBER GREATER ONE");
    */
}

- (void) parsePositionToDeleteTrePunti {
    
    [self parsePositionToDeleteTrePuntiWithStartNumberGreaterOne];
    return;
    
    NSUInteger numParentesiAperte = 0;
    
    BOOL primaMossaProcessata = NO;
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];

    for (int i=0; i<tokenArray.count; i++) {
        NSString *tk = [tokenArray objectAtIndex:i];
        if ([tk hasPrefix:@"("]) {
            numParentesiAperte++;
        }
        if ([tk hasPrefix:@")"]) {
            numParentesiAperte--;
        }
        
        if ([tk hasPrefix:@"1..."] && primaMossaProcessata) {
            [indexes addIndex:i];
        }
        else {
            if ([tk hasSuffix:@"..."] && ((numParentesiAperte>0) || (![tk hasPrefix:@"1."]))) {
                [indexes addIndex:i];
            }
            if ([tk hasPrefix:@"1."] && !primaMossaProcessata) {
                primaMossaProcessata = YES;
            }
        }
    }
    
    [tokenArray removeObjectsAtIndexes:indexes];
    
    
    NSInteger index = -1;
    for (NSString *tk in tokenArray) {
        if ([tk isEqualToString:@"("]) {
            numParentesiAperte++;
        }
        if ([tk isEqualToString:@")"]) {
            numParentesiAperte--;
        }
        if ([tk hasSuffix:@"..."] && (numParentesiAperte==0) && ([tk hasPrefix:@"1."])) {
            index = [tokenArray indexOfObject:tk];
            break;
        }
    }
    
    if (index > -1) {
        NSString *prima = [tokenArray objectAtIndex:index];
        prima = [prima stringByReplacingOccurrencesOfString:@"1..." withString:@"1."];
        [tokenArray replaceObjectAtIndex:index withObject:prima];
        [tokenArray insertObject:@"XXX" atIndex:index + 1];
    }
    
    
    /*
    NSLog(@"INIZIO STAMPA DATI PRODOTTA DA ANALYSE GAME DOPO ELIMINAZIONE TRE PUNTI");
    for (NSString *tk in tokenArray) {
        if ([tk hasSuffix:@"..."]) {
            NSLog(@"TOKEN = %@", tk);
        }
        else {
            NSLog(@"TOKEN = %@", tk);
        }
    }
    NSLog(@"FINE   STAMPA DATI PRODOTTA DA ANALYSE GAME DOPO ELIMINAZIONE TRE PUNTI");
    */
}

- (void) parseGameToListMoves {
    
    NSUInteger plycount = 0;
    BOOL mossaDelBianco;
    NSUInteger numParentesiTondeAperte = 0;
    
    NSString *tk = [self readToken];
    
    //PGNMove *tempMove;
    
    NSMutableArray *stackMoves = [[NSMutableArray alloc] init];
    NSMutableArray *stackPlyCount = [[NSMutableArray alloc] init];
    NSMutableArray *stackColor = [[NSMutableArray alloc] init];
    
    parsedGameArray = [[NSMutableArray alloc] init];
    NSString *colore;
    
    while (tk) {
        if ([tk hasSuffix:@"."]) {
            plycount++;
            mossaDelBianco = YES;
            tk = [self readToken];
        }
        else if ([regexPatternMossa numberOfMatchesInString:tk options:0 range:NSMakeRange(0, [tk length])] > 0) {
            move = [[PGNMove alloc] initWithFullMove:tk];
            if (numParentesiTondeAperte>0) {
                [move setInVariante:YES];
                [move setLivelloVariante:(int)numParentesiTondeAperte];
            }
            [move setPlyCount:(int)plycount];
            if (mossaDelBianco) {
                colore = @"w";
                [move setColor:colore];
                mossaDelBianco = NO;
                plycount++;
            }
            else {
                colore = @"b";
                [move setColor:colore];
            }
            [parsedGameArray addObject:[NSString stringWithFormat:@"%@", [move getMossaDaStampare]]];
            if (prevMove) {
                [prevMove addNextMove:move];
                [move addPrevMove:prevMove];
                prevMove = move;
            }
            else {
                prevMove = move;
                if (!firstMove) {
                    firstMove = move;
                }
                
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"$"]) {
            [prevMove setNag:tk];
            //[parsedGameArray addObject:[NSString stringWithFormat:@"%@", [PGNUtil nagToString:tk]]];
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"("]) {
            numParentesiTondeAperte++;
            //NSLog(@"Devo gestire la parentesi tonda aperta %d", numParentesiTondeAperte);
            [stackMoves addObject:prevMove];
            [stackPlyCount addObject:[NSNumber numberWithUnsignedInteger:plycount]];
            [stackColor addObject:colore];
            if ([colore hasPrefix:@"w"]) {
                plycount--;
                plycount--;
            }
            [parsedGameArray addObject:[prevMove getMossaDaStampareDopoAperturaParentesi]];
            prevMove = [prevMove getPrevMove];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@")"]) {
            numParentesiTondeAperte--;
            //NSLog(@"Devo gestire la parentesi tonda chiusa %d", numParentesiTondeAperte);
            prevMove = [stackMoves lastObject];
            [stackMoves removeLastObject];
            plycount = [[stackPlyCount lastObject] unsignedIntegerValue];
            [stackPlyCount removeLastObject];
            colore = [stackColor lastObject];
            [stackColor removeLastObject];
            tk = [self readToken];
            [parsedGameArray addObject:@"] "];
        }
        else if ([risultato containsObject:tk]) {
            [parsedGameArray addObject:tk];
            move = [[PGNMove alloc] initWithFullMove:tk];
            //*******
            if ([colore hasPrefix:@"b"]) {
                plycount++;
            }
            [move setPlyCount:(int)plycount];
            //*******
            [prevMove addNextMove:move];
            [move addPrevMove:prevMove];
            
            if (plycount == 0) {
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            
            tk = [self readToken];
            
        }
        else {
            tk = [self readToken];
        }
    }
}


- (void) parseGameToListMovesWithGraffaOld {
    
    NSUInteger plycount = 0;
    BOOL mossaDelBianco;
    NSUInteger numParentesiTondeAperte = 0;
    
    NSString *tk = [self readToken];
    
    //PGNMove *tempMove;
    
    NSMutableArray *stackMoves = [[NSMutableArray alloc] init];
    NSMutableArray *stackPlyCount = [[NSMutableArray alloc] init];
    NSMutableArray *stackColor = [[NSMutableArray alloc] init];
    
    parsedGameArray = [[NSMutableArray alloc] init];
    NSString *colore;
    
    NSString *textBeforeMove;
    NSString *textAfterMove;
    
    while (tk) {
        if ([tk hasPrefix:@"{"]) {
            textAfterMove = tk;
            if (move) {
                //[move setTextBefore:textBeforeMove];
                //textBeforeMove = nil;
                [move setTextAfter:textAfterMove];
                textAfterMove = nil;
            }
            else {
                [radice setTextAfter:textAfterMove];
                //textBeforeMove = textAfterMove;
                textAfterMove = nil;
            }
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasSuffix:@"."]) {
            plycount++;
            mossaDelBianco = YES;
            tk = [self readToken];
        }
        else if ([regexPatternMossa numberOfMatchesInString:tk options:0 range:NSMakeRange(0, [tk length])] > 0) {
            move = [[PGNMove alloc] initWithFullMove:tk];
            if (numParentesiTondeAperte>0) {
                [move setInVariante:YES];
                [move setLivelloVariante:(int)numParentesiTondeAperte];
            }
            [move setPlyCount:(int)plycount];
            if (mossaDelBianco) {
                colore = @"w";
                [move setColor:colore];
                mossaDelBianco = NO;
                plycount++;
            }
            else {
                colore = @"b";
                [move setColor:colore];
            }
            if (textBeforeMove) {
                [move setTextBefore:textBeforeMove];
                textBeforeMove = nil;
            }
            if (textAfterMove) {
                [move setTextAfter:textAfterMove];
                textAfterMove = nil;
            }
            [parsedGameArray addObject:[NSString stringWithFormat:@"%@", [move getMossaDaStampare]]];
            if (prevMove) {
                [prevMove addNextMove:move];
                [move addPrevMove:prevMove];
                prevMove = move;
            }
            else {
                prevMove = move;
                if (!firstMove) {
                    firstMove = move;
                }
                
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"$"]) {
            [prevMove setNag:tk];
            //[parsedGameArray addObject:[NSString stringWithFormat:@"%@", [PGNUtil nagToString:tk]]];
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"("]) {
            numParentesiTondeAperte++;
            //NSLog(@"Devo gestire la parentesi tonda aperta %d", numParentesiTondeAperte);
            [stackMoves addObject:prevMove];
            [stackPlyCount addObject:[NSNumber numberWithUnsignedInteger:plycount]];
            [stackColor addObject:colore];
            if ([colore hasPrefix:@"w"]) {
                plycount--;
                plycount--;
            }
            [parsedGameArray addObject:[prevMove getMossaDaStampareDopoAperturaParentesi]];
            prevMove = [prevMove getPrevMove];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@")"]) {
            numParentesiTondeAperte--;
            //NSLog(@"Devo gestire la parentesi tonda chiusa %d", numParentesiTondeAperte);
            prevMove = [stackMoves lastObject];
            [stackMoves removeLastObject];
            plycount = [[stackPlyCount lastObject] unsignedIntegerValue];
            [stackPlyCount removeLastObject];
            colore = [stackColor lastObject];
            [stackColor removeLastObject];
            tk = [self readToken];
            [parsedGameArray addObject:@"] "];
        }
        else if ([risultato containsObject:tk]) {
            [parsedGameArray addObject:tk];
            move = [[PGNMove alloc] initWithFullMove:tk];
            
            if (textBeforeMove) {
                //[move setTextBefore:textBeforeMove];
                textBeforeMove = nil;
            }
            
            //*******
            if ([colore hasPrefix:@"b"]) {
                plycount++;
            }
            [move setPlyCount:(int)plycount];
            //*******
            [prevMove addNextMove:move];
            [move addPrevMove:prevMove];
            
            if (plycount == 0) {
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            
            tk = [self readToken];
            
        }
        else {
            tk = [self readToken];
        }
    }
    
    /*
    NSLog(@"INIZIO STAMPA DATI PRODOTTA DA ANALYSE GAME DOPO Parse List Moves con Graffa");
    for (NSString *tk in parsedGameArray) {
        NSLog(@"TOKEN = %@", tk);
    }
    NSLog(@"FINE   STAMPA DATI PRODOTTA DA ANALYSE GAME DOPO Parse List Moves con Graffa");
    */
}


- (void) parseGameToListMovesWithGraffa {
    
    NSUInteger plycount = 0;
    BOOL mossaDelBianco;
    NSUInteger numParentesiTondeAperte = 0;
    
    NSString *tk = [self readToken];
    
    //PGNMove *tempMove;
    
    NSMutableArray *stackMoves = [[NSMutableArray alloc] init];
    NSMutableArray *stackPlyCount = [[NSMutableArray alloc] init];
    NSMutableArray *stackColor = [[NSMutableArray alloc] init];
    
    parsedGameArray = [[NSMutableArray alloc] init];
    NSString *colore;
    
    NSString *textBeforeMove;
    NSString *textAfterMove;
    
    while (tk) {
        if ([tk hasPrefix:@"{"]) {
            textAfterMove = tk;
            if (move) {
                //[move setTextBefore:textBeforeMove];
                //textBeforeMove = nil;
                
                if (textBeforeMove) {
                    [move setTextBefore:textBeforeMove];
                    textBeforeMove = nil;
                }
                
                if (![move textAfter]) {
                    [move setTextAfter:textAfterMove];
                    textAfterMove = nil;
                }
                else {
                    textBeforeMove = textAfterMove;
                    textAfterMove = nil;
                }
            }
            else {
                [radice setTextAfter:textAfterMove];
                //textBeforeMove = textAfterMove;
                textAfterMove = nil;
            }
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasSuffix:@"."]) {
            plycount++;
            mossaDelBianco = YES;
            tk = [self readToken];
        }
        else if ([regexPatternMossa numberOfMatchesInString:tk options:0 range:NSMakeRange(0, [tk length])] > 0) {
            move = [[PGNMove alloc] initWithFullMove:tk];
            if (numParentesiTondeAperte>0) {
                [move setInVariante:YES];
                [move setLivelloVariante:(int)numParentesiTondeAperte];
            }
            [move setPlyCount:(int)plycount];
            if (mossaDelBianco) {
                colore = @"w";
                [move setColor:colore];
                mossaDelBianco = NO;
                plycount++;
            }
            else {
                colore = @"b";
                [move setColor:colore];
            }
            if (textBeforeMove) {
                [move setTextBefore:textBeforeMove];
                textBeforeMove = nil;
            }
            if (textAfterMove) {
                [move setTextAfter:textAfterMove];
                textAfterMove = nil;
            }
            
            if (move.plyCount == 1) {
                if ([radice textAfter]) {
                    [move setTextBefore:[radice textAfter]];
                    [radice setTextAfter:nil];
                }
            }
            
            
            [parsedGameArray addObject:[NSString stringWithFormat:@"%@", [move getMossaDaStampare]]];
            if (prevMove) {
                [prevMove addNextMove:move];
                [move addPrevMove:prevMove];
                prevMove = move;
            }
            else {
                prevMove = move;
                if (!firstMove) {
                    firstMove = move;
                }
                
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"$"]) {
            [prevMove setNag:tk];
            //[parsedGameArray addObject:[NSString stringWithFormat:@"%@", [PGNUtil nagToString:tk]]];
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"("]) {
            numParentesiTondeAperte++;
            //NSLog(@"Devo gestire la parentesi tonda aperta %d", numParentesiTondeAperte);
            [stackMoves addObject:prevMove];
            [stackPlyCount addObject:[NSNumber numberWithUnsignedInteger:plycount]];
            [stackColor addObject:colore];
            if ([colore hasPrefix:@"w"]) {
                plycount--;
                plycount--;
            }
            [parsedGameArray addObject:[prevMove getMossaDaStampareDopoAperturaParentesi]];
            prevMove = [prevMove getPrevMove];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@")"]) {
            numParentesiTondeAperte--;
            //NSLog(@"Devo gestire la parentesi tonda chiusa %d", numParentesiTondeAperte);
            prevMove = [stackMoves lastObject];
            [stackMoves removeLastObject];
            plycount = [[stackPlyCount lastObject] unsignedIntegerValue];
            [stackPlyCount removeLastObject];
            colore = [stackColor lastObject];
            [stackColor removeLastObject];
            tk = [self readToken];
            [parsedGameArray addObject:@"] "];
        }
        else if ([risultato containsObject:tk]) {
            [parsedGameArray addObject:tk];
            move = [[PGNMove alloc] initWithFullMove:tk];
            
            if (textBeforeMove) {
                //[move setTextBefore:textBeforeMove];
                textBeforeMove = nil;
            }
            
            //*******
            if ([colore hasPrefix:@"b"]) {
                plycount++;
            }
            [move setPlyCount:(int)plycount];
            //*******
            [prevMove addNextMove:move];
            [move addPrevMove:prevMove];
            
            if (plycount == 0) {
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            
            tk = [self readToken];
            
        }
        else {
            tk = [self readToken];
        }
    }
    
    /*
     NSLog(@"INIZIO STAMPA DATI PRODOTTA DA ANALYSE GAME DOPO Parse List Moves con Graffa");
     for (NSString *tk in parsedGameArray) {
     NSLog(@"TOKEN = %@", tk);
     }
     NSLog(@"FINE   STAMPA DATI PRODOTTA DA ANALYSE GAME DOPO Parse List Moves con Graffa");
    */
}


/*
- (void) parsePositionToListMoves2 {
    NSMutableArray *stackMoves = [[NSMutableArray alloc] init];
    NSMutableArray *stackPlyCount = [[NSMutableArray alloc] init];
    NSMutableArray *stackColor = [[NSMutableArray alloc] init];
    
    parsedGameArray = [[NSMutableArray alloc] init];
    NSString *colore;
    
    NSUInteger plycount = 0;
    BOOL mossaDelBianco;
    NSUInteger numParentesiTondeAperte = 0;
    NSString *tk = [self readToken];
    tk = [self readToken];
    if (![tk hasSuffix:@"."]) {
        plycount++;
        plycount++;
        mossaDelBianco = NO;
        move = [[PGNMove alloc] initWithFullMove:tk];
        [move setPlyCount:plycount];
        colore = @"b";
        [move setColor:colore];
        [parsedGameArray addObject:[NSString stringWithFormat:@"%@", [move getPrimaMossaNeroDaStampare]]];
        if (prevMove) {
            [prevMove addNextMove:move];
            [move addPrevMove:prevMove];
            prevMove = move;
        }
        else {
            prevMove = move;
            if (!firstMove) {
                firstMove = move;
            }
            
            [radice addNextMove:move];
            [move addPrevMove:radice];
        }
        tk = [self readToken];
    }
    
    while (tk) {
        if ([tk hasSuffix:@"."]) {
            plycount++;
            mossaDelBianco = YES;
            tk = [self readToken];
        }
        else if (([regexPatternMossa numberOfMatchesInString:tk options:0 range:NSMakeRange(0, [tk length])] > 0)) {
            move = [[PGNMove alloc] initWithFullMove:tk];
            if (numParentesiTondeAperte>0) {
                [move setInVariante:YES];
                [move setLivelloVariante:numParentesiTondeAperte];
            }
            [move setPlyCount:plycount];
            if (mossaDelBianco) {
                colore = @"w";
                [move setColor:colore];
                mossaDelBianco = NO;
                plycount++;
            }
            else {
                colore = @"b";
                [move setColor:colore];
            }
            [parsedGameArray addObject:[NSString stringWithFormat:@"%@", [move getMossaDaStampare]]];
            if (prevMove) {
                [prevMove addNextMove:move];
                [move addPrevMove:prevMove];
                prevMove = move;
            }
            else {
                prevMove = move;
                if (!firstMove) {
                    firstMove = move;
                }
                
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"$"]) {
            [prevMove setNag:tk];
            //[parsedGameArray addObject:[NSString stringWithFormat:@"%@", [PGNUtil nagToString:tk]]];
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"("]) {
            numParentesiTondeAperte++;
            NSLog(@"Devo gestire la parentesi tonda aperta %d", numParentesiTondeAperte);
            [stackMoves addObject:prevMove];
            [stackPlyCount addObject:[NSNumber numberWithUnsignedInteger:plycount]];
            [stackColor addObject:colore];
            if ([colore hasPrefix:@"w"]) {
                plycount--;
                plycount--;
            }
            [parsedGameArray addObject:[prevMove getMossaDaStampareDopoAperturaParentesi]];
            prevMove = [prevMove getPrevMove];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@")"]) {
            numParentesiTondeAperte--;
            NSLog(@"Devo gestire la parentesi tonda chiusa %d", numParentesiTondeAperte);
            prevMove = [stackMoves lastObject];
            [stackMoves removeLastObject];
            plycount = [[stackPlyCount lastObject] unsignedIntegerValue];
            [stackPlyCount removeLastObject];
            colore = [stackColor lastObject];
            [stackColor removeLastObject];
            tk = [self readToken];
            [parsedGameArray addObject:@"] "];
        }
        else if ([risultato containsObject:tk]) {
            [parsedGameArray addObject:tk];
            move = [[PGNMove alloc] initWithFullMove:tk];
 
            //if ([colore hasPrefix:@"b"]) {
            //    plycount++;
            //}
            //[move setPlyCount:plycount];
 
            [prevMove addNextMove:move];
            [move addPrevMove:prevMove];
            tk = [self readToken];
            
        }
        else {
            tk = [self readToken];
        }
    }
}
*/


 
- (void) parsePositionToListMoves {
    NSUInteger plycount = 0;
    BOOL mossaDelBianco;
    NSUInteger numParentesiTondeAperte = 0;
    
    NSString *tk = [self readToken];
    
    //PGNMove *tempMove;
    
    NSMutableArray *stackMoves = [[NSMutableArray alloc] init];
    NSMutableArray *stackPlyCount = [[NSMutableArray alloc] init];
    NSMutableArray *stackColor = [[NSMutableArray alloc] init];
    
    parsedGameArray = [[NSMutableArray alloc] init];
    NSString *colore;

    while (tk) {
        if ([tk hasSuffix:@"."]) {
            plycount++;
            mossaDelBianco = YES;
            tk = [self readToken];
        }
        else if (([regexPatternMossa numberOfMatchesInString:tk options:0 range:NSMakeRange(0, [tk length])] > 0) || ([tk hasSuffix:@"XXX"])) {
            move = [[PGNMove alloc] initWithFullMove:tk];
            if (numParentesiTondeAperte>0) {
                [move setInVariante:YES];
                [move setLivelloVariante:(int)numParentesiTondeAperte];
            }
            [move setPlyCount:(int)plycount];
            if (mossaDelBianco) {
                colore = @"w";
                [move setColor:colore];
                mossaDelBianco = NO;
                plycount++;
            }
            else {
                colore = @"b";
                [move setColor:colore];
            }
            [parsedGameArray addObject:[NSString stringWithFormat:@"%@", [move getMossaDaStampare]]];
            if (prevMove) {
                [prevMove addNextMove:move];
                [move addPrevMove:prevMove];
                prevMove = move;
            }
            else {
                prevMove = move;
                if (!firstMove) {
                    firstMove = move;
                }
                
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"$"]) {
            [prevMove setNag:tk];
            //[parsedGameArray addObject:[NSString stringWithFormat:@"%@", [PGNUtil nagToString:tk]]];
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"("]) {
            numParentesiTondeAperte++;
            //NSLog(@"Devo gestire la parentesi tonda aperta %d", numParentesiTondeAperte);
            [stackMoves addObject:prevMove];
            [stackPlyCount addObject:[NSNumber numberWithUnsignedInteger:plycount]];
            [stackColor addObject:colore];
            if ([colore hasPrefix:@"w"]) {
                plycount--;
                plycount--;
            }
            [parsedGameArray addObject:[prevMove getMossaDaStampareDopoAperturaParentesi]];
            prevMove = [prevMove getPrevMove];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@")"]) {
            numParentesiTondeAperte--;
            //NSLog(@"Devo gestire la parentesi tonda chiusa %d", numParentesiTondeAperte);
            prevMove = [stackMoves lastObject];
            [stackMoves removeLastObject];
            plycount = [[stackPlyCount lastObject] unsignedIntegerValue];
            [stackPlyCount removeLastObject];
            colore = [stackColor lastObject];
            [stackColor removeLastObject];
            tk = [self readToken];
            [parsedGameArray addObject:@"] "];
        }
        else if ([risultato containsObject:tk]) {
            [parsedGameArray addObject:tk];
            move = [[PGNMove alloc] initWithFullMove:tk];
            //*******
            if ([colore hasPrefix:@"b"]) {
                plycount++;
            }
            [move setPlyCount:(int)plycount];
            //*******
            [prevMove addNextMove:move];
            [move addPrevMove:prevMove];
            
            if (plycount == 0) {
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            tk = [self readToken];
        }
        else {
            tk = [self readToken];
        }
    }
}

- (void) parsePositionToListMovesWithGraffaOld {
    NSUInteger plycount = 0;
    BOOL mossaDelBianco;
    NSUInteger numParentesiTondeAperte = 0;
    
    NSString *tk = [self readToken];
    
    //PGNMove *tempMove;
    
    NSMutableArray *stackMoves = [[NSMutableArray alloc] init];
    NSMutableArray *stackPlyCount = [[NSMutableArray alloc] init];
    NSMutableArray *stackColor = [[NSMutableArray alloc] init];
    
    parsedGameArray = [[NSMutableArray alloc] init];
    NSString *colore;
    
    NSString *textBeforeMove;
    NSString *textAfterMove;
    
    while (tk) {
        if ([tk hasPrefix:@"{"]) {
            textAfterMove = tk;
            if (move) {
                //[move setTextBefore:textBeforeMove];
                //textBeforeMove = nil;
                [move setTextAfter:textAfterMove];
                textAfterMove = nil;
            }
            else {
                [radice setTextAfter:textAfterMove];
                //textBeforeMove = textAfterMove;
                textAfterMove = nil;
            }
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasSuffix:@"."]) {
            plycount++;
            mossaDelBianco = YES;
            tk = [self readToken];
        }
        else if (([regexPatternMossa numberOfMatchesInString:tk options:0 range:NSMakeRange(0, [tk length])] > 0) || ([tk hasSuffix:@"XXX"])) {
            move = [[PGNMove alloc] initWithFullMove:tk];
            if (numParentesiTondeAperte>0) {
                [move setInVariante:YES];
                [move setLivelloVariante:(int)numParentesiTondeAperte];
            }
            [move setPlyCount:(int)plycount];
            if (mossaDelBianco) {
                colore = @"w";
                [move setColor:colore];
                mossaDelBianco = NO;
                plycount++;
            }
            else {
                colore = @"b";
                [move setColor:colore];
            }
            if (textBeforeMove) {
                [move setTextBefore:textBeforeMove];
                textBeforeMove = nil;
            }
            if (textAfterMove) {
                [move setTextAfter:textAfterMove];
                textAfterMove = nil;
            }
            [parsedGameArray addObject:[NSString stringWithFormat:@"%@", [move getMossaDaStampare]]];
            if (prevMove) {
                [prevMove addNextMove:move];
                [move addPrevMove:prevMove];
                prevMove = move;
            }
            else {
                prevMove = move;
                if (!firstMove) {
                    firstMove = move;
                }
                
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"$"]) {
            [prevMove setNag:tk];
            //[parsedGameArray addObject:[NSString stringWithFormat:@"%@", [PGNUtil nagToString:tk]]];
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"("]) {
            numParentesiTondeAperte++;
            //NSLog(@"Devo gestire la parentesi tonda aperta %d", numParentesiTondeAperte);
            [stackMoves addObject:prevMove];
            [stackPlyCount addObject:[NSNumber numberWithUnsignedInteger:plycount]];
            [stackColor addObject:colore];
            if ([colore hasPrefix:@"w"]) {
                plycount--;
                plycount--;
            }
            [parsedGameArray addObject:[prevMove getMossaDaStampareDopoAperturaParentesi]];
            prevMove = [prevMove getPrevMove];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@")"]) {
            numParentesiTondeAperte--;
            //NSLog(@"Devo gestire la parentesi tonda chiusa %d", numParentesiTondeAperte);
            prevMove = [stackMoves lastObject];
            [stackMoves removeLastObject];
            plycount = [[stackPlyCount lastObject] unsignedIntegerValue];
            [stackPlyCount removeLastObject];
            colore = [stackColor lastObject];
            [stackColor removeLastObject];
            tk = [self readToken];
            [parsedGameArray addObject:@"] "];
        }
        else if ([risultato containsObject:tk]) {
            [parsedGameArray addObject:tk];
            
            if (!move && textBeforeMove) {
                [radice setTextAfter:textBeforeMove];
                textBeforeMove = nil;
            }
            
            
            
            move = [[PGNMove alloc] initWithFullMove:tk];
            
            if (textBeforeMove) {
                //[move setTextBefore:textBeforeMove];
                textBeforeMove = nil;
            }
            
            //*******
            if ([colore hasPrefix:@"b"]) {
                plycount++;
            }
            [move setPlyCount:(int)plycount];
            //*******
            [prevMove addNextMove:move];
            [move addPrevMove:prevMove];
            
            if (plycount == 0) {
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            tk = [self readToken];
        }
        else {
            tk = [self readToken];
        }
    }

}

- (void) parsePositionToListMovesWithGraffaWithStartNumberGreaterOne {
    NSUInteger plycount = [_fenParser getNumeroSemiMossa];
    plycount--;
    
    
    BOOL mossaDelBianco;
    NSUInteger numParentesiTondeAperte = 0;
    
    NSString *tk = [self readToken];
    
    NSMutableArray *stackMoves = [[NSMutableArray alloc] init];
    NSMutableArray *stackPlyCount = [[NSMutableArray alloc] init];
    NSMutableArray *stackColor = [[NSMutableArray alloc] init];
    
    parsedGameArray = [[NSMutableArray alloc] init];
    NSString *colore;
    
    NSString *textBeforeMove;
    NSString *textAfterMove;
    
    while (tk) {
        if ([tk hasPrefix:@"{"]) {
            textAfterMove = tk;
            if (move) {
                //[move setTextBefore:textBeforeMove];
                //textBeforeMove = nil;
                
                if (textBeforeMove) {
                    [move setTextBefore:textBeforeMove];
                    textBeforeMove = nil;
                }
                
                if (![move textAfter]) {
                    [move setTextAfter:textAfterMove];
                    textAfterMove = nil;
                }
                else {
                    textBeforeMove = textAfterMove;
                    textAfterMove = nil;
                }
            }
            else {
                [radice setTextAfter:textAfterMove];
                //textBeforeMove = textAfterMove;
                textAfterMove = nil;
            }
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasSuffix:@"."]) {
            plycount++;
            mossaDelBianco = YES;
            tk = [self readToken];
        }
        else if (([regexPatternMossa numberOfMatchesInString:tk options:0 range:NSMakeRange(0, [tk length])] > 0) || ([tk hasSuffix:@"XXX"])) {
            move = [[PGNMove alloc] initWithFullMove:tk];
            if (numParentesiTondeAperte>0) {
                [move setInVariante:YES];
                [move setLivelloVariante:(int)numParentesiTondeAperte];
            }
            [move setPlyCount:(int)plycount];
            if (mossaDelBianco) {
                colore = @"w";
                [move setColor:colore];
                mossaDelBianco = NO;
                plycount++;
            }
            else {
                colore = @"b";
                [move setColor:colore];
            }
            if (textBeforeMove) {
                [move setTextBefore:textBeforeMove];
                textBeforeMove = nil;
            }
            if (textAfterMove) {
                [move setTextAfter:textAfterMove];
                textAfterMove = nil;
            }
            
            if (move.plyCount == 1) {
                if ([radice textAfter]) {
                    [move setTextBefore:[radice textAfter]];
                    [radice setTextAfter:nil];
                }
            }
            
            [parsedGameArray addObject:[NSString stringWithFormat:@"%@", [move getMossaDaStampare]]];
            
            if (prevMove) {
                [prevMove addNextMove:move];
                [move addPrevMove:prevMove];
                prevMove = move;
            }
            else {
                prevMove = move;
                if (!firstMove) {
                    firstMove = move;
                }
                
                [radice addNextMove:move];
                [move addPrevMove:radice];
                
            }
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"$"]) {
            [prevMove setNag:tk];
            //[parsedGameArray addObject:[NSString stringWithFormat:@"%@", [PGNUtil nagToString:tk]]];
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"("]) {
            numParentesiTondeAperte++;
            //NSLog(@"Devo gestire la parentesi tonda aperta %d", numParentesiTondeAperte);
            [stackMoves addObject:prevMove];
            [stackPlyCount addObject:[NSNumber numberWithUnsignedInteger:plycount]];
            [stackColor addObject:colore];
            if ([colore hasPrefix:@"w"]) {
                plycount--;
                plycount--;
            }
            [parsedGameArray addObject:[prevMove getMossaDaStampareDopoAperturaParentesi]];
            prevMove = [prevMove getPrevMove];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@")"]) {
            numParentesiTondeAperte--;
            //NSLog(@"Devo gestire la parentesi tonda chiusa %d", numParentesiTondeAperte);
            prevMove = [stackMoves lastObject];
            [stackMoves removeLastObject];
            plycount = [[stackPlyCount lastObject] unsignedIntegerValue];
            [stackPlyCount removeLastObject];
            colore = [stackColor lastObject];
            [stackColor removeLastObject];
            tk = [self readToken];
            [parsedGameArray addObject:@"] "];
        }
        else if ([risultato containsObject:tk]) {
            [parsedGameArray addObject:tk];
            
            //if (!move && textBeforeMove) {
            //    [radice setTextAfter:textBeforeMove];
            //    textBeforeMove = nil;
            //}
            
            
            
            move = [[PGNMove alloc] initWithFullMove:tk];
            
            if (textBeforeMove) {
                //[move setTextBefore:textBeforeMove];
                textBeforeMove = nil;
            }
            
            //*******
            if ([colore hasPrefix:@"b"]) {
                plycount++;
            }
            [move setPlyCount:(int)plycount];
            //*******
            
            //NSLog(@"COLORE = %@    PLYCOUNT = %lu", colore, (unsigned long)plycount);
            
            
            [prevMove addNextMove:move];
            [move addPrevMove:prevMove];
            if ((plycount == 0) || ((plycount > 0) && (!colore))) {
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }

            tk = [self readToken];
        }
        else {
            tk = [self readToken];
        }
    }

    [radice setFen:[_fenParser getFen]];
    //NSLog(@"PlyCount Root = %lu  con FEN = %@", (unsigned long)[radice plyCount], [_fenParser getFen]);
    
}

- (void) parsePositionToListMovesWithGraffa {
    
    [self parsePositionToListMovesWithGraffaWithStartNumberGreaterOne];
    return;
    
    
    NSUInteger plycount = 0;
    BOOL mossaDelBianco;
    NSUInteger numParentesiTondeAperte = 0;
    
    NSString *tk = [self readToken];
    
    //PGNMove *tempMove;
    
    NSMutableArray *stackMoves = [[NSMutableArray alloc] init];
    NSMutableArray *stackPlyCount = [[NSMutableArray alloc] init];
    NSMutableArray *stackColor = [[NSMutableArray alloc] init];
    
    parsedGameArray = [[NSMutableArray alloc] init];
    NSString *colore;
    
    NSString *textBeforeMove;
    NSString *textAfterMove;
    
    while (tk) {
        if ([tk hasPrefix:@"{"]) {
            textAfterMove = tk;
            if (move) {
                //[move setTextBefore:textBeforeMove];
                //textBeforeMove = nil;
                
                if (textBeforeMove) {
                    [move setTextBefore:textBeforeMove];
                    textBeforeMove = nil;
                }
                
                if (![move textAfter]) {
                    [move setTextAfter:textAfterMove];
                    textAfterMove = nil;
                }
                else {
                    textBeforeMove = textAfterMove;
                    textAfterMove = nil;
                }
            }
            else {
                [radice setTextAfter:textAfterMove];
                //textBeforeMove = textAfterMove;
                textAfterMove = nil;
            }
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasSuffix:@"."]) {
            plycount++;
            mossaDelBianco = YES;
            tk = [self readToken];
        }
        else if (([regexPatternMossa numberOfMatchesInString:tk options:0 range:NSMakeRange(0, [tk length])] > 0) || ([tk hasSuffix:@"XXX"])) {
            move = [[PGNMove alloc] initWithFullMove:tk];
            if (numParentesiTondeAperte>0) {
                [move setInVariante:YES];
                [move setLivelloVariante:numParentesiTondeAperte];
            }
            [move setPlyCount:plycount];
            if (mossaDelBianco) {
                colore = @"w";
                [move setColor:colore];
                mossaDelBianco = NO;
                plycount++;
            }
            else {
                colore = @"b";
                [move setColor:colore];
            }
            if (textBeforeMove) {
                [move setTextBefore:textBeforeMove];
                textBeforeMove = nil;
            }
            if (textAfterMove) {
                [move setTextAfter:textAfterMove];
                textAfterMove = nil;
            }
            
            if (move.plyCount == 1) {
                if ([radice textAfter]) {
                    [move setTextBefore:[radice textAfter]];
                    [radice setTextAfter:nil];
                }
            }
            
            
            [parsedGameArray addObject:[NSString stringWithFormat:@"%@", [move getMossaDaStampare]]];
            if (prevMove) {
                [prevMove addNextMove:move];
                [move addPrevMove:prevMove];
                prevMove = move;
            }
            else {
                prevMove = move;
                if (!firstMove) {
                    firstMove = move;
                }
                
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"$"]) {
            [prevMove setNag:tk];
            //[parsedGameArray addObject:[NSString stringWithFormat:@"%@", [PGNUtil nagToString:tk]]];
            [parsedGameArray addObject:tk];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@"("]) {
            numParentesiTondeAperte++;
            //NSLog(@"Devo gestire la parentesi tonda aperta %d", numParentesiTondeAperte);
            [stackMoves addObject:prevMove];
            [stackPlyCount addObject:[NSNumber numberWithUnsignedInteger:plycount]];
            [stackColor addObject:colore];
            if ([colore hasPrefix:@"w"]) {
                plycount--;
                plycount--;
            }
            [parsedGameArray addObject:[prevMove getMossaDaStampareDopoAperturaParentesi]];
            prevMove = [prevMove getPrevMove];
            tk = [self readToken];
        }
        else if ([tk hasPrefix:@")"]) {
            numParentesiTondeAperte--;
            //NSLog(@"Devo gestire la parentesi tonda chiusa %d", numParentesiTondeAperte);
            prevMove = [stackMoves lastObject];
            [stackMoves removeLastObject];
            plycount = [[stackPlyCount lastObject] unsignedIntegerValue];
            [stackPlyCount removeLastObject];
            colore = [stackColor lastObject];
            [stackColor removeLastObject];
            tk = [self readToken];
            [parsedGameArray addObject:@"] "];
        }
        else if ([risultato containsObject:tk]) {
            [parsedGameArray addObject:tk];
            
            //if (!move && textBeforeMove) {
            //    [radice setTextAfter:textBeforeMove];
            //    textBeforeMove = nil;
            //}
            
            
            
            move = [[PGNMove alloc] initWithFullMove:tk];
            
            if (textBeforeMove) {
                //[move setTextBefore:textBeforeMove];
                textBeforeMove = nil;
            }
            
            //*******
            if ([colore hasPrefix:@"b"]) {
                plycount++;
            }
            [move setPlyCount:plycount];
            //*******
            [prevMove addNextMove:move];
            [move addPrevMove:prevMove];
            
            if (plycount == 0) {
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
            tk = [self readToken];
        }
        else {
            tk = [self readToken];
        }
    }
    
}


- (void) parsePositionWithoutMovesToListMoves {
    NSUInteger plycount = 0;
    BOOL mossaDelBianco;
    NSString *colore;
    parsedGameArray = [[NSMutableArray alloc] init];
    
    NSString *tk = [self readToken];
    
    while (tk) {
        //NSLog(@"NUOVO TOKEN %@", tk);
        if ([tk hasSuffix:@"."]) {
            NSString *nm = [tk substringToIndex:[tk rangeOfString:@"."].location];
            //NSLog(@"Il numero mossa da considerare è = %@", nm);
            //plycount = [nm integerValue]*2; Questa istruzione terrebbe conto del fatto che in una posizione si può partire anche da una mossa n
            plycount = [nm integerValue];
            mossaDelBianco = YES;
        }
        else if ([tk hasSuffix:@"XXX"]) {
            move = [[PGNMove alloc] initWithFullMove:tk];
            [move setPlyCount:(int)plycount];
            if (mossaDelBianco) {
                colore = @"w";
                [move setColor:colore];
                mossaDelBianco = NO;
            }
            else {
                colore = @"b";
                [move setColor:colore];
            }
            
            NSString *mds = [move getMossaDaStampare];
            //NSLog(@"MOSSA DA STAMPARE = %@", mds);
            [parsedGameArray addObject:[NSString stringWithFormat:@"%@", mds]];
            
            if (prevMove) {
                [prevMove addNextMove:move];
                [move addPrevMove:prevMove];
                prevMove = move;
            }
            else {
                prevMove = move;
                if (!firstMove) {
                    firstMove = move;
                }
                
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
        }
        else if ([risultato containsObject:tk]) {
            //NSLog(@"Il token letto è un risultato");
            move = [[PGNMove alloc] initWithFullMove:tk];
            [parsedGameArray addObject:tk];
            if ([colore hasPrefix:@"b"]) {
                plycount++;
            }
            [move setPlyCount:(int)plycount];
            
            if (prevMove) {
                [prevMove addNextMove:move];
                [move addPrevMove:prevMove];
            }
            else {
                [radice addNextMove:move];
                [move addPrevMove:radice];
            }
        }
        tk = [self readToken];
    }
    /*
    NSLog(@"INIZIO STAMPA PARSED GAME ARRAY");
    for (NSString *t in parsedGameArray) {
        NSLog(@"%@", t);
    }
    NSLog(@"FINE STAMPA PARSED GAME ARRAY");
    */
}


- (void) visitaAlberoToGetMainLine {
    //NSLog(@"INIZIO VISITA ALBERO IN ORDINE ANTICIPATO TO GET MAIN LINE");
    [radice visitaAlberoToGetMainLine];
    //NSLog(@"FINE   VISITA ALBERO IN ORDINE ANTICIPATO TO GET MAIN LINE");
}

- (void) visitaAlberoAnticipato {
    //NSLog(@"INIZIO VISITA ALBERO IN ORDINE ANTICIPATO");
    [radice visitaAlberoAnticipato];
    //NSLog(@"FINE   VISITA ALBERO IN ORDINE ANTICIPATO");
}

- (void) visitaAlberoDifferito {
    //NSLog(@"INIZIO VISITA ALBERO IN ORDINE DIFFERITO");
    [radice visitaAlberoDifferito];
    //NSLog(@"FINE   VISITA ALBERO IN ORDINE DIFFERITO");
}

- (void) visitaAlberoAnticipato2 {
    //NSLog(@"INIZIO VISITA ALBERO IN ORDINE ANTICIPATO2");
    [radice visitaAlberoAnticipato2];
    //NSLog(@"FINE   VISITA ALBERO IN ORDINE ANTICIPATO2");
    //NSLog(@"%@", [radice getGameDopoAlberoAnticipato2]);
}

- (NSArray *) visitaAlberoAnticipato2AndGetGameArray {
    //NSLog(@"INIZIO VISITA ALBERO IN ORDINE ANTICIPATO2 CON GET GAME ARRAY");
    [radice visitaAlberoAnticipato2];
    //NSLog(@"FINE   VISITA ALBERO IN ORDINE ANTICIPATO2 CON GET GAME ARRAY");
    //NSLog(@"%@", [radice getGameDopoAlberoAnticipato2]);
    return [radice getGameArrayDopoAlberoAnticipato2];
}





- (void) printParsedGame {
    NSMutableString *parsedGameString = [[NSMutableString alloc] init];
    for (NSString *m in parsedGameArray) {
        if ([m hasPrefix:@"$"]) {
            NSString *s =[parsedGameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            parsedGameString = [[NSMutableString alloc] initWithFormat:@"%@", s];
            [parsedGameString appendString:[PGNUtil nagToSymbol:m]];
            //[parsedGameString appendString:m];
            [parsedGameString appendString:@" "];
        }
        else {
            [parsedGameString appendString:m];
            [parsedGameString appendString:@" "];
        }
    }
    //NSString *finalParsedGameString = [parsedGameString stringByReplacingOccurrencesOfString:@" $" withString:@"$"];
    NSString *finalParsedGameString = [parsedGameString stringByReplacingOccurrencesOfString:@"[ " withString:@"["];
    finalParsedGameString = [finalParsedGameString stringByReplacingOccurrencesOfString:@" ]" withString:@"]"];
    finalParsedGameString = [finalParsedGameString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    NSLog(@"%@", finalParsedGameString);
}

- (NSString *) getParsedGame {
    NSMutableString *parsedGameString = [[NSMutableString alloc] init];
    for (NSString *m in parsedGameArray) {
        if ([m hasPrefix:@"$"]) {
            NSString *s =[parsedGameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            parsedGameString = [[NSMutableString alloc] initWithFormat:@"%@", s];
            [parsedGameString appendString:[PGNUtil nagToSymbol:m]];
            //[parsedGameString appendString:m];
            [parsedGameString appendString:@" "];
        }
        else {
            [parsedGameString appendString:m];
            [parsedGameString appendString:@" "];
        }
    }
    //NSString *finalParsedGameString = [parsedGameString stringByReplacingOccurrencesOfString:@" $" withString:@"$"];
    NSString *finalParsedGameString = [parsedGameString stringByReplacingOccurrencesOfString:@"[ " withString:@"["];
    finalParsedGameString = [finalParsedGameString stringByReplacingOccurrencesOfString:@" ]" withString:@"]"];
    finalParsedGameString = [finalParsedGameString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    NSLog(@"%@", finalParsedGameString);
    return finalParsedGameString;
}

- (NSString *) getParsedGameWithNoComments {
    NSMutableString *parsedGameString = [[NSMutableString alloc] init];
    for (NSString *m in parsedGameArray) {
        if (![m hasPrefix:@"$"]) {
            [parsedGameString appendString:m];
            [parsedGameString appendString:@" "];
        }
    }
    NSString *finalParsedGameString = [parsedGameString stringByReplacingOccurrencesOfString:@"[ " withString:@"["];
    finalParsedGameString = [finalParsedGameString stringByReplacingOccurrencesOfString:@" ]" withString:@"]"];
    finalParsedGameString = [finalParsedGameString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    NSLog(@"%@", finalParsedGameString);
    return finalParsedGameString;
}

- (NSString *) getParsedGameWithChessSymbolsAndNoComments {
    NSString *parsedGame = [self getParsedGameWithNoComments];
    parsedGame = [self getParsedGameWithChessSymbols:parsedGame];
    return parsedGame;
}

- (NSString *) getParsedGameWithNoVariationsAndNoComments {
    NSMutableString *parsedGameString = [[NSMutableString alloc] init];
    NSUInteger *numParentesiAperte = 0;
    for (NSString *m in parsedGameArray) {
        if (![m hasPrefix:@"$"]) {
            if ([m hasPrefix:@"["]) {
                numParentesiAperte++;
            }
            else if ([m hasPrefix:@"]"]) {
                numParentesiAperte--;
            }
            else if (numParentesiAperte == 0) {
                [parsedGameString appendString:m];
                //[parsedGameString appendString:@" "];
            }
        }
    }
    NSString *result = [self getParsedGameWithChessSymbols:parsedGameString];
    return result;
}

- (NSArray *) getParsedGameArray {
    NSMutableArray *newParsedGameArray = [[NSMutableArray alloc] init];
    NSString *tempTk = nil;
    for (NSString *tk in parsedGameArray) {
        if ([tk hasPrefix:@"["] || [tk hasPrefix:@"]"] || [risultato containsObject:tk]) {
            if (tempTk) {
                [newParsedGameArray addObject:tempTk];
                tempTk = nil;
            }
            [newParsedGameArray addObject:tk];
        }
        else if (![tk hasPrefix:@"$"]) {
            if (tempTk) {
                [newParsedGameArray addObject:tempTk];
            }
            tempTk = tk;
        }
        else if ([tk hasPrefix:@"$"]) {
            if (tempTk) {
                tempTk = [tempTk stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                tempTk = [tempTk stringByAppendingString:[PGNUtil nagToSymbol:tk]];
            }
        }
    }
    //return parsedGameArray;
    //for (NSString *t in newParsedGameArray) {
        //NSLog(@"%@", t);
    //}
    return newParsedGameArray;
}

- (PGNMove *) getFirstMove {
    return firstMove;
}

- (PGNMove *) getRadice {
    return radice;
}

- (void) printParsedArray {
    //NSLog(@"INIZIO PRINT PARSED ARRAY");
    for (NSString *t in parsedGameArray) {
        NSLog(@"%@", t);
    }
    //NSLog(@"FINE   PRINT PARSED ARRAY");
}

- (NSString *) getParsedGameWithChessSymbols:(NSString *) parsedGame {
    NSString *gameWithSymbols = [parsedGame stringByReplacingOccurrencesOfString:@"N" withString:whiteKnightSymbol];
    gameWithSymbols = [gameWithSymbols stringByReplacingOccurrencesOfString:@"B" withString:whiteBishopSymbol];
    gameWithSymbols = [gameWithSymbols stringByReplacingOccurrencesOfString:@"R" withString:whiteRookSymbol];
    gameWithSymbols = [gameWithSymbols stringByReplacingOccurrencesOfString:@"Q" withString:whiteQueenSymbol];
    gameWithSymbols = [gameWithSymbols stringByReplacingOccurrencesOfString:@"K" withString:whiteKingSymbol];
    return gameWithSymbols;
}

@end
