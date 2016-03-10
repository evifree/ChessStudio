//
//  PGNAnalyzer.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 16/04/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGNMove.h"
#import "FENParser.h"

@interface PGNAnalyzer : NSObject

@property (nonatomic, strong) FENParser *fenParser;

- (id) initWithGame:(NSString *) game;
- (id) initWithPosition:(NSString *)position;


- (void) parseGameToTokenArray;
- (void) parseGameToTokenArrayWithGraffa;
- (void) parsePositionToTokenArray;
- (void) parsePositionToTokenArrayWithGraffa;
- (void) parseGameToDeleteTrePunti;
- (void) parsePositionToDeleteTrePunti;
- (void) parseGameToListMoves;
- (void) parseGameToListMovesWithGraffa;
- (void) parsePositionToListMoves;
- (void) parsePositionToListMovesWithGraffa;
- (void) parsePositionWithoutMovesToListMoves;

- (void) printParsedGame;
- (NSString *) getParsedGame;
- (NSArray *) getParsedGameArray;
- (NSString *) getParsedGameWithNoComments;
- (NSString *) getParsedGameWithChessSymbolsAndNoComments;
- (NSString *) getParsedGameWithNoVariationsAndNoComments;

- (PGNMove *) getFirstMove;


- (PGNMove *) getRadice;

- (void) printParsedArray;


- (void) visitaAlberoToGetMainLine;
- (void) visitaAlberoAnticipato;
- (void) visitaAlberoDifferito;
- (void) visitaAlberoAnticipato2;
- (NSArray *) visitaAlberoAnticipato2AndGetGameArray;


- (BOOL) numerazioneMosseModificata;


- (void) parseGameToExtractMainMoves;

@end
