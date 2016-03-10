//
//  SettingsTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 08/05/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "UtilToView.h"
#import "Options.h"
#import "SettingManager.h"
#import "SWRevealViewController.h"

@interface SettingsTableViewController () {
    NSIndexPath *lastTipoPezziindexPath;
    NSIndexPath *lastCoordinateIndexPath;
    NSIndexPath *lastSquaresIndexPath;
    NSIndexPath *lastNotationIndexPath;
    
    
    NSString *pieceType;
    NSString *coordinate;
    NSString *squares;
    NSString *notation;
    NSString *vistaMotore;
    
    
    SettingManager *settingManager;
}

@end

@implementation SettingsTableViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = NSLocalizedString(@"SETTINGS", @"Titolo");
    
    if (_delegate) {
        NSString *buttonTitle = NSLocalizedString(@"DONE", @"Fatto");
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
        self.navigationItem.leftBarButtonItem = doneButtonItem;
    }
    
    settingManager = [SettingManager sharedSettingManager];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLinkCanceled:) name:@"DropboxLinkCanceled" object:nil];
    
    
    if (IsChessStudioLight) {
        //if (IS_IOS_7) {
            self.canDisplayBannerAds = YES;
        //}
    }
    
    /*
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window]rootViewController];
    
    if ([rootViewController isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *revealViewController = [self revealViewController];
        [revealViewController panGestureRecognizer];
        [revealViewController tapGestureRecognizer];
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon.png"] style:UIBarButtonItemStyleBordered target:revealViewController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }*/
    
    [self checkRevealed];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) checkRevealed {
    UIViewController *sourceViewController = self.parentViewController.parentViewController;
    if ([sourceViewController isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *revealViewController = [self revealViewController];
        [revealViewController panGestureRecognizer];
        [revealViewController tapGestureRecognizer];
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon.png"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
    //NSLog(@"%@", sourceViewController);
    //NSLog(@"%@", self.parentViewController);
    //NSLog(@"%@", self.parentViewController.parentViewController);
}

- (void) doneButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Gestione rotazione

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

//- (NSUInteger) supportedInterfaceOrientations {
    //return UIInterfaceOrientationMaskAll;
//}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (_delegate) {
        [_delegate aggiornaOrientamentoDaSettings];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        return 7;
    }
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    }
    if (section == 1) {
        return 3;
    }
    if (section == 2) {
        return [[UtilToView getEngines] count];
    }
    if (section == 3) {
        return 2;
    }
    if (section == 4) {
        return 1;
    }
    if (section == 5) {
        return 1;
    }
    if (section == 6) {
        return 1;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"PIECES&BOARD", nil);
    }
    if (section == 1) {
        return NSLocalizedString(@"SETTINGS_PIECES_MOVEMENT", nil);
    }
    if (section == 2) {
        return NSLocalizedString(@"ENGINE", nil);
    }
    if (section == 3) {
        return NSLocalizedString(@"BOOK_MOVES_OPENING", nil);
    }
    if (section == 4) {
        return NSLocalizedString(@"EMAIL_RECIPIENTS", nil);
    }
    if (section == 5) {
        return NSLocalizedString(@"DROPBOX_SETTING", nil);
    }
    if (section == 6) {
        return NSLocalizedString(@"ICLOUD_SETTING", nil);
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 ) {
        if (indexPath.row == 0 || indexPath.row == 1) {
            return 80.0;
        }
        return 44.0;
    }
    if (indexPath.section == 1 || indexPath.section == 6) {
        return 60;
    }
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Settings";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            cell.textLabel.text = nil;
            cell.imageView.image = [UIImage imageNamed:[[settingManager pieceType]lowercaseString]];
            cell.detailTextLabel.text = [settingManager pieceTypeAsString];
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            if (IS_PHONE) {
                cell.imageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
            }
            else {
                cell.imageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
            }
            cell.accessoryView = nil;
        }
        
        if (indexPath.row == 1) {
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            cell.textLabel.text = nil;
            cell.imageView.image = [UIImage imageNamed:[settingManager squares]];
            cell.detailTextLabel.text = [settingManager squaresAsString];
            
            if (IS_PHONE) {
                cell.imageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
            }
            else {
                cell.imageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
            }
            cell.accessoryView = nil;
        }
        
        if (indexPath.row == 2) {
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            cell.textLabel.text = NSLocalizedString(@"COORDINATES", nil);
            cell.imageView.image = nil;
            cell.detailTextLabel.text = [settingManager coordinate];
            cell.accessoryView = nil;
        }
        
        if (indexPath.row == 3) {
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            cell.textLabel.text = NSLocalizedString(@"MOVE_NOTATION",nil );
            cell.imageView.image = nil;
            cell.detailTextLabel.text = [settingManager notation];
            cell.accessoryView = nil;
        }
        
        if (indexPath.row == 4) {
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            cell.textLabel.text = NSLocalizedString(@"BOARD_SIZE", nil);
            cell.imageView.image = nil;
            cell.detailTextLabel.text = [settingManager boardSizeAsString];
            cell.accessoryView = nil;
        }

    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.imageView.image = nil;
            if (_delegate) {
                if ([_delegate isEngineRunning]) {
                    cell.textLabel.textColor = [UIColor redColor];
                    //cell.detailTextLabel.textColor = [UIColor redColor];
                }
                else {
                    cell.textLabel.textColor = [UIColor blackColor];
                    //cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.55 alpha:1.0];
                }
            }
            cell.textLabel.text = NSLocalizedString(@"ENGINE_VIEW", nil);
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            cell.detailTextLabel.text = [settingManager vistaMotore];
            cell.accessoryView = nil;
        }
        else if (indexPath.row == 1) {
            cell.imageView.image = nil;
            cell.detailTextLabel.text = nil;
            cell.textLabel.text = [[UtilToView getEngines] objectAtIndex:1];
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            if ([settingManager engineFigurineNotation]) {
                cell.detailTextLabel.text = NSLocalizedString(@"FIGURINE", nil);
            }
            else {
                cell.detailTextLabel.text = NSLocalizedString(@"LETTER", nil);
            }
            cell.accessoryView = nil;
        }
        else if (indexPath.row == 2) {
            cell.imageView.image = nil;
            cell.textLabel.text = [[UtilToView getEngines] objectAtIndex:2];
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            [[cell detailTextLabel] setText: [[Options sharedOptions] playStyle]];
            [cell setAccessoryView: nil];
            cell.accessoryView = nil;
        }
        else if (indexPath.row == 3) {
            cell.imageView.image = nil;
            cell.textLabel.text = [[UtilToView getEngines] objectAtIndex:3];
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            [[cell detailTextLabel] setText: [NSString stringWithFormat: @"%d", [[Options sharedOptions] strength]]];
            [cell setAccessoryView: nil];
        }
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.imageView.image = nil;
            cell.textLabel.text = NSLocalizedString(@"BOOK_OPENING", nil);
            cell.detailTextLabel.text = nil;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            //switchView.tag = 100;
            //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [switchView addTarget:self action:@selector(openingBookSwitched:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
            [switchView setOn:[settingManager showBookMoves]];
        }
        else if (indexPath.row == 1) {
            cell.imageView.image = nil;
            cell.textLabel.text = NSLocalizedString(@"ECO_OPENING", nil);
            cell.detailTextLabel.text = nil;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            //switchView.tag = 200;
            //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [switchView addTarget:self action:@selector(ecoSwitched:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
            [switchView setOn:[settingManager showEco]];
        }
    }
    
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            cell.imageView.image = nil;
            cell.textLabel.text = NSLocalizedString(@"EMAIL_TO", nil);
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = [settingManager getListaEmailRecipients];
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            cell.accessoryView = nil;
        }
    }
    
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"Dropbox"];
            cell.textLabel.text = @"Dropbox";
            cell.detailTextLabel.text = nil;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            //switchView.tag = 300;
            //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [switchView addTarget:self action:@selector(dropboxSwitched:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
            if ([[DBSession sharedSession] isLinked]) {
                [switchView setOn:YES];
            }
            else {
                [switchView setOn:NO];
            }
        }
    }
    
    if (indexPath.section == 6) {
        if (indexPath.row == 0) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CELL"];
            
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-MediumP4" size:17.0];
            
            cell.imageView.image = [UIImage imageNamed:@"CloudFolder"];
            cell.textLabel.text = NSLocalizedString(@"ICLOUD_TEXT", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"ICLOUD_DETAIL", nil);
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            //switchView.tag = 500;
            //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [switchView addTarget:self action:@selector(iCloudSwitched:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
            [switchView setOn:[settingManager iCloudOn]];
        }
    }
    
    if (indexPath.section == 1) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CELL"];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_DRAG_AND_DROP", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"SETTINNGS_DRAG_AND_DROP_DETAIL", nil);
            cell.imageView.image = nil;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            //switchView.tag = 400;
            //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [switchView addTarget:self action:@selector(dragAndDropSwitched:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
            [switchView setOn:[settingManager dragAndDrop]];
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_TAP_ARRIVAL_SQUARE", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"SETTINGS_TAP_ARRIVAL_SQUARE_DETAIL", nil);
            cell.imageView.image = nil;
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            //UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            //switchView.tag = 403;
            //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
            //cell.accessoryView = switchView;
            //[switchView setOn:[settingManager tapDestination]];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_TAP_PIECE", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"SETTINGS_TAP_PIECE_DETAIL", nil);
            cell.imageView.image = nil;
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            cell.accessoryView = nil;
            //UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            //switchView.tag = 401;
            //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
            //cell.accessoryView = switchView;
            //[switchView setOn:[settingManager tapPieceToMove]];
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_COLOR_HIGHLIGHT", nil);
            cell.detailTextLabel.text = @"Colori per evidenziare il movimento dei pezzi";
            cell.imageView.image = nil;
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            cell.accessoryView = nil;
        }
        
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-MediumP4" size:17.0];
    }
    
    return cell;
}

- (void) updateSwitch:(UISwitch *)switchView {
    
    if ([switchView isOn] && IsChessStudioLight && switchView.tag == 100) {
        UIAlertView *lightAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"LIGHT_OPENING_BOOK", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"OK", nil];
        lightAlertView.tag = 1000;
        [lightAlertView show];
        [switchView setOn:NO];
        return;
    }
    
    if ([switchView isOn] && IsChessStudioLight && switchView.tag == 200) {
        UIAlertView *lightAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"LIGHT_SHOW_ECO", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"OK", nil];
        lightAlertView.tag = 1000;
        [lightAlertView show];
        [switchView setOn:NO];
        return;
    }
    
    
    if (switchView.tag == 100) {
        [settingManager setShowBookMoves:[switchView isOn]];
        if (_delegate) {
            [_delegate modifyShowBookMoves];
        }
    }
    else if (switchView.tag == 200) {
        [settingManager setShowEco:[switchView isOn]];
        if (_delegate) {
            [_delegate modifyShowEco];
        }
    }
    else if (switchView.tag == 300) {
        if ([switchView isOn]) {
            //NSLog(@"Devo Attivare Dropbox");
            [[DBSession sharedSession] linkFromController:self];
        }
        else {
            //NSLog(@"Devo disattivare Dropbox");
            [[DBSession sharedSession] unlinkAll];
        }
    }
    else if (switchView.tag == 400) {
        [settingManager setDragAndDrop:[switchView isOn]];
    }
    //else if (switchView.tag == 401) {
    //    [settingManager setTapPieceToMove:[switchView isOn]];
    //}
    //else if (switchView.tag == 402) {
    //    [settingManager setShowLegalMoves:[switchView isOn]];
    //}
    else if (switchView.tag == 403) {
        [settingManager setTapDestination:[switchView isOn]];
    }
    else if (switchView.tag == 500) {
        [settingManager setICloudOn:[switchView isOn]];
    }
}

- (void) dropboxLinkCanceled:(id)sender {
    [self.tableView reloadData];
}

- (void) dragAndDropSwitched:(UISwitch *)switchView {
    [settingManager setDragAndDrop:[switchView isOn]];
}

- (void) openingBookSwitched:(UISwitch *)switchView {
    if ([switchView isOn] && IsChessStudioLight) {
        UIAlertView *lightAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"LIGHT_OPENING_BOOK", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"OK", nil];
        lightAlertView.tag = 1000;
        [lightAlertView show];
        [switchView setOn:NO];
        return;
    }
    
    [settingManager setShowBookMoves:[switchView isOn]];
    if (_delegate) {
        [_delegate modifyShowBookMoves];
    }
}

- (void) ecoSwitched:(UISwitch *)switchView {
    if ([switchView isOn] && IsChessStudioLight) {
        UIAlertView *lightAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"LIGHT_SHOW_ECO", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"OK", nil];
        lightAlertView.tag = 1000;
        [lightAlertView show];
        [switchView setOn:NO];
        return;
    }
    
    [settingManager setShowEco:[switchView isOn]];
    if (_delegate) {
        [_delegate modifyShowEco];
    }
}

- (void) iCloudSwitched:(UISwitch *)switchView {
    [settingManager setICloudOn:[switchView isOn]];
}

- (void) dropboxSwitched:(UISwitch *)switchView {
    if ([switchView isOn]) {
        //NSLog(@"Devo Attivare Dropbox");
        [[DBSession sharedSession] linkFromController:self];
    }
    else {
        //NSLog(@"Devo disattivare Dropbox");
        [[DBSession sharedSession] unlinkAll];
    }
}

/*
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            if ([_delegate isEngineRunning]) {
                [cell setBackgroundColor:[[UIColor alloc] initWithRed:255.0/255 green:59.0/255 blue:48.0/255 alpha:1.0]];
            }
            else {
                [cell setBackgroundColor:[[UIColor alloc] initWithRed:76.0/255 green:217.0/255 blue:100.0/255 alpha:1.0]];
            }
        }
    }
}
*/

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
    
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //if ([cell accessoryType] == UITableViewCellAccessoryCheckmark) {
        //return;
    //}
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            PieceStyleTableViewController *pstvc = [[PieceStyleTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            pstvc.delegate = self;
            [self.navigationController pushViewController:pstvc animated:YES];
            return;
        }
        else if (indexPath.row == 1) {
            SquaresStyleTableViewController *sstvc = [[SquaresStyleTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            sstvc.delegate = self;
            [self.navigationController pushViewController:sstvc animated:YES];
            return;
        }
        else if (indexPath.row == 2) {
            CoordinateTableViewController *cctvc = [[CoordinateTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            cctvc.delegate = self;
            [self.navigationController pushViewController:cctvc animated:YES];
            return;
        
        }
        else if (indexPath.row == 3) {
            MovesNotationTableViewController *mntvc = [[MovesNotationTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            mntvc.delegate = self;
            [self.navigationController pushViewController:mntvc animated:YES];
            return;
        }
        else if (indexPath.row == 4) {
            BoardSizeTableViewController *bstvc = [[BoardSizeTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            bstvc.delegate = self;
            [self.navigationController pushViewController:bstvc animated:YES];
            return;
        }
    }
    
    if (indexPath.section == 2) {
        
        
        if (IsChessStudioLight && ![_delegate getStartFenPosition]) {
            UIAlertView *lightAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"LIGHT_STOCKFISH", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"OK", nil];
            lightAlertView.tag = 1000;
            [lightAlertView show];
            return;
        }
        
        if (indexPath.row == 0) {
            EngineViewTableViewController *evtvc = [[EngineViewTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [evtvc setDelegate:self];
            [self.navigationController pushViewController:evtvc animated:YES];
        }
        else if (indexPath.row == 1) {
            EngineNotationTableViewController *entvc = [[EngineNotationTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            entvc.delegate = self;
            [self.navigationController pushViewController:entvc animated:YES];
        }
        else if (indexPath.row == 2) {
            PlayStyleOptionTableViewController *pstvc = [[PlayStyleOptionTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            pstvc.delegate = self;
            [self.navigationController pushViewController:pstvc animated:YES];
        }
        else if (indexPath.row == 3) {
            PlayStrengthViewController *psvc = [[PlayStrengthViewController alloc] initWithNibName:nil bundle:nil];
            psvc.delegate = self;
            [self.navigationController pushViewController:psvc animated:YES];
        }
    }
    
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            EmailRecipientsTableViewController *ertvc = [[EmailRecipientsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            ertvc.delegate = self;
            [self.navigationController pushViewController:ertvc animated:YES];
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            TapOnPieceTableViewController *toptvc = [[TapOnPieceTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            if (_delegate) {
                [toptvc setDoneButton:YES];
            }
            else {
                [toptvc setDoneButton:NO];
            }
            [self.navigationController pushViewController:toptvc animated:YES];
        }
        else if (indexPath.row == 2) {
            TapOnArrivalTableViewController *toatvc = [[TapOnArrivalTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            if (_delegate) {
                [toatvc setDoneButton:YES];
            }
            else {
                [toatvc setDoneButton:NO];
            }
            [self.navigationController pushViewController:toatvc animated:YES];
        }
        else if (indexPath.row == 3) {
            ColorsTableViewController *ctvc = [[ColorsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            if (_delegate) {
                [ctvc setDoneButton:YES];
            }
            else {
                [ctvc setDoneButton:NO];
            }
            [self.navigationController pushViewController:ctvc animated:YES];
        }
    }
    
}

/*
- (void) aggiornaEngineViewInTable {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    vistaMotore = [defaults objectForKey:@"engine"];
    if ([vistaMotore isEqualToString:@"closed"]){
        cell.detailTextLabel.text = NSLocalizedString(@"ENGINE_VIEW_CLOSED", nil);
    }
    else {
        cell.detailTextLabel.text = NSLocalizedString(@"ENGINE_VIEW_OPEN", nil);
    }
    if (_delegate) {
        if ([_delegate isEngineViewOpened]) {
            [_delegate chiudiVistaMotore];
        }
        else {
            [_delegate apriVistaMotore];
        }
    }
}
*/

- (void) aggiornaPlayStyleInTable {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [[cell detailTextLabel] setText: [[Options sharedOptions] playStyle]];
}

- (void) aggiornaPlayStrengthInTable {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [[cell detailTextLabel] setText: [NSString stringWithFormat: @"%d", [[Options sharedOptions] strength]]];
}

- (void) updateFromPieceStyle {
    if (_delegate) {
        [_delegate modifyPiecesType];
    }
}

- (void) updateFromSquaresStyle {
    if (_delegate) {
        [_delegate modifyBoardSquares];
    }
}

- (void) updateFromCoordinate {
    if (_delegate) {
        [_delegate modifyCoordinates];
    }
}

- (void) updateFromMovesNotation {
    if (_delegate) {
        [_delegate modifyMoveNotation];
    }
}

- (void) updateFromBoardSize {
    if (_delegate) {
        [_delegate modifyBoardSize];
    }
}

- (void) updateFromEngineView {
    if (_delegate) {
        [_delegate modifyVistaMotore];
    }
}


- (void) aggiornaEngineNotationInTable {
    //NSLog(@"AGGIORNO ENGINE NOTATION IN TABLE");
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    if ([[Options sharedOptions] figurineNotation]) {
        cell.detailTextLabel.text = NSLocalizedString(@"FIGURINE", nil);
    }
    else {
        cell.detailTextLabel.text = NSLocalizedString(@"LETTER", nil);
    }
}

#pragma mark - Metodo delegate di EmailRecipientsInTable

- (void) aggiornaEmailRecipientsInTable:(NSDictionary *)emailRecipients {
    [settingManager addEmailRecipients:emailRecipients];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Gestione ChessStudioLight Stockfish non presente
    if (alertView.tag == 1000) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"CHESS_STUDIO_APP_STORE", nil)]];
        }
    }
}

#pragma mark - Metodi per la gestione dei parametri di defaults

- (void) modifyPiecesType:(NSString *)piecesType {
    if ([piecesType hasPrefix:@"Has"]) {
        piecesType = @"has96";
    }
    else if ([piecesType hasPrefix:@"Con"]) {
        piecesType = @"condal96";
    }
    else if ([piecesType hasPrefix:@"Lin"]) {
        piecesType = @"lin96";
    }
    else if ([piecesType hasPrefix:@"Adv"]) {
        piecesType = @"adventurer96";
    }
    else {
        piecesType = @"zur96";
    }
    if ([piecesType isEqualToString:pieceType]) {
        return;
    }
    pieceType = piecesType;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:pieceType forKey:@"pieces"];
    [defaults synchronize];
}

- (void) modifyCoordinates:(NSString *)coordinates {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:coordinates forKey:@"coordinate"];
    [defaults synchronize];
}

- (void) modifyBoardSquares:(NSString *)tipoSquares {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([tipoSquares isEqualToString:@"Wood"]) {
        [defaults setObject:@"square1" forKey:@"squares"];
    }
    else if ([tipoSquares isEqualToString:@"Marble"]) {
        [defaults setObject:@"square2" forKey:@"squares"];
    }
    else if ([tipoSquares isEqualToString:@"Wood 2"]) {
        [defaults setObject:@"square3" forKey:@"squares"];
    }
    else if ([tipoSquares isEqualToString:@"Texture"]) {
        [defaults setObject:@"square4" forKey:@"squares"];
    }
    else if ([tipoSquares isEqualToString:@"Wood 3"]) {
        [defaults setObject:@"square5" forKey:@"squares"];
    }
    else if ([tipoSquares isEqualToString:@"DarkLight"]) {
        [defaults setObject:@"square6" forKey:@"squares"];
    }
    [defaults synchronize];
}

- (void) modifyMoveNotation:(NSInteger)moveNotation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *newNotation = [NSString stringWithFormat:@"%ld", (long)moveNotation];
    [defaults setObject:newNotation forKey:@"notation"];
    [defaults synchronize];
}

@end
