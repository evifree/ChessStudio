//
//  PgnFileInfoTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 05/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PgnFileInfoTableViewController.h"
#import "PgnFileInfo.h"
#import "PgnResultGamesTableViewController.h"
#import "PgnResultGameByEventTableViewController.h"
#import "EventTableViewController.h"
#import "OpeningTableViewController.h"
#import "EcoTableViewController.h"
#import "PlayerTableViewController.h"
#import "MBProgressHUD.h"
#import "BoardModel.h"
#import "BoardViewController.h"
#import "TBPgnFileTableViewController.h"
#import "UtilToView.h"
#import "DateTableViewController.h"
#import "GameByYearsTableViewController.h"
#import "GamesByYearsByEventTableViewController.h"
#import "PGNPastedGame.h"
#import "PgnPastedGameTableViewController.h"

#import "ECO.h"

#import "PGNParser.h"
#import "PGNAnalyzer.h"

#import <mach/mach.h>

@interface PgnFileInfoTableViewController () {

    UITextField *tfDbName;
    
    //PgnFileInfo *pgnFileInfo;
    
    NSArray *result;
    //UIAlertView *alertView;
    
    UIActionSheet *actionSheetMenu;
    
    BOOL eseguiReload;
}

@end

@implementation PgnFileInfoTableViewController

//@synthesize pgnFileInfo = _pgnFileInfo;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    //NSLog(@"PATH DEL File = %@", _pgnFileDoc.pgnFileInfo.path);
    //NSRange range = [_pgnFileDoc.pgnFileInfo.path rangeOfString:@"/Library/Caches/twic/"];
    //NSLog(@"Range Location = %d   Range length = %d", range.location, range.length);
    if ([_pgnFileDoc.pgnFileInfo.path rangeOfString:@"/Library/Caches/twic/"].location == NSNotFound) {
        UIBarButtonItem *actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
        self.navigationItem.rightBarButtonItem = actionBarButtonItem;
    }
    eseguiReload = NO;
    
    
    if (IS_IOS_7) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
    
    if (IsChessStudioLight) {
        if (IS_IOS_7) {
            self.canDisplayBannerAds = YES;
        }
    }
    
    
    if (_pgnFileDoc.pgnFileInfo.isInCloud) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.navigationItem.title = _pgnFileInfo.personalFileName;
    self.navigationItem.title = _pgnFileDoc.pgnFileInfo.personalFileName;
    if (eseguiReload) {
        [self.tableView reloadData];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        if (actionSheetMenu) {
            [actionSheetMenu dismissWithClickedButtonIndex:-1 animated:YES];
            actionSheetMenu = nil;
        }
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //if (alertView) {
    //    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    //}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Ho ricevuto un memory warning");
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) setPgnFileDoc:(PgnFileDocument *)pgnFileDoc {
    _pgnFileDoc = pgnFileDoc;
    /*
    if (!_pgnFileDoc.pgnFileInfo) {
        [_pgnFileDoc openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"Ho aperto PgnFileDocument");
                //[self.tableView reloadData];
            }
        }];
    }*/
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 1;
    }
    if (section == 2) {
        return 1;
    }
    if (section == 3) {
        return 5;
    }
    if (section == 4) {
        return 3;
    }
    if (section == 5) {
        return 3;
    }
    if (section == 6) {
        return _pgnFileDoc.pgnFileInfo.listOfEco.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell PgnFileInfo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    if (indexPath.section == 0) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        //cell.textLabel.text = [_pgnFileInfo personalFileName];
        cell.textLabel.text = @"";
        //NSLog(@"Dati Textklabel   %f   %f   %f   %f", cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width, cell.textLabel.frame.size.height);
        tfDbName = [[UITextField alloc] initWithFrame:CGRectMake(55.0f, 10.0f, 300.0f, 20.0f)];
        //tfDbName = [[UITextField alloc] initWithFrame:CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, 200, 30)];
        [tfDbName addTarget:self action:@selector(tfDbInputDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
        tfDbName.font = [UIFont boldSystemFontOfSize:17.0];
        tfDbName.adjustsFontSizeToFitWidth = YES;
        tfDbName.textColor = [UIColor blackColor];
        tfDbName.text = [_pgnFileDoc.pgnFileInfo personalFileName];
        //tfDbName.backgroundColor = [UIColor lightTextColor];
        tfDbName.textAlignment = NSTextAlignmentLeft;
        tfDbName.keyboardType = UIKeyboardTypeDefault;
        tfDbName.returnKeyType = UIReturnKeyDone;
        tfDbName.clearsOnBeginEditing = YES;
        cell.textLabel.text = _pgnFileDoc.pgnFileInfo.personalFileName;
        //[cell addSubview:tfDbName];
    }
    /*
    if (indexPath.section == 1) {
        cell.textLabel.text = [_pgnFileDoc.pgnFileInfo fileName];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    }
    */
    
    if (indexPath.section == 1) {
        NSString *nog = [NSString stringWithFormat:@"%d", _pgnFileDoc.pgnFileInfo.numberOfGames.intValue];
        cell.textLabel.text = nog;
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    }
    if (indexPath.section == 2) {
        //cell.textLabel.text = [_pgnFileDoc.pgnFileInfo getDataCreazione];
        //cell.textLabel.text = [_pgnFileDoc.pgnFileInfo getDateInfo];
        cell.textLabel.text = [_pgnFileDoc.pgnFileInfo getDateDimInfo];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    }
    if (indexPath.section == 3) {
        //cell.textLabel.text = [result objectAtIndex:indexPath.row];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"GAMES_GAME_INFO", nil);
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"EVENTS_GAME_INFO", nil);
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        /*
        if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"OPENINGS_GAME_INFO", nil);
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }*/
        if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"OPENINGS_ECO_GAME_INFO", nil);
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"PLAYERS_GAME_INFO", nil);
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"DATE_GAME_INFO", nil);
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
    }
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"GAMES_BY_EVENTS_INFO", nil);
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"GAMES_BY_YEARS_INFO", nil);
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"EVENTS_BY_YEARS_INFO", nil);
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
        
    }
    if (indexPath.section == 6) {
        cell.textLabel.text = [_pgnFileDoc.pgnFileInfo.listOfEco objectAtIndex:indexPath.row];
    }
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSMutableString *header = [[NSMutableString alloc] init];
    if (IS_IOS_7) {
        [header appendString:@"   "];
    }
    
    
    if (section == 0) {
        [header appendString:NSLocalizedString(@"DBNAME", @"Nome del Database")];
        return header;
    }
    if (section == 1) {
        [header appendString:NSLocalizedString(@"NGAMESDB", @"Numero partite DB")];
        return header;
    }
    if (section == 2) {
        [header appendString:NSLocalizedString(@"CREATION_DATE + DATABASE SIZE", @"Data creazione")];
        return header;
    }
    if (section == 3) {
        [header appendString:NSLocalizedString(@"SEARCH_BY", @"Search by..")];
        return header;
    }
    if (section == 4) {
        [header appendString:NSLocalizedString(@"ADVANCED_RESEARCH", @"Ricerche avanzate")];
        return header;
    }
    if (section == 6) {
        return @"ECO";
    }
    return nil;
}

- (void) tfDbInputDone:(id)sender {
    [sender resignFirstResponder];
    UITextField *tf = sender;
    NSString *valueInserted = [tf text];
    if ([valueInserted isEqualToString:@""]) {
        valueInserted = [_pgnFileDoc.pgnFileInfo personalFileName];
    }
    else {
        [_pgnFileDoc.pgnFileInfo setPersonalFileName:valueInserted];
    }
    [tf setText:@""];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void) keyBoardWillHide {
    //NSLog(@"KeyBoardWillHide");
    NSString *valueInserted = [tfDbName text];
    if ([valueInserted isEqualToString:@""]) {
        valueInserted = [_pgnFileDoc.pgnFileInfo personalFileName];
    }
    else {
        [_pgnFileDoc.pgnFileInfo setPersonalFileName:valueInserted];
    }
    [tfDbName setText:@""];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
    
    if (_pgnFileDoc.pgnFileInfo.numberOfGames.intValue == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UIAlertView *noGamesAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"NO_GAMES_DATABASE", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noGamesAlertView show];
        return;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.minSize = [UtilToView getSizeOfMBProgress];
            hud.labelText = @"Loading ...";
            hud.detailsLabelText = _pgnFileDoc.pgnFileInfo.fileName;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
                TBPgnFileTableViewController *tpftvc = [sb instantiateViewControllerWithIdentifier:@"TBPgnFileTableViewController"];
                [tpftvc setPgnFileDoc:_pgnFileDoc];
                
                if (IS_PHONE) {
                    if (IS_IOS_7) {
                        self.navigationItem.title = @"";
                    }
                    else {
                        self.navigationItem.title = NSLocalizedString(@"BACK", nil);
                    }
                }
                
                [self.navigationController pushViewController:tpftvc animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            return;
        }
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //NSString *version = [[UIDevice currentDevice] systemVersion];
    
    if (indexPath.section == 3) {
        
        NSArray *tagArray;
        
        if (indexPath.row == 0) {
            tagArray = [NSArray arrayWithObjects:@"White ", @"Black ", @"Result ", nil];
        }
        if (indexPath.row == 1) {
            tagArray = [NSArray arrayWithObjects:@"Event ", @"Site ", nil];
        }
        //if (indexPath.row == 2) {
        //    tagArray = [NSArray arrayWithObjects:@"ECO ",@"Opening ", @"Variation ", @"Subvariation ", nil];
        //}
        if (indexPath.row == 2) {
            tagArray = [NSArray arrayWithObjects:@"ECO ", nil];
        }
        if (indexPath.row == 3) {
            tagArray = [NSArray arrayWithObjects:@"White ", @"Black ", @"WhiteTitle ",@"BlackTitle ", @"WhiteElo ", @"BlackElo ", @"WhiteFideId ", @"BlackFideId ", @"WhiteUSCF ", @"BlackUSCF ", @"WhiteType ", @"BlackType ", @"WhiteNA ", @"BlackNA ", nil];
        }
        if (indexPath.row == 4) {
            tagArray = [NSArray arrayWithObjects:@"Date", nil];
        }
        
        NSString *title = cell.textLabel.text;
        //alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        //UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(130, 50, 25, 25)];
        //progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        //[progress performSelectorInBackground:@selector(startAnimating) withObject:self];
        //[self.tableView addSubview:progress];
        //[alertView addSubview:progress];
        //[progress startAnimating];
        
        
        //if (![version hasPrefix:@"6"]) {
        //    [alertView performSelectorInBackground:@selector(show) withObject:nil];
        //}

        
        //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
        UIStoryboard *sb = [UtilToView getStoryBoard];
        
        if (indexPath.row == 0) {
            //result = [pgnFileInfo getAllGames];
            
            eseguiReload = YES;
            
            PgnResultGamesTableViewController *prgtvc = [sb instantiateViewControllerWithIdentifier:@"PgnResultGames"];
            
            //[prgtvc setGames:result];
            //dispatch_queue_t thread = dispatch_queue_create("GetAllGames", NULL);
            //dispatch_async(thread, ^{
                //[prgtvc setPgnFileDoc:_pgnFileDoc];
                //[alertView dismissWithClickedButtonIndex:0 animated:YES];
                //[self.navigationController pushViewController:prgtvc animated:YES];
            //});
            
            /*
            [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                // Do something...
                [prgtvc setPgnFileDoc:_pgnFileDoc];
                [self.navigationController pushViewController:prgtvc animated:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            });
            */
            
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.minSize = [UtilToView getSizeOfMBProgress];
            hud.labelText = @"Loading ...";
            hud.detailsLabelText = title;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [prgtvc setPgnFileDoc:_pgnFileDoc];
                if (IS_IOS_7) {
                    self.navigationItem.title = @"";
                }
                else {
                    self.navigationItem.title = NSLocalizedString(@"BACK", nil);
                }
                [self.navigationController pushViewController:prgtvc animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
            /*
            [alertView show];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [prgtvc setPgnFileDoc:_pgnFileDoc];
                [self.navigationController pushViewController:prgtvc animated:YES];
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
            });
            */ 
        }
        
        if (indexPath.row == 1) {
            //NSArray *allEvents = [pgnFileInfo getAllEvents];
            EventTableViewController *etvc = [sb instantiateViewControllerWithIdentifier:@"EventTable"];
            //[etvc setEventArray:allEvents];
            eseguiReload = YES;
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.minSize = [UtilToView getSizeOfMBProgress];
            hud.labelText = @"Loading ...";
            hud.detailsLabelText = title;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [etvc setPgnFileDoc:_pgnFileDoc];
                if (IS_IOS_7) {
                    self.navigationItem.title = @"";
                }
                else {
                    self.navigationItem.title = NSLocalizedString(@"BACK", nil);
                }
                [self.navigationController pushViewController:etvc animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
        }
        
        /*
        if (indexPath.row == 2) {
            //NSArray *allEco = [pgnFileInfo getAllEco];
            OpeningTableViewController *otvc = [sb instantiateViewControllerWithIdentifier:@"OpeningTable"];
            //[otvc setOpeningArray:allEco];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.minSize = [UtilToView getSizeOfMBProgress];
            hud.labelText = @"Loading ...";
            hud.detailsLabelText = title;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [otvc setPgnFileDoc:_pgnFileDoc];
                if (IS_PHONE) {
                    self.navigationItem.title = NSLocalizedString(@"BACK", nil);
                }
                [self.navigationController pushViewController:otvc animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }*/
        
        if (indexPath.row == 2) {
            //sleep(5);
            EcoTableViewController *etvc = [sb instantiateViewControllerWithIdentifier:@"EcoTableViewController"];
            eseguiReload = YES;
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.minSize = [UtilToView getSizeOfMBProgress];
            hud.labelText = @"Loading ...";
            hud.detailsLabelText = title;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [etvc setPgnFileDoc:_pgnFileDoc];
                if (IS_IOS_7) {
                    self.navigationItem.title = @"";
                }
                else {
                    self.navigationItem.title = NSLocalizedString(@"BACK", nil);
                }
                [self.navigationController pushViewController:etvc animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
        }
        
        if (indexPath.row == 3) {
            PlayerTableViewController *ptvc = [sb instantiateViewControllerWithIdentifier:@"PlayerTableViewController"];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.minSize = [UtilToView getSizeOfMBProgress];
            hud.labelText = @"Loading ...";
            hud.detailsLabelText = title;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [ptvc setPgnFileDoc:_pgnFileDoc];
                if (IS_IOS_7) {
                    self.navigationItem.title = @"";
                }
                else {
                    self.navigationItem.title = NSLocalizedString(@"BACK", nil);
                }
                [self.navigationController pushViewController:ptvc animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
        
        if (indexPath.row == 4) {
            //DateTableViewController *dtvc = [[DateTableViewController alloc] initWithStyle:UITableViewStylePlain];
            DateTableViewController *dtvc = [sb instantiateViewControllerWithIdentifier:@"DateTableViewController"];
            eseguiReload = YES;
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.minSize = [UtilToView getSizeOfMBProgress];
            hud.labelText = @"Loading ...";
            hud.detailsLabelText = title;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [dtvc setPgnFileDoc:_pgnFileDoc];
                if (IS_IOS_7) {
                    self.navigationItem.title = @"";
                }
                else {
                    self.navigationItem.title = NSLocalizedString(@"BACK", nil);
                }
                [self.navigationController pushViewController:dtvc animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
        
        
        
        //[alertView dismissWithClickedButtonIndex:0 animated:YES];
        
        
        return;
    }
    
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            
            NSString *title = cell.textLabel.text;
            //alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            //UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(130, 50, 25, 25)];
            //progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            //[progress performSelectorInBackground:@selector(startAnimating) withObject:self];
            //[alertView addSubview:progress];

            
            //if (![version hasPrefix:@"6"]) {
            //    [alertView performSelectorInBackground:@selector(show) withObject:nil];
            //}
            

            
            //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
            UIStoryboard *sb = [UtilToView getStoryBoard];
            PgnResultGameByEventTableViewController *prgetvc = [sb instantiateViewControllerWithIdentifier:@"PgnGamesByEvent"];
            
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.minSize = [UtilToView getSizeOfMBProgress];
            hud.labelText = @"Loading ...";
            hud.detailsLabelText = title;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [prgetvc setPgnFileDoc:_pgnFileDoc];
                if (IS_IOS_7) {
                    self.navigationItem.title = @"";
                }
                else {
                    self.navigationItem.title = NSLocalizedString(@"BACK", nil);
                }
                [self.navigationController pushViewController:prgetvc animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
            //[resultGamesByEvent setEvents:events];
            //[resultGamesByEvent setGamesByEvent:eventGames]
            
            
            //[alertView dismissWithClickedButtonIndex:0 animated:YES];
            
            
            return;
        }
        if (indexPath.row == 1) {
            
            NSString *title = cell.textLabel.text;
            
            UIStoryboard *sb = [UtilToView getStoryBoard];
            GameByYearsTableViewController *gytvc = [sb instantiateViewControllerWithIdentifier:@"GameByYearsTableViewController"];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.minSize = [UtilToView getSizeOfMBProgress];
            hud.labelText = @"Loading ...";
            hud.detailsLabelText = title;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [gytvc setPgnFileDoc:_pgnFileDoc];
                if (IS_IOS_7) {
                    self.navigationItem.title = @"";
                }
                else {
                    self.navigationItem.title = NSLocalizedString(@"BACK", nil);
                }
                [self.navigationController pushViewController:gytvc animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            return;
        }
        
        if (indexPath.row == 2) {
            NSString *title = cell.textLabel.text;
            
            UIStoryboard *sb = [UtilToView getStoryBoard];
            GamesByYearsByEventTableViewController *gbybetvc = [sb instantiateViewControllerWithIdentifier:@"GamesByYearsByEventTableViewController"];
            
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.minSize = [UtilToView getSizeOfMBProgress];
            hud.labelText = @"Loading ...";
            hud.detailsLabelText = title;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [gbybetvc setPgnFileDoc:_pgnFileDoc];
                if (IS_IOS_7) {
                    self.navigationItem.title = @"";
                }
                else {
                    self.navigationItem.title = NSLocalizedString(@"BACK", nil);
                }
                [self.navigationController pushViewController:gbybetvc animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            return;
        }
    }
    
}


//metodo actionButtonPressed
- (void) actionButtonPressed:(UIBarButtonItem *) sender {
    if (actionSheetMenu.window ) {
        [actionSheetMenu dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    
    NSString *cancelButton;
    
    if (IS_PAD) {
        cancelButton = @"";
    }
    else {
        cancelButton = NSLocalizedString(@"ACTIONSHEET_CANCEL", nil);
    }
    
    actionSheetMenu = [[UIActionSheet alloc] init];
    
    //actionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_NEW_GAME", nil), NSLocalizedString(@"MENU_NEW_POSITION", nil), nil];
    
    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_NEW_GAME", nil)];
    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_NEW_POSITION", nil)];
    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_PASTE_GAME", nil)];
    //[actionSheetMenu addButtonWithTitle:@"Classifica by ECO"];
    //[actionSheetMenu addButtonWithTitle:@"Classifica ECO parziale"];
    //[actionSheetMenu addButtonWithTitle:@"Remove ECO Tags"];
    //[actionSheetMenu addButtonWithTitle:@"Find games with positions"];
    actionSheetMenu.delegate = self;
    
    actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
    
    [actionSheetMenu showFromBarButtonItem:button animated:YES];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex<0) {
        return;
    }
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"MENU_NEW_GAME", nil)]) {
        //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
        UIStoryboard *sb = [UtilToView getStoryBoard];
        BoardViewController *bvc = [sb instantiateViewControllerWithIdentifier:@"BoardViewController"];
        bvc.delegate = self;
        eseguiReload = YES;
        [bvc setPgnFileDoc:_pgnFileDoc];
        bvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:bvc];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self presentModalViewController:boardNavigationController animated:YES];
            [self presentViewController:boardNavigationController animated:YES completion:nil];
        });
        //[self presentModalViewController:boardNavigationController animated:YES];
        return;
    }
    
    if ([title isEqualToString:NSLocalizedString(@"MENU_NEW_POSITION", nil)]) {
        //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
        UIStoryboard *sb = [UtilToView getStoryBoard];
        BoardViewController *bvc = [sb instantiateViewControllerWithIdentifier:@"BoardViewController"];
        [bvc setDelegate:self];
        eseguiReload = YES;
        [bvc setPgnFileDoc:_pgnFileDoc];
        [bvc setSetupPosition:YES];
        UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:bvc];
        bvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self presentModalViewController:boardNavigationController animated:YES];
            [self presentViewController:boardNavigationController animated:YES completion:nil];
        });
        //[self presentModalViewController:boardNavigationController animated:YES];
        return;
    }
    
    if ([title isEqualToString:NSLocalizedString(@"MENU_PASTE_GAME", nil)]) {
        [self managePasteGame];
        return;
    }
    
    if ([title isEqualToString:@"Classifica by ECO"]) {
        if (actionSheet.window ) {
            [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
            actionSheet = nil;
        }
        
        //EcoClassificator *ecoClassificator = [EcoClassificator sharedEcoClassificator];
        //EcoClassificator *ecoClassificator = [[EcoClassificator alloc] init];
        //[ecoClassificator setPgnFileDoc:_pgnFileDoc];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.minSize = [UtilToView getSizeOfMBProgress];
        hud.labelText = @"Sto Classificando ...";
        //hud.detailsLabelText = title;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            //[ecoClassificator startClassifcationByDatabase];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    
    if ([title isEqualToString:@"Classifica ECO parziale"]) {
        if (actionSheet.window ) {
            [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
            actionSheet = nil;
        }
        
        long numGames = [[_pgnFileDoc.pgnFileInfo getAllGamesAndTags] count];
        long numPassi = numGames/100;
        long resto = numGames%100;
        
        NSLog(@"numPassi = %ld", numPassi);
        NSLog(@"Resto = %ld", resto);
        
        //return;
        
        //EcoClassificator *ecoClassificator = [[EcoClassificator alloc] init];
       // EcoClassificator *ecoClassificator = [EcoClassificator sharedEcoClassificator];
        //[ecoClassificator setPgnFileDoc:_pgnFileDoc];
        
        for (int n = 0; n<=numPassi; n++) {
            int max = n*100 + 99;
            
            if (n == numPassi) {
                max = (int)(n*100 + resto - 1);
            }
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.minSize = [UtilToView getSizeOfMBProgress];
            hud.labelText = @"Sto Classificando ...";
            //hud.detailsLabelText = title;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                //[ecoClassificator startClassifcationByDatabaseFrom:min to:max];
                sleep(10);
                NSLog(@"numero partite classificate:%d", n*100);
                [self report_memory];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
        
        return;
    }
    
    if ([title isEqualToString:@"Remove ECO Tags"]) {
        if (actionSheet.window ) {
            [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
            actionSheet = nil;
        }
        
        //EcoClassificator *ecoClassificator = [[EcoClassificator alloc] init];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.minSize = [UtilToView getSizeOfMBProgress];
        hud.labelText = @"Sto Rimuovendo ...";
        //hud.detailsLabelText = title;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            //[ecoClassificator removeEcoTagsInDatabase:_pgnFileDoc];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        //ecoClassificator = nil;
        return;
    }
    
    
    if ([title isEqualToString:@"Find games with positions"]) {
        if (actionSheet.window ) {
            [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
            actionSheet = nil;
        }
        
        __block NSArray *foundGames;

        //EcoClassificator *ecoClassificator = [[EcoClassificator alloc] init];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.minSize = [UtilToView getSizeOfMBProgress];
        hud.labelText = @"Sto cercando ...";
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //foundGames = [ecoClassificator findGamesByPosition:fen InDatabase:_pgnFileDoc];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"Trovate %lu partite", (unsigned long)foundGames.count);
        });
        //ecoClassificator = nil;
        return;
    }
    
}

- (void) managePasteGame {
    
    if (IsChessStudioLight) {
        UIAlertView *lightAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"LIGHT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"OK", nil];
        lightAlertView.tag = 1000;
        [lightAlertView show];
        return;
    }
    
    UIStoryboard *sb;
    if (IS_PAD) {
        sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    }
    else {
        sb = [UIStoryboard storyboardWithName:@"iPhone" bundle:[NSBundle mainBundle]];
    }
    
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    if (pasteBoard.string.length == 0) {
        UIAlertView *noGamesToPast = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"EMPTY_CLIPBOARD", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [noGamesToPast show];
        return;
    }
    
    //UINavigationController *pastedGameNavigationController = [sb instantiateViewControllerWithIdentifier:@"PgnPastedGameNavigationController"];
    //PgnPastedGameViewController *ppgvc = (PgnPastedGameViewController *)[pastedGameNavigationController visibleViewController];
    //ppgvc.delegate = self;
    //[ppgvc setCallingViewController:[self.class description]];
    //[self presentViewController:pastedGameNavigationController animated:YES completion:nil];
    
    UINavigationController *pastedGameNavigationController = [sb instantiateViewControllerWithIdentifier:@"PgnPastedGameTableNavigationController"];
    PgnPastedGameTableViewController *ppgtvc = (PgnPastedGameTableViewController *)[pastedGameNavigationController visibleViewController];
    [ppgtvc setCallingViewController:[self.class description]];
    [ppgtvc setDelegate:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:pastedGameNavigationController animated:YES completion:nil];
    });
    //[self presentViewController:pastedGameNavigationController animated:YES completion:nil];
    
}

#pragma mark - Implementazione metodi BoardViewControllerDelegate

- (void) updateFileInfo {
    //NSLog(@"Ho chiamato updateFileInfo");
    [self.tableView reloadData];
}

#pragma mark - Implementazione metodi PgnPastedGameViewControllerDelegate

- (void) saveGames:(NSArray *)pastedGames {
    [_pgnFileDoc.pgnFileInfo appendGamesAndTagsToPgnFile:pastedGames];
    [self.tableView reloadData];
}

#pragma mark - Implementazione metodi UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Gestione ChessStudioLight in caso superamento numero mosse consentito
    if (alertView.tag == 1000) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"CHESS_STUDIO_APP_STORE", nil)]];
        }
        return;
    }
}

- (void) report_memory {
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(),
                                   MACH_TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %llu", info.resident_size);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
}

@end
