//
//  GameBoardPreviewTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 17/01/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"

@interface EcoBoardPreviewTableViewController : UITableViewController

@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;
@property (nonatomic, strong) NSString *game;

@property (nonatomic, strong) NSString *eco;
@property (nonatomic, strong) NSString *opening;
@property (nonatomic, strong) NSAttributedString *openingMoves;

- (void) setNumGame:(int)numGame;

@end
