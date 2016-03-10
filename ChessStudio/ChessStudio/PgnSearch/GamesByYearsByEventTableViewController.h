//
//  GamesByYearsByEventTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/06/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "GamesTableViewController.h"

@interface GamesByYearsByEventTableViewController : UITableViewController<UIActionSheetDelegate, GamesTableViewControllerDelegate>

@property (strong, nonatomic) PgnFileDocument *pgnFileDoc;

@end
