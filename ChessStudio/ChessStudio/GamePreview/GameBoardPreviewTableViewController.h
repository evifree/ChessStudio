//
//  GameBoardPreviewTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 17/01/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"

@interface GameBoardPreviewTableViewController : UITableViewController

@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;
@property (nonatomic, strong) NSString *game;

- (void) setNumGame:(int)numGame;

@end
