//
//  PgnPastedGameDetailViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 20/11/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGNPastedGame.h"

@protocol PgnPasteGameDetailViewControllerDelegate <NSObject>

- (void) updateTable;
- (void) saveGame:(NSString *)gameToSave;

@end

@interface PgnPastedGameDetailViewController : UIViewController

@property (nonatomic, assign) id<PgnPasteGameDetailViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextView *gameTextView;
@property (strong, nonatomic) NSString *selectedGameToPast;
@property (strong, nonatomic) PGNPastedGame *pastedGame;

@property (strong, nonatomic) NSString *callingViewController;

@end
