//
//  GameBoardPreviewTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 17/01/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "EcoBoardPreviewTableViewController.h"
#import "BoardView.h"
#import "PGN.h"
#include "AnimatedGameView.h"
#import "Game.h"
#import "MarqueeLabel.h"
#import "UtilToView.h"

//#include "../Engines/Stockfish/Chess/position.h"
//#include "../Engines/Stockfish/Chess/movepick.h"
//#include "../Engines/Stockfish/Chess/direction.h"
//#include "../Engines/Stockfish/Chess/mersenne.h"
//#include "../Engines/Stockfish/Chess/bitboard.h"

//@interface GameHeaderView : UIView {
//    AnimatedGameView *animatedGameView;
//}




@interface EcoBoardPreviewTableViewController () {
    BoardView *boardView;
    PGN *filePgn;
    int _numGame;
    //UIView *headerView;
    
    AnimatedGameView *animatedGameView;
    
    Game *g;
    
    UIButton *fastButton, *slowButton, *playButton, *pauseButton;
    
    NSString *systemVersion;
    
    UIView *view;
    UILabel *labelOpening;
    MarqueeLabel *ml;
}

@end

@implementation EcoBoardPreviewTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //init_mersenne();
        //init_direction_table();
        //init_bitboards();
        //Position::init_zobrist();
        //Position::init_piece_square_tables();
        //MovePicker::init_phase_table();
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //[self setContentSizeForViewInPopover:CGSizeMake(320, 400)];
//    systemVersion = [[UIDevice currentDevice] systemVersion];
//    if ([systemVersion hasPrefix:@"8."]) {
//        //[self setContentSizeForViewInPopover:CGSizeMake(320, 580)];
//        
//    }
    
    
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        [self setPreferredContentSize:CGSizeMake(320.0, 580.0)];
        [self setPreferredContentSize:CGSizeMake(400.0, 400.0)];
        
    }
    else {
        [self setPreferredContentSize:CGSizeMake(320.0, 480.0)];
    }
    
    /*
    boardView = [[BoardView alloc] initWithSquareSizeAndSquareType:28.0 :@"square5"];
    [self setContentSizeForViewInPopover:CGSizeMake(300, 224)];
    boardView.center = CGPointMake(38.0 + 224/2, 0.0);
    self.tableView.tableHeaderView = boardView;
    self.tableView.scrollEnabled = NO;
    */
    
    [[self tableView] setScrollEnabled: NO];
    //[[self tableView] setAllowsSelection: NO];
    
    //[[self tableView] setBackgroundColor:[UIColor colorWithRed:255.0 green:199.0 blue:24.0 alpha:1.0]];
}

- (void) loadView {
    [super loadView];
    [self createHeaderView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


- (void) setNumGame:(int)numGame {
    _numGame = numGame;
    filePgn = [[PGN alloc] initWithFilename:_pgnFileDoc.pgnFileInfo.path];
    [filePgn initializeGameIndices];
    [filePgn goToGameNumber:_numGame];
    //NSLog(@"Partita:\n%@", [filePgn pgnStringForGameNumber:_numGame]);
}

- (void)createHeaderView {
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UILabel *label = nil;
    
    
    //UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 320)];
    //view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 400, 400)];
    
    
    if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 480)];
        }
        else {
            view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 480, 320)];
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 568)];
        }
        else {
            view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 568, 320)];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 375, 667)];
        }
        else {
            view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 667, 375)];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            view = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0, 414, 736)];
        }
        else {
            view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 736, 414)];
        }
    }
    else if ((IS_PAD) || (IS_PAD_PRO)) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
    }
    
    if ([_eco hasPrefix:@"A"]) {
        UIColor *color = [UtilToView getEcoColor:_eco];
        [view setBackgroundColor:[color colorWithAlphaComponent:0.2]];
    }
    else if ([_eco hasPrefix:@"B"]) {
        UIColor *color = [UtilToView getEcoColor:_eco];
        [view setBackgroundColor:[color colorWithAlphaComponent:0.2]];
    }
    else if ([_eco hasPrefix:@"C"]) {
        UIColor *color = [UtilToView getEcoColor:_eco];
        [view setBackgroundColor:[color colorWithAlphaComponent:0.2]];
    }
    else if ([_eco hasPrefix:@"D"]) {
        UIColor *color = [UtilToView getEcoColor:_eco];
        [view setBackgroundColor:[color colorWithAlphaComponent:0.2]];
    }
    else if ([_eco hasPrefix:@"E"]) {
        UIColor *color = [UtilToView getEcoColor:_eco];
        [view setBackgroundColor:[color colorWithAlphaComponent:0.2]];
    }
    
    //[view setBackgroundColor: [UIColor redColor]];
    //[view setBackgroundColor:[UIColor redColor]];
    //[view setBackgroundColor:[UIColor colorWithRed:224.0 green:255.0 blue:255.0 alpha:1.0]];
    
    //Game *g = [[Game alloc] initWithGameController:nil PGNString:[filePgn pgnStringForGameNumber:_numGame]];
    g = [[Game alloc] initWithGameController:nil PGNString:_game];
    if ((IS_PAD) || (IS_PAD_PRO)) {
        //animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(80, 40, 160, 160)];
        animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(50, 50, 300, 300)];
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(40, 20, 240, 240)];
        }
        else {
            //animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(40, 20, 240, 240)];
            animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(120, 20, 240, 240)];
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(40, 20, 240, 240)];
        }
        else {
            animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(164, 20, 240, 240)];
            //[animatedGameView setFrame:CGRectMake(164, 20, 240, 240)];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(67.5, 20, 240, 240)];
        }
        else {
            animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(213.5, 20, 240, 240)];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(87, 20, 240, 240)];
        }
        else {
            animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(248, 20, 240, 240)];
        }
    }
    else {
        if (IS_PORTRAIT) {
            animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(80, 50, 160, 160)];
        }
        else {
            animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(80, 10, 160, 160)];
        }
    }
    //[animatedGameView setBackgroundColor:[UIColor colorWithRed:255.0 green:199.0 blue:24.0 alpha:1.0]];
    //[animatedGameView setBackgroundColor:[UIColor clearColor]];
    [view addSubview: animatedGameView];
    
    
    
    label = [[UILabel alloc] initWithFrame: CGRectMake(175, 15, 50, 20)];
    label.text = _eco;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0];
    [label setTextAlignment: NSTextAlignmentCenter];
    label.adjustsFontSizeToFitWidth = YES;
    labelOpening = [[UILabel alloc] initWithFrame: CGRectMake(50, 352, 300, 20)];
    labelOpening.text = _opening;
    labelOpening.adjustsFontSizeToFitWidth = YES;
    labelOpening.backgroundColor = [UIColor clearColor];
    labelOpening.font = [UIFont fontWithName:@"Verdana-Bold" size:12];
    [labelOpening setTextAlignment: NSTextAlignmentCenter];
    
    
    ml = [[MarqueeLabel alloc] initWithFrame:CGRectMake(50, 374, 300, 20) rate:50.0 andFadeLength:10.0];
    ml.backgroundColor = [UIColor clearColor];
    ml.attributedText = _openingMoves;
    ml.marqueeType = MLContinuous;
    ml.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pauseTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [ml addGestureRecognizer:tapRecognizer];
    [ml setTextAlignment: NSTextAlignmentCenter];
    [view addSubview:ml];
    
    
    
    
    if ((IS_PAD) || (IS_PAD_PRO)) {
        self.tableView.tableHeaderView = view;
        [view addSubview: label];
        [view addSubview:labelOpening];
        
//        ml = [[MarqueeLabel alloc] initWithFrame:CGRectMake(50, 374, 300, 20) rate:50.0 andFadeLength:10.0];
//        ml.backgroundColor = [UIColor clearColor];
//        ml.attributedText = _openingMoves;
//        ml.marqueeType = MLContinuous;
//        ml.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pauseTap:)];
//        tapRecognizer.numberOfTapsRequired = 1;
//        tapRecognizer.numberOfTouchesRequired = 1;
//        [ml addGestureRecognizer:tapRecognizer];
        [view addSubview:ml];
        
    }
    else if (IS_IPHONE_4_OR_LESS) {
        self.tableView.tableHeaderView = view;
        if (IS_PORTRAIT) {
            //[labelOpening setFrame:CGRectMake(10, 270, 300, 20)];
            [labelOpening setCenter:CGPointMake(160, 10)];
            [ml setCenter:CGPointMake(160, 280)];
        }
        else {
            //[labelOpening setFrame:CGRectMake(270, 20, 300, 20)];
            [labelOpening setCenter:CGPointMake(240, 10)];
            [ml setCenter:CGPointMake(240, 280)];
        }
        self.navigationItem.titleView = label;
        [view addSubview:labelOpening];
    }
    else if (IS_IPHONE_5) {
        self.tableView.tableHeaderView = view;
        self.navigationItem.titleView = label;
        if (IS_PORTRAIT) {
            //[labelOpening setFrame:CGRectMake(10, 270, 300, 20)];
            [labelOpening setCenter:CGPointMake(160, 10)];
            [ml setCenter:CGPointMake(160, 280)];
        }
        else {
            //[labelOpening setFrame:CGRectMake(270, 20, 300, 20)];
            [labelOpening setCenter:CGPointMake(284, 10)];
            [ml setCenter:CGPointMake(284, 280)];
        }
        [view addSubview:labelOpening];
        
    }
    else if (IS_IPHONE_6) {
        self.tableView.tableHeaderView = view;
        self.navigationItem.titleView = label;
        if (IS_PORTRAIT) {
            //[labelOpening setFrame:CGRectMake(10, 270, 300, 20)];
            [labelOpening setCenter:CGPointMake(187.5, 10)];
            [ml setCenter:CGPointMake(187, 280)];
        }
        else {
            //[labelOpening setFrame:CGRectMake(270, 20, 300, 20)];
            [labelOpening setCenter:CGPointMake(333.5, 10)];
        }
        [view addSubview:labelOpening];
    }
    else if (IS_IPHONE_6P) {
        self.tableView.tableHeaderView = view;
        self.navigationItem.titleView = label;
        
        if (IS_PORTRAIT) {
            //[labelOpening setFrame:CGRectMake(10, 270, 300, 20)];
            [labelOpening setCenter:CGPointMake(207, 10)];
            [ml setCenter:CGPointMake(207, 280)];
        }
        else {
            //[labelOpening setFrame:CGRectMake(270, 20, 300, 20)];
            [labelOpening setCenter:CGPointMake(368, 10)];
            [ml setCenter:CGPointMake(368, 280)];
        }
        [view addSubview:labelOpening];
    }
    
    
    
    //UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 174, 320, 20)];
    //[label setText: [NSString stringWithFormat: @"%@-%@ %@ (%d moves)", [g whitePlayer], [g blackPlayer], [g result], (int)([[g moves] count] + 1) / 2]];
    //[label setFont: [UIFont systemFontOfSize: 20]];

    

//    if (IS_PAD) {
//        slowButton = [[UIButton alloc] initWithFrame: CGRectMake(80, 200, 40, 40)];
//        [slowButton setImage: [UIImage imageNamed: @"slow"] forState: UIControlStateNormal];
//        [view addSubview: slowButton];
//        [slowButton addTarget: self action: @selector(rallenta) forControlEvents: UIControlEventTouchDown];
//        
//        playButton = [[UIButton alloc] initWithFrame: CGRectMake(120, 200, 40, 40)];
//        [playButton setImage: [UIImage imageNamed: @"play"] forState: UIControlStateNormal];
//        [view addSubview: playButton];
//        [playButton addTarget: self action: @selector(play) forControlEvents: UIControlEventTouchDown];
//        
//        pauseButton = [[UIButton alloc] initWithFrame: CGRectMake(160, 200, 40, 40)];
//        [pauseButton setImage: [UIImage imageNamed: @"pause"] forState: UIControlStateNormal];
//        [view addSubview: pauseButton];
//        [pauseButton addTarget: self action: @selector(pause) forControlEvents: UIControlEventTouchDown];
//        
//        fastButton = [[UIButton alloc] initWithFrame: CGRectMake(200, 200, 40, 40)];
//        [fastButton setImage: [UIImage imageNamed: @"fast"] forState: UIControlStateNormal];
//        [view addSubview: fastButton];
//        [fastButton addTarget: self action: @selector(accelera) forControlEvents: UIControlEventTouchDown];
//    }
//    else if (IS_PORTRAIT) {
//        slowButton = [[UIButton alloc] initWithFrame: CGRectMake(80, 210, 40, 40)];
//        [slowButton setImage: [UIImage imageNamed: @"slow"] forState: UIControlStateNormal];
//        [view addSubview: slowButton];
//        [slowButton addTarget: self action: @selector(rallenta) forControlEvents: UIControlEventTouchDown];
//        
//        playButton = [[UIButton alloc] initWithFrame: CGRectMake(120, 210, 40, 40)];
//        [playButton setImage: [UIImage imageNamed: @"play"] forState: UIControlStateNormal];
//        [view addSubview: playButton];
//        [playButton addTarget: self action: @selector(play) forControlEvents: UIControlEventTouchDown];
//        
//        pauseButton = [[UIButton alloc] initWithFrame: CGRectMake(160, 210, 40, 40)];
//        [pauseButton setImage: [UIImage imageNamed: @"pause"] forState: UIControlStateNormal];
//        [view addSubview: pauseButton];
//        [pauseButton addTarget: self action: @selector(pause) forControlEvents: UIControlEventTouchDown];
//        
//        fastButton = [[UIButton alloc] initWithFrame: CGRectMake(200, 210, 40, 40)];
//        [fastButton setImage: [UIImage imageNamed: @"fast"] forState: UIControlStateNormal];
//        [view addSubview: fastButton];
//        [fastButton addTarget: self action: @selector(accelera) forControlEvents: UIControlEventTouchDown];
//    }
//    else {
//        slowButton = [[UIButton alloc] initWithFrame: CGRectMake(80, 174, 40, 40)];
//        [slowButton setImage: [UIImage imageNamed: @"slow"] forState: UIControlStateNormal];
//        [view addSubview: slowButton];
//        [slowButton addTarget: self action: @selector(rallenta) forControlEvents: UIControlEventTouchDown];
//        
//        playButton = [[UIButton alloc] initWithFrame: CGRectMake(120, 174, 40, 40)];
//        [playButton setImage: [UIImage imageNamed: @"play"] forState: UIControlStateNormal];
//        [view addSubview: playButton];
//        [playButton addTarget: self action: @selector(play) forControlEvents: UIControlEventTouchDown];
//        
//        pauseButton = [[UIButton alloc] initWithFrame: CGRectMake(160, 174, 40, 40)];
//        [pauseButton setImage: [UIImage imageNamed: @"pause"] forState: UIControlStateNormal];
//        [view addSubview: pauseButton];
//        [pauseButton addTarget: self action: @selector(pause) forControlEvents: UIControlEventTouchDown];
//        
//        fastButton = [[UIButton alloc] initWithFrame: CGRectMake(200, 174, 40, 40)];
//        [fastButton setImage: [UIImage imageNamed: @"fast"] forState: UIControlStateNormal];
//        [view addSubview: fastButton];
//        [fastButton addTarget: self action: @selector(accelera) forControlEvents: UIControlEventTouchDown];
//    }
    
    
    [animatedGameView startAnimation];
    
    //return view;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    NSLog(@"will rotate");
    if (!IS_PORTRAIT) {
        if (IS_IPHONE_4_OR_LESS) {
            //[animatedGameView removeFromSuperview];
            [view setFrame:CGRectMake(0, 0, 320, 480)];
        }
        else if (IS_IPHONE_5) {
            //[animatedGameView removeFromSuperview];
            [view setFrame:CGRectMake(0, 0, 320, 568)];
        }
        else if (IS_IPHONE_6) {
            //[animatedGameView removeFromSuperview];
            [view setFrame:CGRectMake(0, 0, 320, 667)];
        }
        else if (IS_IPHONE_6P) {
            //[animatedGameView removeFromSuperview];
            [view setFrame:CGRectMake(0, 0, 414, 736)];
        }
    }
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (!(IS_PAD)) {
        [view setFrame:CGRectMake(0, 0, size.width, size.height)];
        [animatedGameView setCenter:CGPointMake(size.width/2, 140)];
        [labelOpening setCenter:CGPointMake(size.width/2, 10)];
        [ml setCenter:CGPointMake(size.width/2, 280)];
    }
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"did rotate");
    if (!IS_PORTRAIT) {
        if (IS_IPHONE_4_OR_LESS) {
            //[animatedGameView setFrame:CGRectMake(120, 20, 240, 240)];
            [animatedGameView setCenter:CGPointMake(240, 140)];
            [labelOpening setCenter:CGPointMake(240, 10)];
            [ml setCenter:CGPointMake(240, 280)];
        }
        else if (IS_IPHONE_5) {
            //[view setFrame:CGRectMake(0, 0, 320, 568)];
            //[animatedGameView setFrame:CGRectMake(164, 20, 240, 240)];
            //[labelOpening setFrame:CGRectMake(270, 20, 300, 20)];
            //[labelOpening setCenter:CGPointMake(284, 10)];
            //[ml setCenter:CGPointMake(284, 280)];
        }
        else if (IS_IPHONE_6) {
            //[view setFrame:CGRectMake(0, 0, 320, 667)];
            //[animatedGameView setFrame:CGRectMake(213.5, 20, 240, 240)];
            //[labelOpening setCenter:CGPointMake(333.5, 10)];
        }
        else if (IS_IPHONE_6P) {
            //[view setFrame:CGRectMake(0, 0, 414, 736)];
             //[animatedGameView setFrame:CGRectMake(248, 20, 240, 240)];
            //[labelOpening setCenter:CGPointMake(368, 10)];
        }
    }
    else {
        if (IS_IPHONE_4_OR_LESS) {
            //[view setFrame:CGRectMake(0, 0, 320, 480)];
            //[animatedGameView setFrame:CGRectMake(40, 20, 240, 240)];
            [animatedGameView setCenter:CGPointMake(160, 140)];
            //[labelOpening setFrame:CGRectMake(10, 270, 300, 20)];
            [labelOpening setCenter:CGPointMake(160, 10)];
            [ml setCenter:CGPointMake(160, 280)];
        }
        else if (IS_IPHONE_5) {
            //[view setFrame:CGRectMake(0, 0, 320, 568)];
            //[animatedGameView setFrame:CGRectMake(40, 20, 240, 240)];
            //[labelOpening setFrame:CGRectMake(10, 270, 300, 20)];
            //[labelOpening setCenter:CGPointMake(160, 10)];
            //[ml setCenter:CGPointMake(160, 280)];
        }
        else if (IS_IPHONE_6) {
            //[view setFrame:CGRectMake(0, 0, 320, 667)];
            //[animatedGameView setFrame:CGRectMake(67.5, 20, 240, 240)];
            //[labelOpening setCenter:CGPointMake(187.5, 10)];
        }
        else if (IS_IPHONE_6P) {
            //[view setFrame:CGRectMake(0, 0, 414, 736)];
            //[animatedGameView setFrame:CGRectMake(87, 20, 240, 240)];
            //[labelOpening setCenter:CGPointMake(207, 10)];
        }
    }
    //[view addSubview:animatedGameView];
}

- (void)pauseTap:(UITapGestureRecognizer *)recognizer {
    MarqueeLabel *continuousLabel2 = (MarqueeLabel *)recognizer.view;
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (!continuousLabel2.isPaused) {
            [continuousLabel2 pauseLabel];
        } else {
            [continuousLabel2 unpauseLabel];
        }
    }
}

- (void) accelera {
    [animatedGameView accelera];
}

- (void) rallenta {
    [animatedGameView rallenta];
}

- (void) pause {
    [animatedGameView stopAnimation];
}

- (void) play {
    [animatedGameView startAnimation];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return 0;
    
    if (IS_PAD) {
        return 5;
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            return 0;
        }
        else {
            return 0;
        }
    }
    else if (IS_PHONE) {
        if (IS_PORTRAIT) {
            return 0;
        }
        else {
            return 0;
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 0.0;
    
    if (IS_PAD) {
        //if ([systemVersion hasPrefix:@"8."]) {
        //    return 44;
        //}
        return 40.0;
    }
    if (IS_PHONE) {
        if (IS_LANDSCAPE) {
            return 12;
        }
    }
    return 22.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0) {
        [[cell textLabel] setText: @"Event"];
        [[cell detailTextLabel] setText: [g event]];
    }
    else if (indexPath.row == 1) {
        [[cell textLabel] setText: @"Site"];
        [[cell detailTextLabel] setText: [g site]];
    }
    else if (indexPath.row == 2) {
        [[cell textLabel] setText: @"Date"];
        [[cell detailTextLabel] setText: [g date]];
    }
    else if (indexPath.row == 3) {
        [[cell textLabel] setText: @"Round"];
        [[cell detailTextLabel] setText: [g round]];
    }
    else if (indexPath.row == 4) {
        [[cell textLabel] setText: @"ECO"];
        [[cell detailTextLabel] setText: [g eco]];
    }

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
