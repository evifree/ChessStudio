//
//  SideToMoveViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 23/08/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "SideToMoveViewController.h"
#import "SetupPositionTableViewController.h"
#import "SettingManager.h"
#import "NumberMoveViewController.h"

@interface SideToMoveViewController () {

    NSString *_squares;
    NSString *_pieceType;
    CGFloat dimSquare;
    
    BoardView *_boardView;
    
    UISegmentedControl *segmentedControl;
    
    NSInteger checkSetup;
    
    SettingManager *settingManager;

}

@end

@implementation SideToMoveViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithSquaresAndPieceType:(NSString *)squares :(NSString *)pieceType {
    self = [super init];
    if (self) {
        
        settingManager = [SettingManager sharedSettingManager];
        
        _squares = [settingManager squares];
        _pieceType = [settingManager getPieceTypeToLoad];
        if (IS_PAD) {
            dimSquare = 60.0;
        }
        else if (IS_IPHONE_4_OR_LESS) {
            if (IS_PORTRAIT) {
                dimSquare = 40.0;
            }
            else {
                dimSquare = 28.0;
            }
        }
        else if (IS_IPHONE_5) {
            if (IS_PORTRAIT) {
                dimSquare = 40.0;
            }
            else {
                dimSquare = 28.0;
            }
        }
        else if (IS_IPHONE_6) {
            if (IS_PORTRAIT) {
                dimSquare = 46.875;
            }
            else {
                dimSquare = 38.875;
            }
        }
        else if (IS_IPHONE_6P) {
            if (IS_PORTRAIT) {
                dimSquare = 51.75;
            }
            else {
                dimSquare = 35.0;
            }
        }
        
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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SETUP_POSITION_MOVE_NUMBER", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    

    checkSetup = [_boardModel checkSetupPosition];
    
    if (checkSetup == 5) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    }

    /*
    if (checkSetup == 3 || checkSetup == 4) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    }
    else if ([_boardModel almenoUnArroccoPossibile]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SETUP_POSITION_CASTLING", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    }
    else if ([_boardModel esisteAlmenoUnaPresaEnPassant]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"En Passant" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    }
    */
    
    self.view.backgroundColor = UIColorFromRGB(0xffffa6);
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationItem.title = NSLocalizedString(@"SETUP_POSITION_SIDE_TO_MOVE", nil);

    
    //_boardView = [[BoardView alloc] initWithSquareSizeAndSquareType:dimSquare :_squares];
    
    if (_boardView) {
        [_boardView removeFromSuperview];
        _boardView = nil;
    }
    if (segmentedControl) {
        [segmentedControl removeFromSuperview];
        segmentedControl = nil;
    }
    
    if (IS_PAD) {
        dimSquare = 60.0;
        _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
        [_boardView setFrame:CGRectMake(30, 30, 480, 480)];
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            dimSquare = 40.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(0, 0, 320, 320)];
        }
        else {
            dimSquare = 28.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(128, 3, 224, 224)];
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            dimSquare = 40.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(0, 0, 320, 320)];
        }
        else {
            dimSquare = 28.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(172, 3, 224, 224)];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            dimSquare = 46.875;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(0, 0, 375, 375)];
        }
        else {
            dimSquare = 35.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(172.0, 3, 280.0, 280.0)];
            _boardView.center = CGPointMake(667/2, 300/2);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            //dimSquare = 51.75;
            //_boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            //[_boardView setFrame:CGRectMake(0, 0, 414, 414)];
            dimSquare = 35;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            _boardView.center = CGPointMake(420.0/2, 300.0/2);
        }
        else {
            dimSquare = 35;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            _boardView.center = CGPointMake(420.0/2, 300.0/2);
        }
    }

    
    [self setupPositionFromBoardModel];
    
    [self.view addSubview:_boardView];
    [self setupSideToMoveControl];
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
        [_boardView removeFromSuperview];
        _boardView = nil;
        [segmentedControl removeFromSuperview];
        segmentedControl = nil;
    }
    
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = 28.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            if (IS_IPHONE_4_OR_LESS) {
                [_boardView setFrame:CGRectMake(128, 3, 224, 224)];
            }
            else if (IS_IPHONE_5) {
                [_boardView setFrame:CGRectMake(172, 3, 224, 224)];
            }
            [self setupPositionFromBoardModel];
        }
        else if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
            dimSquare = 40.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(0, 0, 320, 320)];
            [self setupPositionFromBoardModel];
        }
    }
    else if (IS_IPHONE_6) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            //dimSquare = 38.875;
            dimSquare = 35.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(172.0, 3, 280.0, 280.0)];
            _boardView.center = CGPointMake(667/2, 300/2);
            [self setupPositionFromBoardModel];
        }
        else if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
            dimSquare = 46.875;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(0, 0, 375, 375)];
            [self setupPositionFromBoardModel];
        }
    }
    else if (IS_IPHONE_6P) {
        if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
            dimSquare = 35.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            //[_boardView setFrame:CGRectMake(0, 0, 414, 414)];
            _boardView.center = CGPointMake(420.0/2, 300.0/2);
            [self setupPositionFromBoardModel];
        }
        else /*if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight))*/ {
            dimSquare = 35;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            _boardView.center = CGPointMake(420.0/2, 300.0/2);
            [self setupPositionFromBoardModel];
        }
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
        [self.view addSubview:_boardView];
        [self setupSideToMoveControl];
    //}
}


- (void) cancelButtonPressed {
    [_boardModel setWhiteHasToMove:YES];
    [_delegate aggiornaColore];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) doneButtonPressed {
    if (IS_PHONE) {
        self.navigationItem.title = NSLocalizedString(@"BACK", nil);
    }
    
    if (checkSetup == 5) {
        [_boardModel setNumberFirstMoveInSetupPosition:1];
        SetupPositionTableViewController *sptvc = [[SetupPositionTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [sptvc setBoardModel:_boardModel];
        [sptvc setBoardView:_boardView];
        [sptvc setCheckupPosition:checkSetup];
        [self.navigationController pushViewController:sptvc animated:YES];
        return;
    }
    
    NumberMoveViewController *nmvc = [[NumberMoveViewController alloc] init];
    [nmvc setBoardModel:_boardModel];
    [nmvc setBoardView:_boardView];
    [self.navigationController pushViewController:nmvc animated:YES];
    
    /*
    if ([_boardModel almenoUnArroccoPossibile]) {
        CastleSetupViewController *csvc = [[CastleSetupViewController alloc] init];
        [csvc setBoardModel:_boardModel];
        [csvc setBoardView:_boardView];
        [csvc setCheckupPosition:checkSetup];
        [self.navigationController pushViewController:csvc animated:YES];
    }
    else if ([_boardModel esisteAlmenoUnaPresaEnPassant]) {
        EnPassantSquareViewController *epsvc = [[EnPassantSquareViewController alloc] init];
        [epsvc setBoardModel:_boardModel];
        [epsvc setBoardView:_boardView];
        [epsvc setCheckupPosition:checkSetup];
        [self.navigationController pushViewController:epsvc animated:YES];
    }
    else {
        SetupPositionTableViewController *sptvc = [[SetupPositionTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [sptvc setBoardModel:_boardModel];
        [sptvc setBoardView:_boardView];
        [sptvc setCheckupPosition:checkSetup];
        [self.navigationController pushViewController:sptvc animated:YES];
        //return;
        //[self.delegate savePositionSetup];
        //[self dismissModalViewControllerAnimated:YES];
    }*/
    
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

- (void) setupSideToMoveControl {
    NSArray *buttonNames = [NSArray arrayWithObjects: NSLocalizedString(@"SETUP_POSITION_WHITE_MOVE", nil), NSLocalizedString(@"SETUP_POSITION_BLACK_MOVE", nil), nil];
    segmentedControl = [[UISegmentedControl alloc] initWithItems: buttonNames];
    
    if (IS_PAD) {
        [segmentedControl setFrame: CGRectMake(110.0f, 518.0f, 320.0f, 50.0f)];
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            [segmentedControl setFrame: CGRectMake(10.0f, 343.0f, 300.0f, 50.0f)];
        }
        else {
            [segmentedControl setFrame: CGRectMake(108.0f, 232.0f, 264.0f, 30.0f)];
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            [segmentedControl setFrame: CGRectMake(10.0f, 343.0f, 300.0f, 50.0f)];
        }
        else {
            [segmentedControl setFrame: CGRectMake(152.0f, 232.0f, 264.0f, 30.0f)];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            [segmentedControl setFrame: CGRectMake(40.0f, 398.0f, 300.0f, 50.0f)];
        }
        else {
            [segmentedControl setFrame: CGRectMake(200.0f, 300.0f, 264.0f, 30.0f)];
            segmentedControl.center = CGPointMake(667/2, segmentedControl.center.y);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            //[segmentedControl setFrame: CGRectMake(40.0f, 440.0f, 334.0f, 50.0f)];
            [segmentedControl setFrame: CGRectMake(200.0f, 300.0f, 264.0f, 30.0f)];
            segmentedControl.center = CGPointMake(420/2, segmentedControl.center.y);
        }
        else {
            [segmentedControl setFrame: CGRectMake(200.0f, 300.0f, 264.0f, 30.0f)];
            segmentedControl.center = CGPointMake(420/2, segmentedControl.center.y);
        }
    }

    
    [segmentedControl addTarget:self action:@selector(segmentedControlPressed:) forControlEvents:UIControlEventValueChanged];
    
    if (checkSetup == 1) {
        [segmentedControl setSelectedSegmentIndex: 0];
        [segmentedControl setEnabled: NO forSegmentAtIndex: 1];
    }
    else if (checkSetup == 2) {
        [segmentedControl setSelectedSegmentIndex: 1];
        [segmentedControl setEnabled: NO forSegmentAtIndex: 0];
    }
    else if (checkSetup == 3) {
        [segmentedControl setSelectedSegmentIndex: 0];
        [segmentedControl setEnabled: NO forSegmentAtIndex: 1];
    }
    else if (checkSetup == 4) {
        [segmentedControl setSelectedSegmentIndex: 1];
        [segmentedControl setEnabled: NO forSegmentAtIndex: 0];
    }
    else if (checkSetup == 5) {
        [segmentedControl setSelectedSegmentIndex: 0];
        [segmentedControl setEnabled: NO forSegmentAtIndex: 1];
    }
    else if ([_boardModel whiteHasToMove]) {
        [segmentedControl setSelectedSegmentIndex:0];
    }
    else {
        [segmentedControl setSelectedSegmentIndex:1];
    }
    //[segmentedControl setSegmentedControlStyle: UISegmentedControlStylePlain];
    [self.view addSubview:segmentedControl];
}

- (void) segmentedControlPressed:(UISegmentedControl *)segControl {
    if ([segControl selectedSegmentIndex] == 0) {
        [_boardModel setWhiteHasToMove:YES];
    }
    else if ([segControl selectedSegmentIndex] == 1) {
        [_boardModel setWhiteHasToMove:NO];
    }
    [_delegate aggiornaColore];
    
    /*
    if ([_boardModel esisteAlmenoUnaPresaEnPassant] && ![_boardModel almenoUnArroccoPossibile]) {
        [self.navigationItem.rightBarButtonItem setTitle:@"En Passant"];
    }
    else if ([_boardModel almenoUnArroccoPossibile]) {
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"SETUP_POSITION_CASTLING", nil)];
    }
    else {
        //[self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"MENU_SAVE", nil)];
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"DONE", nil)];
    }*/
}

@end
