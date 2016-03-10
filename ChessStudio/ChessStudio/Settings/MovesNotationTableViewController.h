//
//  MovesNotationTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 06/02/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MovesNotationTableViewControllerDelegate <NSObject>

- (void) updateFromMovesNotation;

@end

@interface MovesNotationTableViewController : UITableViewController

@property (nonatomic, assign) id<MovesNotationTableViewControllerDelegate> delegate;

@end
