//
//  HelpVideoViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 27/02/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "HelpVideoViewController.h"

@interface HelpVideoViewController () {
    
    Reachability *internetReachability;
    NetworkStatus networkStatus;
    
    NSString *address;
    NSURL *filmUrl;
    MPMoviePlayerController *moviePlayerController;
}

@end

@implementation HelpVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupReachability];
    
    
    self.navigationItem.title = [_videoDictionary objectForKey:NSLocalizedString(@"VIDEO_TITLE", nil)];
    
    address = [_videoDictionary objectForKey:NSLocalizedString(@"VIDEO_DOWNLOAD_URL", nil)];
    filmUrl = [NSURL URLWithString:address];
    
    moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:filmUrl];
    moviePlayerController.view.frame = self.view.bounds;
    [self.view addSubview:moviePlayerController.view];
    
    [moviePlayerController prepareToPlay];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLayoutSubviews {
    [self.view layoutIfNeeded];
    CGRect movieFrame;
    if (IS_PAD) {
        movieFrame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0);
    }
    else if (IS_IPHONE_6P) {
        movieFrame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0);
    }
    else if (IS_IPHONE_6) {
        movieFrame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0);
    }
    else if (IS_IPHONE_5) {
        movieFrame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0);
    }
    else if (IS_IPHONE_4_OR_LESS) {
        movieFrame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0);
    }
    moviePlayerController.view.frame = movieFrame;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (networkStatus == NotReachable) {
        UIAlertView *noConnectionAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noConnectionAlertView show];
        return;
    }
    
    [moviePlayerController play];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [moviePlayerController.view removeFromSuperview];
    moviePlayerController = nil;
}

- (void) setupReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];
    networkStatus = [internetReachability currentReachabilityStatus];
}

- (void) reachabilityChanged:(NSNotification *)notification {
    if (notification) {
        internetReachability = [notification object];
    }
    networkStatus = [internetReachability currentReachabilityStatus];
    if (networkStatus != NotReachable) {
        if ([moviePlayerController isPreparedToPlay]) {
            [moviePlayerController play];
        }
        else {
            if (moviePlayerController) {
                [moviePlayerController.view removeFromSuperview];
                moviePlayerController = nil;
            }
            moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:filmUrl];
            moviePlayerController.view.frame = self.view.bounds;
            [self.view addSubview:moviePlayerController.view];
            
            [moviePlayerController prepareToPlay];
            [moviePlayerController play];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
