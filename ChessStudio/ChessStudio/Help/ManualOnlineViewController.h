//
//  ManualOnlineViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 05/03/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManualOnlineViewController : UIViewController<UIAlertViewDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
