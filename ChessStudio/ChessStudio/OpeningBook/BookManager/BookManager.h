//
//  BookManager.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 26/11/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookManager : NSObject

- (id) initWithBook:(NSString *)book;


- (void) interrogaBook:(NSString *)fenInput;

- (NSString *) getBookMoves:(NSString *)fenInput;

@end
