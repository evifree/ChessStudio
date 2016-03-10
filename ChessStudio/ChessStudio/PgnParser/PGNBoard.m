//
//  PGNBoard.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/04/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PGNBoard.h"



@interface PGNBoard() {
    
    
    short empty;
    
    short white_king;
    short white_queen;
    short white_rook;
    short white_bishop;
    short white_knight;
    short white_pawn;
    
    short black_king;
    short black_queen;
    short black_rook;
    short black_bishop;
    short black_knight;
    short black_pawn;

    NSMutableArray *board;

}

@end

@implementation PGNBoard

- (id) init {
    self = [super init];
    if (self) {
        [self initBoard];
    }
    return self;
}


- (void) initBoard {
    
    empty = 0;
    
    white_king = -6;
    white_queen = -5;
    white_rook = -4;
    white_bishop = -3;
    white_knight = -2;
    white_pawn = -1;
    
    black_king = 6;
    black_queen = 5;
    black_rook = 4;
    black_bishop = 3;
    black_knight = 2;
    black_pawn = 1;
    
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
    
    //[self printPosition];
}

- (void) emptySquare:(short)square {
    NSLog(@"EmptySquare   square = %d", square);
    [board replaceObjectAtIndex:square withObject:[NSNumber numberWithShort:empty]];
}

- (void) replacePiece:(short)squareTo :(short)piece {
    NSLog(@"replacePiece    squareTo = %d     Piece = %d", squareTo, piece);
    NSNumber *pezzo = [NSNumber numberWithShort:piece];
    [board replaceObjectAtIndex:squareTo withObject:pezzo];
}

- (void) replaceContentOfsquare:(short)squareTo :(short)squareFrom {
    NSNumber *pezzoInSquareFrom = [board objectAtIndex:squareFrom];
    [board replaceObjectAtIndex:squareTo withObject:pezzoInSquareFrom];
}

- (short) getPieceAtSquare:(short)square {
    NSLog(@"getPieceAtSquare  square = %d", square);
    return [[board objectAtIndex:square] shortValue];
}

- (short) getPieceAtSquare:(short)column :(short)row {
    return [[board objectAtIndex:column*8 + row] shortValue];
}

- (NSNumber *) getPieceNumberAtSquare:(short)square {
    return [board objectAtIndex:square];
}

- (BOOL) squareIsEmpty:(short)square {
    return [[board objectAtIndex:square] shortValue] == empty;
}

- (BOOL) squareContainsPiece:(short)square :(short)piece {
    return [[board objectAtIndex:square] shortValue] == piece;
}

- (NSArray *) getPosition {
    return board;
}

- (void) setPosition:(NSArray *)position {
    board = [[NSMutableArray alloc] initWithArray:position];
    //NSLog(@"STAMPO POSIZIONE SALVATA");
    //[self printPosition];
}

- (void) muoviAvanti:(PGNMove *)move {
    if (move.isCastle) {
        if (move.kingSideCastle) {
            if ([move.color isEqualToString:@"w"]) {
                //NSLog(@"Arrocco Corto Bianco");
                [self replaceContentOfsquare:6 :4];
                [self replaceContentOfsquare:5 :7];
                [self emptySquare:4];
                [self emptySquare:7];
            }
            else {
                //NSLog(@"Arrocco Corto Nero");
                [self replaceContentOfsquare:62 :60];
                [self replaceContentOfsquare:61 :63];
                [self emptySquare:60];
                [self emptySquare:63];
            }
        }
        else {
            if ([move.color isEqualToString:@"w"]) {
                //NSLog(@"Arrocco Lungo Bianco");
                [self replaceContentOfsquare:2 :4];
                [self replaceContentOfsquare:3 :0];
                [self emptySquare:4];
                [self emptySquare:0];
            }
            else {
                //NSLog(@"Arrocco Lungo Nero");
                [self replaceContentOfsquare:58 :60];
                [self replaceContentOfsquare:59 :56];
                [self emptySquare:60];
                [self emptySquare:56];
            }
        }
        //[self printPosition];
        return;
    }
    if (move.promoted) {
        [self replacePiece:move.fromSquare :empty];
        [self replacePiece:move.toSquare :[self getNumberpiece:move.pezzoPromosso]];
        //[self printPosition];
        return;
    }
    if (move.enPassantCapture) {
        [self replacePiece:move.fromSquare :empty];
        if ([move.color isEqualToString:@"w"]) {
            [self replacePiece:move.toSquare :white_pawn];
        }
        else {
            [self replacePiece:move.toSquare :black_pawn];
        }
        //[self printPosition];
        return;
    }
    NSNumber *pezzoMosso = [self getPieceNumberAtSquare:move.fromSquare];
    [board replaceObjectAtIndex:move.toSquare withObject:pezzoMosso];
    [self replacePiece:move.fromSquare :empty];
    //[self printPosition];
}

- (void) muoviIndietro:(PGNMove *)move {
    NSNumber *pezzoMosso = [self getPieceNumberAtSquare:move.toSquare];
    NSNumber *pezzoCatturato = nil;
    
    if (move.isCastle) {
        if (move.kingSideCastle) {
            if ([move.color isEqualToString:@"w"]) {
                //NSLog(@"Ripristino Arrocco corto bianco");
                [self replaceContentOfsquare:4 :6];
                [self replaceContentOfsquare:7 :5];
                [self emptySquare:6];
                [self emptySquare:5];
            }
            else {
                //NSLog(@"Ripristino arrocco corto Nero");
                [self replaceContentOfsquare:60 :62];
                [self replaceContentOfsquare:63 :61];
                [self emptySquare:62];
                [self emptySquare:61];
            }
        }
        else {
            if ([move.color isEqualToString:@"w"]) {
                //NSLog(@"Ripristino Arrocco Lungo bianco");
                [self replaceContentOfsquare:4 :2];
                [self replaceContentOfsquare:0 :3];
                [self emptySquare:2];
                [self emptySquare:3];
            }
            else {
                //NSLog(@"Ripristino Arrocco Lungo Nero");
                [self replaceContentOfsquare:60 :58];
                [self replaceContentOfsquare:56 :59];
                [self emptySquare:58];
                [self emptySquare:59];
            }
        }
        //[self printPosition];
        return;
    }
    if (move.promoted) {
        if ([move.color isEqualToString:@"w"]) {
            [self replacePiece:move.fromSquare :white_pawn];
        }
        else {
            [self replacePiece:move.fromSquare :black_pawn];
        }
        if (move.capture) {
            [self replacePiece:move.toSquare :[self getNumberpiece:move.captured]];
        }
        else {
            [self replacePiece:move.toSquare :empty];
        }
        //[self printPosition];
        return;
    }
    if (move.enPassantCapture) {
        [self emptySquare:move.toSquare];
        if ([move.color isEqualToString:@"w"]) {
            [self replacePiece:move.fromSquare :white_pawn];
            [self replacePiece:move.enPassantPieceSquare :black_pawn];
        }
        else {
            [self replacePiece:move.fromSquare :black_pawn];
            [self replacePiece:move.enPassantPieceSquare :white_pawn];
        }
        //[self printPosition];
        return;
    }
    if (move.capture) {
        //NSLog(@"Devo prendere il pezzo catturato");
        pezzoCatturato = [NSNumber numberWithShort:[self getNumberpiece:move.captured]];
        
    }
    else {
        pezzoCatturato = [NSNumber numberWithShort:empty];
    }
    [board replaceObjectAtIndex:move.toSquare withObject:pezzoCatturato];
    [board replaceObjectAtIndex:move.fromSquare withObject:pezzoMosso];
    //[self printPosition];
}

- (void) printPosition1 {
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

- (NSString *) getSimbolPiece:(short)piece {
    switch (piece) {
        case -1:
            return @"wp";
            //return whitePawnSymbol;
        case -2:
            return @"wn";
            //return whiteKnightSymbol;
        case -3:
            return @"wb";
            //return whiteBishopSymbol;
        case -4:
            return @"wr";
            //return whiteRookSymbol;
        case -5:
            return @"wq";
            //return whiteQueenSymbol;
        case -6:
            return @"wk";
            //return whiteKingSymbol;
        case 1:
            return @"bp";
            //return blackPawnSymbol;
        case 2:
            return @"bn";
            //return blackKnightSymbol;
        case 3:
            return @"bb";
            //return blackBishopSymbol;
        case 4:
            return @"br";
            //return blackRookSymbol;
        case 5:
            return @"bq";
            //return blackQueenSymbol;
        case 6:
            return @"bk";
            //return blackKingSymbol;
        default:
            break;
    }
    return @"em";
}

- (short) getNumberpiece:(NSString *)piece {
    short colorePezzo = 1;
    if ([piece hasPrefix:@"w"]) {
        colorePezzo = -1;
    }
    else {
        colorePezzo = 1;
    }
    if ([piece hasSuffix:@"k"]) {
        return (colorePezzo * 6);
    }
    else if ([piece hasSuffix:@"q"]) {
        return (colorePezzo * 5);
    }
    else if ([piece hasSuffix:@"r"]) {
        return (colorePezzo * 4);
    }
    else if ([piece hasSuffix:@"b"]) {
        return (colorePezzo * 3);
    }
    else if ([piece hasSuffix:@"n"]) {
        return (colorePezzo * 2);
    }
    return (colorePezzo * 1);
}


- (void) printPosition {
    NSLog(@"BOARD FROM PGNBoard");
    NSLog(@"--------- BOARD -----------");
    NSMutableString *line;
    for( int i=7; i>=0; i--) {
        line = [[NSMutableString alloc] init];
        for( int j=0; j<8; j++) {
            short *sn = [[board objectAtIndex:i*8+j] shortValue];
            NSString *pezzo = [self getSimbolPiece:sn];
            [line appendString:[NSString stringWithFormat:@" %@",pezzo]];
        }
        NSLog(@"|%@ |",line);
    }
    NSLog(@"---------------------------");
}


@end
