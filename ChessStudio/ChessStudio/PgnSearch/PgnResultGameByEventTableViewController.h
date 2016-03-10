//
//  PgnResultGameByEventTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "GamePreviewTableViewController.h"

@interface PgnResultGameByEventTableViewController : UITableViewController<UIActionSheetDelegate, GamePreviewTableViewControllerDelegate>

@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;

@end
