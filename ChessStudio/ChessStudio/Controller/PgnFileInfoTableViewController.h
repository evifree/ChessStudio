//
//  PgnFileInfoTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 05/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "BoardViewController.h"
#import "PgnPastedGameTableViewController.h"

@interface PgnFileInfoTableViewController : UITableViewController<UIActionSheetDelegate, BoardViewControllerDelegate, PgnPastedGameTableViewControllerDelegate, UIAlertViewDelegate>


@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;

@end
