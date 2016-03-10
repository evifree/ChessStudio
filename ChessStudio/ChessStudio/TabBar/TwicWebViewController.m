//
//  TwicWebViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 18/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "TwicWebViewController.h"
#import "MBProgressHUD.h"

@interface TwicWebViewController () {

    NSMutableString *twicWebAddress;
    NSURL *twicUrl;
    NSURLRequest *twicWebRequest;
    
    
    UIAlertView *alert;
    UIAlertView *noWebTwicAlertView;

}

@end

@implementation TwicWebViewController

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
    
    _twicWebView.delegate = self;
    [_twicWebView setScalesPageToFit:YES];
    
    [_twicWebView loadRequest:twicWebRequest];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    self.navigationItem.title = [@"The Week In Chess " stringByAppendingFormat:@"%ld", (long)_twicNumber];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    //[self setTwicWebView:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (IsChessStudioLight) {
        if (IS_IOS_7) {
            self.canDisplayBannerAds = YES;
        }
    }
}


- (void) setTwicNumber:(NSInteger)twicNumber {
    _twicNumber = twicNumber;
    twicWebAddress = [[NSMutableString alloc] initWithString:@"http://www.theweekinchess.com/html/twic"];
    [twicWebAddress appendFormat:@"%ld", (long)_twicNumber];
    [twicWebAddress appendString:@".html"];
    twicUrl = [NSURL URLWithString:twicWebAddress];
    twicWebRequest = [NSURLRequest requestWithURL:twicUrl];
    
    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TWIC DOWNLOAD", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:nil];
    UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 40, 25, 25)];
    progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [progress performSelectorInBackground:@selector(startAnimating) withObject:self];
    [alert addSubview:progress];
    [alert show];
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    /*
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = CGSizeMake(250, 150);
    hud.labelText = @"Loading";
    NSString *detailtext = [[@"The Week In Chess " stringByAppendingFormat:@"%d", _twicNumber] stringByAppendingString:@" web page"];
    hud.detailsLabelText = detailtext;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.00 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        //[_twicWebView loadRequest:twicWebRequest];
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    */
}


- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //NSLog(@"WEB FAILED");
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    //NSLog(@"WEB FINISH");
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSRange range = [html rangeOfString:@"404 - Document Not Found"];
    //NSLog(@"Location = %d", range.location);
    //NSLog(@"Lunghezza = %d", range.length);
    if (range.length > 0) {
        [_twicWebView stopLoading];
        //[self.navigationController popToRootViewControllerAnimated:YES];
        if (!noWebTwicAlertView) {
            noWebTwicAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TWIC ND", nil) message:NSLocalizedString(@"TWIC ND1", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            noWebTwicAlertView.tag = 100;
            [noWebTwicAlertView show];
        }
    }
}

//Implementazione metodi UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        noWebTwicAlertView = nil;
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    [_twicWebView stopLoading];
}

@end
