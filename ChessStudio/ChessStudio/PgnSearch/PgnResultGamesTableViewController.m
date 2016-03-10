//
//  PgnResultGamesTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PgnResultGamesTableViewController.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "DatabaseForCopyTableViewController.h"
#import "FENParser.h"
#import "PgnPastedGameTableViewController.h"
#import "GameBoardPreviewTableViewController.h"

@interface PgnResultGamesTableViewController () {
    //NSArray *games;
    
    NSMutableArray *allGamesAndAllTags;
    
    NSString *ecoPattern;
    NSString *eventDatePattern;
    
    
    //UIAlertView *alertView;
    
    UIBarButtonItem *actionBarButtonItem;
    UIActionSheet *actionSheetMenu;
    
    UIBarButtonItem *twicActionBarButtonItem;
    UIActionSheet *twicActionSheetMenu;
    UIActionSheet *copyActionSheetMenu;
    
    BOOL eseguiReload;
    
    NSArray *partiteSelezionateDaCopiareEliminare;
    
    BOOL twicGames;
    BOOL rearrangingTableView;
    
    PGNGame *pgnGame;
    NSString *gameSel;
    
    
    UIView *titleView;
    
    UIPopoverController *gamePreviewPopoverController;
    NSInteger lastSelectedGame;
    
    //NSIndexPath *expandedPath;
    
    
    //NSMutableAttributedString *attributoMosse;
    //NSDictionary *attributoPezzo;
    
}

@end

@implementation PgnResultGamesTableViewController

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
    ecoPattern = @"ECO \"(?:[^\\\"]+|\\.)*\"";
    eventDatePattern = @"EventDate \"(?:[^\\\"]+|\\.)*\"";
    
    if ([_pgnFileDoc.pgnFileInfo.path rangeOfString:@"/Library/Caches/twic/"].location == NSNotFound) {
        actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
        self.navigationItem.rightBarButtonItem = actionBarButtonItem;
        twicGames = NO;
    }
    else {
        twicActionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(twicActionButtonPressed:)];
        self.navigationItem.rightBarButtonItem = twicActionBarButtonItem;
        twicGames = YES;
    }
    eseguiReload = NO;
    rearrangingTableView = NO;
    
    pgnGame = nil;
    //expandedPath = nil;
    titleView = nil;
    
    
    self.tableView.autoresizesSubviews = YES;
    
    [self setupTitolo];
    
    if (IsChessStudioLight) {
        //if (IS_IOS_7) {
        self.canDisplayBannerAds = YES;
        //}
    }
    
    
    if (_pgnFileDoc.pgnFileInfo.isInCloud) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    //pgnFile = [[PGN alloc] initWithFilename:_pgnFileDoc.pgnFileInfo.fileName];
    //[pgnFile initializeGameIndices];
    
    //attributoPezzo = @{NSFontAttributeName:[UIFont fontWithName:@"SemFigBold" size:12.0]};
    //attributoPezzo = @{NSFontAttributeName:[UIFont fontWithName:@"LinaresDiagram" size:12.0]};
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.navigationItem.title = [@"Games from " stringByAppendingString:_pgnFileDoc.pgnFileInfo.personalFileName];
    
    if (eseguiReload) {
        eseguiReload = NO;
        [self.tableView reloadData];
    }
    
    //if (pgnGame) {
    //    NSLog(@"L'indice di questa partita è %d", [allGamesAndAllTags indexOfObject:[pgnGame getGameForAllGamesAndAllTags]]);
    //}
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        if (actionSheetMenu) {
            [actionSheetMenu dismissWithClickedButtonIndex:-1 animated:YES];
            actionSheetMenu = nil;
        }
        if (twicActionSheetMenu) {
            [twicActionSheetMenu dismissWithClickedButtonIndex:-1 animated:YES];
            twicActionSheetMenu = nil;
        }
        if (copyActionSheetMenu) {
            [copyActionSheetMenu dismissWithClickedButtonIndex:-1 animated:YES];
            copyActionSheetMenu = nil;
        }
    }
}


- (void) setPgnFileDoc:(PgnFileDocument *)pgnFileDoc {
    _pgnFileDoc = pgnFileDoc;
    allGamesAndAllTags = [_pgnFileDoc.pgnFileInfo getAllGamesAndTags];
    //allGamesAndAllTags = [[_pgnFileDoc.pgnFileInfo allGames] mutableCopy];
    //NSLog(@"Nel database ci sono %d partite", allGamesAndAllTags.count);
    
    //NSLog(@"Nel database ho contato %d tag eventi", [_pgnFileDoc.pgnFileInfo caricaTutteGliEventi].count);
    //NSLog(@"Nel database ho contato %d risultati", [_pgnFileDoc.pgnFileInfo caricaTuttiIRisultati].count);
}

- (void) setupTitolo {
    if (IS_PHONE && IS_PORTRAIT) {
        
        self.navigationItem.title = NSLocalizedString(@"GAMES1", nil);
        
        return;
        
        
        if (titleView) {
            self.navigationItem.titleView = titleView;
        }
        
        
        UIColor *coloreTitolo;
        if (IS_IOS_7) {
            coloreTitolo = [UIColor blackColor];
        }
        else {
            coloreTitolo = [UIColor whiteColor];
        }
        
        
        //UIView *titoloView;
        UILabel *label1;
        UILabel *label2;
        if (IS_ITALIANO) {
            titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, self.navigationController.navigationBar.frame.size.height)];
            label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 28)];
            label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 150, 16)];
        }
        else {
            titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
            label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 190, 28)];
            label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 190, 16)];
        }
        label1.font = [UIFont boldSystemFontOfSize:17.0];
        label1.textColor = coloreTitolo;
        label1.text = [NSString stringWithFormat:NSLocalizedString(@"GAME_TABLE_VIEW_CONTROLLER_TITLE", nil), @""];
        label1.backgroundColor = [UIColor clearColor];
        label1.textAlignment = NSTextAlignmentCenter;
        [titleView addSubview:label1];
        
        label2.font = [UIFont boldSystemFontOfSize:17.0];
        //label2.text = NSLocalizedString(@"GAMES1", nil);
        label2.text = _pgnFileDoc.pgnFileInfo.personalFileName;
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = coloreTitolo;
        label2.textAlignment = NSTextAlignmentCenter;
        [titleView addSubview:label2];
        
        self.navigationItem.titleView = titleView;
    }
    else {
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"GAME_TABLE_VIEW_CONTROLLER_TITLE", nil), _pgnFileDoc.pgnFileInfo.fileName];
    }
    
    
    //UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 50)];
    //label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25.0];
    //label.textColor = UIColorFromRGB(0x4F94CD);
    //label.text = _pgnFileDoc.pgnFileInfo.fileName;
    //self.tableView.tableHeaderView = label;
}

#pragma mark - Gestione rotazione

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if ([gamePreviewPopoverController isPopoverVisible]) {
        [gamePreviewPopoverController dismissPopoverAnimated:NO];
        gamePreviewPopoverController = nil;
    }
    
    if (IS_PORTRAIT) {
        titleView = nil;
        self.navigationItem.titleView = nil;
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"GAME_TABLE_VIEW_CONTROLLER_TITLE", nil), _pgnFileDoc.pgnFileInfo.fileName];
    }
    else {
        [self setupTitolo];
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return games.count;
    return  allGamesAndAllTags.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (!expandedPath) {
    //    return 80.0;
    //}
    //if (indexPath.row == expandedPath.row) {
    //    return 120.0;
    //}
    return 80.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSMutableString *titolo = [[NSMutableString alloc] init];
    [titolo appendString:[_pgnFileDoc.pgnFileInfo fileName]];
    [titolo appendString:@" - "];
    [titolo appendString:[NSString stringWithFormat:@"%d", _pgnFileDoc.pgnFileInfo.numberOfGames.intValue]];
    [titolo appendString:@" "];
    if (_pgnFileDoc.pgnFileInfo.numberOfGames.intValue == 1) {
        [titolo appendString:NSLocalizedString(@"GAME_GAME_INFO", nil)];
    }
    else {
        [titolo appendString:NSLocalizedString(@"GAMES_GAME_INFO", nil)];
    }
    return titolo;
}

- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (IS_IOS_7) {
        if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
            UITableViewHeaderFooterView *thfv = (UITableViewHeaderFooterView *)view;
            //[thfv setFrame:CGRectMake(0, 0, thfv.frame.size.width, thfv.frame.size.height + 20)];
            thfv.textLabel.textColor = [UIColor whiteColor];
            //thfv.contentView.backgroundColor = UIColorFromRGB(0xFFD700);
            thfv.contentView.backgroundColor = [UIColor blackColor];
            //thfv.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
            thfv.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25.0];
        }
    }
}

/*
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor yellowColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25.0];
    label.adjustsFontSizeToFitWidth = YES;
    label.text = [_pgnFileDoc.pgnFileInfo fileName];
    return nil;
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Game";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    //cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lin96bb.png"]];
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    
    
    //NSString *game = [games objectAtIndex:indexPath.row];
    NSString *game = [allGamesAndAllTags objectAtIndex:indexPath.row];
    
    PGNGame *cellPgnGame = [[PGNGame alloc] initWithPgn:game];
    
    
    if ([game rangeOfString:separator].length == 0) {
        game = [game stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    }
    
    //NSArray *gameArray = [game componentsSeparatedByString:separator];
    
    
    //NSString *w = [[[gameArray objectAtIndex:4] componentsSeparatedByString:@"\""] objectAtIndex:1];
    //NSString *b = [[[gameArray objectAtIndex:5] componentsSeparatedByString:@"\""] objectAtIndex:1];
    
    
    //NSString *w = [cellPgnGame getTagValueByTagName:@"White"];
    //NSString *b = [cellPgnGame getTagValueByTagName:@"Black"];
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    //cell.textLabel.text = [[w stringByAppendingString:@" - "] stringByAppendingString:b];
    cell.textLabel.text = [cellPgnGame getCellTextLabel];
    
    //NSMutableString *detail = [[NSMutableString alloc] init];
    
    //[detail appendString:[[[gameArray objectAtIndex:6] componentsSeparatedByString:@"\""] objectAtIndex:1]]; //Result
    //[detail appendString:@"  "];
    
    //NSError *error = NULL;
    //NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:ecoPattern options:NSRegularExpressionCaseInsensitive error:&error];
    //NSTextCheckingResult *result = [regex firstMatchInString:game options:0 range:NSMakeRange(0, [game length])];
    //if (result.range.location > 0) {
    //    [detail appendString:[[[game substringWithRange:result.range] componentsSeparatedByString:@"\""] objectAtIndex:1]]; //ECO
    //    [detail appendString:@"  "];
    //}
    
    //[detail appendString:[[[gameArray objectAtIndex:0] componentsSeparatedByString:@"\""] objectAtIndex:1]];
    //[detail appendString:@"  "];
    //[detail appendString:[[[gameArray objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:1]];
    //[detail appendString:@"  "];
    
    //regex = [[NSRegularExpression alloc] initWithPattern:eventDatePattern options:NSRegularExpressionCaseInsensitive error:&error];
    //result = [regex firstMatchInString:game options:0 range:NSMakeRange(0, [game length])];
    //if (result.range.location > 0) {
    //    [detail appendString:[[[game substringWithRange:result.range] componentsSeparatedByString:@"\""] objectAtIndex:1]]; //EventDate
    //    [detail appendString:@"  "];
    //}
    
    
    
    //NSDictionary *attributoMossa = @{NSFontAttributeName:[UIFont fontWithName:@"SemFigBold" size:12.0]};
    //NSString *mosse = [gameArray lastObject];
    //NSLog(@"%@", mosse);
    
    //attributoMosse = [[NSMutableAttributedString alloc] initWithString:mosse];
    
    //[self setAttributoFor:@"K" :mosse :attributoPezzo];
    //[self setAttributoFor:@"Q" :mosse :attributoPezzo];
    //[self setAttributoFor:@"R" :mosse :attributoPezzo];
    //[self setAttributoFor:@"B" :mosse :attributoPezzo];
    //[self setAttributoFor:@"N" :mosse :attributoPezzo];
    
    //NSMutableAttributedString *attributoMosse = [PGNGame getMovesWithAttributed:mosse];
    
    NSMutableAttributedString *attributoMosse = [cellPgnGame getAttributedGameMoves];
    
    
    //[ecoAttrText setAttributes:attributoMossa range:NSMakeRange(0, [mosse length])];
    
    
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    //cell.detailTextLabel.text = detail;
    cell.detailTextLabel.text = [cellPgnGame getCellDetailTextLabel];
    
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
        [gameLabel setTextColor:[UIColor blueColor]];
        //[gameLabel setText:[gameArray lastObject]];
        [gameLabel setAttributedText:attributoMosse];
        [cell.contentView addSubview:gameLabel];
    }
    else {
        [gameLabel setFrame:CGRectMake(cell.detailTextLabel.frame.origin.x, 58, tableView.contentSize.width - 70, 20)];
        //[gameLabel setText:[gameArray lastObject]];
        [gameLabel setAttributedText:attributoMosse];
    }
    
    
    
    UILabel *numGameLabel = (UILabel *)[cell viewWithTag:200];
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

        numGameLabel.tag = 200;
        [numGameLabel setBackgroundColor:[UIColor clearColor]];
        [numGameLabel setFont:[UIFont fontWithName:@"Courier-Bold" size:13]];
        [numGameLabel setTextColor:[UIColor redColor]];
        [numGameLabel setText:[NSString stringWithFormat:@"%d", (int)(indexPath.row + 1)]];
        [cell.contentView addSubview:numGameLabel];
    }
    else {
        [numGameLabel setText:[NSString stringWithFormat:@"%d", (int)(indexPath.row + 1)]];
    }
    
    //NSLog(@"Larghezza gamelabel = %f  con valore %@", gameLabel.frame.size.width, gameLabel.text);
    
    //NSLog(@"altezza textlabel = %f", cell.textLabel.frame.size.height);
    //NSLog(@"altezza detail = %f", cell.detailTextLabel.frame.size.height);
    
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
    
    NSString *game = [allGamesAndAllTags objectAtIndex:indexPath.row];
    
    PGNGame *previewPgnGame = [[PGNGame alloc] initWithPgn:game];
    NSString *g = [previewPgnGame getGameForCopy];
    
    
    /*
    NSMutableString *testoGame = [[NSMutableString alloc] init];
    NSMutableString *testoMosse = [[NSMutableString alloc] init];
    //NSString *game = [allGamesAndAllTags objectAtIndex:indexPath.row];
    for (NSString *t in [game componentsSeparatedByString:separator]) {
        if ([t hasPrefix:@"["]) {
            [testoGame appendString:t];
            [testoGame appendString:@"\n"];
        }
        else {
            [testoGame appendString:@"\n"];
            [testoMosse appendString:t];
        }
    }
    */
    

    
    //[testoGame appendString:g];
    
    if ((IS_PAD) || (IS_PAD_PRO)) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        GameBoardPreviewTableViewController *gbptvc = [[GameBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //[gbptvc setPgnFileDoc:_pgnFileDoc];
        //[gbptvc setNumGame:indexPath.row];
        [gbptvc setGame:g];
        gamePreviewPopoverController = [[UIPopoverController alloc] initWithContentViewController:gbptvc];
        [gamePreviewPopoverController presentPopoverFromRect:CGRectMake((cell.frame.size.width-60), cell.frame.origin.y  , cell.frame.size.width, cell.frame.size.height) inView:tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        GameBoardPreviewTableViewController *gbptvc = [[GameBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //[gbptvc setPgnFileDoc:_pgnFileDoc];
        //[gbptvc setNumGame:indexPath.row];
        [gbptvc setGame:g];
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

    /*
    if (IS_IOS_7 && IS_PAD) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        GameBoardPreviewTableViewController *gbptvc = [[GameBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [gbptvc setPgnFileDoc:_pgnFileDoc];
        [gbptvc setNumGame:indexPath.row];
        gamePreviewPopoverController = [[UIPopoverController alloc] initWithContentViewController:gbptvc];
        [gamePreviewPopoverController presentPopoverFromRect:CGRectMake((cell.frame.size.width-60), cell.frame.origin.y  , cell.frame.size.width, cell.frame.size.height) inView:tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        return;
        
        
        //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        //GameBoardPreviewTableViewController *gbptvc = [[GameBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //gamePreviewPopoverController = [[UIPopoverController alloc] initWithContentViewController:gbptvc];
        //[gamePreviewPopoverController presentPopoverFromRect:CGRectMake((cell.frame.size.width-60), cell.frame.origin.y  , cell.frame.size.width, cell.frame.size.height) inView:tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        return;
        
        if (!expandedPath) {
            expandedPath = indexPath;
        }
        else {
            expandedPath = nil;
        }
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        return;
        
        [self goToTheBoard:indexPath];
        //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        //GameBoardPreviewTableViewController *gbptvc = [[GameBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //gamePreviewPopoverController = [[UIPopoverController alloc] initWithContentViewController:gbptvc];
        //[gamePreviewPopoverController presentPopoverFromRect:CGRectMake((cell.frame.size.width-60), cell.frame.origin.y  , cell.frame.size.width, cell.frame.size.height) inView:tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self goToTheBoard:indexPath];
    }
    */ 
     
    /*
    NSString *game = [allGamesAndAllTags objectAtIndex:indexPath.row];
    
    @try {
        pgnGame = [[PGNGame alloc] initWithPgn:game];
    }
    @catch (NSException *exception) {
        UIAlertView *wrongGameAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"WRONG_SELECTED_GAME", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [wrongGameAlertView show];
        return;
    }
    @finally {
        
    }
    
    [pgnGame setIndexInAllGamesAllTags:[allGamesAndAllTags indexOfObject:game]];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    BoardViewController *bvc = [sb instantiateViewControllerWithIdentifier:@"BoardViewController"];
    bvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:bvc];
    //NSMutableString *gameMoves = [[NSMutableString alloc] initWithString:moves];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
        //[bvc setGameToView:gameMoves];
        //[bvc setGameToViewArray:gameArray];
        [bvc setPgnFileDoc:_pgnFileDoc];
        [bvc setPgnGame:pgnGame];
        [self presentModalViewController:boardNavigationController animated:YES];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    */
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString *gameToDelete = [allGamesAndAllTags objectAtIndex:indexPath.row];
        NSLog(@"Devo cancellare la partita %@", gameToDelete);
        [allGamesAndAllTags removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (twicGames) {
        return;
    }
    NSString *gameToMove = [allGamesAndAllTags objectAtIndex:fromIndexPath.row];
    [allGamesAndAllTags removeObject:gameToMove];
    [allGamesAndAllTags insertObject:gameToMove atIndex:toIndexPath.row];
    rearrangingTableView = YES;
    [tableView reloadData];
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (twicGames) {
        return NO;
    }
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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
    
    //[self selectGame:indexPath];
    [self goToTheGamePreview:indexPath];
    
    /*
    gameSel = [allGamesAndAllTags objectAtIndex:indexPath.row];
    
    @try {
        pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
    }
    @catch (NSException *exception) {
        UIAlertView *wrongGameAlertView = [[UIAlertView alloc] init];
        if ([exception.name isEqualToString:@"NSRangeException"]) {
            [wrongGameAlertView setTitle:nil];
            [wrongGameAlertView setMessage:NSLocalizedString(exception.name, nil)];
            [wrongGameAlertView setDelegate:nil];
            [wrongGameAlertView setCancelButtonIndex:0];
            [wrongGameAlertView addButtonWithTitle:@"OK"];
        }
        else if ([exception.name isEqualToString:@"WRONG_FEN_EXCEPTION_2"]) {
            [wrongGameAlertView setTitle:nil];
            [wrongGameAlertView setMessage:NSLocalizedString(exception.name, nil)];
            [wrongGameAlertView setDelegate:self];
            [wrongGameAlertView setCancelButtonIndex:0];
            [wrongGameAlertView addButtonWithTitle:@"No"];
            [wrongGameAlertView addButtonWithTitle:@"OK"];
            [wrongGameAlertView setTag:200];
        }
        [wrongGameAlertView show];
        return;
    }
    @finally {
        
    }
    
    //[pgnGame setIndexInAllGamesAllTags:[allGamesAndAllTags indexOfObject:gameSel]];
    
    //NSLog(@"L'indice di questa partita è %d", [allGamesAndAllTags indexOfObject:[pgnGame getGameForAllGamesAndAllTags]]);
    
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
        gameSel = [allGamesAndAllTags objectAtIndex:indexPath.row];
        lastSelectedGame = indexPath.row;
        indicePartita = [[_pgnFileDoc.pgnFileInfo getAllGamesAndTags] indexOfObject:gameSel];  //Serve per salvare permanente l'eventuale partita con FEN non corretto
    }
    
    @try {
        if ([PGNGame gameIsPositionWithRegularFen:gameSel]) {
            
            gameSel = [PGNGame checkStartColorAndFirstMove:gameSel]; //controlla e restituisce gameSel modificata tendendo conto del colore che deve muovere e la prima mossa.
            
            //NSLog(@"%@", gameSel);
            
            if ([PGNGame gameIsPositionWithRegularNumbering:gameSel]) {
                pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
            }
        }
        else {
            NSLog(@"La posizione non è corretta, la correggo");
            gameSel = [PGNGame getCorrectedGame:gameSel];
            [allGamesAndAllTags replaceObjectAtIndex:indexPath.row withObject:gameSel];
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
            [wrongGameAlertView show];
        }
        else if ([exception.name isEqualToString:@"WRONG_FEN_EXCEPTION_2"]) {
            
            wrongGameAlertView = [[UIAlertView alloc] initWithTitle:[PGNGame getTemporaryFen] message:NSLocalizedString(exception.name, nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:NSLocalizedString(@"FEN_CORRECT_SAVE", nil), NSLocalizedString(@"FEN_CORRECT_NO_SAVE", nil), nil];
            if ([callerMethod isEqualToString:@"goToTheGamePreview:"]) {
                [wrongGameAlertView setTag:200];
            }
            else if ([callerMethod isEqualToString:@"goToTheBoard:"]) {
                [wrongGameAlertView setTag:300];
            }
            [wrongGameAlertView show];
        }
        else if ([exception.name isEqualToString:@"WRONG_GAME_NUMBERING"]) {
            wrongGameAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(exception.name, nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:NSLocalizedString(@"WRONG_GAME_NUMBERING_SAVE", nil), NSLocalizedString(@"WRONG_GAME_NUMBERING_NO_SAVE", nil), nil];
            if ([callerMethod isEqualToString:@"goToTheGamePreview:"]) {
                [wrongGameAlertView setTag:400];
            }
            else if ([callerMethod isEqualToString:@"goToTheBoard:"]) {
                [wrongGameAlertView setTag:500];
            }
            [wrongGameAlertView show];
        }
        return NO;
    }
    return YES;
}

- (void) goToTheGamePreview:(NSIndexPath *) indexPath {
    
    if (![self checkTheGame:indexPath]) {
        return;
    }
    
    
    //[pgnGame setIndexInAllGamesAllTags:indexPath.row];   //**************************
    
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
        
        eseguiReload = YES;
        
        [gptvc setPgnFileDoc:_pgnFileDoc];
        [gptvc setPgnGame:pgnGame];
        [self.navigationController pushViewController:gptvc animated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void) goToTheBoard:(NSIndexPath *) indexPath {
    
    if (![self checkTheGame:indexPath]) {
        return;
    }
    
    [pgnGame setIndexInAllGamesAllTags:[allGamesAndAllTags indexOfObject:gameSel]];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    BoardViewController *bvc = [sb instantiateViewControllerWithIdentifier:@"BoardViewController"];
    bvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:bvc];
    //NSMutableString *gameMoves = [[NSMutableString alloc] initWithString:moves];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //[bvc setGameToView:gameMoves];
        //[bvc setGameToViewArray:gameArray];
        [bvc setPgnFileDoc:_pgnFileDoc];
        [bvc setPgnGame:pgnGame];
        //[self presentModalViewController:boardNavigationController animated:YES];
        [self presentViewController:boardNavigationController animated:YES completion:nil];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
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
    
    
    //actionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_NEW_GAME", nil), NSLocalizedString(@"MENU_NEW_POSITION", nil), NSLocalizedString(@"MENU_MANAGE_GAMES", nil), nil];
    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_NEW_GAME", nil)];
    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_NEW_POSITION", nil)];
    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_MANAGE_GAMES", nil)];
    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_PASTE_GAME", nil)];
    actionSheetMenu.delegate = self;
    actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
    
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
    
    //copyActionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_COPY_GAMES", nil), NSLocalizedString(@"MENU_DELETE_GAMES", nil),  NSLocalizedString(@"DONE", nil), nil];
    
    copyActionSheetMenu = [[UIActionSheet alloc] init];
    copyActionSheetMenu.delegate = self;
    copyActionSheetMenu.tag = 100;
    [copyActionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_COPY_GAMES", nil)];
    [copyActionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_DELETE_GAMES", nil)];
    [copyActionSheetMenu addButtonWithTitle:NSLocalizedString(@"DONE", nil)];
    copyActionSheetMenu.cancelButtonIndex = [copyActionSheetMenu addButtonWithTitle:cancelButton];
    [copyActionSheetMenu showFromBarButtonItem:button animated:YES];
}

- (void) twicActionButtonPressed:(UIBarButtonItem *) sender {
    if (twicActionSheetMenu.window ) {
        [twicActionSheetMenu dismissWithClickedButtonIndex:0 animated:YES];
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
    //twicActionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles: NSLocalizedString(@"MENU_MANAGE_GAMES", nil), nil];
    twicActionSheetMenu = [[UIActionSheet alloc] init];
    twicActionSheetMenu.delegate = self;
    twicActionSheetMenu.tag = 200;
    [twicActionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_MANAGE_GAMES", nil)];
    twicActionSheetMenu.cancelButtonIndex = [twicActionSheetMenu addButtonWithTitle:cancelButton];
    [twicActionSheetMenu showFromBarButtonItem:button animated:YES];
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
                    NSString *gameAndTags = [allGamesAndAllTags objectAtIndex:indexPath.row];
                    [copyArray addObject:gameAndTags];
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
                NSString *msg;
                if (partiteSelezionateDaCopiareEliminare.count == 1) {
                    msg = NSLocalizedString(@"CONFIRM_DELETE_ONE", nil);
                }
                else {
                    msg = [NSString stringWithFormat:NSLocalizedString(@"CONFIRM_DELETE_MANY", nil), partiteSelezionateDaCopiareEliminare.count];
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
            if (rearrangingTableView) {
                NSLog(@"Devo salvare il file perchè ho modificato la tabella");
                [_pgnFileDoc.pgnFileInfo saveAllGamesAndTags:allGamesAndAllTags];
            }
            return;
        }
    }
    
    if (actionSheet.tag == 200) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:NSLocalizedString(@"MENU_MANAGE_GAMES", nil)]) {
            self.tableView.allowsMultipleSelectionDuringEditing = YES;
            [self.tableView setValue:UIColorFromRGB(0x4CE466) forKey:@"multiselectCheckmarkColor"];
            [self.tableView setEditing:YES animated:YES];
            actionBarButtonItem = self.navigationItem.rightBarButtonItem;
            UIBarButtonItem *manageCopyBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(manageCopyButtonPressed:)];
            self.navigationItem.rightBarButtonItem = manageCopyBarButtonItem;
        }
        return;
    }
    if (actionSheet.tag == 300) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:NSLocalizedString(@"MENU_NEW_GAME", nil)]) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
            BoardViewController *bvc = [sb instantiateViewControllerWithIdentifier:@"BoardViewController"];
            [bvc setDelegate:self];
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
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
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
        if ([title isEqualToString:NSLocalizedString(@"MENU_MANAGE_GAMES", nil)]) {
            self.tableView.allowsMultipleSelectionDuringEditing = YES;
            [self.tableView setValue:UIColorFromRGB(0x4CE466) forKey:@"multiselectCheckmarkColor"];
            [self.tableView setEditing:YES animated:YES];
            rearrangingTableView = NO;
            actionBarButtonItem = self.navigationItem.rightBarButtonItem;
            UIBarButtonItem *manageCopyBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(manageCopyButtonPressed:)];
            self.navigationItem.rightBarButtonItem = manageCopyBarButtonItem;
            return;
        }
        if ([title isEqualToString:NSLocalizedString(@"MENU_PASTE_GAME", nil)]) {
            [self managePasteGame];
            return;
        }
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
        //[self presentModalViewController:pastedGameNavigationController animated:YES];
        [self presentViewController:pastedGameNavigationController animated:YES completion:nil];
    });
    //[self presentViewController:pastedGameNavigationController animated:YES completion:nil];
    
    
}

#pragma mark - AlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //Gestione ChessStudioLight in caso superamento numero mosse consentito
    if (alertView.tag == 1000) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"CHESS_STUDIO_APP_STORE", nil)]];
        }
        return;
    }
    
    if (alertView.tag == 100) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"OK"]) {
            //NSMutableArray *gamesToDelete = [[NSMutableArray alloc] init];
            NSMutableIndexSet *indexGamesToDelete = [NSMutableIndexSet indexSet];
            for (NSIndexPath *indexPath in partiteSelezionateDaCopiareEliminare) {
                //NSString *item = [allGamesAndAllTags objectAtIndex:indexPath.row];
                //[gamesToDelete addObject:item];
                [indexGamesToDelete addIndex:indexPath.row];
            }
            //[allGamesAndAllTags removeObjectsInArray:gamesToDelete];
            [allGamesAndAllTags removeObjectsAtIndexes:indexGamesToDelete];
            [self.tableView deleteRowsAtIndexPaths:partiteSelezionateDaCopiareEliminare withRowAnimation:UITableViewRowAnimationFade];
            //[_pgnFileDoc.pgnFileInfo saveAllGamesAndTags:allGamesAndAllTags];
            
            
            
            
            if ([_pgnFileDoc.pgnFileInfo isInCloud]) {
                NSLog(@"Adesso salvo tutte le partite in Cloud");
                [self saveDatabaseInCloud];
            }
            else {
                NSLog(@"Adesso salvo tutte le partite non in Cloud");
                [_pgnFileDoc.pgnFileInfo salvaTutteLePartite];
            }
        }
    }
    if (alertView.tag == 200 || alertView.tag == 300) {
        NSString *scelta = [alertView buttonTitleAtIndex:buttonIndex];
        if ([scelta isEqualToString:NSLocalizedString(@"MENU_CANCEL", nil)]) {
            return;
        }
        else {
            NSString *newGameSel = [PGNGame getGameWithNumberOfMoveInFenCorrected:gameSel];
            NSInteger *indexGame = [allGamesAndAllTags indexOfObject:gameSel];
            [allGamesAndAllTags replaceObjectAtIndex:indexGame withObject:newGameSel];
            gameSel = newGameSel;
            if ([scelta isEqualToString:NSLocalizedString(@"FEN_CORRECT_SAVE", nil)]) {
                [_pgnFileDoc.pgnFileInfo salvaTutteLePartite];
            }
            if (alertView.tag == 200) {
                [self goToTheGamePreview:nil];
            }
            else if (alertView.tag == 300) {
                [self goToTheBoard:nil];
            }
        }
    }
    if (alertView.tag == 400 || alertView.tag == 500) {
        NSString *scelta = [alertView buttonTitleAtIndex:buttonIndex];
        if ([scelta isEqualToString:NSLocalizedString(@"MENU_CANCEL", nil)]) {
            return;
        }
        else {
            if (alertView.tag == 400) {
                [self goToTheGamePreview:nil];
            }
            else if (alertView.tag == 500) {
                [self goToTheBoard:nil];
            }
        }
    }
}

- (void) doneButtonPressed {
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = actionBarButtonItem;
}

#pragma mark - Implementazione Metodi GamePreviewTableViewControllerDelegate

- (void) aggiorna:(PGNGame *)pgnGame {
    //NSLog(@"Eseguo Metodo Delete di GamePreviewTableViewController");
    eseguiReload = YES;
}

- (PGNGame *) getPreviousGame {
    if (lastSelectedGame == 0) {
        return nil;
    }
    lastSelectedGame--;
    gameSel = [allGamesAndAllTags objectAtIndex:lastSelectedGame];
    pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
    [pgnGame setIndexInAllGamesAllTags:lastSelectedGame];
    return pgnGame;
}

- (PGNGame *) getNextGame {
    if (lastSelectedGame == (allGamesAndAllTags.count - 1)) {
        return nil;
    }
    lastSelectedGame++;
    gameSel = [allGamesAndAllTags objectAtIndex:lastSelectedGame];
    pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
    [pgnGame setIndexInAllGamesAllTags:lastSelectedGame];
    return pgnGame;
}

#pragma mark - Implementazione metodi PgnPastedGameViewControllerDelegate

- (void) saveGames:(NSArray *)pastedGames {
    [_pgnFileDoc.pgnFileInfo appendGamesAndTagsToPgnFile:pastedGames];
    [self.tableView reloadData];
}

#pragma mark - Metodi per gestire il salvataggio dei dati in cloud

- (void) saveDatabaseInCloud {
    NSLog(@"Il database si trova nel CLOUD quindi salvo nel local cloud");
    NSLog(@"%@", _pgnFileDoc.pgnFileInfo.localCloudPath);
    [_pgnFileDoc.pgnFileInfo salvaTutteLePartite];
    BOOL salvato = [NSKeyedArchiver archiveRootObject:_pgnFileDoc.pgnFileInfo toFile:_pgnFileDoc.pgnFileInfo.localCloudPath];
    if (salvato) {
        NSLog(@"Ho creato pure il dat che devo inviare al cloud perchè aggiornato");
        NSString *fileString = _pgnFileDoc.pgnFileInfo.localCloudPath;
        NSLog(@"%@", fileString);
        
        NSURL *urlForSaveCloud = [self urlForSaveCloud:_pgnFileDoc.pgnFileInfo.fileName];
        NSLog(@"URL FOR SAVE CLOUD = %@", urlForSaveCloud);
        
        NSURL *metadataURL = [[NSURL alloc] initFileURLWithPath:fileString];
        NSURL *cloudURL = urlForSaveCloud;
        
        
        NSLog(@"fileURL: %@", metadataURL);
        NSLog(@"destURL: %@", cloudURL);
        
        
        NSLog(@"A questo punto devo inviare il file su cloud");
        
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:cloudURL.path]) {
            NSLog(@"Il file %@ esiste nella dir destinazione", cloudURL.path);
            [self removeDocumentAtUrl:metadataURL :cloudURL];
            
        }
        
        
        /*
         NSLog(@"A questo punto devo inviare il file su cloud");
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
         NSError * error;
         BOOL moved = [[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:fileURL destinationURL:destURL error:&error];
         if (moved) {
         NSLog(@"Moved %@ to %@", fileURL, destURL);
         //[self loadDocAtURL:destURL];
         } else {
         NSLog(@"Failed to move %@ to %@: %@", fileURL, destURL, error.localizedDescription);
         }
         });*/
    }
}

- (NSURL *)urlForSaveCloud:(NSString *)filename {
    // be sure to insert "Documents" into the path
    filename = [filename stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"];
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL *pathURL = [baseURL URLByAppendingPathComponent:@"Documents"];
    NSURL *destinationURL = [pathURL URLByAppendingPathComponent:filename];
    return destinationURL;
}

- (void) removeDocumentAtUrl:(NSURL *)fileURL :(NSURL *)destURL {
    
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    // Wrap in file coordinator
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [fileCoordinator coordinateWritingItemAtURL:fileURL
                                            options:NSFileCoordinatorWritingForDeleting
                                              error:nil
                                         byAccessor:^(NSURL* writingURL) {
                                             // Simple delete to start
                                             
                                             NSError *error1 = nil;
                                             NSFileManager* fileManager = [[NSFileManager alloc] init];
                                             BOOL deleted = [fileManager removeItemAtURL:destURL error:&error1];
                                             if (deleted) {
                                                 NSLog(@"Eliminato file at %@", fileURL);
                                             }
                                             
                                             
                                             NSError * error;
                                             BOOL moved = [[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:fileURL destinationURL:destURL error:&error];
                                             if (moved) {
                                                 NSLog(@"Moved %@ to %@", fileURL, destURL);
                                                 //[self loadDocAtURL:destURL];
                                             } else {
                                                 NSLog(@"Failed to move %@ to %@: %@", fileURL, destURL, error.localizedDescription);
                                             }
                                             
                                         }];
    });
}

//- (void) setAttributoFor:(NSString *)s :(NSString *)testo :(NSDictionary *)dict {
//    NSError *error = NULL;
//    //NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:s options:NSRegularExpressionCaseInsensitive error:&error];
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:s options:0 error:&error];
//    NSArray *matches = [regex matchesInString:testo options:0 range:NSMakeRange(0, [testo length])];
//    for (NSTextCheckingResult *match in matches) {
//        NSRange matchRange = [match range];
//        //NSLog(@"%@ = %lu  %lu", s, (unsigned long)matchRange.location, (unsigned long)matchRange.length);
//        //[attributoMosse setAttributes:dict range:matchRange];
//    }
//}

@end
