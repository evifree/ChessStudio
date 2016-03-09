//
//  DescriptionViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 05/08/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DescriptionViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, assign) NSUInteger section;
@property (nonatomic, assign) NSUInteger rigaHelp;

@end
