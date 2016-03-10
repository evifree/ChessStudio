//
//  GamesTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 25/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "GamePreviewTableViewController.h"

@protocol GamesTableViewControllerDelegate <NSObject>

- (void) aggiorna;

@end

@interface GamesTableViewController : UITableViewController<UIActionSheetDelegate, GamePreviewTableViewControllerDelegate>

@property (nonatomic, assign) id<GamesTableViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *games;
@property (nonatomic, strong) NSString *playerName;
@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;


@end
