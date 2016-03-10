//
//  DatabaseForCopyTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 25/06/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"


@protocol DatabaseForCopyTableViewControllerDelegate <NSObject>

@optional

- (void) partitaSalvataInDatabaseInModalitaReveal;  //Questo metodo si utilizza solamente quando si deve salvare una partita creata in modalità reveal

@end


@interface DatabaseForCopyTableViewController : UITableViewController<UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) id<DatabaseForCopyTableViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *actualPath;
@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;
@property (nonatomic, strong) NSArray *gamesToCopyArray;
@property (nonatomic, assign) BOOL partitaDaSalvare;

@end
