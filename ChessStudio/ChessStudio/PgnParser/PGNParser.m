//
//  PGNParser.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 03/04/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PGNParser.h"
#import "PGNSquare.h"
#import "PGNBoard.h"
#import "BoardModel.h"


short const empty = 0;

short const white_king = -6;
short const white_queen = -5;
short const white_rook = -4;
short const white_bishop = -3;
short const white_knight = -2;
short const white_pawn = -1;

short const black_king = 6;
short const black_queen = 5;
short const black_rook = 4;
short const black_bishop = 3;
short const black_knight = 2;
short const black_pawn = 1;


NSString *KING = @"K";
NSString *QUEEN = @"Q";
NSString *ROOK = @"R";
NSString *BISHOP = @"B";
NSString *KNIGHT = @"N";
NSString *PAWN = @"P";


short const MOVE_TYPE_1_LENGTH = 2;
short const MOVE_TYPE_2_LENGTH = 3;
short const MOVE_TYPE_3_LENGTH = 4;
short const MOVE_TYPE_4_LENGTH = 5;


@interface PGNParser() {

    
    NSString *gameToParser;
    
    //PGNGame *pgnGame;

    NSMutableArray *rawMoves;
    
    //PGNBoard *pgnBoard;
    BoardModel *boardModel;
    
    BoardModel *boardModel2;
    
    NSString *color;
    short colorByte;

    NSString *pattern1;
    NSString *pattern2;
    NSString *pattern3;//Mossa del tipo Nbd2 o Rad8
    NSString *pattern4;//Mossa del Tipo N1e2 o R1g4
    
    NSRegularExpression *regexPattern1;
    NSRegularExpression *regexPattern2;
    NSRegularExpression *regexPattern3;
    NSRegularExpression *regexPattern4;
    
    
    NSMutableArray *knightSearchPath;
    NSMutableArray *bishopSearchPath;
    NSMutableArray *rookSearchPath;
    NSMutableArray *queenAndKingSearchPath;
}

@end


@implementation PGNParser


- (id) init {
    self = [super init];
    if (self) {
        //[self initParserWithGame];
    }
    return self;
}

- (id) initWithPgnMoves:(NSString *)pgnMoves {
    self = [super init];
    if (self) {
        //NSString *className = NSStringFromClass([self class]);
        //NSString *methodName = NSStringFromSelector(_cmd);
        //NSLog(@"Inizio Messaggio da %@ con metodo %@", className, methodName);
        //NSLog(@"%@", pgnMoves);
        //NSLog(@"Fine Messaggio da %@ con metodo %@", className, methodName);
        
        
        gameToParser = pgnMoves;
        [self initParserWithGame];
        
        //pattern1 = @"[KQRBN][a-h][1-8]";
        //pattern2 = @"[a-h][a-h][1-8]";
        //pattern3 = @"[KQRBN][a-h][a-h][1-8]";
        //pattern4 = @"[KQRBN][1-8][a-h][1-8]";
        
        //NSError *error = NULL;
        
        //regexPattern1 = [[NSRegularExpression alloc] initWithPattern:pattern1 options:0 error:&error];
        //regexPattern2 = [[NSRegularExpression alloc] initWithPattern:pattern2 options:0 error:&error];
        //regexPattern3 = [[NSRegularExpression alloc] initWithPattern:pattern3 options:0 error:&error];
        //regexPattern4 = [[NSRegularExpression alloc] initWithPattern:pattern4 options:0 error:&error];
        

        //[self initSearchPath];
        
        //[self createDefaultBoard];
        
        
        
        //pgnGame = [[PGNGame alloc] initWithPgn:pgnMoves];
        
        //rawMoves = [[NSMutableArray alloc] init];
        
        //for (NSString *m in [pgnMoves componentsSeparatedByString:@" "]) {
        //    [rawMoves addObject:m];
        //}
        
        //[self handleRawMoves];
    }
    return self;
}

- (id) initWithGame {
    self = [super init];
    if (self) {
        [self initParserWithGame];
    }
    return self;
}

- (id) initWithPosition {
    self = [super init];
    if (self) {
        [self initParserWithPosition];
    }
    return self;
}

- (void) initParserWithGame {
    pattern1 = @"[KQRBN][a-h][1-8]";
    pattern2 = @"[a-h][a-h][1-8]";
    pattern3 = @"[KQRBN][a-h][a-h][1-8]";
    pattern4 = @"[KQRBN][1-8][a-h][1-8]";
    
    NSError *error = NULL;
    
    regexPattern1 = [[NSRegularExpression alloc] initWithPattern:pattern1 options:0 error:&error];
    regexPattern2 = [[NSRegularExpression alloc] initWithPattern:pattern2 options:0 error:&error];
    regexPattern3 = [[NSRegularExpression alloc] initWithPattern:pattern3 options:0 error:&error];
    regexPattern4 = [[NSRegularExpression alloc] initWithPattern:pattern4 options:0 error:&error];
    
    [self initSearchPath];
    
    //pgnBoard = [[PGNBoard alloc] init];
    boardModel = [[BoardModel alloc] init];
    [boardModel setupInitialPosition];
    
    boardModel2 = [[BoardModel alloc] init];
    [boardModel2 setupInitialPosition];
    
    color = @"w";
    colorByte = -1;
}

- (void) initParserWithPosition {
    pattern1 = @"[KQRBN][a-h][1-8]";
    pattern2 = @"[a-h][a-h][1-8]";
    pattern3 = @"[KQRBN][a-h][a-h][1-8]";
    pattern4 = @"[KQRBN][1-8][a-h][1-8]";
    
    NSError *error = NULL;
    
    regexPattern1 = [[NSRegularExpression alloc] initWithPattern:pattern1 options:0 error:&error];
    regexPattern2 = [[NSRegularExpression alloc] initWithPattern:pattern2 options:0 error:&error];
    regexPattern3 = [[NSRegularExpression alloc] initWithPattern:pattern3 options:0 error:&error];
    regexPattern4 = [[NSRegularExpression alloc] initWithPattern:pattern4 options:0 error:&error];
    
    [self initSearchPath];
    
    //pgnBoard = [[PGNBoard alloc] init];
    boardModel = [[BoardModel alloc] init];
    [boardModel setStartFromFen:YES];
    [boardModel setupInitialPosition];
    
    boardModel2 = [[BoardModel alloc] init];
    [boardModel2 setStartFromFen:YES];
    [boardModel2 setupInitialPosition];
    
    color = @"w";
    colorByte = -1;
}

- (void) parse:(NSString *)pgnMoves {
    gameToParser = pgnMoves;
    
    //pgnGame = [[PGNGame alloc] initWithPgn:pgnMoves];
    rawMoves = [[NSMutableArray alloc] init];
    for (NSString *m in [pgnMoves componentsSeparatedByString:@" "]) {
        [rawMoves addObject:m];
    }
    [self handleRawMoves];
}

- (void) parseTreeMoves:(PGNMove *)pgnMove {
    //pgnGame = [[PGNGame alloc] initWithPgn:@""];
    if (!pgnMove) {
        //NSLog(@" MESSAGGIO DA PGNParser: FIRST MOVE NULLO");
        return;
    }    
    color = @"w";
    colorByte = -1;
    

    [self visitaAlberoMosse:pgnMove];
    
    
    if (pgnMove) {
        //NSLog(@"Alla fine di parseTreeMoves pgnMove non è nil con valore %@", pgnMove.description);
        [self updateToPreviousMove:pgnMove];
    }
    else {
        //NSLog(@"Alla fine di parseTreeMoves pgnMove  è nil");
        boardModel2 = nil;
    }
    
    //boardModel2 = nil;
}

- (void) parseTreeMovesGameWithMoves:(PGNMove *)pgnMove {
    
    //NSLog(@"START PARSE TREE MOVES GAME WITH MOVES");
    
    if (!pgnMove) {
        //NSLog(@" MESSAGGIO DA PGNParser: FIRST MOVE NULLO");
        return;
    }
    color = @"w";
    colorByte = -1;
    
    [self visitaAlberoMosse:pgnMove];
    
    if (pgnMove) {
        //NSLog(@"Alla fine di parseTreeMoves pgnMove non è nil con valore %@", pgnMove.description);
        [self updateToPreviousMove:pgnMove];
    }
    else {
        //NSLog(@"Alla fine di parseTreeMoves pgnMove  è nil");
        boardModel2 = nil;
    }
    
    //boardModel2 = nil;
    
    //NSLog(@"END PARSE TREE MOVES GAME WITH MOVES");
}

- (void) parseTreeMovesPositionWithMoves:(PGNMove *)pgnMove {
    
    //NSLog(@"START PARSE TREE MOVES POSITION WITH MOVES");
    
    if (!pgnMove) {
        //NSLog(@" MESSAGGIO DA PGNParser: FIRST MOVE NULLO");
        return;
    }
    color = @"w";
    colorByte = -1;
    
    [self visitaAlberoMosse:pgnMove];
    
    if (pgnMove) {
        //NSLog(@"Alla fine di parseTreeMoves pgnMove non è nil con valore %@", pgnMove.description);
        [self updateToPreviousMove:pgnMove];
    }
    else {
        //NSLog(@"Alla fine di parseTreeMoves pgnMove  è nil");
        boardModel2 = nil;
    }
    
    //NSLog(@"END PARSE TREE MOVES POSITION WITH MOVES");
}

- (void) parseMoveForward:(PGNMove *)moveToParseForward {
    //NSLog(@"Devo fare il parse della mossa: %@", moveToParseForward.description);
    if (moveToParseForward) {
        //NSLog(@"MOVE TO PARSE FORWARD ESISTE");
        if ((moveToParseForward.fromSquare == 0) && (moveToParseForward.toSquare == 0)) {
            [self switchColor:moveToParseForward.color];
            [self updateNextMove:moveToParseForward];
            if ([moveToParseForward isValid]) {
                //[self switchColor];
                //[pgnGame addMove:moveToParseForward];
                //NSLog(@"PARSE_MOVE_FORWARD OK");
            }
        }
        else {
            //NSLog(@"DEVO andare a Muovi Avanti");
            //[pgnBoard muoviAvanti:moveToParseForward];
            [boardModel muoviAvanti:moveToParseForward];
        }
    }
}

- (void) parseMoveBack:(PGNMove *)moveToParseBack {
    //NSLog(@"Devo fare il parse Back della mossa: %@", moveToParseBack.description);
    //[pgnBoard muoviIndietro:moveToParseBack];
    [boardModel muoviIndietro:moveToParseBack];
}


//- (PGNGame *) getGame {
    //return pgnGame;
//}


- (void) initSearchPath {
    //knightSearchPath = [[NSArray alloc] initWithObjects:[NSNumber numberWithShort:10], [NSNumber numberWithShort:-10], [NSNumber numberWithShort:6], [NSNumber numberWithShort:-6], [NSNumber numberWithShort:17], [NSNumber numberWithShort:-17], [NSNumber numberWithShort:15], [NSNumber numberWithShort:-15], nil];
    
    knightSearchPath = [[NSMutableArray alloc] init];
    PGNSquare *sq = [[PGNSquare alloc] initWithColumnAndRow:-1 :2];
    [knightSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:1 :2];
    [knightSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:-1 :-2];
    [knightSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:1 :-2];
    [knightSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:-2 :1];
    [knightSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:-2 :-1];
    [knightSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:2 :-1];
    [knightSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:2 :1];
    [knightSearchPath addObject:sq];
    
    bishopSearchPath = [[NSMutableArray alloc] init];
    sq = [[PGNSquare alloc] initWithColumnAndRow:1 :1];
    [bishopSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:1 :-1];
    [bishopSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:-1 :-1];
    [bishopSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:-1 :1];
    [bishopSearchPath addObject:sq];
    
    rookSearchPath = [[NSMutableArray alloc] init];
    sq = [[PGNSquare alloc] initWithColumnAndRow:0 :1];
    [rookSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:1 :0];
    [rookSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:0 :-1];
    [rookSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:-1 :0];
    [rookSearchPath addObject:sq];
    
    queenAndKingSearchPath = [[NSMutableArray alloc] init];
    sq = [[PGNSquare alloc] initWithColumnAndRow:1 :1];
    [queenAndKingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:1 :-1];
    [queenAndKingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:-1 :-1];
    [queenAndKingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:-1 :1];
    [queenAndKingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:0 :1];
    [queenAndKingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:1 :0];
    [queenAndKingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:0 :-1];
    [queenAndKingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:-1 :0];
    [queenAndKingSearchPath addObject:sq];
}


- (void) handleRawMoves {
    PGNMove *move = nil;
    //NSString *className = NSStringFromClass([self class]);
    //NSString *methodName = NSStringFromSelector(_cmd);
    //NSLog(@"Inizio Messaggio da %@ con metodo %@", className, methodName);
    color = @"w";
    colorByte = -1;
    int plyCount = 0;
    for (NSString *rawMove in rawMoves) {
        //NSLog(@"RAW MOVE = %@", rawMove);
        if ([rawMove rangeOfString:@"."].location != NSNotFound) {
            //NSRange rangePunto = [rawMove rangeOfString:@"."];
            //NSString *num = [rawMove substringToIndex:rangePunto.location];
            //NSUInteger numValue = [num integerValue];
            //NSLog(@"%d", numValue);
        }
        else if ([rawMove hasPrefix:@"$"]) {
                //NSLog(@"Devo Gestire NAG");
                [move setNag:rawMove];
             }
            else {
                move = [[PGNMove alloc] initWithFullMove:rawMove];
                [move setColor:color];
                plyCount++;
                [move setPlyCount:plyCount];
                //NSLog(@"%@", [move description]);
                //[pgnGame addMove:move];
                [self updateNextMove:move];
                [self switchColor];
            }
    }
    //NSLog(@"Fine Messaggio da %@ con metodo %@", className, methodName);
}

- (void) updateToPreviousMove:(PGNMove *)move {
    //[pgnBoard muoviIndietro:move];
    [boardModel muoviIndietro:move];
    [boardModel2 muoviIndietro:move];
    [self switchColor];
}

- (void) visitaAlberoMosse:(PGNMove *)nextMove {
    //PGNMove *tempMoveForRadice = nextMove;
    
    while (nextMove) {
        //NSLog(@"VISITA ALBERO MOSSE =  %@", [nextMove description]);
        
        //NSLog(@"VISITA ALBERO MOSSE PRIMA %d   %d", nextMove.fromSquare, nextMove.toSquare);
        
        
        [self updateNextMove:nextMove];
        [self switchColor];
        
        
        //NSLog(@"Stampo BoardModel2");
        //[boardModel2 muoviPezzo:nextMove.fromSquare :nextMove.toSquare];
        [boardModel2 muoviAvanti:nextMove];
        
        NSString *fen = [boardModel2 fenNotation];
        [nextMove setFen:fen];
        
        //NSLog(@"MOSSA = %@    con FEN = %@", nextMove.fullMove, fen);
        //[pgnGame addMove:nextMove];
        
        //NSLog(@"VISITA ALBERO MOSSE DOPO %d   %d", nextMove.fromSquare, nextMove.toSquare);
        
        
        NSArray *nextMovesArray = [nextMove getNextMoves];
        if (nextMovesArray) {
            //NSLog(@"Numero varianti = %d", nextMovesArray.count);
            //NSLog(@"A questo punto ho %d varianti al plycount %d", nextMovesArray.count, nextMove.plyCount);
            for (int i=0; i<nextMovesArray.count; i++) {
            //for (int i=nextMovesArray.count - 1; i>=0; i--) {
                nextMove = [nextMovesArray objectAtIndex:i];
                [self visitaAlberoMosse:nextMove];
                
                //NSLog(@"In questo momento nextMove è %@", nextMove.description);
                PGNMove *prevMove;
                if (nextMove.endGameMarked) {
                    //NSLog(@"La variante è terminata con nextmove = %@", nextMove.description);
                    nextMove = nil;
                    [self switchColor];
                    [boardModel2 switchColor];
                    
                    //NSLog(@"Eseguo solo un cambio di colore");
                }
                else {
                    prevMove = nextMove;
                    
                    //NSLog(@"Forse qui devo andare indietro di una mossa e raggiungo la mossa %@   -  La mossa eseguita è stata %d - %d", prevMove.description, prevMove.fromSquare, prevMove.toSquare);
                    //NSLog(@"Ora devo eseguire la mossa indietro  %d - %d", prevMove.toSquare, prevMove.fromSquare);
                    [self updateToPreviousMove:prevMove];
                }
                nextMove = nil;
            }
        }
        else {
            //NSLog(@"Forse il cambio variante è qui");
            //NSLog(@"Ho raggiunto plycount = %d", nextMove.plyCount);
            nextMove = nil;
        }
    }
    /*
    if (tempMoveForRadice) {
        NSLog(@"In visita albero mosse nextMove non è nil con valore %@", tempMoveForRadice.description);
        [self updateToPreviousMove:tempMoveForRadice];
    }
    else {
        NSLog(@"In visita albero mosse nextMove è nil");
    }*/
}

- (void) switchColor {
    if ([color isEqualToString:@"w"]) {
        color = @"b";
        colorByte = 1;
    }
    else {
        color = @"w";
        colorByte = -1;
    }
}

- (void) switchColor:(NSString *)moveColor  {
    if ([moveColor isEqualToString:@"w"]) {
        color = @"w";
        colorByte = -1;
    }
    else {
        color = @"b";
        colorByte = 1;
    }
}

- (NSString *) shortPieceToString:(short)shortPiece {
    switch (shortPiece) {
        case 1:
            return @"bp";
            break;
        case 2:
            return @"bn";
            break;
        case 3:
            return @"bb";
            break;
        case 4:
            return @"br";
            break;
        case 5:
            return @"bq";
            break;
        case -1:
            return @"wp";
            break;
        case -2:
            return @"wn";
            break;
        case -3:
            return @"wb";
            break;
        case -4:
            return @"wr";
            break;
        case -5:
            return @"wq";
            break;
        default:
            break;
    }
    return @"em";
}

- (BOOL) validateMove:(PGNMove *)move {
    NSString *strippedMove = [move move];
    if ([move isCastle]) {
        return YES;
    }
    else if ([move endGameMarked]) {
        return YES;
    }
    else if ([strippedMove length] == 2) {
        
    }
    return YES;
}

- (void) updateNextMove:(PGNMove *)move {
    
    //NSLog(@"START UPDATE NEXT MOVE");
    
    NSString *strippedMove = [move move];
    NSUInteger matchPattern = 0;
    
    //NSLog(@"MOSSA DA ANALIZZARE IN UPDATE_NEXT_MOVE = %@", strippedMove);
    
    if ([strippedMove isEqualToString:@"XXX"]) {
        //NSLog(@"SALTO A PIE PARI");
        return;
    }
    
    
    
    if (move.isCastle) {
        if (move.kingSideCastle) {
            if ([move.color isEqualToString:@"w"]) { //Arrocco corto bianco
                //[board replaceObjectAtIndex:6 withObject:[board objectAtIndex:4]];
                //[board replaceObjectAtIndex:5 withObject:[board objectAtIndex:7]];
                //[board replaceObjectAtIndex:4 withObject:[NSNumber numberWithShort:empty]];
                //[board replaceObjectAtIndex:7 withObject:[NSNumber numberWithShort:empty]];
                
                //[pgnBoard replaceContentOfsquare:6 :4];
                //[pgnBoard replaceContentOfsquare:5 :7];
                //[pgnBoard emptySquare:4];
                //[pgnBoard emptySquare:7];
                [boardModel replaceContentOfSquare:6 :4];
                [boardModel replaceContentOfSquare:5 :7];
                [boardModel emptySquare:4];
                [boardModel emptySquare:7];
                
                [move setFromSquare:4];
                [move setToSquare:6];
            }
            else { //Arrocco Corto nero
                //[board replaceObjectAtIndex:62 withObject:[board objectAtIndex:60]];
                //[board replaceObjectAtIndex:61 withObject:[board objectAtIndex:63]];
                //[board replaceObjectAtIndex:60 withObject:[NSNumber numberWithShort:empty]];
                //[board replaceObjectAtIndex:63 withObject:[NSNumber numberWithShort:empty]];
                
                //[pgnBoard replaceContentOfsquare:62 :60];
                //[pgnBoard replaceContentOfsquare:61 :63];
                //[pgnBoard emptySquare:60];
                //[pgnBoard emptySquare:63];
                
                [boardModel replaceContentOfSquare:62 :60];
                [boardModel replaceContentOfSquare:61 :63];
                [boardModel emptySquare:60];
                [boardModel emptySquare:63];
                
                [move setFromSquare:60];
                [move setToSquare:62];
            }
        }
        else {
            if ([move.color isEqualToString:@"w"]) {//Arrocco lungo Bianco
                //[board replaceObjectAtIndex:2 withObject:[board objectAtIndex:4]];
                //[board replaceObjectAtIndex:3 withObject:[board objectAtIndex:0]];
                //[board replaceObjectAtIndex:4 withObject:[NSNumber numberWithShort:empty]];
                //[board replaceObjectAtIndex:0 withObject:[NSNumber numberWithShort:empty]];
                
                //[pgnBoard replaceContentOfsquare:2 :4];
                //[pgnBoard replaceContentOfsquare:3 :0];
                //[pgnBoard emptySquare:4];
                //[pgnBoard emptySquare:0];

                [boardModel replaceContentOfSquare:2 :4];
                [boardModel replaceContentOfSquare:3 :0];
                [boardModel emptySquare:4];
                [boardModel emptySquare:0];
                
                [move setFromSquare:4];
                [move setToSquare:2];
            }
            else { //Arrocco lungo Nero
                //[board replaceObjectAtIndex:58 withObject:[board objectAtIndex:60]];
                //[board replaceObjectAtIndex:59 withObject:[board objectAtIndex:56]];
                //[board replaceObjectAtIndex:60 withObject:[NSNumber numberWithShort:empty]];
                //[board replaceObjectAtIndex:56 withObject:[NSNumber numberWithShort:empty]];
                
                //[pgnBoard replaceContentOfsquare:58 :60];
                //[pgnBoard replaceContentOfsquare:59 :56];
                //[pgnBoard emptySquare:60];
                //[pgnBoard emptySquare:56];

                [boardModel replaceContentOfSquare:58 :60];
                [boardModel replaceContentOfSquare:59 :56];
                [boardModel emptySquare:60];
                [boardModel emptySquare:56];
                
                [move setFromSquare:60];
                [move setToSquare:58];
            }
        }
    }
    else if (move.endGameMarked) {
        //Gestione Risultato
    }
    else {
        switch ([strippedMove length]) {
            case MOVE_TYPE_1_LENGTH:
                //NSLog(@"GESTISCO MOSSA TIPO 1");
                //Gestisci mosse lunghezza Tipo 1
                [self handleMoveType1:move :strippedMove :color];
                break;
            case MOVE_TYPE_2_LENGTH:
                //NSLog(@"GESTISCO MOSSA TIPO 2");
                //Gestisci mosse lunghezza Tipo 2
                //NSLog(@"Devo fare il match  di %@ con pattern %@   match ora vale %d", strippedMove, pattern1, matchPattern);
                matchPattern = [regexPattern1 numberOfMatchesInString:strippedMove options:0 range:NSMakeRange(0, [strippedMove length])];
                //NSLog(@"Ora match vale %d", matchPattern);
                if (matchPattern > 0) {
                    //NSLog(@"La mossa %@ è una mossa di pezzo", strippedMove);
                    [self handleMoveType2:move :strippedMove :color];
                }
                else {
                    matchPattern = [regexPattern2 numberOfMatchesInString:strippedMove options:0 range:NSMakeRange(0, [strippedMove length])];
                    if (matchPattern > 0) {
                        //NSLog(@"La mossa %@ è una mossa di pedone", strippedMove);
                        [self handleMoveType5:move :strippedMove :color];
                    }
                }
                break;
            case MOVE_TYPE_3_LENGTH:
                //NSLog(@"GESTISCO MOSSA TIPO 3");
                //Gestisci mosse lunghezza Tipo 3
                matchPattern = [regexPattern3 numberOfMatchesInString:strippedMove options:0 range:NSMakeRange(0, [strippedMove length])];
                if (matchPattern > 0) {
                    [self handleMoveType3:move :strippedMove :color];
                }
                else if ([regexPattern4 numberOfMatchesInString:strippedMove options:0 range:NSMakeRange(0, [strippedMove length])] > 0) {
                    [self handleMoveType6:move :strippedMove :color];
                }
                break;
            case MOVE_TYPE_4_LENGTH:
                //NSLog(@"GESTISCO MOSSA TIPO 4");
                //Gestisci mosse lunghezza Tipo 4
                break;
            default:
                break;
        }
        
        
        //NSLog(@"ALLA FINE DELLO SWITCH CI SONO");
        
        
        //Il seguente codice cerca di capire se si è in presenza di una cattura o di una cattura en passant anche in mancanza del simobolo x
        short pezzoCasaDestinazione = [boardModel getPieceAtSquare:move.toSquare];
        if (pezzoCasaDestinazione == 0) {
            //NSLog(@"%@ ********************QUESTA MOSSA NON È UNA CATTURA MA POTREBBE ESSERE UNA PRESA AL VARCO: %@", move.fullMove, strippedMove);
            NSUInteger *matchEnPassant = [regexPattern2 numberOfMatchesInString:strippedMove options:0 range:NSMakeRange(0, [strippedMove length])];
            if ((matchEnPassant > 0) && (strippedMove.length == 3)) {
                //NSLog(@"Potrebbe essere una presa en passant");
                const char *strippedMoveChar =  [strippedMove UTF8String];
                short toColumn = [self getColumnFromLetter:strippedMoveChar[1]];
                short toRow = [self getRowFromLetter:strippedMoveChar[2]];
                short fromColumn = [self getColumnFromLetter:strippedMoveChar[0]];
                short pezzo = (short)(black_pawn * colorByte);
                short fromRow = [self getPawnVPos:fromColumn :toRow :pezzo];
                short enPassantColumn = toColumn;
                short enPassantRow = toRow - (toRow - fromRow);
                short squareEnPassant = [self getSquareValueFromColumnAndRaw:enPassantColumn :enPassantRow];
                if ([boardModel squareContainsPiece:squareEnPassant :(short)(-1*black_pawn*colorByte)]) {
                    [move setEnPassantCapture:YES];
                    [move setEnPassantPieceSquare:squareEnPassant];
                    //NSLog(@"§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§   SQUARE EN PASSANT:%d",squareEnPassant);
                    //NSLog(@"%@ ********************QUESTA MOSSA È UNA CATTURA EN PASSANT", move.fullMove);
                }
            }
        }
        else {
            //NSLog(@"%@ ********************QUESTA MOSSA È UNA CATTURA", move.fullMove);
            [move setCapture:YES];
        }
        
        
        
        if (move.capture) {
            //short captured = [pgnBoard getPieceAtSquare:move.toSquare];
            short captured = [boardModel getPieceAtSquare:move.toSquare];
            [move setCaptured:[self shortPieceToString:captured]];
            
            
            //NSLog(@"*********************************************CAPTURE = %d", captured);
        }
        
        //short *pzMosso = [pgnBoard getPieceAtSquare:move.fromSquare];
        //[pgnBoard emptySquare:move.fromSquare];
        //[pgnBoard replacePiece:move.toSquare :pzMosso];
        
        
        
        
        
        
        
        
        
        short *pzMosso = [boardModel getPieceAtSquare:move.fromSquare];
        [boardModel emptySquare:move.fromSquare];
        [boardModel replacePiece:move.toSquare :pzMosso];
        

        
        
        
        if (move.enPassantCapture) {
            //NSLog(@"Gestione enPassant con cattura");
            //NSLog(@"Casa enPassant = %d", move.enPassantPieceSquare);
            //[pgnBoard emptySquare:move.enPassantPieceSquare];
            [boardModel emptySquare:move.enPassantPieceSquare];
        }
        
        if (move.promoted) {
            short pp = 0;
            //NSLog(@"Gestione Promozione pedone");
            if ([move.promotion isEqualToString:QUEEN]) {
                //NSLog(@"Promozione del pedone a Donna");
                pp = (short)black_queen*colorByte;
            }
            else if ([move.promotion isEqualToString:ROOK]) {
                //NSLog(@"Promozione del pedone a Torre");
                pp = (short)black_rook*colorByte;
            }
            else if ([move.promotion isEqualToString:BISHOP]) {
                //NSLog(@"Promozione del Pedone ad Alfiere");
                pp = (short)black_bishop*colorByte;
            }
            else if ([move.promotion isEqualToString:KNIGHT]) {
                //NSLog(@"Promozione del pedone a Cavallo");
                pp = (short)black_knight*colorByte;
            }
            //[pgnBoard replacePiece:move.toSquare :pp];
            [boardModel replacePiece:move.toSquare :pp];
        }
    }
    
    
    //[pgnBoard printPosition];
    //NSLog(@"Stampo BoardModel da UpdateNextMove");
    //NSLog(@"END UPDATE NEXT MOVE");
    //[boardModel printPosition];
}

- (void) handleMoveType1:(PGNMove *)move :(NSString *)strippedMove :(NSString *)col {
    
    //NSLog(@"HandleMoveType1   Devo gestire la mossa %@", strippedMove);
    /*
    short colorByte;
    if ([col isEqualToString:@"w"]) {
        colorByte = -1;
    }
    else {
        colorByte = 1;
    }*/
    
    const char *strippedMoveChar =  [strippedMove UTF8String];
    short column = [self getColumnFromLetter:strippedMoveChar[0]];
    int row = [self getRowFromLetter:strippedMoveChar[1]];
    
    short toSquare = [self getSquareValueFromColumnAndRaw:column :row];
    
    short pezzo = (short)(black_pawn * colorByte);
    //char let = 'a';
    short fromSquare = [self getPawnInitialPos:column :row :pezzo];
    //NSLog(@"Colonna = %d", column);
    //NSLog(@"Riga = %d", row);
    //NSLog(@"Pezzo = %d", pezzo);
    //NSLog(@"Carattere a = %d", let);
    //NSLog(@"La casa di partenza è %d", fromSquare);
    //NSLog(@"La casa di arrivo è %d", toSquare);
    
    short fromColumn = [self getColumnFromSquare:fromSquare];
    short fromRow = [self getRowFromSquare:fromSquare];
    
    //NSLog(@"CONTROLLO SE RE SOTTO SCACCO DOPO MOSSA DI PEDONE");
    //if ([self isKingInCheckAfterMove:fromColumn :fromRow :row :column]) {
    //    NSLog(@"Dopo la mossa di pedone il re è sotto scacco");
    //    return;
    //}
    
    if ([self ilReSiTrovaSottoScacco:fromRow :fromColumn :row :column]) {
        //NSLog(@"Dopo la mossa di pedone il re è sotto scacco");
        return;
    }
    
    [move setFromSquare:fromSquare];
    [move setToSquare:toSquare];
}

- (void) handleMoveType2:(PGNMove *)move :(NSString *)strippedMove :(NSString *)col {
    /*
    short colorByte;
    if ([col isEqualToString:@"w"]) {
        colorByte = -1;
    }
    else {
        colorByte = 1;
    }*/
    
    //NSLog(@"GESTIONE MOSSA TIPO 2");
    
    short pezzo = white_pawn;
    const char *strippedMoveChar =  [strippedMove UTF8String];
    short toColumn = [self getColumnFromLetter:strippedMoveChar[1]];
    short toRow = [self getRowFromLetter:strippedMoveChar[2]];
    
    short fromSquare = -1;
    short toSquare = -1;
    NSString *pezzoMosso = [strippedMove substringToIndex:1];
    if ([pezzoMosso isEqualToString:KNIGHT]) {
        //NSLog(@"Devo gestire il movimento del Cavallo");
        pezzo = (short)(black_knight * colorByte);
        NSArray *caseOrigine = [self getSingleMovePiecePos:toColumn :toRow :pezzo :knightSearchPath];
        if (caseOrigine.count == 1) {
            fromSquare = [[caseOrigine objectAtIndex:0] shortValue];
            toSquare = [self getSquareValueFromColumnAndRaw:toColumn :toRow];
        }
        else {
            //NSLog(@"Case origine del cavallo = %d", caseOrigine.count);
            return;
        }
        //NSLog(@"Cavallo Mosso da %d a %d", fromSquare, toSquare);
    }
    else if ([pezzoMosso isEqualToString:BISHOP]) {
        pezzo = (short)(black_bishop * colorByte);
        //NSLog(@"Devo gestire il movimento dell'Alfiere");
        //NSLog(@"Mossa Alfiere = %@", strippedMove);
        //NSLog(@"HandleMoveType2 Alfiere     Colonna = %d    Riga = %d   Pezzo = %d", toColumn, toRow, pezzo);
        NSArray *caseOrigine = [self getMultiMovePiecePos:toColumn :toRow :pezzo :bishopSearchPath];
        if (caseOrigine) {
            if (caseOrigine.count == 1) {
                fromSquare = [[caseOrigine objectAtIndex:0] shortValue];
                toSquare = [self getSquareValueFromColumnAndRaw:toColumn :toRow];
                //NSLog(@"Alfiere Mosso da %d a %d", fromSquare, toSquare);
            }
        }
        else {
            //NSLog(@"Case origine dell' Alfiere = %d", caseOrigine.count);
            return;
        }
        
    }
    else if ([pezzoMosso isEqualToString:ROOK]) {
        //NSLog(@"Devo gestire il movimento della Torre");
        pezzo = (short)(black_rook * colorByte);
        NSArray *caseOrigine = [self getMultiMovePiecePos:toColumn :toRow :pezzo :rookSearchPath];
        if (caseOrigine) {
            if (caseOrigine.count == 1) {
                fromSquare = [[caseOrigine objectAtIndex:0] shortValue];
                toSquare = [self getSquareValueFromColumnAndRaw:toColumn :toRow];
                //NSLog(@"Torre Mossa da %d a %d", fromSquare, toSquare);
            }
        }
        else {
            //NSLog(@"Case origine Torre = nil");
            return;
        }
    }
    else if ([pezzoMosso isEqualToString:QUEEN]) {
        //NSLog(@"Devo gestire il movimento della Donna");
        pezzo = (short)(black_queen * colorByte);
        NSArray *caseOrigine = [self getMultiMovePiecePos:toColumn :toRow :pezzo :queenAndKingSearchPath];
        if (caseOrigine) {
            if (caseOrigine.count == 1) {
                fromSquare = [[caseOrigine objectAtIndex:0] shortValue];
                toSquare = [self getSquareValueFromColumnAndRaw:toColumn :toRow];
                //NSLog(@"Donna Mossa da %d a %d", fromSquare, toSquare);
            }
        }
        else {
            //NSLog(@"Case origine donna = nil");
            return;
        }
    }
    else if ([pezzoMosso isEqualToString:KING]) {
        //NSLog(@"Devo gestire il movimento del Re");
        pezzo = (short)(black_king * colorByte);
        NSArray *caseOrigine = [self getSingleMovePiecePos:toColumn :toRow :pezzo :queenAndKingSearchPath];
        if (caseOrigine) {
            fromSquare = [[caseOrigine objectAtIndex:0] shortValue];
            toSquare = [self getSquareValueFromColumnAndRaw:toColumn :toRow];
            //NSLog(@"Re Mosso da %d a %d", fromSquare, toSquare);
        }
    }
    else if ([pezzoMosso isEqualToString:PAWN]) {
        //NSLog(@"Devo gestire il movimento del pedone  %@", strippedMove);
        pezzo = (short)(black_pawn * colorByte);
        fromSquare = [self getPawnInitialPos:toColumn :toRow :pezzo];
        toSquare = [self getSquareValueFromColumnAndRaw:toColumn :toRow];
        //NSLog(@"HandleMoveType2  Pedone   FromSquare = %d    ToSquare = %d", fromSquare, toSquare);
    }
    else {
        //NSLog(@"ERRORE nella mossa!!!");
    }
    
    [move setFromSquare:fromSquare];
    [move setToSquare:toSquare];
}

- (void) handleMoveType3:(PGNMove *)move :(NSString *)strippedMove :(NSString *)col {
    //NSLog(@"HandleMoveType3   Devo gestire la mossa %@", strippedMove);
    /*
    short colorByte;
    if ([col isEqualToString:@"w"]) {
        colorByte = -1;
    }
    else {
        colorByte = 1;
    }*/
    
    const char *strippedMoveChar =  [strippedMove UTF8String];
    short toColumn = [self getColumnFromLetter:strippedMoveChar[2]];
    short toRow = [self getRowFromLetter:strippedMoveChar[3]];
    short fromColumn = [self getColumnFromLetter:strippedMoveChar[1]];
    short fromRow = -1;
    short pezzo = white_pawn;
    
    NSString *pezzoMosso = [strippedMove substringToIndex:1];
    if ([pezzoMosso isEqualToString:KNIGHT]) {
        pezzo = (short)(black_knight * colorByte);
        fromRow = [self getSingleMovePieceVPos:toColumn :toRow :fromColumn :pezzo :knightSearchPath];
        //NSLog(@"HandleMoveType3 FromRow = %d", fromRow);
    }
    else if ([pezzoMosso isEqualToString:ROOK]) {
        pezzo = (short)(black_rook * colorByte);
        fromRow = [self getMultiMovePieceVPos:toColumn :toRow :fromColumn :pezzo :rookSearchPath];
    }
    else if ([pezzoMosso isEqualToString:BISHOP]) {
        //gestione di questo tipo di mossa con gli Alfieri anche se è molto improbabile (solo in caso di promozione)
        pezzo = (short)(black_bishop * colorByte);
        fromRow = [self getMultiMovePieceVPos:toColumn :toRow :fromColumn :pezzo :bishopSearchPath];
    }
    else if ([pezzoMosso isEqualToString:QUEEN]) {
        //gestione di questo tipo di mossa con la donna anche se è molto improbabile (solo in caso di promozione)
        pezzo = (short)(black_queen * colorByte);
        fromRow = [self getMultiMovePieceVPos:toColumn :toRow :fromColumn :pezzo :queenAndKingSearchPath];
    }
    else if ([pezzoMosso isEqualToString:KING]) {
        //gestione di questo tipo di mossa con il Re non necessaria;
    }
    
    //NSLog(@"HandleMoveType3  ToColumn=%d     ToRow=%d   FromColumn = %d    FromRow = %d", toColumn, toRow, fromColumn, fromRow);
    
    if (fromRow == -1) {
        return;
    }
    short toSquare = [self getSquareValueFromColumnAndRaw:toColumn :toRow];
    short fromSquare = [self getSquareValueFromColumnAndRaw:fromColumn :fromRow];
    [move setFromSquare:fromSquare];
    [move setToSquare:toSquare];
}

- (void) handleMoveType5:(PGNMove *)move :(NSString *)strippedMove :(NSString *)col {
    //NSLog(@"HandleMoveType5   Devo gestire la mossa %@", strippedMove);
    /*
    short colorByte;
    if ([col isEqualToString:@"w"]) {
        colorByte = -1;
    }
    else {
        colorByte = 1;
    }*/
    
    const char *strippedMoveChar =  [strippedMove UTF8String];
    short toColumn = [self getColumnFromLetter:strippedMoveChar[1]];
    short toRow = [self getRowFromLetter:strippedMoveChar[2]];
    short fromColumn = [self getColumnFromLetter:strippedMoveChar[0]];
    short pezzo = (short)(black_pawn * colorByte);
    short fromRow = [self getPawnVPos:fromColumn :toRow :pezzo];
    //short fromRow = [self getPawnInitialPos:fromColumn :toRow :pezzo];
    
    //NSLog(@"HandleMoveType5  ToColumn=%d     ToRow=%d   FromColumn = %d    FromRow = %d", toColumn, toRow, fromColumn, fromRow);
    
    if (fromRow == -1) {
        //NSLog(@"Attenzione fromRow = -1");
        return;
    }
    
    if (move.capture) {
        short toSquare = [self getSquareValueFromColumnAndRaw:toColumn :toRow];
        //if ([pgnBoard squareIsEmpty:toSquare]) {
        if ([boardModel squareIsEmpty:toSquare]) {
            short enPassantColumn = toColumn;
            short enPassantRow = toRow - (toRow - fromRow);
            short squareEnPassant = [self getSquareValueFromColumnAndRaw:enPassantColumn :enPassantRow];
            //if ([pgnBoard squareContainsPiece:squareEnPassant :(short)(-1*black_pawn*colorByte)]) {
            if ([boardModel squareContainsPiece:squareEnPassant :(short)(-1*black_pawn*colorByte)]) {
                [move setEnPassantCapture:YES];
                [move setEnPassantPieceSquare:squareEnPassant];
            }
        }
    }
    short fromSquare = [self getSquareValueFromColumnAndRaw:fromColumn :fromRow];
    [move setFromSquare:fromSquare];
    short toSquare = [self getSquareValueFromColumnAndRaw:toColumn :toRow];
    [move setToSquare:toSquare];
    
    
    //NSLog(@"HandleMoveType5    Mossa da %d a %d", move.fromSquare, move.toSquare);
}

- (void) handleMoveType6:(PGNMove *)move :(NSString *)strippedMove :(NSString *)col {
    //NSLog(@"HandleMoveType6   Devo gestire la mossa %@", strippedMove);
    /*
    short colorByte;
    if ([col isEqualToString:@"w"]) {
        colorByte = -1;
    }
    else {
        colorByte = 1;
    }*/
    
    short pezzo = white_pawn;
    const char *strippedMoveChar =  [strippedMove UTF8String];
    short toColumn = [self getColumnFromLetter:strippedMoveChar[2]];
    short toRow = [self getRowFromLetter:strippedMoveChar[3]];
    short fromRow = [self getRowFromLetter:strippedMoveChar[1]];
    short fromColumn = -1;
    NSString *pezzoMosso = [strippedMove substringToIndex:1];
    if ([pezzoMosso isEqualToString:KNIGHT]) {
        //NSLog(@"HandleMoveType6 ToColumn = %d, ToRow= %d, FromRow = %d,  FromColumn = %d", toColumn, toRow, fromRow, fromColumn);
        pezzo = (short)(black_knight * colorByte);
        fromColumn = [self getSingleMovePieceHPos:toColumn :toRow :fromRow :pezzo :knightSearchPath];
        //NSLog(@"HandleMoveType6 ToColumn = %d, ToRow= %d, FromRow = %d,  FromColumn = %d", toColumn, toRow, fromRow, fromColumn);
    }
    else if ([pezzoMosso isEqualToString:ROOK]) {
        //NSLog(@"HandleMoveType6 ToColumn = %d, ToRow= %d, FromRow = %d,  FromColumn = %d", toColumn, toRow, fromRow, fromColumn);
        pezzo = (short)(black_rook * colorByte);
        fromColumn = [self getMultiMovePieceHPos:toColumn :toRow :fromRow :pezzo :rookSearchPath];
        //NSLog(@"HandleMoveType6 ToColumn = %d, ToRow= %d, FromRow = %d,  FromColumn = %d", toColumn, toRow, fromRow, fromColumn);
    }
    else if ([pezzoMosso isEqualToString:BISHOP]) {
        //gestione di questo tipo di mossa con gli Alfieri anche se è molto improbabile (solo in caso di promozione)
        //NSLog(@"HandleMoveType6 ToColumn = %d, ToRow= %d, FromRow = %d,  FromColumn = %d", toColumn, toRow, fromRow, fromColumn);
        pezzo = (short)(black_bishop * colorByte);
        fromColumn = [self getMultiMovePieceHPos:toColumn :toRow :fromRow :pezzo :bishopSearchPath];
        //NSLog(@"HandleMoveType6 ToColumn = %d, ToRow= %d, FromRow = %d,  FromColumn = %d", toColumn, toRow, fromRow, fromColumn);
    }
    else if ([pezzoMosso isEqualToString:QUEEN]) {
        //gestione di questo tipo di mossa con la donna anche se è molto improbabile (solo in caso di promozione)
        pezzo = (short)(black_queen * colorByte);
        fromColumn = [self getMultiMovePieceHPos:toColumn :toRow :fromRow :pezzo :queenAndKingSearchPath];
        //NSLog(@"HandleMoveType6 ToColumn = %d, ToRow= %d, FromRow = %d,  FromColumn = %d", toColumn, toRow, fromRow, fromColumn);
    }
    else if ([pezzoMosso isEqualToString:KING]) {
        //gestione di questo tipo di mossa con il Re non necessaria;
    }
    if (fromColumn == -1) {
        return;
    }
    short toSquare = [self getSquareValueFromColumnAndRaw:toColumn :toRow];
    short fromSquare = [self getSquareValueFromColumnAndRaw:fromColumn :fromRow];
    [move setFromSquare:fromSquare];
    [move setToSquare:toSquare];
}

- (NSArray *) getSingleMovePiecePos:(short)toColumn :(short)toRow :(short)pezzo :(NSArray *)moveData {
    //NSLog(@"Pezzo = %d", pezzo);
    //short casaArrivo = [self getSquareValueFromColumnAndRaw:toColumn :toRow];
    //NSLog(@"Casa Arrivo = %d", casaArrivo);
    NSMutableArray *caseOrigine = [[NSMutableArray alloc] init];
    for (PGNSquare *pgnSquare in moveData) {
        short column = toColumn + pgnSquare.column;
        short row = toRow + pgnSquare.row;
        if ((column >= 0) && (column <= 7) && (row >= 0) && (row <= 7)) {
            short casaOrigine = [self getSquareValueFromColumnAndRaw:column :row];
            //NSLog(@"Trovato pezzo in casa %d", casaOrigine);
            //if ([pgnBoard squareContainsPiece:casaOrigine :pezzo]) {
            if ([boardModel squareContainsPiece:casaOrigine :pezzo]) {
                //NSLog(@"Trovato pezzo in casa %d", casaOrigine);
                if (abs(pezzo) != black_king) {
                    //Devo valutare se il re è sotto scacco
                    //if ([self isKingInCheckAfterMove:row :column :toRow :toColumn]) {
                    //    continue;
                    //}
                    if ([self ilReSiTrovaSottoScacco:row :column :toRow :toColumn]) {
                        continue;
                    }
                }
                [caseOrigine addObject:[NSNumber numberWithShort:casaOrigine]];
                return caseOrigine;
            }
        }
    }
    return caseOrigine;
}

- (short) getSingleMovePieceVPos:(short)toColumn :(short)toRow :(short)fromColumn :(short)pezzo :(NSArray *)moveData {
    for (PGNSquare *pgnSquare in moveData) {
        short column = toColumn + pgnSquare.column;
        short row = toRow + pgnSquare.row;
        if ((column >= 0) && (column <= 7) && (row >= 0) && (row <= 7)) {
            short casaOrigine = [self getSquareValueFromColumnAndRaw:column :row];
            //if (([pgnBoard squareContainsPiece:casaOrigine :pezzo]) && (column == fromColumn)) {
            if (([boardModel squareContainsPiece:casaOrigine :pezzo]) && (column == fromColumn)) {
                if (abs(pezzo) != black_king) {
                    //Devo valutare se il re è sotto scacco
                    //if ([self isKingInCheckAfterMove:row :column :toRow :toColumn]) {
                    //    continue;
                    //}
                    if ([self ilReSiTrovaSottoScacco:row :column :toRow :toColumn]) {
                        continue;
                    }
                }
                
                return row;
            }
        }
    }
    return -1;
}

- (short) getSingleMovePieceHPos:(short)toColumn :(short)toRow :(short)fromRow :(short)pezzo :(NSArray *)moveData {
    for (PGNSquare *pgnSquare in moveData) {
        short column = toColumn + pgnSquare.column;
        short row = toRow + pgnSquare.row;
        if ((column >= 0) && (column <= 7) && (row >= 0) && (row <= 7)) {
            short casaOrigine = [self getSquareValueFromColumnAndRaw:column :row];
            //NSLog(@"GetSingleMovePieceHPos      CasaOrigine = %d   Row=%d", casaOrigine, row);
            //if (([pgnBoard squareContainsPiece:casaOrigine :pezzo]) && (row == fromRow)) {
            if (([boardModel squareContainsPiece:casaOrigine :pezzo]) && (row == fromRow)) {
                if (abs(pezzo) != black_king) {
                    //Devo valutare se il re è sotto scacco
                    //if ([self isKingInCheckAfterMove:row :column :toRow :toColumn]) {
                    //    continue;
                    //}
                    if ([self ilReSiTrovaSottoScacco:row :column :toRow :toColumn]) {
                        continue;
                    }
                }
                
                return column;
            }
        }
    }
    return -1;
}

- (NSArray *) getMultiMovePiecePos:(short)toColumn :(short)toRow  :(short)pezzo :(NSArray *)moveData {
    //NSLog(@"getMultiMovepiecePos chiamato");
    //NSLog(@"Movedata contiene %d elementi", moveData.count);
    NSMutableArray *caseOrigine = [[NSMutableArray alloc] init];
    for (PGNSquare *pgnSquare in moveData) {
        NSNumber *numeroCasa = [self getMultiMovePiecePosRecursive:toColumn :toRow :toColumn :toRow :pgnSquare.column :pgnSquare.row :pezzo];
        if (numeroCasa) {
            [caseOrigine addObject:numeroCasa];
            return caseOrigine;
        }
    }
    return nil;
}

- (short) getMultiMovePieceVPos:(short)toColumn :(short)toRow :(short)fromColumn :(short)pezzo :(NSArray *)moveData {
    for (PGNSquare *pgnSquare in moveData) {
        short fromRow = [self getMultiMovePieceVPosRecursive:toColumn :toRow :toColumn :toRow :pgnSquare.column :pgnSquare.row :fromColumn :pezzo];
        if (fromRow != -1) {
            return fromRow;
        }
    }
    return -1;
}

- (short) getMultiMovePieceHPos:(short)toColumn :(short)toRow :(short)fromRow :(short)pezzo :(NSArray *)moveData {
    for (PGNSquare *pgnSquare in moveData) {
        short fromColumn = [self getMultiMovePieceHPosRecursive:toColumn :toRow :toColumn :toRow :pgnSquare.column :pgnSquare.row :fromRow :pezzo];
        if (fromColumn != -1) {
            return fromColumn;
        }
    }
    return -1;
}

- (short) getMultiMovePieceVPosRecursive:(short)originalColumn :(short)originalRow :(short)column :(short)row :(short)columnAdd :(short)rowAdd :(short)fromColumn :(short)pezzo {
    column += columnAdd;
    row += rowAdd;
    
    if ((column >= 0) && (column <= 7) && (row >= 0) && (row <= 7)) {
        short numeroCasa = [self getSquareValueFromColumnAndRaw:column :row];
        //NSLog(@"getMultiMovePieceVPosRecursive:Column = %d     fromColumn = %d     NumeroCasa = %d    Pezzo = %d", column, fromColumn, numeroCasa, pezzo);
        //if (([pgnBoard squareContainsPiece:numeroCasa :pezzo]) && (column == fromColumn)) {
        if (([boardModel squareContainsPiece:numeroCasa :pezzo]) && (column == fromColumn)) {
            
            if (abs(pezzo) != black_king) {
                //Devo valutare se il re è sotto scacco
                //if ([self isKingInCheckAfterMove:row :column :originalRow :originalColumn]) {
                //    return -1;
                //}
                if ([self ilReSiTrovaSottoScacco:row :column :originalRow :originalColumn]) {
                    return -1;
                }
            }
            
            return row;
        }
        //else if (![pgnBoard squareIsEmpty:numeroCasa]) {
        else if (![boardModel squareIsEmpty:numeroCasa]) {
            return -1;
        }
    }
    else {
        return -1;
    }
    return [self getMultiMovePieceVPosRecursive:originalColumn :originalRow :column :row :columnAdd :rowAdd :fromColumn :pezzo];
}

- (short) getMultiMovePieceHPosRecursive:(short)originalColumn :(short)originalRow :(short)column :(short)row :(short)columnAdd :(short)rowAdd :(short)fromRow :(short)pezzo {
    column += columnAdd;
    row += rowAdd;
    if ((column >= 0) && (column <= 7) && (row >= 0) && (row <= 7)) {
        short numeroCasa = [self getSquareValueFromColumnAndRaw:column :row];
        //NSLog(@"getMultiMovePieceHPosRecursive:Column = %d     fromColumn = %d     NumeroCasa = %d    Pezzo = %d", column, fromRow, numeroCasa, pezzo);
        // if (([pgnBoard squareContainsPiece:numeroCasa :pezzo]) && (row == fromRow )) {
        if (([boardModel squareContainsPiece:numeroCasa :pezzo]) && (row == fromRow )) {
            
            if (abs(pezzo) != black_king) {
                //Devo valutare se il re è sotto scacco
                //if ([self isKingInCheckAfterMove:row :column :originalRow :originalColumn]) {
                //    return -1;
                //}
                if ([self ilReSiTrovaSottoScacco:row :column :originalRow :originalColumn]) {
                    return -1;
                }
            }
            
            
            return column;
        }
        //else if (![pgnBoard squareIsEmpty:numeroCasa]) {
        else if (![boardModel squareIsEmpty:numeroCasa]) {
            return -1;
        }
    }
    else {
        return -1;
    }
    return [self getMultiMovePieceHPosRecursive:originalColumn :originalRow :column :row :columnAdd :rowAdd :fromRow :pezzo];
}

- (NSNumber *) getMultiMovePiecePosRecursive:(short)originalColumn :(short)originalRow :(short)column :(short)row :(short)columnAdd :(short)rowAdd :(short)pezzo {
    column += columnAdd;
    row += rowAdd;
    //NSLog(@"getMultiMovepiecePosRecursive chiamato");
    if ((column >= 0) && (column <= 7) && (row >= 0) && (row <= 7)) {
        short numeroCasa = [self getSquareValueFromColumnAndRaw:column :row];
        //NSLog(@"Numero casa intermedio per alfiere = %d", numeroCasa);
        //if ([pgnBoard squareContainsPiece:numeroCasa :pezzo]) {
        if ([boardModel squareContainsPiece:numeroCasa :pezzo]) {
            //NSLog(@"Trovato pezzo in casa %d", numeroCasa);
            if (abs(pezzo) != black_king) {
                //Devo valutare se il re è sotto scacco
                //if ([self isKingInCheckAfterMove:row :column :originalRow :originalColumn]) {
                //    return nil;
                //}
                if ([self ilReSiTrovaSottoScacco:row :column :originalRow :originalColumn]) {
                    return nil;
                }
            }
            return [NSNumber numberWithShort:numeroCasa];
        }
        //else if (![pgnBoard squareIsEmpty:numeroCasa]) {
        else if (![boardModel squareIsEmpty:numeroCasa]) {
            return nil;
        }
    }
    else {
        return nil;
    }
    
    return [self getMultiMovePiecePosRecursive:originalColumn :originalRow :column :row :columnAdd :rowAdd :pezzo];
}


- (short) getPawnInitialPos:(short) columnPos :(short)rowPos :(short)pezzo {
    short casa = 0;
    rowPos = rowPos + pezzo;
    casa = [self getSquareValueFromColumnAndRaw:columnPos :rowPos];
    
    //NSLog(@"getPawninitialPos casa = %d", casa);
    //NSNumber *pz = [pgnBoard getPieceNumberAtSquare:casa];
    NSNumber *pz = [boardModel getPieceNumberAtSquare:casa];
    //NSLog(@"getPawnInitialPos pezzo in casa = %d", pz.shortValue);
    if ([pz shortValue] == pezzo) {
        return casa;
    }
    else {
        rowPos = rowPos + pezzo;
        casa = [self getSquareValueFromColumnAndRaw:columnPos :rowPos];
        //NSNumber *pz = [pgnBoard getPieceNumberAtSquare:casa];
        NSNumber *pz = [boardModel getPieceNumberAtSquare:casa];
        if ([pz shortValue] == pezzo) {
            return casa;
        }
    }
    return -1;
}

- (short) getPawnVPos:(short)column :(short)row :(short)pezzo {
    short casa = [self getSquareValueFromColumnAndRaw:column :row + pezzo];
    //NSNumber *pz = [pgnBoard getPieceNumberAtSquare:casa];
    NSNumber *pz = [boardModel getPieceNumberAtSquare:casa];
    if ([pz shortValue] == pezzo) {
        return row + pezzo;
    }
    else {
        casa = [self getSquareValueFromColumnAndRaw:column :row + 2*pezzo];
        //pz = [pgnBoard getPieceNumberAtSquare:casa];
        pz = [boardModel getPieceNumberAtSquare:casa];
        if ([pz shortValue] == pezzo) {
            return row + 2*pezzo;
        }
    }
    return -1;
}

- (short) getSquareValueFromColumnAndRaw:(short)column :(short)row {
    short squareValue = 0;
    for (int r=0; r<=row; r++) {
        squareValue = column + r*8;
    }
    return squareValue;
}

- (short) getColumnFromLetter:(char)letter {
    return letter - 'a';
}

- (short) getRowFromLetter:(char)letter {
    return letter - '1';
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


- (BOOL) ilReSiTrovaSottoScacco:(short)hPos :(short)vPos :(short)tohPos :(short)tovPos {
    short king = (short)(black_king * colorByte);
    short kinghPos = -1;
    short kingvPos = -1;
    
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            //if ([pgnBoard getPieceAtSquare:j :i] == king) {
            if ([boardModel getPieceAtSquare:j :i] == king) {
                kinghPos = j;
                kingvPos = i;
                break;
            }
        }
    }
    
    if (kinghPos == -1 || kingvPos == -1) {
        return NO;
    }
    
    //NSLog(@"VEDO SE IL RE E SOTTO SCACCO DI ALFIERE");
    short piece = (short)(-1 * colorByte * black_bishop);
    for (PGNSquare *pgnSquare in bishopSearchPath) {
        if ([self ilReSiTrovaSottoScaccoRecursive:piece :kinghPos :kingvPos :hPos :vPos :tohPos :tovPos :pgnSquare.row :pgnSquare.column]) {
            return YES;
        }
    }
    
    
    //NSLog(@"VEDO SE IL RE E SOTTO SCACCO DI TORRE");
    piece = (short)(-1 * colorByte * black_rook);
    for (PGNSquare *pgnSquare in rookSearchPath) {
        if ([self ilReSiTrovaSottoScaccoRecursive:piece :kinghPos :kingvPos :hPos :vPos :tohPos :tovPos :pgnSquare.row :pgnSquare.column]) {
            return YES;
        }
    }
    
    
    
    //NSLog(@"VEDO SE IL RE E SOTTO SCACCO DI DONNA");
    piece = (short)(-1 * colorByte * black_queen);
    for (PGNSquare *pgnSquare in queenAndKingSearchPath) {
        if ([self ilReSiTrovaSottoScaccoRecursive:piece :kinghPos :kingvPos :hPos :vPos :tohPos :tovPos :pgnSquare.row :pgnSquare.column]) {
            return YES;
        }
    }
    
    
    return NO;
}

- (BOOL) ilReSiTrovaSottoScaccoRecursive:(short)piece :(short)hPos :(short)vPos :(short)skiphPos :(short)skipvPos :(short)tohPos :(short)tovPos :(short)hAdd :(short)vAdd {
    hPos += hAdd;
    vPos += vAdd;
    
    if (hPos < 0 || hPos > 7 || vPos < 0 || vPos > 7 || (hPos == tohPos && vPos == tovPos)) {
        return NO;
    }
    //if ([pgnBoard getPieceAtSquare:hPos :vPos] == empty  || (skiphPos == hPos && skipvPos == vPos)) {
    if ([boardModel getPieceAtSquare:hPos :vPos] == empty  || (skiphPos == hPos && skipvPos == vPos)) {
        return [self ilReSiTrovaSottoScaccoRecursive:piece :hPos :vPos :skiphPos :skipvPos :tohPos :tovPos :hAdd :vAdd];
    }
    
    //return [pgnBoard getPieceAtSquare:hPos :vPos] == piece;
    return [boardModel getPieceAtSquare:hPos :vPos] == piece;
}


- (void) setFenPosition:(NSString *)fenPosition {
    [boardModel setFenNotation:fenPosition];
    [boardModel2 setFenNotation:fenPosition];
    [boardModel setWhiteHasToMove:YES];
    [boardModel2 setWhiteHasToMove:YES];
    if ([boardModel whiteHasToMove]) {
        color = @"w";
    }
    else {
        color = @"b";
    }
}

/*
- (BOOL) isKingInCheckAfterMove:(short)column :(short)row :(short)toRow :(short)toColumn {

    NSLog(@"DEVO VEDERE SE IL RE SOTTO SCACCO");
    
    short king = (short)(black_king * colorByte);
    short kinghPos = -1;
    short kingvPos = -1;
    
    NSLog(@"KING = %d", king);
    
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            if ([pgnBoard getPieceAtSquare:i :j] == king) {
                kinghPos = i;
                kingvPos = j;
                break;
            }
        }
    }
    
    NSLog(@"King Pos = %d  %d", kingvPos, kinghPos);
    
    if (kinghPos == -1 || kingvPos == -1) {
        return NO;
    }
    
    
    NSLog(@"VEDO SE IL RE E SOTTO SCACCO DI ALFIERE");
    short piece = (short)(-1 * colorByte * black_bishop);
    NSLog(@"PEZZO = %d", piece);
    for (int i = 0; i < bishopSearchPath.count; i++) {
        PGNSquare *square = [bishopSearchPath objectAtIndex:i];
        if ([self isKingInCheckAfterMoveRec :piece :kinghPos :kingvPos :row :column :toRow :toColumn :square.column :square.row]) {
            NSLog(@"IL RE E SOTTO SCACCO DI ALFIERE");
            return YES;
        }
    }
    NSLog(@"IL RE NON E SOTTO SCACCO DI ALFIERE");
    
    NSLog(@"VEDO SE IL RE E SOTTO SCACCO DI TORRE");
    piece = (short)(-1 * colorByte * black_rook);
    NSLog(@"PEZZO = %d", piece);
    for (int i = 0; i < rookSearchPath.count; i++) {
        PGNSquare *square = [rookSearchPath objectAtIndex:i];
        if ([self isKingInCheckAfterMoveRec :piece :kinghPos :kingvPos :row :column :toRow :toColumn :square.column :square.row]) {
            NSLog(@"IL RE E SOTTO SCACCO DI TORRE");
            return YES;
        }
    }
    NSLog(@"IL RE NON E SOTTO SCACCO DI TORRE");
    
    NSLog(@"VEDO SE IL RE E SOTTO SCACCO DI DONNA");
    piece = (short)(-1 * colorByte * black_queen);
    for (int i = 0; i < queenAndKingSearchPath.count; i++) {
        PGNSquare *square = [queenAndKingSearchPath objectAtIndex:i];
        if ([self isKingInCheckAfterMoveRec :piece :kinghPos :kingvPos :row :column :toRow :toColumn :square.column :square.row]) {
            NSLog(@"IL RE E SOTTO SCACCO DI DONNA");
            return YES;
        }
    }
    NSLog(@"IL RE NON E SOTTO SCACCO DI DONNA");
    
    return NO;
}
*/

/*
- (BOOL) isKingInCheckAfterMoveRec:(short)piece :(short)hPos :(short)vPos :(short)skiphPos :(short)skipvPos :(short)tohPos :(short)tovPos :(short)hAdd :(short)vAdd {
    
    hPos += hAdd;
    vPos += vAdd;
    
    if (hPos < 0 || hPos > 7 || vPos < 0 || vPos > 7 || (hPos == tohPos && vPos == tovPos)) {
        return NO;
    }
    
    if ([pgnBoard getPieceAtSquare:hPos :vPos] == empty  || (skiphPos == hPos && skipvPos == vPos)) {
        return [self isKingInCheckAfterMoveRec :piece :hPos :vPos :skiphPos :skipvPos :tohPos :tovPos :hAdd :vAdd];
    }
    
    return [pgnBoard getPieceAtSquare:hPos :vPos] == piece;
}
*/

//- (void) createDefaultBoard {
    /*
    board = [[NSMutableArray alloc] initWithCapacity:64];
    
    for (int i=0; i < 64; i++) {
        [board insertObject:[NSNumber numberWithShort:empty] atIndex:i];
    }
    
    
    [board replaceObjectAtIndex:0 withObject:[NSNumber numberWithShort:white_rook]];
	[board replaceObjectAtIndex:1 withObject:[NSNumber numberWithShort:white_knight]];
	[board replaceObjectAtIndex:2 withObject:[NSNumber numberWithShort:white_bishop]];
	[board replaceObjectAtIndex:3 withObject:[NSNumber numberWithShort:white_queen]];
	[board replaceObjectAtIndex:4 withObject:[NSNumber numberWithShort:white_king]];
	[board replaceObjectAtIndex:5 withObject:[NSNumber numberWithShort:white_bishop]];
	[board replaceObjectAtIndex:6 withObject:[NSNumber numberWithShort:white_knight]];
	[board replaceObjectAtIndex:7 withObject:[NSNumber numberWithShort:white_rook]];
    
    for (int i=8; i < 16; i++) {
		[board replaceObjectAtIndex:i withObject:[NSNumber numberWithShort:white_pawn]];
	}
    
    for (int i=48; i < 56; i++) {
		[board replaceObjectAtIndex:i withObject:[NSNumber numberWithShort:black_pawn]];
	}
    
    [board replaceObjectAtIndex:56 withObject:[NSNumber numberWithShort:black_rook]];
	[board replaceObjectAtIndex:57 withObject:[NSNumber numberWithShort:black_knight]];
	[board replaceObjectAtIndex:58 withObject:[NSNumber numberWithShort:black_bishop]];
	[board replaceObjectAtIndex:59 withObject:[NSNumber numberWithShort:black_queen]];
	[board replaceObjectAtIndex:60 withObject:[NSNumber numberWithShort:black_king]];
	[board replaceObjectAtIndex:61 withObject:[NSNumber numberWithShort:black_bishop]];
	[board replaceObjectAtIndex:62 withObject:[NSNumber numberWithShort:black_knight]];
	[board replaceObjectAtIndex:63 withObject:[NSNumber numberWithShort:black_rook]];
    
    [self printPosition];
    */
//}
/*
- (void) printPosition {
    
	NSLog(@"--------- BOARD -----------");
	NSString * line;
	// Start at the top of the row first
	for( int i=7; i>=0; i--) {
		line = @"";
		// Simply move from left to right in that row
		for( int j=0; j<8; j++) {
			// Create a space between for readability
            NSNumber *sn = [board objectAtIndex:i*8+j];
            if ([sn shortValue] < 0) {
                line = [line stringByAppendingString:[NSString stringWithFormat:@"%d",[sn shortValue]]];
            }
            else {
                line = [line stringByAppendingString:[NSString stringWithFormat:@" %d",[sn shortValue]]];
            }
		}
		NSLog(@"|%@ |",line);
	}
	NSLog(@"---------------------------");
 
}
*/

@end
