//
//  EcoTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 18/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "SingleEcoTableViewController.h"

@interface EcoTableViewController : UITableViewController<SingleEcoTableViewControllerDelegate>

@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;

@end
