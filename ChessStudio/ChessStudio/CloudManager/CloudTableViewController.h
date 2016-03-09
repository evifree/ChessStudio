//
//  CloudTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 30/06/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "PgnFileInfoTableViewController.h"
#import "SettingManager.h"
#import "CopyFromCloudToPgnDatabaseTableViewController.h"
#import "MoveFromCloudToPgnDatabaseTableViewController.h"


#define PGN_EXTENSION @"dat"

@interface CloudTableViewController : UITableViewController<UIActionSheetDelegate, UIAlertViewDelegate>

@end
