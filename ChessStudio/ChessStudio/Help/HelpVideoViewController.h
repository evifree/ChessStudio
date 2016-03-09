//
//  HelpVideoViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 27/02/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface HelpVideoViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, strong) NSDictionary *videoDictionary;

@end
