//
//  SetupPositionTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 28/08/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "SetupPositionTableViewController.h"
#import "SideToMoveViewController.h"
#import "SettingManager.h"

@interface SetupPositionTableViewController () {
    CGFloat dimSquare;
    NSString *_pieceType;
    
    SettingManager *settingManager;
    
    UIView *viewForTableViewHeader;
}

@end

@implementation SetupPositionTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_IOS_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.tableView.backgroundColor = [UIColor clearColor];
    }
    
    settingManager = [SettingManager sharedSettingManager];
    _pieceType = [settingManager getPieceTypeToLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0xffffa6);

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.navigationItem.title = NSLocalizedString(@"SETUP_POSITION_FINAL", niL);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed)];
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    viewForTableViewHeader = nil;
    
    if (IS_PAD) {
        //dimSquare = 60.0;
        //_boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
        //[self setupPositionFromBoardModel];
        viewForTableViewHeader = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 540, 500)];
        [viewForTableViewHeader setBackgroundColor: [UIColor clearColor]];
        _boardView.center = CGPointMake(viewForTableViewHeader.frame.size.width/2, viewForTableViewHeader.frame.size.height/2);
        [viewForTableViewHeader addSubview:_boardView];
        self.tableView.tableHeaderView = viewForTableViewHeader;
    }
    else {
        if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
            if (IS_PORTRAIT) {
                dimSquare = 40.0;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [self setupPositionFromBoardModel];
                viewForTableViewHeader = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 340)];
                [viewForTableViewHeader setBackgroundColor: [UIColor clearColor]];
                _boardView.center = CGPointMake(viewForTableViewHeader.frame.size.width/2, viewForTableViewHeader.frame.size.height/2);
                [viewForTableViewHeader addSubview:_boardView];
                self.tableView.tableHeaderView = viewForTableViewHeader;
            }
            else {
                dimSquare = 30.0;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [self setupPositionFromBoardModel];
                if (IS_IPHONE_5) {
                    viewForTableViewHeader = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 568, 240)];
                }
                else {
                    viewForTableViewHeader = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 480, 240)];
                }
                [viewForTableViewHeader setBackgroundColor: [UIColor clearColor]];
                _boardView.center = CGPointMake(viewForTableViewHeader.frame.size.width/2, viewForTableViewHeader.frame.size.height/2);
                [viewForTableViewHeader addSubview:_boardView];
                self.tableView.tableHeaderView = viewForTableViewHeader;
            }
        }
        else if (IS_IPHONE_6) {
            if (IS_PORTRAIT) {
                dimSquare = 46.875;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [self setupPositionFromBoardModel];
                viewForTableViewHeader = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 375, 375)];
                [viewForTableViewHeader setBackgroundColor: [UIColor clearColor]];
                _boardView.center = CGPointMake(viewForTableViewHeader.frame.size.width/2, viewForTableViewHeader.frame.size.height/2);
                [viewForTableViewHeader addSubview:_boardView];
                self.tableView.tableHeaderView = viewForTableViewHeader;
            }
            else {
                dimSquare = 35.0;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [self setupPositionFromBoardModel];
                viewForTableViewHeader = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 280, 280)];
                [viewForTableViewHeader setBackgroundColor: [UIColor clearColor]];
                _boardView.center = CGPointMake(667/2, 280/2);
                [viewForTableViewHeader addSubview:_boardView];
                self.tableView.tableHeaderView = viewForTableViewHeader;
            }
        }
        else if (IS_IPHONE_6P) {
            if (IS_PORTRAIT) {
                //dimSquare = 51.75;
                dimSquare = 35.0;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [self setupPositionFromBoardModel];
                viewForTableViewHeader = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 280, 300)];
                [viewForTableViewHeader setBackgroundColor: [UIColor clearColor]];
                _boardView.center = CGPointMake(420.0/2, 300.0/2);
                [viewForTableViewHeader addSubview:_boardView];
                self.tableView.tableHeaderView = viewForTableViewHeader;
            }
            else {
                dimSquare = 35.0;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [self setupPositionFromBoardModel];
                viewForTableViewHeader = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 280, 300)];
                [viewForTableViewHeader setBackgroundColor: [UIColor clearColor]];
                _boardView.center = CGPointMake(420.0/2, 300.0/2);
                //_boardView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
                [viewForTableViewHeader addSubview:_boardView];
                self.tableView.tableHeaderView = viewForTableViewHeader;
            }
        }
    }
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (!IS_PAD) {
        self.tableView.tableHeaderView = nil;
        if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
            if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
                dimSquare = 30.0;
            }
            else {
                dimSquare = 40.0;
            }
            _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
        }
        else if (IS_IPHONE_6) {
            if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
                dimSquare = 35.0;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            }
            else {
                dimSquare = 46.875;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            }
        }
        else if (IS_IPHONE_6P) {
            NSLog(@"Sto ruotatndo iPHONE6p");
            if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
                dimSquare = 35.0;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            }
            else {
                dimSquare = 46.875;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
            }
        }
        [self setupPositionFromBoardModel];
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (!IS_PAD) {
        if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
            if (IS_PORTRAIT) {
                UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 340)];
                [view setBackgroundColor: [UIColor clearColor]];
                _boardView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
                [view addSubview:_boardView];
                self.tableView.tableHeaderView = view;
            }
            else {
                UIView *view = nil;
                if (IS_IPHONE_5) {
                    view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 568, 240)];
                }
                else {
                    view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 480, 240)];
                }
                [view setBackgroundColor: [UIColor clearColor]];
                _boardView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
                [view addSubview:_boardView];
                self.tableView.tableHeaderView = view;
            }
        }
        else if (IS_IPHONE_6) {
            if (IS_PORTRAIT) {
                UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 375, 375)];
                [view setBackgroundColor: [UIColor clearColor]];
                _boardView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
                [view addSubview:_boardView];
                self.tableView.tableHeaderView = view;
            }
            else {
                UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 280, 280)];
                [view setBackgroundColor: [UIColor clearColor]];
                _boardView.center = CGPointMake(667/2, 280/2);
                [view addSubview:_boardView];
                self.tableView.tableHeaderView = view;
            }
        }
        else if (IS_IPHONE_6P) {
            if (IS_PORTRAIT) {
                dimSquare = 35.0;
                _boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
                [self setupPositionFromBoardModel];
                UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 280, 300)];
                [view setBackgroundColor: [UIColor clearColor]];
                _boardView.center = CGPointMake(420.0/2, 300.0/2);
                [view addSubview:_boardView];
                self.tableView.tableHeaderView = view;
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_checkupPosition>0) {
        return 5;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        if ([[_boardModel getArrocchiPermessiInPosizione] count] == 0) {
            return 1;
        }
        return [[_boardModel getArrocchiPermessiInPosizione] count];
    }
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    if (indexPath.section == 0) {
        if (IS_PAD) {
            return 500.0;
        }
        else {
            if (IS_PORTRAIT) {
                return 340;
            }
            else {
                return 250;
            }
        }
    }*/
    return 44.0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == -1) {
        return NSLocalizedString(@"SETUP_POSITION", nil);
    }
    else if (section == 0) {
        return NSLocalizedString(@"SETUP_POSITION_SIDE_TO_MOVE", nil);
    }
    else if (section == 1) {
        return NSLocalizedString(@"SETUP_POSITION_CASTLING", nil);
    }
    else if (section == 2) {
        return @"En Passant";
    }
    else if (section == 3) {
        if (_checkupPosition>0) {
            return NSLocalizedString(@"SETUP_POSITION_REMARK", nil);
        }
        return NSLocalizedString(@"SETUP_POSITION_FEN", nil);
    }
    else if (section == 4) {
        return NSLocalizedString(@"SETUP_POSITION_FEN", nil);
    }
    return nil;
}

- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (IS_IOS_7) {
        if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
            UITableViewHeaderFooterView *thfv = (UITableViewHeaderFooterView *)view;
            thfv.textLabel.textColor = [UIColor whiteColor];
            thfv.contentView.backgroundColor = UIColorFromRGB(0x6E7B8B);
            thfv.textLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:15];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell SetupPosition";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (IS_IOS_7) {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    if (indexPath.section == -1 && indexPath.row == 0) {
        if (IS_PAD) {
            CGRect boardFrame = _boardView.frame;
            boardFrame.origin.y = 10;
            _boardView.frame = boardFrame;
        }
        else {
            CGRect boardFrame = _boardView.frame;
            boardFrame.origin.y = 10;
            _boardView.frame = boardFrame;
        }
        //[cell.contentView addSubview:_boardView];
        cell.textLabel.text = nil;
    }
    else if (indexPath.section == 0 && indexPath.row == 0) {
        if ([_boardModel whiteHasToMove]) {
            cell.textLabel.text = NSLocalizedString(@"SETUP_POSITION_WHITE", nil);
        }
        else {
            cell.textLabel.text = NSLocalizedString(@"SETUP_POSITION_BLACK", nil);
        }
        //[_boardView removeFromSuperview];
    }
    else if (indexPath.section == 1) {
        if ([[_boardModel getArrocchiPermessiInPosizione] count] == 0) {
            cell.textLabel.text = NSLocalizedString(@"SETUP_POSITION_NO_CASTLING", nil);
        }
        else {
            cell.textLabel.text = [[_boardModel getArrocchiPermessiInPosizione] objectAtIndex:indexPath.row];
        }
        //[_boardView removeFromSuperview];
    }
    else if (indexPath.section ==2 && indexPath.row == 0) {
        if (![_boardModel getSelectedSquareEnPassant]) {
            cell.textLabel.text = NSLocalizedString(@"SETUP_POSITION_NO_ENPASSANT", nil);
        }
        else {
            cell.textLabel.text = [_boardModel getSelectedSquareEnPassant];
        }
        //[_boardView removeFromSuperview];
    }
    else if (indexPath.section == 3 && indexPath.row == 0) {
        if (_checkupPosition == 1) {
            cell.textLabel.text = NSLocalizedString(@"SETUP_POSITION_WHITE_CHECK", nil);
        }
        else if (_checkupPosition == 2) {
            cell.textLabel.text = NSLocalizedString(@"SETUP_POSITION_BLACK_CHECK", nil);
        }
        else if (_checkupPosition == 3) {
            cell.textLabel.text = NSLocalizedString(@"SETUP_POSITION_WHITE_CHECKMATED", nil);
        }
        else if (_checkupPosition == 4) {
            cell.textLabel.text = NSLocalizedString(@"SETUP_POSITION_BLACK_CHECKMATED", nil);
        }
        else if (_checkupPosition == 5) {
            cell.textLabel.text = NSLocalizedString(@"SETUP_POSITION_START_POSITION", nil);
        }
        else {
            //cell.textLabel.text = [_boardModel fenNotation];
            cell.textLabel.text = [_boardModel calcFenNotationWithNumberFirstMove];
        }
        //[_boardView removeFromSuperview];
    }
    else if (indexPath.section == 4 && indexPath.row == 0) {
        cell.textLabel.text = [_boardModel fenNotation];
        //[_boardView removeFromSuperview];
    }
    // Configure the cell...
    
    return cell;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void) saveButtonPressed {
    NSLog(@"Devo salvare definitivamente");
    SideToMoveViewController *stmvc = (SideToMoveViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    [stmvc.delegate savePositionSetup];
    [self dismissViewControllerAnimated:YES completion:nil];
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
