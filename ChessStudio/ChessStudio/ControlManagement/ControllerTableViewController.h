//
//  ControllerTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 16/05/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ControllerTableViewControllerDelegate <NSObject>

- (void) doneButtonPressed;
- (void) managePawnStructure;
- (void) startForwardAnimation;
- (void) startBackAnimation;
- (NSInteger) loadNextGameFromDatabase;
- (NSInteger) loadPreviousGameFromDatabase;

@end

@interface ControllerTableViewController : UITableViewController

@property (nonatomic, assign) id<ControllerTableViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger indexGame;
@property (nonatomic, strong) NSString *nameDatabase;
@property (nonatomic) BOOL displayLoadGames;

@end
