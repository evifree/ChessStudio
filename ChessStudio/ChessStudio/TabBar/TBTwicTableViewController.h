//
//  TBTwicTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 12/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBTwicTableViewController : UITableViewController<NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

- (IBAction)buttonActionPressed:(id)sender;

@end
