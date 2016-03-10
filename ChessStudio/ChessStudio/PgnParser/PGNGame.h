//
//  PGNGame.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 11/12/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FENParser.h"
#import "PgnFileInfo.h"
#import "UtilToView.h"

extern NSUInteger const GAME_WITH_MOVES;
extern NSUInteger const GAME_WITHOUT_MOVES;
extern NSUInteger const POSITION_WITH_MOVES;
extern NSUInteger const POSITION_WITHOUT_MOVES;

@interface PGNGame : NSObject

@property (nonatomic, strong) NSString *moves;
@property (nonatomic, assign) NSInteger indexInAllGamesAllTags;

@property (nonatomic, strong) NSString *movesInPositionWithoutMoves;

@property (nonatomic, assign, getter = endsWithCheckMate) BOOL checkMate;

@property (nonatomic, assign, getter = isEditMode) BOOL editMode;
@property (nonatomic, assign, getter = isModified) BOOL modified;


- (id) initWithPgn:(NSString *)pgn;
- (id) initWithFen:(NSString *)fen;

- (void) setTag:(NSString *)tagName andTagValue:(NSString *)tagValue;
- (void) addSupplementalTag:(NSString *)suppTag andTagValue:(NSString *)suppTagValue;
- (void) saveSupplementalTag:(NSDictionary *)suppTagDictionary;
- (void) savePositionTag:(NSDictionary *)positionTagDictionary;
- (void) stampaSevenTag;
- (void) stampaTag;
- (void) printGame;
- (void) printCompleteGame;
- (NSString *) getCompleteGame;
- (NSString *) getTagValueByTagName:(NSString *)tagName;
- (NSString *) getTagValueByTagName:(NSString *)tagName withQuotes:(BOOL)quotes;
- (NSString *) getTagInBrackets:(NSString *)tagName;
- (void) addCompleteTag:(NSString *)completeTag;
- (BOOL) isNewGame;
- (BOOL) isPosition;
- (NSString *) getGameForFile;
- (NSString *) getGameForMail;
- (NSString *) getGameForCopy;
- (NSString *) getGameMovesForPreview;
- (NSArray *) getOriginalGameArray;
- (NSArray *) getGameArray;
- (NSString *) getFenPosition;
- (NSUInteger) getNumberOfSupplementalTag;
- (NSString *) getSupplementalTagByIndex:(NSUInteger)index;
- (NSString *) getSupplementalTagValueByIndex:(NSUInteger)index;
- (void) removeTag:(NSString *)tagName;
- (NSString *) getGameForAllGamesAndAllTags;
- (void) replaceTagAndTagValue:(NSString *)tagName :(NSString *)tagValue;
- (void) replaceOnlyTagAndTagValue:(NSString *)tagName :(NSString *)tagValue;

- (BOOL) userCanEditGameData;
- (BOOL) sevenTagsAreAllEmpty;

- (void) aggiornaOrdineTagArray:(NSArray *)tagArray;
- (void) resetTag;
- (void) resetTagExceptResult;

- (BOOL) supplementalTagIsPresent:(NSString *)supplementalTagName;

- (NSUInteger) getGameType;
- (NSString *) getMovesForPreview;

- (FENParser *) getFenParser;
- (NSUInteger) getStartPlycount;//Metodo aggiunto per la gestione del numero mossa iniziale delle posizioni

- (NSMutableDictionary *) getSevenTag;
- (NSMutableDictionary *) getSupplementalTag;
- (NSMutableArray *) getOrderedSuppTag;
- (NSMutableDictionary *) getSupplementalTagApp;
- (NSMutableDictionary *) getOtherTagApp;
- (NSMutableDictionary *) getPositionTagDict;

+ (BOOL) gameIsPositionWithRegularFen:(NSString *)gameSel;
+ (BOOL) gameIsPositionWithRegularNumbering:(NSString *)gameSel;
+ (NSString *) checkStartColorAndFirstMove:(NSString *)gameSel;
+ (NSString *) getGameWithNumberOfMoveInFenCorrected:(NSString *) gameSel;
+ (NSString *) getTemporaryFen;
+ (NSString *) getCorrectedGame:(NSString *)gameSel;



//Metodi per la formattazione dei dati in una UITableViewCell

- (NSString *) getCellTextLabel;
- (NSString *) getCellDetailTextLabel;


- (NSString *) getOriginalPgn;

- (NSString *) getTitleWhiteAndBlack;

-(void) stampaMosse;

- (void) backupMoves;
- (void) restoreMoves;

- (void) addEcoTags:(NSDictionary *)ecoDictionary;
- (void) removeEcoTags;

+ (NSString *) getMovesWithoutGraffe:(NSString *) game;
+ (NSMutableAttributedString *) getMovesWithAttributed:(NSString *) game;

- (NSMutableAttributedString *) getAttributedGameMoves;

@end
