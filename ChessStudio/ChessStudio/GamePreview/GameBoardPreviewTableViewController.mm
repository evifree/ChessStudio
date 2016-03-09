//
//  GameBoardPreviewTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 17/01/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "GameBoardPreviewTableViewController.h"
#import "BoardView.h"
#import "PGN.h"
#include "AnimatedGameView.h"
#import "Game.h"

//#include "../Engines/Stockfish/Chess/position.h"
//#include "../Engines/Stockfish/Chess/movepick.h"
//#include "../Engines/Stockfish/Chess/direction.h"
//#include "../Engines/Stockfish/Chess/mersenne.h"
//#include "../Engines/Stockfish/Chess/bitboard.h"

//@interface GameHeaderView : UIView {
//    AnimatedGameView *animatedGameView;
//}




@interface GameBoardPreviewTableViewController () {
    BoardView *boardView;
    PGN *filePgn;
    int _numGame;
    //UIView *headerView;
    
    AnimatedGameView *animatedGameView;
    
    Game *g;
    
    UIButton *fastButton, *slowButton, *playButton, *pauseButton;
    
    NSString *systemVersion;
}

@end

@implementation GameBoardPreviewTableViewController

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
    systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion hasPrefix:@"8."]) {
        //[self setContentSizeForViewInPopover:CGSizeMake(320, 580)];
        [self setPreferredContentSize:CGSizeMake(320.0, 580.0)];
    }
    else {
        //[self setContentSizeForViewInPopover:CGSizeMake(320, 480)];
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
    
    UILabel *label = nil;
    
    //UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 226)];
    
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 280)];
    
    if (IS_IPHONE_4_OR_LESS) {
        if (!IS_PORTRAIT) {
            view = [[UIView alloc] initWithFrame: CGRectMake(80, 0, 320, 226)];
        }
    }
    else if (IS_IPHONE_5) {
        if (!IS_PORTRAIT) {
            view = [[UIView alloc] initWithFrame: CGRectMake(120, 0, 320, 226)];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            view = [[UIView alloc] initWithFrame: CGRectMake(27.5, 0, 320, 226)];
        }
        else {
            view = [[UIView alloc] initWithFrame: CGRectMake(173.5, 0, 320, 226)];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            view = [[UIView alloc] initWithFrame: CGRectMake(47.0, 0, 320, 226)];
        }
        else {
            view = [[UIView alloc] initWithFrame: CGRectMake(208, 0, 320, 226)];
        }
    }
    
    [view setBackgroundColor: [UIColor clearColor]];
    //[view setBackgroundColor:[UIColor redColor]];
    //[view setBackgroundColor:[UIColor colorWithRed:224.0 green:255.0 blue:255.0 alpha:1.0]];
    
    //Game *g = [[Game alloc] initWithGameController:nil PGNString:[filePgn pgnStringForGameNumber:_numGame]];
    g = [[Game alloc] initWithGameController:nil PGNString:_game];
    if (IS_PAD) {
        animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(80, 40, 160, 160)];
    }
    else {
        if (IS_PORTRAIT) {
            //animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(80, 30, 160, 160)];
            animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(80, 50, 160, 160)];
        }
        else {
            animatedGameView = [[AnimatedGameView alloc] initWithGame:g frame:CGRectMake(80, 10, 160, 160)];
        }
    }
    //[animatedGameView setBackgroundColor:[UIColor colorWithRed:255.0 green:199.0 blue:24.0 alpha:1.0]];
    [view addSubview: animatedGameView];
    
    if (IS_PAD) {
        self.tableView.tableHeaderView = view;
        //label = [[UILabel alloc] initWithFrame: CGRectMake(0, 210, 320, 20)];
        label = [[UILabel alloc] initWithFrame: CGRectMake(0, 15, 320, 20)];
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            UIView *view1 = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 100)];
            self.tableView.tableHeaderView = view1;
            self.tableView.tableFooterView = view;
            label = [[UILabel alloc] initWithFrame: CGRectMake(0, 5, 320, 20)];
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 20)];
            [label2 setFont: [UIFont systemFontOfSize: 12]];
            [label2 setTextAlignment: NSTextAlignmentCenter];
            label2.adjustsFontSizeToFitWidth = YES;
            [label2 setText:[NSString stringWithFormat:@"%@  %@  %@  %@  %@", [g event], [g site], [g date], [g round], [g eco]]];
            [view addSubview:label2];
            
        }
        else {
            UIView *view1 = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 30)];
            self.tableView.tableHeaderView = view1;
            self.tableView.tableFooterView = view;
            label = [[UILabel alloc] initWithFrame: CGRectMake(0, 204, 320, 20)];
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 224, 320, 20)];
            [label2 setFont: [UIFont systemFontOfSize: 12]];
            [label2 setTextAlignment: NSTextAlignmentCenter];
            label2.adjustsFontSizeToFitWidth = YES;
            [label2 setText:[NSString stringWithFormat:@"%@  %@  %@  %@  %@", [g event], [g site], [g date], [g round], [g eco]]];
            [view addSubview:label2];
        }
    }
    else {
        if (IS_PORTRAIT) {
            UIView *view1 = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 70)];
            self.tableView.tableHeaderView = view1;
            self.tableView.tableFooterView = view;
            //label = [[UILabel alloc] initWithFrame: CGRectMake(0, 224, 320, 20)];
            label = [[UILabel alloc] initWithFrame: CGRectMake(0, 5, 320, 20)];
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 20)];
            [label2 setFont: [UIFont systemFontOfSize: 12]];
            [label2 setTextAlignment: NSTextAlignmentCenter];
            label2.adjustsFontSizeToFitWidth = YES;
            [label2 setText:[NSString stringWithFormat:@"%@  %@  %@  %@  %@", [g event], [g site], [g date], [g round], [g eco]]];
            [view addSubview:label2];
        }
        else {
            UIView *view1 = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 30)];
            self.tableView.tableHeaderView = view1;
            self.tableView.tableFooterView = view;
            label = [[UILabel alloc] initWithFrame: CGRectMake(0, 204, 320, 20)];
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 224, 320, 20)];
            [label2 setFont: [UIFont systemFontOfSize: 12]];
            [label2 setTextAlignment: NSTextAlignmentCenter];
            label2.adjustsFontSizeToFitWidth = YES;
            [label2 setText:[NSString stringWithFormat:@"%@  %@  %@  %@  %@", [g event], [g site], [g date], [g round], [g eco]]];
            [view addSubview:label2];
        }
    }
    

    
    
    
    //UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 174, 320, 20)];
    [label setText: [NSString stringWithFormat: @"%@-%@ %@ (%d moves)", [g whitePlayer], [g blackPlayer], [g result], (int)([[g moves] count] + 1) / 2]];
    [label setFont: [UIFont systemFontOfSize: 12]];
    [label setTextAlignment: NSTextAlignmentCenter];
    label.adjustsFontSizeToFitWidth = YES;
    [view addSubview: label];
    

    if (IS_PAD) {
        slowButton = [[UIButton alloc] initWithFrame: CGRectMake(80, 200, 40, 40)];
        [slowButton setImage: [UIImage imageNamed: @"slow"] forState: UIControlStateNormal];
        [view addSubview: slowButton];
        [slowButton addTarget: self action: @selector(rallenta) forControlEvents: UIControlEventTouchDown];
        
        playButton = [[UIButton alloc] initWithFrame: CGRectMake(120, 200, 40, 40)];
        [playButton setImage: [UIImage imageNamed: @"play"] forState: UIControlStateNormal];
        [view addSubview: playButton];
        [playButton addTarget: self action: @selector(play) forControlEvents: UIControlEventTouchDown];
        
        pauseButton = [[UIButton alloc] initWithFrame: CGRectMake(160, 200, 40, 40)];
        [pauseButton setImage: [UIImage imageNamed: @"pause"] forState: UIControlStateNormal];
        [view addSubview: pauseButton];
        [pauseButton addTarget: self action: @selector(pause) forControlEvents: UIControlEventTouchDown];
        
        fastButton = [[UIButton alloc] initWithFrame: CGRectMake(200, 200, 40, 40)];
        [fastButton setImage: [UIImage imageNamed: @"fast"] forState: UIControlStateNormal];
        [view addSubview: fastButton];
        [fastButton addTarget: self action: @selector(accelera) forControlEvents: UIControlEventTouchDown];
    }
    else if (IS_PORTRAIT) {
        slowButton = [[UIButton alloc] initWithFrame: CGRectMake(80, 210, 40, 40)];
        [slowButton setImage: [UIImage imageNamed: @"slow"] forState: UIControlStateNormal];
        [view addSubview: slowButton];
        [slowButton addTarget: self action: @selector(rallenta) forControlEvents: UIControlEventTouchDown];
        
        playButton = [[UIButton alloc] initWithFrame: CGRectMake(120, 210, 40, 40)];
        [playButton setImage: [UIImage imageNamed: @"play"] forState: UIControlStateNormal];
        [view addSubview: playButton];
        [playButton addTarget: self action: @selector(play) forControlEvents: UIControlEventTouchDown];
        
        pauseButton = [[UIButton alloc] initWithFrame: CGRectMake(160, 210, 40, 40)];
        [pauseButton setImage: [UIImage imageNamed: @"pause"] forState: UIControlStateNormal];
        [view addSubview: pauseButton];
        [pauseButton addTarget: self action: @selector(pause) forControlEvents: UIControlEventTouchDown];
        
        fastButton = [[UIButton alloc] initWithFrame: CGRectMake(200, 210, 40, 40)];
        [fastButton setImage: [UIImage imageNamed: @"fast"] forState: UIControlStateNormal];
        [view addSubview: fastButton];
        [fastButton addTarget: self action: @selector(accelera) forControlEvents: UIControlEventTouchDown];
    }
    else {
        slowButton = [[UIButton alloc] initWithFrame: CGRectMake(80, 174, 40, 40)];
        [slowButton setImage: [UIImage imageNamed: @"slow"] forState: UIControlStateNormal];
        [view addSubview: slowButton];
        [slowButton addTarget: self action: @selector(rallenta) forControlEvents: UIControlEventTouchDown];
        
        playButton = [[UIButton alloc] initWithFrame: CGRectMake(120, 174, 40, 40)];
        [playButton setImage: [UIImage imageNamed: @"play"] forState: UIControlStateNormal];
        [view addSubview: playButton];
        [playButton addTarget: self action: @selector(play) forControlEvents: UIControlEventTouchDown];
        
        pauseButton = [[UIButton alloc] initWithFrame: CGRectMake(160, 174, 40, 40)];
        [pauseButton setImage: [UIImage imageNamed: @"pause"] forState: UIControlStateNormal];
        [view addSubview: pauseButton];
        [pauseButton addTarget: self action: @selector(pause) forControlEvents: UIControlEventTouchDown];
        
        fastButton = [[UIButton alloc] initWithFrame: CGRectMake(200, 174, 40, 40)];
        [fastButton setImage: [UIImage imageNamed: @"fast"] forState: UIControlStateNormal];
        [view addSubview: fastButton];
        [fastButton addTarget: self action: @selector(accelera) forControlEvents: UIControlEventTouchDown];
    }
    
    
    [animatedGameView startAnimation];
    
    //return view;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
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
