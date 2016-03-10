//
//  DDFileReader.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 09/12/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "DDFileReader.h"

@interface NSData (DDAdditions)

- (NSRange) rangeOfData_dd:(NSData *)dataToFind;

@end

@implementation NSData (DDAdditions)

- (NSRange) rangeOfData_dd:(NSData *)dataToFind {
    
    const void * bytes = [self bytes];
    NSUInteger length = [self length];
    
    const void * searchBytes = [dataToFind bytes];
    NSUInteger searchLength = [dataToFind length];
    NSUInteger searchIndex = 0;
    
    NSRange foundRange = {NSNotFound, searchLength};
    for (NSUInteger index = 0; index < length; index++) {
        if (((char *)bytes)[index] == ((char *)searchBytes)[searchIndex]) {
            //the current character matches
            if (foundRange.location == NSNotFound) {
                foundRange.location = index;
            }
            searchIndex++;
            if (searchIndex >= searchLength) { return foundRange; }
        } else {
            searchIndex = 0;
            foundRange.location = NSNotFound;
        }
    }
    return foundRange;
}

@end


@implementation DDFileReader

@synthesize lineDelimiter, chunkSize;

- (id) initWithFilePath:(NSString *)aPath {
    if (self = [super init]) {
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:aPath];
        if (fileHandle == nil) {
            return nil;
        }
        
        lineDelimiter = @"\n";
        currentOffset = 0ULL;
        //chunkSize = 10;
        chunkSize = 128;
        [fileHandle seekToEndOfFile];
        totalFileLength = [fileHandle offsetInFile];
        //we don't need to seek back, since readLine will do that.
    }
    return self;
}

- (void) dealloc {
    [fileHandle closeFile];
    fileHandle = nil;
    filePath = nil;
    lineDelimiter = nil;
    currentOffset = 0ULL;
}

- (NSString *) readLineOld {
    if (currentOffset >= totalFileLength) { return nil; }
    
    NSData *newLineData = [lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle seekToFileOffset:currentOffset];
    NSMutableData * currentData = [[NSMutableData alloc] init];
    BOOL shouldReadMore = YES;
    
    @autoreleasepool {
        while (shouldReadMore) {
            if (currentOffset >= totalFileLength) { break; }
            NSData * chunk = [fileHandle readDataOfLength:chunkSize];
            NSRange newLineRange = [chunk rangeOfData_dd:newLineData];
            if (newLineRange.location != NSNotFound) {
                
                //include the length so we can include the delimiter in the string
                chunk = [chunk subdataWithRange:NSMakeRange(0, newLineRange.location+[newLineData length])];
                shouldReadMore = NO;
            }
            [currentData appendData:chunk];
            currentOffset += [chunk length];
        }
    }

    
    NSString *line = [[NSString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
    
    if (!line) {
        //NSLog(@"line è null e devo fare qualcosa");
        //line = [[NSString alloc] initWithData:currentData encoding:NSISOLatin1StringEncoding];
    }
    
    return line;
}

- (NSString *) readLine {
    if (currentOffset >= totalFileLength) { return nil; }
    
    NSData *newLineData = [lineDelimiter dataUsingEncoding:NSISOLatin1StringEncoding];
    [fileHandle seekToFileOffset:currentOffset];
    NSMutableData * currentData = [[NSMutableData alloc] init];
    BOOL shouldReadMore = YES;
    
    @autoreleasepool {
        while (shouldReadMore) {
            if (currentOffset >= totalFileLength) { break; }
            NSData * chunk = [fileHandle readDataOfLength:chunkSize];
            NSRange newLineRange = [chunk rangeOfData_dd:newLineData];
            if (newLineRange.location != NSNotFound) {
                
                //include the length so we can include the delimiter in the string
                chunk = [chunk subdataWithRange:NSMakeRange(0, newLineRange.location+[newLineData length])];
                shouldReadMore = NO;
            }
            [currentData appendData:chunk];
            currentOffset += [chunk length];
        }
    }
    
    
    NSString *line = [[NSString alloc] initWithData:currentData encoding:NSISOLatin1StringEncoding];
    
    return line;
}

- (NSString *) readTrimmedLine {
    return [[self readLine] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#if NS_BLOCKS_AVAILABLE
- (void) enumerateLinesUsingBlock:(void(^)(NSString*, BOOL*))block {
    NSString * line = nil;
    BOOL stop = NO;
    while (stop == NO && (line = [self readLine])) {
        block(line, &stop);
    }
}
#endif

@end
