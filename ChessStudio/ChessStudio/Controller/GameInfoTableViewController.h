//
//  GameInfoTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 19/07/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "PGNGame.h"
#import "AdditionalTagTableViewController.h"

@protocol GameInfoTableViewControllerDelegate <NSObject>

-(void) saveGameResult:(NSString *)risultato;
-(void) aggiornaTitoli;

@end

@interface GameInfoTableViewController : UITableViewController<UIActionSheetDelegate, UITextFieldDelegate, AdditionalTagTableViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) id<GameInfoTableViewControllerDelegate> delegate;
@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;
@property (strong, nonatomic) PGNGame *pgnGame;
@property (nonatomic, assign) BOOL modificabile;

@end
