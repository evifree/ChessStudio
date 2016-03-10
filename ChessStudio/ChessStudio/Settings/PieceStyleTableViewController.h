//
//  PieceStyleTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 04/02/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PieceStyleTableViewControllerDelegate <NSObject>

- (void) updateFromPieceStyle;

@end

@interface PieceStyleTableViewController : UITableViewController

@property (nonatomic, assign) id<PieceStyleTableViewControllerDelegate> delegate;

@end
