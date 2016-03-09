/*
  Stockfish, a chess program for iOS.
  Copyright (C) 2004-2013 Tord Romstad, Marco Costalba, Joona Kiiski.

  Stockfish is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Stockfish is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <Foundation/Foundation.h>

#import "ChessClock.h"
#import "ChessMove.h"
#import "OpeningBook.h"

#include "../Chess/position.h"

using namespace Chess;

#define HINT_HASH_TABLE_SIZE 1024

typedef struct {
   uint64_t key;
   Move move;
} HintHashentry;

@class GameController;

@interface Game : NSObject {
   GameController *gameController;
   NSString *startFEN;
   Position *startPosition;
   Position *currentPosition;
   NSMutableArray *moves;
   int currentMoveIndex;
   OpeningBook *book;
   ChessClock *clock;

   NSString *event;
   NSString *site;
   NSString *date;
   NSString *round;
   NSString *whitePlayer;
   NSString *blackPlayer;
   NSString *result;
   
   NSString *eco;
   NSString *opening;
   NSString *variation;

   NSString *openingString;

   HintHashentry hintHashTable[HINT_HASH_TABLE_SIZE];
}

@property (nonatomic, readonly) ChessClock *clock;
@property (nonatomic, retain) NSString *event;
@property (nonatomic, retain) NSString *site;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *round;
@property (nonatomic, retain) NSString *whitePlayer;
@property (nonatomic, retain) NSString *blackPlayer;
@property (nonatomic, retain) NSString *result;
@property (nonatomic, retain) NSString *eco;
@property (nonatomic, retain) NSString *opening;
@property (nonatomic, retain) NSString *variation;
@property (nonatomic, retain) NSString *openingString;
@property (nonatomic, readonly) int currentMoveIndex;
@property (nonatomic, readonly) Position *startPosition;
@property (nonatomic, readonly) NSArray *moves;

- (id)initWithGameController:(GameController *)gc FEN:(NSString *)fen;
- (id)initWithGameController:(GameController *)gc PGNString:(NSString *)string;
- (id)initWithGameController:(GameController *)gc;
- (Color)sideToMove;
- (Piece)pieceOn:(Square)sq;
- (BOOL)pieceCanMoveFrom:(Square)sq;
- (int)pieceCanMoveFrom:(Square)fSq to:(Square)tSq;
- (int)generateLegalMoves:(Move *)mlist;
- (int)movesFrom:(Square)sq saveInArray:(Move *)mlist;
- (int)destinationSquaresFrom:(Square)sq saveInArray:(Square *)sqs;
- (void)doMove:(Move)m;
- (Move)doMoveFrom:(Square)fSq to:(Square)tSq promotion:(PieceType)prom;
- (void)doMoveFrom:(Square)fSq to:(Square)tSq;
- (BOOL)atBeginning;
- (BOOL)atEnd;
- (void)takeBack;
- (void)stepForward;
- (void)toBeginning;
- (void)toEnd;
- (void)toPly:(int)ply;
- (ChessMove *)previousMove;
- (ChessMove *)nextMove;
- (NSString *)moveListString;
- (NSString *)partialMoveListString;
- (NSString *)pgnString;
- (NSString *)emailPgnString;
- (NSString *)remoteEngineGameString;
- (NSString *)uciGameString;
- (NSString *)htmlString;
- (Move)getBookMove;
- (void)getAllBookMoves:(Move *)moveArray;
- (NSString *)bookMovesAsString;
- (Move)moveFromString:(NSString *)string;
- (void)startClock;
- (void)stopClock;
- (void)pushClock;
- (int)whiteRemainingTime;
- (int)blackRemainingTime;
- (NSString *)whiteClockString;
- (NSString *)blackClockString;
- (void)setTimeControlWithTime:(int)time increment:(int)increment;
- (void)setTimeControlWithTime:(int)time movesPerSession:(int)mps;
- (void)setTimeControlWithFixedTime:(int)time;
- (void)setHintForCurrentPosition:(Move)hintMove;
- (Move)getHintForCurrentPosition;
- (BOOL)positionIsMate;
- (BOOL)positionIsDraw;
- (NSString *)drawReason;
- (BOOL)positionIsTerminal;
- (BOOL)positionAfterMoveIsTerminal:(Move)m;
- (void)addComment: (NSString *)comment;
- (Move)currentMove;
- (NSString *)currentFEN;
- (NSArray *)moveList;
- (uint64_t)keyForCurrentPosition;
- (void)computeOpeningString;

@end
