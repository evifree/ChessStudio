//
//  SingleEcoTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 20/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileDocument.h"
#import "GamesTableViewController.h"

@protocol SingleEcoTableViewControllerDelegate <NSObject>

- (void) aggiorna;
- (void) aggiornaDopoRotazione;

@end

@interface SingleEcoTableViewController : UITableViewController<UIActionSheetDelegate, GamesTableViewControllerDelegate>

@property (nonatomic, assign) id<SingleEcoTableViewControllerDelegate> delegate;

//@property (nonatomic, strong) NSArray *singleEcoArray;
@property (nonatomic, strong) PgnFileDocument *pgnFileDoc;
@property (nonatomic, strong) NSCountedSet *ecoCountedSet;
@property (nonatomic, strong) NSString *ecoSymbol;
@property (nonatomic, strong) NSString *ecoTitle;

@property (nonatomic, assign) BOOL fromSWReveal;

@end
