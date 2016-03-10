//
//  PgnMentorTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 25/11/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "PgnMentorTableViewController.h"
#import "Reachability.h"
#import "PgnMentorPlayersTableViewController.h"
#import "PgnMentorOpeningsTableViewController.h"
#import "PgnMentorEventsTableViewController.h"
#import "UtilToView.h"
#import "SWRevealViewController.h"

@interface PgnMentorTableViewController () {

    
    Reachability *internetReachability;
    UIActivityIndicatorView *aiv;
    
    
    UIAlertView *downloadAlertView;
    
    NSArray *sections;
    
    
    HTMLDocument *htmlDocument;
    NSArray *tableArray;
    
    NSMutableArray *listPlayersPgn;
    NSMutableArray *listPlayers;
    NSMutableArray *listLinkPlayers;
    
    NSMutableArray *listAperturePgn;
    NSMutableArray *listMosseApertura;
    NSMutableArray *listLinkAperture;
    
    NSMutableArray *listEventsPgn;
    NSMutableArray *listEvents;
    NSMutableArray *listLinkEvents;

}

@end

#define MENTOR @"http://www.pgnmentor.com/"

@implementation PgnMentorTableViewController

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
    
    
    
    
    //[self loadHtml];
    //[self loadPlayers];
    //[self loadOpenings];
    //[self loadEvents];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    sections = [NSArray arrayWithObjects:@"Players", @"Openings", @"Events", nil];
    
    self.navigationItem.title = @"PGN Mentor";
    
    
    [self setupTitle:@"PGN Mentor"];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self setRefreshControl:refreshControl];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
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
    
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x76EEC6);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x76EEC6);
    
    //NSArray *viewControllers = self.navigationController.viewControllers;
    //NSLog(@"VIEW CONTROLLERS:%lu", (unsigned long)viewControllers.count);
    //if (viewControllers.count == 1) {
    //    NSLog(@"Sono arrivato alla radice");
    //}
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[self setupPgnMentor];
    
    internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
    //NSLog(@"NETWORK STATUS = %d", networkStatus);
    if (networkStatus == NotReachable) {
        UIAlertView *notReachableAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_INTERNET", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [notReachableAlertView show];
        return;
    }
    
    
    if (!htmlDocument) {
        [self.tableView setAllowsSelection:NO];
        downloadAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"DATABASE_DOWNLOADING_IOS7", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:nil, nil];
        downloadAlertView.tag = 100;
        [downloadAlertView show];
        [self performSelectorInBackground:@selector(loadHtml) withObject:nil];
    }
}

- (void) checkRevealed {
    UIViewController *sourceViewController = nil;
    NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
    if ( index != 0 && index != NSNotFound ) {
        sourceViewController = [self.navigationController.viewControllers objectAtIndex:index-1];
    }
    if (!sourceViewController) {
        SWRevealViewController *revealViewController = [self revealViewController];
        [revealViewController panGestureRecognizer];
        [revealViewController tapGestureRecognizer];
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon.png"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
}

- (void) setupTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    if (IS_PAD) {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:35.0];
    }
    else if (IS_PAD_PRO) {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:38.0];
    }
    else {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25.0];
    }
    
    //titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textColor = UIColorFromRGB(0x0000CD);
    titleLabel.text = title;
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationItem.titleView = titleLabel;
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    //NSLog(@"Mi sto rinfrescando");
    //[self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
    [self setupPgnMentor];
    [refreshControl endRefreshing];
}

- (void) setupPgnMentor {
    htmlDocument = nil;
    internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
    //NSLog(@"NETWORK STATUS = %d", networkStatus);
    if (networkStatus == NotReachable) {
        UIAlertView *notReachableAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_INTERNET", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [notReachableAlertView show];
        return;
    }
    
    if (!htmlDocument) {
        //NSLog(@"Qui ci sono passato");
        [self.tableView setAllowsSelection:NO];
        downloadAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"DATABASE_DOWNLOADING_IOS7", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:nil, nil];
        downloadAlertView.tag = 100;
        [downloadAlertView show];
        [self performSelectorInBackground:@selector(loadHtml) withObject:nil];
        //[self loadHtml];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 100) {
        [self.tableView setAllowsSelection:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if (alertView.tag == 1000) {
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"CHESS_STUDIO_APP_STORE", nil)]];
            }
    }
}

#pragma mark - Metodi per caricare i dati da PGN Mentor


- (void) loadHtml {
    NSURL *url = [NSURL URLWithString:@"http://www.pgnmentor.com/files.html"];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
    
    [self.tableView setAllowsSelection:YES];
    
    if (!htmlData) {
        NSLog(@"DATI INESISTENTI");
        UIAlertView *notReachableAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_INTERNET", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [notReachableAlertView show];
        [downloadAlertView dismissWithClickedButtonIndex:0 animated:NO];
        return;
    }
    
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    htmlDocument = [HTMLDocument documentWithString:htmlString];
    HTMLSelector *selector = [HTMLSelector selectorForString:@"table"];
    tableArray = [htmlDocument nodesMatchingParsedSelector:selector];
    if (aiv) {
        [aiv stopAnimating];
        [aiv removeFromSuperview];
        aiv = nil;
    }
    if (downloadAlertView) {
        [downloadAlertView dismissWithClickedButtonIndex:0 animated:YES];
        downloadAlertView = nil;
    }
    [self.tableView setAllowsSelection:YES];
}


/*
- (void) loadPlayers {
    listPlayers = [[NSMutableArray alloc] init];
    listPlayersPgn = [[NSMutableArray alloc] init];
    listLinkPlayers = [[NSMutableArray alloc] init];

    NSUInteger numTable = 0;
    for (HTMLElement *ele in tableArray) {
        NSDictionary *tableAttr = [ele attributes];
        NSString *border = [tableAttr objectForKey:@"border"];
        NSString *cellSpacing = [tableAttr objectForKey:@"cellspacing"];
        if (numTable == 2) {
            break;
        }
        if ([border isEqualToString:@"1"] && [cellSpacing isEqualToString:@"10"]) {
            numTable++;
            NSArray *body = [ele childElementNodes];
            NSArray *trArray = [[body objectAtIndex:0] childElementNodes];
            for (HTMLElement *trEl in trArray) {
                HTMLSelector *selector1 = [HTMLSelector selectorForString:@"a"];
                NSArray *aArray = [trEl nodesMatchingParsedSelector:selector1];
                HTMLElement *aEl = [aArray objectAtIndex:0];
                NSString *link = [MENTOR stringByAppendingString:[[aEl attributes] objectForKey:@"href"]];
                HTMLSelector *selector2 = [HTMLSelector selectorForString:@"td"];
                NSArray *tdArray = [trEl nodesMatchingParsedSelector:selector2];
                HTMLElement *tdEl = [tdArray objectAtIndex:1];
                [listPlayers addObject:[tdEl textContent]];
                [listPlayersPgn addObject:[aEl textContent]];
                [listLinkPlayers addObject:link];
            }
        }
    }
}

- (void) loadOpenings {
    
    listAperturePgn = [[NSMutableArray alloc] init];
    listMosseApertura = [[NSMutableArray alloc] init];
    listLinkAperture = [[NSMutableArray alloc] init];
    
    for (HTMLElement *ele in tableArray) {
        NSDictionary *tableAttr = [ele attributes];
        NSString *border = [tableAttr objectForKey:@"border"];
        NSString *cellSpacing = [tableAttr objectForKey:@"cellspacing"];
        if ([border isEqualToString:@"3"] && [cellSpacing isEqualToString:@"10"]) {
            NSArray *body = [ele childElementNodes];
            NSArray *trArray = [[body objectAtIndex:0] childElementNodes];
            for (HTMLElement *trEl in trArray) {
                HTMLSelector *selector1 = [HTMLSelector selectorForString:@"a"];
                NSArray *aArray = [trEl nodesMatchingParsedSelector:selector1];
                HTMLElement *aEl = [aArray objectAtIndex:0];
                NSString *linkApertura = [MENTOR stringByAppendingString:[[aEl attributes] objectForKey:@"href"]];
                
                [listLinkAperture addObject:linkApertura];
                
                HTMLSelector *selector2 = [HTMLSelector selectorForString:@"td"];
                NSArray *tdArray = [trEl nodesMatchingParsedSelector:selector2];
                //HTMLElement *tdEl = [tdArray objectAtIndex:1];
                //NSString *nomeApertura = [tdEl textContent];
                //[listAperturePgn addObject:[aEl textContent]];
                
                HTMLElement *numGamesEl = [tdArray objectAtIndex:1];
                NSOrderedSet *numGamesSet = [numGamesEl children];
                //NSLog(@"%@", numGamesSet);
                NSArray *numGameArray = [numGamesSet array];
                NSMutableString *nomeAndNumGames = [[NSMutableString alloc] init];
                for (HTMLNode *node in numGameArray) {
                    if ([node isKindOfClass:[HTMLTextNode class]]) {
                        HTMLTextNode *t = (HTMLTextNode *)node;
                        [nomeAndNumGames appendString:[t textContent]];
                        //[nomeAndNumGames appendString:@" - "];
                    }
                    else if ([node isKindOfClass:[HTMLElement class]]) {
                        HTMLElement *e = (HTMLElement *)node;
                        
                        if ([[e tagName] isEqualToString:@"br"]) {
                            [nomeAndNumGames appendString:@" - "];
                        }
                        else if ([[e tagName] isEqualToString:@"img"]) {
                            
                            //NSLog(@"%@", [[e attributes] objectForKey:@"alt"]);
                            NSString *pezzo = [[e attributes] objectForKey:@"alt"];
                            if ([pezzo hasPrefix:@"Kn"]) {
                                [nomeAndNumGames appendString:@"N"];
                            }
                            else if ([pezzo hasPrefix:@"Bish"]) {
                                [nomeAndNumGames appendString:@"B"];
                            }
                            else if ([pezzo hasPrefix:@"King"]) {
                                [nomeAndNumGames appendString:@"N"];
                            }
                            else if ([pezzo hasPrefix:@"Queen"]) {
                                [nomeAndNumGames appendString:@"Q"];
                            }
                            else if ([pezzo hasPrefix:@"Rook"]) {
                                [nomeAndNumGames appendString:@"R"];
                            }
                        }
                    }
                }
                
                NSString *finalNome = [nomeAndNumGames stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                //NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   %@", finalNome);
                [listAperturePgn addObject:finalNome];
                
                
                HTMLElement *mosseEl = [tdArray objectAtIndex:2];
                NSOrderedSet *tdSEt = [mosseEl children];
                NSArray *ar = [tdSEt array];
                NSMutableString *moves = [[NSMutableString alloc] init];
                for (HTMLNode *node in ar) {
                    if ([node isKindOfClass:[HTMLElement class]]) {
                        HTMLElement *e = (HTMLElement *)node;
                        NSLog(@"%@", [[e attributes] objectForKey:@"alt"]);
                        NSString *pezzo = [[e attributes] objectForKey:@"alt"];
                        if ([pezzo hasPrefix:@"Kn"]) {
                            [moves appendString:@"N"];
                        }
                        else if ([pezzo hasPrefix:@"Bish"]) {
                            [moves appendString:@"B"];
                        }
                        else if ([pezzo hasPrefix:@"King"]) {
                            [moves appendString:@"N"];
                        }
                        else if ([pezzo hasPrefix:@"Queen"]) {
                            [moves appendString:@"Q"];
                        }
                        else if ([pezzo hasPrefix:@"Rook"]) {
                            [moves appendString:@"R"];
                        }
                    }
                    else if ([node isKindOfClass:[HTMLTextNode class]]) {
                        HTMLTextNode *t = (HTMLTextNode *)node;
                        NSLog(@"%@", [t textContent]);
                        [moves appendString:[t textContent]];
                    }
                }
                NSString *finalMoves = [moves stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                //NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   %@", finalMoves);
                [listMosseApertura addObject:finalMoves];
            }
        }
    }
}

- (void) loadEvents {
    
    listEvents = [[NSMutableArray alloc] init];
    listEventsPgn = [[NSMutableArray alloc] init];
    listLinkEvents = [[NSMutableArray alloc] init];
    
    NSUInteger numTable = 0;
    for (HTMLElement *ele in tableArray) {
        NSDictionary *tableAttr = [ele attributes];
        NSString *border = [tableAttr objectForKey:@"border"];
        NSString *cellSpacing = [tableAttr objectForKey:@"cellspacing"];
        if ([border isEqualToString:@"1"] && [cellSpacing isEqualToString:@"10"]) {
            numTable++;
            if (numTable<3) {
                continue;
            }
            NSArray *body = [ele childElementNodes];
            NSArray *trArray = [[body objectAtIndex:0] childElementNodes];
            for (HTMLElement *trEl in trArray) {
                HTMLSelector *selector1 = [HTMLSelector selectorForString:@"a"];
                NSArray *aArray = [trEl nodesMatchingParsedSelector:selector1];
                HTMLElement *aEl = [aArray objectAtIndex:0];
                NSString *link = [MENTOR stringByAppendingString:[[aEl attributes] objectForKey:@"href"]];
                HTMLSelector *selector2 = [HTMLSelector selectorForString:@"td"];
                NSArray *tdArray = [trEl nodesMatchingParsedSelector:selector2];
                HTMLElement *tdEl = [tdArray objectAtIndex:1];
                [listEvents addObject:[tdEl textContent]];
                [listEventsPgn addObject:[aEl textContent]];
                [listLinkEvents addObject:link];
            }
        }
    }
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return sections.count;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
    
    if (section == 0) {
        return listPlayers.count;
    }
    else if (section == 1) {
        return listAperturePgn.count;
    }
    else if (section == 2) {
        return listEvents.count;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
    return [sections objectAtIndex:section];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        cell.backgroundColor = UIColorFromRGB(0XFAFAD2);
    }
    else if (indexPath.row == 1) {
        cell.backgroundColor = UIColorFromRGB(0XF5F5F5);
    }
    else if (indexPath.row == 2) {
        cell.backgroundColor = UIColorFromRGB(0XCAFF70);
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Pgn Mentor Database";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"PGN_MENTOR_PLAYERS", nil);
        cell.detailTextLabel.text = NSLocalizedString(@"PGN_MENTOR_PLAYERS_DETAIL", nil);;
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"PGN_MENTOR_OPENINGS", nil);
        cell.detailTextLabel.text = NSLocalizedString(@"PGN_MENTOR_OPENINGS_DETAIL", nil);
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"PGN_MENTOR_EVENTS", nil);
        cell.detailTextLabel.text = NSLocalizedString(@"PGN_MENTOR_EVENTS_DETAIL", nil);
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.detailTextLabel.text = nil;
    
    return cell;
    
    
    // Configure the cell...
    if (indexPath.section == 0) {
        cell.textLabel.text = [listPlayers objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [listPlayersPgn objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1) {
        cell.textLabel.text = [listAperturePgn objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [listMosseApertura objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 2) {
        cell.textLabel.text = [listEvents objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [listEventsPgn objectAtIndex: indexPath.row];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *notReachableAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_INTERNET", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [notReachableAlertView show];
        return;
    }
    
    if (!htmlDocument) {
        UIAlertView *noDataAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PGN_MENTOR_NO_DATA_TITLE", nil) message:NSLocalizedString(@"PGN_MENTOR_NO_DATA_MESSAGE", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noDataAlertView show];
        return;
    }
    
    
    if (indexPath.row == 0) {
        UIStoryboard *sb = [UtilToView getStoryBoard];
        PgnMentorPlayersTableViewController *pmptvc = [sb instantiateViewControllerWithIdentifier:@"PgnMentorPlayersTableViewController"];
        [pmptvc setHtmlDocument:htmlDocument];
        [self.navigationController pushViewController:pmptvc animated:YES];
    }
    else if (indexPath.row == 1) {
        if (IsChessStudioLight) {
            UIAlertView *lightAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"LIGHT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"OK", nil];
            lightAlertView.tag = 1000;
            [lightAlertView show];
            return;
        }
        UIStoryboard *sb = [UtilToView getStoryBoard];
        PgnMentorOpeningsTableViewController *pmotvc = [sb instantiateViewControllerWithIdentifier:@"PgnMentorOpeningsTableViewController"];
        [pmotvc setHtmlDocument:htmlDocument];
        [self.navigationController pushViewController:pmotvc animated:YES];
    }
    else if (indexPath.row == 2) {
        UIStoryboard *sb = [UtilToView getStoryBoard];
        PgnMentorEventsTableViewController *pmetvc = [sb instantiateViewControllerWithIdentifier:@"PgnMentorEventsTableViewController"];
        [pmetvc setHtmlDocument:htmlDocument];
        [self.navigationController pushViewController:pmetvc animated:YES];
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
