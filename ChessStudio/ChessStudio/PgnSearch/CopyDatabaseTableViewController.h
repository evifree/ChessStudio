//
//  CopyDatabaseTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 29/06/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CopyDatabaseTableViewControllerDelegate <NSObject>

-(void) aggiorna;

@end

@interface CopyDatabaseTableViewController : UITableViewController<UIAlertViewDelegate>

@property (nonatomic, assign) id<CopyDatabaseTableViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *actualPath;
@property (nonatomic, strong) NSArray *databasesDaSpostare;

@end
