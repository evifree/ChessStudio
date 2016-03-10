//
//  TBPgnFileTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 22/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "TBPgnFileTableViewController.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "GameBoardPreviewTableViewController.h"

@interface TBPgnFileTableViewController () {
    NSMutableArray *games;
    
    NSString *gameSel;
    PGNGame *pgnGame;
    
    
    UITableViewHeaderFooterView *thfv;
    
    UIPopoverController *gamePreviewPopoverController;
    NSInteger lastSelectedGame;
}

@end

@implementation TBPgnFileTableViewController

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
    
    games = [_pgnFileDoc.pgnFileInfo getAllGamesAndTags];
    //NSLog(@"Ci sono %d partite", games.count);
    
    
    if (IsChessStudioLight) {
        if (IS_IOS_7) {
            self.canDisplayBannerAds = YES;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedGameInfoNotification:) name:@"SAVED" object:@"GameInfo"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (IS_PHONE) {
        
        self.navigationItem.title = NSLocalizedString(@"GAMES1", nil);
        
        return;
        
        UIView *titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 190, 28)];
        label1.font = [UIFont boldSystemFontOfSize:17.0];
        label1.textColor = [UIColor whiteColor];
        label1.text = [NSString stringWithFormat:NSLocalizedString(@"GAME_TABLE_VIEW_CONTROLLER_TITLE", nil), @""];
        label1.backgroundColor = [UIColor clearColor];
        label1.textAlignment = NSTextAlignmentCenter;
        [titoloView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 190, 16)];
        label2.font = [UIFont boldSystemFontOfSize:17.0];
        //label2.text = NSLocalizedString(@"GAMES1", nil);
        label2.text = _pgnFileDoc.pgnFileInfo.personalFileName;
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = [UIColor whiteColor];
        label2.textAlignment = NSTextAlignmentCenter;
        [titoloView addSubview:label2];
        self.navigationItem.titleView = titoloView;
    }
    else {
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"GAME_TABLE_VIEW_CONTROLLER_TITLE", nil), _pgnFileDoc.pgnFileInfo.fileName];
    }
}

#pragma mark - Gestion Rotazione


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self calcolaConstraintRowHeight:indexPath];
    
//    CGSize constraint;
//    CGSize size;
//    NSString *game = [games objectAtIndex:indexPath.row];
//    NSMutableString *testo = [[NSMutableString alloc] init];
//    for (NSString *t in [game componentsSeparatedByString:separator]) {
//        if ([t hasPrefix:@"["]) {
//            [testo appendString:t];
//            [testo appendString:@"\n"];
//        }
//        else {
//            [testo appendString:t];
//        }
//    }
//    
//    UILabel *testSizeLabel = [[UILabel alloc] init];
//    testSizeLabel.text = testo;
//    testSizeLabel.numberOfLines = 0;
//    
//    if (IS_PAD) {
//        constraint = CGSizeMake(768, 20000.0f);
//        //size = [testo sizeWithFont:[UIFont fontWithName:@"Courier" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
//        testSizeLabel.font = [UIFont fontWithName:@"Courier" size:14.0];
//        size = [testSizeLabel sizeThatFits:constraint];
//    }
//    else {
//        constraint = CGSizeMake(400, 1000);
//        //size = [testo sizeWithFont:[UIFont fontWithName:@"Courier" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
//        testSizeLabel.font = [UIFont fontWithName:@"Courier" size:14.0];
//        size = [testSizeLabel sizeThatFits:constraint];
//    }
//    
//    CGFloat height = MAX(size.height, 44.0f);
//    
//    return height + 20;
}

- (CGFloat) calcolaConstraintRowHeight:(NSIndexPath *)indexPath {
    CGSize constraintSize;
    CGSize size;
    NSString *game = [games objectAtIndex:indexPath.row];
    NSMutableString *testo = [[NSMutableString alloc] init];
    for (NSString *t in [game componentsSeparatedByString:separator]) {
        if ([t hasPrefix:@"["]) {
            [testo appendString:t];
            [testo appendString:@"\n"];
        }
        else {
            [testo appendString:t];
        }
    }
    
    UILabel *testSizeLabel = [[UILabel alloc] init];
    testSizeLabel.text = testo;
    testSizeLabel.numberOfLines = 0;
    
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            constraintSize = CGSizeMake(768, 20000.0f);
            //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:18.0]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            size = rect.size;
        }
        else {
            constraintSize = CGSizeMake(1024, 20000.0f);
            //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:18.0]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            size = rect.size;
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            constraintSize = CGSizeMake(640, 5000);
            //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:18.0]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            size = rect.size;
        }
        else {
            constraintSize = CGSizeMake(1136, 5000);
            //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:18.0]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            size = rect.size;
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            constraintSize = CGSizeMake(640, 5000);
            //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:18.0]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            size = rect.size;
        }
        else {
            constraintSize = CGSizeMake(1136, 5000);
            //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:18.0]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            size = rect.size;
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            constraintSize = CGSizeMake(640, 5000);
            //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:18.0]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            size = rect.size;
        }
        else {
            constraintSize = CGSizeMake(1136, 5000);
            //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:18.0]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            size = rect.size;
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            constraintSize = CGSizeMake(640, 3000);
            //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:18.0]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            size = rect.size;
        }
        else {
            constraintSize = CGSizeMake(960, 3000);
            //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:18.0]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            size = rect.size;
        }
    }
    CGFloat height = MAX(size.height, 44.0f);
    
    //NSLog(@"HEIGHT = %f", height);
    
    return height + 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return games.count;
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
            thfv = (UITableViewHeaderFooterView *)view;
            //[thfv setFrame:CGRectMake(0, 0, thfv.frame.size.width, thfv.frame.size.height + 20)];
            thfv.textLabel.textColor = [UIColor whiteColor];
            //thfv.contentView.backgroundColor = UIColorFromRGB(0xFFD700);
            //thfv.contentView.backgroundColor = [UIColor blackColor];
            thfv.contentView.backgroundColor = [UIColor blackColor];
            //thfv.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
            thfv.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25.0];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell TBPgnFile";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    
    NSMutableString *testoTags = [[NSMutableString alloc] init];
    NSMutableString *testoGame = [[NSMutableString alloc] init];
    NSString *game = [games objectAtIndex:indexPath.row];
    for (NSString *t in [game componentsSeparatedByString:separator]) {
        if ([t hasPrefix:@"["]) {
            [testoTags appendString:t];
            [testoTags appendString:@"\n"];
        }
        else {
            [testoTags appendString:@"\n"];
            [testoGame appendString:t];
        }
    }
    
    if (IS_PAD) {
        cell.textLabel.font=[UIFont fontWithName:@"Courier" size:14];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Courier" size:12];
    }
    else {
        cell.textLabel.font=[UIFont fontWithName:@"Courier" size:12];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Courier" size:11];
    }
    
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = testoTags;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = testoGame;
    
    UILabel *numGameLabel = (UILabel *)[cell viewWithTag:200];
    if (!numGameLabel) {
        numGameLabel = [[UILabel alloc] initWithFrame:[self getLabelFrame]];
        numGameLabel.tag = 200;
        [numGameLabel setBackgroundColor:[UIColor clearColor]];
        [numGameLabel setFont:[UIFont fontWithName:@"Courier-Bold" size:13]];
        [numGameLabel setTextColor:[UIColor redColor]];
        [numGameLabel setText:[NSString stringWithFormat:@"%ld", (long)(indexPath.row + 1)]];
        [cell.contentView addSubview:numGameLabel];
    }
    else {
        [numGameLabel setFrame:[self getLabelFrame]];
        [numGameLabel setText:[NSString stringWithFormat:@"%ld", (long)(indexPath.row + 1)]];
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
    NSString *game = [games objectAtIndex:indexPath.row];
    
    PGNGame *previewPgnGame = [[PGNGame alloc] initWithPgn:game];
    NSString *g = [previewPgnGame getGameForCopy];
    
    if (IS_PAD) {
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
    
    
    //gameSel = [games objectAtIndex:indexPath.row];
    //NSArray *gameArray = [selectedGame componentsSeparatedByString:separator];
    
    [self goToTheBoard:indexPath];
    
    /*
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
    
    
    
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    BoardViewController *bvc = [sb instantiateViewControllerWithIdentifier:@"BoardViewController"];
    bvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:bvc];
    
    //NSMutableString *game = [[NSMutableString alloc] initWithString:cell.detailTextLabel.text];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        
        //[bvc setGameToView:game];
        //[bvc setGameToViewArray:gameArray];
        [bvc setPgnFileDoc:_pgnFileDoc];
        [bvc setPgnGame:pgnGame];
        [self presentModalViewController:boardNavigationController animated:YES];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    */
}

#pragma mark - Metodi per gestire la partita una volta selezionata in didSelectRowAtIndexPath

- (BOOL) checkTheGame:(NSIndexPath *) indexPath {
    
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    NSString *callerMethod = [array objectAtIndex:4];
    
    
    NSUInteger indicePartita = 0;
    if (indexPath) {
        gameSel = [games objectAtIndex:indexPath.row];
        lastSelectedGame = indexPath.row;
        indicePartita = [[_pgnFileDoc.pgnFileInfo getAllGamesAndTags] indexOfObject:gameSel];  //Serve per salvare permanente l'eventuale partita con FEN non corretto
    }
    
    @try {
        if ([PGNGame gameIsPositionWithRegularFen:gameSel]) {
            
            gameSel = [PGNGame checkStartColorAndFirstMove:gameSel]; //controlla e restituisce gameSel modificata tendendo conto del colore che deve muovere e la prima mossa.
            
            pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
        }
        else {
            NSLog(@"La posizione non è corretta, la correggo");
            gameSel = [PGNGame getCorrectedGame:gameSel];
            [games replaceObjectAtIndex:indexPath.row withObject:gameSel];
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
            
            wrongGameAlertView = [[UIAlertView alloc] initWithTitle:[PGNGame getTemporaryFen] message:NSLocalizedString(exception.name, nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:NSLocalizedString(@"FEN_CORRECT_SAVE", nil), NSLocalizedString(@"FEN_CORRECT_NO_SAVE", nil), nil];
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

- (void) goToTheBoard:(NSIndexPath *) indexPath {
    
    if (![self checkTheGame:indexPath]) {
        return;
    }
    
    [pgnGame setIndexInAllGamesAllTags:[games indexOfObject:gameSel]];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    BoardViewController *bvc = [sb instantiateViewControllerWithIdentifier:@"BoardViewController"];
    [bvc setDelegate:self];
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
        
        //NSLog(@"Devo passare PGNGAme a BVC");
        
        
        @try {
            [bvc setPgnGame:pgnGame];
        }
        @catch (NSException *exception) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //UIAlertView *wrongGameAlertView;
            //wrongGameAlertView = [[UIAlertView alloc] initWithTitle:nil message:exception.name delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            //[wrongGameAlertView show];
            NSString *title = NSLocalizedString(@"TITLE_ERROR_IN_GAME_PREVIEW", nil);
            NSString *message = NSLocalizedString(@"MSG_ERROR_IN_GAME_PREVIEW", nil);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        //[bvc setPgnGame:pgnGame];
        //[self presentViewController:boardNavigationController animated:YES completion:nil];
        [self presentViewController:boardNavigationController animated:YES completion:^{
            [self.tableView reloadData];
        }];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

#pragma mark - AlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 200 || alertView.tag == 300) {
        NSString *scelta = [alertView buttonTitleAtIndex:buttonIndex];
        if ([scelta isEqualToString:NSLocalizedString(@"MENU_CANCEL", nil)]) {
            return;
        }
        else {
            NSString *newGameSel = [PGNGame getGameWithNumberOfMoveInFenCorrected:gameSel];
            NSLog(@"GAME SEL = %@", newGameSel);
            NSInteger *indexGame = [games indexOfObject:gameSel];
            [games replaceObjectAtIndex:indexGame withObject:newGameSel];
            gameSel = newGameSel;
            if ([scelta isEqualToString:NSLocalizedString(@"FEN_CORRECT_SAVE", nil)]) {
                [_pgnFileDoc.pgnFileInfo salvaTutteLePartite];
            }
            [self.tableView reloadData];
            if (alertView.tag == 200) {
                //[self goToTheGamePreview:nil];
            }
            else if (alertView.tag == 300) {
                [self goToTheBoard:nil];
            }
        }
    }
}

/*
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray* indexPaths = [self.tableView indexPathsForVisibleRows];
    NSArray* sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    NSInteger row = [(NSIndexPath*)[sortedIndexPaths objectAtIndex:0] row];
    NSLog(@"CELL NUMBER %d", row);
    if (row == 200) {
        thfv.contentView.backgroundColor = [UIColor whiteColor];
    }
    else if (row > 120) {
        thfv.contentView.backgroundColor = [UIColor greenColor];
    }
}
*/

- (CGRect) getLabelFrame {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            return CGRectMake(768 - 50.0, 5, 50, 15);
        }
        else {
            return CGRectMake(1024 - 50.0, 5, 50, 15);
        }
    }
    
    if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            return CGRectMake(320.0 - 50.0, 5, 50, 15);
        }
        else {
            return CGRectMake(480.0 - 50.0, 5, 50, 15);
        }
    }
    
    if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            return CGRectMake(320.0 - 50.0, 5, 50, 15);
        }
        else {
            return CGRectMake(568.0 - 50.0, 5, 50, 15);
        }
    }
    
    if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            return CGRectMake(375.0 - 50.0, 5, 50, 15);
        }
        else {
            return CGRectMake(667.0 - 50.0, 5, 50, 15);
        }
    }
    
    if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            return CGRectMake(414.0 - 50.0, 5, 50, 15);
        }
        else {
            return CGRectMake(736.0 - 50.0, 5, 50, 15);
        }
    }

    return CGRectZero;
}

#pragma mark - BoardViewController Delegate

- (void) updateTBPgnFileTableViewController {
    //NSLog(@"Aggiorno TBPgnFileTableViewControllert");
    games = [_pgnFileDoc.pgnFileInfo getAllGamesAndTags];
    [self.tableView reloadData];
}

- (PGNGame *) getNextGame {
    if (lastSelectedGame == (games.count - 1)) {
        return nil;
    }
    lastSelectedGame++;
    gameSel = [games objectAtIndex:lastSelectedGame];
    pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
    [pgnGame setIndexInAllGamesAllTags:lastSelectedGame];
    return pgnGame;
}

- (PGNGame *) getPreviousGame {
    if (lastSelectedGame == 0) {
        return nil;
    }
    lastSelectedGame--;
    gameSel = [games objectAtIndex:lastSelectedGame];
    pgnGame = [[PGNGame alloc] initWithPgn:gameSel];
    [pgnGame setIndexInAllGamesAllTags:lastSelectedGame];
    return pgnGame;
}

#pragma mark - Implementazione metodo ricezione Notifica da GameInfoTableViewController per aggiornare la partita salvata

- (void) receivedGameInfoNotification:(NSNotification *) notification {
    //NSLog(@"Game Preview ha ricevuto la notifica con name = %@", notification.name);
    //NSString *s = [notification object];
    //NSLog(@"OGGETTO NOTIFICA = %@", s);
    games = [_pgnFileDoc.pgnFileInfo getAllGamesAndTags];
    [self.tableView reloadData];
}

@end
