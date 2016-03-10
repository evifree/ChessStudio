//
//  EcoTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 18/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "EcoTableViewController.h"
#import "GamesTableViewController.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "SWRevealViewController.h"

@interface EcoTableViewController () {
    //NSArray *openingArray;
    //NSArray *ecoArray;
    //NSMutableDictionary *ecoNumber;
    //NSMutableDictionary *ecoDictionary;
    //NSMutableDictionary *ecoDictionaryNoDoppie;
    NSDictionary *ecoABCDE;
    
    NSCountedSet *ecoA;
    NSCountedSet *ecoB;
    NSCountedSet *ecoC;
    NSCountedSet *ecoD;
    NSCountedSet *ecoE;
    
    
    NSMutableArray *allEcoArray;
    
    
    NSCountedSet *ecoCountedSet;
    NSMutableArray *A;
    NSMutableArray *B;
    NSMutableArray *C;
    NSMutableArray *D;
    NSMutableArray *E;
    int numA;
    int numB;
    int numC;
    int numD;
    int numE;
    
    
    UIColor *color1;
    UIColor *color2;
    
    SWRevealViewController *revealViewController;
}

@end

@implementation EcoTableViewController

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
    
    if (IsChessStudioLight) {
        //if (IS_IOS_7) {
            self.canDisplayBannerAds = YES;
        //}
    }
    
    [self checkRevealed];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0xB0E2FF);
    
    if (IS_PHONE) {
        
        self.navigationItem.title = NSLocalizedString(@"OPENINGS_ECO_GAME_INFO", nil);
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
        label1.text = [NSString stringWithFormat:NSLocalizedString(@"ECO_TABLE_VIEW_CONTROLLER_TITLE", nil), @""];
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
        
        if (revealViewController) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:35.0];
            NSString *titolo = NSLocalizedString(@"OPENINGS_SW", nil);
            titleLabel.textColor = UIColorFromRGB(0x0000CD);
            titleLabel.text = titolo;
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            self.navigationItem.titleView = titleLabel;
        }
        else {
            NSString *titolo = [NSString stringWithFormat:NSLocalizedString(@"ECO_TABLE_VIEW_CONTROLLER_TITLE", nil), _pgnFileDoc.pgnFileInfo.fileName];
            self.navigationItem.title = titolo;
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //NSLog(@"Memory warning da EcoTableViewController");
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

- (void) checkRevealed {
    revealViewController = nil;
    NSArray *parents = self.parentViewController.childViewControllers;
    UIViewController *sourceViewController = [parents objectAtIndex:0];
    if ([sourceViewController isKindOfClass:[EcoTableViewController class]]) {
        revealViewController = [self revealViewController];
        [revealViewController panGestureRecognizer];
        [revealViewController tapGestureRecognizer];
        [revealViewController disablePanGesture];
        //UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon.png"] style:UIBarButtonItemStyleBordered target:revealViewController action:@selector(revealToggle:)];
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(ecoTableViewControllerRevealToggle)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
    //NSLog(@"%@", sourceViewController);
    //NSLog(@"%@", self.parentViewController.childViewControllers);
    //NSLog(@"%@", self.parentViewController.parentViewController);
}

- (void) ecoTableViewControllerRevealToggle {
    if (revealViewController) {
        [revealViewController revealToggleAnimated:YES];
    }
}

- (void) setPgnFileDoc:(PgnFileDocument *)pgnFileDoc {
    _pgnFileDoc = pgnFileDoc;
    
    self.navigationItem.title = @"ECO";
    
    [self initData];
}

- (void) initData {
    ecoCountedSet = [_pgnFileDoc.pgnFileInfo getAllEcoByCountedSet];
    A = [[NSMutableArray alloc] init];
    B = [[NSMutableArray alloc] init];
    C = [[NSMutableArray alloc] init];
    D = [[NSMutableArray alloc] init];
    E = [[NSMutableArray alloc] init];
    numA = 0;
    numB = 0;
    numC = 0;
    numD = 0;
    numE = 0;
    for (NSString *eco in [[ecoCountedSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        if ([eco rangeOfString:@"[ECO \"A"].length > 0) {
            [A addObject:eco];
            numA += [ecoCountedSet countForObject:eco];
        }
        if ([eco rangeOfString:@"[ECO \"B"].length > 0) {
            [B addObject:eco];
            numB += [ecoCountedSet countForObject:eco];
        }
        if ([eco rangeOfString:@"[ECO \"C"].length > 0) {
            [C addObject:eco];
            numC += [ecoCountedSet countForObject:eco];
        }
        if ([eco rangeOfString:@"[ECO \"D"].length > 0) {
            [D addObject:eco];
            numD += [ecoCountedSet countForObject:eco];
        }
        if ([eco rangeOfString:@"[ECO \"E"].length > 0) {
            [E addObject:eco];
            numE += [ecoCountedSet countForObject:eco];
        }
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_PAD_PRO) {
        return 140.0;
    }
    if (IS_PAD) {
        return 120.0;
    }
    if (IS_IPHONE_4_OR_LESS) {
        return 40.0;
    }
    if (IS_IPHONE_5) {
        return 55.0;
    }
    if (IS_IPHONE_6) {
        return 60.0;
    }
    if (IS_IPHONE_6P) {
        return 70.0;
    }
    return 40.0;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        [cell setBackgroundColor:[UtilToView getEcoColor:@"A"]];
//    }
//    else if (indexPath.section == 1) {
//        [cell setBackgroundColor:[UtilToView getEcoColor:@"B"]];
//    }
//    else if (indexPath.section == 2) {
//        [cell setBackgroundColor:[UtilToView getEcoColor:@"C"]];
//    }
//    else if (indexPath.section == 3) {
//        [cell setBackgroundColor:[UtilToView getEcoColor:@"D"]];
//    }
//    else if (indexPath.section == 4) {
//        [cell setBackgroundColor:[UtilToView getEcoColor:@"E"]];
//    }
//    else if (indexPath.section == 5) {
//        [cell setBackgroundColor:[UtilToView getEcoColor:@"0"]];
//    }
    
    if (indexPath.section == 0) {
        color1 = UIColorFromRGB(0xCCF22D);
        color2 = UIColorFromRGB(0x74A605);
    }
    else if (indexPath.section == 1) {
        color1 = UIColorFromRGB(0xfcf9a5);
        color2 = UIColorFromRGB(0xfbf555);
    }
    else if (indexPath.section == 2) {
        color1 = UIColorFromRGB(0x74defa);
        color2 = UIColorFromRGB(0x40acdc);
    }
    else if (indexPath.section == 3) {
        color1 = UIColorFromRGB(0xf47976);
        color2 = UIColorFromRGB(0xe50a0b);
    }
    else if (indexPath.section == 4) {
        color1 = UIColorFromRGB(0xfecd03);
        color2 = UIColorFromRGB(0xfa7d00);
    }
    else if (indexPath.section == 5) {
        [cell setBackgroundColor:[UtilToView getEcoColor:@"0"]];
        return;
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = cell.bounds;
    grad.colors = [NSArray arrayWithObjects:(id)[color1 CGColor], (id)[color2 CGColor], nil];
    [cell setBackgroundView:[[UIView alloc] init]];
    [cell.backgroundView.layer insertSublayer:grad atIndex:0];
    CAGradientLayer *selectedGrad = [CAGradientLayer layer];
    selectedGrad.frame = cell.bounds;
    selectedGrad.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [cell setSelectedBackgroundView:[[UIView alloc] init]];
    [cell.selectedBackgroundView.layer insertSublayer:selectedGrad atIndex:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell EcoTable";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSString *testo;
    NSString *detail;
    CGFloat textFontSize = 0.0;
    CGFloat detailTextFontSize = 0.0;
    
    if (IS_PAD_PRO) {
        textFontSize = 60.0;
        detailTextFontSize = 20.0;
    }
    else if (IS_PAD) {
        textFontSize = 40.0;
        detailTextFontSize = 15.0;
    }
    else if (IS_IPHONE_4_OR_LESS) {
        textFontSize = 15.0;
        detailTextFontSize = 10;
    }
    else if (IS_IPHONE_5) {
        textFontSize = 15.0;
        detailTextFontSize = 10;
    }
    else if (IS_IPHONE_6) {
        textFontSize = 20.0;
        detailTextFontSize = 12;
    }
    else if (IS_IPHONE_6P) {
        textFontSize = 30.0;
        detailTextFontSize = 15.0;
    }
    
    
    
    cell.textLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:textFontSize];
    cell.detailTextLabel.textColor = [UIColor blueColor];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:detailTextFontSize];
    
    if (indexPath.section == 0) {
        testo = @"A 00 - A 99";
        //NSNumber *a = [ecoNumber objectForKey:@"A"];
        detail = [NSString stringWithFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), numA];
        //NSCountedSet *eco = [ecoABCDE objectForKey:@"A"];
        detail = [detail stringByAppendingFormat:NSLocalizedString(@"ECO_DETAIL", nil), A.count];
    }
    if (indexPath.section == 1) {
        testo = @"B 00 - B 99";
        //NSNumber *a = [ecoNumber objectForKey:@"B"];
        detail = [NSString stringWithFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), numB];
        //NSCountedSet *eco = [ecoABCDE objectForKey:@"B"];
        detail = [detail stringByAppendingFormat:NSLocalizedString(@"ECO_DETAIL", nil), B.count];
    }
    if (indexPath.section == 2) {
        testo = @"C 00 - C 99";
        //NSNumber *a = [ecoNumber objectForKey:@"C"];
        detail = [NSString stringWithFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), numC];
        //NSCountedSet *eco = [ecoABCDE objectForKey:@"C"];
        detail = [detail stringByAppendingFormat:NSLocalizedString(@"ECO_DETAIL", nil), C.count];
    }
    if (indexPath.section == 3) {
        testo = @"D 00 - D 99";
        //NSNumber *a = [ecoNumber objectForKey:@"D"];
        detail = [NSString stringWithFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), numD];
        //NSCountedSet *eco = [ecoABCDE objectForKey:@"D"];
        detail = [detail stringByAppendingFormat:NSLocalizedString(@"ECO_DETAIL", nil), D.count];
    }
    if (indexPath.section == 4) {
        testo = @"E 00 - E 99";
        //NSNumber *a = [ecoNumber objectForKey:@"E"];
        detail = [NSString stringWithFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), numE];
        //NSCountedSet *eco = [ecoABCDE objectForKey:@"E"];
        detail = [detail stringByAppendingFormat:NSLocalizedString(@"ECO_DETAIL", nil), E.count];
    }
    if (indexPath.section == 5) {
        testo = @"A 00 - E 99";
        //NSNumber *a = [ecoNumber objectForKey:@"A"];
        //NSNumber *b = [ecoNumber objectForKey:@"B"];
        //NSNumber *c = [ecoNumber objectForKey:@"C"];
        //NSNumber *d = [ecoNumber objectForKey:@"D"];
        //NSNumber *e = [ecoNumber objectForKey:@"E"];
        
        detail = [NSString stringWithFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), (numA + numB + numC + numD + numE)];
        
        //NSCountedSet *nA = [ecoABCDE objectForKey:@"A"];
        //NSCountedSet *nB = [ecoABCDE objectForKey:@"B"];
        //NSCountedSet *nC = [ecoABCDE objectForKey:@"C"];
        //NSCountedSet *nD = [ecoABCDE objectForKey:@"D"];
        //NSCountedSet *nE = [ecoABCDE objectForKey:@"E"];
        
        detail = [detail stringByAppendingFormat:NSLocalizedString(@"ECO_DETAIL", nil), (A.count + B.count + C.count + D.count + E.count)];
    }
    
    cell.textLabel.text = testo;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.detailTextLabel.text = detail;
    
    
    if (revealViewController) {
        
        cell.detailTextLabel.text = nil;
    }
    
    
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
    
    NSError *error = NULL;
    NSRegularExpression *regex;
    
    //NSMutableArray *singleEcoArray = [[NSMutableArray alloc] init];
    
    NSArray *sea;
    
    NSString *title;
    NSString *lettera = nil;
    if (indexPath.section == 0) {
        lettera = @"A";
        regex = [[NSRegularExpression alloc] initWithPattern:@"\\bA\\d\\d\\b" options:0 error:&error];
        title = @"A 00 - A 99";
        sea = A;
    }
    if (indexPath.section == 1) {
        lettera = @"B";
        regex = [[NSRegularExpression alloc] initWithPattern:@"\\bB\\d\\d\\b" options:0 error:&error];
        title = @"B 00 - B 99";
        sea = B;
    }
    if (indexPath.section == 2) {
        lettera = @"C";
        regex = [[NSRegularExpression alloc] initWithPattern:@"\\bC\\d\\d\\b" options:0 error:&error];
        title = @"C 00 - C 99";
        sea = C;
    }
    if (indexPath.section == 3) {
        lettera = @"D";
        regex = [[NSRegularExpression alloc] initWithPattern:@"\\bD\\d\\d\\b" options:0 error:&error];
        title = @"D 00 - D 99";
        sea = D;
    }
    if (indexPath.section == 4) {
        lettera = @"E";
        regex = [[NSRegularExpression alloc] initWithPattern:@"\\bE\\d\\d\\b" options:0 error:&error];
        title = @"E 00 - E 99";
        sea = E;
    }
    if (indexPath.section == 5) {
        lettera = nil;
        title = @"A 00 - E 99";
        sea = [ecoCountedSet allObjects];
    }
    /*
    for (NSString *ecoLine  in openingArray) {
        if (lettera) {
            //if ([ecoLine hasPrefix:lettera]) {
            //    NSLog(@"%@", ecoLine);
            //}
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:ecoLine options:0 range:NSMakeRange(0, [ecoLine length])];
            if (numberOfMatches > 0) {
                //NSLog(@"Numero match: %d   in %@", numberOfMatches, ecoLine);
                [singleEcoArray addObject:ecoLine];
            }
        }
        else {
            //NSLog(@"%@", ecoLine);
            [singleEcoArray addObject:ecoLine];
        }
    }
    
    for (NSString *p in singleEcoArray) {
        NSLog(@"%@", p);
    }
    */
    //for (NSString *p in sea) {
    //    NSLog(@"%@", p);
    //}
    
    
    
    
    if (revealViewController && IsChessStudioLight) {
        if (indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 5) {
            UIAlertView *stopAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"LIGHT_ECO_CLASSIFICATION", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [stopAlertView show];
            return;
        }
    }
    
    
    //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    UIStoryboard *sb = [UtilToView getStoryBoard];
    SingleEcoTableViewController *setvc = [sb instantiateViewControllerWithIdentifier:@"SingleEcoTableViewController"];
    [setvc setDelegate:self];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    //hud.detailsLabelText = title;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [setvc setPgnFileDoc:_pgnFileDoc];
        [setvc setEcoSymbol:lettera];
        [setvc setEcoCountedSet:ecoCountedSet];
        [setvc setEcoTitle:title];
        if (revealViewController) {
            [setvc setFromSWReveal:YES];
        }
        else {
            [setvc setFromSWReveal:NO];
        }
        [self.navigationController pushViewController:setvc animated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });

}

#pragma mark - SingleEcoTableViewController delegate

- (void) aggiorna {
    [self initData];
    [self.tableView reloadData];
}

- (void) aggiornaDopoRotazione {
    [self.tableView reloadData];
}

@end
