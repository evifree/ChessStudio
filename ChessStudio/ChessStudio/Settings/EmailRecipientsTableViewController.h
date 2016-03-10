//
//  EmailRecipientsTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 06/12/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmailRecipientsDelegate <NSObject>

- (void) aggiornaEmailRecipientsInTable:(NSDictionary *)emailRecipients;

@end

@interface EmailRecipientsTableViewController : UITableViewController<UIAlertViewDelegate>

@property (nonatomic, assign) id<EmailRecipientsDelegate> delegate;

@end
