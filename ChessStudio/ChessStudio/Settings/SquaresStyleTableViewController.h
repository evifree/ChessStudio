//
//  SquaresStyleTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 06/02/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SquaresStyleTableViewControllerDelegate <NSObject>

- (void) updateFromSquaresStyle;

@end

@interface SquaresStyleTableViewController : UITableViewController

@property (nonatomic, assign) id<SquaresStyleTableViewControllerDelegate> delegate;

@end
