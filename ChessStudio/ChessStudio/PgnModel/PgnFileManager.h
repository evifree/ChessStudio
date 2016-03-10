//
//  PgnFileManager.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PgnFileManager : NSObject

+ (id) sharedPgnFileManager;

@property(nonatomic, strong) NSString *fileName;

@end
