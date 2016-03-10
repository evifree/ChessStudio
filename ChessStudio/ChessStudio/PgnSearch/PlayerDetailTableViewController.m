//
//  PlayerDetailTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 07/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PlayerDetailTableViewController.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "DatabaseForCopyTableViewController.h"
#import "GameBoardPreviewTableViewController.h"

@interface PlayerDetailTableViewController () {
    NSArray *playerArray;
    NSMutableArray *playerGames;
    
    NSString *pattern;
    NSRegularExpression *regex;
    
    UIBarButtonItem *actionBarButtonItem;
    UIActionSheet *actionSheetMenu;
    UIActionSheet *copyActionSheetMenu;
    
    NSArray *partiteSelezionateDaCopiareEliminare;
    NSMutableArray *gamesToDelete;
    
    NSString *gameSel;
    PGNGame *_pgnGame;
    
    
    UIPopoverController *gamePreviewPopoverController;
    
    NSInteger lastSelectedGame;
    
    
    //NSMutableAttributedString *attributoMosse;
    //NSDictionary *attributoPezzo;
}

@end

@implementation PlayerDetailTableViewController

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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = [playerArray objectAtIndex:0];
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

- (void) setPlayerData:(NSString *)playerData {
    _playerData = [playerData stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:separator]];
    [self initData];
    //NSLog(@"PlayerData = %@", _playerData);
    //NSLog(@"PlayerArray = %d", playerArray.count);
}

- (void) initData {
    playerArray = [_playerData componentsSeparatedByString:separator];
    playerGames = [_pgnFileDoc.pgnFileInfo findGamesByPlayerName:[playerArray objectAtIndex:0]].mutableCopy;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return playerArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section<playerArray.count) {
        return 1;
    }
    return playerGames.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section<playerArray.count) {
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        if (section == 0) {
            return NSLocalizedString(@"DETAIL_PLAYER_PLAYER", nil);
        }
        if (section>0) {
            NSString *dato = [playerArray objectAtIndex:section];
            NSNumber *datoNumero = [numberFormatter numberFromString:dato];
            if (!datoNumero) {
                return NSLocalizedString(@"DETAIL_PLAYER_TITLE", nil);
            }
            else if (dato.length == 4) {
                return @"ELO";
            }
            else {
                return NSLocalizedString(@"DETAIL_PLAYER_ID-FIDE", nil);
            }
        }
    }
    if (section >= playerArray.count && playerGames.count>0) {
        return NSLocalizedString(@"DETAIL_PLAYER_GAMES", nil);
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section<playerArray.count) {
        return 44.0;
    }
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell PlayerDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (indexPath.section < playerArray.count) {
        cell.textLabel.text = [playerArray objectAtIndex:indexPath.section];
        cell.detailTextLabel.text = nil;
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        UILabel *gameLabel = (UILabel *)[cell viewWithTag:100];
        if (gameLabel) {
            [gameLabel removeFromSuperview];
            gameLabel = nil;
        }
        
        UILabel *numGameLabel = (UILabel *)[cell viewWithTag:200];
        if (numGameLabel) {
            [numGameLabel removeFromSuperview];
            numGameLabel = nil;
        }
        
        
    }
    else {
        
        NSString *game = [playerGames objectAtIndex:indexPath.row];
        
        PGNGame *cellPgnGame = [[PGNGame alloc] initWithPgn:game];
        
        
        NSArray *matches = [regex matchesInString:game options:0 range:NSMakeRange(0, [game length])];
        NSMutableArray *dati = [[NSMutableArray alloc] init];
        for (NSTextCheckingResult *cr in matches) {
            //NSString *s0 = [game substringWithRange:cr.range];
            //NSLog(@"%@", s0);
            
            NSString *s = [[[game substringWithRange:cr.range] componentsSeparatedByString:@"\""] objectAtIndex:1];
            //NSLog(@"%@", s);
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
        //[detail appendString:@"  -  "];
        
        
        
        for (int i=5; i<dati.count; i++) {
            [detail appendString:@"  "];
            [detail appendString:[dati objectAtIndex:i]];
        }
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.text = detail;
        
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        
        
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
            [gameLabel setAttributedText:attributoMosse];
            //[gameLabel setText:[[game componentsSeparatedByString:separator] lastObject]];
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
            [numGameLabel setText:[NSString stringWithFormat:@"%ld", (long)indexGame + 1]];
            [cell.contentView addSubview:numGameLabel];
        }
        else {
            [numGameLabel setText:[NSString stringWithFormat:@"%ld", (long)indexGame + 1]];
        }
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
    gameSel = [playerGames objectAtIndex:indexPath.row];
    //NSLog(@"GAME SEL = \n%@", gameSel);
    _pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
    //NSInteger index = [_pgnFileDoc.pgnFileInfo getIndexOfGame:gameSel];
    
    if (IS_PAD) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        GameBoardPreviewTableViewController *gbptvc = [[GameBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //[gbptvc setPgnFileDoc:_pgnFileDoc];
        //[gbptvc setNumGame:index];
        [gbptvc setGame:[_pgnGame getGameForCopy]];
        gamePreviewPopoverController = [[UIPopoverController alloc] initWithContentViewController:gbptvc];
        [gamePreviewPopoverController presentPopoverFromRect:CGRectMake((cell.frame.size.width-60), cell.frame.origin.y  , cell.frame.size.width, cell.frame.size.height) inView:tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        GameBoardPreviewTableViewController *gbptvc = [[GameBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //[gbptvc setPgnFileDoc:_pgnFileDoc];
        //[gbptvc setNumGame:index];
        [gbptvc setGame:[_pgnGame getGameForCopy]];
        gbptvc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [self.navigationController presentViewController:gbptvc animated:YES completion:nil];
        //[self.navigationController pushViewController:gbptvc animated:YES];
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section < playerArray.count) {
        return NO;
    }
    return YES;
}


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
    
    if (indexPath.section >= playerArray.count) {
        //NSString *title = NSLocalizedString(@"SEARCHING", nil);
        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        //UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(130, 50, 25, 25)];
        //progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        //[progress performSelectorInBackground:@selector(startAnimating) withObject:self];
        //[alertView addSubview:progress];
        //[alertView performSelectorInBackground:@selector(show) withObject:nil];
        
        
        
        [self goToTheGamePreview:indexPath];
        
        
        /*
        gameSel = [playerGames objectAtIndex:indexPath.row];
        
        
        @try {
            _pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
        }
        @catch (NSException *exception) {
            UIAlertView *wrongGameAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(exception.name, nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [wrongGameAlertView show];
            return;
        }
        @finally {
            
        }
        
        
        
        
        //NSString *moves = [_pgnFileDoc.pgnFileInfo findGameMovesByTagPairs:gameSel];
        
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
            //NSString *moves = [_pgnFileDoc.pgnFileInfo findGameMovesByTagPairs:gameSel];
            //NSString *gameSel2 = [gameSel stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
            //gameSel2 = [[gameSel2 stringByAppendingString:separator] stringByAppendingString:moves];
            
            
            [gptvc setPgnFileDoc:_pgnFileDoc];
            
            
            //[gptvc setGame:gameSel2];
            //[gptvc setMoves:moves];
            [gptvc setPgnGame:_pgnGame];
            
            
            if (IS_PHONE) {
                self.navigationItem.title = NSLocalizedString(@"BACK", nil);
            }
            
            [self.navigationController pushViewController:gptvc animated:YES];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        */
    }
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
        [gptvc setPgnGame:_pgnGame];
        
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
        gameSel = [playerGames objectAtIndex:indexPath.row];
        lastSelectedGame = indexPath.row;
        indicePartita = [[_pgnFileDoc.pgnFileInfo getAllGamesAndTags] indexOfObject:gameSel];  //Serve per salvare permanente l'eventuale partita con FEN non corretto
    }
    
    @try {
        if ([PGNGame gameIsPositionWithRegularFen:gameSel]) {
            
            gameSel = [PGNGame checkStartColorAndFirstMove:gameSel]; //controlla e restituisce gameSel modificata tendendo conto del colore che deve muovere e la prima mossa.
            
            if ([PGNGame gameIsPositionWithRegularNumbering:gameSel]) {
                _pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
            }
        }
        else {
            NSLog(@"La posizione non è corretta, la correggo");
            gameSel = [PGNGame getCorrectedGame:gameSel];
            [playerGames replaceObjectAtIndex:indexPath.row withObject:gameSel];
            if ([PGNGame gameIsPositionWithRegularNumbering:gameSel]) {
                _pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
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
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    NSString *updatedGame = [pgnGame getGameForAllGamesAndAllTags];
    [playerGames replaceObjectAtIndex:selectedIndexPath.row withObject:updatedGame];
    [self.tableView reloadData];
}

- (PGNGame *) getNextGame {
    if (lastSelectedGame == (playerGames.count - 1)) {
        return nil;
    }
    lastSelectedGame++;
    gameSel = [playerGames objectAtIndex:lastSelectedGame];
    _pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
    return _pgnGame;
}

- (PGNGame *) getPreviousGame {
    if (lastSelectedGame == 0) {
        return nil;
    }
    lastSelectedGame--;
    gameSel = [playerGames objectAtIndex:lastSelectedGame];
    _pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
    return _pgnGame;
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
    actionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_MANAGE_GAMES", nil), nil];
    actionSheetMenu.tag = 300;
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
    
    copyActionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_COPY_GAMES", nil), NSLocalizedString(@"MENU_DELETE_GAMES", nil),  NSLocalizedString(@"DONE", nil), nil];
    //copyActionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_COPY_GAMES", nil), NSLocalizedString(@"DONE", nil), nil];
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
                    [copyArray addObject:[playerGames objectAtIndex:indexPath.row]];
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
                    [gamesToDelete addObject:[playerGames objectAtIndex:indexPath.row]];
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
        if ([title isEqualToString:NSLocalizedString(@"MENU_MANAGE_GAMES", nil)] && playerGames.count>0) {
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
            //[playerGames removeObjectsInArray:gamesToDelete];
            [_pgnFileDoc.pgnFileInfo deleteGamesInArray:gamesToDelete];
            [self initData];
            [self.tableView deleteRowsAtIndexPaths:partiteSelezionateDaCopiareEliminare withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
            //[_delegate aggiorna];
        }
    }
    if (alertView.tag == 200 || alertView.tag == 300) {
        NSString *scelta = [alertView buttonTitleAtIndex:buttonIndex];
        if ([scelta isEqualToString:NSLocalizedString(@"MENU_CANCEL", nil)]) {
            return;
        }
        else {
            NSString *newGameSel = [PGNGame getGameWithNumberOfMoveInFenCorrected:gameSel];
            NSInteger *indexGame = [playerGames indexOfObject:gameSel];
            [playerGames replaceObjectAtIndex:indexGame withObject:newGameSel];
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
