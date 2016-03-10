//
//  BoardSizeTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 06/02/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BoardSizeTableViewControllerDelegate <NSObject>

- (void) updateFromBoardSize;

@end

@interface BoardSizeTableViewController : UITableViewController

@property (nonatomic, assign) id<BoardSizeTableViewControllerDelegate> delegate;

@end
