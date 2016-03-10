//
//  PgnMentorPlayersTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 28/11/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMLDocument.h"
#import "HTMLElement.h"
#import "HTMLNode.h"
#import "HTMLSelector.h"
#import "HTMLTextNode.h"
#import "PgnMentorSaveDatabaseTableViewController.h"


@interface PgnMentorPlayersTableViewController : UITableViewController<NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate, PgnMentorSaveDatabaseDelegate>

@property (nonatomic, strong) HTMLDocument *htmlDocument;

@end
