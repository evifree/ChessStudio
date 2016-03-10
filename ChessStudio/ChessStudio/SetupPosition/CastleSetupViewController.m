//
//  CastleSetupViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 23/08/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "CastleSetupViewController.h"
#import "SideToMoveViewController.h"
#import "SetupPositionTableViewController.h"
#import "SettingManager.h"

@interface CastleSetupViewController () {

    UISwitch *wOOOswitch, *wOOswitch, *bOOOswitch, *bOOswitch;
    
    CGFloat dimSquare;
    NSString *_pieceType;
    SettingManager *settingManager;
    
}

@end

@implementation CastleSetupViewController

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
    
    //self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    settingManager = [SettingManager sharedSettingManager];
    _pieceType = [settingManager getPieceTypeToLoad];
    
    if (IS_IOS_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = UIColorFromRGB(0xffffa6);
    
    if (IS_PAD) {
        CGRect boardFrame = _boardView.frame;
        boardFrame.origin.x = 30;
        boardFrame.origin.y = 48;
        _boardView.frame = boardFrame;
    }
    
    if ([_boardModel esisteAlmenoUnaPresaEnPassant]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"En Passant" style:UIBarButtonItemStyleDone target:self action:@selector(enPassantButtonPressed)];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    }
    
    
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationItem.title = NSLocalizedString(@"SETUP_POSITION_CASTLING", nil);
    if (IS_PAD) {
        CGRect boardFrame = _boardView.frame;
        boardFrame.origin.x = 30;
        boardFrame.origin.y = 48;
        _boardView.frame = boardFrame;
        [self.view addSubview:_boardView];
        [self setupCastleSwitch];
    }
    
    if (IS_PHONE) {
        [self setupClear];
        [self setupCastleBoard];
        [self.view addSubview:_boardView];
        [self setupCastleSwitch];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (!IS_PAD) {
        [self setupClear];
    }
    
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = 33.5;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(128, 0, 268, 268)];
            if (IS_IPHONE_5) {
                [_boardView setFrame:CGRectMake(172, 0, 268, 268)];
                _boardView.center = CGPointMake(568.0/2, _boardView.center.y);
            }
            else if (IS_IPHONE_4_OR_LESS) {
                [_boardView setFrame:CGRectMake(128, 0, 268, 268)];
                _boardView.center = CGPointMake(480.0/2, _boardView.center.y);
            }
            [self setupPositionFromBoardModel];
        }
        else if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
            dimSquare = 40.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(0, 48.0, 320, 320)];
            [self setupPositionFromBoardModel];
        }
    }
    else if (IS_IPHONE_6) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            //[self setupCastleBoard];
            dimSquare = 40.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(172.0, 3, 320.0, 320.0)];
            _boardView.center = CGPointMake(667/2, 343/2);
            [self setupPositionFromBoardModel];
        }
        else {
            dimSquare = 46.875;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(0, 48.0, 320, 320)];
            [self setupPositionFromBoardModel];
        }
    }
    else if (IS_IPHONE_6P) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        }
        else {
            dimSquare = 35.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(67.0, 30.0, 320.0, 320.0)];
            [self setupPositionFromBoardModel];
        }
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.view addSubview:_boardView];
    [self setupCastleSwitch];
}

- (void) setupClear {
    [_boardView removeFromSuperview];
    _boardView = nil;
    [bOOOswitch removeFromSuperview];
    [bOOswitch removeFromSuperview];
    [wOOOswitch removeFromSuperview];
    [wOOswitch removeFromSuperview];
    for (int i=1; i<=4; i++) {
        UILabel *l = (UILabel *)[self.view viewWithTag:i];
        if (l) {
            [l removeFromSuperview];
            l = nil;
        }
    }
}

- (void) setupCastleBoard {
    if (!IS_PAD) {
        if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
            if (IS_PORTRAIT) {
                dimSquare = 40.0;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [_boardView setFrame:CGRectMake(0, 48.0, 320, 320)];
                [self setupPositionFromBoardModel];
            }
            else {
                dimSquare = 33.5;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [_boardView setFrame:CGRectMake(128, 3, 240, 240)];
                if (IS_IPHONE_5) {
                    [_boardView setFrame:CGRectMake(172, 0, 268, 268)];
                }
                else if (IS_IPHONE_4_OR_LESS) {
                    [_boardView setFrame:CGRectMake(128, 3, 268, 268)];
                }
                _boardView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
                [self setupPositionFromBoardModel];
            }
        }
        else if (IS_IPHONE_6) {
            if (IS_PORTRAIT) {
                dimSquare = 46.875;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [_boardView setFrame:CGRectMake(0, 48.0, 320, 320)];
                [self setupPositionFromBoardModel];
            }
            else {
                dimSquare = 40.0;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [_boardView setFrame:CGRectMake(172.0, 3, 320.0, 320.0)];
                _boardView.center = CGPointMake(667/2, 343/2);
                [self setupPositionFromBoardModel];
            }
        }
        else if (IS_IPHONE_6P) {
            if (IS_PORTRAIT) {
                dimSquare = 35.0;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [_boardView setFrame:CGRectMake(67.0, 30.0, 320.0, 320.0)];
                //_boardView.center = CGPointMake(420.0/2, 300.0/2);
                [self setupPositionFromBoardModel];
            }
            else {
                dimSquare = 35.0;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [_boardView setFrame:CGRectMake(67.0, 30.0, 320.0, 320.0)];
                //_boardView.center = CGPointMake(420.0/2, 300.0/2);
                [self setupPositionFromBoardModel];
            }
        }
    }
}

- (void) setupCastleSwitch {
    
    UILabel *label;
    
    if (IS_PAD) {
        bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(30, 15, 0, 0)];
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            if (IS_IOS_7) {
                bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(50, 16, 0, 0)];
            }
            else {
                bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(41, 18, 0, 0)];
            }
        }
        else {
            if (IS_IOS_7) {
                bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(35, 20, 0, 0)];
            }
            else {
                bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(26, 20, 0, 0)];
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            if (IS_IOS_7) {
                bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(50, 16, 0, 0)];
            }
            else {
                bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(41, 18, 0, 0)];
            }
        }
        else {
            if (IS_IOS_7) {
                bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(75, 20, 0, 0)];
            }
            else {
                bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(66, 20, 0, 0)];
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(70, 16, 0, 0)];
        }
        else {
            bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(110, 17, 0, 0)];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(10, 30, 0, 0)];
        }
        else {
            //bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(110, 17, 0, 0)];
            bOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(10, 30, 0, 0)];
        }
    }
    
    bOOOswitch.tag = 2;
    [bOOOswitch addTarget:self action:@selector(switchManage:) forControlEvents:UIControlEventValueChanged];
    
    if ([_boardModel neroPuoArroccareLungoInPosizione]) {
        [bOOOswitch setOn:YES];
    }
    else {
        [bOOOswitch setOn:NO];
        [bOOOswitch setEnabled:NO];
    }
    
    [self.view addSubview:bOOOswitch];
    
    if (IS_PAD) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(120, 20, 105, 20)];
        [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:20]];
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(97, 0, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }

    
    [label setText: NSLocalizedString(@"SETUP_POSITION_BLACK_OOO", nil)];
    [label setTextColor:[UIColor blackColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    label.tag = 1;
    [self.view addSubview:label];
    
    if (IS_PAD) {
        bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(432, 15, 0, 0)];
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            if (IS_IOS_7) {
                bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(220, 16, 0, 0)];
            }
            else {
                bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(211, 18, 0, 0)];
            }
        }
        else {
            if (IS_IOS_7) {
                bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(385, 20, 0, 0)];
            }
            else {
                bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(376, 20, 0, 0)];
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            if (IS_IOS_7) {
                bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(220, 16, 0, 0)];
            }
            else {
                bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(211, 18, 0, 0)];
            }
        }
        else {
            if (IS_IOS_7) {
                bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(430, 20, 0, 0)];
            }
            else {
                bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(421, 20, 0, 0)];
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(270, 16, 0, 0)];
        }
        else {
            bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(505, 17, 0, 0)];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(357, 30, 0, 0)];
        }
        else {
            //bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(505, 17, 0, 0)];
            bOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(357, 30, 0, 0)];
        }
    }
    
    bOOswitch.tag = 3;
    [bOOswitch addTarget:self action:@selector(switchManage:) forControlEvents:UIControlEventValueChanged];
    
    if ([_boardModel neroPuoArroccareCortoInPosizione]) {
        [bOOswitch setOn:YES];
    }
    else {
        [bOOswitch setOn:NO];
        [bOOswitch setEnabled:NO];
    }
    
    [self.view addSubview:bOOswitch];
    
    if (IS_PAD) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(345, 20, 105, 20)];
        [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:20]];
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(220, 0, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(380, 0, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(220, 0, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(430, 0, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(265, 0, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(500, 0, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(348, 10, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            //label = [[UILabel alloc] initWithFrame:CGRectMake(500, 0, 100, 20)];
            //[label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
            label = [[UILabel alloc] initWithFrame:CGRectMake(348, 10, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }

    
    [label setText: NSLocalizedString(@"SETUP_POSITION_BLACK_OO", nil)];
    [label setTextColor:[UIColor blackColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    label.tag = 2;
    [self.view addSubview:label];
    
    
    if (IS_PAD) {
        wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(30, 534, 0, 0)];
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            if (IS_IOS_7) {
                wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(50, 369, 0, 0)];
            }
            else {
                wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(36, 371, 0, 0)];
            }
        }
        else {
            if (IS_IOS_7) {
                wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(35, 230, 0, 0)];
            }
            else {
                wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(26, 230, 0, 0)];
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            if (IS_IOS_7) {
                wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(50, 369, 0, 0)];
            }
            else {
                wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(36, 371, 0, 0)];
            }
        }
        else {
            if (IS_IOS_7) {
                wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(75, 232, 0, 0)];
            }
            else {
                wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(66, 232, 0, 0)];
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(70, 440, 0, 0)];
        }
        else {
            wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(110, 300, 0, 0)];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(10, 280, 0, 0)];
        }
        else {
            wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(10, 280, 0, 0)];
            //wOOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(110, 300, 0, 0)];
        }
    }

    
    wOOOswitch.tag = 0;
    [wOOOswitch addTarget:self action:@selector(switchManage:) forControlEvents:UIControlEventValueChanged];
    
    if ([_boardModel biancoPuoArroccareLungoInPosizione]) {
        [wOOOswitch setOn:YES];
    }
    else {
        [wOOOswitch setOn:NO];
        [wOOOswitch setEnabled:NO];
    }
    
    [self.view addSubview:wOOOswitch];
    
    
    if (IS_PAD) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(120, 539, 105, 20)];
        [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:20]];
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(45, 398, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(30, 210, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(45, 398, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(70, 210, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(60, 422, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(97, 283, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(5, 310, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            //label = [[UILabel alloc] initWithFrame:CGRectMake(97, 283, 100, 20)];
            //[label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
            label = [[UILabel alloc] initWithFrame:CGRectMake(5, 310, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }

    
    [label setText: NSLocalizedString(@"SETUP_POSITION_WHITE_OOO", nil)];
    [label setTextColor:[UIColor blackColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    label.tag = 3;
    [self.view addSubview:label];
    
    
    if (IS_PAD) {
        wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(432, 534, 0, 0)];
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            if (IS_IOS_7) {
                wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(220, 369, 0, 0)];
            }
            else {
                wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(211, 371, 0, 0)];
            }
        }
        else {
            if (IS_IOS_7) {
                wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(385, 230, 0, 0)];
            }
            else {
                wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(376, 230, 0, 0)];
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            if (IS_IOS_7) {
                wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(220, 369, 0, 0)];
            }
            else {
                wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(211, 371, 0, 0)];
            }
        }
        else {
            if (IS_IOS_7) {
                wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(430, 230, 0, 0)];
            }
            else {
                wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(421, 230, 0, 0)];
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(270, 440, 0, 0)];
        }
        else {
            wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(505, 300, 0, 0)];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(357, 280, 0, 0)];
        }
        else {
            //wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(505, 300, 0, 0)];
            wOOswitch = [[UISwitch alloc] initWithFrame: CGRectMake(357, 280, 0, 0)];
        }
    }
    
    wOOswitch.tag = 1;
    [wOOswitch addTarget:self action:@selector(switchManage:) forControlEvents:UIControlEventValueChanged];
    
    if ([_boardModel biancoPuoArroccareCortoInPosizione]) {
        [wOOswitch setOn:YES];
    }
    else {
        [wOOswitch setOn:NO];
        [wOOswitch setEnabled:NO];
    }
    
    [self.view addSubview:wOOswitch];
    
    if (IS_PAD) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(345, 539, 105, 20)];
        [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:20]];
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(220, 398, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(380, 210, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(220, 398, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(430, 210, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(265, 422, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(500, 283, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(348, 310, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
        else {
            //label = [[UILabel alloc] initWithFrame:CGRectMake(500, 283, 100, 20)];
            //[label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
            label = [[UILabel alloc] initWithFrame:CGRectMake(348, 310, 100, 20)];
            [label setFont:[UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:15]];
        }
    }

    
    [label setText: NSLocalizedString(@"SETUP_POSITION_WHITE_OO", nil)];
    [label setTextColor:[UIColor blackColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    label.tag = 4;
    [self.view addSubview:label];

}

- (void) setupPositionFromBoardModel {
    PieceButton *pb;
    for (int i=0; i<64; i++) {
        NSString *square = [_boardModel findContenutoBySquareNumber:i];
        if (![square hasSuffix:@"m"]) {
            if ([square hasSuffix:@"r"]) {
                pb = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:_pieceType:square];
            }
            else {
                if ([square hasSuffix:@"k"]) {
                    pb = [[[KingButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:_pieceType:square];
                }
                else {
                    if ([square hasSuffix:@"q"]) {
                        pb = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:_pieceType:square];
                    }
                    else {
                        if ([square hasSuffix:@"n"]) {
                            pb = [[[KnightButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:_pieceType:square];
                        }
                        else {
                            if ([square hasSuffix:@"b"]) {
                                pb = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:_pieceType:square];
                            }
                            else {
                                if ([square hasSuffix:@"p"]) {
                                    pb = [[[PawnButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:_pieceType:square];
                                }
                            }
                        }
                    }
                }
            }
            //[pb setSquareNumber:[[boardModel.numericSquares objectAtIndex:i] intValue]];
            [pb setCasaIniziale:i];
            [pb setSquareValue:i];
            //if (flipped) {
            //    [pb flip];
            //}
            [pb setUserInteractionEnabled:NO];
            [_boardView addSubview:pb];
        }
        else {
            PieceButton *pb = [_boardView findPieceBySquareTag:i];
            if (pb) {
                [pb removeFromSuperview];
            }
        }
    }
}

- (void) setupSwitch {
    if ([_boardModel neroPuoArroccareLungoInPosizione]) {
        [bOOOswitch setOn:YES];
    }
    else {
        [bOOOswitch setOn:NO];
        //[bOOOswitch setEnabled:NO];
    }
    
    if ([_boardModel neroPuoArroccareCortoInPosizione]) {
        [bOOswitch setOn:YES];
    }
    else {
        [bOOswitch setOn:NO];
        //[bOOswitch setEnabled:NO];
    }
    
    if ([_boardModel biancoPuoArroccareLungoInPosizione]) {
        [wOOOswitch setOn:YES];
    }
    else {
        [wOOOswitch setOn:NO];
        //[wOOOswitch setEnabled:NO];
    }
    
    if ([_boardModel biancoPuoArroccareCortoInPosizione]) {
        [wOOswitch setOn:YES];
    }
    else {
        [wOOswitch setOn:NO];
        //[wOOswitch setEnabled:NO];
    }
}

- (void) switchManage:(UISwitch *)switchSelected {
    switch (switchSelected.tag) {
        case 0:
            [_boardModel setBiancoPuoArroccareLungo:[switchSelected isOn]];
            break;
        case 1:
            [_boardModel setBiancoPuoArroccareCorto:[switchSelected isOn]];
            break;
        case 2:
            [_boardModel setNeroPuoArroccareLungo:[switchSelected isOn]];
            break;
        case 3:
            [_boardModel setNeroPuoArroccareCorto:[switchSelected isOn]];
            break;
        default:
            break;
    }
    [self setupSwitch];
}

- (void) doneButtonPressed {
    if (IS_PHONE) {
        self.navigationItem.title = NSLocalizedString(@"BACK", nil);
    }
    SetupPositionTableViewController *sptvc = [[SetupPositionTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [sptvc setBoardModel:_boardModel];
    [sptvc setBoardView:_boardView];
    [sptvc setCheckupPosition:_checkupPosition];
    [self.navigationController pushViewController:sptvc animated:YES];
    //return;
    //SideToMoveViewController *stmvc = (SideToMoveViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    //[stmvc.delegate saveCastleSetup];
    //[self dismissModalViewControllerAnimated:YES];
}

- (void) enPassantButtonPressed {
    EnPassantSquareViewController *epsvc = [[EnPassantSquareViewController alloc] init];
    [epsvc setBoardModel:_boardModel];
    [epsvc setBoardView:_boardView];
    [epsvc setCheckupPosition:_checkupPosition];
    [self.navigationController pushViewController:epsvc animated:YES];
}

@end
