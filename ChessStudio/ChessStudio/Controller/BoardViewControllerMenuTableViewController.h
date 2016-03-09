//
//  BoardViewControllerMenuTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 09/02/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGNGame.h"
#import "PGNMove.h"
#import "AnnotationMoveTableViewController.h"

@protocol BoardViewControllerMenuDelegate <NSObject>

@optional
- (BOOL) plycountMaggioreZero;
- (BOOL) esisteTestoIniziale;
- (BOOL) suffissoUltimaMossaXXX;
- (NSString *) getUltimaMossa;
- (BOOL) isUltimaMossaInserita;
- (BOOL) isInVariante;
- (NSString *) getTitleGame;
- (BOOL) isRevealed;
- (PGNMove *) getMossaDaAnnotare;


- (void) exitGame;
- (void) undoMove;
- (void) saveGame;
- (void) displaySetting;
- (void) newGame;
- (void) sendGameByEmail;
- (void) editInitialText;
- (void) addInitialText;
- (void) addAnnotationToMove;
- (void) addTextAfterMove;
- (void) editGameData;
- (void) updateWebViewAfterMoveAnnotation;
- (void) insertVariant;
- (void) insertVariantInsteadOf;
- (void) deleteVariation;
- (void) promuoviVariation;
- (void) editPosition;

@end

@interface BoardViewControllerMenuTableViewController : UITableViewController<AnnotationMoveTableViewControllerDelegate>

@property (nonatomic, assign) id<BoardViewControllerMenuDelegate> delegate;

@property (nonatomic, strong) PGNGame *pgnGame;

@end
