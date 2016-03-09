//
//  BoardViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BoardModel.h"
#import "BoardView.h"
#import "PieceButton.h"
#import "GameWebView.h"
#import "SettingsTableViewController.h"
#import "GameDetailTableViewController.h"
#import "AnnotationMoveTableViewController.h"
#import "PgnFileDocument.h"
#import "GameInfoTableViewController.h"
#import "SetupPositionView.h"
#import "SideToMoveViewController.h"
#import "TextCommentViewController.h"
#import "EngineController.h"
#import "Options.h"
#import "ControllerTableViewController.h"
#import "GameSetting.h"
#import "BoardViewControllerMenuTableViewController.h"
#import "DatabaseForCopyTableViewController.h"
#import "BoardViewPositionTableViewController.h"
#import "TextCommentPopoverViewController.h"
#import "RNGridMenu.h"


@protocol BoardViewControllerDelegate <NSObject>

@optional
- (void) saveGame:(NSMutableString *)game;
- (void) updateFileInfo;
- (void) updateGamePreviewTableViewController;
- (void) updateTBPgnFileTableViewController;
- (PGNGame *) getNextGame;
- (PGNGame *) getPreviousGame;
- (void) updatePgnGame:(PGNGame *)pgnGame;


@end

@interface BoardViewController : UIViewController<PieceButtonDelegate, UIWebViewDelegate, BoardViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, SettingsTableViewControllerDelegate, GameDetailTableViewControllerDelegate, AnnotationMoveTableViewControllerDelegate, MFMailComposeViewControllerDelegate, GameInfoTableViewControllerDelegate, SetupPositionViewDelegate, SideToMoveViewControllerDelegate, TextCommentViewControllerDelegate, EngineControllerDelegate, ADBannerViewDelegate, ControllerTableViewControllerDelegate, BoardViewControllerMenuDelegate, BoardViewPositionMenuDelegate, TextCommentPopoverViewControllerDelegate, DatabaseForCopyTableViewControllerDelegate, RNGridMenuDelegate>


@property (nonatomic, assign) id<BoardViewControllerDelegate> delegate;

@property (nonatomic, strong) BoardModel *gameModel;

@property (strong, nonatomic) IBOutlet GameWebView *gameWebView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *flipButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *avantiButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *indietroButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *varianteSuButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *azioneButton;



//@property (nonatomic) BOOL insertMode;
@property (nonatomic) BOOL setupPosition;

@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;

@property (nonatomic, strong) NSMutableString *gameToView;
@property (nonatomic, strong) NSArray *gameToViewArray;

@property (nonatomic, strong) PGNGame *pgnGame;

@property (strong, nonatomic) ADBannerView *rectangleAdView;

- (IBAction)controllerButtonPressed:(UIBarButtonItem *)sender;

- (IBAction)flipButtonPressed:(id)sender;

- (IBAction)avantiButtonPressed:(id)sender;

- (IBAction)indietroButtonPressed:(id)sender;

- (IBAction)varianteSuButtonPressed:(id)sender;


- (IBAction)backButtonPressed:(id)sender;


@end
