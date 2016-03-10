//
//  EngineViewTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 23/01/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EngineViewTableViewControllerDelegate <NSObject>

- (void) updateFromEngineView;

@end

@interface EngineViewTableViewController : UITableViewController

@property (nonatomic, assign) id<EngineViewTableViewControllerDelegate> delegate;

@end
