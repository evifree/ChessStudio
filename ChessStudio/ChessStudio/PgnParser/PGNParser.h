//
//  PGNParser.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 03/04/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "PGNGame.h"
#import "PGNMove.h"

@interface PGNParser : NSObject


//- (id) init;
//- (id) initWithPgnMoves:(NSString *)pgnMoves;
- (id) initWithGame;
- (id) initWithPosition;



- (void) parse:(NSString *)pgnMoves;

- (void) parseTreeMoves:(PGNMove *)pgnMove;

- (void) parseTreeMovesGameWithMoves:(PGNMove *)pgnMove;
- (void) parseTreeMovesPositionWithMoves:(PGNMove *)pgnMove;

//- (PGNGame *) getGame;

- (void) parseMoveForward:(PGNMove *)moveToParseForward;
- (void) parseMoveBack:(PGNMove *)moveToParseBack;

- (void) setFenPosition:(NSString *)fenPosition;

@end
