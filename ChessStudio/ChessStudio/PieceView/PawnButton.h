//
//  PawnButton.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "PieceButton.h"

@interface PawnButton : PieceButton


@property (nonatomic, strong) NSMutableSet *pseudoAttackSquares;

@end
