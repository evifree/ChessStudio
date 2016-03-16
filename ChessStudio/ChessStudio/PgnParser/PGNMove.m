//
//  PGNMove.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 11/12/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "PGNMove.h"
#import "PGNUtil.h"
#import "PGNMoveAnnotation.h"


#define lettereScacchiera [NSArray arrayWithObjects: @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", nil]

@interface PGNMove() {
    
    NSMutableArray *nags;
    NSMutableArray *preNags;
    
    NSMutableArray *_nextMoves;
    PGNMove *_prevMove;
    
    
    
    NSString *_preParentesi;
    NSString *_postParentesi;
    
    
    NSMutableCharacterSet *setGraffe;
    
    
    
    PGNMoveAnnotation *pgnMoveAnnotation;
    
}

@end;

@implementation PGNMove

static short numVariantiAperte;
static NSMutableString *game;
static NSMutableString *gameWithNags;
static NSMutableArray *gameArray;
static short numMosse;
static NSMutableString *engineMovesArray;
static BOOL fenTrovatoUguale;


- (id) initWithFullMove:(NSString *)fullMove {
    self = [super init];
    if (self) {
        
        _extendedMove = NO;
        
        if (fullMove != nil) {
            if (![fullMove isEqualToString:@"1-0"] && ![fullMove isEqualToString:@"0-1"] && ![fullMove isEqualToString:@"1/2-1/2"] && ![fullMove isEqualToString:@"*"]) {
                if (![fullMove isEqualToString:@"O-O"] && ![fullMove isEqualToString:@"0-0"] && ![fullMove isEqualToString:@"O-O-O"] && ![fullMove isEqualToString:@"0-0-0"]) {
                    
                    NSString *ss = nil;
                    NSString *es = nil;
                    NSString *p = nil;
                    NSString *presa = nil;
                    
                    if ([fullMove rangeOfString:@"-"].location != NSNotFound) {
                        //NSLog(@"La mossa ha una notazione estesa senza presa:%@", fullMove);
                        NSArray *moveArray = [fullMove componentsSeparatedByString:@"-"];
                        ss = [moveArray objectAtIndex:0];
                        es = [moveArray objectAtIndex:1];
                        
                        presa = nil;
                        
                        if (ss.length == 3) {
                            p = [ss substringToIndex:1];
                            ss = [ss substringFromIndex:1];
                            //fullMove = p;
                            //fullMove = [fullMove stringByAppendingString:es];
                            _extendedMove = YES;
                        }
                        else {
                            p = @"P";
                            //fullMove = es;
                            _extendedMove = YES;
                        }
                        
                        //NSLog(@"%@  %@   -   %@", p, ss, es);
                        
                        //int fromDevSquare = [self getDevelopmentSquareFromAlgebricValue:ss];
                        //int toDevSquare = [self getDevelopmentSquareFromAlgebricValue:es];
                        
                        //[self setFromSquare:fromDevSquare];
                        //[self setToSquare:toDevSquare];
                    }
                    else if ([fullMove rangeOfString:@"x"].location != NSNotFound) {
                        NSArray *moveArray = [fullMove componentsSeparatedByString:@"x"];
                        if ([[moveArray objectAtIndex:0] length]>1) {
                            //NSLog(@"La mossa ha una notazione estesa con presa:%@", fullMove);
                            ss = [moveArray objectAtIndex:0];
                            es = [moveArray objectAtIndex:1];
                            presa = @"x";
                            
                            if (ss.length == 3) {
                                p = [ss substringToIndex:1];
                                ss = [ss substringFromIndex:1];
                                //fullMove = p;
                                //fullMove = [fullMove stringByAppendingString:@"x"];
                                //fullMove = [fullMove stringByAppendingString:es];
                                _extendedMove = YES;
                                _capture = YES;
                            }
                            else {
                                NSString *primoCar = [ss substringToIndex:1];
                                if ([lettereScacchiera containsObject:primoCar]) {
                                    p = @"P";
                                    
                                    //fullMove = [ss substringToIndex:1];
                                    //fullMove = [fullMove stringByAppendingString:@"x"];
                                    //fullMove = [fullMove stringByAppendingString:es];
                                    _extendedMove = YES;
                                    _capture = YES;
                                }
                                else {
                                    presa = nil;
                                    _fullMove = fullMove;
                                    p = nil;
                                    _extendedMove = NO;
                                }
                            }
                            
                            //int fromDevSquare = [self getDevelopmentSquareFromAlgebricValue:ss];
                            //int toDevSquare = [self getDevelopmentSquareFromAlgebricValue:es];
                            
                            //[self setFromSquare:fromDevSquare];
                            //[self setToSquare:toDevSquare];
                            
                            //NSLog(@"%@  %@   -   %@", p, ss, es);
                        }
                    }
                    
                    if (_extendedMove) {
                        int fromDevSquare = [self getDevelopmentSquareFromAlgebricValue:ss];
                        int toDevSquare = [self getDevelopmentSquareFromAlgebricValue:es];
                        
                        [self setFromSquare:fromDevSquare];
                        [self setToSquare:toDevSquare];
                    }
                }
            }
        }
        
        //if (_extendedMove) {
            //NSLog(@"Questa mossa è extended: %@", fullMove);
        //}
        
        //NSLog(@"%@", fullMove);
        
        
        _fullMove = fullMove;
        _enPassantCapture = NO;
        _nag = nil;
        nags = nil;
        [self parse];
        
        numVariantiAperte = 0;
        game = [[NSMutableString alloc] init];
        gameArray = [[NSMutableArray alloc] init];
        gameWithNags = [[NSMutableString alloc] init];
        numMosse = 0;
        engineMovesArray = [[NSMutableString alloc] init];
        [self initNag];
        _inVariante = NO;
        _livelloVariante = 0;
        
        
        setGraffe = [[NSMutableCharacterSet alloc] init];
        [setGraffe addCharactersInString:@"{}"];
        

        
        pgnMoveAnnotation = [[PGNMoveAnnotation alloc] init];
        
        _textBefore = nil;
        _textAfter = nil;
        
        _insertWebDiagram = NO;
        
    }
    return self;
}

#pragma mark - Inizio sezione dedicata alle annotazioni della mossa

- (void) initNag {
    nags = [[NSMutableArray alloc] init];
    [nags addObject:@""];//Posizione zero riservata a MoveAnnotation
    [nags addObject:@""];//Posizione uno dedicata alla Mossa Unica
    [nags addObject:@""];//Posizione due dedicata alla Novità (dovrebbe essere in conflitto con la posizione 1)
}

- (void) setMoveAnnotation:(NSString *)moveAnnotation {
    //NSLog(@"ESEGUO SET MOVE ANNOTATION");
    moveAnnotation = [NSString stringWithFormat:@"$%@", moveAnnotation];
    
    
    //NSUInteger numMoveAnnotation = [moveAnnotation integerValue];
    //if (numMoveAnnotation == 0) {
        //moveAnnotation = @"$0";
    //}
    
    [pgnMoveAnnotation setNag:moveAnnotation];
    
    return;
    
    /*
    if (numMoveAnnotation<7) {
        [nags replaceObjectAtIndex:0 withObject:moveAnnotation];
    }
    else if (numMoveAnnotation == 7) {
        [nags replaceObjectAtIndex:1 withObject:moveAnnotation];
    }
    else if (numMoveAnnotation == 146) {
        [nags replaceObjectAtIndex:2 withObject:moveAnnotation];
    }
    [self stampaNags];
    */
}

- (void) removeMoveAnnotation:(NSString *)moveAnnotation {
    //NSLog(@"ESEGUO REMOVE MOVE ANNOTATION");
    
    moveAnnotation = [NSString stringWithFormat:@"$%@", moveAnnotation];
    [pgnMoveAnnotation removeNag:moveAnnotation];
    
    /*
    NSUInteger numMoveAnnotation = [moveAnnotation integerValue];
    if (numMoveAnnotation<7) {
        [nags replaceObjectAtIndex:0 withObject:@""];
    }
    else if (numMoveAnnotation == 7) {
        [nags replaceObjectAtIndex:1 withObject:@""];
    }
    else if (numMoveAnnotation == 146) {
        [nags replaceObjectAtIndex:2 withObject:@""];
    }
    [self stampaNags];
    */
}

- (void) setPositionAnnotation:(NSString *)positionAnnotation {
    if (![nags containsObject:positionAnnotation]) {
        [nags addObject:positionAnnotation];
    }
}

- (NSString *) getMoveAnnotationAtIndex:(NSUInteger)index {
    if (index > 1) {
        return nil;
    }
    return [nags objectAtIndex:index];
}

- (void) setNag:(NSString *)nag {
    
    
    if ([nag hasSuffix:@"142"] || [nag hasSuffix:@"145"] || [nag hasSuffix:@"140"]) {
        [self setPreNag:nag];
        return;
    }
    
    if (!pgnMoveAnnotation) {
        pgnMoveAnnotation = [[PGNMoveAnnotation alloc] init];
    }
    
    [pgnMoveAnnotation setNag:nag];
    
    return;
    
    if ([nag hasSuffix:@"146"]) {
        [nags replaceObjectAtIndex:2 withObject:nag];
    }
    
    NSUInteger nagNumber = 0;
    
    if ([nag hasPrefix:@"$"]) {
        nagNumber = [[nag substringFromIndex:1] integerValue];
    }
    else {
        nagNumber = [nag integerValue];
    }
    
    if (nagNumber  == 0) {
        [nags replaceObjectAtIndex:0 withObject:@""];
    }
    else if (nagNumber<7 && nagNumber>0) {
        [nags replaceObjectAtIndex:0 withObject:nag];
    }
    else if (nagNumber == 7) {
        [nags replaceObjectAtIndex:1 withObject:nag];
    }
    //[nags addObject:nag];
    
    //NSLog(@"setNag:   %@   numero elementi nags=%d", nag, nags.count);
    [self stampaNags];
}

- (void) removeNag:(NSString *)nag {
    if (nags) {
        if ([nags containsObject:nag]) {
            [nags removeObject:nag];
        }
    }
}

- (BOOL) containsNag:(NSString *)nag {
    
    NSUInteger nNag = [nag integerValue];
    nag = [NSString stringWithFormat:@"$%@", nag];
    
    return [pgnMoveAnnotation containsNag:nag];
    
    //[self stampaNags];

    NSLog(@"containsNag:  %@", nag);
    if (nNag < 7) {
        NSLog(@"Valore Indice 0 = %@", [self getMoveAnnotationAtIndex:0]);
        if (nNag == 0 && [[self getMoveAnnotationAtIndex:0] isEqualToString:@""]) {
            NSLog(@"La condizione 0 e vuoto è soddisfatta");
            return YES;
        }
    }
    if ([nags containsObject:nag]) {
        NSLog(@"nags contiene %@", nag);
        return YES;
    }
    return NO;
}

- (void) setPreNag:(NSString *)nag {
    if (!preNags) {
        preNags = [[NSMutableArray alloc] init];
    }
    [preNags addObject:nag];
}


- (void) stampaNags {
    NSMutableString *s = [[NSMutableString alloc] init];
    for (NSString *c in nags) {
        [s appendString:c];
    }
    //NSLog(@"STAMPA NAGS:%@", s);
}

#pragma mark - Fine sezione dedicata alle annotazioni della mossa


- (void) parse {
    if (!_fullMove) {
        //NSLog(@"FullMove non è definita");
        _plyCount = 0;
        _piece = nil;
        _capture = NO;
        _check = NO;
        _checkMate = NO;
        _captured = nil;
        _kingSideCastle = NO;
        _queenSideCastle = NO;
        _endGameMark = nil;
        _endGameMarked = NO;
        _prevMove = nil;
        _promoted = NO;
        _promotion = nil;
        _enPassant = NO;
        _enPassantCapture = NO;
        _enPassantPieceSquare = 0;
        
        return;
    }
    
    NSString *move = _fullMove;
    //NSLog(@"MOVE = %@", move);
    
    //Il seguento passaggio risolve il problema della promozione in cui non sia presente il segno =
    //Praticamente lo risolve introducendo il segno =
    if ([move hasSuffix:@"Q"] || [move hasSuffix:@"R"] || [move hasSuffix:@"B"] || [move hasSuffix:@"N"]) {
        if ([move rangeOfString:@"="].location == NSNotFound) {
            NSString *last = [move substringFromIndex: [move length] - 1];
            NSString *replacing = [NSString stringWithFormat:@"=%@", last];
            move = [move stringByReplacingOccurrencesOfString:last withString:replacing];
            _fullMove = move;
        }
        //NSLog(@"MOVE = %@", move);
    }
    
    if ([move hasSuffix:@"Q+"] || [move hasSuffix:@"R+"] || [move hasSuffix:@"B+"] || [move hasSuffix:@"N+"]) {
        if ([move rangeOfString:@"="].location == NSNotFound) {
            NSString *last = [move substringFromIndex: [move length] - 2];
            NSString *replacing = [NSString stringWithFormat:@"=%@", last];
            move = [move stringByReplacingOccurrencesOfString:last withString:replacing];
            _fullMove = move;
        }
        //NSLog(@"MOVE = %@", move);
    }
    
    if ([move hasSuffix:@"Q#"] || [move hasSuffix:@"R#"] || [move hasSuffix:@"B#"] || [move hasSuffix:@"N#"]) {
        if ([move rangeOfString:@"="].location == NSNotFound) {
            NSString *last = [move substringFromIndex: [move length] - 2];
            NSString *replacing = [NSString stringWithFormat:@"=%@", last];
            move = [move stringByReplacingOccurrencesOfString:last withString:replacing];
            _fullMove = move;
        }
        //NSLog(@"MOVE = %@", move);
    }
    
    if ([move isEqualToString:@"0-0"] || [move isEqualToString:@"0-0-0"]) {
        move = [move stringByReplacingOccurrencesOfString:@"0" withString:@"O"];
        _fullMove = move;
        //NSLog(@"MOVE = %@", move);
    }
    
    if ([move hasPrefix:@"K"]) {
        _piece = @"k";
    }
    else if ([move hasPrefix:@"Q"]) {
        _piece = @"q";
    }
    else if ([move hasPrefix:@"R"]) {
        _piece = @"r";
    }
    else if ([move hasPrefix:@"B"]) {
        _piece = @"b";
    }
    else if ([move hasPrefix:@"N"]) {
        _piece = @"n";
    }
    else {
        _piece = @"p";
    }
    
    if ([move rangeOfString:@"x"].location == NSNotFound) {
        _capture = NO;
    }
    else {
        _capture = YES;
        move = [move stringByReplacingOccurrencesOfString:@"x" withString:@""];
    }
    
    if ([move rangeOfString:@"+"].location == NSNotFound) {
        _check = NO;
    }
    else {
        _check = YES;
        move = [move stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }
    
    if ([move rangeOfString:@"#"].location == NSNotFound) {
        _checkMate = NO;
    }
    else {
        _checkMate = YES;
        _check = YES;
        move = [move stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    
    if ([move rangeOfString:@"="].location == NSNotFound) {
        _promoted = NO;
    }
    else {
        NSRange range = [move rangeOfString:@"="];
        NSString *pezzoPromosso = [move substringFromIndex:range.location + 1];
        if ([pezzoPromosso isEqualToString:@"Q"] || [pezzoPromosso isEqualToString:@"R"] || [pezzoPromosso isEqualToString:@"B"] || [pezzoPromosso isEqualToString:@"N"]) {
            _promoted = YES;
            _promotion = pezzoPromosso;
            move = [move substringToIndex:range.location];
        }
    }
    
    if ([move isEqualToString:@"O-O"]) {
        _kingSideCastle = YES;
        _queenSideCastle = NO;
        _piece = @"k";
    }
    
    if ([move isEqualToString:@"O-O-O"]) {
        _kingSideCastle = NO;
        _queenSideCastle = YES;
        _piece = @"k";
    }
    
    if ([move isEqualToString:@"1-0"] || [move isEqualToString:@"0-1"] || [move isEqualToString:@"1/2-1/2"] || [move isEqualToString:@"*"]) {
        _endGameMarked = YES;
        _endGameMark = move;
    }
    else {
        _endGameMarked = NO;
        _endGameMark = nil;
    }
    
    _move = move;
    
    
    //NSLog(@"FULL MOVE = %@", _move);
}

- (BOOL) isCastle {
    return _kingSideCastle || _queenSideCastle;
}

- (NSString *) captured {
    if (!_capture) {
        return @"em";
    }
    return _captured;
}


- (NSString *) pezzoPromosso {
    if ([_promotion isEqualToString:@"Q"]) {
        return [_color stringByAppendingString:@"q"];
    } else if ([_promotion isEqualToString:@"R"]) {
        return [_color stringByAppendingString:@"r"];
    }
    else if ([_promotion isEqualToString:@"B"]) {
        return [_color stringByAppendingString: @"b"];
    }
    else if ([_promotion isEqualToString:@"N"]) {
        return [_color stringByAppendingString:@"n"];
    }
    return @"";
}

- (NSString *) getWebMove {
    NSMutableString *webMove = [[NSMutableString alloc] init];
    if (_endGameMarked) {
        return _endGameMark;
    }
    NSUInteger numeroMossa = ceil(_plyCount/2.0);
    if (_plyCount & 1) {
        [webMove appendFormat:@"%ld. ", (long)numeroMossa];
        [webMove appendString:_fullMove];
    }
    else {
        [webMove appendString:_fullMove];
    }
    if (nags) {
        NSMutableString *nagsString = [[NSMutableString alloc] init];
        for (NSString *nag in nags) {
            if ([nagsString length] > 0) {
                [nagsString appendString:@" "];
            }
            [nagsString appendString:nag];
        }
        [webMove appendString:@" "];
        [webMove appendString:nagsString];
    }
    return webMove;
}

- (NSString *) fenForBookMoves {
    NSArray *fenArray;
    if ([self isRootMove] && ![self fen]) {
        fenArray = [FEN_START_POSITION componentsSeparatedByString:@" "];
    }
    else {
        fenArray = [_fen componentsSeparatedByString:@" "];
    }
    NSMutableString *newFen = [[NSMutableString alloc] init];
    for (int i=0; i<3; i++) {
        [newFen appendString:[fenArray objectAtIndex:i]];
        [newFen appendString:@" "];
    }
    [newFen appendString:@"-"];
    return newFen;
}

- (NSString *) log {
    //NSUInteger realnum = ceil(_plyCount/2.0);
    if (_plyCount & 1) {
        //NSLog(@"%d.", realnum);
    }
    else {
        //NSLog(@"%d... ", realnum);
    }
    NSString *plyCountString = [NSString stringWithFormat:@"%ld.", (long)_plyCount];
    NSString *mossa = [[plyCountString stringByAppendingString:@" "] stringByAppendingString:_fullMove];
    if (nags) {
        NSMutableString *nagsString = [[NSMutableString alloc] init];
        for (NSString *nag in nags) {
            if ([nagsString length] > 0) {
                [nagsString appendString:@" "];
            }
            [nagsString appendString:nag];
        }
        return [[mossa stringByAppendingString:@" "] stringByAppendingString:nagsString];
    }
    return mossa;
}


- (NSString *) description {
    
    if (_endGameMarked) {
        return _endGameMark;
    }
    
    NSUInteger numeroMossa = ceil(_plyCount/2.0);
    NSMutableString *descr = [[NSMutableString alloc] init];
    if ([_color isEqualToString:@"w"]) {
        [descr appendFormat:@"%ld. ", (long)numeroMossa];
    }
    else {
        [descr appendFormat:@"%ld... ", (long)numeroMossa];
    }
    [descr appendString:_move];
    [descr appendString:@" "];
    
    if (nags.count > 0) {
        for (NSString *nag in nags) {
            [descr appendFormat:@"%@ ", nag];
        }
    }
    
    [descr appendString:@" "];
    [descr appendString:_color];
    [descr appendString:@"  "];
    if (_capture) {
        [descr appendString:@"Cattura  "];
    }
    if (_check) {
        [descr appendString:@"Scacco  "];
    }
    if (_promoted) {
        [descr appendString:@"Promozione  "];
        [descr appendFormat:@"Pezzo promosso: %@  ", _promotion];
    }
    if (_kingSideCastle) {
        [descr appendString:@"Arrocco Corto  "];
    }
    if (_queenSideCastle) {
        [descr appendString:@"Arrocco lungo"];
    }
    
    /*
    if (_nextMoves.count > 1) {
        PGNMove *m = [_nextMoves objectAtIndex:0];
        [descr appendString:m.startDescription];
        for (int i=1; i<_nextMoves.count; i++) {
            PGNMove *mvar = [_nextMoves objectAtIndex:i];
            [descr appendString:@"["];
            [descr appendString:[mvar description]];
            [descr appendString:@"] "];
        }
        [descr appendString:m.endDescription];
    }
    else if (_nextMoves.count == 1) {
        PGNMove *m = [_nextMoves objectAtIndex:0];
        [descr appendString:m.description];
    }
    */
    
    if (_fen) {
        [descr appendFormat:@" - %@", _fen];
    }
    
    return descr;
}

- (void) addNextMove:(PGNMove *)nextMove {
    if (!_nextMoves) {
        _nextMoves = [[NSMutableArray alloc] init];
    }
    [_nextMoves addObject:nextMove];
}

- (void) addPrevMove:(PGNMove *)prevMove {
    _prevMove = prevMove;
}

- (void) overwriteNextMoves:(PGNMove *)nextMove {
    if (_nextMoves) {
        [_nextMoves removeAllObjects];
        [_nextMoves addObject:nextMove];
    }
}

- (void) promoteNextMoveToMainLine:(PGNMove *)nextMove {
    if (_nextMoves) {
        [_nextMoves insertObject:nextMove atIndex:0];
    }
}

- (void) undoLastMove {
    if (_nextMoves) {
        [_nextMoves removeAllObjects];
    }
}

- (NSArray *) getNextMoves {
    return _nextMoves;
}

- (PGNMove *) getPrevMove {
    return _prevMove;
}

- (BOOL) daQuestaMossaEsisteDiramazione {
    if (_nextMoves) {
        if (_nextMoves.count > 1) {
            return YES;
        }
    }
    return NO;
}


- (NSString *) getMossaDaStampareConNag {
    
    NSUInteger numeroMossa = ceil(_plyCount/2.0);
    NSMutableString *mossaDaStampare = [[NSMutableString alloc] init];
    
    if (preNags) {
        for (NSString *preNag in preNags) {
            [mossaDaStampare appendString:preNag];
            [mossaDaStampare appendString:@" "];
        }
    }
    
    if ([_fullMove isEqualToString:@"XXX"]) {
        if ([_color isEqualToString:@"w"]) {
            [mossaDaStampare appendFormat:@"%ld... ", (long)numeroMossa];
        }
    }
    else {
        
        if ([_color isEqualToString:@"w"]) {
            [mossaDaStampare appendFormat:@"%ld. ", (long)numeroMossa];
        }
        
        if (_fullMove) {
            [mossaDaStampare appendString:_fullMove];
        }
        
        //[mossaDaStampare appendString:_fullMove];
        [mossaDaStampare appendString:@""];
        
    }
    
    [mossaDaStampare appendString:[pgnMoveAnnotation getMoveAnnotation]];
    
    return mossaDaStampare;
    
    if (nags.count > 0) {
        [mossaDaStampare appendString:@" "];
        for (NSString *nag in nags) {
            //NSLog(@"getMossaDaStampareConNag:   %@", nag);
            if (nag.length>0) {
                [mossaDaStampare appendFormat:@"%@ ", nag];
            }
        }
    }
    
    return mossaDaStampare;
}

- (NSString *) getMossaDaStampare {
    
    NSUInteger numeroMossa = ceil(_plyCount/2.0);
    NSMutableString *mossaDaStampare = [[NSMutableString alloc] init];
    
    
    if (preNags) {
        for (NSString *preNag in preNags) {
            [mossaDaStampare appendString:[PGNUtil nagToSymbol:preNag]];
            [mossaDaStampare appendString:@" "];
        }
    }
    
    if ([_fullMove isEqualToString:@"XXX"]) {
        if ([_color isEqualToString:@"w"]) {
            [mossaDaStampare appendFormat:@"%ld... ", (long)numeroMossa];
        }
    }
    else {
    
        if ([_color isEqualToString:@"w"]) {
            [mossaDaStampare appendFormat:@"%ld. ", (long)numeroMossa];
        }
    
        //if (_fullMove) {
            [mossaDaStampare appendString:_fullMove];
        //}
        
        
        //[mossaDaStampare appendString:@""];
    
    }
    
    if (nags.count > 0) {
        for (NSString *nag in nags) {
            //NSLog(@"getMossaDaStampare:   %@", nag);
            [mossaDaStampare appendFormat:@"%@ ", [PGNUtil nagToSymbol:nag]];
        }
    }
    
    return mossaDaStampare;
}

- (NSString *) getMossaDaStampareDopoAperturaParentesi {
    NSUInteger numeroMossa = ceil(_plyCount/2.0);
    NSMutableString *mossaDopoParentesiAperta = [[NSMutableString alloc] init];
    
    if (preNags) {
        for (NSString *preNag in preNags) {
            [mossaDopoParentesiAperta appendString:[PGNUtil nagToSymbol:preNag]];
            [mossaDopoParentesiAperta appendString:@" "];
        }
    }
    
    
    if ([_color isEqualToString:@"b"]) {
        [mossaDopoParentesiAperta appendFormat:@"[%ld...", (long)numeroMossa];
    }
    else {
        [mossaDopoParentesiAperta appendString:@"["];
    }
    return mossaDopoParentesiAperta;
}

- (NSString *) getPrimaMossaNeroDaStampare {
    NSMutableString *primaMossaNero = [[NSMutableString alloc] init];
    [primaMossaNero appendString:@"1... "];
    [primaMossaNero appendString:_fullMove];
    return primaMossaNero;
}

- (NSString *) getCompleteMove {
    NSMutableString *completeMove = [[NSMutableString alloc] init];
    [completeMove appendString:[PGNUtil moveWithLetterToMoveWithSymbol:_fullMove]];
    if (nags.count > 0) {
        for (NSString *nag in nags) {
            [completeMove appendFormat:@"%@", [PGNUtil nagToSymbol:nag]];
        }
    }
    return completeMove;
}

- (NSString *) getMossaPerVarianti {
    NSUInteger numeroMossa = ceil(_plyCount/2.0);
    NSMutableString *mossaPerVarianti = [[NSMutableString alloc] init];
    if ([_color isEqualToString:@"w"]) {
        [mossaPerVarianti appendFormat:@"%ld. ", (long)numeroMossa];
    }
    else {
        [mossaPerVarianti appendFormat:@"%ld... ", (long)numeroMossa];
    }
    [mossaPerVarianti appendString:[PGNUtil moveWithLetterToMoveWithSymbol:_fullMove]];
    
    
    if (nags.count > 0) {
        //for (NSString *nag in nags) {
            //[mossaPerVarianti appendFormat:@"%@", [PGNUtil nagToSymbol:nag]];
        //}
    }
    
    [mossaPerVarianti appendString:[pgnMoveAnnotation getWebMoveAnnotation]];
    
    NSString *mossaVarianti = [mossaPerVarianti stringByReplacingOccurrencesOfString:@"\u24C3" withString:@"N"];
    return mossaVarianti;
}

- (BOOL) isValid {
    if ([_fullMove hasPrefix:@"XXX"]) {
        return YES;
    }
    if (_endGameMarked) {
        return YES;
    }
    if ((_fromSquare == 0) && (_toSquare == 0)) {
        return NO;
    }
    return YES;
}

- (BOOL) pedoneMossoDiDuePassi {
    if ([_piece isEqualToString:@"p"]) {
        if ([_color isEqualToString:@"w"]) {
            if ((_toSquare - _fromSquare) == 16) {
                return YES;
            }
        }
        else if ([_color isEqualToString:@"b"]) {
            if ((_toSquare - _fromSquare) == -16) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL) mossaDiPedoneOCattura {
    if ([_piece isEqualToString:@"p"]) {
        return YES;
    }
    if ([self capture]) {
        return YES;
    }
    return NO;
}

////////////////////////////////////////////////////////////////

- (void) visitaAlberoToGetTextAfterGraffe {
    if (_textAfter) {
        if (_fullMove) {
            //NSLog(@"MOSSA = %@   con commento after = %@", [self getMossaDaStampare], _textAfter);
            //NSLog(@"MOSSA = %@   con commento after = %@", [self getMossaDaStampare], [self textAfterWithGraffe]);
        }
        else {
            //NSLog(@"RADICE  con commento after = %@", _textAfter);
            //NSLog(@"RADICE  con commento after = %@", [self textAfterWithGraffe]);
        }
        
    }
    if (_nextMoves) {
        PGNMove *nextMove = [_nextMoves objectAtIndex:0];
        [nextMove visitaAlberoToGetTextAfterGraffe];
    }
}

- (void) visitaAlberoToGetTextBeforeGraffe {
    if (_textBefore) {
        if (_fullMove) {
            //NSLog(@"MOSSA = %@   con commento before = %@", [self getMossaDaStampare], _textBefore);
            //NSLog(@"MOSSA = %@   con commento before = %@", [self getMossaDaStampare], [self textBeforeWithGraffe]);
        }
        else {
            //NSLog(@"RADICE  con commento  before = %@", _textBefore);
            //NSLog(@"RADICE  con commento  before = %@", [self textBeforeWithGraffe]);
        }
    }
    if (_nextMoves) {
        PGNMove *nextMove = [_nextMoves objectAtIndex:0];
        [nextMove visitaAlberoToGetTextBeforeGraffe];
    }
}

- (void) visitaAlberoToGetFen {
    if (_fullMove) {
        NSLog(@"MOSSA = %@   con FEN = %@", [self getMossaDaStampare], _fen);
    }
    else {
        NSLog(@"ROOT MOVE");
    }
    if (_nextMoves) {
        PGNMove *nextMove = [_nextMoves objectAtIndex:0];
        [nextMove visitaAlberoToGetFen];
    }
}

- (void) visitaAlberoToCompareFen:(NSString *)inputFen {
    if (_fullMove) {
        NSLog(@"MOSSA = %@   con FEN = %@", [self getMossaDaStampare], _fen);
        if ([_fen isEqualToString:inputFen]) {
            //NSLog(@"I due fen sono uguali");
            //NSLog(@"%@", _fen);
            //NSLog(@"%@", inputFen);
            fenTrovatoUguale = YES;
            return;
        }
        else {
            //NSLog(@"I due fen non sono uguali");
            //NSLog(@"%@", _fen);
            //NSLog(@"%@", inputFen);
        }
    }
    else {
        //NSLog(@"ROOT MOVE");
    }
    if (_nextMoves) {
        PGNMove *nextMove = [_nextMoves objectAtIndex:0];
        [nextMove visitaAlberoToCompareFen:inputFen];
    }
}

- (void) setTrovatoFenUguale:(BOOL)trovatoFenUguale {
    fenTrovatoUguale = trovatoFenUguale;
}

- (BOOL) trovatoFenUguale {
    return fenTrovatoUguale;
}

- (void) visitaAlberoToGetMainLine {
    //if (_fullMove) {
        //NSLog(@"%@ con plycount = %d", [self getMossaDaStampare], _plyCount);
    //}
    //else {
        //NSLog(@"RADICE = NIL");
    //}
    if (_nextMoves) {
        PGNMove *nextMove = [_nextMoves objectAtIndex:0];
        [nextMove visitaAlberoToGetMainLine];
    }
}

- (void) visitaAlberoAnticipato {
    if (_fullMove) {
        //NSLog(@"PARENTESI = %@", [self getParentesi]);
        NSLog(@"%@", [self getMossaDaStampare]);
    }
    if (_nextMoves) {
        for (PGNMove *nextMove in _nextMoves) {
            if ([_nextMoves indexOfObject:nextMove]>0) {
                NSLog(@"[");
            }
            [nextMove visitaAlberoAnticipato];
        }
    }
    else {
        NSLog(@"]");
    }
}

- (void) visitaAlberoDifferito {
    if (_nextMoves) {
        for (PGNMove *nextMove in _nextMoves) {
            [nextMove visitaAlberoDifferito];
        }
    }
    else {
        NSLog(@"\n");
    }
    if (_fullMove) {
        NSLog(@"%@", [self getMossaDaStampare]);
    }
}

- (NSString *) getMossaInParentesi {
    NSUInteger numeroMossa = ceil(_plyCount/2.0);
    NSMutableString *mossaInParentesi = [[NSMutableString alloc] init];
    
    if (preNags) {
        for (NSString *preNag in preNags) {
            [mossaInParentesi appendString:[PGNUtil nagToSymbol:preNag]];
            [mossaInParentesi appendString:@" "];
        }
    }
    
    if ([_color isEqualToString:@"b"]) {
        [mossaInParentesi appendFormat:@"%ld...", (long)numeroMossa];
    }
    else {
        [mossaInParentesi appendString:@""];
    }
    return mossaInParentesi;
}

- (NSString *) getMossaInParentesiConNag {
    NSUInteger numeroMossa = ceil(_plyCount/2.0);
    NSMutableString *mossaInParentesi = [[NSMutableString alloc] init];
    
    if (preNags) {
        for (NSString *preNag in preNags) {
            [mossaInParentesi appendString:preNag];
            [mossaInParentesi appendString:@" "];
        }
    }
    
    if ([_color isEqualToString:@"b"]) {
        [mossaInParentesi appendFormat:@"%ld...", (long)numeroMossa];
    }
    else {
        [mossaInParentesi appendString:@""];
    }
    return mossaInParentesi;
}

- (NSString *) getMossaPerWebView {
    NSUInteger numeroMossa = ceil(_plyCount/2.0);
    NSMutableString *mossaPerWebView = [[NSMutableString alloc] init];
    
    
    if (preNags) {
        for (NSString *preNag in preNags) {
            [mossaPerWebView appendString:[PGNUtil nagToSymbol:preNag]];
            [mossaPerWebView appendString:@" "];
        }
    }
    
    if ([_fullMove hasPrefix:@"XXX"]) {
        if ([_color isEqualToString:@"w"]) {
            [mossaPerWebView appendFormat:@"%ld... ", (long)numeroMossa];
        }
    }
    else {
    
        if ([_color isEqualToString:@"w"]) {
            [mossaPerWebView appendFormat:@"%ld. ", (long)numeroMossa];
        }
        else if ([_color isEqualToString:@"b"] && (_prevMove.livelloVariante < _livelloVariante)) {
            [mossaPerWebView appendFormat:@"%ld... ", (long)numeroMossa];
        }
        
        [mossaPerWebView appendString:_fullMove];
        [mossaPerWebView appendString:@""];
    }
    
    
    if (nags.count > 0) {
        //for (NSString *nag in nags) {
            //[mossaPerWebView appendFormat:@"%@ ", [PGNUtil nagToSymbol:nag]];
        //}
    }
    
    [mossaPerWebView appendString:[pgnMoveAnnotation getWebMoveAnnotation]];
    
    
    NSString *mossaWebView = [mossaPerWebView stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return mossaWebView;
    
    /*
    NSString *mossaWeb = mossaPerWebView;
    
    if (_evidenzia) {
        if (IS_PAD) {
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbtr.png' width='16' height='16' alt='B'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wntr.png' width='16' height='16' alt='N'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrtr.png' width='16' height='16' alt='R'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqtr.png' width='16' height='16' alt='Q'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wktr.png' width='16' height='16' alt='K'/>"];
        }
        else {
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbtr.png' width='10' height='10' alt='B'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wntr.png' width='10' height='10' alt='N'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrtr.png' width='10' height='10' alt='R'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqtr.png' width='10' height='10' alt='Q'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wktr.png' width='10' height='10' alt='K'/>"];
        }
        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"\u24C3" withString:@"N"];
        mossaPerWebView = [[NSMutableString alloc] initWithString:[PGNUtil getMossaEvidenziata]];
        [mossaPerWebView appendString:[PGNUtil getMossaLinkApri]];
        //[mossaPerWebView appendString:mossaWeb];
        [mossaPerWebView appendString:[self getCompleteMove]];
        [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudiAngolare]];
        [mossaPerWebView appendString:mossaWeb];
        [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudi]];
        [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudiSpan]];
        [mossaPerWebView appendString:@" "];
    }
    else {
        if (IS_PAD) {
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbt.png' width='16' height='16' alt='B'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wnt.png' width='16' height='16' alt='N'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrt.png' width='16' height='16' alt='R'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqt.png' width='16' height='16' alt='Q'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wkt.png' width='16' height='16' alt='K'/>"];
        }
        else {
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbt.png' width='10' height='10' alt='B'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wnt.png' width='10' height='10' alt='N'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrt.png' width='10' height='10' alt='R'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqt.png' width='10' height='10' alt='Q'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wkt.png' width='10' height='10' alt='K'/>"];
        }
        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"\u24C3" withString:@"N"];
        mossaPerWebView = [[NSMutableString alloc] init];
        [mossaPerWebView appendString:[PGNUtil getMossaLinkApri]];
        //[mossaPerWebView appendString:mossaWeb];
        [mossaPerWebView appendString:@"10"];
        [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudiAngolare]];
        [mossaPerWebView appendString:mossaWeb];
        [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudi]];
        [mossaPerWebView appendString:@" "];
    }
    return mossaPerWebView;
    */
}


- (NSString *) textBefore {
    if (_textBefore && _textBefore.length>0) {
        NSString *tb = [_textBefore stringByTrimmingCharactersInSet:setGraffe];
        
        tb = [tb stringByReplacingOccurrencesOfString:@"><" withString:@"X "];
        tb = [tb stringByReplacingOccurrencesOfString:@"Ã" withString:@"\u2796"];
        tb = [tb stringByReplacingOccurrencesOfString:@"/\\" withString:@"\u1403"];
        
        NSMutableString *tbConBianchi = [[NSMutableString alloc] init];
        [tbConBianchi appendString:@" "];
        [tbConBianchi appendString:tb];
        [tbConBianchi appendString:@" "];
        return tbConBianchi;
    }
    return _textBefore;
}

- (NSString *) textAfter {
    if (_textAfter && _textAfter.length>0) {
        NSString *ta = [_textAfter stringByTrimmingCharactersInSet:setGraffe];
        
        ta = [ta stringByReplacingOccurrencesOfString:@"><" withString:@"X "];
        //ta = [ta stringByReplacingOccurrencesOfString:@"Ã" withString:@"\u2014"];
        ta = [ta stringByReplacingOccurrencesOfString:@"Ã" withString:@"\u2796"];
        //ta = [ta stringByReplacingOccurrencesOfString:@"Ã" withString:@"\u2212"];
        ta = [ta stringByReplacingOccurrencesOfString:@"/\\" withString:@"\u1403"];
        
        NSMutableString *taConBianchi = [[NSMutableString alloc] init];
        [taConBianchi appendString:@" "];
        [taConBianchi appendString:ta];
        [taConBianchi appendString:@" "];
        return taConBianchi;
    }
    return _textAfter;
}

- (NSString *) textAfterForGameMovesWebView {
    if (_textAfter && _textAfter.length>0) {
        NSString *ta = [_textAfter stringByTrimmingCharactersInSet:setGraffe];
        
        //ta = [ta stringByReplacingOccurrencesOfString:@"><" withString:@"X "];
        ta = [ta stringByReplacingOccurrencesOfString:@"><" withString:@"<span class='move-annotation'>k</span>"];
        //ta = [ta stringByReplacingOccurrencesOfString:@"Ã" withString:@"\u2796"];
        ta = [ta stringByReplacingOccurrencesOfString:@"Ã" withString:@"<span class='move-annotation'>y</span>"];
        //ta = [ta stringByReplacingOccurrencesOfString:@"/\\" withString:@"\u1403"];
        ta = [ta stringByReplacingOccurrencesOfString:@"/\\" withString:@"<span class='move-annotation'>c</span>"];
        NSMutableString *taConBianchi = [[NSMutableString alloc] init];
        //[taConBianchi appendString:@" "];
        [taConBianchi appendString:ta];
        //[taConBianchi appendString:@" "];
        return taConBianchi;
    }
    return _textAfter;
}

- (NSString *) textBeforeWithGraffe {
    if (_textBefore && _textBefore.length>0) {
        _textBefore = [_textBefore stringByTrimmingCharactersInSet:setGraffe];
        _textBefore = [_textBefore stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableString *textBeforeWithGraffa = [[NSMutableString alloc] init];
        [textBeforeWithGraffa appendString:@"{"];
        [textBeforeWithGraffa appendString:_textBefore];
        [textBeforeWithGraffa appendString:@"} "];
        //NSLog(@"Stampo Text before prima di restituirlo:   %@", textBeforeWithGraffa);
        return textBeforeWithGraffa;
    }
    return @"";
}

- (NSString *) textAfterWithGraffe {
    if (_textAfter && _textAfter.length>0) {
        _textAfter = [_textAfter stringByTrimmingCharactersInSet:setGraffe];
        _textAfter = [_textAfter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableString *textAfterWithGraffa = [[NSMutableString alloc] init];
        [textAfterWithGraffa appendString:@"{"];
        [textAfterWithGraffa appendString:_textAfter];
        [textAfterWithGraffa appendString:@"} "];
        //NSLog(@"Stampo Text After prima di restituirlo:   %@", textAfterWithGraffa);
        return textAfterWithGraffa;
    }
    return @"";
}

- (NSString *) getMossaPerWebView2 {
    NSMutableString *mossaPerWebView = [[NSMutableString alloc] init];
    [mossaPerWebView appendString:_fullMove];
    if (nags.count > 0) {
        for (NSString *nag in nags) {
            [mossaPerWebView appendFormat:@"%@ ", [PGNUtil nagToSymbol:nag]];
        }
    }
    NSString *resultMossa = [mossaPerWebView stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return resultMossa;
}

- (NSString *) getMossaTest {
    NSMutableString *mossaTest = [[NSMutableString alloc] init];
    [mossaTest appendString:[self getMossaPerWebView2]];
    [mossaTest appendString:@" - "];
    if (_inVariante) {
        [mossaTest appendString:@"Appartengo ad una variante"];
    }
    return mossaTest;
}

- (NSString *) getMossaCompletaConParentesi {
    NSMutableString *mossaConParentesi = [[NSMutableString alloc] init];
    if (_preParentesi) {
        [mossaConParentesi appendString:_preParentesi];
    }
    [mossaConParentesi appendString:[self getMossaPerWebView]];
    if (_postParentesi) {
        [mossaConParentesi appendString:_postParentesi];
    }
    //if (_inVariante) {
        //[mossaConParentesi appendFormat:@"      - appartengo ad una variante di livello %d", _livelloVariante];
    //}
    return mossaConParentesi;
}

- (NSUInteger) getNumeroMossa {
    NSUInteger numeroMossa = ceil(_plyCount/2.0);
    return numeroMossa;
}

- (void) resetWebArray {
    [gameArray removeAllObjects];
    [gameWithNags setString:@""];
}

- (void) resetGameWithNags {
    [gameWithNags setString:@""];
}

- (void) resetEngineMoves {
    [engineMovesArray setString:@""];
}

- (void) visitaAlberoAnticipato2 {
    if (_nextMoves) {
        
        
        PGNMove *figlioMove = [_nextMoves objectAtIndex:0];
        
        if ([self isRootMove] && [figlioMove endGameMarked]) {
            [game appendString:[self textAfterWithGraffe]];
            [gameWithNags appendString:[self textAfterWithGraffe]];
            [gameWithNags appendString:[figlioMove getMossaDaStampareConNag]];
            [game appendString:[figlioMove getMossaDaStampare]];
            [gameArray addObject:figlioMove];
            return;
        }
        
        
        PGNMove *padreMove = [figlioMove getPrevMove];
        if ([padreMove inVariante]) {
            [figlioMove setInVariante:YES];
            [figlioMove setLivelloVariante:[padreMove livelloVariante]];
        }
        else {
            [figlioMove setInVariante:NO];
            [figlioMove setLivelloVariante:0];
        }
        padreMove = nil;
        
        
        
        //NSLog(@">>>>>%@", [figlioMove getMossaDaStampare]);
        //NSLog(@"VisitaAlberoAnticipato2:   %@", [figlioMove textBeforeWithGraffe]);
        [game appendString:[figlioMove textBeforeWithGraffe]];
        [game appendString:[figlioMove getMossaDaStampare]];
        [game appendString:@" "];
        [game appendString:[figlioMove textAfterWithGraffe]];
        [gameWithNags appendString:[figlioMove textBeforeWithGraffe]];
        
        //NSLog(@"VAA2: %@", gameWithNags);
        
        [gameWithNags appendString:[figlioMove getMossaDaStampareConNag]];
        [gameWithNags appendString:@" "];
        [gameWithNags appendString:[figlioMove textAfterWithGraffe]];
        //[gameArray addObject:[figlioMove getMossaDaStampare]];
        //[gameArray addObject:[figlioMove getMossaPerWebView]];
        [gameArray addObject:figlioMove];
        if (_nextMoves.count>1) {
            for (int i=1; i<_nextMoves.count; i++) {
                PGNMove *fratelloMove = [_nextMoves objectAtIndex:i];
                numVariantiAperte++;
                [fratelloMove setInVariante:YES];
                [fratelloMove setLivelloVariante:numVariantiAperte];
                if (numVariantiAperte == 1) {
                    //NSLog(@"[");
                    [game appendString:@"["];
                    [gameWithNags appendString:@"("];
                    [gameArray addObject:@"["];
                    [fratelloMove setPreParentesi:@"["];
                }
                else {
                    //NSLog(@"(");
                    [game appendString:@"("];
                    [gameWithNags appendString:@"("];
                    [gameArray addObject:@"("];
                    [fratelloMove setPreParentesi:@"("];
                }
                //NSLog(@"[");
                
                //NSLog(@"%@", [fratelloMove getMossaDaStampare]);
                [game appendString:[fratelloMove textBeforeWithGraffe]];
                [game appendString:[fratelloMove getMossaInParentesi]];
                [game appendString:[fratelloMove getMossaDaStampare]];
                [game appendString:@" "];
                [game appendString:[fratelloMove textAfterWithGraffe]];
                [gameWithNags appendString:[fratelloMove textBeforeWithGraffe]];
                [gameWithNags appendString:[fratelloMove getMossaInParentesiConNag]];
                [gameWithNags appendString:[fratelloMove getMossaDaStampareConNag]];
                [gameWithNags appendString:@" "];
                [gameWithNags appendString:[fratelloMove textAfterWithGraffe]];
                //[gameArray addObject:[fratelloMove getMossaInParentesi]];
                //[gameArray addObject:[fratelloMove getMossaDaStampare]];
                //[gameArray addObject:[fratelloMove getMossaPerWebView]];
                [gameArray addObject:fratelloMove];
                [fratelloMove visitaAlberoAnticipato2];
                numVariantiAperte--;
                if (numVariantiAperte==0) {
                    //NSLog(@"]");
                    [game deleteCharactersInRange:NSMakeRange([game length] - 1, 1)];
                    [game appendString:@"]"];
                    [game appendString:@" "];
                    [gameWithNags deleteCharactersInRange:NSMakeRange([gameWithNags length] - 1, 1)];
                    [gameWithNags appendString:@")"];
                    [gameWithNags appendString:@" "];
                    [gameArray addObject:@"]"];
                }
                else {
                    //NSLog(@")");
                    [game deleteCharactersInRange:NSMakeRange([game length] - 1, 1)];
                    [game appendString:@")"];
                    [game appendString:@" "];
                    [gameWithNags deleteCharactersInRange:NSMakeRange([gameWithNags length] - 1, 1)];
                    [gameWithNags appendString:@")"];
                    [gameWithNags appendString:@" "];
                    [gameArray addObject:@")"];
                }
            }
        }
        [figlioMove visitaAlberoAnticipato2];
    }
    else {
        if (numVariantiAperte>1) {
            [self setPostParentesi:@")"];
        }
        else if (numVariantiAperte == 1) {
            [self setPostParentesi:@"]"];
        }
    }
}

- (void) setPreParentesi:(NSString *)preParentesi {
    _preParentesi = preParentesi;
    //NSLog(@"HO APERTO LA PARENTESI %@ PRIMA DELLA MOSSA %@", _preParentesi, _fullMove);
}

- (NSString *) getPreParentesi {
    if (_preParentesi) {
        return _preParentesi;
    }
    return @"";
}

- (void) setPostParentesi:(NSString *)postParentesi {
    _postParentesi = postParentesi;
    //NSLog(@"HO CHIUSO LA PARENTESI %@ DOPO LA MOSSA %@", _postParentesi, _fullMove);
}

- (NSString *) getPostParentesi {
    if (_postParentesi) {
        return _postParentesi;
    }
    return @"";
}

- (NSString *) getGameDopoAlberoAnticipato2 {
    return game;
}

- (NSString *) getGameWithNagsDopoAlberoAnticipato2 {
    return gameWithNags;
}

- (NSArray *) getGameArrayDopoAlberoAnticipato2 {
    //[gameArray insertObject:self atIndex:0];
    return gameArray;
}

- (void) visitaAlberoIndietro {
    if (_fullMove) {
        NSLog(@"%@", _fullMove);
    }
    if (_prevMove) {
        [_prevMove visitaAlberoIndietro];
    }
}

- (void) visitaAlberoIndietroPerMotore {
    if (_fullMove) {
        
        if (_fromSquare == 0 && _toSquare == 0) {
            return;
        }
        
        int colonnaP = [self getColumnFromSquare:_fromSquare];
        int rigaP = [self getRowFromSquare:_fromSquare];
        char letterP = 96 + colonnaP + 1;
        NSString *casaAlgebricaP = [[NSString stringWithFormat:@"%c", letterP] stringByAppendingString:[NSString stringWithFormat:@"%d", rigaP + 1]];
        
        int colonnaA = [self getColumnFromSquare:_toSquare];
        int rigaA = [self getRowFromSquare:_toSquare];
        char letterA = 96 + colonnaA + 1;
        NSString *casaAlgebricaA = [[NSString stringWithFormat:@"%c", letterA] stringByAppendingString:[NSString stringWithFormat:@"%d", rigaA + 1]];
        
        NSString *m = [NSString stringWithFormat:@"%@%@", casaAlgebricaP, casaAlgebricaA];
        
        if (self.promoted) {
            NSString *pezzoPromosso = [_promotion lowercaseString];
            m = [m stringByAppendingString:pezzoPromosso];
        }
        
        [engineMovesArray insertString:m atIndex:0];
        [engineMovesArray insertString:@" " atIndex:0];
    }
    if (_prevMove) {
        [_prevMove visitaAlberoIndietroPerMotore];
    }
}

- (NSString *) getMosseDopoVisitaAlberoIndietroPerMotore {
    return [engineMovesArray stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (short) getColumnFromSquare:(short) square {
    for (short r = 0; r<=7; r++) {
        for (short c = 0; c<=7; c++) {
            short sq = c + r*8;
            if (sq == square) {
                return c;
            }
        }
    }
    return -1;
}

- (short) getRowFromSquare:(short) square {
    for (short r = 0; r<=7; r++) {
        for (short c = 0; c<=7; c++) {
            short sq = c + r*8;
            if (sq == square) {
                return r;
            }
        }
    }
    return -1;
}

- (NSUInteger) getNumeroMosse:(NSString *)pezzo {
    if (_fullMove) {
        if ([_fullMove hasPrefix:pezzo]) {
            numMosse++;
            NSLog(@"NumeroMosse per %@ = %d", pezzo, numMosse);
        }
    }
    if (_prevMove) {
        numMosse = [_prevMove getNumeroMosse:pezzo];
    }
    return numMosse;
}

- (BOOL) isEqualToMove:(PGNMove *)pgnMove {
    NSLog(@"Sto comparando due mosse   %@   e   %@", pgnMove.move, _move);
    
    if (_promoted) {
        if ([pgnMove.move isEqualToString:_move] && [pgnMove.color isEqualToString:_color] && [pgnMove.promotion isEqualToString:_promotion]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    
    
    
    if ([pgnMove.move isEqualToString:_move] && [pgnMove.color isEqualToString:_color]) {
        return YES;
    }
    //if ((pgnMove.fromSquare == _fromSquare) && (pgnMove.toSquare == _toSquare) && ([pgnMove.color isEqualToString:_color])) {
    //    return YES;
    //}
    return NO;
}

- (PGNMove *) getLastMove {
    if (_nextMoves) {
        PGNMove *figlioMove = [_nextMoves objectAtIndex:0];
        return [figlioMove getLastMove];
    }
    return self;
}

- (void) removeResultMove {
    if (_nextMoves) {
        PGNMove *figlioMove = [_nextMoves objectAtIndex:0];
        if ([figlioMove endGameMarked]) {
            [_nextMoves removeObjectAtIndex:0];
            _nextMoves = nil;
        }
        else {
            [figlioMove removeResultMove];
        }
    }
}

- (void) addResultMove:(PGNMove *)resultMove {
    if (_nextMoves) {
        PGNMove *figlioMove = [_nextMoves objectAtIndex:0];
        [figlioMove addResultMove:resultMove];
    }
    else {
        [self addNextMove:resultMove];
    }
}

- (BOOL) isRootMove {
    if (!_prevMove) {
        return YES;
    }
    return NO;
}

- (BOOL) isFirstMoveAfterRoot {
    if (_prevMove) {
        if ([_prevMove isRootMove]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isFirstMoveAfterRootWithDots {
    if ([self isFirstMoveAfterRoot]) {
        if ([_fullMove isEqualToString:@"XXX"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isResultMove {
    if ([_fullMove isEqualToString:@"1-0"] || [_fullMove isEqualToString:@"0-1"] || [_fullMove isEqualToString:@"1/2-1/2"] || [_fullMove isEqualToString:@"*"]) {
        return YES;
    }
    return NO;
}

- (BOOL) movesHasBeenInserted {
    if ([self isRootMove]) {
        if ([self getNextMoves]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) existInitialText {
    if ([self isRootMove]) {
        if (_textAfter) {
            return YES;
        }
        if ([self getNextMoves]) {
            PGNMove *firstMove = [_nextMoves objectAtIndex:0];
            if ([firstMove textBefore]) {
                return YES;
            }
        }
    }
    return NO;
}

- (PGNMove *) getFirstMoveAfterRoot {
    if ([self isRootMove]) {
        if ([self getNextMoves]) {
            return [_nextMoves objectAtIndex:0];
        }
    }
    return nil;
}

- (int) getDevelopmentSquareFromAlgebricValue:(NSString *)algebricSquare {
    NSString *col = [algebricSquare substringToIndex:1];
    NSString *row = [algebricSquare substringFromIndex:1];
    
    int riga = [row intValue] - 1;
    int column = -1;
    
    column = (int)[lettereScacchiera indexOfObject:col];
    
//    if ([col isEqualToString:@"a"]) {
//        column = 0;
//    }
//    else if ([col isEqualToString:@"b"]) {
//        column = 1;
//    }
//    else if ([col isEqualToString:@"c"]) {
//        column = 2;
//    }
//    else if ([col isEqualToString:@"d"]) {
//        column = 3;
//    }
//    else if ([col isEqualToString:@"e"]) {
//        column = 4;
//    }
//    else if ([col isEqualToString:@"f"]) {
//        column = 5;
//    }
//    else if ([col isEqualToString:@"g"]) {
//        column = 6;
//    }
//    else if ([col isEqualToString:@"h"]) {
//        column = 7;
//    }
    
    
    
    //NSLog(@">>>>>>>>>>>>   %@-%@", col, row);
    
    return riga*8 + column;
}


#pragma mark - Implementazione metodi per gestire le varianti (eliminazione, promozione)

- (void) deleteVariation:(NSInteger)livelloVariante {
    [_nextMoves removeObjectAtIndex:livelloVariante];
}

- (void) promoteVariationToMainLine:(NSInteger)livelloVarianteDaPromuovere {
    PGNMove *varToPromote = [_nextMoves objectAtIndex:livelloVarianteDaPromuovere];
    [_nextMoves removeObjectAtIndex:livelloVarianteDaPromuovere];
    //[_nextMoves insertObject:varToPromote atIndex:livelloVarianteDaPromuovere - 1];
    [_nextMoves insertObject:varToPromote atIndex:0];
}

- (void) promoteVariationUp:(NSInteger)livelloVarianteDaPromuovere {
    PGNMove *varToPromote = [_nextMoves objectAtIndex:livelloVarianteDaPromuovere];
    [_nextMoves removeObjectAtIndex:livelloVarianteDaPromuovere];
    [_nextMoves insertObject:varToPromote atIndex:livelloVarianteDaPromuovere - 1];
}

- (void) promoteAsFirstVariation:(NSInteger)livelloVarianteDaPromuovere {
    PGNMove *varToPromote = [_nextMoves objectAtIndex:livelloVarianteDaPromuovere];
    [_nextMoves removeObjectAtIndex:livelloVarianteDaPromuovere];
    [_nextMoves insertObject:varToPromote atIndex:1];
}

#pragma mark - Implementazione metodi per gestire GameMovesWebView

- (NSString *) getMoveToDisplayOnWebView {
    NSUInteger numeroMossa = ceil(_plyCount/2.0);
    NSMutableString *mossaPerWebView = [[NSMutableString alloc] init];
    
    if (preNags) {
        for (NSString *preNag in preNags) {
            [mossaPerWebView appendString:[PGNUtil nagToSymbolForGameMovesWebView:preNag]];
            [mossaPerWebView appendString:@" "];
        }
    }
    
    if ([_fullMove hasPrefix:@"XXX"]) {
        if ([_color isEqualToString:@"w"]) {
            [mossaPerWebView appendFormat:@"%d... ", (int)numeroMossa];
        }
    }
    else {
        
        if ([_color isEqualToString:@"w"]) {
            [mossaPerWebView appendFormat:@"%d. ", (int)numeroMossa];
        }
        else if ([_color isEqualToString:@"b"] && (_prevMove.livelloVariante < _livelloVariante)) {
            [mossaPerWebView appendFormat:@"%d... ", (int)numeroMossa];
        }
        
        [mossaPerWebView appendString:_fullMove];
        [mossaPerWebView appendString:@""];
    }
    
    [mossaPerWebView appendString:[pgnMoveAnnotation getWebMoveAnnotationForGameMovesWebView]];
    
    NSString *mossaWebView = [mossaPerWebView stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return mossaWebView;
}


- (void) convertExtendedMoveToFullMove:(NSString *)prefix {
    if (_fullMove != nil) {
        if (![_fullMove isEqualToString:@"1-0"] && ![_fullMove isEqualToString:@"0-1"] && ![_fullMove isEqualToString:@"1/2-1/2"] && ![_fullMove isEqualToString:@"*"]) {
            if (![_fullMove isEqualToString:@"O-O"] && ![_fullMove isEqualToString:@"0-0"] && ![_fullMove isEqualToString:@"O-O-O"] && ![_fullMove isEqualToString:@"0-0-0"]) {
                
                NSString *ss = nil;
                NSString *es = nil;
                NSString *p = nil;
                NSString *presa = nil;
                
                if ([_fullMove rangeOfString:@"-"].location != NSNotFound) {
                    //NSLog(@"La mossa ha una notazione estesa senza presa:%@", fullMove);
                    NSArray *moveArray = [_fullMove componentsSeparatedByString:@"-"];
                    ss = [moveArray objectAtIndex:0];
                    es = [moveArray objectAtIndex:1];
                    
                    presa = nil;
                    
                    
                    if (ss.length == 3) {
                        p = [ss substringToIndex:1];
                        ss = [ss substringFromIndex:1];
                        _fullMove = p;
                        if (prefix) {
                            _fullMove = [_fullMove stringByAppendingString:prefix];
                        }
                        _fullMove = [_fullMove stringByAppendingString:es];
                    }
                    else {
                        p = @"P";
                        _fullMove = es;
                    }
                    
                }
                else if ([_fullMove rangeOfString:@"x"].location != NSNotFound) {
                    NSArray *moveArray = [_fullMove componentsSeparatedByString:@"x"];
                    if ([[moveArray objectAtIndex:0] length]>1) {
                        //NSLog(@"La mossa ha una notazione estesa con presa:%@", fullMove);
                        ss = [moveArray objectAtIndex:0];
                        es = [moveArray objectAtIndex:1];
                        presa = @"x";
                        
                        if (ss.length == 3) {
                            p = [ss substringToIndex:1];
                            ss = [ss substringFromIndex:1];
                            _fullMove = p;
                            if (prefix) {
                                _fullMove = [_fullMove stringByAppendingString:prefix];
                            }
                            _fullMove = [_fullMove stringByAppendingString:@"x"];
                            _fullMove = [_fullMove stringByAppendingString:es];
                        }
                        else {
                            NSString *primoCar = [ss substringToIndex:1];
                            if ([lettereScacchiera containsObject:primoCar]) {
                                p = @"P";
                                
                                _fullMove = [ss substringToIndex:1];
                                _fullMove = [_fullMove stringByAppendingString:@"x"];
                                _fullMove = [_fullMove stringByAppendingString:es];
                            }
                            else {
                                presa = nil;
                                _fullMove = es;
                                p = nil;
                            }
                        }
                    }
                }
                
                //NSLog(@"CONVERTED MOVE = %@", _fullMove);
                _extendedMove = NO;
            }
        }
    }
}


@end
