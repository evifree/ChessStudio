//
//  EventTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "GamesTableViewController.h"

@interface EventTableViewController : UITableViewController<GamesTableViewControllerDelegate, UIActionSheetDelegate>


@property (strong, nonatomic) PgnFileDocument *pgnFileDoc;


@end
