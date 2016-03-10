//
//  EnPassantSquareViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 23/08/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardModel.h"
#import "BoardView.h"

@interface EnPassantSquareViewController : UIViewController

@property (nonatomic, strong) BoardModel *boardModel;
@property (nonatomic, strong) BoardView *boardView;
@property (nonatomic, assign) NSInteger checkupPosition;

@end
