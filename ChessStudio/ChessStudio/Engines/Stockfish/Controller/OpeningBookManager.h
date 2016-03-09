//
//  OpeningBookManager.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 20/01/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpeningBookManager : NSObject

- (id) initManager;
- (id) initManagerWithBookName:(NSString *)bookName;

- (NSString *) getBookMovesForFen:(NSString *)fen;
- (NSString *) getOpeningString:(NSString *)fen;
- (NSArray *) getOpening:(NSString *)fen;
- (NSArray *) getBookMoves:(NSString *)fen;
- (NSArray *) getBookMovesArrayForFen:(NSString *)fen;

@end
