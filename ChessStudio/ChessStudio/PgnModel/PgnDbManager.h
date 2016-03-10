//
//  PgnDbManager.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PgnDbManager : NSObject


+ (id) sharedPgnDbManager;



- (BOOL) isDirectory:(NSString *)item;
- (BOOL) createDirectory:(NSString *)path;
- (BOOL) createFile:(NSString *)file;
- (BOOL) esisteFile:(NSString *)file;
- (BOOL) isPgnFile:(NSString *)file;
- (BOOL) isDirectoryAtPath:(NSString *)path;
- (BOOL) createDatabaseAtPath:(NSString *)pathDatabase;
- (BOOL) existDatabaseAtPath:(NSString *)pathDatabase;
- (BOOL) existDirectoryAtPath:(NSString *)pathDirectory;
- (BOOL) deleteDirectoryAtPath:(NSString *)pathDirectory;
- (BOOL) deleteDatabaseAtPath:(NSString *)pathDatabase;

- (NSInteger) numberOfItemsAtPath:(NSString *)pathDirectory;

- (NSArray *) listDownloadedTwic;
- (NSArray *) listPgnFile;
- (NSArray *) listDirectory:(NSString *)path;
- (NSArray *) listPgnFileAndDirectory;
- (NSString *) getCreationInfo:(NSString *)path;
- (NSMutableArray *) listPgnFileAndDirectoryAtPath:(NSString *)path;
- (NSArray *) listCompletePathPgnFileAndDirectoryAtPath:(NSString *)path;
- (BOOL) moveDatabase:(NSString *)sourcePath :(NSString *)destinationPath;
- (BOOL) copyDatabase:(NSString *)sourcePath :(NSString *)destinationPath;
- (BOOL) renameDatabase:(NSString *)sourcePath :(NSString *)oldDbName :(NSString *)dbName;

- (NSArray *) listOfCloudDatabaseAtPath:(NSString *)path;

@end
