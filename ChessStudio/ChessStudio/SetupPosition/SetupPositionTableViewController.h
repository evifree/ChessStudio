//
//  SetupPositionTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 28/08/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardModel.h"
#import "BoardView.h"

@interface SetupPositionTableViewController : UITableViewController

@property (nonatomic, strong) BoardModel *boardModel;
@property (nonatomic, strong) BoardView *boardView;
@property (nonatomic, assign) NSInteger checkupPosition;

@end
