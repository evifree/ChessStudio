//
//  PgnFileDocument.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 07/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PgnFileDocument.h"

@interface PgnFileDocument() {


}

@end

@implementation PgnFileDocument

@synthesize pgnFileInfo = _pgnFileInfo;

- (id) contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSLog(@"Eseguo contentsForType");
    if (_pgnFileInfo == nil) {
        return nil;
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_pgnFileInfo];
    return data;
}

- (BOOL) loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSLog(@"Eseguo LoadFromContents");
    NSLog(@"Path: %@", self.fileURL.path);
    
    if ([self.fileURL.path hasSuffix:@".pgn"]) {
        
        NSLog(@"pgn name: %@", self.fileURL.lastPathComponent);
        
        //_pgnFileInfo = [[PgnFileInfo alloc] initWithFileName:self.fileURL.lastPathComponent];
        _pgnFileInfo = [[PgnFileInfo alloc] initWithFilePath:self.fileURL.path];
        return YES;
    }
    
    _pgnFileInfo = [NSKeyedUnarchiver unarchiveObjectWithData:contents];
    
    if ([self.fileURL.path hasSuffix:@".dat"]) {
        NSLog(@"Il file è di tipo dat");
    }
    
    
    if (_pgnFileInfo) {
        //NSLog(@"PgnFileInfo OK");
        //NSLog(@"Numero Partite: %d", _pgnFileInfo.numberOfGames.intValue);
        //NSLog(@"%@", self.description);
        //NSLog(@"%@", _pgnFileInfo.attributiFile);
    }
    return YES;
}

@end
