//
//  PGNPastedGame.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 11/11/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSUInteger const PARTITA_INDEFINITA;
extern NSUInteger const PARTITA_CON_TAG_E_MOSSE;
extern NSUInteger const PARTITA_SENZA_TAG_CON_MOSSE;
extern NSUInteger const PARTITA_CON_TAG_SENZA_MOSSE;
extern NSUInteger const PARTITA_CON_TAG_INCOMPLETI_CON_MOSSE;

@interface PGNPastedGame : NSObject


- (id) initWithPastedString:(NSString *)pastedString;



- (void) stampaTags;
- (void) stampaMoves;

- (NSArray *) getFinalPastedGames;

- (NSUInteger) getEvaluation;

- (void) aggiungiTuttiTag;
- (NSString *)getGamesForTextView;

- (NSDictionary *) getEvaluationDictionary;

- (NSInteger) getEvaluationForGame:(NSString *)selectedGame;

- (NSArray *) gamesToSave;

+ (NSString *) getGameForTextView:(NSString *)selectedGame;
- (NSString *) getGameForTableView:(NSString *)selectedGame;
- (NSString *) getGameDetailForTableView:(NSString *)selectedGame;

- (NSString *) correctGame:(NSString *)selectedGame;

- (void) replaceGame:(NSString *)oldGame :(NSString *)newGame;

@end
