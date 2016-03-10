//
//  PgnFileInfo.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 07/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PgnFileInfo.h"
#import "DDFileReader.h"
//#import "PGNDocumentGame.h"


#define strTag [NSArray arrayWithObjects: @"Event ",@"Site ", @"Date ", @"Round ", @"White ", @"Black ", @"Result ", nil]
#define playerTag [NSArray arrayWithObjects: @"White ", @"Black ", @"WhiteTitle ",@"BlackTitle ", @"WhiteElo ", @"BlackElo ", @"WhiteFideId ", @"BlackFideId ", @"WhiteUSCF ", @"BlackUSCF ", @"WhiteType ", @"BlackType ", @"WhiteNA ", @"BlackNA ", nil]
#define whitePlayerTag [NSArray arrayWithObjects: @"White ", @"WhiteTitle ", @"WhiteElo ", @"WhiteFideId ", @"WhiteUSCF ", @"WhiteType ", @"WhiteNA ", nil]
#define blackPlayerTag [NSArray arrayWithObjects: @"Black ", @"BlackTitle ", @"BlackElo ", @"BlackFideId ", @"BlackUSCF ", @"BlackType ", @"BlackNA ", nil]
#define tournamentTag [NSArray arrayWithObjects: @"Event ", @"EventDate ",@"EventSponsor ", @"EventCountry ", @"EventType ", @"EventRounds " @"Section ", @"Stage ", @"Board ", nil]
#define openingTag [NSArray arrayWithObjects: @"ECO ",@"Opening ", @"Variation ", @"Subvariation ", nil]
//#define eventTag [NSArray arrayWithObjects: @"Event ", @"Site ", @"Date ", nil]
#define eventTag [NSArray arrayWithObjects: @"Event ", @"Site ", nil]
#define ecoTag [NSArray arrayWithObjects: @"ECO ", nil]
#define gameTag [NSArray arrayWithObjects: @"White ", @"Black ", @"Result",  nil]

@interface PgnFileInfo() {

    NSMutableCharacterSet *setQuadre;
    NSMutableCharacterSet *setDoppiApici;
    NSMutableCharacterSet *setPunto;
    
    NSCharacterSet *stranoCharSet;
    
    DDFileReader *reader;

    NSArray *allGamesByRegex;
    
    NSMutableArray *allGamesAndTags;
    
}

@end


@implementation PgnFileInfo


@synthesize fileName = _fileName;
@synthesize personalFileName = _personalFileName;
@synthesize path = _path;
@synthesize savePath = _savePath;
@synthesize dataCreazione = _dataCreazione;
@synthesize dataUltimaModifica = _dataUltimaModifica;
@synthesize dataUltimoAccesso = _dataUltimoAccesso;
@synthesize dataUscita = _dataUscita;

@synthesize numberOfGames = _numberOfGames;
@synthesize listOfTags = _listOfTags;
@synthesize listOfEvents = _listOfEvents;
@synthesize listOfEco = _listOfEco;



- (id) initWithFileName:(NSString *)fName {
    self = [super init];
    if (self) {
        _dataCreazione = [[NSDate alloc] init];
        _dataUltimaModifica = _dataCreazione;
        _dataUltimoAccesso = _dataCreazione;
        _fileName = fName;
        _personalFileName = fName;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [paths objectAtIndex:0];
        _path = [documentPath stringByAppendingPathComponent:_fileName];
        
        _savePath = [self getFileNameWithInfoSuffix];
        
        setQuadre = [[NSMutableCharacterSet alloc] init];
        [setQuadre addCharactersInString:@"[]"];
        setDoppiApici = [[NSMutableCharacterSet alloc] init];
        [setDoppiApici addCharactersInString:@"\""];
        setPunto = [[NSMutableCharacterSet alloc] init];
        [setPunto addCharactersInString:@"."];
        
        stranoCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ï»¿"];
        
        
        _isInCloud = NO;
        
        //[self calcNumberOfGames];
        [self initPgnDatabase];
        
        _attributiFile = [[NSFileManager defaultManager] attributesOfItemAtPath:_path error:nil];
        
        
    }
    return self;
}

- (id) initWithFilePath:(NSString *)fPath {
    self = [super init];
    if (self) {
        _dataCreazione = [[NSDate alloc] init];
        _dataUltimaModifica = _dataCreazione;
        _dataUltimoAccesso = _dataCreazione;
        _fileName = [fPath lastPathComponent];
        _personalFileName = _fileName;
        _path = fPath;
        _savePath = [self getFileNameWithInfoSuffix];
        
        setQuadre = [[NSMutableCharacterSet alloc] init];
        [setQuadre addCharactersInString:@"[]"];
        setDoppiApici = [[NSMutableCharacterSet alloc] init];
        [setDoppiApici addCharactersInString:@"\""];
        setPunto = [[NSMutableCharacterSet alloc] init];
        [setPunto addCharactersInString:@"."];
        
        stranoCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ï»¿"];
        
        _isInCloud = NO;
        
        //[self calcNumberOfGames];
        [self initPgnDatabase];
        
        
        
        //NSLog(@"PGNFILEINFO   _PATH:%@", _path);
        _attributiFile = [[NSFileManager defaultManager] attributesOfItemAtPath:_path error:nil];

    }
    return self;
}


- (void) initPgnDatabase {
    
    //NSLog(@"Sto per caricare tutte le partite");
    
    allGamesAndTags = [self caricaTutteLePartite];
    
    //[self scorriAllGamesInDatabase];
    
    //NSLog(@"Ho caricato tutte le partite");
    
    
    
    
    _numberOfGames = [NSNumber numberWithInteger:allGamesAndTags.count];
    //NSLog(@"Stampa da InitPgnDatabase");
    //for (NSString *g in allGamesAndTags) {
    //    NSLog(@"%@\n\n", g);
    //}
}


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    setQuadre = [[NSMutableCharacterSet alloc] init];
    [setQuadre addCharactersInString:@"[]"];
    setDoppiApici = [[NSMutableCharacterSet alloc] init];
    [setDoppiApici addCharactersInString:@"\""];
    setPunto = [[NSMutableCharacterSet alloc] init];
    [setPunto addCharactersInString:@"."];
    
    _personalFileName = [aDecoder decodeObjectForKey:@"PERSONAL_FILE_NAME"];
    _fileName = [aDecoder decodeObjectForKey:@"NOME_FILE"];
    _path = [aDecoder decodeObjectForKey:@"PATH"];
    _savePath = [aDecoder decodeObjectForKey:@"SAVEPATH"];
    _dataCreazione = [aDecoder decodeObjectForKey:@"DATA_CREAZIONE"];
    _dataUltimaModifica = [aDecoder decodeObjectForKey:@"DATA_ULTIMA_MODIFICA"];
    _dataUltimoAccesso = [aDecoder decodeObjectForKey:@"DATA_ULTIMO_ACCESSO"];
    _dataUscita = [aDecoder decodeObjectForKey:@"DATA_USCITA"];
    
    _numberOfGames = [aDecoder decodeObjectForKey:@"NUMBER_OF_GAMES"];
    //_listOfTags = [aDecoder decodeObjectForKey:@"LIST_OF_TAGS"];
    //_listOfEvents = [aDecoder decodeObjectForKey:@"LIST_OF_EVENTS"];
    //_listOfEco = [aDecoder decodeObjectForKey:@"LIST_OF_ECO"];
    //_listOfGames = [aDecoder decodeObjectForKey:@"LIST_OF_GAMES"];
    //_listOfPlayers = [aDecoder decodeObjectForKey:@"LIST_OF_PLAYERS"];
    //_allGames = [aDecoder decodeObjectForKey:@"ALL_GAMES"];
    //_listOfYears = [aDecoder decodeObjectForKey:@"LIST_OF_YEARS"];
    
    
    _isInCloud = [aDecoder decodeBoolForKey:@"IS_IN_CLOUD"];
    
    allGamesAndTags = [aDecoder decodeObjectForKey:@"ALL_GAMES_ALL_TAGS"];
    
    _attributiFile = [aDecoder decodeObjectForKey:@"ATTRIBUTI_FILE"];
    
    
    //NSLog(@"Ho eseguito initWithCoder");
    //NSLog(@"SAVE PATH: %@", _savePath);
    //NSLog(@"%@", allGamesAndTags);
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_fileName forKey:@"NOME_FILE"];
    [aCoder encodeObject:_personalFileName forKey:@"PERSONAL_FILE_NAME"];
    [aCoder encodeObject:_path forKey:@"PATH"];
    [aCoder encodeObject:_savePath forKey:@"SAVEPATH"];
    [aCoder encodeObject:_dataCreazione forKey:@"DATA_CREAZIONE"];
    [aCoder encodeObject:_dataUltimaModifica forKey:@"DATA_ULTIMA_MODIFICA"];
    [aCoder encodeObject:_dataUltimoAccesso forKey:@"DATA_ULTIMO_ACCESSO"];
    [aCoder encodeObject:_dataUscita forKey:@"DATA_USCITA"];
    
    [aCoder encodeObject:_numberOfGames forKey:@"NUMBER_OF_GAMES"];
    [aCoder encodeObject:_listOfTags forKey:@"LIST_OF_TAGS"];
    [aCoder encodeObject:_listOfEvents forKey:@"LIST_OF_EVENTS"];
    [aCoder encodeObject:_listOfEco forKey:@"LIST_OF_ECO"];
    [aCoder encodeObject:_listOfGames forKey:@"LIST_OF_GAMES"];
    [aCoder encodeObject:_listOfPlayers forKey:@"LIST_OF_PLAYERS"];
    [aCoder encodeObject:_allGames forKey:@"ALL_GAMES"];
    [aCoder encodeObject:_listOfYears forKey:@"LIST_OF_YEARS"];
    
    [aCoder encodeBool:_isInCloud forKey:@"IS_IN_CLOUD"];
    
    [aCoder encodeObject:allGamesAndTags forKey:@"ALL_GAMES_ALL_TAGS"];
    
    [aCoder encodeObject:_attributiFile forKey:@"ATTRIBUTI_FILE"];
}

- (NSString *) getFileNameWithInfoSuffix {
    NSArray *nameArray = [_fileName componentsSeparatedByString:@"."];
    NSString *finalName = [[nameArray objectAtIndex:0] stringByAppendingString:@".dat"];
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentPath = [paths objectAtIndex:0];
    NSRange rangeLastPath = [_path rangeOfString:_fileName];
    NSString *pathWithoutFile = [_path substringToIndex:rangeLastPath.location];
    //NSLog(@"Path Without File = %@", pathWithoutFile);
    NSString *pathWithDatFile = [pathWithoutFile stringByAppendingPathComponent:finalName];
    //NSLog(@"Path with Dat file = %@", pathWithDatFile);
    return pathWithDatFile;
}

- (NSString *) getDateInfo {
    NSDate *data = [_attributiFile fileCreationDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateInfo = [dateFormatter stringFromDate:data];
    return dateInfo;
}

- (NSString *) getDimInfo {
    NSNumber *fileByteSize = [_attributiFile objectForKey:NSFileSize];
    long dimensioniFile = fileByteSize.longLongValue;
    NSString *dimFormattate = [NSByteCountFormatter stringFromByteCount:dimensioniFile countStyle:NSByteCountFormatterCountStyleFile];
    return dimFormattate;
}

- (NSString *) getDateDimInfo {
    return [[[self getDateInfo] stringByAppendingString:@" - "] stringByAppendingString:[self getDimInfo]];
}

/*
- (NSString *) localCloudPath {
    NSArray *nameArray = [_fileName componentsSeparatedByString:@"."];
    //NSString *finalName = [[nameArray objectAtIndex:0] stringByAppendingString:@".dat"];
    NSString *finalName = [[nameArray objectAtIndex:0] stringByAppendingString:@".dat"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *cloudPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Documents"];
    cloudPath = [cloudPath stringByAppendingPathComponent:@"iCloudMetadata"];
    NSString *fileCloudPath = [cloudPath stringByAppendingPathComponent:finalName];
    return fileCloudPath;
}

- (NSString *) metadataCloudPath {
    NSArray *nameArray = [_fileName componentsSeparatedByString:@"."];
    NSString *finalName = [[nameArray objectAtIndex:0] stringByAppendingString:@".pgn"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *cloudPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Documents"];
    cloudPath = [cloudPath stringByAppendingPathComponent:@"iCloudMetadata"];
    NSString *fileCloudPath = [cloudPath stringByAppendingPathComponent:finalName];
    return fileCloudPath;
}
*/

- (NSString *) getCompletePathAndName {
    return _path;
}

- (NSNumber *)numberOfGames {
    //if (!_numberOfGames) {
    //    NSLog(@"Calcolo numero partite");
    //    [self calcNumberOfGames];
    //}
    _numberOfGames = [NSNumber numberWithInteger:allGamesAndTags.count];
    return _numberOfGames;
}

- (NSArray *)listOfTags {
    if (!_listOfTags    ) {
        NSLog(@"Cerco i tag");
        [self searchAllTags];
    }
    return _listOfTags;
}

- (NSArray *)listOfEvents {
    if (!_listOfEvents) {
        NSLog(@"Cerco i gli eventi");
        [self searchListOfEvents];
    }
    return _listOfEvents;
}

- (NSArray *)listOfEco {
    if (!_listOfEco) {
        NSLog(@"Cerco ECO");
        [self searchListOfEco];
    }
    return _listOfEco;
}

- (NSArray *)listOfGames {
    if (!_listOfGames) {
        NSLog(@"Cerco Games");
        [self searchListOfGames];
    }
    return _listOfGames;
}

- (NSArray *)listOfPlayers {
    if (!_listOfPlayers) {
        NSLog(@"Cerco List Of Players");
        [self searchListOfGames];
    }
    return _listOfPlayers;
}

- (NSArray *)allGames {
    if (!_allGames) {
        NSLog(@"Estraggo le partite");
        [self searchAllGames];
    }
    return _allGames;
}

- (NSArray *)listOfYears {
    if (!_listOfYears) {
        NSLog(@"Estraggo tutti gli years");
        [self searchAllYears];
    }
    return _listOfYears;
}

- (NSArray *) allTagsOfGames {
    if (!_allTagsOfGames) {
        NSLog(@"Calcolo AllTagsOfGames");
        [self searchAllTagOfAllGames];
    }
    return _allTagsOfGames;
}

- (NSString *) getDataCreazione {
    NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:_path error:nil];
    NSDate *data = [fileAttr fileCreationDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    //[dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:data];
    //return [NSDateFormatter localizedStringFromDate:_dataCreazione dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *) description {
    NSString *descr = [NSString stringWithFormat:@"Database %@ con %d partite", _fileName, _numberOfGames.intValue];
    return descr;
}

- (NSArray *) getValueOfTag:(NSString *)tag {
    NSLog(@"TAG IN INGRESSO: %@", tag);
    NSString *tagSenzaParentesi = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([tag hasPrefix:@"["] && [tag hasSuffix:@"]"]) {
        tagSenzaParentesi = [tag stringByTrimmingCharactersInSet:setQuadre];
    }
    NSArray *temp = [tagSenzaParentesi componentsSeparatedByString:@" "];
    if (temp.count == 2) {
        NSString *tagSymbol = [temp objectAtIndex:0];
        NSString *tagValueSenzaApici = [[temp objectAtIndex:1] stringByTrimmingCharactersInSet:setDoppiApici];
        NSLog(@"TAG  IN USCITA: %@ --> %@", tagSymbol, tagValueSenzaApici);
        NSArray *risu = [NSArray arrayWithObjects:tagSymbol, tagValueSenzaApici, nil];
        return risu;
    }
    NSLog(@"TAG VALUE IN USCITA: NIL");
    return nil;
}

- (void) calcNumberOfGames {
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    NSInteger numOfGames = 0;
    while ((line = [reader readLine])) {
        if ([line hasPrefix:@"[Event "]) {
            numOfGames++;
        }
    }
    _numberOfGames = [NSNumber numberWithInteger:numOfGames];
}

- (void) searchAllTags {
    NSMutableArray *listaOfTags = [[NSMutableArray alloc] init];
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    while ((line = [reader readLine])) {
        if ([line hasPrefix:@"["]) {
            line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
            NSRange bRange = [stringaSenzaParentesi rangeOfString:@" "];
            NSString *tag = [stringaSenzaParentesi substringToIndex:bRange.location];
            tag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![listaOfTags containsObject:tag]) {
                [listaOfTags addObject:tag];
            }
        }
    }
    _listOfTags = [NSArray arrayWithArray:listaOfTags];
}

- (void) searchListOfEvents {
    NSMutableArray *loe = [[NSMutableArray alloc] init];
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    while ((line = [reader readLine])) {
        if ([line hasPrefix:@"[Event "]) {
            line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
            NSRange bRange = [stringaSenzaParentesi rangeOfString:@" "];
            NSString *event = [stringaSenzaParentesi substringFromIndex:bRange.location];
            event = [event stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            event = [event stringByTrimmingCharactersInSet:setDoppiApici];
            if (![loe containsObject:event]) {
                [loe addObject:event];
            }
        }
    }
    _listOfEvents = [NSArray arrayWithArray:loe];
}

- (void) searchListOfEco {
    NSMutableArray *loe = [[NSMutableArray alloc] init];
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    while ((line = [reader readLine])) {
        if ([line hasPrefix:@"[ECO "]) {
            line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
            NSRange bRange = [stringaSenzaParentesi rangeOfString:@" "];
            NSString *eco = [stringaSenzaParentesi substringFromIndex:bRange.location];
            eco = [eco stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            eco = [eco stringByTrimmingCharactersInSet:setDoppiApici];
            if (![loe containsObject:eco]) {
                [loe addObject:eco];
            }
        }
    }
    _listOfEco = [[NSArray arrayWithArray:loe] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (void) searchListOfGames {
    NSMutableArray *log = [[NSMutableArray alloc] init];
    NSMutableSet *lop = [[NSMutableSet alloc] init];
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    NSString *white;
    NSString *black;
    while ((line = [reader readLine])) {
        if ([line hasPrefix:@"[White "]) {
            line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
            NSRange bRange = [stringaSenzaParentesi rangeOfString:@" "];
            white = [stringaSenzaParentesi substringFromIndex:bRange.location];
            white = [white stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            white = [white stringByTrimmingCharactersInSet:setDoppiApici];
        }
        if ([line hasPrefix:@"[Black "]) {
            line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
            NSRange bRange = [stringaSenzaParentesi rangeOfString:@" "];
            black = [stringaSenzaParentesi substringFromIndex:bRange.location];
            black = [black stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            black = [black stringByTrimmingCharactersInSet:setDoppiApici];
        }
        if (white && black) {
            NSString *g = [[white stringByAppendingString:@" - "] stringByAppendingString:black];
            [log addObject:g];
            [lop addObject:white];
            [lop addObject:black];
            white = nil;
            black = nil;
        }
    }
    _listOfGames = [NSArray arrayWithArray:log];
    _listOfPlayers = [NSArray arrayWithArray:[lop allObjects]];
    _listOfPlayers = [_listOfPlayers sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (void) searchAllGames {
    
    //NSString *bishop = @"\u2657";
    //NSString *king = @"♔";
    //NSString *queen = @"♕";
    //NSString *rook = @"♖";
    //NSString *knight = @"♘";
    
    NSMutableArray *allGames = [[NSMutableArray alloc] init];
    NSMutableString *game = nil;
    NSMutableString *moves = nil;
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    while ((line = [reader readLine])) {
        
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"[Event "]) {
            game = [[NSMutableString alloc] initWithString:line];
            [game appendString:separator];
        }
        
        if ([line hasPrefix:@"["]  && ![line hasPrefix:@"[Event "]) {
            [game appendString:line];
            [game appendString:separator];
        }
        
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            if (!moves) {
                moves = [[NSMutableString alloc] initWithString:line];
            }
            else {
                [moves appendString:@" "];
                [moves appendString:line];
            }
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"] || [line hasSuffix:@"*"]) {
                //NSString *newMoves = [moves stringByReplacingOccurrencesOfString:@"N" withString:knight];
                //newMoves = [newMoves stringByReplacingOccurrencesOfString:@"B" withString:bishop];
                //newMoves = [newMoves stringByReplacingOccurrencesOfString:@"R" withString:rook];
                //newMoves = [newMoves stringByReplacingOccurrencesOfString:@"Q" withString:queen];
                //newMoves = [newMoves stringByReplacingOccurrencesOfString:@"K" withString:king];
                [game appendString:moves];
                [allGames addObject:game];
                game = nil;
                moves = nil;
            }
        }
    }
    _allGames = [NSArray arrayWithArray:allGames];
}

- (void) searchAllTagOfAllGames {
    NSMutableArray *allTags = [[NSMutableArray alloc] init];
    NSMutableString *tagsOfGame = nil;
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([line hasPrefix:@"[Event "]) {
            tagsOfGame = [[NSMutableString alloc] initWithString:line];
            [tagsOfGame appendString:separator];
        }
        if ([line hasPrefix:@"["]  && ![line hasPrefix:@"[Event "]) {
            [tagsOfGame appendString:line];
            [tagsOfGame appendString:separator];
        }
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"]) {
                [tagsOfGame deleteCharactersInRange:NSMakeRange([tagsOfGame length] - 1, 1)];
                [allTags addObject:tagsOfGame];
                tagsOfGame = nil;
            }
        }
    }
    _allTagsOfGames = [NSArray arrayWithArray:allTags];
}

- (void) searchAllYears {
    NSMutableSet *allYears = [[NSMutableSet alloc] init];
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([line hasPrefix:@"[Date "]) {
            NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
            NSRange bRange = [stringaSenzaParentesi rangeOfString:@" "];
            NSString *data = [stringaSenzaParentesi substringFromIndex:bRange.location];
            data = [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            data = [data stringByTrimmingCharactersInSet:setDoppiApici];
            NSArray *dataArray = [data componentsSeparatedByString:@"."];
            NSString *anno = [dataArray objectAtIndex:0];
            [allYears addObject:anno];
        }
    }
    _listOfYears = [[NSArray arrayWithArray:[allYears allObjects]] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

/*
- (NSArray *) findGamesByEco:(NSString *)eco {
    NSMutableArray *games = [[NSMutableArray alloc] init];
    PGNDocumentGame *game;
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    BOOL found;
    BOOL foundECO = NO;
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"[Event "]) {
            foundECO = NO;
            game = [[PGNDocumentGame alloc] init];
            [game addTag:line];
        }
        
        if ([line hasPrefix:@"[ECO "]) {
            foundECO = YES;
            NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
            NSRange bRange = [stringaSenzaParentesi rangeOfString:@" "];
            NSString *ecoInGame = [stringaSenzaParentesi substringFromIndex:bRange.location];
            ecoInGame = [ecoInGame stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            ecoInGame = [ecoInGame stringByTrimmingCharactersInSet:setDoppiApici];
            found = [ecoInGame isEqualToString:eco];
            if (found) {
                [game addTag:line];
            }
            else {
                game = nil;
            }
        }
        
        if ([line hasPrefix:@"["]) {
            if (game) {
                [game addTag:line];
            }
        }
        
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            NSString *line1 = [line stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            line1 = [line1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (game) {
                [game addMovesLine:line1];
            }
            if ([line1 hasSuffix:@"1-0"] || [line1 hasSuffix:@"0-1"] || [line1 hasSuffix:@"1/2-1/2"]) {
                if (game && foundECO) {
                    [games addObject:game];
                    game = nil;
                    foundECO = NO;
                }
            }
        }
    }
    return games;
}
*/

- (NSArray *)findGamesByOpeningTag {
    NSMutableArray *allOpeningTags = [[NSMutableArray alloc] init];
    NSMutableString *opTags = nil;
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"[Event "]) {
            opTags = [[NSMutableString alloc] init];
        }
        
        NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
        for (NSString *t in openingTag) {
            if ([stringaSenzaParentesi hasPrefix:t]) {
                [opTags appendString:line];
                [opTags appendString:separator];
                break;
            }
        }
        
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"]) {
                if (opTags.length > 0) {
                    [opTags deleteCharactersInRange:NSMakeRange([opTags length] - 1, 1)];
                    [allOpeningTags addObject:opTags];
                }
                opTags = nil;
            }
        }
    }
    return allOpeningTags;
}

- (NSArray *)findGamesByStrTag {
    NSMutableArray *allStrTags = [[NSMutableArray alloc] init];
    NSMutableString *strTags = nil;
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"[Event "]) {
            strTags = [[NSMutableString alloc] init];
        }
        
        NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
        
        for (NSString *t in strTag) {
            if ([stringaSenzaParentesi hasPrefix:t]) {
                [strTags appendString:line];
                [strTags appendString:separator];
                break;
            }
        }
        
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"]) {
                if (strTags.length > 0) {
                    [strTags deleteCharactersInRange:NSMakeRange([strTags length] - 1, 1)];
                    [allStrTags addObject:strTags];
                }
                strTags = nil;
            }
        }
    }
    return allStrTags;
}

- (NSArray *) findGamesByPlayerTag {
    NSMutableArray *allPlayerTags = [[NSMutableArray alloc] init];
    NSMutableString *playerTags = nil;
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"[Event "]) {
            playerTags = [[NSMutableString alloc] init];
        }
        
        NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
        
        for (NSString *t in playerTag) {
            if ([stringaSenzaParentesi hasPrefix:t]) {
                [playerTags appendString:line];
                [playerTags appendString:separator];
                break;
            }
        }
        
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"]) {
                if (playerTags.length > 0) {
                    [playerTags deleteCharactersInRange:NSMakeRange([playerTags length] - 1, 1)];
                    [allPlayerTags addObject:playerTags];
                }
                playerTags = nil;
            }
        }
    }
    return allPlayerTags;
}

- (NSArray *) findGamesByTournamentTag {
    NSMutableArray *allTournTags = [[NSMutableArray alloc] init];
    NSMutableString *tournTags = nil;
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"[Event "]) {
            tournTags = [[NSMutableString alloc] init];
        }
        
        NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
        
        for (NSString *t in tournamentTag) {
            if ([stringaSenzaParentesi hasPrefix:t]) {
                [tournTags appendString:line];
                [tournTags appendString:separator];
                break;
            }
        }
        
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"]) {
                if (tournTags.length > 0) {
                    [tournTags deleteCharactersInRange:NSMakeRange([tournTags length] - 1, 1)];
                    [allTournTags addObject:tournTags];
                }
                tournTags = nil;
            }
        }
    }
    return allTournTags;
}

- (NSArray *) findGamesByTag:(NSString *)tag {
    NSArray *tagArray;
    if ([tag isEqualToString:@"STR_TAG"]) {
        tagArray = strTag;
    }
    if ([tag isEqualToString:@"PLAYER_TAG"]) {
        tagArray = playerTag;
    }
    if ([tag isEqualToString:@"WHITE_PLAYER_TAG"]) {
        tagArray = whitePlayerTag;
    }
    if ([tag isEqualToString:@"BLACK_PLAYER_TAG"]) {
        tagArray = blackPlayerTag;
    }
    if ([tag isEqualToString:@"TOURNAMENT_TAG"]) {
        tagArray = tournamentTag;
    }
    if ([tag isEqualToString:@"OPENING_TAG"]) {
        tagArray = openingTag;
    }
    if ([tag isEqualToString:@"EVENT_TAG"]) {
        tagArray = eventTag;
    }
    if ([tag isEqualToString:@"ECO_TAG"]) {
        tagArray = ecoTag;
    }
    if ([tag isEqualToString:@"GAME_TAG"]) {
        tagArray = gameTag;
    }
    //NSMutableArray *allTags = [[NSMutableArray alloc] init];
    NSMutableSet *allTags = [[NSMutableSet alloc] init];
    NSMutableString *tags = nil;
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"[Event "]) {
            tags = [[NSMutableString alloc] init];
        }
        
        NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
        
        for (NSString *t in tagArray) {
            if ([stringaSenzaParentesi hasPrefix:t]) {
                [tags appendString:line];
                [tags appendString:separator];
                break;
            }
        }
        
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"]) {
                if (tags.length > 0) {
                    [tags deleteCharactersInRange:NSMakeRange([tags length] - 1, 1)];
                    [allTags addObject:tags];
                }
                tags = nil;
            }
        }
    }
    return [[allTags allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSArray *) findGamesByTagArray:(NSArray *)tagArray {
    
    
    //Deve restituire un array contente i tag riferiti alle partite nel file specificati in tagArray
    //I tag nel risultato devono essere separati dal simbolo |
    //Il tag risultato deve essere nello stesso ordine del tag di input
    
    NSMutableArray *allTags = [[NSMutableArray alloc] init];//array con i risultati
    NSMutableString *tags = nil; //string di tag trovata  nella partita
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    
    //Il seguente array serve per poter ottenere i tag risultato nello stesso ordine dei tag di input
    NSMutableArray *stringArray = [[NSMutableArray alloc] init];
    for (int i=0; i<tagArray.count; i++) {
        [stringArray addObject:@" "];
    }
    
    //NSLog(@"StringArray contiene %d elementi", stringArray.count);
    
    while ((line = [reader readLine])) { //legge una linea
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //elimina eventuali caratteri a inizio e fine linea
        
        if ([line hasPrefix:@"[Event "]) {
            tags = [[NSMutableString alloc] init];  //se trovo [Event reinizializzo i valori
            for (int i=0; i<tagArray.count; i++) {
                [stringArray replaceObjectAtIndex:i withObject:@" "];
            }
        }
        
        NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre]; //Tolgo le parentesi quadre del tag trovato
        
        for (NSString *t in tagArray) {
            if ([stringaSenzaParentesi hasPrefix:t]) {
                
                NSArray *gArray = [stringaSenzaParentesi componentsSeparatedByString:@"\""];
                NSString *stringaSenzaApici = [gArray objectAtIndex:1];
                //[tags appendString:stringaSenzaApici];
                
                NSString *tag = [gArray objectAtIndex:0];
                
                //NSLog(@"Il tag di cui devo cercare l'indice è %@", tag);
                //[stringArray setObject:stringaSenzaParentesi atIndexedSubscript:[tagArray indexOfObject:tag]];
                [stringArray replaceObjectAtIndex:[tagArray indexOfObject:tag] withObject:stringaSenzaApici];
                
                //[tags appendString:stringaSenzaParentesi];
                //[tags appendString:separator];
                break;
            }
        }
        
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"] || [line hasSuffix:@"*"]) {
                /*
                if (tags.length > 0) {
                    [tags deleteCharactersInRange:NSMakeRange([tags length] - 1, 1)];
                    [allTags addObject:tags];
                }
                tags = nil;
                 */
                for (NSString *s in stringArray) {
                    if (s.length > 1) {
                        [tags appendString:s];
                        [tags appendString:separator];
                    }
                }
                [tags deleteCharactersInRange:NSMakeRange([tags length] - 1, 1)];
                [allTags addObject:tags];
            }
        }
    }
    //return [[allTags allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    //return [allTags allObjects];
    return  allTags;
}

- (NSArray *) findGamesByTagArray2:(NSArray *)tagArray {
    NSMutableArray *risuArray = [[NSMutableArray alloc] init];//array con i risultati
    NSMutableString *tags = nil;
    
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    int ng = 0;
    
    while ((line = [reader readLine])) { //legge una linea
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //elimina eventuali caratteri a inizio e fine linea
        if ([line hasPrefix:@"[Event "]) {
            tags = [[NSMutableString alloc] init];  //se trovo [Event reinizializzo i valori
            ng++;
        }
        
        NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre]; //Tolgo le parentesi quadre del tag trovato
        
        for (NSString *t in tagArray) {
            if ([stringaSenzaParentesi hasPrefix:t]) {
                
                NSArray *arrayConTagSenzaApici = [stringaSenzaParentesi componentsSeparatedByString:@"\""];
                NSString *stringaSenzaApici = [arrayConTagSenzaApici objectAtIndex:1];
                
                [tags appendString:stringaSenzaApici];
                [tags appendString:separator];
                break;
            }
        }
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"] || [line hasSuffix:@"*"]) {
                if (tags.length > 0) {
                    //NSString *num = [NSString stringWithFormat:@"%d", ng];
                    //[tags appendString:num];
                    //[tags appendString:separator];
                    
                    if (tags.length == 4) {
                        NSString *subTags = [tags substringToIndex:4];
                        [tags appendString:subTags];
                    }
                    
                    
                    [tags deleteCharactersInRange:NSMakeRange([tags length] - 1, 1)];
                    [risuArray addObject:tags];
                }
            }
        }
    }
    
    return risuArray;
}


//Trova tutte le informazioni sui tag passati eliminando i doppioni
- (NSArray *) findInfoByTagArray:(NSArray *)tagArray {
    //NSMutableSet *allTags = [[NSMutableSet alloc] init];
    NSMutableArray *allTags = [[NSMutableArray alloc] init];
    NSMutableString *tags = nil;
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    
    
    NSMutableArray *stringArray = [[NSMutableArray alloc] init];
    for (int i=0; i<tagArray.count; i++) {
        [stringArray addObject:@" "];
    }
    
    //NSLog(@"StringArray contiene %d elementi", stringArray.count);
    
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"[Event "]) {
            tags = [[NSMutableString alloc] init];
        }
        
        NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
        
        for (NSString *t in tagArray) {
            if ([stringaSenzaParentesi hasPrefix:t]) {
                
                NSArray *gArray = [stringaSenzaParentesi componentsSeparatedByString:@"\""];
                NSString *stringaSenzaApici = [gArray objectAtIndex:1];
                //[tags appendString:stringaSenzaApici];
                
                NSString *tag = [gArray objectAtIndex:0];
                
                //NSLog(@"Il tag di cui devo cercare l'indice è %@", tag);
                //[stringArray setObject:stringaSenzaParentesi atIndexedSubscript:[tagArray indexOfObject:tag]];
                [stringArray replaceObjectAtIndex:[tagArray indexOfObject:tag] withObject:stringaSenzaApici];
                
                //[tags appendString:stringaSenzaParentesi];
                //[tags appendString:separator];
                break;
            }
        }
        
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"] || [line hasSuffix:@"*"]) {
                /*
                 if (tags.length > 0) {
                 [tags deleteCharactersInRange:NSMakeRange([tags length] - 1, 1)];
                 [allTags addObject:tags];
                 }
                 tags = nil;
                 */
                for (NSString *s in stringArray) {
                    [tags appendString:s];
                    [tags appendString:separator];
                }
                [tags deleteCharactersInRange:NSMakeRange([tags length] - 1, 1)];
                
                if (![allTags containsObject:tags]) {
                    [allTags addObject:tags];
                }
                
            
            }
        }
    }
    //return [[allTags allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    //return [allTags allObjects];
    return  allTags;
}

- (NSArray *) findForfaitGames {
    NSMutableString *game = nil;
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"[Event "]) {
            game = [[NSMutableString alloc] init];
        }
        
        //NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
        
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            if ([line rangeOfString:@"2."].location == NSNotFound) {
                if ([line rangeOfString:@"1-0"].location != NSNotFound  || [line rangeOfString:@"0-1"].location != NSNotFound  || [line rangeOfString:@"1/2-1/2"].location != NSNotFound) {
                    if ([line hasPrefix:@"1."] || [line hasPrefix:@"0"]) {
                        //NSArray *mosse = [line componentsSeparatedByString:@" "];
                        //for (NSString *mossa in mosse) {
                        //    NSString *mossa1 = [mossa stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        //    NSLog(@"Mossa: %@", mossa1);
                        //}
                        NSLog(@"%@", line);
                    }
                    
                }
            }
        }
        
        /*
         if ((line.length > 2) && ![line hasPrefix:@"["] && ([line hasPrefix:@"1."] || [line hasPrefix:@"0"])) {
         if ([line rangeOfString:@"1-0"].location != NSNotFound  || [line rangeOfString:@"0-1"].location != NSNotFound  || [line rangeOfString:@"1/2-1/2"].location != NSNotFound) {
         NSLog(@">>>>>>>>>>    %@", line);
         }
         }*/
    }
    return nil;
}


- (NSArray *) getAllGames {
    if (_allGames) {
        return _allGames;
    }
    NSArray *tagArray = [NSArray arrayWithObjects:@"White ", @"Black ", @"Result ", @"ECO ", @"Event ", @"Site ", @"EventDate ", @"EventCountry ", nil];
    _allGames = [self findGamesByTagArray:tagArray];
    return _allGames;
    //return [self findGamesByTagArray:tagArray];
}

 
- (NSArray *) getAllEvents {
    NSArray *tagArray = [NSArray arrayWithObjects:@"Event ", @"Site ", @"EventDate ", @"EventCountry ", nil];
    return [self findInfoByTagArray:tagArray];
}

- (NSDictionary *) getAllEventsByDictionary {
    if (!allGamesByRegex) {
        allGamesByRegex = [self getAllGamesByRegex];
    }
    
    NSMutableDictionary *eventDictionaryCompleto = [[NSMutableDictionary alloc] init];
    
    NSError *error = NULL;
    NSString *pattern = @"\\[Event \"(?:[^\\\"]+|\\.)*\"\\]|\\[Site \"(?:[^\\\"]+|\\.)*\"\\]|\\[EventDate \"(?:[^\\\"]+|\\.)*\"\\]|\\[EventCountry \"(?:[^\\\"]+|\\.)*\"\\]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    for (NSString *gameInTag in allGamesByRegex) {
        NSArray *matches = [regex matchesInString:gameInTag options:0 range:NSMakeRange(0, [gameInTag length])];
        NSMutableString *matchStringCompleta = [[NSMutableString alloc] init];
        for (NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match range];
            NSString *subString = [gameInTag substringWithRange:matchRange];
            [matchStringCompleta appendString:subString];
        }
        if (matchStringCompleta.length > 0) {
            if ([eventDictionaryCompleto.allKeys containsObject:matchStringCompleta]) {
                NSNumber *n = [eventDictionaryCompleto objectForKey:matchStringCompleta];
                int num = [n intValue];
                num++;
                NSNumber *newNum = [NSNumber numberWithInt:num];
                [eventDictionaryCompleto removeObjectForKey:matchStringCompleta];
                [eventDictionaryCompleto setObject:newNum forKey:matchStringCompleta];
            }
            else {
                NSNumber *n = [NSNumber numberWithInt:1];
                [eventDictionaryCompleto setObject:n forKey:matchStringCompleta];
            }
        }
    }
    return eventDictionaryCompleto;
}

- (NSCountedSet *) getAllEventsByCountedSet {
    //if (!allGamesByRegex) {
        //allGamesByRegex = [self getAllGamesByRegex];
        ////allGamesByRegex = [self getAllGamesAndTags];
    //}
    if (!allGamesAndTags) {
        allGamesAndTags = [self caricaTutteLePartite];
    }
    
    //NSLog(@"In origine ho trovato %d eventi", allGamesByRegex.count);
    
    NSCountedSet *eventsByCountedSet = [[NSCountedSet alloc] init];
    
    NSError *error = NULL;
    NSString *pattern = @"\\[Event \"(?:[^\\\"]+|\\.)*\"\\]|\\[Site \"(?:[^\\\"]+|\\.)*\"\\]|\\[EventDate \"(?:[^\\\"]+|\\.)*\"\\]|\\[EventCountry \"(?:[^\\\"]+|\\.)*\"\\]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    for (NSString *gameInTag in allGamesAndTags) {
        NSArray *matches = [regex matchesInString:gameInTag options:0 range:NSMakeRange(0, [gameInTag length])];
        NSMutableString *matchStringCompleta = [[NSMutableString alloc] init];
        for (NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match range];
            NSString *subString = [gameInTag substringWithRange:matchRange];
            [matchStringCompleta appendString:subString];
        }
        if (matchStringCompleta.length>0) {
            [eventsByCountedSet addObject:matchStringCompleta];
        }
    }
    
    return eventsByCountedSet;
}

- (NSCountedSet *) getAllDateByCountedSet {
    //if (!allGamesByRegex) {
    //    allGamesByRegex = [self getAllGamesByRegex];
    //}
    
    if (!allGamesAndTags) {
        allGamesAndTags = [self caricaTutteLePartite];
    }
    
    NSCountedSet *dateByCountedSet = [[NSCountedSet alloc] init];
    
    NSError *error = NULL;
    NSString *pattern = @"\\[Date \"(?:[^\\\"]+|\\.)*\"\\]|";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    for (NSString *gameInTag in allGamesAndTags) {
        NSArray *matches = [regex matchesInString:gameInTag options:0 range:NSMakeRange(0, [gameInTag length])];
        NSMutableString *matchStringCompleta = [[NSMutableString alloc] init];
        for (NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match range];
            NSString *subString = [gameInTag substringWithRange:matchRange];
            [matchStringCompleta appendString:subString];
        }
        if (matchStringCompleta.length>0) {
            NSString *data = [matchStringCompleta stringByTrimmingCharactersInSet:setQuadre];
            NSArray *dataArray = [data componentsSeparatedByString:@" "];
            data = [[dataArray objectAtIndex:1] stringByTrimmingCharactersInSet:setDoppiApici];
            dataArray = [data componentsSeparatedByString:@"."];
            [dateByCountedSet addObject:[dataArray objectAtIndex:0]];
        }
    }
    
    return dateByCountedSet;
}



- (NSArray *) getAllEco {
    //NSArray *tagArray = [NSArray arrayWithObjects:@"ECO ", @"Opening ", @"Variation ", @"Subvariation ", nil];
    //NSArray *ecoArray = [NSArray arrayWithObjects:@"ECO ", nil];
    //return [[self findGamesByTagArray2:tagArray] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    if (!allGamesByRegex) {
        allGamesByRegex = [self getAllGamesByRegex];
    }
    
    NSMutableArray *gameRisu = [[NSMutableArray alloc] init];
    NSError *error = NULL;
    //NSString *pattern = @"\\[ECO \"...\"\\]|\\[Opening \"(?:[^\\\"]+|\\.)*\"\\]|(\[Variation \"(?:[^\\\"\\]+|\\.)*\"\\])|(\[Subvariation \"(?:[^\\\"\\]+|\\.)*\"\\]\")";
    NSString *pattern = @"\\[ECO \"...\"\\]|\\[Opening \"(?:[^\\\"]+|\\.)*\"\\]|\\[Variation \"(?:[^\\\"]+|\\.)*\"\\]|\\[Subvariation \"(?:[^\\\"]+|\\.)*\"\\]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    //NSLog(@"%@", regex.pattern);
    
    for (NSString *gameInTag in allGamesByRegex) {
        //NSUInteger match = [regex numberOfMatchesInString:gameInTag options:0 range:NSMakeRange(0, [gameInTag length])];
        //if (match > 0) {
        //    [gameRisu addObject:gameInTag];
        //}
        //NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:gameInTag options:0 range:NSMakeRange(0, [gameInTag length])];
        NSArray *matches = [regex matchesInString:gameInTag options:0 range:NSMakeRange(0, [gameInTag length])];
        NSMutableString *matchString = [[NSMutableString alloc] init];
        for (NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match range];
            NSString *subString = [gameInTag substringWithRange:matchRange];
            
            NSString *stringaSenzaParentesi = [subString stringByTrimmingCharactersInSet:setQuadre];
            NSArray *arrayConTagSenzaApici = [stringaSenzaParentesi componentsSeparatedByString:@"\""];
            NSString *stringaSenzaApici = [arrayConTagSenzaApici objectAtIndex:1];
            
            [matchString appendString:stringaSenzaApici];
            
            [matchString appendString:separator];
            if (matches.count == 1) {
                [matchString appendString:stringaSenzaApici];
                [matchString appendString:separator];
            }
            
        }
        if (matchString.length > 0) {
            [matchString deleteCharactersInRange:NSMakeRange([matchString length] - 1, 1)];
            [gameRisu addObject:matchString];
        }
        
        //if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        //    NSString *substringFromFirstMatch = [gameInTag substringWithRange:rangeOfFirstMatch];
        //    [gameRisu addObject:substringFromFirstMatch];
        //}
        
    }
    return gameRisu;
    
    //return [self findGamesByTagArray2:tagArray];
    //return [[self findGamesByTagArray:tagArray] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSDictionary *) getAllEcoByDictionary {
    if (!allGamesByRegex) {
        allGamesByRegex = [self getAllGamesByRegex];
    }
    NSError *error = NULL;
    NSString *pattern = @"\\[ECO \"...\"\\]|\\[Opening \"(?:[^\\\"]+|\\.)*\"\\]|\\[Variation \"(?:[^\\\"]+|\\.)*\"\\]|\\[Subvariation \"(?:[^\\\"]+|\\.)*\"\\]";
    //NSString *ecoPattern = @"\\[ECO \"...\"\\]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    //NSRegularExpression *ecoRegex = [[NSRegularExpression alloc] initWithPattern:ecoPattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSMutableDictionary *ecoDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *gameInTag in allGamesByRegex) {
        
        //NSRange ecoMatchRange = [ecoRegex rangeOfFirstMatchInString:gameInTag options:0 range:NSMakeRange(0, [gameInTag length])];
        //NSString *ecoString;
        //if (!NSEqualRanges(ecoMatchRange, NSMakeRange(NSNotFound, 0))) {
        //    ecoString = [gameInTag substringWithRange:ecoMatchRange];
            //NSLog(@"ECO MATCH = %@", ecoString);
        //}
        
        NSArray *matches = [regex matchesInString:gameInTag options:0 range:NSMakeRange(0, [gameInTag length])];
        NSMutableString *matchString = [[NSMutableString alloc] init];
        for (NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match range];
            NSString *subString = [gameInTag substringWithRange:matchRange];
            
            //NSString *stringaSenzaParentesi = [subString stringByTrimmingCharactersInSet:setQuadre];
            //NSArray *arrayConTagSenzaApici = [stringaSenzaParentesi componentsSeparatedByString:@"\""];
            //NSString *stringaSenzaApici = [arrayConTagSenzaApici objectAtIndex:1];
            
            
            [matchString appendString:subString];
            //[matchString appendString:separator];
            //if (matches.count == 1) {
            //    [matchString appendString:stringaSenzaApici];
            //    [matchString appendString:separator];
            //}
        }
        
        /*
        if (ecoString && matchString.length>0) {
            if ([matchString hasPrefix:ecoString]) {
                if ([ecoDictionary.allKeys containsObject:matchString]) {
                    NSNumber *n = [ecoDictionary objectForKey:matchString];
                    int num = [n intValue];
                    NSNumber *newNum = [NSNumber numberWithInt:num];
                    [ecoDictionary removeObjectForKey:matchString];
                    [ecoDictionary setObject:newNum forKey:matchString];
                }
                else {
                    NSNumber *n = [NSNumber numberWithInt:1];
                    [ecoDictionary setObject:n forKey:matchString];
                }
            }
        }*/
        
        
        
        if (matchString.length > 0) {
            //[matchString deleteCharactersInRange:NSMakeRange([matchString length] - 1, 1)];
            if ([ecoDictionary.allKeys containsObject:matchString]) {
                NSNumber *n = [ecoDictionary objectForKey:matchString];
                int num = [n intValue];
                num++;
                NSNumber *newNum = [NSNumber numberWithInt:num];
                [ecoDictionary removeObjectForKey:matchString];
                [ecoDictionary setObject:newNum forKey:matchString];
            }
            else {
                NSNumber *n = [NSNumber numberWithInt:1];
                [ecoDictionary setObject:n forKey:matchString];
            }
        }
    }
    return ecoDictionary;
}

- (NSCountedSet *) getAllEcoByCountedSet {
    //if (!allGamesByRegex) {
    //    allGamesByRegex = [self getAllGamesByRegex];
    //}
    
    if (!allGamesAndTags) {
        allGamesAndTags = [self caricaTutteLePartite];
    }
    
    NSError *error = NULL;
    NSString *pattern = @"\\[ECO \"...\"\\]|\\[Opening \"(?:[^\\\"]+|\\.)*\"\\]|\\[Variation \"(?:[^\\\"]+|\\.)*\"\\]|\\[Subvariation \"(?:[^\\\"]+|\\.)*\"\\]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSCountedSet *ecoCountedSet = [[NSCountedSet alloc] init];
    
    for (NSString *gameInTag in allGamesAndTags) {
        NSArray *matches = [regex matchesInString:gameInTag options:0 range:NSMakeRange(0, [gameInTag length])];
        NSMutableString *matchString = [[NSMutableString alloc] init];
        for (NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match range];
            NSString *subString = [gameInTag substringWithRange:matchRange];
            [matchString appendString:subString];
        }
        if (matchString.length>0) {
            [ecoCountedSet addObject:matchString];
        }
    }
    return ecoCountedSet;
}

- (NSDictionary *) getAllEcoByClassification {
    if (!allGamesByRegex) {
        allGamesByRegex = [self getAllGamesByRegex];
    }
    NSMutableDictionary *ecoABCDE = [[NSMutableDictionary alloc] init];
    NSError *error = NULL;
    NSString *pattern = @"\\[ECO \"...\"\\]|\\[Opening \"(?:[^\\\"]+|\\.)*\"\\]|\\[Variation \"(?:[^\\\"]+|\\.)*\"\\]|\\[Subvariation \"(?:[^\\\"]+|\\.)*\"\\]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSCountedSet *ecoA = [[NSCountedSet alloc] init];
    NSCountedSet *ecoB = [[NSCountedSet alloc] init];
    NSCountedSet *ecoC = [[NSCountedSet alloc] init];
    NSCountedSet *ecoD = [[NSCountedSet alloc] init];
    NSCountedSet *ecoE = [[NSCountedSet alloc] init];
    
    for (NSString *gameInTag in allGamesByRegex) {
        NSArray *matches = [regex matchesInString:gameInTag options:0 range:NSMakeRange(0, [gameInTag length])];
        NSMutableString *matchString = [[NSMutableString alloc] init];
        for (NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match range];
            NSString *subString = [gameInTag substringWithRange:matchRange];
            [matchString appendString:subString];
        }
        if (matchString.length>0) {
            //NSLog(@"ECO CLASSIFICATION: %@", matchString);
            if ([matchString rangeOfString:@"[ECO \"A"].length>0 ) {
                [ecoA addObject:matchString];
            }
            if ([matchString rangeOfString:@"[ECO \"B"].length>0 ) {
                [ecoB addObject:matchString];
            }
            if ([matchString rangeOfString:@"[ECO \"C"].length>0 ) {
                [ecoC addObject:matchString];
            }
            if ([matchString rangeOfString:@"[ECO \"D"].length>0 ) {
                [ecoD addObject:matchString];
            }
            if ([matchString rangeOfString:@"[ECO \"E"].length>0 ) {
                [ecoE addObject:matchString];
            }
        }
    }
    
    [ecoABCDE setObject:ecoA forKey:@"A"];
    [ecoABCDE setObject:ecoB forKey:@"B"];
    [ecoABCDE setObject:ecoC forKey:@"C"];
    [ecoABCDE setObject:ecoD forKey:@"D"];
    [ecoABCDE setObject:ecoE forKey:@"E"];
    
    return ecoABCDE;
}

- (NSArray *) getAllPlayers {
    if (!allGamesByRegex) {
        allGamesByRegex = [self getAllGamesByRegex];
    }
    
    NSMutableSet *playerSet = [[NSMutableSet alloc] init];
    
    NSString *patternWhite = @"White \"(?:[^\\\"]+|\\.)*\"";
    NSString *patternBlack = @"Black \"(?:[^\\\"]+|\\.)*\"";
    NSError *error = NULL;
    NSRegularExpression *regexWhite = [[NSRegularExpression alloc] initWithPattern:patternWhite options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *regexBlack = [[NSRegularExpression alloc] initWithPattern:patternBlack options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    for (NSString *game in allGamesByRegex) {
        NSRange rangeWhite = [regexWhite rangeOfFirstMatchInString:game options:0 range:NSMakeRange(0, [game length])];
        NSRange rangeBlack = [regexBlack rangeOfFirstMatchInString:game options:0 range:NSMakeRange(0, [game length])];
        NSString *w = [game substringWithRange:rangeWhite];
        NSString *b = [game substringWithRange:rangeBlack];
        w = [[w componentsSeparatedByString:@"\""] objectAtIndex:1];
        b = [[b componentsSeparatedByString:@"\""] objectAtIndex:1];
        
        [playerSet addObject:w];
        [playerSet addObject:b];
    }
    return [[playerSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSDictionary *) getAllPlayersByDictionary {
    if (!allGamesByRegex) {
        allGamesByRegex = [self getAllGamesByRegex];
    }
    NSString *patternWhite = @"White \"(?:[^\\\"]+|\\.)*\"";
    NSString *patternBlack = @"Black \"(?:[^\\\"]+|\\.)*\"";
    NSError *error = NULL;
    NSRegularExpression *regexWhite = [[NSRegularExpression alloc] initWithPattern:patternWhite options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *regexBlack = [[NSRegularExpression alloc] initWithPattern:patternBlack options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSMutableDictionary *playerDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *game in allGamesByRegex) {
        NSRange rangeWhite = [regexWhite rangeOfFirstMatchInString:game options:0 range:NSMakeRange(0, [game length])];
        NSRange rangeBlack = [regexBlack rangeOfFirstMatchInString:game options:0 range:NSMakeRange(0, [game length])];
        NSString *w = [game substringWithRange:rangeWhite];
        NSString *b = [game substringWithRange:rangeBlack];
        w = [[w componentsSeparatedByString:@"\""] objectAtIndex:1];
        b = [[b componentsSeparatedByString:@"\""] objectAtIndex:1];
        
        if ([[playerDictionary allKeys] containsObject:w]) {
            NSNumber *n = [playerDictionary objectForKey:w];
            int num = [n intValue];
            num++;
            NSNumber *newNum = [NSNumber numberWithInt:num];
            [playerDictionary removeObjectForKey:w];
            [playerDictionary setObject:newNum forKey:w];
        }
        else {
            NSNumber *n = [NSNumber numberWithInt:1];
            [playerDictionary setObject:n forKey:w];
        }
        
        if ([[playerDictionary allKeys] containsObject:b]) {
            NSNumber *n = [playerDictionary objectForKey:b];
            int num = [n intValue];
            num++;
            NSNumber *newNum = [NSNumber numberWithInt:num];
            [playerDictionary removeObjectForKey:b];
            [playerDictionary setObject:newNum forKey:b];
        }
        else {
            NSNumber *n = [NSNumber numberWithInt:1];
            [playerDictionary setObject:n forKey:b];
        }
    }
    return playerDictionary;
}

/*
- (NSCountedSet *) getAllPlayersByCountedSet {
    //if (!allGamesByRegex) {
    //    allGamesByRegex = [self getAllGamesByRegex];
    //}
    
    return [self getAllPlayersByCountedSet2];
    
    if (!allGamesAndTags) {
        allGamesAndTags = [self caricaTutteLePartite];
    }
    
    
    //NSLog(@"METODO getAllPlayersByCountedSet");
    
    //NSString *patternWhite = @"White \"(?:[^\\\"]+|\\.)*\"";
    //NSString *patternBlack = @"Black \"(?:[^\\\"]+|\\.)*\"";

    //NSString *patternWhiteInfo = @"\\[White(?:[^\\\"]+|\\.)* \"(?:[^\\\"]+|\\.)\"\\]";
    //NSString *patternBlackInfo = @"\\[Black(?:[^\\\"]+|\\.)* \"(?:[^\\\"]+|\\.)\"\\]";
    
    //NSString *patternWhiteInfo = @"\\[White \"(?:[^\\\"]+|\\.)*\"\\]|\\[WhiteTitle \"(?:[^\\\"]+|\\.)*\"\\]|\\[WhiteElo \"(?:[^\\\"]+|\\.)*\"\\]|\\[WhiteFideId \"(?:[^\\\"]+|\\.)*\"\\]";
    //NSString *patternBlackInfo = @"\\[Black \"(?:[^\\\"]+|\\.)*\"\\]|\\[BlackTitle \"(?:[^\\\"]+|\\.)*\"\\]|\\[BlackElo \"(?:[^\\\"]+|\\.)*\"\\]|\\[BlackFideId \"(?:[^\\\"]+|\\.)*\"\\]";
    
    //NSError *error = NULL;
    //NSRegularExpression *regexWhite = [[NSRegularExpression alloc] initWithPattern:patternWhite options:NSRegularExpressionCaseInsensitive error:&error];
    //NSRegularExpression *regexBlack = [[NSRegularExpression alloc] initWithPattern:patternBlack options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSCountedSet *playerCountedSet = [[NSCountedSet alloc] init];
    NSCountedSet *playerConInfoCountedSet = [[NSCountedSet alloc] init];
    
    //NSRegularExpression *regexWhiteInfo = [[NSRegularExpression alloc] initWithPattern:patternWhiteInfo options:NSRegularExpressionCaseInsensitive error:&error];
    //NSRegularExpression *regexBlackInfo = [[NSRegularExpression alloc] initWithPattern:patternBlackInfo options:NSRegularExpressionCaseInsensitive error:&error];
    
    for (NSString *game in allGamesAndTags) {
        
        //NSLog(@"Partita n. %d\n", [allGamesAndTags indexOfObject:game]);
        //NSLog(@"%@\n\n", game);
        
        PGNGame *pgnGame = [[PGNGame alloc] initWithPgn:game];
        
        
        //NSRange rangeWhite = [regexWhite rangeOfFirstMatchInString:game options:0 range:NSMakeRange(0, [game length])];
        //NSRange rangeBlack = [regexBlack rangeOfFirstMatchInString:game options:0 range:NSMakeRange(0, [game length])];
        //NSString *w = [game substringWithRange:rangeWhite];
        //NSString *b = [game substringWithRange:rangeBlack];
        
        NSString *w = [pgnGame getTagValueByTagName:@"White" withQuotes:YES];
        NSString *b = [pgnGame getTagValueByTagName:@"Black" withQuotes:YES];
        
        
        //NSLog(@"WHITE = %@", w);
        //NSLog(@"BLACK = %@", b);
        
        //NSString *gameForFile = [pgnGame getGameForFile];
        //NSLog(@"%@\n\n", gameForFile);
        
        //NSArray *matchesWhite = [regexWhiteInfo matchesInString:game options:0 range:NSMakeRange(0, [game length])];
        NSMutableString *wInfo = [[NSMutableString alloc] init];
        //for (NSTextCheckingResult *match in matchesWhite) {
        //    NSRange matchRange = [match range];
        //    NSString *whiteInfo = [game substringWithRange:matchRange];
        //    [wInfo appendString:whiteInfo];
        //    NSLog(@"WHITE INFO    %@", whiteInfo);
        //}
        
        [wInfo appendString:[pgnGame getTagInBrackets:@"White"]];
        
        
        //NSLog(@"WINFO = %@",wInfo);
        //NSArray *matchesBlack = [regexBlackInfo matchesInString:game options:0 range:NSMakeRange(0, [game length])];
        NSMutableString *bInfo = [[NSMutableString alloc] init];
        //for (NSTextCheckingResult *match in matchesBlack) {
        //    NSRange matchRange = [match range];
        //    NSString *blackInfo = [game substringWithRange:matchRange];
        //    NSLog(@"BLACK INFO    %@", blackInfo);
        //    [bInfo appendString:blackInfo];
        //}
        
        [bInfo appendString:[pgnGame getTagInBrackets:@"Black"]];
        
        //NSLog(@"BINFO = %@", bInfo);
        w = [[w componentsSeparatedByString:@"\""] objectAtIndex:1];
        b = [[b componentsSeparatedByString:@"\""] objectAtIndex:1];
        
        //NSLog(@"WHITE = %@", w);
        //NSLog(@"BLACK = %@", b);
        
        [playerCountedSet addObject:w];
        [playerCountedSet addObject:b];
        
        
        //NSLog(@"%@       %@", w, wInfo);
        //NSLog(@"%@       %@", b, bInfo);
        
        //NSString *infoW = [wInfo stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
        //NSArray *wArray = [infoW componentsSeparatedByString:separator];
        NSMutableString *ww = [[NSMutableString alloc] init];
        //for (NSString *value in wArray) {
        //    NSString *w1 = [[value componentsSeparatedByString:@"\""] objectAtIndex:1];
        //    if (ww.length > 0) {
        //        [ww appendString:separator];
        //    }
        //    [ww appendString:w1];
        //}
        [ww appendString:[pgnGame getTagValueByTagName:@"White"]];
        //NSLog(@"Info Bianco: %@", ww);
        
        [playerConInfoCountedSet addObject:ww];
        
        //NSString *infoN = [bInfo stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
        //NSArray *bArray = [infoN componentsSeparatedByString:separator];
        NSMutableString *bb = [[NSMutableString alloc] init];
        //for (NSString *value in bArray) {
        //    NSString *b1 = [[value componentsSeparatedByString:@"\""] objectAtIndex:1];
        //    if (bb.length > 0) {
        //        [bb appendString:separator];
        //    }
        //    [bb appendString:b1];
        //}
        
        [bb appendString:[pgnGame getTagValueByTagName:@"Black"]];
        //NSLog(@"Info Nero : %@", bb);
        [playerConInfoCountedSet addObject:bb];
    }
    
    
    //for (NSString *pl in [[playerConInfoCountedSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
    //    NSLog(@"%@             %d", pl, [playerConInfoCountedSet countForObject:pl]);
    //}
    return playerConInfoCountedSet;
    //return playerCountedSet;
}
*/
 
 
- (NSCountedSet *) getAllPlayersByCountedSet {
    if (!allGamesAndTags) {
        allGamesAndTags = [self caricaTutteLePartite];
    }
    
    NSCountedSet *playerConInfoCountedSet = [[NSCountedSet alloc] init];
    
    for (NSString *game in allGamesAndTags) {
        NSArray *gameArray = [game componentsSeparatedByString:separator];
        
        NSString *w;
        NSString *b;
        
        for (NSString *s in gameArray) {
            if ([s hasPrefix:@"[White "]) {
                w = [[s componentsSeparatedByString:@"\""] objectAtIndex:1];
                //NSLog(@"WWW = %@", w);
                [playerConInfoCountedSet addObject:w];
            }
            else if ([s hasPrefix:@"[Black "]) {
                b = [[s componentsSeparatedByString:@"\""] objectAtIndex:1];
                //NSLog(@"BBB = %@", b);
                [playerConInfoCountedSet addObject:b];
            }
        }
    }
    return playerConInfoCountedSet;
}

- (NSArray *) getAllInfoOnPlayers {
    if (!allGamesByRegex) {
        allGamesByRegex = [self getAllGamesByRegex];
    }
    
    NSString *patternWhite = @"White \"(?:[^\\\"]+|\\.)*\"|WhiteTitle \"(?:[^\\\"]+|\\.)*\"|WhiteElo \"(?:[^\\\"]+|\\.)*\"";
    NSString *patternBlack = @"Black \"(?:[^\\\"]+|\\.)*\"|BlackTitle \"(?:[^\\\"]+|\\.)*\"|BlackElo \"(?:[^\\\"]+|\\.)*\"";
    NSError *error = NULL;
    NSRegularExpression *regexWhite = [[NSRegularExpression alloc] initWithPattern:patternWhite options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *regexBlack = [[NSRegularExpression alloc] initWithPattern:patternBlack options:NSRegularExpressionCaseInsensitive error:&error];
    
    //NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    NSMutableDictionary *playerNumGamesDictionary = [[NSMutableDictionary alloc] init];
    //NSMutableArray *playerInfoArray = [[NSMutableArray alloc] init];
    NSMutableSet *playerInfoSet = [[NSMutableSet alloc] init];
    
    for (NSString *game in allGamesByRegex) {
        //procedura trattamento colore White
        NSArray *matchesWhite = [regexWhite matchesInString:game options:0 range:NSMakeRange(0, [game length])];
        NSMutableString *matchWhite = [[NSMutableString alloc] init];
        for (NSTextCheckingResult *match in matchesWhite) {
            NSRange matchRange = [match range];
            NSString *subString = [game substringWithRange:matchRange];
            NSString *stringaSenzaParentesi = [subString stringByTrimmingCharactersInSet:setQuadre];
            NSArray *arrayConTagSenzaApici = [stringaSenzaParentesi componentsSeparatedByString:@"\""];
            NSString *stringaSenzaApici = [arrayConTagSenzaApici objectAtIndex:1];
            
            [matchWhite appendString:stringaSenzaApici];
            [matchWhite appendString:separator];
        }
        
        if (matchWhite.length > 0) {
            [matchWhite deleteCharactersInRange:NSMakeRange([matchWhite length] - 1, 1)];
        }
        NSString *w = [[matchWhite componentsSeparatedByString:separator] objectAtIndex:0];
        if ([[playerNumGamesDictionary allKeys] containsObject:w]) {
            NSNumber *n = [playerNumGamesDictionary objectForKey:w];
            int num = [n intValue];
            num++;
            NSNumber *newNum = [NSNumber numberWithInt:num];
            [playerNumGamesDictionary removeObjectForKey:w];
            [playerNumGamesDictionary setObject:newNum forKey:w];
        }
        else {
            NSNumber *n = [NSNumber numberWithInt:1];
            [playerNumGamesDictionary setObject:n forKey:w];
        }
        //[playerInfoArray addObject:matchWhite];
        [playerInfoSet addObject:matchWhite];
        
        //Procedura trattamento colore Black
        NSArray *matchesBlack = [regexBlack matchesInString:game options:0 range:NSMakeRange(0, [game length])];
        NSMutableString *matchBlack = [[NSMutableString alloc] init];
        for (NSTextCheckingResult *match in matchesBlack) {
            NSRange matchRange = [match range];
            NSString *subString = [game substringWithRange:matchRange];
            NSString *stringaSenzaParentesi = [subString stringByTrimmingCharactersInSet:setQuadre];
            NSArray *arrayConTagSenzaApici = [stringaSenzaParentesi componentsSeparatedByString:@"\""];
            NSString *stringaSenzaApici = [arrayConTagSenzaApici objectAtIndex:1];
            
            [matchBlack appendString:stringaSenzaApici];
            [matchBlack appendString:separator];
        }
        if (matchBlack.length > 0) {
            [matchBlack deleteCharactersInRange:NSMakeRange([matchBlack length] - 1, 1)];
        }
        NSString *b = [[matchBlack componentsSeparatedByString:separator] objectAtIndex:0];
        if ([[playerNumGamesDictionary allKeys] containsObject:b]) {
            NSNumber *n = [playerNumGamesDictionary objectForKey:b];
            int num = [n intValue];
            num++;
            NSNumber *newNum = [NSNumber numberWithInt:num];
            [playerNumGamesDictionary removeObjectForKey:b];
            [playerNumGamesDictionary setObject:newNum forKey:b];
        }
        else {
            NSNumber *n = [NSNumber numberWithInt:1];
            [playerNumGamesDictionary setObject:n forKey:b];
        }
        //[playerInfoArray addObject:matchBlack];
        [playerInfoSet addObject:matchBlack];
    }
    NSArray *risuArray = [NSArray arrayWithObjects:playerInfoSet.allObjects, playerNumGamesDictionary, nil];
    return risuArray;
}



- (NSString *) findGameByNumber:(NSInteger)gameNumber {
    
    NSMutableString *moves = nil;
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    NSInteger numeroPartite = 0;
    BOOL partitaTrovata = NO;
    BOOL stop = NO;
    while ((line = [reader readLine]) && !stop) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"[Event "]) {
            numeroPartite++;
            if (numeroPartite == gameNumber) {
                partitaTrovata = YES;
            }
        }
        
        
        
        if ((line.length > 2) && ![line hasPrefix:@"["] && partitaTrovata) {
            NSString *line1 = [line stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            line1 = [line1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (!moves) {
                moves = [[NSMutableString alloc] initWithString:line1];
            }
            else {
                [moves appendString:@" "];
                [moves appendString:line1];
            }
            
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"] || [line hasSuffix:@"*"]) {
                stop = YES;
            }
        }

    }
    return moves;
}

- (NSDictionary *) findGamesByTagValue:(NSString *)tag {
    NSArray *tagArray = [NSArray arrayWithObjects:tag, nil];
    NSArray *listTag = [self findGamesByTagArray:tagArray];
    NSMutableArray *setValues = [[NSMutableArray alloc] init];
    for (NSString *s in listTag) {
        if (![setValues containsObject:s]) {
            [setValues addObject:s];
        }
    }
    
    NSArray *allGames = [self getAllGames];
    
    
    //NSLog(@"Ho caricato gli eventi e tutte le partite");
    //NSLog(@"Numero eventi: %lu     Numero partite: %lu", (unsigned long)setValues.count, (unsigned long)allGames.count);
    
    //for (NSString *ev in setValues) {
        //NSLog(@"Evento: %@", ev);
    //}
    //NSLog(@"\n\n");
    
    NSMutableDictionary *tagValuesDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *games;
    
    for (NSString *event in setValues) {
        games = [[NSMutableArray alloc] init];
        for (NSString *game in allGames) {
            if ([game rangeOfString:event].location != NSNotFound) {
                //NSLog(@"Evento   %@  contenuto nella partita  %@", event, game);
                [games addObject:game];
            }
        }
        [tagValuesDictionary setObject:games forKey:event];
    }
    return tagValuesDictionary;
}

- (NSString *) findGameByEventAndInfo:(NSString *)event :(NSString *)info {  //Cerca una partita sulla base dell'evento e di altre informazioni (Bianco, Nero, Risultato, ECO etc.
    
    NSArray *tagArray = [NSArray arrayWithObjects:@"White ", @"Black ", @"Result ", @"ECO ", @"Event ", @"Site ", @"EventDate ", @"EventCountry ", nil];
    
    NSMutableString *tags = nil;
    NSString *line = nil;
    NSMutableString *moves = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    
    NSMutableArray *stringArray = [[NSMutableArray alloc] init];
    for (int i=0; i<tagArray.count; i++) {
        [stringArray addObject:@" "];
    }
    
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"[Event "]) {
            tags = [[NSMutableString alloc] init];
        }
        
        NSString *stringaSenzaParentesi = [line stringByTrimmingCharactersInSet:setQuadre];
        
        
        for (NSString *t in tagArray) {
            if ([stringaSenzaParentesi hasPrefix:t]) {
                
                NSArray *gArray = [stringaSenzaParentesi componentsSeparatedByString:@"\""];
                NSString *stringaSenzaApici = [gArray objectAtIndex:1];
                
                NSString *tag = [gArray objectAtIndex:0];
                
                [stringArray replaceObjectAtIndex:[tagArray indexOfObject:tag] withObject:stringaSenzaApici];
                break;
            }
        }
        
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            NSString *line1 = [line stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            line1 = [line1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (!moves) {
                moves = [[NSMutableString alloc] initWithString:line1];
            }
            else {
                [moves appendString:@" "];
                [moves appendString:line1];
            }
            
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"] || [line hasSuffix:@"*"]) {
                
                for (NSString *s in stringArray) {
                    [tags appendString:s];
                    [tags appendString:separator];
                }
                [tags deleteCharactersInRange:NSMakeRange([tags length] - 1, 1)];
                
                
                if ([tags rangeOfString:event].location != NSNotFound) {
                    if ([tags rangeOfString:info].location != NSNotFound) {
                        NSLog(@"Trovata partita: %@", tags);
                        return moves;
                    }
                }
                moves = nil;
            }
        }
    }
    return nil;
}

- (NSArray *) findGamesByTagValues:(NSString *)tagValues {
    
    //if (!allGamesByRegex) {
    //     allGamesByRegex = [self getAllGamesByRegex];
    //}
    
    return [self findGamesByEventTags:tagValues];
    
    
    if (!allGamesAndTags) {
        allGamesAndTags = [self caricaTutteLePartite];
    }
    
    
    tagValues = [tagValues stringByReplacingOccurrencesOfString:@"+" withString:@"\\+"];
    
    NSMutableArray *gamesByTagValues = [[NSMutableArray alloc] init];
    NSError *error = NULL;
    NSRegularExpression *ecoPattern = [[NSRegularExpression alloc] initWithPattern:tagValues options:NSRegularExpressionCaseInsensitive error:&error];
    
    //NSLog(@"PATTERN = %@", ecoPattern.pattern);
    //NSLog(@"ERRORE = %@", error.description);
    
    NSArray *minMatchArray = [tagValues componentsSeparatedByString:separator];
    int numeroMatch = 0;
    NSUInteger minMatch = minMatchArray.count;
    for (NSString *gameInTag in allGamesAndTags) {
        NSUInteger match = 0;
        @try {
            match = [ecoPattern numberOfMatchesInString:gameInTag options:0 range:NSMakeRange(0, [gameInTag length])];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception = %@", exception.description);
            match = 0;
        }
        //NSLog(@"MATCH = %d", match);
        if (match == minMatch) {
            [gamesByTagValues addObject:gameInTag];
            //NSLog(@"Ho trovato la partita!!");
            numeroMatch += match;
        }
    }
    return gamesByTagValues;
}

- (NSArray *)findGamesByEventTags:(NSString *)tagValues {
    if (!allGamesAndTags) {
        allGamesAndTags = [self caricaTutteLePartite];
    }
    
    //NSLog(@"Sto facendo la ricerca in %d partite con tag = %@", allGamesAndTags.count, tagValues);
    
    tagValues = [tagValues stringByReplacingOccurrencesOfString:@"+" withString:@"\\+"];
    tagValues = [tagValues stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    NSMutableArray *gamesByEventValues = [[NSMutableArray alloc] init];
    
    NSArray *minMatchArray = [tagValues componentsSeparatedByString:separator];
    NSUInteger minMatch = minMatchArray.count;
    
    for (NSString *gameInTag in allGamesAndTags) {
        NSUInteger match = 0;
        for (NSString *t in minMatchArray) {
            NSRange r1 = [gameInTag rangeOfString:t];
            if (r1.location != NSNotFound) {
                match++;
            }
        }
        if (match == minMatch) {
            [gamesByEventValues addObject:gameInTag];
        }
    }
    return gamesByEventValues;
}


- (NSArray *) findGamesByEcoOpening:(NSArray *)ecoOpeningArray {
    
    if (!allGamesAndTags) {
        allGamesAndTags = [self caricaTutteLePartite];
    }
    //NSString *tagEco = [ecoOpeningArray objectAtIndex:0];
    
    NSMutableArray *gamesFound = [[NSMutableArray alloc] init];
    for (NSString *game in allGamesAndTags) {
        NSUInteger match = 0;
        for (NSString *tag in ecoOpeningArray) {
            if ([game rangeOfString:tag].location == NSNotFound) {
                break;
            }
            else {
                match++;
            }
        }
        switch (match) {
            case 1:
                if (match == ecoOpeningArray.count) {
                    if (([game rangeOfString:@"[Opening"].location == NSNotFound) && ([game rangeOfString:@"[Variation"].location == NSNotFound) && ([game rangeOfString:@"[SubVariation"].location == NSNotFound)) {
                        [gamesFound addObject:game];
                    }
                }
                break;
            case 2:
                if (match == ecoOpeningArray.count) {
                    if (([game rangeOfString:@"[Variation"].location == NSNotFound) && ([game rangeOfString:@"[SubVariation"].location == NSNotFound)) {
                        [gamesFound addObject:game];
                    }
                }
                break;
            case 3:
                if (match == ecoOpeningArray.count) {
                    if (([game rangeOfString:@"[SubVariation"].location == NSNotFound)) {
                        [gamesFound addObject:game];
                    }
                }
                break;
            case 4:
                [gamesFound addObject:game];
                break;
            default:
                break;
        }
    }
    return gamesFound;
}

/*
- (NSArray *) findGamesByPlayerName:(NSString *)playerName {

    return [self findGamesByPlayerName2:playerName];
    
    if (!allGamesAndTags) {
        allGamesAndTags = [self caricaTutteLePartite];
    }
    
    //NSLog(@"METODO findGamesByPlayerName");
    
    //NSLog(@"Nome da trovare = %@", playerName);
    
    //NSMutableString *patternPlayer = [[NSMutableString alloc] init];
    //[patternPlayer appendString:@"\\b"];
    
    //playerName = [playerName stringByTrimmingCharactersInSet:setPunto];
    
    //NSLog(@"Nome da trovare = %@", playerName);
    
    //[patternPlayer appendString:playerName];
    //[patternPlayer appendString:@"\\b"];
    
    NSMutableArray *gamesByPlayerName = [[NSMutableArray alloc] init];
    //NSError *error = NULL;
    //NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:patternPlayer options:NSRegularExpressionCaseInsensitive error:&error];
    //NSLog(@"%@", regex.pattern);
    
    for (NSString *game in allGamesAndTags) {
        //NSUInteger match = [regex numberOfMatchesInString:game options:0 range:NSMakeRange(0, [game length])];
        //if (match > 0) {
        //    [gamesByPlayerName addObject:game];
        //}
        PGNGame *pgnGame = [[PGNGame alloc] initWithPgn:game];
        //NSString *w = [pgnGame getTagValueByTagName:@"White"];
        //NSString *b = [pgnGame getTagValueByTagName:@"Black"];
        //NSLog(@"%@       -      %@", w, b);
        if ([[pgnGame getTagValueByTagName:@"White"] isEqualToString:playerName] || [[pgnGame getTagValueByTagName:@"Black"] isEqualToString:playerName]) {
            [gamesByPlayerName addObject:game];
            //NSLog(@"Inserito: %@   -   %@", w, b);
        }
    }
    return gamesByPlayerName;
}
*/

- (NSArray *) findGamesByPlayerName:(NSString *)playerName {
    if (!allGamesAndTags) {
        allGamesAndTags = [self caricaTutteLePartite];
    }
    NSMutableArray *gamesByPlayerName = [[NSMutableArray alloc] init];
    
    for (NSString *game in allGamesAndTags) {
        NSArray *gameArray = [game componentsSeparatedByString:separator];
        
        NSString *w;
        NSString *b;
        
        for (NSString *s in gameArray) {
            if ([s hasPrefix:@"[White "]) {
                w = [[s componentsSeparatedByString:@"\""] objectAtIndex:1];
            }
            else if ([s hasPrefix:@"[Black "]) {
                b = [[s componentsSeparatedByString:@"\""] objectAtIndex:1];
            }
        }
        
        if ([w isEqualToString:playerName] || [b isEqualToString:playerName]) {
            [gamesByPlayerName addObject:game];
        }
    }
    
    return gamesByPlayerName;
}

- (NSArray *) findGamesByYear:(NSString *)year {
    //if (!allGamesByRegex) {
    //    allGamesByRegex = [self getAllGamesByRegex];
    //}
    if (!allGamesAndTags) {
        allGamesAndTags = [self caricaTutteLePartite];
    }
    
    NSString *pattern = [NSString stringWithFormat:@"Date \"%@", year];
    NSMutableArray *gamesByYear = [[NSMutableArray alloc] init];
    for (NSString *s in allGamesAndTags) {
        if (!([s rangeOfString:pattern].location == NSNotFound)) {
            [gamesByYear addObject:s];
        }
    }
    return gamesByYear;
}

- (void) classifyGamesByEvent:(NSArray *)gamesByYear {
    for (NSString *game in gamesByYear) {
        NSLog(@"%@", game);
    }
}

- (NSCountedSet *) getAllEventsInArray:(NSArray *)gamesByYear {
    NSCountedSet *eventsByCountedSet = [[NSCountedSet alloc] init];
    
    NSError *error = NULL;
    NSString *pattern = @"\\[Event \"(?:[^\\\"]+|\\.)*\"\\]|\\[Site \"(?:[^\\\"]+|\\.)*\"\\]|\\[EventDate \"(?:[^\\\"]+|\\.)*\"\\]|\\[EventCountry \"(?:[^\\\"]+|\\.)*\"\\]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    for (NSString *gameInTag in gamesByYear) {
        NSArray *matches = [regex matchesInString:gameInTag options:0 range:NSMakeRange(0, [gameInTag length])];
        NSMutableString *matchStringCompleta = [[NSMutableString alloc] init];
        for (NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match range];
            NSString *subString = [gameInTag substringWithRange:matchRange];
            [matchStringCompleta appendString:subString];
        }
        if (matchStringCompleta.length>0) {
            [eventsByCountedSet addObject:matchStringCompleta];
        }
    }
    
    return eventsByCountedSet;
}

- (NSString *) findGameMovesByTagPairs:(NSString *)tagPairs {
    if (!allGamesByRegex) {
        allGamesByRegex = [self getAllGamesByRegex];
    }
    for (NSString *game in allGamesByRegex) {
        if ([tagPairs rangeOfString:game].length>0) {
            NSUInteger n = [allGamesByRegex indexOfObject:game];
            return [self findGameByNumber:n + 1];
        }
    }
    return nil;
}

- (NSArray *) getAllDatabaseGames {
    if (!allGamesByRegex) {
        allGamesByRegex = [self getAllGamesByRegex];
    }
    return allGamesByRegex;
}

//Metodi introdotti che usano le espressioni regolari

- (NSArray *) getAllGamesByRegex {
    
    NSError *error = NULL;
    NSRegularExpression *eventPattern = [[NSRegularExpression alloc] initWithPattern:@"\\bEvent\\b" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRegularExpression *pQuadra = [[NSRegularExpression alloc] initWithPattern:@"\\[" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRegularExpression *risuPattern = [[NSRegularExpression alloc] initWithPattern:@"\\b0-1\\b|\\b1-0\\b|\\b1/2-1/2\\b|\\*" options:NSRegularExpressionCaseInsensitive error:&error];
    
    //NSLog(@"%@", risuPattern.pattern);
    
    NSMutableArray *allGamesAllTag = [[NSMutableArray alloc] init];
    
    NSMutableString *tagsList;
    
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    
    while ((line = [reader readLine])) {
        
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //if ([line hasPrefix:@"[Event "]) {
        //    tagsList = [[NSMutableString alloc] init];
        //}
        
        NSUInteger match = [eventPattern numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])];
        //NSLog(@"Match = %d", match);
        
        if (match == 1) {
            tagsList = [[NSMutableString alloc] init];
        }
        
        //if ([line hasPrefix:@"["]) {
        //    [tagsList appendString:line];
        //}
        
        NSUInteger matchQuadra = [pQuadra numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])];
        
        if (matchQuadra == 1) {
            [tagsList appendString:line];
        }
        else {
            NSUInteger matchRisu = [risuPattern numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])];
            //[tagsList appendString:line];
            if (matchRisu == 1) {
                [allGamesAllTag addObject:tagsList];
                tagsList = nil;
            }
        }
        /*
        if ((line.length > 2) && ![line hasPrefix:@"["]) {
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"] || [line hasSuffix:@"*"]) {
                [allGamesTag addObject:tagsList];
                tagsList = nil;
            }
        }*/
    }
    return allGamesAllTag;
}

- (NSMutableArray *) getAllGamesAndTags {
    if (allGamesAndTags) {
        return allGamesAndTags;
    }
    //allGamesAndTags = [[NSMutableArray alloc] init];
    
    //allGamesAndTags = [[self allGames] mutableCopy];
    allGamesAndTags = [self caricaTutteLePartite];
    return allGamesAndTags;
    
    NSError *error = NULL;
    NSRegularExpression *eventPattern = [[NSRegularExpression alloc] initWithPattern:@"\\bEvent\\b" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRegularExpression *pQuadra = [[NSRegularExpression alloc] initWithPattern:@"\\[" options:NSRegularExpressionCaseInsensitive error:&error];
    
    //NSRegularExpression *risuPattern = [[NSRegularExpression alloc] initWithPattern:@"\\b0-1\\b|\\b1-0\\b|\\b1/2-1/2\\b|\\*" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSMutableString *tagsList;
    NSMutableString *moveList;
    
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSUInteger match = [eventPattern numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])];
        if (match == 1) {
            tagsList = [[NSMutableString alloc] init];
            moveList = [[NSMutableString alloc] init];
        }
        NSUInteger matchQuadra = [pQuadra numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])];
        if (matchQuadra == 1) {
            [tagsList appendString:line];
            [tagsList appendString:separator];
        }
        else {
            //NSUInteger matchRisu = [risuPattern numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])];
            NSUInteger matchRisu;
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"] || [line hasSuffix:@"*"]) {
                matchRisu = 1;
            }
            else {
                matchRisu = 0;
            }
            if (matchRisu == 1) {
                [moveList appendString:line];
                [tagsList appendString:moveList];
                [allGamesAndTags addObject:tagsList];
                tagsList = nil;
            }
            else {
                [moveList appendString:line];
                [moveList appendString:@" "];
            }
        }
    }
    return allGamesAndTags;
}


- (NSArray *) findGamesByTagsByRegex:(NSArray *)tagsArray {
    NSError *error = NULL;
    NSRegularExpression *eventPattern = [[NSRegularExpression alloc] initWithPattern:@"\\bEvent\\b" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *tagArray = [NSArray arrayWithObjects:@"White", @"Black", @"Result", @"ECO", @"Event", @"Site", @"EventDate", @"EventCountry", nil];
    //NSArray *tagArray = [NSArray arrayWithObjects:@"White ", @"Black ", @"Result ", @"ECO ", @"Event ", @"Site ", @"EventDate ", nil];
    
    NSMutableString *pattern = [[NSMutableString alloc] init];
    for (NSString *tag in tagArray) {
        [pattern appendString:@"\\b"];
        [pattern appendString:tag];
        [pattern appendString:@"\\b"];
        [pattern appendString:separator];
    }
    
    //NSRegularExpression *eventPattern = [[NSRegularExpression alloc] initWithPattern:@"\\bEvent\\b\\s\"[a-zA-Z0-9]\"" options:0 error:&error];
    //NSLog(@"%@", eventPattern);
    
    
    
    //NSRegularExpression *tagsPattern = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:&error];
    NSArray *allGamesTag = [self getAllGamesByRegex];
    
    for (NSString *tagsPartita in allGamesTag) {
        //NSUInteger match = [tagsPattern numberOfMatchesInString:tagsPartita options:0 range:NSMakeRange(0, [tagsPartita length])];
        NSUInteger match = [eventPattern numberOfMatchesInString:tagsPartita options:0 range:NSMakeRange(0, [tagsPartita length])];
        if (match>0) {
            NSLog(@"Match Ok per %@", tagsPartita);
        }
        else {
            NSLog(@"Match KO per %@", tagsPartita);
        }
    }
    return nil;
}

- (void) saveGame:(NSString *)game {
    NSString *textFile = [NSString stringWithContentsOfFile:_path encoding:NSISOLatin1StringEncoding error:nil];
    NSString *newTextFile = [textFile stringByAppendingString:game];
    //[newTextFile writeToFile:_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [newTextFile writeToFile:_path atomically:YES encoding:NSISOLatin1StringEncoding error:nil];
    [self calcNumberOfGames];
    
    for (NSString *g in [self getAllGamesByRegex]) {
        NSLog(@"%@", g);
    }
}

- (void) saveAllGamesAndTags:(NSMutableArray *)gamesAndTags {
    
    allGamesAndTags = gamesAndTags;
    _numberOfGames = [NSNumber numberWithInteger:allGamesAndTags.count];
    
    NSMutableString *gameFile = [[NSMutableString alloc] init];
    for (NSString *g in gamesAndTags) {
        NSArray *gameArray = [g componentsSeparatedByString:separator];
        for (NSString *riga in gameArray) {
            if (![riga hasPrefix:@"["]) {
                [gameFile appendString:@"\n"];
            }
            [gameFile appendString:riga];
            [gameFile appendString:@"\n"];
        }
        [gameFile appendString:@"\n"];
    }
    //NSLog(@"%@", gameFile);
    //[gameFile writeToFile:_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [gameFile writeToFile:_path atomically:YES encoding:NSISOLatin1StringEncoding error:nil];
}

- (void) appendGamesAndTagsToPgnFile:(NSArray *)gamesToAppend {
    
    if (!allGamesAndTags) {
        allGamesAndTags = [self getAllGamesAndTags];
    }
    
    [allGamesAndTags addObjectsFromArray:gamesToAppend];
    
    NSMutableString *gameFile = [[NSMutableString alloc] init];
    for (NSString *g in allGamesAndTags) {
        NSArray *gameArray = [g componentsSeparatedByString:separator];
        for (NSString *riga in gameArray) {
            if (![riga hasPrefix:@"["]) {
                [gameFile appendString:@"\n"];
            }
            [gameFile appendString:riga];
            [gameFile appendString:@"\n"];
        }
        [gameFile appendString:@"\n"];
    }
    //[gameFile writeToFile:_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [gameFile writeToFile:_path atomically:YES encoding:NSISOLatin1StringEncoding error:nil];
}

- (NSMutableArray *) caricaTutteGliEventi {
    NSMutableArray *tutteGliEventi = [[NSMutableArray alloc] init];
    NSString *line = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([line hasPrefix:@"[Event "]) {
            [tutteGliEventi addObject:line];
        }
    }
    return tutteGliEventi;
}

- (NSMutableArray *) caricaTutteLePartiteOld {
    NSMutableArray *tutteLePartite = [[NSMutableArray alloc] init];
    NSString *line = nil;
    NSMutableString *game = nil;
    NSMutableString *moves = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    while ((line = [reader readLine])) {
        
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        if (line.length > 0) {
            if ([line hasPrefix:@"[Event "]) {
                game = [[NSMutableString alloc] initWithString:line];
                [game appendString:separator];
            }
            
            if ([line hasPrefix:@"["]  && ![line hasPrefix:@"[Event "]) {
                [game appendString:line];
                [game appendString:separator];
            }
            
            if (![line hasPrefix:@"["]) {
                if (!moves) {
                    moves = [[NSMutableString alloc] initWithString:line];
                }
                else {
                    [moves appendString:@" "];
                    [moves appendString:line];
                }
            }
            
            if ([line hasSuffix:@"1-0"] || [line hasSuffix:@"0-1"] || [line hasSuffix:@"1/2-1/2"] || [line hasSuffix:@"*"]) {
                [game appendString:moves];
                
                if (game) {
                    [tutteLePartite addObject:game];
                }
                else {
                    NSLog(@"Ho trovato una partita NULL");
                }
                
                game = nil;
                moves = nil;
            }
        }
        
    }
    return tutteLePartite;
}

- (NSMutableArray *) caricaTutteLePartiteSenzaConsiderareOrdineTag {
    NSMutableArray *tutteLePartite = [[NSMutableArray alloc] init];
    NSString *line = nil;
    NSMutableString *game = nil;
    NSMutableString *moves = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    
    
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"%"]) {
            continue;
        }
        
        if ([line hasPrefix:@"ï»¿"]) {
            line = [line stringByTrimmingCharactersInSet:stranoCharSet];
        }
        
        
        if (line.length > 0) {
            if ([line hasPrefix:@"["] && !moves) {
                if (!game) {
                    game = [[NSMutableString alloc] initWithString:line];
                    [game appendString:separator];
                }
                else {
                    [game appendString:line];
                    [game appendString:separator];
                }
            }
            else if (!moves) {
                //NSLog(@"Incontro per la prima volta le mosse = %@", line);
                
                //NSLog(@"ESEGUO ISTRUZIONI 1 PER ARROCCO CON ZERI");
                //line = [line stringByReplacingOccurrencesOfString:@"0-0" withString:@"O-O"];
                //line = [line stringByReplacingOccurrencesOfString:@"0-0-0" withString:@"O-O-O"];
                
                moves = [[NSMutableString alloc] initWithString:line];
            }
            else {
                [moves appendString:@" "];
                
                //Provo ad inserire qui le istruzioni per correggere il problema dell'arrocco con gli zeri
                //NSLog(@"ESEGUO ISTRUZIONI 2 PER ARROCCO CON ZERI");
                //line = [line stringByReplacingOccurrencesOfString:@"0-0" withString:@"O-O"];
                //line = [line stringByReplacingOccurrencesOfString:@"0-0-0" withString:@"O-O-O"];
                
                [moves appendString:line];
                //NSLog(@"Incontro altre mosse = %@", moves);
            }
            
            
            if (game) {
                //NSLog(@"GAME = %@", game);
                if (moves) {
                    //NSLog(@"MOVES = %@", moves);
                    if ([moves hasSuffix:@"1-0"] || [moves hasSuffix:@"0-1"] || [moves hasSuffix:@"1/2-1/2"] || [moves hasSuffix:@"*"]) {
                        
                        [game appendString:moves];
                        [tutteLePartite addObject:game];
                        
                        //NSLog(@"GAME FINALE = %@", game);
                        
                        game = nil;
                        moves = nil;
                    }
                }
            }
        }
        else {
            if (game) {
                //NSLog(@"GAME = %@", game);
                if (moves) {
                    //NSLog(@"MOVES = %@", moves);
                    if ([moves hasSuffix:@"1-0"] || [moves hasSuffix:@"0-1"] || [moves hasSuffix:@"1/2-1/2"] || [moves hasSuffix:@"*"]) {
                        
                        [game appendString:moves];
                        [tutteLePartite addObject:game];
                        
                        //NSLog(@"GAME FINALE = %@", game);
                        
                        game = nil;
                        moves = nil;
                    }
                }
            }
        }
    }
    
    if (game) {
        if (moves) {
            [game appendString:moves];
            [tutteLePartite addObject:game];
        }
    }
    
    return tutteLePartite;
}

- (NSMutableArray *) caricaTutteLePartiteSenzaConsiderareOrdineTagEvitandoRisultatiIntermedi {
    NSMutableArray *tutteLePartite = [[NSMutableArray alloc] init];
    NSString *line = nil;
    NSMutableString *game = nil;
    NSMutableString *moves = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"%"]) {
            continue;
        }
        
        if ([line hasPrefix:@"ï»¿"]) {
            line = [line stringByTrimmingCharactersInSet:stranoCharSet];
        }
        
        if (line.length > 0) {
            if (![line hasPrefix:@"["]) {
                if (!game) {
                    continue;
                }
            }
        }
        
        
        //NSLog(@"%@", line);
        
        if (line.length > 0) {
            if ([line hasPrefix:@"["]) {
                if (!moves) {
                    if (!game) {
                        game = [[NSMutableString alloc] initWithString:line];
                        [game appendString:separator];
                    }
                    else {
                        [game appendString:line];
                        [game appendString:separator];
                    }
                }
                else {
                    if ([moves hasSuffix:@"1-0"] || [moves hasSuffix:@"0-1"] || [moves hasSuffix:@"1/2-1/2"] || [moves hasSuffix:@"*"]) {
                        [game appendString:moves];
                        [tutteLePartite addObject:game];
                        game = nil;
                        moves = nil;
                    }
                    else {
                        [moves appendString:@" "];
                        [moves appendString:line];
                    }
                }
            }
            else if (!moves) {
                //NSLog(@"Incontro per la prima volta le mosse = %@", line);
                
                //NSLog(@"ESEGUO ISTRUZIONI 1 PER ARROCCO CON ZERI");
                //line = [line stringByReplacingOccurrencesOfString:@"0-0" withString:@"O-O"];
                //line = [line stringByReplacingOccurrencesOfString:@"0-0-0" withString:@"O-O-O"];
                
                moves = [[NSMutableString alloc] initWithString:line];
            }
            else {
                [moves appendString:@" "];
                
                //Provo ad inserire qui le istruzioni per correggere il problema dell'arrocco con gli zeri
                //NSLog(@"ESEGUO ISTRUZIONI 2 PER ARROCCO CON ZERI");
                //line = [line stringByReplacingOccurrencesOfString:@"0-0" withString:@"O-O"];
                //line = [line stringByReplacingOccurrencesOfString:@"0-0-0" withString:@"O-O-O"];
                
                [moves appendString:line];
                //NSLog(@"Incontro altre mosse = %@", moves);
            }
            
            /*
            if (game) {
                //NSLog(@"GAME = %@", game);
                if (moves) {
                    //NSLog(@"MOVES = %@", moves);
                    if ([moves hasSuffix:@"1-0"] || [moves hasSuffix:@"0-1"] || [moves hasSuffix:@"1/2-1/2"] || [moves hasSuffix:@"*"]) {
                        
                        [game appendString:moves];
                        //[tutteLePartite addObject:game];
                        
                        //NSLog(@"GAME FINALE = %@", game);
                        
                        //game = nil;
                        //moves = nil;
                    }
                }
            }*/
        }
        else {
            if (game) {
                //NSLog(@"GAME = %@", game);
                if (moves) {
                    //NSLog(@"MOVES = %@", moves);
                    if ([moves hasSuffix:@"1-0"] || [moves hasSuffix:@"0-1"] || [moves hasSuffix:@"1/2-1/2"] || [moves hasSuffix:@"*"]) {
                        
                        [game appendString:moves];
                        [tutteLePartite addObject:game];
                        
                        //NSLog(@"GAME FINALE = %@", game);
                        
                        game = nil;
                        moves = nil;
                    }
                }
            }
        }
    }
    
    if (game) {
        if (moves) {
            [game appendString:moves];
            [tutteLePartite addObject:game];
        }
    }
    
    return tutteLePartite;
}


- (NSMutableArray *) caricaTutteLePartite {
    
    return [self caricaTutteLePartiteSenzaConsiderareOrdineTagEvitandoRisultatiIntermedi];
    
    return [self caricaTutteLePartiteSenzaConsiderareOrdineTag];
    
    //NSLog(@"ESEGUO CARICA TUTTE LE PARTITE");
    NSMutableArray *tutteLePartite = [[NSMutableArray alloc] init];
    NSString *line = nil;
    NSMutableString *game = nil;
    NSMutableString *moves = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        if ([line hasPrefix:@"%"]) {
            continue;
        }
        
        if ([line hasPrefix:@"ï»¿"]) {
            line = [line stringByTrimmingCharactersInSet:stranoCharSet];
        }
        
        //NSLog(@"%@", line);
        
        //if (!moves && line.length>0 && ![line hasPrefix:@"[Event "] && ![line hasPrefix:@"["]) {
        //    NSLog(@"%@", line);
        //    continue;
        //}
        
        if (line.length > 0) {
            if ([line hasPrefix:@"[Event "] && !moves) {
                game = [[NSMutableString alloc] initWithString:line];
                [game appendString:separator];
            }
            else if ([line hasPrefix:@"["]  && ![line hasPrefix:@"[Event "] && !moves) {
                [game appendString:line];
                [game appendString:separator];
            }
            else if (!moves) {
                //NSLog(@"Incontro per la prima volta le mosse = %@", line);
                
                //NSLog(@"ESEGUO ISTRUZIONI 1 PER ARROCCO CON ZERI");
                //line = [line stringByReplacingOccurrencesOfString:@"0-0" withString:@"O-O"];
                //line = [line stringByReplacingOccurrencesOfString:@"0-0-0" withString:@"O-O-O"];
                
                moves = [[NSMutableString alloc] initWithString:line];
            }
            else {
                [moves appendString:@" "];
                
                //Provo ad inserire qui le istruzioni per correggere il problema dell'arrocco con gli zeri
                //NSLog(@"ESEGUO ISTRUZIONI 2 PER ARROCCO CON ZERI");
                //line = [line stringByReplacingOccurrencesOfString:@"0-0" withString:@"O-O"];
                //line = [line stringByReplacingOccurrencesOfString:@"0-0-0" withString:@"O-O-O"];
                
                [moves appendString:line];
                //NSLog(@"Incontro altre mosse = %@", moves);
            }
            
            if (game) {
                //NSLog(@"GAME = %@", game);
                if (moves) {
                    //NSLog(@"MOVES = %@", moves);
                    if ([moves hasSuffix:@"1-0"] || [moves hasSuffix:@"0-1"] || [moves hasSuffix:@"1/2-1/2"] || [moves hasSuffix:@"*"]) {
                        
                        [game appendString:moves];
                        [tutteLePartite addObject:game];
                        
                        //NSLog(@"GAME FINALE = %@", game);
                        
                        game = nil;
                        moves = nil;
                    }
                }
            }
            
            
        }
        else {
            if (game) {
                //NSLog(@"GAME = %@", game);
                if (moves) {
                    //NSLog(@"MOVES = %@", moves);
                    if ([moves hasSuffix:@"1-0"] || [moves hasSuffix:@"0-1"] || [moves hasSuffix:@"1/2-1/2"] || [moves hasSuffix:@"*"]) {
                        
                        [game appendString:moves];
                        [tutteLePartite addObject:game];
                        
                        //NSLog(@"GAME FINALE = %@", game);
                        
                        game = nil;
                        moves = nil;
                    }
                }
            }
        }
    }
    //NSLog(@"LINE NON ESISTE e stampo i seguenti valori:");
    //NSLog(@"GAME = %@", game);
    //NSLog(@"MOSSE = %@", moves);
    
    if (game) {
        if (moves) {
            [game appendString:moves];
            [tutteLePartite addObject:game];
        }
    }
    
    return tutteLePartite;
}

- (void) salvaTutteLePartiteOld {
    NSMutableString *gameFile = [[NSMutableString alloc] init];
    for (NSString *g in allGamesAndTags) {
        NSArray *gameArray = [g componentsSeparatedByString:separator];
        for (NSString *riga in gameArray) {
            if (![riga hasPrefix:@"["]) {
                [gameFile appendString:@"\n"];
            }
            [gameFile appendString:riga];
            [gameFile appendString:@"\n"];
        }
        [gameFile appendString:@"\n"];
    }
    [gameFile writeToFile:_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void) salvaTutteLePartite {
    NSMutableString *gameFile = [[NSMutableString alloc] init];
    for (NSString *g in allGamesAndTags) {
        NSArray *gameArray = [g componentsSeparatedByString:separator];
        for (NSString *riga in gameArray) {
            
            //NSLog(@"RIGA         %@", riga);
            
            if (![riga hasPrefix:@"["]) {
                [gameFile appendString:@"\n"];
            }
            [gameFile appendString:riga];
            [gameFile appendString:@"\n"];
        }
        [gameFile appendString:@"\n"];
    }
    
    
    
    if (_isInCloud) {
        NSLog(@"Sto salvando il database in local cloud");
        //NSLog(@"Devo salvare la partita in path %@", [self metadataCloudPath]);
        //NSError *error = nil;
        //[gameFile writeToFile:[self metadataCloudPath] atomically:YES encoding:NSISOLatin1StringEncoding error:&error];
        //if (!error) {
        //    NSLog(@"Database salvato con successo");
        //}
        //else {
            //NSLog(@"Database non salvato: %@", error.description);
        //}
    }
    else {
        //NSLog(@"Sto salvando il database normalmente");
        //NSLog(@"Devo salvare la partita in path %@", _path);
        [gameFile writeToFile:_path atomically:YES encoding:NSISOLatin1StringEncoding error:nil];
    }
    
    
    
    //NSLog(@"Partite salvate!!!!!");
}

- (void) deleteGamesInArray:(NSArray *)gamesToDelete {
    [allGamesAndTags removeObjectsInArray:gamesToDelete];
    [self salvaTutteLePartite];
}

- (NSInteger) getIndexOfGame:(NSString *)game {
    if (!allGamesAndTags) {
        allGamesAndTags = [self caricaTutteLePartite];
    }
    NSUInteger index = [allGamesAndTags indexOfObject:game];
    if (index == NSNotFound) {
        return -1;
    }
    return index;
}


- (void) printAllGamesAllTags {
    for (NSString *g in allGamesAndTags) {
        NSLog(@"%@\n\n", g);
    }
}

#pragma mark - Sezione dedicata al caricamento partite senza occupare memoria (per database con molte partite)

- (void) scorriAllGamesInDatabase {
    //NSMutableArray *tutteLePartite = [[NSMutableArray alloc] init];
    long numeroPartite = 0;
    NSString *line = nil;
    NSMutableString *game = nil;
    NSMutableString *moves = nil;
    reader = [[DDFileReader alloc] initWithFilePath:_path];
    
    
    while ((line = [reader readLine])) {
        
        NSLog(@"NUMERO PARTITE: %ld", numeroPartite);
        
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line hasPrefix:@"%"]) {
            continue;
        }
        
        if ([line hasPrefix:@"ï»¿"]) {
            line = [line stringByTrimmingCharactersInSet:stranoCharSet];
        }
        
        
        if (line.length > 0) {
            if ([line hasPrefix:@"["]) {
                if (!moves) {
                    if (!game) {
                        game = [[NSMutableString alloc] initWithString:line];
                        [game appendString:separator];
                    }
                    else {
                        [game appendString:line];
                        [game appendString:separator];
                    }
                }
                else {
                    if ([moves hasSuffix:@"1-0"] || [moves hasSuffix:@"0-1"] || [moves hasSuffix:@"1/2-1/2"] || [moves hasSuffix:@"*"]) {
                        [game appendString:moves];
                        //[tutteLePartite addObject:game];
                        numeroPartite++;
                        game = nil;
                        moves = nil;
                    }
                    else {
                        [moves appendString:@" "];
                        [moves appendString:line];
                    }
                }
            }
            else if (!moves) {
                //NSLog(@"Incontro per la prima volta le mosse = %@", line);
                
                //NSLog(@"ESEGUO ISTRUZIONI 1 PER ARROCCO CON ZERI");
                //line = [line stringByReplacingOccurrencesOfString:@"0-0" withString:@"O-O"];
                //line = [line stringByReplacingOccurrencesOfString:@"0-0-0" withString:@"O-O-O"];
                
                moves = [[NSMutableString alloc] initWithString:line];
            }
            else {
                [moves appendString:@" "];
                
                //Provo ad inserire qui le istruzioni per correggere il problema dell'arrocco con gli zeri
                //NSLog(@"ESEGUO ISTRUZIONI 2 PER ARROCCO CON ZERI");
                //line = [line stringByReplacingOccurrencesOfString:@"0-0" withString:@"O-O"];
                //line = [line stringByReplacingOccurrencesOfString:@"0-0-0" withString:@"O-O-O"];
                
                [moves appendString:line];
                //NSLog(@"Incontro altre mosse = %@", moves);
            }
        }
        else {
            if (game) {
                //NSLog(@"GAME = %@", game);
                if (moves) {
                    //NSLog(@"MOVES = %@", moves);
                    if ([moves hasSuffix:@"1-0"] || [moves hasSuffix:@"0-1"] || [moves hasSuffix:@"1/2-1/2"] || [moves hasSuffix:@"*"]) {
                        
                        [game appendString:moves];
                        //[tutteLePartite addObject:game];
                        numeroPartite++;
                        
                        //NSLog(@"GAME FINALE = %@", game);
                        
                        game = nil;
                        moves = nil;
                    }
                }
            }
        }
    }
    
    if (game) {
        if (moves) {
            [game appendString:moves];
            //[tutteLePartite addObject:game];
            numeroPartite++;
        }
    }
    
    
    NSLog(@"Ho contato %ld partite", numeroPartite);
    
}

@end
