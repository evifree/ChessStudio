//
//  PlayerTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 25/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PlayerTableViewController.h"
#import "PlayerDetailTableViewController.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "DatabaseForCopyTableViewController.h"

@interface PlayerTableViewController () {
    
    //NSString *letters;
    NSMutableArray *indexTitle;
    
    
    //NSDictionary *playerDictionary;
    //NSArray *playerInfoArray;
    NSArray *playerNameArray;
    NSCountedSet *playerCountedSet;
    
    UIBarButtonItem *actionBarButtonItem;
    UIActionSheet *actionSheetMenu;
    UIActionSheet *copyActionSheetMenu;
    
    NSArray *partiteSelezionateDaCopiareEliminare;
    NSMutableArray *gamesToDelete;
    
    
    //NSMutableArray *mutableIndexTitle;
}

@end

@implementation PlayerTableViewController

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
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //letters = @"A a B b C c D d E e F f G g H h I i J j K k L l M m N n O o P p Q q R r S s T t U u V v W w X x Y y Z z";
    //indexTitle = [letters componentsSeparatedByString:@" "];
    
    
    //NSString *className = NSStringFromClass([self class]);
    //NSLog(@"Sto eseguendo %@ con metodo  %s", className, __PRETTY_FUNCTION__);
    //NSString *methodName = NSStringFromSelector(_cmd);
    //NSLog(@"Sto eseguendo il metodo %@ alla riga %d", methodName, __LINE__);
    
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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (IS_PHONE) {
        
        self.navigationItem.title = NSLocalizedString(@"PLAYERS_GAME_INFO", nil);
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
        label1.text = [NSString stringWithFormat:NSLocalizedString(@"PLAYER_TABLE_VIEW_CONTROLLER_TITLE", nil), @""];
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
        NSString *titolo = [NSString stringWithFormat:NSLocalizedString(@"PLAYER_TABLE_VIEW_CONTROLLER_TITLE", nil), _pgnFileDoc.pgnFileInfo.fileName];
        self.navigationItem.title = titolo;
    }
    //NSLog(@"PlayerTableViewController sta per apparire");
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"Memory warning da %@", className);
    
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) setPgnFileDoc:(PgnFileDocument *)pgnFileDoc {
    _pgnFileDoc = pgnFileDoc;
    [self initData];
    //NSMutableString *titolo = [[NSMutableString alloc] initWithString:NSLocalizedString(@"PLAYER", nil)];
    //self.navigationItem.title = titolo;
}

- (void) initData {

    playerCountedSet = [_pgnFileDoc.pgnFileInfo getAllPlayersByCountedSet];
    playerNameArray = [[playerCountedSet allObjects]sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    if (!indexTitle) {
        indexTitle = [[NSMutableArray alloc] init];
    }
    else {
        [indexTitle removeAllObjects];
    }
    
    for (NSString *name in playerNameArray) {
        NSString *primaLettera = [name substringToIndex:1];
        if (![indexTitle containsObject:primaLettera]) {
            [indexTitle addObject:primaLettera];
        }
    }

}

#pragma mark - Table view data source

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return indexTitle;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [indexTitle indexOfObject:title];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [indexTitle objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [indexTitle count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *list2 = [[NSMutableArray alloc] init];
    NSString *lettera = [indexTitle objectAtIndex:section];
    for (NSString *s in playerNameArray) {
        if ([s hasPrefix:lettera]) {
            [list2 addObject:s];
        }
    }
    return list2.count;
    
    //return playerNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell PlayerTable";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    NSMutableArray *list2 = [[NSMutableArray alloc] init];
    NSString *lettera = [indexTitle objectAtIndex:indexPath.section];
    for (NSString *s in playerNameArray) {
        if ([s hasPrefix:lettera]) {
            [list2 addObject:s];
        }
    }
    
    [list2 sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    cell.textLabel.textColor = [UIColor blueColor];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSArray *textArray = [[list2 objectAtIndex:indexPath.row] componentsSeparatedByString:separator];
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [textArray objectAtIndex:0];
    
    NSMutableString *detail = [[NSMutableString alloc] init];
    
    //NSNumber *num = [playerDictionary objectForKey:[list2 objectAtIndex:indexPath.row]];
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    for (int i=1; i<textArray.count; i++) {
        NSString *dato = [textArray objectAtIndex:i];
        NSNumber *datoNumero = [numberFormatter numberFromString:dato];
        if (!datoNumero) {
            if (dato.length>0 && ![dato hasPrefix:@"?"]) {
                if (detail.length > 0) {
                    [detail appendString:@" - "];
                }
                [detail appendFormat:NSLocalizedString(@"PLAYER_TITLE", nil), dato];
            }
        }
        if (datoNumero) {
            if (dato.length == 4) {
                if (detail.length > 0) {
                    [detail appendString:@" - "];
                }
                [detail appendFormat:@"ELO: %@", dato];
            }
            else {
                if (detail.length > 0) {
                    [detail appendString:@" - "];
                }
                [detail appendFormat:NSLocalizedString(@"PLAYER_FIDE_ID", nil), dato];
            }
        }
    }
    
    
    
    
    NSUInteger num = [playerCountedSet countForObject:[list2 objectAtIndex:indexPath.row]];
    
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

- (NSArray *) getGamesForPlayer:(NSIndexPath *) indexPath {
    NSMutableArray *list2 = [[NSMutableArray alloc] init];
    NSString *lettera = [indexTitle objectAtIndex:indexPath.section];
    for (NSString *s in playerNameArray) {
        if ([s hasPrefix:lettera]) {
            [list2 addObject:s];
        }
    }
    [list2 sortUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *player = [list2 objectAtIndex:indexPath.row];
    NSArray *playerArray = [player componentsSeparatedByString:separator];
    return [_pgnFileDoc.pgnFileInfo findGamesByPlayerName:[playerArray objectAtIndex:0]];
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
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //NSString *selectedPlayer = cell.textLabel.text;
    //NSLog(@"Giocatore selezionato %@", selectedPlayer);
    
    if (self.tableView.isEditing) {
        partiteSelezionateDaCopiareEliminare = [tableView indexPathsForSelectedRows];
        return;
    }
    
    
    NSMutableArray *list2 = [[NSMutableArray alloc] init];
    NSString *lettera = [indexTitle objectAtIndex:indexPath.section];
    for (NSString *s in playerNameArray) {
        if ([s hasPrefix:lettera]) {
            [list2 addObject:s];
        }
    }
    [list2 sortUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *player = [list2 objectAtIndex:indexPath.row];
    //NSLog(@"Player: %@", player);
    
    
    
    //NSArray *games = [_pgnFileDoc.pgnFileInfo findGamesByPlayerName:selectedPlayer];
    //NSLog(@"Per %@ ho trovato %d partite", selectedPlayer, games.count);
    
    
    //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    UIStoryboard *sb = [UtilToView getStoryBoard];
    PlayerDetailTableViewController *pdtvc = [sb instantiateViewControllerWithIdentifier:@"PlayerDetailTableViewController"];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    //hud.detailsLabelText = title;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        //NSArray *games = [_pgnFileDoc.pgnFileInfo findGamesByPlayerName:selectedPlayer];
        [pdtvc setPgnFileDoc:_pgnFileDoc];
        [pdtvc setPlayerData:player];
        
        if (IS_PHONE) {
            self.navigationItem.title = NSLocalizedString(@"BACK", nil);
        }
        
        [self.navigationController pushViewController:pdtvc animated:YES];
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
    
    //copyActionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_COPY_GAMES", nil), NSLocalizedString(@"DONE", nil), nil];
    //copyActionSheetMenu.tag = 100;
    
    copyActionSheetMenu = [[UIActionSheet alloc] init];
    copyActionSheetMenu.tag = 100;
    copyActionSheetMenu.delegate = self;
    
    [copyActionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_COPY_GAMES", nil)];
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
                    [copyArray addObjectsFromArray:[self getGamesForPlayer:indexPath]];
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
                    [gamesToDelete addObjectsFromArray:[self getGamesForPlayer:indexPath]];
                }
                NSString *msg;
                if (gamesToDelete.count == 1) {
                    msg = NSLocalizedString(@"CONFIRM_DELETE_ONE", nil);
                }
                else {
                    msg = [NSString stringWithFormat:NSLocalizedString(@"CONFIRM_DELETE_MANY", nil), gamesToDelete.count];
                }
                UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
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
            //NSLog(@"Numero nomi prima di eliminazione = %d", playerNameArray.count);
            [_pgnFileDoc.pgnFileInfo deleteGamesInArray:gamesToDelete];
            [self initData];
            //NSLog(@"Numero nomi dopo di eliminazione = %d", playerNameArray.count);
            [self.tableView deleteRowsAtIndexPaths:partiteSelezionateDaCopiareEliminare withRowAnimation:UITableViewRowAnimationFade];
            //[self.tableView reloadData];
        }
    }
}

@end
