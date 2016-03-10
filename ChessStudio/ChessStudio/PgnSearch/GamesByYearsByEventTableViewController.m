//
//  GamesByYearsByEventTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/06/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "GamesByYearsByEventTableViewController.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "DatabaseForCopyTableViewController.h"

@interface GamesByYearsByEventTableViewController () {
    NSCountedSet *dateCountedSet;
    NSCountedSet *eventsCountedSet;
    NSCountedSet *allEventsCountedSet;
    NSArray *dateArray;
    NSMutableDictionary *gamesByYear;
    NSMutableDictionary *eventsByYear;
    
    
    
    NSString *_evento;
    NSString *_titolo;
    
    UIBarButtonItem *actionBarButtonItem;
    UIActionSheet *actionSheetMenu;
    UIActionSheet *copyActionSheetMenu;
    
    NSArray *partiteSelezionateDaCopiareEliminare;
    NSMutableArray *gamesToDelete;
    
}

@end

@implementation GamesByYearsByEventTableViewController

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
    actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    self.navigationItem.rightBarButtonItem = actionBarButtonItem;
    
    if (IsChessStudioLight) {
        //if (IS_IOS_7) {
            self.canDisplayBannerAds = YES;
        //}
    }
    
    if (_pgnFileDoc.pgnFileInfo.isInCloud) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (IS_PHONE) {
        
        self.navigationItem.title = NSLocalizedString(@"EVENTS_BY_YEARS_INFO", nil);
        return;
        
        UIView *titoloView;
        UILabel *label1;
        UILabel *label2;
        if (IS_ITALIANO) {
            titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, self.navigationController.navigationBar.frame.size.height)];
            label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 28)];
            label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 150, 16)];
        }
        else {
            titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
            label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 190, 28)];
            label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 190, 16)];
        }
        
        //UIView *titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
        //UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 190, 28)];
        label1.font = [UIFont boldSystemFontOfSize:16.0];
        label1.textColor = [UIColor whiteColor];
        label1.text = [NSString stringWithFormat:NSLocalizedString(@"EVENTS_BY_YEAR_TABLE_VIEW_CONTROLLER_TITLE", nil), @""];
        label1.backgroundColor = [UIColor clearColor];
        label1.textAlignment = NSTextAlignmentCenter;
        [titoloView addSubview:label1];
        
        //UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 190, 16)];
        label2.font = [UIFont boldSystemFontOfSize:16.0];
        label2.text = _pgnFileDoc.pgnFileInfo.fileName;
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = [UIColor whiteColor];
        label2.textAlignment = NSTextAlignmentCenter;
        [titoloView addSubview:label2];
        self.navigationItem.titleView = titoloView;
    }
    else {
        NSString *titolo = [NSString stringWithFormat:NSLocalizedString(@"EVENTS_BY_YEAR_TABLE_VIEW_CONTROLLER_TITLE", nil), _pgnFileDoc.pgnFileInfo.fileName];
        self.navigationItem.title = titolo;
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        if (actionSheetMenu) {
            [actionSheetMenu dismissWithClickedButtonIndex:-1 animated:YES];
            actionSheetMenu = nil;
        }
        if (copyActionSheetMenu) {
            [copyActionSheetMenu dismissWithClickedButtonIndex:-1 animated:YES];
            copyActionSheetMenu = nil;
        }
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) setPgnFileDoc:(PgnFileDocument *)pgnFileDoc {
    _pgnFileDoc = pgnFileDoc;
    [self initData];
}

- (void) initData {
    dateCountedSet = [_pgnFileDoc.pgnFileInfo getAllDateByCountedSet];
    dateArray = [[dateCountedSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    //NSLog(@"%@", dateArray);
    
    gamesByYear = [[NSMutableDictionary alloc] init];
    for (NSString *year in dateArray) {
        NSArray *gamesArrayByYear = [_pgnFileDoc.pgnFileInfo findGamesByYear:year];
        [gamesByYear setValue:gamesArrayByYear forKey:year];
    }
    
    //NSLog(@"%@", gamesByYear);
    
    eventsByYear = [[NSMutableDictionary alloc] init];
    
    for (NSString *year in dateArray) {
        eventsCountedSet = [_pgnFileDoc.pgnFileInfo getAllEventsInArray:[gamesByYear objectForKey:year]];
        NSArray *eventArray = [[eventsCountedSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        [eventsByYear setObject:eventArray forKey:year];
    }
    
    allEventsCountedSet = [_pgnFileDoc.pgnFileInfo getAllEventsByCountedSet];
    
    
    //NSLog(@"%@", eventsByYear);
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dateArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *year = [dateArray objectAtIndex:section];
    NSArray *eventsArray = [eventsByYear objectForKey:year];
    return eventsArray.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSMutableString *header = [[NSMutableString alloc] init];
    NSString *year = [dateArray objectAtIndex:section];
    [header appendString:year];
    NSUInteger numEventi = [[eventsByYear objectForKey:year] count];
    if (numEventi == 1) {
        [header appendFormat:NSLocalizedString(@"NUM_EVENTI_SINGOLAR", @"1 evento"), numEventi];
    }
    else {
        [header appendFormat:NSLocalizedString(@"NUM_EVENTI_PLURAL", @"n eventi"), numEventi];
    }
    return header;
}

- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (IS_IOS_7) {
        if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
            UITableViewHeaderFooterView *thfv = (UITableViewHeaderFooterView *)view;
            thfv.textLabel.textColor = [UIColor blueColor];
            thfv.contentView.backgroundColor = UIColorFromRGB(0xADFF2F);
            //thfv.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
            thfv.textLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:20];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell GamesByYearsByEvent";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    NSString *year = [dateArray objectAtIndex:indexPath.section];
    NSArray *eventsArray = [eventsByYear objectForKey:year];
    NSString *eventData = [eventsArray objectAtIndex:indexPath.row];
    
    if ([eventData rangeOfString:separator].length == 0) {
        eventData = [eventData stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    }
    
    NSArray *event = [eventData componentsSeparatedByString:separator];
    
    NSString *evento = [[[event objectAtIndex:0] componentsSeparatedByString:@"\""] objectAtIndex:1];
    NSString *site = [[[event objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:1];
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [[evento stringByAppendingString:@" - "] stringByAppendingString:site];
    cell.textLabel.textColor = UIColorFromRGB(0x191970);
    
    NSMutableString *detail = [[NSMutableString alloc] init];
    for (int i = 2; i<event.count; i++) {
        [detail appendString:[[[event objectAtIndex:i] componentsSeparatedByString:@"\""] objectAtIndex:1]];
        [detail appendString:@" - "];
    }
    NSUInteger num = [allEventsCountedSet countForObject:[eventsArray objectAtIndex:indexPath.row]];
    
    if (num == 1) {
        [detail appendFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita"), num];
    }
    else {
        [detail appendFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), num];
    }
    
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.text = detail;
    
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

- (NSArray *) getGamesByYearsByEvent:(NSIndexPath *)indexPath {
    NSString *year = [dateArray objectAtIndex:indexPath.section];
    NSArray *eventsArray = [eventsByYear objectForKey:year];
    NSString *selectedEvent = [eventsArray objectAtIndex:indexPath.row];
    NSString *eventData = [eventsArray objectAtIndex:indexPath.row];
    if ([eventData rangeOfString:separator].length == 0) {
        eventData = [eventData stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    }
    NSArray *event = [eventData componentsSeparatedByString:separator];
    _evento = [[[event objectAtIndex:0] componentsSeparatedByString:@"\""] objectAtIndex:1];
    NSString *site = [[[event objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:1];
    _titolo = [[_evento stringByAppendingString:@" - "] stringByAppendingString:site];
    
    selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
    selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
    selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"?" withString:@"\\?"];
    
    NSMutableString *parametro = [[NSMutableString alloc] init];
    [parametro appendString:selectedEvent];
    
    [parametro replaceOccurrencesOfString:@"(" withString:@"\\(" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [selectedEvent length])];
    [parametro replaceOccurrencesOfString:@")" withString:@"\\)" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [selectedEvent length])];
    
    return [_pgnFileDoc.pgnFileInfo findGamesByTagValues:parametro];
}

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
    
    
    if (self.tableView.isEditing) {
        partiteSelezionateDaCopiareEliminare = [tableView indexPathsForSelectedRows];
        return;
    }
    
    /*
    NSString *year = [dateArray objectAtIndex:indexPath.section];
    NSArray *eventsArray = [eventsByYear objectForKey:year];
    NSString *selectedEvent = [eventsArray objectAtIndex:indexPath.row];
    
    NSString *eventData = [eventsArray objectAtIndex:indexPath.row];
    if ([eventData rangeOfString:separator].length == 0) {
        eventData = [eventData stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    }
    NSArray *event = [eventData componentsSeparatedByString:separator];
    NSString *evento = [[[event objectAtIndex:0] componentsSeparatedByString:@"\""] objectAtIndex:1];
    NSString *site = [[[event objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:1];
    NSString *titolo = [[evento stringByAppendingString:@" - "] stringByAppendingString:site];
    
    
    selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
    selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
    selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"?" withString:@"\\?"];
    
    NSMutableString *parametro = [[NSMutableString alloc] init];
    [parametro appendString:selectedEvent];
    
    [parametro replaceOccurrencesOfString:@"(" withString:@"\\(" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [selectedEvent length])];
    [parametro replaceOccurrencesOfString:@")" withString:@"\\)" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [selectedEvent length])];
    
    
    //NSArray *gamesFound = [_pgnFileDoc.pgnFileInfo findGamesByTagValues:parametro];
    
    //NSLog(@"Ci sono %d partite con %@", gamesFound.count, parametro);
    
    //NSLog(@"Hai selezionato l'evento %@", selectedEvent);
    //NSLog(@"Valore parametro = %@", parametro);
    */
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    GamesTableViewController *gtvc = [sb instantiateViewControllerWithIdentifier:@"GamesTableViewController"];
    [gtvc setDelegate:self];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    //hud.detailsLabelText = title;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        //NSArray *gamesFound = [_pgnFileDoc.pgnFileInfo findGamesByTagValues:parametro];
        NSArray *gamesFound = [self getGamesByYearsByEvent:indexPath];
        [gtvc setGames:gamesFound.mutableCopy];
        [gtvc setPgnFileDoc:_pgnFileDoc];
        [gtvc.navigationItem setTitle:_titolo];
        [gtvc setPlayerName:_evento];
        [self.navigationController pushViewController:gtvc animated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        partiteSelezionateDaCopiareEliminare = [tableView indexPathsForSelectedRows];
    }
}

#pragma mark - GamesTableViewController Delegate

- (void) aggiorna {
    [self initData];
    [self.tableView reloadData];
}

#pragma mark - Gestione ActionButton

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
        cancelButton = NSLocalizedString(@"MENU_CANCEL", nil);
    }
    actionSheetMenu = [[UIActionSheet alloc] init];
    actionSheetMenu.tag = 300;
    actionSheetMenu.delegate = self;
    
    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_MANAGE_GAMES", nil)];
    actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
    [actionSheetMenu showFromBarButtonItem:button animated:YES];
}

- (void) manageCopyButtonPressed:(UIBarButtonItem *)sender {
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
        cancelButton = NSLocalizedString(@"MENU_CANCEL", nil);
    }
    
    //copyActionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_COPY_GAMES", nil), NSLocalizedString(@"MENU_DELETE_GAMES", nil),  NSLocalizedString(@"DONE", nil), nil];
    //copyActionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_COPY_GAMES", nil), NSLocalizedString(@"DONE", nil), nil];
    //copyActionSheetMenu.tag = 100;
    
    copyActionSheetMenu = [[UIActionSheet alloc] init];
    copyActionSheetMenu.tag = 100;
    copyActionSheetMenu.delegate = self;
    
    [copyActionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_COPY_GAMES", nil)];
    [copyActionSheetMenu addButtonWithTitle: NSLocalizedString(@"DONE", nil)];
    copyActionSheetMenu.cancelButtonIndex = [copyActionSheetMenu addButtonWithTitle:cancelButton];
    
    [copyActionSheetMenu showFromBarButtonItem:button animated:YES];
}

#pragma mark - ActionSheet Delegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex<0) {
        return;
    }
    if (actionSheet.tag == 100) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:NSLocalizedString(@"MENU_COPY_GAMES", nil)]) {
            if (partiteSelezionateDaCopiareEliminare.count > 0) {
                NSMutableArray *copyArray = [[NSMutableArray alloc] init];
                for (NSIndexPath *indexPath in partiteSelezionateDaCopiareEliminare) {
                    NSArray *selectedGames = [self getGamesByYearsByEvent:indexPath];
                    [copyArray addObjectsFromArray:selectedGames];
                }
                DatabaseForCopyTableViewController *dfctvc = [[DatabaseForCopyTableViewController alloc] initWithStyle:UITableViewStylePlain];
                [dfctvc setPgnFileDoc:_pgnFileDoc];
                [dfctvc setGamesToCopyArray:copyArray];
                UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:dfctvc];
                if (IS_PAD) {
                    boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                }
                else {
                    boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self presentModalViewController:boardNavigationController animated:YES];
                    [self presentViewController:boardNavigationController animated:YES completion:nil];
                });
                //[self presentModalViewController:boardNavigationController animated:YES];
            }
            return;
        }
        if ([title isEqualToString:NSLocalizedString(@"MENU_DELETE_GAMES", nil)]) {
            if (partiteSelezionateDaCopiareEliminare.count>0) {
                gamesToDelete = [[NSMutableArray alloc] init];
                //for (NSIndexPath *indexPath in partiteSelezionateDaCopiareEliminare) {
                    //NSString *selectedEvent = [eventArray objectAtIndex:indexPath.section];
                    //NSArray *games = [gamesByEvent objectForKey:selectedEvent];
                    //NSString *gameSel = [games objectAtIndex:indexPath.row];
                    //[gamesToDelete addObject:gameSel];
                //}
                NSString *msg;
                if (gamesToDelete.count == 1) {
                    msg = NSLocalizedString(@"CONFIRM_DELETE_ONE", nil);
                }
                else {
                    msg = [NSString stringWithFormat:NSLocalizedString(@"CONFIRM_DELETE_MANY", nil), gamesToDelete.count];
                }
                UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
                confirmAlertView.tag = 100;
                [confirmAlertView show];
            }
            return;
        }
        if ([title isEqualToString:NSLocalizedString(@"DONE", nil)]) {
            [self.tableView setEditing:NO animated:YES];
            self.navigationItem.rightBarButtonItem = actionBarButtonItem;
            //if (rearrangingTableView) {
            //    NSLog(@"Devo salvare il file perchè ho modificato la tabella");
            //    [_pgnFileDoc.pgnFileInfo saveAllGamesAndTags:allGamesAndAllTags];
            //}
            return;
        }
    }
    if (actionSheet.tag == 300) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:NSLocalizedString(@"MENU_MANAGE_GAMES", nil)]) {
            self.tableView.allowsMultipleSelectionDuringEditing = YES;
            [self.tableView setValue:UIColorFromRGB(0x4CE466) forKey:@"multiselectCheckmarkColor"];
            [self.tableView setEditing:YES animated:YES];
            actionBarButtonItem = self.navigationItem.rightBarButtonItem;
            UIBarButtonItem *manageCopyBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(manageCopyButtonPressed:)];
            self.navigationItem.rightBarButtonItem = manageCopyBarButtonItem;
            return;
        }
    }
}

#pragma mark - AlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"OK"]) {
            [_pgnFileDoc.pgnFileInfo deleteGamesInArray:gamesToDelete];
            [self initData];
            [self.tableView deleteRowsAtIndexPaths:partiteSelezionateDaCopiareEliminare withRowAnimation:UITableViewRowAnimationFade];
            //[self.tableView reloadData];
        }
    }
}


@end
