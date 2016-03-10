//
//  SettingsTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 08/05/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayStyleOptionTableViewController.h"
#import "PlayStrengthViewController.h"
#import "EngineNotationTableViewController.h"
#import "EngineViewTableViewController.h"
#import "PieceStyleTableViewController.h"
#import "SquaresStyleTableViewController.h"
#import "CoordinateTableViewController.h"
#import "MovesNotationTableViewController.h"
#import "BoardSizeTableViewController.h"
#import "EmailRecipientsTableViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "TapOnPieceTableViewController.h"
#import "ColorsTableViewController.h"
#import "TapOnArrivalTableViewController.h"

@protocol SettingsTableViewControllerDelegate <NSObject>

- (void) modifyPiecesType;
- (void) modifyCoordinates;
- (void) modifyBoardSquares;
- (void) modifyMoveNotation;
- (void) modifyBoardSize;
- (void) modifyVistaMotore;
- (BOOL) isEngineViewOpened;
- (BOOL) isEngineRunning;
- (NSString *) getStartFenPosition;
- (void) modifyShowBookMoves;
- (void) modifyShowEco;

- (void) aggiornaOrientamentoDaSettings;

@end

@interface SettingsTableViewController : UITableViewController<PlayStyleOptionDelegate, PlayStrengthDelegate, PieceStyleTableViewControllerDelegate, SquaresStyleTableViewControllerDelegate, CoordinateTableViewControllerDelegate, MovesNotationTableViewControllerDelegate, BoardSizeTableViewControllerDelegate, EngineViewTableViewControllerDelegate, UIAlertViewDelegate, EngineNotationDelegate, EmailRecipientsDelegate>

@property (nonatomic, assign) id<SettingsTableViewControllerDelegate> delegate;

@end
