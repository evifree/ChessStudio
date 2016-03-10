//
//  DDFileReader.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 09/12/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDFileReader : NSObject {
    NSString * filePath;
    
    NSFileHandle * fileHandle;
    unsigned long long currentOffset;
    unsigned long long totalFileLength;
    
    NSString * lineDelimiter;
    NSUInteger chunkSize;
}

@property (nonatomic, copy) NSString * lineDelimiter;
@property (nonatomic) NSUInteger chunkSize;

- (id) initWithFilePath:(NSString *)aPath;

- (NSString *) readLine;
- (NSString *) readTrimmedLine;

#if NS_BLOCKS_AVAILABLE
- (void) enumerateLinesUsingBlock:(void(^)(NSString*, BOOL *))block;
#endif

@end
