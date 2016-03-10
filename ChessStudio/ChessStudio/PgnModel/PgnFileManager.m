//
//  PgnFileManager.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PgnFileManager.h"

@interface PgnFileManager() {
    NSFileManager *fileManager;
    NSString *documentPath;
}

@end

@implementation PgnFileManager


- (id) init {
    self = [super init];
    if (self) {
        fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentPath = [paths objectAtIndex:0];
    }
    return self;
}

- (void) setFileName:(NSString *)fileName {
    _fileName = fileName;
    documentPath = [documentPath stringByAppendingPathComponent:_fileName];
}



+ (id) sharedPgnFileManager {
    static PgnFileManager *pgnFileManager  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pgnFileManager = [[self alloc] init];
    });
    return pgnFileManager;
}

@end
