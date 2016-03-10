//
//  NumberMoveViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 19/03/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardView.h"
#import "BoardModel.h"
#import "CastleSetupViewController.h"
#import "EnPassantSquareViewController.h"
#import "SetupPositionTableViewController.h"

@interface NumberMoveViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) BoardModel *boardModel;
@property (nonatomic, strong) BoardView *boardView;

@end
