//
//  SideToMoveViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 23/08/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardView.h"
#import "BoardModel.h"
#import "CastleSetupViewController.h"
#import "EnPassantSquareViewController.h"

@protocol SideToMoveViewControllerDelegate <NSObject>

- (void) aggiornaColore;
- (void) savePositionSetup;

@end

@interface SideToMoveViewController : UIViewController

@property (nonatomic, assign) id<SideToMoveViewControllerDelegate> delegate;

@property (nonatomic, strong) BoardModel *boardModel;

- (id) initWithSquaresAndPieceType:(NSString *)squares :(NSString *)pieceType;

@end
