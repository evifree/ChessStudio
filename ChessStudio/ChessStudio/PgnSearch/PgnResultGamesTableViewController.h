//
//  PgnResultGamesTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "GamePreviewTableViewController.h"
#import "BoardViewController.h"
#import "PgnPastedGameTableViewController.h"

@interface PgnResultGamesTableViewController : UITableViewController<UIActionSheetDelegate, UIAlertViewDelegate, GamePreviewTableViewControllerDelegate, BoardViewControllerDelegate, PgnPastedGameTableViewControllerDelegate>

@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;

@end
