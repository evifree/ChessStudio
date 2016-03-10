//
//  PgnDownloadViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PgnDownloadViewController : UIViewController<UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *tfAddress;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)downloadButton:(id)sender;
- (IBAction)saveButtonPressed:(UIButton *)sender;

@end
