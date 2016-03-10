//
//  AboutNalimovViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 24/07/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "AboutNalimovViewController.h"

@interface AboutNalimovViewController ()

@end

@implementation AboutNalimovViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) loadView {
    [super loadView];
    NSString *path = [[NSBundle mainBundle] pathForResource: NSLocalizedString(@"ABOUT_NALIMOV", nil) ofType: @"html"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath: path];
    NSURLRequest *req = [NSURLRequest requestWithURL: url];
    UIWebView *webView = [[UIWebView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
    [webView setScalesPageToFit: YES];
    [webView loadRequest: req];
    [self setView: webView];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.title = @"Nalimov Tablebase";
}

- (void) doneButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
