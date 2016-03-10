//
//  DateTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 30/05/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "SingleYearTableViewController.h"

@interface DateTableViewController : UITableViewController<UIActionSheetDelegate, SingleYearTableViewControllerDelegate>

@property (strong, nonatomic) PgnFileDocument *pgnFileDoc;

@end
