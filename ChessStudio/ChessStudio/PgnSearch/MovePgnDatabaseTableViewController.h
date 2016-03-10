//
//  CopyPgnDatabaseTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 03/06/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MovePgnDatabaseTableViewControllerDelegate <NSObject>

-(void) aggiornaDopoAverCopiato;

@end

@interface MovePgnDatabaseTableViewController : UITableViewController<UIAlertViewDelegate, NSFileManagerDelegate>

@property (nonatomic, assign) id<MovePgnDatabaseTableViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *actualPath;
@property (nonatomic, strong) NSArray *databasesDaSpostare;

@end
