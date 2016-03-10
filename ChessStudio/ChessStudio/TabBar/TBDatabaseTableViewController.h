//
//  TBDatabaseTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 12/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "CopyDatabaseTableViewController.h"
#import "TBDatabaseMenuTableViewController.h"
#import "CopyPgnDatabaseTableViewController.h"
#import "MovePgnDatabaseTableViewController.h"

@interface TBDatabaseTableViewController : UITableViewController<UIActionSheetDelegate, UIAlertViewDelegate, CopyDatabaseTableViewControllerDelegate, MFMailComposeViewControllerDelegate, TBDatabaseMenuDelegate, CopyPgnDatabaseTableViewControllerDelegate, MovePgnDatabaseTableViewControllerDelegate>


@property (nonatomic, strong) NSString *actualPath;

- (IBAction)buttonActionPressed:(id)sender;

@end
