//
//  GamePreviewTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "PgnFileDocument.h"
#import "PGNGame.h"
#import "BoardViewController.h"
#import "AdditionalTagTableViewController.h"


@protocol GamePreviewTableViewControllerDelegate <NSObject>

- (void) aggiorna:(PGNGame *)pgnGame;

//- (NSString *) getNextGame;
//- (NSString *) getPreviousGame;
- (PGNGame *) getPreviousGame;
- (PGNGame *) getNextGame;

@end

@interface GamePreviewTableViewController : UITableViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, BoardViewControllerDelegate, AdditionalTagTableViewControllerDelegate>

@property (nonatomic, assign) id<GamePreviewTableViewControllerDelegate> delegate;

@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;
//@property (strong, nonatomic) NSString *game;
//@property (strong, nonatomic) NSString *moves;
@property (strong, nonatomic) PGNGame *pgnGame;


@end
