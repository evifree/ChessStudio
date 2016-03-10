//
//  PgnPastedGameTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 20/11/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnPastedGameDetailViewController.h"

@protocol PgnPastedGameTableViewControllerDelegate <NSObject>

@optional
- (void) saveGames:(NSArray *)pastedGames;

@end

@interface PgnPastedGameTableViewController : UITableViewController<PgnPasteGameDetailViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) id<PgnPastedGameTableViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *callingViewController;

@end
