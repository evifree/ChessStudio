//
//  PGNBoard.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/04/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGNMove.h"


@interface PGNBoard : NSObject

- (id) init;

- (void) printPosition;

- (void) emptySquare:(short) square;
- (void) replacePiece:(short) squareTo :(short) piece;
- (void) replaceContentOfsquare:(short)squareTo :(short) squareFrom;
- (short) getPieceAtSquare:(short)square;
- (NSNumber *) getPieceNumberAtSquare:(short)square;
- (BOOL) squareIsEmpty:(short)square;
- (BOOL) squareContainsPiece:(short) square :(short) piece;
- (short) getPieceAtSquare:(short)column :(short)row;

- (NSArray *) getPosition;
- (void) setPosition:(NSArray *)position;

- (void) muoviAvanti:(PGNMove *)move;
- (void) muoviIndietro:(PGNMove *)move;

@end
