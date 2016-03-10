//
//  TBPgnFileTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 22/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "BoardViewController.h"

@interface TBPgnFileTableViewController : UITableViewController<UIAlertViewDelegate, BoardViewControllerDelegate>

@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;

@end
