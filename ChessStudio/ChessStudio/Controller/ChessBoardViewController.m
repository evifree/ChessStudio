//
//  ChessBoardViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 09/01/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "ChessBoardViewController.h"
#import "SettingManager.h"

@interface ChessBoardViewController () {
    
    SettingManager *settingManager;

    UIView *viewForBoard;
    UIView *viewForWebMoves;
    UIView *viewForEngine;

    
    CGRect boardRect, webViewRect, engineRect;
}

@end

@implementation ChessBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void) loadView {
    [super loadView];
    
    settingManager = [SettingManager sharedSettingManager];
    //BOOL portrait = UIInterfaceOrientationIsPortrait([self interfaceOrientation]);

    [self loadInterface];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeButtonPressed)];
    self.navigationItem.leftBarButtonItem = closeBarButtonItem;
    
    self.navigationItem.title = @"Chess Board";
    //self.navigationController.toolbarHidden = NO;
    
    
    UIToolbar *toolbar = self.navigationController.toolbar;
    
    NSLog(@"TOOLBAR RECT: %f     %f     %f    %f", toolbar.frame.origin.x, toolbar.frame.origin.y, toolbar.frame.size.width, toolbar.frame.size.height);
    
    NSArray *items = [toolbar items];
    NSLog(@"ITEMS = %lu", (unsigned long)items.count);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) closeButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

}
- (IBAction)testAzione:(UIBarButtonItem *)sender {
    
    NSLog(@"Test Azione");
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [viewForBoard removeFromSuperview];
    [viewForWebMoves removeFromSuperview];
    [viewForEngine removeFromSuperview];
    
    [self loadInterface];
    
}

- (void) loadInterface {
    //boardRect = [settingManager getViewRectForBoard:[self interfaceOrientation]];
    viewForBoard = [[UIView alloc] initWithFrame:boardRect];
    [viewForBoard setBackgroundColor:[UIColor colorWithRed:0.000 green:0.557 blue:0.165 alpha:1.000]];
    [self.view addSubview:viewForBoard];
    
    //webViewRect = [settingManager getViewRectForWebMoves:[self interfaceOrientation]];
    
    NSLog(@"BOARD RECT: %f     %f     %f    %f", boardRect.origin.x, boardRect.origin.y, boardRect.size.width, boardRect.size.height);
    
    viewForWebMoves = [[UIView alloc] initWithFrame:webViewRect];
    [viewForWebMoves setBackgroundColor:[[UIColor yellowColor]colorWithAlphaComponent:0.5]];
    [self.view addSubview:viewForWebMoves];
    
    NSLog(@"WEB VIEW RECT: %f     %f     %f    %f", webViewRect.origin.x, webViewRect.origin.y, webViewRect.size.width, webViewRect.size.height);
    
    //engineRect = [settingManager getViewRectForEngine:[self interfaceOrientation]];
    
    if (!CGRectIsEmpty(engineRect)) {
        viewForEngine = [[UIView alloc] initWithFrame:engineRect];
        [viewForEngine setBackgroundColor:[[UIColor orangeColor] colorWithAlphaComponent:0.5]];
        [self.view addSubview:viewForEngine];
        NSLog(@"ENGINE RECT:  %f     %f     %f    %f", engineRect.origin.x, engineRect.origin.y, engineRect.size.width, engineRect.size.height);
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
