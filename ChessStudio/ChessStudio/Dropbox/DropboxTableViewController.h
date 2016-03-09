//
//  DropboxTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 05/12/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxTableViewController : UITableViewController<DBRestClientDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) DBRestClient *dbRestClient;

@property (nonatomic, strong) NSString *startDirectory;

@property (nonatomic, strong) NSArray *databasesDaCopiare;

@end
