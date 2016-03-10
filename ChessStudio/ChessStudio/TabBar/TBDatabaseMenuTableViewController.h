//
//  TBDatabaseMenuTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 08/11/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TBDatabaseMenuDelegate <NSObject>

- (void) choiceMenu:(NSString *)selectedMenu;

@end

@interface TBDatabaseMenuTableViewController : UITableViewController

@property (nonatomic, assign) id<TBDatabaseMenuDelegate> delegate;
@property (nonatomic, strong) NSArray *listFile;

- (id) initWithStyleAndEditMode:(UITableViewStyle)style :(BOOL)editMode;
- (id) initWithStyleAndEditModeAndNumfile:(UITableViewStyle)style :(BOOL)editMode :(NSArray *)listFile;

@end
