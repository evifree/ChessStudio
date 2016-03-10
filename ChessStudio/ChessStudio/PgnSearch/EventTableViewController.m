//
//  EventTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "EventTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "DatabaseForCopyTableViewController.h"

@interface EventTableViewController () {
    
    NSArray *eventArray;
    NSCountedSet *eventsCountedSet;
    
    UIBarButtonItem *actionBarButtonItem;
    UIActionSheet *actionSheetMenu;
    UIActionSheet *copyActionSheetMenu;
    
    NSArray *partiteSelezionateDaCopiareEliminare;
    NSMutableArray *gamesToDelete;
}

@end

@implementation EventTableViewController


//#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


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
        
        self.navigationItem.title = NSLocalizedString(@"EVENTS_GAME_INFO", nil);
        
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
        
        label1.font = [UIFont boldSystemFontOfSize:17.0];
        label1.textColor = [UIColor whiteColor];
        label1.text = [NSString stringWithFormat:NSLocalizedString(@"EVENT_TABLE_VIEW_CONTROLLER_TITLE", nil), @""];
        label1.backgroundColor = [UIColor clearColor];
        label1.textAlignment = NSTextAlignmentCenter;
        [titoloView addSubview:label1];
        
        label2.font = [UIFont boldSystemFontOfSize:17.0];
        label2.text = _pgnFileDoc.pgnFileInfo.fileName;
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = [UIColor whiteColor];
        label2.textAlignment = NSTextAlignmentCenter;
        [titoloView addSubview:label2];
        self.navigationItem.titleView = titoloView;
    }
    else {
        NSString *titolo = [NSString stringWithFormat:NSLocalizedString(@"EVENT_TABLE_VIEW_CONTROLLER_TITLE", nil), _pgnFileDoc.pgnFileInfo.fileName];
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

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}


- (void) setPgnFileDoc:(PgnFileDocument *)pgnFileDoc {
    _pgnFileDoc = pgnFileDoc;
    [self initData];
    //NSLog(@"Numero eventi = %d", eventArray.count);
    //[_pgnFileDoc.pgnFileInfo printAllGamesAllTags];
}

- (void) initData {
    eventsCountedSet = [_pgnFileDoc.pgnFileInfo getAllEventsByCountedSet];
    eventArray = [[eventsCountedSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return eventArray.count;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = cell.bounds;
    
    UIColor *color1 = UIColorFromRGB(0x99FF00);
    UIColor *color2 = UIColorFromRGB(0x009933);
    
    
    //grad.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor greenColor] CGColor], nil];
    grad.colors = [NSArray arrayWithObjects:(id)[color1 CGColor], (id)[color2 CGColor], nil];
    
    [cell setBackgroundView:[[UIView alloc] init]];
    [cell.backgroundView.layer insertSublayer:grad atIndex:0];
    
    CAGradientLayer *selectedGrad = [CAGradientLayer layer];
    selectedGrad.frame = cell.bounds;
    selectedGrad.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    
    [cell setSelectedBackgroundView:[[UIView alloc] init]];
    [cell.selectedBackgroundView.layer insertSublayer:selectedGrad atIndex:0];

    cell.selectedBackgroundView.alpha = 0.1;
    cell.backgroundView.alpha = 0.3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Event";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    NSString *eventData = [eventArray objectAtIndex:indexPath.row];
    if ([eventData rangeOfString:separator].length == 0) {
        eventData = [eventData stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    }
    NSArray *event = [eventData componentsSeparatedByString:separator];
    
    NSString *evento = [[[event objectAtIndex:0] componentsSeparatedByString:@"\""] objectAtIndex:1];
    NSString *site = [[[event objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:1];
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [[evento stringByAppendingString:@" - "] stringByAppendingString:site];
    
    NSMutableString *detail = [[NSMutableString alloc] init];
    for (int i = 2; i<event.count; i++) {
        [detail appendString:[[[event objectAtIndex:i] componentsSeparatedByString:@"\""] objectAtIndex:1]];
        [detail appendString:@" - "];
    }
    
    //NSNumber *num = [eventDictionary objectForKey:[eventArray objectAtIndex:indexPath.row]];
    NSUInteger num = [eventsCountedSet countForObject:[eventArray objectAtIndex:indexPath.row]];
    
    //if (num.intValue == 1) {
    //    [detail appendFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita"), num.intValue];
    //}
    //else {
    //    [detail appendFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), num.intValue];
    //}
    
    if (num == 1) {
        [detail appendFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita"), num];
    }
    else {
        [detail appendFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), num];
    }
    
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

- (NSArray *) getGamesForEvent:(NSIndexPath *)indexPath {
    NSString *selectedEvent = [eventArray objectAtIndex:indexPath.row];
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
    
    NSString *selectedEvent = [eventArray objectAtIndex:indexPath.row];
    
    //NSLog(@"Evento selezionato = %@", selectedEvent);
    
    //selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"][EventDate" withString:@"]|[EventDate"];
    
    //NSLog(@"SelectedEvent = %@", selectedEvent);
    NSArray *evArray = [selectedEvent componentsSeparatedByString:@"\""];
    //NSLog(@"Primo di array = %@", [evArray objectAtIndex:1]);
    
    //selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    //selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
    //selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
    //selectedEvent = [selectedEvent stringByReplacingOccurrencesOfString:@"?" withString:@"\\?"];
    
    //NSMutableString *parametro = [[NSMutableString alloc] init];
    //[parametro appendString:selectedEvent];
    
    //[parametro replaceOccurrencesOfString:@"(" withString:@"\\(" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [selectedEvent length])];
    //[parametro replaceOccurrencesOfString:@")" withString:@"\\)" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [selectedEvent length])];

    //NSArray *gamesFound = [_pgnFileDoc.pgnFileInfo findGamesByTagValues:parametro];
    
    //NSLog(@"Ci sono %d partite con %@", gamesFound.count, parametro);
    
    //NSLog(@"Hai selezionato l'evento %@", selectedEvent);
    //NSLog(@"Valore parametro = %@", parametro);
    
    //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    UIStoryboard *sb = [UtilToView getStoryBoard];
    GamesTableViewController  *gtvc = [sb instantiateViewControllerWithIdentifier:@"GamesTableViewController"];
    [gtvc setDelegate:self];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    //hud.detailsLabelText = title;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        NSArray *gamesFound = [self getGamesForEvent:indexPath];
        [gtvc setGames:gamesFound.mutableCopy];
        [gtvc setPgnFileDoc:_pgnFileDoc];
        [gtvc setPlayerName:[evArray objectAtIndex:1]];
        [self.navigationController pushViewController:gtvc animated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        partiteSelezionateDaCopiareEliminare = [tableView indexPathsForSelectedRows];
    }
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
    //actionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_MANAGE_GAMES", nil), nil];
    //actionSheetMenu.tag = 300;
    
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
    //copyActionSheetMenu.tag = 100;
    
    copyActionSheetMenu = [[UIActionSheet alloc] init];
    copyActionSheetMenu.tag = 100;
    copyActionSheetMenu.delegate = self;
    
    [copyActionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_COPY_GAMES", nil)];
    [copyActionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_DELETE_GAMES", nil)];
    [copyActionSheetMenu addButtonWithTitle:NSLocalizedString(@"DONE", nil)];
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
                    [copyArray addObjectsFromArray:[self getGamesForEvent:indexPath]];
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
                for (NSIndexPath *indexPath in partiteSelezionateDaCopiareEliminare) {
                    [gamesToDelete addObjectsFromArray:[self getGamesForEvent:indexPath]];
                }
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
            [self.tableView reloadData];
        }
    }
}

#pragma mark - GamesTableViewController delegate

- (void) aggiorna {
    NSLog(@"Devo aggiornare i dati");
    [self initData];
    [self.tableView reloadData];
}

@end
