//
//  PgnFileInfo.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 07/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "PGNGame.h"

@interface PgnFileInfo : NSObject<NSCoding>

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *personalFileName;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *savePath;
@property (nonatomic, strong) NSDate *dataCreazione;
@property (nonatomic, strong) NSDate *dataUltimaModifica;
@property (nonatomic, strong) NSDate *dataUltimoAccesso;
@property (nonatomic, strong) NSDate *dataUscita;

@property (nonatomic, strong) NSString *localCloudPath;
@property (nonatomic) BOOL isInCloud;


@property (nonatomic, strong) NSNumber *numberOfGames;
@property (nonatomic, strong) NSArray *listOfTags;
@property (nonatomic, strong) NSArray *listOfEvents;
@property (nonatomic, strong) NSArray *listOfEco;
@property (nonatomic, strong) NSArray *listOfGames;
@property (nonatomic, strong) NSArray *listOfPlayers;
@property (nonatomic, strong) NSArray *allGames;
@property (nonatomic, strong) NSArray *listOfYears;
@property (nonatomic, strong) NSArray *allTagsOfGames;

@property (nonatomic, strong) NSDictionary *attributiFile;


- (id) initWithFileName:(NSString *)fName;
- (id) initWithFilePath:(NSString *)fPath;

- (NSArray *)findGamesByTag:(NSString *)tag;
- (NSArray *)findGamesByOpeningTag;
- (NSArray *)findGamesByStrTag;
- (NSArray *)findGamesByPlayerTag;
- (NSArray *)findGamesByTournamentTag;
- (NSArray *)findGamesByTagArray:(NSArray *)tagArray;

- (NSArray *)findInfoByTagArray:(NSArray *)tagArray;

- (NSArray *)findForfaitGames;


- (NSArray *)getAllGames;
- (NSString *)findGameByNumber:(NSInteger)gameNumber;
- (NSDictionary *)findGamesByTagValue:(NSString *)tag;
- (NSString *)findGameByEventAndInfo:(NSString *)event :(NSString *)info;

- (NSArray *)getAllEvents;
- (NSDictionary *)getAllEventsByDictionary;
- (NSCountedSet *)getAllEventsByCountedSet;

- (NSArray *)getAllEco;
- (NSDictionary *)getAllEcoByDictionary;
- (NSCountedSet *)getAllEcoByCountedSet;
- (NSDictionary *)getAllEcoByClassification;

- (NSArray *)getAllPlayers;
- (NSDictionary *)getAllPlayersByDictionary;
- (NSCountedSet *)getAllPlayersByCountedSet;
- (NSArray *)getAllInfoOnPlayers;

- (NSArray *)findGamesByTagValues:(NSString *)tagValues;
- (NSArray *)findGamesByEventTags:(NSString *)tagValues;

- (NSArray *)findGamesByEcoOpening:(NSArray *)ecoOpeningArray;


- (NSArray *)findGamesByPlayerName:(NSString *)playerName;
- (NSString *)findGameMovesByTagPairs:(NSString *)tagPairs;

- (NSArray *)findGamesByYear:(NSString *)year;

- (NSString *)getDataCreazione;

- (NSArray *)getAllDatabaseGames;
- (NSArray *)getAllGamesByRegex;
- (NSArray *)findGamesByTagsByRegex:(NSArray *)tagsArray;

- (void) classifyGamesByEvent:(NSArray *)gamesByYear;
- (NSCountedSet *)getAllEventsInArray:(NSArray *)gamesByYear;

- (NSCountedSet *)getAllDateByCountedSet;

- (NSMutableArray *)getAllGamesAndTags;


- (void) saveGame:(NSString *)game;
- (void) saveAllGamesAndTags:(NSMutableArray *)gamesAndTags;
- (void) appendGamesAndTagsToPgnFile:(NSArray *)gamesToAppend;

- (NSString *) getCompletePathAndName;


- (NSMutableArray *) caricaTutteGliEventi;
- (NSMutableArray *) caricaTutteLePartite;

- (void) salvaTutteLePartite;

- (void) deleteGamesInArray:(NSArray *)gamesToDelete;

- (NSInteger) getIndexOfGame:(NSString *)game;


- (void) printAllGamesAllTags;


- (NSString *) getDateInfo;
- (NSString *) getDimInfo;
- (NSString *) getDateDimInfo;

@end
