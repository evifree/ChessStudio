//
//  GameByYearsTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/06/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "GamePreviewTableViewController.h"

@interface GameByYearsTableViewController : UITableViewController<UIActionSheetDelegate, GamePreviewTableViewControllerDelegate>

@property (strong, nonatomic) PgnFileDocument *pgnFileDoc;

@end
