//
//  TwicWebViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 18/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwicWebViewController : UIViewController<UIWebViewDelegate, UIAlertViewDelegate>


@property (nonatomic) NSInteger twicNumber;

@property (strong, nonatomic) IBOutlet UIWebView *twicWebView;

@end
