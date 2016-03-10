//
//  TextCommentViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 10/10/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "TextCommentViewController.h"

@interface TextCommentViewController () {
    BoardView *bv;
    CGFloat squareSize;
    
    UITextView *textView;
    
    
    CGFloat larghezzaSchermo;
    //CGFloat altezzaSchermo;
    NSString *tempText;
    
    UILabel *labelText;
    UILabel *labelBoard;
    
    //SettingManager *settingNamager;
}

@end

@implementation TextCommentViewController

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
    
    //[self.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    [self.view setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.6]];
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveMenuButtonPressed:)];
    
    
    [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doneMenuButtonPressed:)]];
    [[self navigationItem] setRightBarButtonItem:saveBarButtonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (IS_PAD_PRO) {
        if (IS_PORTRAIT) {
            larghezzaSchermo = 1024;
            [self gestisciPadPortrait];
        }
        else {
            larghezzaSchermo = 1366;
            [self gestisciPadLandscape];
        }
    }
    else if (IS_PAD) {
        if (IS_PORTRAIT) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            larghezzaSchermo = 768.0;
            //altezzaSchermo = 1024.0;
            [self gestisciPadPortrait];
        }
        else {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            larghezzaSchermo = 1024.0;
            //altezzaSchermo = 768.0;
            [self gestisciPadLandscape];
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            larghezzaSchermo = 320.0;
            //altezzaSchermo = 480.0;
            [self gestisciPhone4Portrait];
        }
        else {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            larghezzaSchermo = 480.0;
            //altezzaSchermo = 320.0;
            [self gestisciPhone4Landscape];
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            larghezzaSchermo = 320.0;
            //altezzaSchermo = 568.0;
            [self gestisciPhone5Portrait];
        }
        else {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            larghezzaSchermo = 568.0;
            //altezzaSchermo = 320.0;
            [self gestisciPhone5Landscape];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            larghezzaSchermo = 375.0;
            //altezzaSchermo = 667.0;
            [self gestisciPhone6Portrait];
        }
        else {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            larghezzaSchermo = 667.0;
            //altezzaSchermo = 375.0;
            [self gestisciPhone6Landscape];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            larghezzaSchermo = 414.0;
            //altezzaSchermo = 736.0;
            [self gestisciPhone6PPortrait];
        }
        else {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            larghezzaSchermo = 736.0;
            //altezzaSchermo = 414.0;
            [self gestisciPhone6PLandscape];
        }
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - Metodi gestione rotazione iPad

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (IS_PAD_PRO) {
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            larghezzaSchermo = 1366.0;
            //altezzaSchermo = 768.0;
            [self gestisciPadLandscape];
        }
        else if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            larghezzaSchermo = 1024.0;
            //altezzaSchermo = 1024.0;
            [self gestisciPadPortrait];
        }
    }
    else if (IS_PAD) {
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            larghezzaSchermo = 1024.0;
            //altezzaSchermo = 768.0;
            [self gestisciPadLandscape];
        }
        else if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            larghezzaSchermo = 768.0;
            //altezzaSchermo = 1024.0;
            [self gestisciPadPortrait];
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            larghezzaSchermo = 320.0;
            //altezzaSchermo = 480.0;
            [self gestisciPhone4Portrait];
        }
        else {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            larghezzaSchermo = 480.0;
            //altezzaSchermo = 320.0;
            [self gestisciPhone4Landscape];
        }
    }
    else if (IS_IPHONE_5) {
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            larghezzaSchermo = 320.0;
            //altezzaSchermo = 568.0;
            [self gestisciPhone5Portrait];
        }
        else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            larghezzaSchermo = 568.0;
            //altezzaSchermo = 320.0;
            [self gestisciPhone5Landscape];
        }
    }
    else if (IS_IPHONE_6) {
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            larghezzaSchermo = 375.0;
            //altezzaSchermo = 667.0;
            [self gestisciPhone6Portrait];
        }
        else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            larghezzaSchermo = 667.0;
            //altezzaSchermo = 375.0;
            [self gestisciPhone6Landscape];
        }
    }
    else if (IS_IPHONE_6P) {
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            larghezzaSchermo = 414.0;
            //altezzaSchermo = 736.0;
            [self gestisciPhone6PPortrait];
        }
        else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation==UIInterfaceOrientationLandscapeRight) {
            //larghezzaSchermo = [UIScreen mainScreen].bounds.size.height;
            //altezzaSchermo = [UIScreen mainScreen].bounds.size.width;
            larghezzaSchermo = 736.0;
            //altezzaSchermo = 414.0;
            [self gestisciPhone6PLandscape];
        }
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //[_delegate aggiornaOrientamento];
}

- (void) gestisciPadLandscape {
    
    //NSLog(@"Larghezza schermo = %f", larghezzaSchermo);
    //NSLog(@"Altezza schermo = %f", altezzaSchermo);
    
    tempText = textView.text;
    [bv removeFromSuperview];
    [textView removeFromSuperview];
    bv = nil;
    textView = nil;
    squareSize = 40.0;
    bv = [[BoardView alloc] initWithSquareSizeAndBoardModel:squareSize :_boardModel];
    CGRect boardFrame = bv.frame;
    boardFrame.origin.y = 24.0;
    boardFrame.origin.x = 50.0;
    bv.frame = boardFrame;
    [self.view addSubview:bv];
    
    CGRect textFrame;
    CGFloat fontSize;
    fontSize = 15;
    CGFloat larghezzaTextView = larghezzaSchermo - (50.0 + squareSize*8 + 50.0 + 50.0);
    textFrame = CGRectMake(50.0 + squareSize*8 + 50, 24.0, larghezzaTextView, squareSize*8);
    textView = [[UITextView alloc] initWithFrame:textFrame];
    textView.font = [UIFont fontWithName:@"Courier" size:fontSize];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.textColor = [UIColor blueColor];
    textView.backgroundColor = UIColorFromRGB(0xFFFFA6);
    [self.view addSubview:textView];
    //textView.text = tempText;
    
    [labelBoard removeFromSuperview];
    labelBoard = nil;
    
    labelBoard = [[UILabel alloc] initWithFrame:CGRectMake((squareSize*8 + 50.0 + 50.0)/2, 14, squareSize*8, 20.0)];
    labelBoard.font = [UIFont fontWithName:@"Courier-Bold" size:18];
    
    labelBoard.textColor = UIColorFromRGB(0xFFFFA6);
    labelBoard.backgroundColor = [UIColor clearColor];
    labelBoard.adjustsFontSizeToFitWidth = YES;
    labelBoard.textAlignment = NSTextAlignmentCenter;
    labelBoard.center = CGPointMake((squareSize*8 + 50.0 + 50.0)/2, 14);
    [self.view addSubview:labelBoard];
    
    [labelText removeFromSuperview];
    labelText = nil;
    
    labelText = [[UILabel alloc] initWithFrame:CGRectMake((larghezzaSchermo - squareSize*8 - 50.0 - 50.0)/2, 14, squareSize*8, 20.0)];
    labelText.font = [UIFont fontWithName:@"Courier-Bold" size:18];
    labelText.textColor = [UIColor blueColor];
    labelText.backgroundColor = [UIColor clearColor];
    labelText.adjustsFontSizeToFitWidth = YES;
    labelText.textAlignment = NSTextAlignmentCenter;
    //labelText.center = CGPointMake((larghezzaSchermo - squareSize*8 - 50.0 - 50.0 + larghezzaTextView + 200.0)/2, 14);
    labelText.center = CGPointMake(textView.center.x, 14.0);
    [self.view addSubview:labelText];
    
    
    if ([_pgnMove isRootMove] || _textBefore) {
        if ([_pgnMove isRootMove] && !_textBefore && ! _pgnMove.textAfter) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
        else if ([_pgnMove isRootMove] && !_textBefore && _pgnMove.textAfter) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && _pgnMove.textBefore) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && !_pgnMove.textBefore) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
    }
    else {
        labelBoard.text = [NSLocalizedString(@"POSITION_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        self.navigationItem.title = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        labelText.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
    }
    
    if (tempText) {
        textView.text = tempText;
    }
    else {
        if (_textBefore) {
            textView.text = [[_pgnMove textBefore] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            textView.text = [[_pgnMove textAfter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
}

- (void) gestisciPadPortrait {
    //NSLog(@"Larghezza schermo = %f", larghezzaSchermo);
    //NSLog(@"Altezza schermo = %f", altezzaSchermo);
    CGRect textFrame;
    CGFloat fontSize;
    if (IS_PAD) {
        tempText = textView.text;
        [bv removeFromSuperview];
        [textView removeFromSuperview];
        bv = nil;
        textView = nil;
        squareSize = 62.5;
        bv = [[BoardView alloc] initWithSquareSizeAndBoardModel:squareSize :_boardModel];
        //bv = [[BoardView alloc] initWithSquareSizeAndBoardModel:[settingNamager getSquareSize]:_boardModel];
        CGRect boardFrame = bv.frame;
        boardFrame.origin.y = 30.0;
        boardFrame.origin.x = (larghezzaSchermo - squareSize*8)/2;
        bv.frame = boardFrame;
        [self.view addSubview:bv];
        
        if (IS_PAD_PRO) {
            textFrame = CGRectMake((larghezzaSchermo - squareSize*8)/2, squareSize*8+20+40, squareSize*8, 300.0);
        }
        else {
            textFrame = CGRectMake((larghezzaSchermo - squareSize*8)/2, squareSize*8+20+40, squareSize*8, 100.0);
        }
        
        
        fontSize = 15;
        textView = [[UITextView alloc] initWithFrame:textFrame];
        textView.font = [UIFont fontWithName:@"Courier" size:fontSize];
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView.textColor = [UIColor blueColor];
        textView.backgroundColor = UIColorFromRGB(0xFFFFA6);
        [self.view addSubview:textView];
        
        
        
        [labelBoard removeFromSuperview];
        labelBoard = nil;
        
        labelBoard = [[UILabel alloc] initWithFrame:CGRectMake((larghezzaSchermo - squareSize*8)/2, 10, squareSize*8, 20.0)];
        labelBoard.font = [UIFont fontWithName:@"Courier-Bold" size:20];
        
        labelBoard.textColor = UIColorFromRGB(0xFFFFA6);
        labelBoard.backgroundColor = [UIColor clearColor];
        labelBoard.adjustsFontSizeToFitWidth = YES;
        labelBoard.textAlignment = NSTextAlignmentCenter;
        labelBoard.center = CGPointMake(larghezzaSchermo/2, 15);
        [self.view addSubview:labelBoard];
        
        [labelText removeFromSuperview];
        labelText = nil;
        labelText = [[UILabel alloc] initWithFrame:CGRectMake((larghezzaSchermo - squareSize*8)/2, squareSize*8+30, squareSize*8, 20.0)];
        labelText.font = [UIFont fontWithName:@"Courier-Bold" size:20];
        labelText.textColor = [UIColor blueColor];
        labelText.backgroundColor = [UIColor clearColor];
        labelText.adjustsFontSizeToFitWidth = YES;
        labelText.textAlignment = NSTextAlignmentCenter;
        labelText.center = CGPointMake(larghezzaSchermo/2, squareSize*8+45);
        [self.view addSubview:labelText];
    }
    else {
        squareSize = 30.0;
        textFrame = CGRectMake((larghezzaSchermo - squareSize*8)/2, 25, squareSize*8, 100.0);
        fontSize = 12;
        textView = [[UITextView alloc] initWithFrame:textFrame];
        textView.font = [UIFont fontWithName:@"Courier" size:fontSize];
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView.textColor = [UIColor blueColor];
        textView.backgroundColor = UIColorFromRGB(0xFFFFA6);
        [self.view addSubview:textView];

        
        labelText = [[UILabel alloc] initWithFrame:CGRectMake((larghezzaSchermo - squareSize*8)/2, 20, squareSize*8, 20.0)];
        labelText.font = [UIFont fontWithName:@"Courier-Bold" size:20];
        labelText.textColor = [UIColor blueColor];
        labelText.backgroundColor = [UIColor clearColor];
        labelText.adjustsFontSizeToFitWidth = YES;
        labelText.textAlignment = NSTextAlignmentCenter;
        labelText.center = CGPointMake(larghezzaSchermo/2, 15.0);
        [self.view addSubview:labelText];
    }
    
    
    if ([_pgnMove isRootMove] || _textBefore) {
        if ([_pgnMove isRootMove] && !_textBefore && ! _pgnMove.textAfter) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
        else if ([_pgnMove isRootMove] && !_textBefore && _pgnMove.textAfter) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && _pgnMove.textBefore) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && !_pgnMove.textBefore) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
    }
    else {
        labelBoard.text = [NSLocalizedString(@"POSITION_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        self.navigationItem.title = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        labelText.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
    }
    
    if (tempText) {
        textView.text = tempText;
    }
    else {
        if (_textBefore) {
            textView.text = [[_pgnMove textBefore] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            textView.text = [[_pgnMove textAfter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
}

- (void) gestisciPhone5Portrait {
    CGRect textFrame;
    CGFloat fontSize;
    squareSize = 18.0;
    
    tempText = textView.text;
    [bv removeFromSuperview];
    [textView removeFromSuperview];
    bv = nil;
    textView = nil;
    bv = [[BoardView alloc] initWithSquareSizeAndBoardModel:squareSize :_boardModel];
    CGRect boardFrame = bv.frame;
    boardFrame.origin.y = 130.0;
    boardFrame.origin.x = (larghezzaSchermo - squareSize*8)/2;
    bv.frame = boardFrame;
    [self.view addSubview:bv];
    
    squareSize = 30.0;
    textFrame = CGRectMake((larghezzaSchermo - squareSize*8)/2, 10, squareSize*8, 115.0);
    fontSize = 12;
    textView = [[UITextView alloc] initWithFrame:textFrame];
    textView.font = [UIFont fontWithName:@"Courier" size:fontSize];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.textColor = [UIColor blueColor];
    textView.backgroundColor = UIColorFromRGB(0xFFFFA6);
    [self.view addSubview:textView];
    
    if ([_pgnMove isRootMove] || _textBefore) {
        if ([_pgnMove isRootMove] && !_textBefore && ! _pgnMove.textAfter) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
        else if ([_pgnMove isRootMove] && !_textBefore && _pgnMove.textAfter) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && _pgnMove.textBefore) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && !_pgnMove.textBefore) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
    }
    else {
        labelBoard.text = [NSLocalizedString(@"POSITION_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        self.navigationItem.title = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        labelText.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
    }
    
    if (tempText) {
        textView.text = tempText;
    }
    else {
        if (_textBefore) {
            textView.text = [[_pgnMove textBefore] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            textView.text = [[_pgnMove textAfter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
}

- (void) gestisciPhone5Landscape {
    CGRect textFrame;
    CGFloat fontSize;
    CGFloat altezza;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        squareSize = 15.0;
        altezza = 120.0;
    }
    else {
        squareSize = 12.0;
        altezza = 96.0;
    }
    
    tempText = textView.text;
    [bv removeFromSuperview];
    [textView removeFromSuperview];
    bv = nil;
    textView = nil;
    bv = [[BoardView alloc] initWithSquareSizeAndBoardModel:squareSize :_boardModel];
    CGRect boardFrame = bv.frame;
    boardFrame.origin.y = 3.0;
    //boardFrame.origin.x = ([UIScreen mainScreen].bounds.size.width - squareSize*8)/2;
    boardFrame.origin.x = 50;
    bv.frame = boardFrame;
    [self.view addSubview:bv];
    
    
    squareSize = 30.0;
    textFrame = CGRectMake((larghezzaSchermo - squareSize*8)/2 + 20, 3.0, squareSize*8 + 100, altezza);
    fontSize = 12;
    textView = [[UITextView alloc] initWithFrame:textFrame];
    textView.font = [UIFont fontWithName:@"Courier" size:fontSize];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.textColor = [UIColor blueColor];
    textView.backgroundColor = UIColorFromRGB(0xFFFFA6);
    [self.view addSubview:textView];
    
    if ([_pgnMove isRootMove] || _textBefore) {
        if ([_pgnMove isRootMove] && !_textBefore && ! _pgnMove.textAfter) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
        else if ([_pgnMove isRootMove] && !_textBefore && _pgnMove.textAfter) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && _pgnMove.textBefore) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && !_pgnMove.textBefore) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
    }
    else {
        labelBoard.text = [NSLocalizedString(@"POSITION_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        self.navigationItem.title = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        labelText.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
    }
    
    if (tempText) {
        textView.text = tempText;
    }
    else {
        if (_textBefore) {
            textView.text = [[_pgnMove textBefore] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            textView.text = [[_pgnMove textAfter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
}

- (void) gestisciPhone4Portrait {
    CGRect textFrame;
    CGFloat fontSize;
    squareSize = 15.0;
    
    tempText = textView.text;
    [bv removeFromSuperview];
    [textView removeFromSuperview];
    bv = nil;
    textView = nil;
    bv = [[BoardView alloc] initWithSquareSizeAndBoardModel:squareSize :_boardModel];
    CGRect boardFrame = bv.frame;
    boardFrame.origin.y = 70.0;
    boardFrame.origin.x = (larghezzaSchermo - squareSize*8)/2;
    bv.frame = boardFrame;
    [self.view addSubview:bv];
    
    squareSize = 30.0;
    textFrame = CGRectMake((larghezzaSchermo - squareSize*8)/2, 5, squareSize*8, 60.0);
    fontSize = 12;
    textView = [[UITextView alloc] initWithFrame:textFrame];
    textView.font = [UIFont fontWithName:@"Courier" size:fontSize];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.textColor = [UIColor blueColor];
    textView.backgroundColor = UIColorFromRGB(0xFFFFA6);
    [self.view addSubview:textView];
    
    if ([_pgnMove isRootMove] || _textBefore) {
        if ([_pgnMove isRootMove] && !_textBefore && ! _pgnMove.textAfter) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
        else if ([_pgnMove isRootMove] && !_textBefore && _pgnMove.textAfter) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && _pgnMove.textBefore) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && !_pgnMove.textBefore) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
    }
    else {
        labelBoard.text = [NSLocalizedString(@"POSITION_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        self.navigationItem.title = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        labelText.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
    }
    
    if (tempText) {
        textView.text = tempText;
    }
    else {
        if (_textBefore) {
            textView.text = [[_pgnMove textBefore] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            textView.text = [[_pgnMove textAfter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
}

- (void) gestisciPhone4Landscape {
    CGRect textFrame;
    CGFloat fontSize;
    squareSize = 12.0;
    
    tempText = textView.text;
    [bv removeFromSuperview];
    [textView removeFromSuperview];
    bv = nil;
    textView = nil;
    bv = [[BoardView alloc] initWithSquareSizeAndBoardModel:squareSize :_boardModel];
    CGRect boardFrame = bv.frame;
    boardFrame.origin.y = 5.0;
    //boardFrame.origin.x = ([UIScreen mainScreen].bounds.size.width - squareSize*8)/2;
    boardFrame.origin.x = 50;
    bv.frame = boardFrame;
    [self.view addSubview:bv];
    
    
    squareSize = 30.0;
    textFrame = CGRectMake((larghezzaSchermo - squareSize*8)/2 + 40, 5, squareSize*8 + 50, 96.0);
    fontSize = 12;
    textView = [[UITextView alloc] initWithFrame:textFrame];
    textView.font = [UIFont fontWithName:@"Courier" size:fontSize];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.textColor = [UIColor blueColor];
    textView.backgroundColor = UIColorFromRGB(0xFFFFA6);
    [self.view addSubview:textView];
    
    if ([_pgnMove isRootMove] || _textBefore) {
        if ([_pgnMove isRootMove] && !_textBefore && ! _pgnMove.textAfter) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
        else if ([_pgnMove isRootMove] && !_textBefore && _pgnMove.textAfter) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && _pgnMove.textBefore) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && !_pgnMove.textBefore) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
    }
    else {
        labelBoard.text = [NSLocalizedString(@"POSITION_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        self.navigationItem.title = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        labelText.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
    }
    
    if (tempText) {
        textView.text = tempText;
    }
    else {
        if (_textBefore) {
            textView.text = [[_pgnMove textBefore] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            textView.text = [[_pgnMove textAfter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
}



- (void) gestisciPhone6Portrait {
    CGRect textFrame;
    CGFloat fontSize;
    squareSize = 25.0;
    
    tempText = textView.text;
    [bv removeFromSuperview];
    [textView removeFromSuperview];
    bv = nil;
    textView = nil;
    bv = [[BoardView alloc] initWithSquareSizeAndBoardModel:squareSize :_boardModel];
    CGRect boardFrame = bv.frame;
    boardFrame.origin.y = 140.0;
    boardFrame.origin.x = (larghezzaSchermo - squareSize*8)/2;
    bv.frame = boardFrame;
    [self.view addSubview:bv];
    
    squareSize = 40.0;
    textFrame = CGRectMake((larghezzaSchermo - squareSize*8)/2, 15, squareSize*8, 120.0);
    fontSize = 12;
    textView = [[UITextView alloc] initWithFrame:textFrame];
    textView.font = [UIFont fontWithName:@"Courier" size:fontSize];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.textColor = [UIColor blueColor];
    textView.backgroundColor = UIColorFromRGB(0xFFFFA6);
    [self.view addSubview:textView];
    
    if ([_pgnMove isRootMove] || _textBefore) {
        if ([_pgnMove isRootMove] && !_textBefore && ! _pgnMove.textAfter) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
        else if ([_pgnMove isRootMove] && !_textBefore && _pgnMove.textAfter) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && _pgnMove.textBefore) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && !_pgnMove.textBefore) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
    }
    else {
        labelBoard.text = [NSLocalizedString(@"POSITION_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        self.navigationItem.title = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        labelText.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
    }
    
    if (tempText) {
        textView.text = tempText;
    }
    else {
        if (_textBefore) {
            textView.text = [[_pgnMove textBefore] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            textView.text = [[_pgnMove textAfter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
}

- (void) gestisciPhone6Landscape {
    CGRect textFrame;
    CGFloat fontSize;
    squareSize = 20.0;
    
    tempText = textView.text;
    [bv removeFromSuperview];
    [textView removeFromSuperview];
    bv = nil;
    textView = nil;
    bv = [[BoardView alloc] initWithSquareSizeAndBoardModel:squareSize :_boardModel];
    CGRect boardFrame = bv.frame;
    boardFrame.origin.y = 5.0;
    //boardFrame.origin.x = ([UIScreen mainScreen].bounds.size.width - squareSize*8)/2;
    boardFrame.origin.x = 50;
    bv.frame = boardFrame;
    [self.view addSubview:bv];
    
    
    squareSize = 40.0;
    textFrame = CGRectMake((larghezzaSchermo - squareSize*8)/2 + 60, 5, squareSize*8 + 80, 160.0);
    fontSize = 12;
    textView = [[UITextView alloc] initWithFrame:textFrame];
    textView.font = [UIFont fontWithName:@"Courier" size:fontSize];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.textColor = [UIColor blueColor];
    textView.backgroundColor = UIColorFromRGB(0xFFFFA6);
    [self.view addSubview:textView];
    
    if ([_pgnMove isRootMove] || _textBefore) {
        if ([_pgnMove isRootMove] && !_textBefore && ! _pgnMove.textAfter) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
        else if ([_pgnMove isRootMove] && !_textBefore && _pgnMove.textAfter) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && _pgnMove.textBefore) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && !_pgnMove.textBefore) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
    }
    else {
        labelBoard.text = [NSLocalizedString(@"POSITION_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        self.navigationItem.title = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        labelText.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
    }
    
    if (tempText) {
        textView.text = tempText;
    }
    else {
        if (_textBefore) {
            textView.text = [[_pgnMove textBefore] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            textView.text = [[_pgnMove textAfter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
}

- (void) gestisciPhone6PPortrait {
    CGRect textFrame;
    CGFloat fontSize;
    squareSize = 30.0;
    
    tempText = textView.text;
    [bv removeFromSuperview];
    [textView removeFromSuperview];
    bv = nil;
    textView = nil;
    bv = [[BoardView alloc] initWithSquareSizeAndBoardModel:squareSize :_boardModel];
    CGRect boardFrame = bv.frame;
    boardFrame.origin.y = 160.0;
    boardFrame.origin.x = (larghezzaSchermo - squareSize*8)/2;
    bv.frame = boardFrame;
    [self.view addSubview:bv];
    
    squareSize = 40.0;
    textFrame = CGRectMake((larghezzaSchermo - squareSize*8)/2, 15, squareSize*8, 140.0);
    fontSize = 12;
    textView = [[UITextView alloc] initWithFrame:textFrame];
    textView.font = [UIFont fontWithName:@"Courier" size:fontSize];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.textColor = [UIColor blueColor];
    textView.backgroundColor = UIColorFromRGB(0xFFFFA6);
    [self.view addSubview:textView];
    
    if ([_pgnMove isRootMove] || _textBefore) {
        if ([_pgnMove isRootMove] && !_textBefore && ! _pgnMove.textAfter) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
        else if ([_pgnMove isRootMove] && !_textBefore && _pgnMove.textAfter) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && _pgnMove.textBefore) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && !_pgnMove.textBefore) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
    }
    else {
        labelBoard.text = [NSLocalizedString(@"POSITION_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        self.navigationItem.title = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        labelText.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
    }
    
    if (tempText) {
        textView.text = tempText;
    }
    else {
        if (_textBefore) {
            textView.text = [[_pgnMove textBefore] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            textView.text = [[_pgnMove textAfter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
}

- (void) gestisciPhone6PLandscape {
    CGRect textFrame;
    CGFloat fontSize;
    squareSize = 22.0;
    
    tempText = textView.text;
    [bv removeFromSuperview];
    [textView removeFromSuperview];
    bv = nil;
    textView = nil;
    bv = [[BoardView alloc] initWithSquareSizeAndBoardModel:squareSize :_boardModel];
    CGRect boardFrame = bv.frame;
    boardFrame.origin.y = 5.0;
    //boardFrame.origin.x = ([UIScreen mainScreen].bounds.size.width - squareSize*8)/2;
    boardFrame.origin.x = 50;
    bv.frame = boardFrame;
    [self.view addSubview:bv];
    
    
    squareSize = 40.0;
    textFrame = CGRectMake((larghezzaSchermo - squareSize*8)/2 + 50, 5, squareSize*8 + 110, 176.0);
    fontSize = 12;
    textView = [[UITextView alloc] initWithFrame:textFrame];
    textView.font = [UIFont fontWithName:@"Courier" size:fontSize];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.textColor = [UIColor blueColor];
    textView.backgroundColor = UIColorFromRGB(0xFFFFA6);
    [self.view addSubview:textView];
    
    if ([_pgnMove isRootMove] || _textBefore) {
        if ([_pgnMove isRootMove] && !_textBefore && ! _pgnMove.textAfter) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
        else if ([_pgnMove isRootMove] && !_textBefore && _pgnMove.textAfter) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && _pgnMove.textBefore) {
            //label.text = @"Edit initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
        }
        else if (![_pgnMove isRootMove] && _textBefore && !_pgnMove.textBefore) {
            //label.text = @"Add initial text";
            labelBoard.text = @"";
            labelText.text = NSLocalizedString(@"INITIAL_TEXT", nil);
            self.navigationItem.title = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
        }
    }
    else {
        labelBoard.text = [NSLocalizedString(@"POSITION_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        self.navigationItem.title = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
        labelText.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:_pgnMove.getMossaPerVarianti];
    }
    
    if (tempText) {
        textView.text = tempText;
    }
    else {
        if (_textBefore) {
            textView.text = [[_pgnMove textBefore] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        else {
            textView.text = [[_pgnMove textAfter] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
}




- (void) doneMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveMenuButtonPressed:(id)sender {
    
    NSString *commento = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (commento.length == 0) {
        //NSLog(@"La stringa è nulla e la interpreto come nil");
        if (_textBefore) {
            [_pgnMove setTextBefore:nil];
        }
        else {
            [_pgnMove setTextAfter:nil];
        }
    }
    else {
        NSMutableString *comment = [[NSMutableString alloc] initWithString:@"{ "];
        [comment appendString:textView.text];
        [comment appendString:@" }"];
        if (_textBefore) {
            [_pgnMove setTextBefore:comment];
        }
        else {
            [_pgnMove setTextAfter:comment];
        }
    }
    if (_delegate) {
        [_delegate aggiornaCommento];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
