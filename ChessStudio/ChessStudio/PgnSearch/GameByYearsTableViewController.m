//
//  GameByYearsTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/06/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "GameByYearsTableViewController.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "DatabaseForCopyTableViewController.h"
#import "GameBoardPreviewTableViewController.h"

@interface GameByYearsTableViewController () {
    NSCountedSet *dateCountedSet;
    NSArray *dateArray;
    NSMutableDictionary *numberGamesForYear;
    NSMutableDictionary *gamesByYear;
    
    NSString *pattern;
    NSRegularExpression *regex;
    
    UIBarButtonItem *actionBarButtonItem;
    UIActionSheet *actionSheetMenu;
    UIActionSheet *copyActionSheetMenu;
    
    NSArray *partiteSelezionateDaCopiareEliminare;
    NSMutableArray *gamesToDelete;
    
    
    NSMutableArray *_gamesArrayByYear;
    NSString *gameSel;
    PGNGame *pgnGame;
    
    UIPopoverController *gamePreviewPopoverController;
    NSInteger lastSelectedGame;
    
    //NSMutableAttributedString *attributoMosse;
    //NSDictionary *attributoPezzo;
}

@end

@implementation GameByYearsTableViewController

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
    
    NSError *error = NULL;
    pattern = @"White \"(?:[^\\\"]+|\\.)*\"|Black \"(?:[^\\\"]+|\\.)*\"|Event \"(?:[^\\\"]+|\\.)*\"|Site \"(?:[^\\\"]+|\\.)*\"|Result \"(?:[^\\\"]+|\\.)*\"|ECO \"(?:[^\\\"]+|\\.)*\"|EventDate \"(?:[^\\\"]+|\\.)*\"|EventCountry \"(?:[^\\\"]+|\\.)*\"";
    regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
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
    
    //attributoPezzo = @{NSFontAttributeName:[UIFont fontWithName:@"SemFigBold" size:12.0]};
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (IS_PHONE) {
        
        self.navigationItem.title = NSLocalizedString(@"GAMES_BY_YEARS_INFO", nil);
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
        label1.text = [NSString stringWithFormat:NSLocalizedString(@"GAMES_BY_YEAR_TABLE_VIEW_CONTROLLER_TITLE", nil), @""];
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
        NSString *titolo = [NSString stringWithFormat:NSLocalizedString(@"GAMES_BY_YEAR_TABLE_VIEW_CONTROLLER_TITLE", nil), _pgnFileDoc.pgnFileInfo.fileName];
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
    
    numberGamesForYear = [[NSMutableDictionary alloc] init];
    
    for (NSString *p in [[dateCountedSet allObjects]sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        NSUInteger numeroPartite = [dateCountedSet countForObject:p];
        [numberGamesForYear setObject:[NSNumber numberWithInteger:numeroPartite] forKey:p];
    }
    
    gamesByYear = [[NSMutableDictionary alloc] init];
    for (NSString *year in dateArray) {
        NSArray *gamesArrayByYear = [_pgnFileDoc.pgnFileInfo findGamesByYear:year];
        [gamesByYear setValue:gamesArrayByYear forKey:year];
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([gamePreviewPopoverController isPopoverVisible]) {
        [gamePreviewPopoverController dismissPopoverAnimated:NO];
        gamePreviewPopoverController = nil;
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
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
    NSNumber *numeroPartite = [numberGamesForYear objectForKey:[dateArray objectAtIndex:section]];
    return [numeroPartite integerValue];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

/*
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor yellowColor];
    label.font = [UIFont fontWithName:@"Verdana-Bold" size:20];
    label.adjustsFontSizeToFitWidth = YES;
    
    if (IS_PHONE) {
        label.font = [UIFont fontWithName:@"Verdana-Bold" size:12];
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 0;
    }
    
    NSMutableString *header = [[NSMutableString alloc] init];
    [header appendString:[dateArray objectAtIndex:section]];
    [header appendString:@" "];
    
    NSNumber *numeroPartite = [numberGamesForYear objectForKey:[dateArray objectAtIndex:section]];
    if ([numeroPartite integerValue] == 1) {
        [header appendFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita"), [numeroPartite integerValue]];
    }
    else {
        [header appendFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), [numeroPartite integerValue]];
    }
    
    label.text = header;
    return label;
}
*/

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSMutableString *header = [[NSMutableString alloc] init];
    [header appendString:[dateArray objectAtIndex:section]];
    NSNumber *numeroPartite = [numberGamesForYear objectForKey:[dateArray objectAtIndex:section]];
    if ([numeroPartite integerValue] == 1) {
        [header appendFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita"), [numeroPartite integerValue]];
    }
    else {
        [header appendFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), [numeroPartite integerValue]];
    }
    return header;
}

- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (IS_IOS_7) {
        if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
            UITableViewHeaderFooterView *thfv = (UITableViewHeaderFooterView *)view;
            thfv.textLabel.textColor = [UIColor redColor];
            thfv.contentView.backgroundColor = UIColorFromRGB(0xFFD700);
            //thfv.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
            thfv.textLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:20];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Game By Years";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    
    NSString *year = [dateArray objectAtIndex:indexPath.section];
    NSArray *gamesArrayByYear = [gamesByYear objectForKey:year];
    NSString *game = [gamesArrayByYear objectAtIndex:indexPath.row];
    
    PGNGame *cellPgnGame = [[PGNGame alloc] initWithPgn:game];
    
    
    
    NSArray *matches = [regex matchesInString:game options:0 range:NSMakeRange(0, [game length])];
    NSMutableArray *dati = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *cr in matches) {
        NSString *s = [[[game substringWithRange:cr.range] componentsSeparatedByString:@"\""] objectAtIndex:1];
        [dati addObject:s];
    }
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    //cell.textLabel.text = [[[dati objectAtIndex:2] stringByAppendingString:@" - "] stringByAppendingString:[dati objectAtIndex:3]];
    cell.textLabel.text = [cellPgnGame getCellTextLabel];
    
    NSMutableString *detail = [[NSMutableString alloc] init];
    [detail appendString:[dati objectAtIndex:4]]; //Result
    [detail appendString:@"  "];
    [detail appendString:[dati objectAtIndex:0]]; //Event
    [detail appendString:@"  "];
    [detail appendString:[dati objectAtIndex:1]]; //Site
    
    for (int i=5; i<dati.count; i++) {
        [detail appendString:@"  "];
        [detail appendString:[dati objectAtIndex:i]];
    }
    
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.text = detail;
    
    NSString *mosse = [[game componentsSeparatedByString:separator] lastObject];
    //attributoMosse = [[NSMutableAttributedString alloc] initWithString:mosse];
    
    //[self setAttributoFor:@"K" :mosse :attributoPezzo];
    //[self setAttributoFor:@"Q" :mosse :attributoPezzo];
    //[self setAttributoFor:@"R" :mosse :attributoPezzo];
    //[self setAttributoFor:@"B" :mosse :attributoPezzo];
    //[self setAttributoFor:@"N" :mosse :attributoPezzo];
    
    NSMutableAttributedString *attributoMosse = [PGNGame getMovesWithAttributed:mosse];
    
    UILabel *gameLabel = (UILabel *)[cell viewWithTag:100];
    if (!gameLabel) {
        
        if (IS_PHONE) {
            if (IS_IPHONE_6P) {
                gameLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.detailTextLabel.frame.origin.x + 5, 58, tableView.contentSize.width - 50, 20)];
                [gameLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
            }
            else {
                gameLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.detailTextLabel.frame.origin.x, 58, tableView.contentSize.width - 50, 20)];
                [gameLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
            }
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && !IsChessStudioLight) {
                gameLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.detailTextLabel.frame.origin.x + 5, 58, tableView.contentSize.width - 70, 20)];
                [gameLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];
            }
            else {
                gameLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.detailTextLabel.frame.origin.x, 58, tableView.contentSize.width - 70, 20)];
                [gameLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];
            }
        }
        
        gameLabel.tag = 100;
        [gameLabel setBackgroundColor:[UIColor clearColor]];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
            gameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        else {
            gameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        }
        
        //[gameLabel setFont:[cell.detailTextLabel font]];
        [gameLabel setTextColor:[UIColor blueColor]];
        //[gameLabel setText:[[game componentsSeparatedByString:separator] lastObject]];
        [gameLabel setAttributedText:attributoMosse];
        [cell.contentView addSubview:gameLabel];
    }
    else {
        [gameLabel setFrame:CGRectMake(cell.detailTextLabel.frame.origin.x, 58, tableView.contentSize.width - 70, 20)];
        //[gameLabel setText:[[game componentsSeparatedByString:separator] lastObject]];
        [gameLabel setAttributedText:attributoMosse];
    }
    
    UILabel *numGameLabel = (UILabel *)[cell viewWithTag:200];
    NSInteger indexGame = [_pgnFileDoc.pgnFileInfo getIndexOfGame:game];
    if (!numGameLabel) {
        
        if (IS_PHONE) {
            if (IS_IPHONE_6P) {
                numGameLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.textLabel.frame.origin.x + 5, 5, 200, 15)];
            }
            else {
                numGameLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.textLabel.frame.origin.x, 5, 200, 15)];
            }
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && !IsChessStudioLight) {
                numGameLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.textLabel.frame.origin.x + 5, 5, 200, 15)];
            }
            else {
                numGameLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.textLabel.frame.origin.x, 5, 200, 15)];
            }
        }
        
        //numGameLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.textLabel.frame.origin.x, 5, 200, 15)];
        numGameLabel.tag = 200;
        [numGameLabel setBackgroundColor:[UIColor clearColor]];
        [numGameLabel setFont:[UIFont fontWithName:@"Courier-Bold" size:13]];
        [numGameLabel setTextColor:[UIColor redColor]];
        [numGameLabel setText:[NSString stringWithFormat:@"%d", (int)(indexGame + 1)]];
        [cell.contentView addSubview:numGameLabel];
    }
    else {
        [numGameLabel setText:[NSString stringWithFormat:@"%d", (int)(indexGame + 1)]];
    }
    
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.row % 2) == 0) {
        UIColor *oddRowColor = [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0];
        [cell setBackgroundColor: oddRowColor];
    }
    else {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}


- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    NSString *year = [dateArray objectAtIndex:indexPath.section];
    _gamesArrayByYear = [gamesByYear objectForKey:year];
    gameSel = [_gamesArrayByYear objectAtIndex:indexPath.row];
    PGNGame *_pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
    
    if (IS_PAD) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        GameBoardPreviewTableViewController *gbptvc = [[GameBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //[gbptvc setPgnFileDoc:_pgnFileDoc];
        //[gbptvc setNumGame:indexPath.row];
        [gbptvc setGame:[_pgnGame getGameForCopy]];
        gamePreviewPopoverController = [[UIPopoverController alloc] initWithContentViewController:gbptvc];
        [gamePreviewPopoverController presentPopoverFromRect:CGRectMake((cell.frame.size.width-60), cell.frame.origin.y  , cell.frame.size.width, cell.frame.size.height) inView:tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        GameBoardPreviewTableViewController *gbptvc = [[GameBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //[gbptvc setPgnFileDoc:_pgnFileDoc];
        //[gbptvc setNumGame:indexPath.row];
        [gbptvc setGame:[_pgnGame getGameForCopy]];
        gbptvc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [self.navigationController presentViewController:gbptvc animated:YES completion:nil];
        //[self.navigationController pushViewController:gbptvc animated:YES];
        return;
        
        
        [UIView transitionFromView:self.tableView
                            toView:gbptvc.tableView
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCurlUp
                        completion:^(BOOL finished) {
                            // Do something... or not...
                        }];
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
    
    if (self.tableView.isEditing) {
        partiteSelezionateDaCopiareEliminare = [tableView indexPathsForSelectedRows];
        return;
    }
    
    NSString *year = [dateArray objectAtIndex:indexPath.section];
    _gamesArrayByYear = [gamesByYear objectForKey:year];
    
    [self goToTheGamePreview:indexPath];
    
    /*
    gameSel = [_gamesArrayByYear objectAtIndex:indexPath.row];
    
    //NSLog(@"Game = %@", gameSel);
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    GamePreviewTableViewController *gptvc = [sb instantiateViewControllerWithIdentifier:@"GamePreviewTable"];
    [gptvc setDelegate:self];
    
    
    @try {
        pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
    }
    @catch (NSException *exception) {
        UIAlertView *wrongGameAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(exception.name, nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [wrongGameAlertView show];
        return;
    }
    @finally {
        
    }
    
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    //hud.detailsLabelText = title;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        //NSString *moves = [_pgnFileDoc.pgnFileInfo findGameMovesByTagPairs:game];
        //NSString *gameSel2 = [game stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
        //gameSel2 = [[gameSel2 stringByAppendingString:separator] stringByAppendingString:moves];
        
        
        [gptvc setPgnFileDoc:_pgnFileDoc];
        
        //[gptvc setGame:gameSel2];
        //[gptvc setMoves:moves];
        [gptvc setPgnGame:pgnGame];
        
        if (IS_PHONE) {
            self.navigationItem.title = NSLocalizedString(@"BACK", nil);
        }
        
        [self.navigationController pushViewController:gptvc animated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    */
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        partiteSelezionateDaCopiareEliminare = [tableView indexPathsForSelectedRows];
    }
}

#pragma mark - Metodi per gestire la partita una volta selezionata in didSelectRowAtIndexPath

- (void) goToTheGamePreview:(NSIndexPath *) indexPath {
    
    if (![self checkTheGame:indexPath]) {
        return;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    GamePreviewTableViewController *gptvc = [sb instantiateViewControllerWithIdentifier:@"GamePreviewTable"];
    [gptvc setDelegate:self];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    //hud.detailsLabelText = title;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        //NSString *moves = [_pgnFileDoc.pgnFileInfo findGameByNumber:indexPath.row + 1];
        //[gptvc setGame:gameSel];
        //[gptvc setMoves:moves];
        [gptvc setPgnFileDoc:_pgnFileDoc];
        [gptvc setPgnGame:pgnGame];
        
        if (IS_PHONE) {
            self.navigationItem.title = NSLocalizedString(@"BACK", nil);
        }
        
        [self.navigationController pushViewController:gptvc animated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (BOOL) checkTheGame:(NSIndexPath *) indexPath {
    
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    NSString *callerMethod = [array objectAtIndex:4];
    //NSLog(@"Stack = %@", [array objectAtIndex:0]);
    //NSLog(@"Framework = %@", [array objectAtIndex:1]);
    //NSLog(@"Memory address = %@", [array objectAtIndex:2]);
    //NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    //NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    
    
    NSUInteger indicePartita = 0;
    if (indexPath) {
        gameSel = [_gamesArrayByYear objectAtIndex:indexPath.row];
        lastSelectedGame = indexPath.row;
        indicePartita = [[_pgnFileDoc.pgnFileInfo getAllGamesAndTags] indexOfObject:gameSel];  //Serve per salvare permanente l'eventuale partita con FEN non corretto
    }
    
    @try {
        if ([PGNGame gameIsPositionWithRegularFen:gameSel]) {
            
            gameSel = [PGNGame checkStartColorAndFirstMove:gameSel]; //controlla e restituisce gameSel modificata tendendo conto del colore che deve muovere e la prima mossa.
            
            if ([PGNGame gameIsPositionWithRegularNumbering:gameSel]) {
                pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
            }
        }
        else {
            NSLog(@"La posizione non è corretta, la correggo");
            gameSel = [PGNGame getCorrectedGame:gameSel];
            [_gamesArrayByYear replaceObjectAtIndex:indexPath.row withObject:gameSel];
            if ([PGNGame gameIsPositionWithRegularNumbering:gameSel]) {
                pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
                [[_pgnFileDoc.pgnFileInfo getAllGamesAndTags] replaceObjectAtIndex:indicePartita withObject:gameSel];
                [_pgnFileDoc.pgnFileInfo salvaTutteLePartite];
                NSLog(@"Ho salvato la partita corretta n.%lu in maniera permanente", indicePartita+1);
            }
        }
    }
    @catch (NSException *exception) {
        UIAlertView *wrongGameAlertView;
        if ([exception.name isEqualToString:@"NSRangeException"]) {
            wrongGameAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(exception.name, nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        }
        else if ([exception.name isEqualToString:@"WRONG_FEN_EXCEPTION_2"]) {
            
            wrongGameAlertView = [[UIAlertView alloc] initWithTitle:[PGNGame getTemporaryFen] message:NSLocalizedString(exception.name, nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:NSLocalizedString(@"FEN_CORRECT", nil), nil];
            if ([callerMethod isEqualToString:@"goToTheGamePreview:"]) {
                [wrongGameAlertView setTag:200];
            }
            else if ([callerMethod isEqualToString:@"goToTheBoard:"]) {
                [wrongGameAlertView setTag:300];
            }
            
        }
        [wrongGameAlertView show];
        return NO;
    }
    return YES;
}

#pragma mark - GamePreviewTableViewController Delegate

- (void) aggiorna:(PGNGame *)pgnGame {
    [self initData];
    [self.tableView reloadData];
}

- (PGNGame *) getNextGame {
    if (lastSelectedGame == (_gamesArrayByYear.count - 1)) {
        return nil;
    }
    lastSelectedGame++;
    gameSel = [_gamesArrayByYear objectAtIndex:lastSelectedGame];
    pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
    return pgnGame;
}

- (PGNGame *) getPreviousGame {
    if (lastSelectedGame == 0) {
        return nil;
    }
    lastSelectedGame--;
    gameSel = [_gamesArrayByYear objectAtIndex:lastSelectedGame];
    pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
    return pgnGame;
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
    copyActionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_COPY_GAMES", nil), NSLocalizedString(@"DONE", nil), nil];
    copyActionSheetMenu.tag = 100;
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
                    NSString *year = [dateArray objectAtIndex:indexPath.section];
                    NSArray *gamesArrayByYear = [gamesByYear objectForKey:year];
                    NSString *_gameSel = [gamesArrayByYear objectAtIndex:indexPath.row];
                    [copyArray addObject:_gameSel];
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
    if (alertView.tag == 200 || alertView.tag == 300) {
        NSString *scelta = [alertView buttonTitleAtIndex:buttonIndex];
        if ([scelta isEqualToString:NSLocalizedString(@"MENU_CANCEL", nil)]) {
            return;
        }
        else {
            NSString *newGameSel = [PGNGame getGameWithNumberOfMoveInFenCorrected:gameSel];
            NSInteger *indexGame = [_gamesArrayByYear indexOfObject:gameSel];
            [_gamesArrayByYear replaceObjectAtIndex:indexGame withObject:newGameSel];
            gameSel = newGameSel;
            if (alertView.tag == 200) {
                [self goToTheGamePreview:nil];
            }
            else if (alertView.tag == 300) {
                //[self goToTheBoard:nil];
            }
        }
    }
}

//- (void) setAttributoFor:(NSString *)s :(NSString *)testo :(NSDictionary *)dict {
//    NSError *error = NULL;
//    //NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:s options:NSRegularExpressionCaseInsensitive error:&error];
//    NSRegularExpression *regexAttr = [NSRegularExpression regularExpressionWithPattern:s options:0 error:&error];
//    NSArray *matches = [regexAttr matchesInString:testo options:0 range:NSMakeRange(0, [testo length])];
//    for (NSTextCheckingResult *match in matches) {
//        NSRange matchRange = [match range];
//        //NSLog(@"%@ = %lu  %lu", s, (unsigned long)matchRange.location, (unsigned long)matchRange.length);
//        [attributoMosse setAttributes:dict range:matchRange];
//    }
//}

@end
