//
//  PlayerDetailTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 07/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "GamePreviewTableViewController.h"

@interface PlayerDetailTableViewController : UITableViewController<UIActionSheetDelegate, GamePreviewTableViewControllerDelegate>

@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;
@property (nonatomic, strong) NSString *playerData;

@end
