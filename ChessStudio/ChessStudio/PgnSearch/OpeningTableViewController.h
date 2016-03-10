//
//  OpeningTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"

@interface OpeningTableViewController : UITableViewController

@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;

@end
