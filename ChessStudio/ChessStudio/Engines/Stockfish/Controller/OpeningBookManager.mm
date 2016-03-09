//
//  OpeningBookManager.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 20/01/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "OpeningBookManager.h"
#import "OpeningBook.h"
#import "ECO.h"

//#include "../Chess/position.h"
//#include "../Chess/movepick.h"
//#include "../Chess/direction.h"
//#include "../Chess/mersenne.h"
//#include "../Chess/bitboard.h"

@interface OpeningBookManager() {
    Chess::Position *startPosition;
    Chess::Position *currentPosition;
    OpeningBook *openingBook;
    
    NSString *openingString;
    NSArray *openingArray;
    
    ECO *eco;
}

@end

@implementation OpeningBookManager

- (id) initManager {
    self = [super init];
    if (self) {
        //init_mersenne();
        //init_direction_table();
        //init_bitboards();
        //Position::init_zobrist();
        //Position::init_piece_square_tables();
        //MovePicker::init_phase_table();
        
        // Make random number generation less deterministic, for book moves
        //int i = abs(get_system_time() % 10000);
        //for (int j = 0; j < i; j++)
        //    genrand_int32();
        
        startPosition = new Chess::Position;
        currentPosition = new Chess::Position;
        
        NSString *fen = @"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
        
        startPosition->from_fen([fen UTF8String]);
        currentPosition->copy(*startPosition);
        openingBook = [[OpeningBook alloc] init];
        
        eco = [ECO sharedInstance];
        
        //NSString *bookMoves = [openingBook bookMovesAsString:currentPosition];
        //NSLog(@"################ %@", bookMoves);
    }
    return self;
}

- (id) initManagerWithBookName:(NSString *)bookName {
    self = [super init];
    if (self) {
        //init_mersenne();
        //init_direction_table();
        //init_bitboards();
        //Position::init_zobrist();
        //Position::init_piece_square_tables();
        //MovePicker::init_phase_table();
        
        // Make random number generation less deterministic, for book moves
        //int i = abs(get_system_time() % 10000);
        //for (int j = 0; j < i; j++)
        //    genrand_int32();
        
        startPosition = new Chess::Position;
        currentPosition = new Chess::Position;
        
        NSString *fen = @"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
        
        startPosition->from_fen([fen UTF8String]);
        currentPosition->copy(*startPosition);
        openingBook = [[OpeningBook alloc] initWithFilename:bookName];
        
        //NSString *bookMoves = [openingBook bookMovesAsString:currentPosition];
        //NSLog(@"################ %@", bookMoves);
    }
    return self;
}

- (NSString *) getBookMovesForFen:(NSString *)fen {
    Chess::Position *p = new Chess::Position;
    p->from_fen([fen UTF8String]);
    currentPosition->copy(*p);
    NSString *bookMoves = [openingBook bookMovesAsString:currentPosition];
    return bookMoves;
}

- (NSArray *) getBookMoves:(NSString *)fen {
    Chess::Position *p = new Chess::Position;
    p->from_fen([fen UTF8String]);
    currentPosition->copy(*p);
    NSString *bookMoves = [openingBook bookMovesAsString:currentPosition];
    //NSLog(@"%@", bookMoves);
    NSArray *bookArray = [bookMoves componentsSeparatedByString:@") "];
    NSMutableArray *newBookArray = [[NSMutableArray alloc] init];
    for (NSString *m in bookArray) {
        [newBookArray addObject:[m stringByAppendingString:@")"]];
    }
    [newBookArray removeLastObject];
    return newBookArray;
}

- (NSArray *) getBookMovesArrayForFen:(NSString *)fen {
    Chess::Position *p = new Chess::Position;
    p->from_fen([fen UTF8String]);
    currentPosition->copy(*p);
    NSArray *bookMovesArray = [openingBook bookMovesAsArray:currentPosition];
    
    NSString *bookMoves = [bookMovesArray objectAtIndex:0];
    NSArray *bookArray = [bookMoves componentsSeparatedByString:@") "];
    NSMutableArray *newBookArray = [[NSMutableArray alloc] init];
    for (NSString *m in bookArray) {
        [newBookArray addObject:[m stringByAppendingString:@")"]];
    }
    [newBookArray removeLastObject];
    
    NSString *bookMovesComplete = [bookMovesArray objectAtIndex:1];
    NSArray *movesCompleteArray = [bookMovesComplete componentsSeparatedByString:@" "];
    NSMutableArray *newMovesCompleteArray = [[NSMutableArray alloc] init];
    for (NSString *m in movesCompleteArray) {
        [newMovesCompleteArray addObject:m];
    }
    //[newMovesCompleteArray removeLastObject];
    
    return [NSArray arrayWithObjects:newBookArray, newMovesCompleteArray, nil];
    
}

- (NSString *) getOpeningString:(NSString *)fen {
    Chess::Position *p = new Chess::Position;
    p->from_fen([fen UTF8String]);
    currentPosition->copy(*p);
    //NSString *s = [[ECO sharedInstance] openingDescriptionForKey: currentPosition->get_key((int)i)];
    //NSString *s = [[ECO sharedInstance] openingDescriptionForKey:currentPosition->get_key()];
    NSString *s = [eco openingDescriptionForKey:currentPosition->get_key()];
    if ([s isEqualToString:@"(null)"] || !s) {
        return openingString;
    }
    else {
        openingString = s;
        return openingString;
    }
}

- (NSArray *) getOpening:(NSString *)fen {
    Chess::Position *p = new Chess::Position;
    p->from_fen([fen UTF8String]);
    currentPosition->copy(*p);
    NSArray *opArray = [eco openingForKey:currentPosition->get_key()];
    if (opArray.count == 0) {
        //return openingArray;
        return opArray;
    }
    else {
        //openingArray = opArray;
        return opArray;
    }
    //return
    //return [[ECO sharedInstance] openingForKey:currentPosition->get_key()];
}

@end
