//
//  CoordinateTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 06/02/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoordinateTableViewControllerDelegate <NSObject>

- (void) updateFromCoordinate;

@end

@interface CoordinateTableViewController : UITableViewController

@property (nonatomic, assign) id<CoordinateTableViewControllerDelegate> delegate;

@end
