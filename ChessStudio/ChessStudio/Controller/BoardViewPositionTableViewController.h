//
//  BoardViewPositionTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/02/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BoardViewPositionMenuDelegate <NSObject>

@optional

- (void) flipBoard;
- (void) displaySetting;
- (void) clearPosition;
- (void) savePosition;

@end

@interface BoardViewPositionTableViewController : UITableViewController

@property (nonatomic, assign) id<BoardViewPositionMenuDelegate> delegate;

@end
