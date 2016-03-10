//
//  PgnPastedGameTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 20/11/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PgnPastedGameTableViewController.h"
#import "PGNPastedGame.h"
#import "DatabaseForCopyTableViewController.h"

@interface PgnPastedGameTableViewController () {

    NSArray *pastedGamesArray;
    PGNPastedGame *pastedGame;
    NSDictionary *evaluationDictionary;
    
}

@end

@implementation PgnPastedGameTableViewController

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
    
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_CANCEL", nil) style:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE", nil) style:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pastedGame = [[PGNPastedGame alloc] initWithPastedString:[pasteBoard string]];
    pastedGamesArray = [pastedGame getFinalPastedGames];
    evaluationDictionary = [pastedGame getEvaluationDictionary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) cancelButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveButtonPressed {
    NSArray *gamesToSave = [pastedGame gamesToSave];
    if (gamesToSave.count == 0) {
        UIAlertView *noGameAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_PASTED_GAME_TO SAVE", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [noGameAlertView show];
        return;
    }
    if ([_callingViewController isEqualToString:@"TBDatabaseTableViewController"]) {
        DatabaseForCopyTableViewController *dctvc = [[DatabaseForCopyTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [dctvc setGamesToCopyArray:gamesToSave];
        [self.navigationController pushViewController:dctvc animated:YES];
        return;
    }
    
    if ([_callingViewController isEqualToString:@"PgnFileInfoTableViewController"]) {
        if (_delegate) {
            [_delegate saveGames:gamesToSave];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if ([_callingViewController isEqualToString:@"PgnResultGamesTableViewController"]) {
        if (_delegate) {
            [_delegate saveGames:gamesToSave];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (pastedGamesArray) {
        if (pastedGamesArray.count == 0) {
            UIAlertView *noGamesToPastAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_VALID_GAME", nil) delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            noGamesToPastAlertView.tag = 1;
            [noGamesToPastAlertView show];
        }
    }
}


#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (pastedGamesArray) {
        return pastedGamesArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Paste";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //}
    
    // Configure the cell...
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSString *game = [pastedGamesArray objectAtIndex:indexPath.row];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    if (IS_PAD) {
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    else {
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:13];
    }
    
    //cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [pastedGame getGameForTableView:game];
    
    
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = [pastedGame getGameDetailForTableView:game];
    
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *game = [pastedGamesArray objectAtIndex:indexPath.row];
    NSInteger evaluation = [[evaluationDictionary objectForKey:game] integerValue];
    if (evaluation == 0) {
        [cell setBackgroundColor:[[UIColor alloc] initWithRed:76.0/255 green:217.0/255 blue:100.0/255 alpha:1.0]];
    }
    else if (evaluation == 1) {
        [cell setBackgroundColor:[[UIColor alloc] initWithRed:255.0/255 green:204.0/255 blue:0.0/255 alpha:1.0]];
    }
    else if (evaluation == 3) {
        [cell setBackgroundColor:[[UIColor alloc] initWithRed:255.0/255 green:59.0/255 blue:48.0/255 alpha:1.0]];
    }
    else if (evaluation == 5 || evaluation == 6 || evaluation == 4 || evaluation == 2) {
        [cell setBackgroundColor:[[UIColor alloc] initWithRed:142.0/255 green:142.0/255 blue:147.0/255 alpha:1.0]];
    }
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
    
    //NSString *gameSelected = [pastedGamesArray objectAtIndex:indexPath.row];
    //NSLog(@"Game selected = %@", gameSelected);
    //NSInteger evaluation = [[evaluationDictionary objectForKey:gameSelected] integerValue];
    //NSLog(@"Game Evaluation = %d", evaluation);
    
    
    //[self performSegueWithIdentifier:@"PgnPastedGameDetailSegue" sender:gameSelected];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *gameSelected = [pastedGamesArray objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    PgnPastedGameDetailViewController *ppgdvc = (PgnPastedGameDetailViewController *)[segue destinationViewController];
    [ppgdvc setSelectedGameToPast:gameSelected];
    [ppgdvc setPastedGame:pastedGame];
    [ppgdvc setCallingViewController:_callingViewController];
    [ppgdvc setDelegate:self];
}

#pragma mark - Implementazione metodi PgnPastedGameDetailViewControllerDelegate

- (void) updateTable {
    [self.tableView reloadData];
}

- (void) saveGame:(NSString *)gameToSave {
    if (_delegate) {
        [_delegate saveGames:[NSArray arrayWithObject:gameToSave]];
    }
}

#pragma mark - Implementazione metodi UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [self cancelButtonPressed];
    }
}

@end
