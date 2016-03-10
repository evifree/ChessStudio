//
//  EnPassantSquareViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 23/08/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "EnPassantSquareViewController.h"
#import "SideToMoveViewController.h"
#import "SetupPositionTableViewController.h"
#import "SettingManager.h"

@interface EnPassantSquareViewController () {
    NSArray *caseEnPassant;
    
    CGFloat dimSquare;
    NSString *_pieceType;
    
    SettingManager *settingManager;
    
    NSUInteger selectedCasaEnPassant;
}

@end

@implementation EnPassantSquareViewController

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
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = NSLocalizedString(@"SETUP_POSITION_ENPASSANT", nil);
    if (IS_PAD) {
        CGRect boardFrame = _boardView.frame;
        boardFrame.origin.x = 30;
        boardFrame.origin.y = 48;
        _boardView.frame = boardFrame;
    }
    
    
    if (IS_PHONE) {
        [self setupClear];
        [self setupEnPassantBoard];
    }
     
    [self.view addSubview:_boardView];
    
    caseEnPassant = [_boardModel trovaCaseEnPassant];
    [_boardView segnaCaseEnPassant:caseEnPassant];
    
    if ([_boardModel getSelectedSquareEnPassant]) {
        selectedCasaEnPassant = [_boardModel getSelectedEnPassantSquare];
    }
    [_boardView setSelectedCasaEnPassant:selectedCasaEnPassant];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_boardView clearCaseEnPassant:caseEnPassant];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (!IS_PAD) {
        selectedCasaEnPassant = [_boardView getSelectedCasaEnPassant];
        [_boardView removeFromSuperview];
        _boardView = nil;
    }
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
         if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = 28.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(128, 3, 224, 224)];
            if (IS_IPHONE_5) {
                [_boardView setFrame:CGRectMake(172, 3, 224, 224)];
            }
            else if (IS_PHONE) {
                [_boardView setFrame:CGRectMake(128, 3, 224, 224)];
            }
            CGRect boardFrame = _boardView.frame;
            boardFrame.origin.y = 22;
            _boardView.frame = boardFrame;
            [self setupPositionFromBoardModel];
        }
        else {
            dimSquare = 40.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(0, 0, 320, 320)];
            //CGRect boardFrame = _boardView.frame;
            //boardFrame.origin.y = 48;
            //_boardView.frame = boardFrame;
            [self setupPositionFromBoardModel];
        }
    }
    else if (IS_IPHONE_6) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = 38.875;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(172, 3, 311, 311)];
            [self setupPositionFromBoardModel];
        }
        else {
            dimSquare = 46.875;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [_boardView setFrame:CGRectMake(0, 0, 375, 375)];
            [self setupPositionFromBoardModel];
        }
    }
    else if (IS_IPHONE_6P) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        
        }
        else {
            dimSquare = 35.0;
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [self setupPositionFromBoardModel];
        }
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            
        }
        else {
            _boardView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            _boardView.center = CGPointMake(self.view.frame.size.width/2, 340.0/2);
        }
    }
    
    if (!IS_PAD) {
        [self.view addSubview:_boardView];
        [_boardView segnaCaseEnPassant:caseEnPassant];
        [_boardView setSelectedCasaEnPassant:selectedCasaEnPassant];
    }
    

}

- (void) didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        [_boardModel resetEnPassantInPosition];
        [_boardView resetEnPassantInPosition];
    }
}

- (void) setupClear {
    [_boardView removeFromSuperview];
    _boardView = nil;
}

- (void) setupEnPassantBoard {
    if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            dimSquare = 40.0;
        }
        else {
            dimSquare = 28.0;
        }
        _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
        if (IS_PORTRAIT) {
            [_boardView setFrame:CGRectMake(0, 0, 320, 320)];
        }
        else {
            [_boardView setFrame:CGRectMake(128, 3, 240, 240)];
            _boardView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            dimSquare = 40.0;
        }
        else {
            dimSquare = 28.0;
        }
        _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
        if (IS_PORTRAIT) {
            [_boardView setFrame:CGRectMake(0, 0, 320, 320)];
        }
        else {
            [_boardView setFrame:CGRectMake(172, 3, 240, 240)];
            _boardView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            dimSquare = 46.875;
        }
        else {
            dimSquare = 38.875;
        }
        _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
        if (IS_PORTRAIT) {
            [_boardView setFrame:CGRectMake(0, 0, 375, 375)];
        }
        else {
            [_boardView setFrame:CGRectMake(172, 3, 311, 311)];
            //[_boardView setFrame:CGRectMake(172, 3, 240, 240)];
            //_boardView.center = CGPointMake(667/2, 343/2);
            _boardView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            dimSquare = 35.0;
        }
        else {
            dimSquare = 35.0;
        }
        _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
        if (IS_PORTRAIT) {
            //[_boardView setFrame:CGRectMake(0, 0, 320, 320)];
            _boardView.center = CGPointMake(self.view.frame.size.width/2, 340.0/2);
        }
        else {
            _boardView.center = CGPointMake(self.view.frame.size.width/2, 340.0/2);
            //[_boardView setFrame:CGRectMake(172, 3, 240, 240)];
            //_boardView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        }
    }
    
    [self setupPositionFromBoardModel];
}

- (void) doneButtonPressed {
    
    selectedCasaEnPassant = [_boardView getSelectedCasaEnPassant];
    
    //NSLog(@"SELECTED CASA EN PASSANT = %d", selectedCasaEnPassant);
    
    if (selectedCasaEnPassant > 0) {
        [_boardModel setPresaEnPassantPossibile:YES :selectedCasaEnPassant];
    }
    else {
        [_boardModel setPresaEnPassantPossibile:NO :0];
    }
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
    //[stmvc.delegate saveEnpassantSetup];
    //[self dismissModalViewControllerAnimated:YES];
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

@end
