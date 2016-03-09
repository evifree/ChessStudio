//
//  CopyPgnDatabaseTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 03/06/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoveFromCloudToPgnDatabaseTableViewControllerDelegate <NSObject>

-(void) moveDatabaseFromCloud:(NSString *)database;

@end

@interface MoveFromCloudToPgnDatabaseTableViewController : UITableViewController<UIAlertViewDelegate, NSFileManagerDelegate>

@property (nonatomic, assign) id<MoveFromCloudToPgnDatabaseTableViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *actualPath;
@property (nonatomic, strong) NSArray *databasesDaSpostare;

@end
