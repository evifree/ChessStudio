//
//  GameDetailTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/05/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdditionalTagTableViewController.h"
#import "PGNGame.h"


@protocol GameDetailTableViewControllerDelegate <NSObject>

-(void) saveGameDetail:(NSDictionary *)tagValueDictionary;

@end

@interface GameDetailTableViewController : UITableViewController<UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, AdditionalTagTableViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, assign) id<GameDetailTableViewControllerDelegate> delegate;
@property (nonatomic, strong) PGNGame *pgnGame;
@property (nonatomic, strong) NSString *databaseName;

@end
