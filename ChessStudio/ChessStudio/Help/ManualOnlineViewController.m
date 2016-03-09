//
//  ManualOnlineViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 05/03/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "ManualOnlineViewController.h"
#import "UtilToView.h"
#import "Reachability.h"

@interface ManualOnlineViewController () {
    BOOL problemiDownload;
    BOOL esisteManuale;
    
    NSURL *url;
    NSURLRequest *request;
    
    UIAlertView *alert;
}

@end

@implementation ManualOnlineViewController

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
    self.view.backgroundColor = [UIColor redColor];
    
    self.navigationItem.title = NSLocalizedString(@"MANUAL0", nil);
    
    
    _webView.delegate = self;
    [_webView setScalesPageToFit:YES];
    
    problemiDownload = NO;

    esisteManuale = NO;
    
    
    if (![self connected]) {
        UIAlertView *notReachableAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_INTERNET_MANUAL", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        notReachableAlertView.tag = 100;
        [notReachableAlertView show];
        return;
    }
    
    
    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DATABASE_DOWNLOAD", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:nil];
    alert.tag = 300;
    [alert show];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //esisteManuale = [self checkManualeInDocuments];
    

    
    

    

    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *urlString = [NSString stringWithFormat:@"@", NSLocalizedString(@"MANUAL1", nil)];
    NSData *pdfData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    
    if (!pdfData) {
        problemiDownload = YES;
        return;
    }
    else {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, NSLocalizedString(@"MANUAL1", nil)];
    //NSLog(@"PATH = %@", path);
    [pdfData writeToFile:path atomically:YES];
    
    
    url = [NSURL fileURLWithPath:path];
    request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    
    
    
    
    if (problemiDownload) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ERROR_DOWNLOAD", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        av.tag = 200;
        [av show];
    }
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 200) {
        if ([self checkManualeInDocuments]) {
            [self loadManual];
        }
        else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        return;
    }
    if (alertView.tag == 300) {
        NSLog(@"ho sentito ");
        [_webView stopLoading];
        if ([self checkManualeInDocuments]) {
            [self loadManual];
        }
        else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        return;
    }
    if (alertView.tag == 100) {
        if ([self checkManualeInDocuments]) {
            [self loadManual];
        }
        else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        return;
    }
}

- (void) loadManual {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, NSLocalizedString(@"MANUAL1", nil)];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSURL *targetURL = [NSURL fileURLWithPath:path];
        NSURLRequest *targetRequest = [NSURLRequest requestWithURL:targetURL];
        [_webView loadRequest:targetRequest];
    }
}

- (BOOL) checkManualeInDocuments {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, NSLocalizedString(@"MANUAL1", nil)];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}

- (BOOL) connected {
    Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    }
    return YES;
}




//Implementazione metodi UIAlertViewDelegate


@end
