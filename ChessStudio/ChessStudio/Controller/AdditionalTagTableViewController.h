//
//  AdditionalTagTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 16/05/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGNGame.h"

@protocol AdditionalTagTableViewControllerDelegate <NSObject>

-(void)saveAdditionalTag:(NSString *)additionalTag;
-(void)saveSupplementalTag:(NSDictionary *)supplementalTag;

@end

@interface AdditionalTagTableViewController : UITableViewController<UIAlertViewDelegate>


@property (nonatomic, assign) id<AdditionalTagTableViewControllerDelegate> delegate;

@property (nonatomic, strong) PGNGame *pgnGame;
@property (nonatomic, strong) NSArray *orderedSupplementalTag;

@end
