//
//  PgnMentorSaveDatabaseTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 29/11/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PgnMentorSaveDatabaseDelegate <NSObject>

-(void)saveDatabase:(NSString *)path;

@end

@interface PgnMentorSaveDatabaseTableViewController : UITableViewController<UIAlertViewDelegate>

@property (nonatomic, assign) id<PgnMentorSaveDatabaseDelegate> delegate;

@property (nonatomic, strong) NSString *rootPath;

@property (nonatomic, strong) NSString *fileToSave;

@end
