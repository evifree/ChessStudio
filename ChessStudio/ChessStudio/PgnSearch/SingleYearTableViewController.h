//
//  SingleYearTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/06/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "GamePreviewTableViewController.h"

@protocol SingleYearTableViewControllerDelegate <NSObject>

- (void) aggiorna;

@end

@interface SingleYearTableViewController : UITableViewController<UIActionSheetDelegate, GamePreviewTableViewControllerDelegate>

@property (nonatomic, assign) id<SingleYearTableViewControllerDelegate> delegate;

@property (strong, nonatomic) PgnFileDocument *pgnFileDoc;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSMutableArray *gamesForYear;

@end
