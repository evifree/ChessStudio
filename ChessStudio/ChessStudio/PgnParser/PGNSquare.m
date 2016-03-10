//
//  PGNSquare.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 04/04/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PGNSquare.h"

@implementation PGNSquare


- (id) initWithColumnAndRow:(short)column :(short)row {
    self = [super init];
    if (self) {
        _column = column;
        _row = row;
    }
    return self;
}

@end
