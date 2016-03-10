//
//  PgnDbManager.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PgnDbManager.h"

@interface PgnDbManager() {
    NSFileManager *fileManager;
    NSString *documentPath;
    //NSString *twicDownloadedPath;
}

@end

@implementation PgnDbManager

- (id) init {
    self = [super init];
    if (self) {
        fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentPath = [paths objectAtIndex:0];
        //twicDownloadedPath = [documentPath stringByAppendingPathComponent:@"twic"];
        //NSLog(@"Document Path = %@", documentPath);
        //NSLog(@"Twic Path = %@", twicDownloadedPath);
    }
    return self;
}



+ (id) sharedPgnDbManager {
    static PgnDbManager *pgnDbManager  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pgnDbManager = [[self alloc] init];
    });
    return pgnDbManager;
}


- (BOOL) isDirectory:(NSString *)item {
    BOOL isDir = NO;
    NSString *path = [documentPath stringByAppendingPathComponent:item];
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        return isDir;
    }
    return isDir;
}

- (BOOL) isDirectoryAtPath:(NSString *)path {
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        return isDir;
    }
    return isDir;
}

- (BOOL) isPgnFile:(NSString *)item {
    if ([item hasSuffix:@".pgn"] && ![self isDirectory:item]) {
        return YES;
    }
    return NO;
}

- (BOOL) esisteFile:(NSString *)file {
    NSString *path = [documentPath stringByAppendingPathComponent:file];
    BOOL *fileExist = [fileManager fileExistsAtPath:path];
    if (fileExist) {
        NSLog(@"Il file %@ esiste", file);
    }
    else {
        NSLog(@"Il file %@ non esiste", file);
    }
    return fileExist;
}

- (BOOL) existDatabaseAtPath:(NSString *)pathDatabase {
    return [fileManager fileExistsAtPath:pathDatabase];
}

- (BOOL) existDirectoryAtPath:(NSString *)pathDirectory {
    return [fileManager fileExistsAtPath:pathDirectory];
}

- (NSInteger) numberOfItemsAtPath:(NSString *)pathDirectory {
    if ([self existDirectoryAtPath:pathDirectory]) {
        NSArray *contentArray = [fileManager contentsOfDirectoryAtPath:pathDirectory error:nil];
        if (!contentArray) {
            return -1;
        }
        NSInteger content = 0;
        for (NSString *c in contentArray) {
            if (![c hasSuffix:@".dat"]) {
                content++;
            }
        }
        return content;
    }
    return -1;
}

- (BOOL) createDirectory:(NSString *)path {
    if ([self existDirectoryAtPath:path]) {
        return NO;
    }
    if ([self isDirectory:path]) {
        return NO;
    }
    else {
        NSError *error = nil;
        //NSString *path = [documentPath stringByAppendingPathComponent:path];
        BOOL *directoryCreata = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (directoryCreata) {
            return YES;
        }
        else {
            NSLog(@"Directory non creata  %@", error.description);
        }
    }
    return NO;
}

- (BOOL) deleteDirectoryAtPath:(NSString *)pathDirectory {
    NSError *error = nil;
    fileManager = [[NSFileManager alloc] init];
    BOOL dirRimossa = [fileManager removeItemAtPath:pathDirectory error:&error];
    if (!dirRimossa) {
        NSLog(@"%@", error);
    }
    return dirRimossa;
}

- (BOOL) deleteDatabaseAtPath:(NSString *)pathDatabase {
    if ([pathDatabase hasSuffix:@".pgn"]) {
        fileManager = [[NSFileManager alloc] init];
        //NSLog(@"Database da elimnare = %@", pathDatabase);
        [fileManager removeItemAtPath:pathDatabase error:nil];
        pathDatabase = [pathDatabase stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"];
        [fileManager removeItemAtPath:pathDatabase error:nil];
        return YES;
    }
    return [fileManager removeItemAtPath:pathDatabase error:nil];
}

- (BOOL) createFile:(NSString *)file {
    if (![self esisteFile:file]) {
        NSString *path = [documentPath stringByAppendingPathComponent:file];
        NSString *content = @"";
        NSData *fileContents = [content dataUsingEncoding:NSUTF8StringEncoding];
        BOOL fileCreato = [fileManager createFileAtPath:path contents:fileContents attributes:nil];
        return fileCreato;
    }
    return NO;
}

- (BOOL) createDatabaseAtPath:(NSString *)pathDatabase {
    if (![self existDatabaseAtPath:pathDatabase]) {
        NSString *content = @"";
        NSData *fileContents = [content dataUsingEncoding:NSUTF8StringEncoding];
        BOOL fileCreato = [fileManager createFileAtPath:pathDatabase contents:fileContents attributes:nil];
        return fileCreato;
    }
    return NO;
}

- (NSArray *) listDownloadedTwic {
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:documentPath error:nil];
    //NSPredicate *filtro = [NSPredicate predicateWithFormat:@"self ENDSWITH '.pgn'"];
    NSPredicate *filtroTwic = [NSPredicate predicateWithFormat:@"(self BEGINSWITH 'twic') && (self ENDSWITH '.pgn')"];
    NSArray *twicArray = [dirContents filteredArrayUsingPredicate:filtroTwic];
    return twicArray;
}

- (NSArray *) listPgnFile {
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:documentPath error:nil];
    NSPredicate *filtroPgn = [NSPredicate predicateWithFormat:@"self ENDSWITH '.pgn'"];
    NSArray *pgnArray = [dirContents filteredArrayUsingPredicate:filtroPgn];
    for (NSString *item in dirContents) {
        if ([self isDirectory:item]) {
            NSLog(@"%@ è una directory", item);
        }
        else {
            NSLog(@"%@ è un file", item);
        }
    }
    return pgnArray;
}

- (NSArray *) listDirectory:(NSString *) path {
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *contenutoDirectory = [[NSMutableArray alloc] init];
    for (NSString *item in dirContents) {
        NSString *newPath = [path stringByAppendingPathComponent:item];
        BOOL isDir = NO;
        if ([fileManager fileExistsAtPath:newPath isDirectory:&isDir]) {
            if (isDir) {
                [contenutoDirectory addObject:item];
            }
        }
    }
    return contenutoDirectory;
}

- (NSArray *) listPgnFileAndDirectory {
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:documentPath error:nil];
    NSMutableArray *contenutoDirectory = [[NSMutableArray alloc] init];
    for (NSString *item in dirContents) {
        if ([self isDirectory:item]) {
            [contenutoDirectory addObject:item];
        }
    }
    NSPredicate *filtroPgn = [NSPredicate predicateWithFormat:@"self ENDSWITH '.pgn'"];
    for (NSString *pgn in [dirContents filteredArrayUsingPredicate:filtroPgn]) {
        [contenutoDirectory addObject:pgn];
    }
    return contenutoDirectory;
}

- (NSMutableArray *) listPgnFileAndDirectoryAtPath:(NSString *)path {
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *contenutoDirectory = [[NSMutableArray alloc] init];
    for (NSString *item in dirContents) {
        NSString *newPath = [path stringByAppendingPathComponent:item];
        BOOL isDir = NO;
        if ([fileManager fileExistsAtPath:newPath isDirectory:&isDir]) {
            if (isDir) {
                if (![newPath hasSuffix:@"/Inbox"]) {
                    [contenutoDirectory addObject:item];
                }
            }
        }
    }
    NSPredicate *filtroPgn = [NSPredicate predicateWithFormat:@"self ENDSWITH '.pgn'"];
    for (NSString *pgn in [dirContents filteredArrayUsingPredicate:filtroPgn]) {
        [contenutoDirectory addObject:pgn];
    }
    return contenutoDirectory;
}

- (NSArray *) listCompletePathPgnFileAndDirectoryAtPath:(NSString *)path {
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *contenutoDirectory = [[NSMutableArray alloc] init];
    
    for (NSString *item in dirContents) {
        NSString *newPath = [path stringByAppendingPathComponent:item];
        BOOL isDir = NO;
        if ([fileManager fileExistsAtPath:newPath isDirectory:&isDir]) {
            if (isDir) {
                if (![newPath hasSuffix:@"/Inbox"]) {
                    [contenutoDirectory addObject:item];
                }
            }
        }
    }
    
    NSPredicate *filtroPgn = [NSPredicate predicateWithFormat:@"self ENDSWITH '.pgn'"];
    for (NSString *pgn in [dirContents filteredArrayUsingPredicate:filtroPgn]) {
        NSString *newPgn = [path stringByAppendingPathComponent:pgn];
        [contenutoDirectory addObject:newPgn];
    }
    return contenutoDirectory;
}

- (NSArray *) listOfCloudDatabaseAtPath:(NSString *)path {
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *contenutoDirectory = [[NSMutableArray alloc] init];
    for (NSString *item in dirContents) {
        if ([self isDirectory:item]) {
            //[contenutoDirectory addObject:item];
        }
    }
    //NSPredicate *filtroCloud = [NSPredicate predicateWithFormat:@"self ENDSWITH '.icloud'"];
    //for (NSString *dat in [dirContents filteredArrayUsingPredicate:filtroCloud]) {
        //NSString *dat = [cloud stringByReplacingOccurrencesOfString:@"icloud" withString:@""];
        //dat = [dat stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
        //NSString *pgn = [dat stringByReplacingOccurrencesOfString:@".dat" withString:@".pgn"];
        //[contenutoDirectory addObject:dat];
    //}
    
    NSPredicate *filtroPgn = [NSPredicate predicateWithFormat:@"self ENDSWITH '.dat'"];
    for (NSString *dat in [dirContents filteredArrayUsingPredicate:filtroPgn]) {
        //NSString *pgn = [dat stringByReplacingOccurrencesOfString:@".dat" withString:@".pgn"];
        [contenutoDirectory addObject:dat];
    }
    return contenutoDirectory;
}

- (NSString *) getCreationInfo:(NSString *)path {
    //NSLog(@"Sto raccogliendo info per %@", path);
    fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSDate *data = nil;
    NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:path error:&error];
    if (error) {
        //NSLog(@"%@", error.localizedDescription);
        data = [[NSDate alloc] init];
    }
    else {
        data = [fileAttr fileCreationDate];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    //[dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    return [dateFormatter stringFromDate:data];
}

- (BOOL) moveDatabase:(NSString *)sourcePath :(NSString *)destinationPath {
    NSError *error = nil;
    NSLog(@"SOURCE = %@", sourcePath);
    NSLog(@"DEST = %@", destinationPath);
    BOOL move = [fileManager moveItemAtPath:sourcePath toPath:destinationPath error:&error];
    if (move) {
        NSString *sourcePathDat = [sourcePath stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"];
        NSString *destPathDat = [destinationPath stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"];
        [fileManager moveItemAtPath:sourcePathDat toPath:destPathDat error:nil];
        return YES;
    }
    else {
        NSLog(@"ERROR IN MOVING = %@", error.description);
    }
    return NO;
}

- (BOOL) copyDatabase:(NSString *)sourcePath :(NSString *)destinationPath {
    NSError *error = nil;
    BOOL copy = [fileManager copyItemAtPath:sourcePath toPath:destinationPath error:&error];
    if (error) {
        NSLog(@"%@", error.description);
    }
    return copy;
}

- (BOOL) renameDatabase:(NSString *)sourcePath :(NSString *)oldDbName :(NSString *)dbName {
    NSError *error = nil;
    NSString *pathIniziale = [sourcePath stringByAppendingPathComponent:oldDbName];
    NSString *pathFinale = [sourcePath stringByAppendingPathComponent:dbName];
    NSLog(@"PATH INIZIALE = %@", pathIniziale);
    NSLog(@"PATH FINALE = %@", pathFinale);
    
    BOOL renamed = [fileManager moveItemAtPath:pathIniziale toPath:pathFinale error:&error];
    
    if (error) {
        NSLog(@"ERROR = %@", error.description);
    }
    
    return renamed;
}


@end
