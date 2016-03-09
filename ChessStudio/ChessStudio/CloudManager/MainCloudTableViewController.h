//
//  MainCloudTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/05/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "CopyFromCloudToPgnDatabaseTableViewController.h"
#import "MoveFromCloudToPgnDatabaseTableViewController.h"
#import "SettingManager.h"


#define PGN_EXTENSION @"dat"

@interface MainCloudTableViewController : UITableViewController<UIActionSheetDelegate, UIAlertViewDelegate, MoveFromCloudToPgnDatabaseTableViewControllerDelegate, CopyFromCloudToPgnDatabaseTableViewControllerDelegate>

@end
