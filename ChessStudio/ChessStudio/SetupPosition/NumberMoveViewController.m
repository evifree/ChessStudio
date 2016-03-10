//
//  NumberMoveViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 19/03/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "NumberMoveViewController.h"
#import "SettingManager.h"
#import "UtilToView.h"

@interface NumberMoveViewController () {
    CGFloat dimSquare;
    NSString *_pieceType;
    SettingManager *settingManager;
    
    NSInteger checkSetup;
    
    //UIView *picherView;
    UIPickerView *numberPicker;
    
    NSString *primoNumero;
    NSString *secondoNumero;
    NSString *terzoNumero;
    
    NSUInteger numeroMossa;
    
    UILabel *labelNumberFirstMove;
    UIButton *changeNumMoveButton;
    
    BoardView *localBoardView;
}

@end

@implementation NumberMoveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    settingManager = [SettingManager sharedSettingManager];
    _pieceType = [settingManager getPieceTypeToLoad];
    
    if (IS_IOS_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = UIColorFromRGB(0xffffa6);
    
    
    checkSetup = [_boardModel checkSetupPosition];
    
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
    
    
    //if (IS_PAD) {
        //CGRect boardFrame = _boardView.frame;
        //boardFrame.origin.x = 30;
        //boardFrame.origin.y = 48;
        //_boardView.frame = boardFrame;
        //[self.view addSubview:_boardView];
    //}
    
    primoNumero = @"1";
    secondoNumero = @"0";
    terzoNumero = @"0";
    numeroMossa = [primoNumero integerValue] + [secondoNumero integerValue]*10 + [terzoNumero integerValue]*100;
    
    
    //picherView = [[UIView alloc] init];   //view
    //picherView.backgroundColor = [UIColor grayColor];
    
    numberPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    numberPicker.showsSelectionIndicator = YES;
    numberPicker.delegate = self;
    //[picherView addSubview:numberPicker];
    //UIColor *color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
    [numberPicker setBackgroundColor:[UIColor clearColor]];
    numberPicker.hidden = YES;
    
    [numberPicker selectRow:1 inComponent:2 animated:NO];

    //self.view = view;
    //[self.view addSubview:numberPicker];
    

}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationItem.title = NSLocalizedString(@"SETUP_POSITION_MOVE_NUMBER", nil);
    
    if (localBoardView) {
        [localBoardView removeFromSuperview];
    }
    if (labelNumberFirstMove) {
        [labelNumberFirstMove removeFromSuperview];
    }
    if (changeNumMoveButton) {
        [changeNumMoveButton removeFromSuperview];
    }
    if (numberPicker) {
        [numberPicker removeFromSuperview];
    }
    
    
    labelNumberFirstMove = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 520.0, 210.0, 25.0)];
    labelNumberFirstMove.text = [NSLocalizedString(@"SETUP_POSITION_NUMBER_FIRST_MOVE", nil) stringByAppendingString:[NSString stringWithFormat:@": %lu", (unsigned long)numeroMossa]];
    [labelNumberFirstMove sizeToFit];
    changeNumMoveButton = [[UIButton alloc] initWithFrame:CGRectMake(240.0, 520, 200.0, 25.0)];
    [changeNumMoveButton setTitle:NSLocalizedString(@"SETUP_POSITION_CHANGE_NUMBER", nil) forState:UIControlStateNormal];
    [changeNumMoveButton addTarget:self action:@selector(changeNumMoveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [changeNumMoveButton setBackgroundColor:[UIColor clearColor]];
    [changeNumMoveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [changeNumMoveButton sizeToFit];
    
    
    if (IS_PAD) {
        dimSquare = 35.0;
        localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
        [localBoardView setFrame:CGRectMake(130, 15, 280, 280)];
        labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 35);
        changeNumMoveButton.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 60);
        numberPicker.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 180);
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            dimSquare = 25.0;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(60.0, 10.0, 200.0, 200.0)];
            
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 20);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 40);
            [numberPicker setFrame:CGRectMake(20.0, 440.0, 280.0, 162.0)];
            numberPicker.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 130);
        }
        else {
            dimSquare = 25.0;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(20.0, 20.0, 200.0, 200.0)];
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x + 225, 30.0);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x + 225, 60.0);
            [numberPicker setFrame:CGRectMake(20.0, 440.0, 240.0, 162.0)];
            numberPicker.center = CGPointMake(localBoardView.center.x + 225.0, 150);
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            dimSquare = 30.0;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(40.0, 10.0, 240.0, 240.0)];
            
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 20);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 40);
            [numberPicker setFrame:CGRectMake(20.0, 430.0, 280.0, 162.0)];
            numberPicker.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 140);
        }
        else {
            dimSquare = 25.0;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(20.0, 20.0, 200.0, 200.0)];
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x + 260, 30.0);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x + 260, 60.0);
            [numberPicker setFrame:CGRectMake(20.0, 430.0, 280.0, 162.0)];
            numberPicker.center = CGPointMake(localBoardView.center.x + 260.0, 150);
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            dimSquare = 36.875;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(40, 10, 295.0, 295.0)];
            
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 30);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 50);
            numberPicker.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 170);
        }
        else {
            dimSquare = 38.0;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(20.0, 20.0, 304.0, 304.0)];
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x + 320, 30.0);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x + 320, 60.0);
            numberPicker.center = CGPointMake(localBoardView.center.x + 320.0, 190);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            dimSquare = 35;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            localBoardView.center = CGPointMake(420.0/2, 300.0/2);
            
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 30);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 50);
            numberPicker.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 190);
        }
        else {
            
            dimSquare = 35;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            localBoardView.center = CGPointMake(420.0/2, 300.0/2);
            
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 30);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 50);
            numberPicker.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 190);
            
            //dimSquare = 35.0;
            //localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            //[localBoardView setFrame:CGRectMake(20.0, 20.0, 160.0, 160.0)];
            //labelNumberFirstMove.center = CGPointMake(localBoardView.center.x + 250, 30.0);
            //changeNumMoveButton.center = CGPointMake(localBoardView.center.x + 250, 60.0);
            //numberPicker.center = CGPointMake(localBoardView.center.x + 320.0, 190);
        }
    }
    
    
    [self setupPositionFromBoardModel];
    [self.view addSubview:localBoardView];
    [self.view addSubview:labelNumberFirstMove];
    [self.view addSubview:changeNumMoveButton];
    [self.view addSubview:numberPicker];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (!IS_PAD) {
        [localBoardView removeFromSuperview];
        [labelNumberFirstMove removeFromSuperview];
        [changeNumMoveButton removeFromSuperview];
        [numberPicker removeFromSuperview];
    }
    
    if (IS_IPHONE_4_OR_LESS) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = 25.0;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(20.0, 20.0, 200.0, 200.0)];
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x + 225, 30.0);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x + 225, 60.0);
            [numberPicker setFrame:CGRectMake(20.0, 440.0, 240.0, 162.0)];
            numberPicker.center = CGPointMake(localBoardView.center.x + 225.0, 150);
        }
        else {
            NSLog(@"Ruoto iPhone 4 to portrait");
            dimSquare = 25.0;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(60.0, 10.0, 200.0, 200.0)];
            
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 20);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 40);
            [numberPicker setFrame:CGRectMake(20.0, 440.0, 280.0, 162.0)];
            numberPicker.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 130);
        }
    }
    else if (IS_IPHONE_5) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = 25.0;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(20.0, 20.0, 200.0, 200.0)];
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x + 260, 30.0);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x + 260, 60.0);
            [numberPicker setFrame:CGRectMake(20.0, 430.0, 280.0, 162.0)];
            numberPicker.center = CGPointMake(localBoardView.center.x + 260.0, 150);
        }
        else {
            dimSquare = 30.0;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(40.0, 10.0, 240.0, 240.0)];
            
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 20);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 40);
            [numberPicker setFrame:CGRectMake(20.0, 430.0, 280.0, 162.0)];
            numberPicker.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 140);
        }
    }
    else if (IS_IPHONE_6) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = 38.0;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(20.0, 20.0, 304.0, 304.0)];
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x + 320, 30.0);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x + 320, 60.0);
            numberPicker.center = CGPointMake(localBoardView.center.x + 320.0, 190);
        }
        else {
            dimSquare = 36.875;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(40, 10, 295.0, 295.0)];
            
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 30);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 50);
            numberPicker.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 170);
        }
    }
    else if (IS_IPHONE_6P) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = 20.0;
            localBoardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            [localBoardView setFrame:CGRectMake(20.0, 20.0, 160.0, 160.0)];
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x + 320, 30.0);
            changeNumMoveButton.center = CGPointMake(localBoardView.center.x + 320, 60.0);
            numberPicker.center = CGPointMake(localBoardView.center.x + 320.0, 190);
        }
    }
    
    [self setupPositionFromBoardModel];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.view addSubview:localBoardView];
    [self.view addSubview:labelNumberFirstMove];
    [self.view addSubview:changeNumMoveButton];
    [self.view addSubview:numberPicker];
}

- (void) doneButtonPressed {
    if (IS_PHONE) {
        self.navigationItem.title = NSLocalizedString(@"BACK", nil);
    }
    
    if (numberPicker.hidden == NO) {
        numberPicker.hidden = YES;
    }
    [changeNumMoveButton removeFromSuperview];
    [labelNumberFirstMove removeFromSuperview];
    
    [_boardModel setNumberFirstMoveInSetupPosition:numeroMossa];
    
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
     }
}

- (void) changeNumMoveButtonPressed {
    if ([changeNumMoveButton.titleLabel.text hasPrefix:NSLocalizedString(@"SETUP_POSITION_CHANGE_NUMBER", nil)]) {
        
        if (IS_IPHONE_6P) {
            if (IS_PORTRAIT) {
                [numberPicker setBackgroundColor:[UIColor clearColor]];
                numberPicker.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 190);
            }
            else {
                numberPicker.center = localBoardView.center;
                UIColor *color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
                [numberPicker setBackgroundColor:color];
            }
        }
        
        numberPicker.hidden = NO;
        [changeNumMoveButton setTitle:NSLocalizedString(@"SETUP_POSITION_CLOSE", nil) forState:UIControlStateNormal];
    }
    else if ([changeNumMoveButton.titleLabel.text hasPrefix:NSLocalizedString(@"SETUP_POSITION_CLOSE", nil)]) {
        numberPicker.hidden = YES;
        if (IS_IPHONE_6P && IS_LANDSCAPE) {
            [numberPicker setBackgroundColor:[UIColor clearColor]];
        }
        [changeNumMoveButton setTitle:NSLocalizedString(@"SETUP_POSITION_CHANGE_NUMBER", nil) forState:UIControlStateNormal];
    }
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!numberPicker.hidden) {
        numberPicker.hidden = YES;
        [changeNumMoveButton setTitle:NSLocalizedString(@"SETUP_POSITION_CHANGE_NUMBER", nil) forState:UIControlStateNormal];
    }
}

#pragma mark - Metodi PickerView delegate

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 2) {
        return[[UtilToView getEcoNumberArray] objectAtIndex:row];
    }
    return [[UtilToView getEcoNumberArray] objectAtIndex:row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 2) {
        primoNumero = [[UtilToView getEcoNumberArray] objectAtIndex:row];
    }
    else if (component == 1) {
        secondoNumero = [[UtilToView getEcoNumberArray] objectAtIndex:row];
    }
    else {
        terzoNumero = [[UtilToView getEcoNumberArray] objectAtIndex:row];
    }
    
    //NSLog(@"%@", [[terzoNumero stringByAppendingString:secondoNumero] stringByAppendingString:primoNumero]);
    
    numeroMossa = [primoNumero integerValue] + [secondoNumero integerValue]*10 + [terzoNumero integerValue]*100;
    
    if (numeroMossa == 0) {
        [pickerView selectRow:1 inComponent:2 animated:NO];
        [pickerView reloadComponent:2];
        numeroMossa = 1;
    }
    
    labelNumberFirstMove.text = [NSLocalizedString(@"SETUP_POSITION_NUMBER_FIRST_MOVE", nil) stringByAppendingString:[NSString stringWithFormat:@": %lu", (unsigned long)numeroMossa]];
    [labelNumberFirstMove sizeToFit];
    
    
    
    
    if (IS_PAD) {
        labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 35);
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 20);
        }
        else {
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x + 225, 30.0);
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 20);
        }
        else {
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x + 260, 30.0);
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 30);
        }
        else {
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x + 320, 30.0);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 30);
        }
        else {
            labelNumberFirstMove.center = CGPointMake(localBoardView.center.x, localBoardView.frame.size.height + 30);
        }
    }
    
    //NSLog(@"Numero mossa = %lu", (unsigned long)numeroMossa);
    
    [_boardModel setNumberFirstMoveInSetupPosition:numeroMossa];
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
            [localBoardView addSubview:pb];
        }
        else {
            PieceButton *pb = [localBoardView findPieceBySquareTag:i];
            if (pb) {
                [pb removeFromSuperview];
            }
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
