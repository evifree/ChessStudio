//
//  DescriptionViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 05/08/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "DescriptionViewController.h"
#import "UtilToView.h"

@interface DescriptionViewController () {
    //UIWebView *webView;
}

@end

@implementation DescriptionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (IS_IOS_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //webView =[[UIWebView alloc]initWithFrame:[UtilToView getRectByDevice]];
    //webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
    [_webView setScalesPageToFit:YES];
    NSString *riga;
    if (_section == 0) {
        riga = [@"MAIN" stringByAppendingFormat:@"%d", (int)_rigaHelp];
    }
    else if (_section == 2) {
        riga = [@"HELP" stringByAppendingFormat:@"%d", (int)_rigaHelp];
    }
     
    NSString *filePath = [[NSBundle mainBundle] pathForResource:NSLocalizedString(riga, nil) ofType:@"pdf"];
    if (filePath) {
        NSURL *targetURL = [NSURL fileURLWithPath:filePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [_webView loadRequest:request];
        self.navigationItem.title = NSLocalizedString(riga, nil);
    }
    //[self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
