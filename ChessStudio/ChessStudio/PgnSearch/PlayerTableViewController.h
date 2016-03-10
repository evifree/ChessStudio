//
//  PlayerTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 25/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"

@interface PlayerTableViewController : UITableViewController<UIActionSheetDelegate>

@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;

@end
