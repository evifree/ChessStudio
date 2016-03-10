//
//  PGNSquare.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 04/04/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGNSquare : NSObject

@property (nonatomic) short column;
@property (nonatomic) short row;



- (id) initWithColumnAndRow:(short)column :(short)row;


@end
