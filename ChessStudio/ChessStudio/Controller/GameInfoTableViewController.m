//
//  GameInfoTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 19/07/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "GameInfoTableViewController.h"
#import "TagGamePreviewCell.h"
#import "DateTagViewController.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "EcoTagViewController.h"

@interface GameInfoTableViewController () {
    NSMutableArray *gameArray;
    
    CGFloat dimLabelLength;
    
    NSString *moves;
    
    UIActionSheet *doneActionSheetMenu;
    
    UIPopoverController *popoverController;
    UINavigationController *navigationController;
    
    TagGamePreviewCell *selectedCell;
    NSString *selectedTag;
    NSString *selectedValue;
    
    //NSMutableDictionary *sevenTagDictionary;
    //NSMutableDictionary *suppTagDictionary;
    
    UITextField *tfTag;
    
    UIPopoverController *supplementalTagPopover;
    
    
    
    //NSArray *sevenTag;
    //NSArray *suppTag;
    //NSMutableArray *orderedSuppTag;
    
    //NSArray *defaultOrderdSuppTag;
    
    
    
    
    NSArray *orderedSevenTags;
    NSMutableArray *orderedSuppTags;
    NSMutableArray *orderedSuppOtherTags;
    
    NSMutableDictionary *gameSevenTagsDict;
    NSMutableDictionary *gameSuppTagsDict;
    NSMutableDictionary *gameOtherTagsDict;
    NSMutableDictionary *gamePositionTagDict;
    NSMutableDictionary *gameSuppOtherTagsDict;
    
    BOOL tagsModified;
}

@end

@implementation GameInfoTableViewController

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
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
    
    orderedSevenTags = [UtilToView getOrderedSevenTags];
    orderedSuppTags = [UtilToView getOrderedSuppTags].mutableCopy;
    orderedSuppOtherTags = [[NSMutableArray alloc] init];
    
    for (NSString *tag in gameOtherTagsDict.allKeys) {
        [orderedSuppTags addObject:tag];
    }
    
    for (NSString *tag in orderedSuppTags) {
        if ([gameSuppOtherTagsDict.allKeys containsObject:tag]) {
            [orderedSuppOtherTags addObject:tag];
        }
    }
    
    //NSLog(@"%@", orderedSevenTags);
    //NSLog(@"%@", orderedSuppTags);
    //NSLog(@"%@", orderedSuppOtherTags);
    
    
    tagsModified = NO;
    
    //[self stampa];
}

- (void) loadView {
    [super loadView];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
    
    [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneMenuButtonPressed:)]];
    
    if (_modificabile) {
        [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"TAG", nil) style:UIBarButtonItemStylePlain target:self action:@selector(actionMenuButtonPressed:)]];
        
        UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE_TAGS", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveTags:)];
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *saveAndExitBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE_TAGS_EXIT", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveTagsAndExit:)];
        self.toolbarItems = [NSArray arrayWithObjects:saveBarButtonItem, flexible, saveAndExitBarButtonItem, flexible, cancelBarButtonItem, nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.navigationItem.title = [[[[[gameArray objectAtIndex:4] componentsSeparatedByString:@"\""] objectAtIndex:1] stringByAppendingString:@" - "] stringByAppendingString:[[[gameArray objectAtIndex:5] componentsSeparatedByString:@"\""] objectAtIndex:1]];
    
    self.navigationController.toolbarHidden = !_modificabile;
    if (_modificabile) {
        self.navigationItem.title = NSLocalizedString(@"TITLE_GAME_DATA", nil);
    }
    else {
        self.navigationItem.title = NSLocalizedString(@"TITLE_GAME_DATA_NO_MODIFY", nil);
    }
    
    if (IS_PAD) {
        dimLabelLength = 650.0;
    }
    else {
        dimLabelLength = 200.0;
    }
    
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


- (void) setPgnGame:(PGNGame *)pgnGame {
    _pgnGame = pgnGame;
    [self initData];
}


- (void) initData {
    
    //NSLog(@"Inizio Init Data");
    gameArray = [[_pgnGame getGameArray] mutableCopy];
    [gameArray removeLastObject];
    
    NSMutableString *_gameToView = [[NSMutableString alloc] initWithString:[_pgnGame moves]];
    if ([_pgnGame isPosition]) {
        moves = [_gameToView stringByReplacingOccurrencesOfString:@"1. XXX" withString:@"1..."];
    }
    else {
        moves = _gameToView;
    }
    
    gameSevenTagsDict = [_pgnGame getSevenTag];
    //NSLog(@"%@", gameSevenTagsDict);
    gameSuppTagsDict = [_pgnGame getSupplementalTagApp];
    //NSLog(@"%@", gameSuppTagsDict);
    gameOtherTagsDict = [_pgnGame getOtherTagApp];
    //NSLog(@"%@", gameOtherTagsDict);
    gamePositionTagDict = [_pgnGame getPositionTagDict];
    //NSLog(@"%@", gamePositionTagDict);
    gameSuppOtherTagsDict = [[NSMutableDictionary alloc] initWithDictionary:gameSuppTagsDict];
    [gameSuppOtherTagsDict addEntriesFromDictionary:gameOtherTagsDict];
    //NSLog(@"%@", gameSuppOtherTagsDict);
    
    //NSLog(@"Fine Init Data");
    
    //[self stampa];
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

#pragma mark - Metodi gestione pulsanti in toolbar

- (void) saveTags:(UIBarButtonItem *)sender {
    [self saveTagsInGame];
}

- (void) cancelButtonPressed:(UIBarButtonItem *)sender {
    if (tagsModified) {
        [self displayAlert];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveGameAndExit:(UIBarButtonItem *)sender {
    [self saveTagsInGame];
    //[self salvaModificheInDatabase];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveTagsAndExit:(UIBarButtonItem *)sender {
    [self saveTagsInGame];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
- (void) ordinaSupplementalTagsOld {
    NSLog(@"Ordino Supplemental tag");
    
    NSMutableArray *tempSuppTag = [[NSMutableArray alloc] init];
    
    for (NSString *st in suppTag) {
        if ([orderedSuppTag containsObject:st]) {
            NSLog(@"TAG = %@", st);
            [tempSuppTag addObject:st];
        }
    }
    
    [orderedSuppTag removeAllObjects];
    [orderedSuppTag addObjectsFromArray:tempSuppTag];
    
    NSArray *suppTagOrdered = [UtilToView getSupplementalTagValues];
    NSMutableArray *newSuppTagOrdered = [[NSMutableArray alloc] init];
    for (NSString *st in suppTagOrdered) {
        if ([orderedSuppTag containsObject:st]) {
            NSLog(@"ordino: %@", st);
            [newSuppTagOrdered addObject:st];
        }
    }
    
    [orderedSuppTag removeAllObjects];
    [orderedSuppTag addObjectsFromArray:newSuppTagOrdered];
    
    NSLog(@"Ho ordinato i tags:   %@", orderedSuppTag);
}
*/

/*
- (void) ordinaSupplementalTags {
    [orderedSuppTag removeAllObjects];
    for (NSString *st in defaultOrderdSuppTag) {
        if ([suppTagDictionary.allKeys containsObject:st]) {
            [orderedSuppTag addObject:st];
        }
    }
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (gamePositionTagDict.count>0) {
        if (gameSuppOtherTagsDict.count>0) {
            return 4;
        }
        else {
            return 3;
        }
    }
    else {
        if (gameSuppOtherTagsDict.count>0) {
            return 3;
        }
        else {
            return 2;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 7;
    }
    if (section == 1) {
        if (gamePositionTagDict.count>0) {
            return 2;
        }
        else {
            if ((gameSuppOtherTagsDict.count)>0) {
                return gameSuppOtherTagsDict.count;
            }
            else {
                return 1;
            }
        }
    }
    if (section == 2) {
        if (gamePositionTagDict.count>0) {
            if (gameSuppOtherTagsDict.count>0) {
                return gameSuppOtherTagsDict.count;
            }
            else {
                return 1;
            }
        }
    }
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"GAME_PREVIEW_SECTION_0_TITLE", nil);
    }
    if (section == 1) {
        if (gamePositionTagDict.count>0) {
            return NSLocalizedString(@"GAME_PREVIEW_SECTION_1_POSITION_TITLE", nil);
        }
        else {
            if (gameSuppOtherTagsDict.count > 0) {
                return NSLocalizedString(@"GAME_PREVIEW_SECTION_1_TITLE", nil);
            }
            else {
                return NSLocalizedString(@"GAME_PREVIEW_SECTION_2_TITLE", nil);
            }
        }
    }
    if (section == 2) {
        if (gamePositionTagDict.count>0) {
            return NSLocalizedString(@"GAME_PREVIEW_SECTION_1_TITLE", nil);
        }
        return NSLocalizedString(@"GAME_PREVIEW_SECTION_2_TITLE", nil);
    }
    
    if (section == 3) {
        return NSLocalizedString(@"GAME_PREVIEW_SECTION_2_TITLE", nil);
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger sezioneMosse = [tableView numberOfSections] - 1;
    
    if (indexPath.section == sezioneMosse) {
        CGSize constraint;
        CGSize size;
        
        UILabel *testSizeLabel = [[UILabel alloc] init];
        testSizeLabel.text = moves;
        testSizeLabel.numberOfLines = 0;
        
        if (IS_PAD) {
            constraint = CGSizeMake(500, 20000.0f);
            //size = [moves sizeWithFont:[UIFont fontWithName:@"Arial" size:16] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            testSizeLabel.font = [UIFont fontWithName:@"Arial" size:16.0];
            size = [testSizeLabel sizeThatFits:constraint];
        }
        else {
            constraint = CGSizeMake(400, 1000.0f);
            //size = [moves sizeWithFont:[UIFont fontWithName:@"Arial" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            testSizeLabel.font = [UIFont fontWithName:@"Arial" size:14.0];
            size = [testSizeLabel sizeThatFits:constraint];
        }
        CGFloat height = MAX(size.height, 44.0f);
        
        return height + 20;
    }
    return 44.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell GameInfo";
    TagGamePreviewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TagGamePreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    if (IS_PAD) {
        cell.textLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:20];
    }
    else {
        cell.textLabel.font=[UIFont fontWithName:@"helvetica_Bold" size:15];
    }
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    if (label) {
        [label removeFromSuperview];
        label = nil;
    }
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    
    if (indexPath.section == 0) {   //Gestione Seven Tag Roster
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        //NSString *tag = [[[[gameArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"\""] objectAtIndex:0]stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
        
        NSString *tag = [orderedSevenTags objectAtIndex:indexPath.row];
        
        NSMutableString *testo = [[NSMutableString alloc] initWithString:tag];
        [testo appendString:@":  "];
        cell.textLabel.text = testo;
        //CGSize expectedCellLabelSize = [testo sizeWithFont:cell.textLabel.font];
        CGSize expectedCellLabelSize = [testo sizeWithAttributes:@{NSFontAttributeName:cell.textLabel.font}];
        
        if (!label) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(expectedCellLabelSize.width + 10, 7, dimLabelLength, 30)];
            label.adjustsFontSizeToFitWidth = YES;
            if (IS_PAD) {
                label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
            }
            else {
                label.font = [UIFont fontWithName:@"helvetica_Bold" size:15];
            }
            label.tag = 1;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor redColor];
            //label.text = [[[gameArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"\""] objectAtIndex:1];
            label.text = [gameSevenTagsDict objectForKey:tag];
            [cell.contentView addSubview:label];
        }
        else {
            //abel.text = [[[gameArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"\""] objectAtIndex:1];
            label.text = [gameSevenTagsDict objectForKey:tag];
        }
        
        if (_modificabile) {
            UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            [cell addGestureRecognizer:recognizer];
        }
        
        return cell;
    }
    
    if (indexPath.section == 1 && gamePositionTagDict.count > 0) { //Gestion tag Position
        NSString *tag;
        if (indexPath.row == 0) {
            tag = @"SetUp";
        }
        else if (indexPath.row == 1) {
            tag = @"FEN";
        }
        NSMutableString *testo = [[NSMutableString alloc] initWithString:tag];
        [testo appendString:@":  "];
        cell.textLabel.text = testo;
        CGSize expectedCellLabelSize = [testo sizeWithAttributes:@{NSFontAttributeName: cell.textLabel.font}];
        if (!label) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(expectedCellLabelSize.width + 10, 7, dimLabelLength, 30)];
            label.adjustsFontSizeToFitWidth = YES;
            if (IS_PAD) {
                label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
            }
            else {
                label.font = [UIFont fontWithName:@"helvetica_Bold" size:15];
            }
            label.tag = 1;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor orangeColor];
            //label.text = [[[gameArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"\""] objectAtIndex:1];
            //label.text = [sevenTagDictionary objectForKey:tag];
            label.text = [gameSevenTagsDict objectForKey:tag];
            label.text = [gamePositionTagDict objectForKey:tag];
            [cell.contentView addSubview:label];
        }
        else {
            //label.text = [[[gameArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"\""] objectAtIndex:1];
            //label.text = [sevenTagDictionary objectForKey:tag];
            label.text = [gameSevenTagsDict objectForKey:tag];
            label.text = [gamePositionTagDict objectForKey:tag];
        }
        
        //UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapCell:)];
        //doubleTapRecognizer.numberOfTapsRequired = 1;
        //[cell addGestureRecognizer:doubleTapRecognizer];
        
        if (_modificabile) {
            UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            [cell addGestureRecognizer:recognizer];
        }
        
        return cell;
    }
    
    if (indexPath.section == 1 && gamePositionTagDict.count == 0) {  //Gestione Supplemental Tags
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (gameSuppOtherTagsDict.count > 0) {
            NSString *tag = [orderedSuppOtherTags objectAtIndex:indexPath.row];
            NSMutableString *testo = [[NSMutableString alloc] initWithString:tag];
            [testo appendString:@":  "];
            cell.textLabel.text = testo;
            
            //CGSize expectedCellLabelSize = [testo sizeWithFont:cell.textLabel.font];
            CGSize expectedCellLabelSize = [testo sizeWithAttributes:@{NSFontAttributeName: cell.textLabel.font}];
            
            if (!label) {
                label = [[UILabel alloc] initWithFrame:CGRectMake(expectedCellLabelSize.width + 10, 7, dimLabelLength - expectedCellLabelSize.width + 10, 30)];
                label.adjustsFontSizeToFitWidth = YES;
                if (IS_PAD) {
                    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
                }
                else {
                    label.font = [UIFont fontWithName:@"helvetica_Bold" size:15];
                }
                label.tag = 1;
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor blueColor];
                //label.text = [[[gameArray objectAtIndex:indexPath.row + 7] componentsSeparatedByString:@"\""] objectAtIndex:1];
                //label.text = [suppTagDictionary objectForKey:tag];
                label.text = [gameSuppTagsDict objectForKey:tag];
                label.text = [gameSuppOtherTagsDict objectForKey:tag];
                [cell.contentView addSubview:label];
            }
            else {
                //label.text = [[[gameArray objectAtIndex:indexPath.row + 7] componentsSeparatedByString:@"\""] objectAtIndex:1];
                //label.text = [suppTagDictionary objectForKey:tag];
                label.text = [gameSuppTagsDict objectForKey:tag];
                label.text = [gameSuppOtherTagsDict objectForKey:tag];
            }
            
            if (_modificabile) {
                UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
                [cell addGestureRecognizer:recognizer];
            }
        }
        else {
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 0;
            
            
            if (IS_PAD) {
                //cell.textLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:15];
                cell.textLabel.font=[UIFont fontWithName:@"Courier" size:15];
            }
            else {
                //cell.textLabel.font=[UIFont fontWithName:@"Arial" size:11];
                cell.textLabel.font=[UIFont fontWithName:@"Courier" size:9];
            }
            
            if (([_pgnGame getGameType] == POSITION_WITHOUT_MOVES) || ([_pgnGame getGameType] == GAME_WITHOUT_MOVES)) {
                //cell.textLabel.text = [_pgnGame getMovesForPreview];
                cell.textLabel.text = moves;
            }
            else {
                cell.textLabel.text = moves;
                //cell.textLabel.text = movesNoSymbols;
            }
            
            //[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
        }
        return cell;
    }
    
    if (indexPath.section == 2) {
        if (gamePositionTagDict.count>0 && (gameSuppOtherTagsDict.count>0)) {
            NSString *tag = [orderedSuppOtherTags objectAtIndex:indexPath.row];
            NSMutableString *testo = [[NSMutableString alloc] initWithString:tag];
            [testo appendString:@":  "];
            cell.textLabel.text = testo;
            
            //CGSize expectedCellLabelSize = [testo sizeWithFont:cell.textLabel.font];
            CGSize expectedCellLabelSize = [testo sizeWithAttributes:@{NSFontAttributeName: cell.textLabel.font}];
            
            if (!label) {
                label = [[UILabel alloc] initWithFrame:CGRectMake(expectedCellLabelSize.width + 10, 7, dimLabelLength - expectedCellLabelSize.width + 10, 30)];
                label.adjustsFontSizeToFitWidth = YES;
                if (IS_PAD) {
                    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
                }
                else {
                    label.font = [UIFont fontWithName:@"helvetica_Bold" size:15];
                }
                label.tag = 1;
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor blueColor];
                //label.text = [[[gameArray objectAtIndex:indexPath.row + 7] componentsSeparatedByString:@"\""] objectAtIndex:1];
                //label.text = [suppTagDictionary objectForKey:tag];
                label.text = [gameSuppTagsDict objectForKey:tag];
                label.text = [gameSuppOtherTagsDict objectForKey:tag];
                [cell.contentView addSubview:label];
            }
            else {
                //label.text = [[[gameArray objectAtIndex:indexPath.row + 7] componentsSeparatedByString:@"\""] objectAtIndex:1];
                //label.text = [suppTagDictionary objectForKey:tag];
                label.text = [gameSuppTagsDict objectForKey:tag];
                label.text = [gameSuppOtherTagsDict objectForKey:tag];
            }
            
            if (_modificabile) {
                UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
                [cell addGestureRecognizer:recognizer];
            }
        }
        else {
            
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 0;
            
            
            if (IS_PAD) {
                //cell.textLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:15];
                cell.textLabel.font=[UIFont fontWithName:@"Courier" size:15];
            }
            else {
                //cell.textLabel.font=[UIFont fontWithName:@"Arial" size:11];
                cell.textLabel.font=[UIFont fontWithName:@"Courier" size:9];
            }
            
            if (([_pgnGame getGameType] == POSITION_WITHOUT_MOVES) || ([_pgnGame getGameType] == GAME_WITHOUT_MOVES)) {
                //cell.textLabel.text = [_pgnGame getMovesForPreview];
                cell.textLabel.text = moves;
            }
            else {
                cell.textLabel.text = moves;
                //cell.textLabel.text = movesNoSymbols;
            }
            
            //[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
            
            //cell.textLabel.text = [pgnAnalyzer getParsedGameWithChessSymbolsAndNoComments];
            
            return cell;
        }
    }
    if (indexPath.section == 3) {
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        
        
        if (IS_PAD) {
            //cell.textLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:15];
            cell.textLabel.font=[UIFont fontWithName:@"Courier" size:15];
        }
        else {
            //cell.textLabel.font=[UIFont fontWithName:@"Arial" size:11];
            cell.textLabel.font=[UIFont fontWithName:@"Courier" size:9];
        }
        
        if (([_pgnGame getGameType] == POSITION_WITHOUT_MOVES) || ([_pgnGame getGameType] == GAME_WITHOUT_MOVES)) {
            //cell.textLabel.text = [_pgnGame getMovesForPreview];
            cell.textLabel.text = moves;
        }
        else {
            cell.textLabel.text = moves;
            //cell.textLabel.text = movesNoSymbols;
        }
        
        //[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
        
        //cell.textLabel.text = [pgnAnalyzer getParsedGameWithChessSymbolsAndNoComments];
        
        return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    [self performSelector: @selector(deselectCell:) withObject:tableView afterDelay:0.1f];
    
    if (!_modificabile) {
        return;
    }
    
    selectedCell = (TagGamePreviewCell *)[tableView cellForRowAtIndexPath:indexPath];
    selectedTag = [selectedCell.textLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@": "]];
    [self editMenuPressed:nil];
}


- (void)deselectCell:(UITableView *)tableView {
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:NO];
}


#pragma mark - Gestione Long Press

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        NSInteger sezioneMosse = [self.tableView numberOfSections] - 1;
        
        selectedCell = (TagGamePreviewCell *)[recognizer view];
        NSIndexPath *selIndexPath = [self.tableView indexPathForCell:selectedCell];
        //NSLog(@"Sezione = %d", selIndexPath.section);
        if (selIndexPath.section == sezioneMosse) {
            return;
        }
        
        [self becomeFirstResponder];
        
        CGPoint tapPoint = [recognizer locationInView:selectedCell];
        CGPoint tapPointInView = [selectedCell convertPoint:tapPoint toView:self.view];
        CGRect rect = CGRectMake(tapPointInView.x, tapPointInView.y, 10.0, 10.0);
        
        selectedTag = [selectedCell.textLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@": "]];
        
        if ([selectedTag isEqualToString:@"FEN"] || [selectedTag isEqualToString:@"SetUp"]) {
            UIAlertView *tagPositionAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"SETUP_POSITION_EDIT_TAG", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [tagPositionAlertView show];
            return;
        }
        
        //NSLog(@"Tag selezionato = %@", selectedTag);
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:selectedCell];
        UIMenuItem *editItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"EDIT", nil) action:@selector(editMenuPressed:)];
        UIMenuItem *delItem = nil;
        
        if (selectedIndexPath.section > 0) {
            delItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"DELETE", nil) action:@selector(delMenuPressed:)];
        }
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        
        [menuController setMenuItems:[NSArray arrayWithObjects:editItem, delItem, nil]];
        
        [menuController setTargetRect:rect inView:self.tableView];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (void) editMenuPressed:(id)sender {
    
    if ([[UtilToView getResultsArray] containsObject:selectedTag]) {
        return;
    }
    
    if ([selectedTag hasPrefix:@"1."] || [selectedTag hasPrefix:@"{"]) {
        return;
    }
    if ([selectedTag isEqualToString:@"Date"]  || [selectedTag hasSuffix:@"Date"]) {
        [self gestisciDateTag];
    }
    else if ([selectedTag isEqualToString:@"Result"] || [selectedTag hasSuffix:@"Title"]) {
        [self gestisciResultAndTitleTag];
    }
    else if ([selectedTag isEqualToString:@"ECO"]) {
        [self gestisciEcoTag];
    }
    else {
        [self gestisciTextTag];
    }
}

- (void) delMenuPressed:(id)sender {
    //[orderedSuppOtherTags removeObject:selectedTag];
    //[orderedSuppTags removeObject:selectedTag];
    [gameSuppTagsDict removeObjectForKey:selectedTag];
    [gameOtherTagsDict removeObjectForKey:selectedTag];
    [gameSuppOtherTagsDict removeObjectForKey:selectedTag];
    
    [orderedSuppOtherTags removeAllObjects];
    for (NSString *tag in orderedSuppTags) {
        if ([gameSuppOtherTagsDict.allKeys containsObject:tag]) {
            [orderedSuppOtherTags addObject:tag];
        }
    }
    
    //[self stampa];
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:selectedCell];
    
    //NSLog(@"%d                   %d                     %d", gameSuppTagsDict.count, gameOtherTagsDict.count, gameSuppOtherTagsDict.count);
    
    if (gameSuppOtherTagsDict.count > 0) {
        [self.tableView deleteRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:[selectedIndexPath section]] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView reloadData];
    
    tagsModified = YES;

}


#pragma mark - Gestione Inserimento Tag

- (void) gestisciDateTag {
    UILabel *label = (UILabel *)[selectedCell viewWithTag:1];
    DateTagViewController *dtvc = [[DateTagViewController alloc] init];
    [dtvc setPreviousDate:label.text];
    navigationController = [[UINavigationController alloc] initWithRootViewController:dtvc];
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    dtvc.navigationItem.leftBarButtonItem = cancelButtonItem;
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveDateButtonPressed)];
    dtvc.navigationItem.rightBarButtonItem = doneButtonItem;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"";
    hud.alpha = 0.7;
    hud.color = [UIColor blackColor];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (IS_PAD) {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
            [popoverController setPopoverContentSize:CGSizeMake(320, 216) animated:NO];
            CGRect rect = CGRectMake(30, 1, 300, 30);
            [popoverController presentPopoverFromRect:rect inView:selectedCell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
            //[self presentModalViewController:navigationController animated:YES];
            [self presentViewController:navigationController animated:YES completion:nil];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void) gestisciResultAndTitleTag {
    selectedValue = [_pgnGame getTagValueByTagName:selectedTag];
    UIActionSheet *resultActionSheet = [[UIActionSheet alloc] init];
    
    if ([selectedTag isEqualToString:@"Result"]) {
        for (NSString *result in [UtilToView getResultsArray]) {
            [resultActionSheet addButtonWithTitle:result];
        }
        resultActionSheet.tag = 1;
    }
    else if ([selectedTag hasSuffix:@"Title"]) {
        for (NSString *title in [UtilToView getTitleArray]) {
            [resultActionSheet addButtonWithTitle:title];
        }
        resultActionSheet.tag = 2;
    }
    
    resultActionSheet.delegate = self;
    //if (IS_PHONE) {
        resultActionSheet.cancelButtonIndex = [resultActionSheet addButtonWithTitle:NSLocalizedString(@"MENU_CANCEL", nil)];
    //}
    //CGSize expectedCellLabelSize = [selectedCell.textLabel.text sizeWithFont:selectedCell.textLabel.font];
    CGSize expectedCellLabelSize = [selectedCell.textLabel.text sizeWithAttributes:@{NSFontAttributeName:selectedCell.textLabel.font}];
    CGRect resultRect = CGRectMake(expectedCellLabelSize.width + 10, 5, expectedCellLabelSize.width, selectedCell.bounds.size.height);
    [resultActionSheet showFromRect:resultRect inView:selectedCell animated:YES];
}

- (void) gestisciEcoTag {
    selectedValue = [_pgnGame getTagValueByTagName:selectedTag];
    if (!selectedValue) {
        //selectedValue = [suppTagDictionary objectForKey:selectedTag];
        selectedValue = [gameSuppOtherTagsDict objectForKey:selectedTag];
    }
    EcoTagViewController *ecoTagViewController = [[EcoTagViewController alloc] init];
    [ecoTagViewController setPreviousEco:selectedValue];
    navigationController = [[UINavigationController alloc] initWithRootViewController:ecoTagViewController];
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    ecoTagViewController.navigationItem.leftBarButtonItem = cancelButtonItem;
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveEcoButtonPressed)];
    ecoTagViewController.navigationItem.rightBarButtonItem = doneButtonItem;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"";
    hud.alpha = 0.7;
    hud.color = [UIColor blackColor];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (IS_PAD) {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
            [popoverController setPopoverContentSize:CGSizeMake(320, 216) animated:NO];
            CGRect rect = CGRectMake(30, 1, 300, 30);
            [popoverController presentPopoverFromRect:rect inView:selectedCell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
            //[self presentModalViewController:navigationController animated:YES];
            [self presentViewController:navigationController animated:YES completion:nil];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void) gestisciTextTag {
    UIViewController *viewController = [[UIViewController alloc] init];
    UIView *view = [[UIView alloc] init];   //view
    
    if (IS_IOS_7) {
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    view.backgroundColor = [UIColor grayColor];
    tfTag = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    tfTag.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    tfTag.borderStyle = UITextBorderStyleRoundedRect;
    tfTag.backgroundColor = [UIColor whiteColor];
    tfTag.textColor = [UIColor redColor];
    tfTag.textAlignment = NSTextAlignmentLeft;
    tfTag.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tfTag.autocorrectionType = UITextAutocorrectionTypeNo;
    tfTag.delegate = self;
    
    tfTag.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    
    [view addSubview:tfTag];
    viewController.view = view;
    selectedValue = [_pgnGame getTagValueByTagName:selectedTag];
    if (!selectedValue) {
        selectedValue = [gameSuppOtherTagsDict objectForKey:selectedTag];
    }
    //NSLog(@"VALUE = %@", selectedValue);
    
    if (selectedValue.length == 0) {
        selectedValue = @"?";
    }
    if ([selectedValue hasPrefix:@"?"]) {
        [tfTag setPlaceholder:selectedValue];
    }
    else {
        [tfTag setText:selectedValue];
    }
    navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.navigationItem.title = selectedTag;
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    //cancelButtonItem.tag = indexPath.row + 1;
    viewController.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveTextButtonPressed)];
    //doneButtonItem.tag = indexPath.row + 1;
    viewController.navigationItem.rightBarButtonItem = doneButtonItem;
    
    //UILabel *label = (UILabel *)[selectedCell viewWithTag:1];
    
    if (IS_PAD) {
        CGRect rect = CGRectMake(30, 1, 300, 20);
        popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        [popoverController setPopoverContentSize:CGSizeMake(320, 87) animated:NO];
        [popoverController presentPopoverFromRect:rect inView:selectedCell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
        //[self presentModalViewController:navigationController animated:YES];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    [tfTag becomeFirstResponder];
}

#pragma mark - Implementazione metodi di UIBarButtonItem

- (void) doneMenuButtonPressed:(id)sender {
    if (doneActionSheetMenu.window ) {
        [doneActionSheetMenu dismissWithClickedButtonIndex:0 animated:YES];
        doneActionSheetMenu = nil;
        return;
    }
    if (supplementalTagPopover.isPopoverVisible) {
        [supplementalTagPopover dismissPopoverAnimated:YES];
        supplementalTagPopover = nil;
    }
    
    if (tagsModified) {
        [self displayAlert];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
    
    
    
    NSString *reset = NSLocalizedString(@"MENU_RESET_TAG", nil);
    NSString *save = NSLocalizedString(@"MENU_SAVE", nil);
    NSString *saveAndExit = NSLocalizedString(@"MENU_SAVE_EXIT", nil);
    NSString *exitNoSave = NSLocalizedString(@"MENU_EXIT_NO_SAVE", nil);
    UIBarButtonItem *bbi = (UIBarButtonItem *)sender;
    
    //doneActionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    doneActionSheetMenu = [[UIActionSheet alloc] init];
    doneActionSheetMenu.delegate = self;
    
    [doneActionSheetMenu addButtonWithTitle:reset];
    [doneActionSheetMenu addButtonWithTitle:save];
    [doneActionSheetMenu addButtonWithTitle:saveAndExit];
    [doneActionSheetMenu addButtonWithTitle:exitNoSave];
    //if (IS_PHONE) {
        doneActionSheetMenu.cancelButtonIndex = [doneActionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_CANCEL", nil)];
    //}
    [doneActionSheetMenu setTag:100];
    [doneActionSheetMenu showFromBarButtonItem:bbi animated:YES];
}

- (void) actionMenuButtonPressed:(id) sender {
    if (supplementalTagPopover.isPopoverVisible) {
        [supplementalTagPopover dismissPopoverAnimated:YES];
        supplementalTagPopover = nil;
        return;
    }
    if (doneActionSheetMenu.window ) {
        [doneActionSheetMenu dismissWithClickedButtonIndex:0 animated:YES];
        doneActionSheetMenu = nil;
    }

    AdditionalTagTableViewController *attvc = [[AdditionalTagTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [attvc setPgnGame:_pgnGame];
    [attvc setOrderedSupplementalTag:gameSuppTagsDict.allKeys];
    [attvc setDelegate:self];
    //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:attvc];
    
    if (IS_PAD) {
        //UIBarButtonItem *bbi = (UIBarButtonItem *)sender;
        //supplementalTagPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
        //[supplementalTagPopover presentPopoverFromBarButtonItem:bbi permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [self.navigationController pushViewController:attvc animated:YES];
    }
    else {
        self.navigationItem.title = NSLocalizedString(@"BACK", nil);
        [self.navigationController pushViewController:attvc animated:YES];
    }
    
}

#pragma mark - Implementazione metodi ActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex<0) {
        return;
    }
    if (actionSheet.tag == 1) {
        NSString *result = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([result isEqualToString:NSLocalizedString(@"MENU_CANCEL", nil)]) {
            return;
        }
        //if (![result isEqualToString:selectedValue]) {
            
            if ([_pgnGame endsWithCheckMate]) {
                UIAlertView *checkMateAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CHECKMATE", nil) message:NSLocalizedString(@"CHECKMATE_RESULT", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [checkMateAlertView show];
                return;
            }
            
            
            //[_pgnGame replaceTagAndTagValue:selectedTag :result];
            //gameArray = [[_pgnGame getGameArray] mutableCopy];
            //[gameArray removeLastObject];
        
        
        
            //NSString *oldResult = [sevenTagDictionary objectForKey:@"Result"];
            //[sevenTagDictionary setObject:result forKey:selectedTag];
        
        NSString *oldResult = [gameSevenTagsDict objectForKey:@"Result"];
        [gameSevenTagsDict setObject:result forKey:selectedTag];
        
        
        //[_delegate saveGameResult:nil];
            //moves = [_pgnGame moves];
        
        NSLog(@"OLD RESULT = %@        RESULT = %@", oldResult, result);
        
            moves = [moves stringByReplacingOccurrencesOfString:oldResult withString:result];
            
            if ([_pgnGame isPosition]) {
                moves = [moves stringByReplacingOccurrencesOfString:@"1. XXX" withString:@"1..."];
            }
            
            [self.tableView reloadData];
            //[self salvaModificheInDatabase];
        //}

        return;
    }
    
    if (actionSheet.tag == 2) {
        NSString *info = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([info isEqualToString:NSLocalizedString(@"MENU_CANCEL", nil)]) {
            return;
        }
        //[suppTagDictionary setObject:info forKey:selectedTag];
        
        [gameOtherTagsDict setObject:info forKey:selectedTag];
        [gameSuppTagsDict setObject:info forKey:selectedTag];
        [gameSuppOtherTagsDict setObject:info forKey:selectedTag];
        
        //[self stampa];
        
        [self.tableView reloadData];
        return;
    }
    
    if (actionSheet.tag == 100) {
        NSString *scelta = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([scelta isEqualToString:NSLocalizedString(@"MENU_EXIT_NO_SAVE", nil)]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if ([scelta isEqualToString:NSLocalizedString(@"MENU_SAVE", nil)]) {
            [self salvaModificheInDatabase];
        }
        else if ([scelta isEqualToString:NSLocalizedString(@"MENU_SAVE_EXIT", nil)]) {
            [self salvaModificheInDatabase];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if ([scelta isEqualToString:NSLocalizedString(@"MENU_CANCEL", nil)]) {
            return;
        }
        else if ([scelta isEqualToString:NSLocalizedString(@"MENU_RESET_TAG", nil)]) {
            [self resetTag];
        }
    }
}

#pragma mark - Implementazione metodi per salvare i dati dopo le modifiche

- (void) cancelButtonPressed {
    if ([popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
    }
    if (navigationController) {
        //[navigationController dismissModalViewControllerAnimated:YES];
        [navigationController dismissViewControllerAnimated:YES completion:nil];
        navigationController = nil;
    }
}

- (void) saveDateButtonPressed {
    DateTagViewController *dtvc = navigationController.viewControllers[0];
    NSString *nuovaData = [dtvc nuovaData];
    if ([popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
        navigationController = nil;
    }
    if (navigationController) {
        //[navigationController dismissModalViewControllerAnimated:YES];
        [navigationController dismissViewControllerAnimated:YES completion:nil];
        navigationController = nil;
    }
    if (nuovaData) {
        //[_pgnGame replaceTagAndTagValue:selectedTag :nuovaData];
        //gameArray = [[_pgnGame getGameArray] mutableCopy];
        //[gameArray removeLastObject];
        
        //NSIndexPath *indexPath = [self.tableView indexPathForCell:selectedCell];
        //if (indexPath.section == 0) {
        //    [sevenTagDictionary setObject:nuovaData forKey:selectedTag];
        //}
        //else if (indexPath.section == 1) {
        //    [suppTagDictionary setObject:nuovaData forKey:selectedTag];
        //}
        if ([orderedSevenTags containsObject:selectedTag]) {
            [gameSevenTagsDict setObject:nuovaData forKey:selectedTag];
        }
        else {
            [gameSuppTagsDict setObject:nuovaData forKey:selectedTag];
            [gameOtherTagsDict setObject:nuovaData forKey:selectedTag];
            [gameSuppOtherTagsDict setObject:nuovaData forKey:selectedTag];
        }
        
        selectedCell = nil;
        selectedTag = nil;
        [self.tableView reloadData];
        //[self salvaModificheInDatabase];
        tagsModified = YES;
    }
}

- (void) saveTextButtonPressed {
    NSString *tfValue = [tfTag.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (tfValue.length == 0) {
        tfValue = @"?";
    }
    if ([popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
        navigationController = nil;
    }
    if (navigationController) {
        //[navigationController dismissModalViewControllerAnimated:YES];
        [navigationController dismissViewControllerAnimated:YES completion:nil];
        navigationController = nil;
    }
    if (![tfValue isEqualToString:selectedValue]) {
        //NSLog(@"Lo salvo lo stesso");
        //[_pgnGame replaceTagAndTagValue:selectedTag :tfValue];
        //gameArray = [[_pgnGame getGameArray] mutableCopy];
        //[gameArray removeLastObject];
        //NSIndexPath *indexPath = [self.tableView indexPathForCell:selectedCell];
        //if (indexPath.section == 0) {
        //    [sevenTagDictionary setObject:tfValue forKey:selectedTag];
        //}
        //else if (indexPath.section == 1) {
        //    [suppTagDictionary setObject:tfValue forKey:selectedTag];
        //}
        if ([orderedSevenTags containsObject:selectedTag]) {
            [gameSevenTagsDict setObject:tfValue forKey:selectedTag];
        }
        else {
            [gameSuppTagsDict setObject:tfValue forKey:selectedTag];
            [gameOtherTagsDict setObject:tfValue forKey:selectedTag];
            [gameSuppOtherTagsDict setObject:tfValue forKey:selectedTag];
        }
        selectedCell = nil;
        selectedTag = nil;
        tfTag = nil;
        [self.tableView reloadData];
        //[self salvaModificheInDatabase];
        tagsModified = YES;
    }
}

- (void) saveEcoButtonPressed {
    EcoTagViewController *etvc = navigationController.viewControllers[0];
    NSString *newEco = [etvc selectedEco];
    if ([popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
        navigationController = nil;
    }
    if (navigationController) {
        //[navigationController dismissModalViewControllerAnimated:YES];
        [navigationController dismissViewControllerAnimated:YES completion:nil];
        navigationController = nil;
    }
    if (![selectedValue isEqualToString:newEco]) {
        //[_pgnGame replaceTagAndTagValue:selectedTag :newEco];
        //gameArray = [[_pgnGame getGameArray] mutableCopy];
        //[gameArray removeLastObject];
        //[suppTagDictionary setObject:newEco forKey:selectedTag];
        [gameSuppTagsDict setObject:newEco forKey:selectedTag];
        [gameOtherTagsDict setObject:newEco forKey:selectedTag];
        [gameSuppOtherTagsDict setObject:newEco forKey:selectedTag];
        selectedCell = nil;
        selectedTag = nil;
        tfTag = nil;
        [self.tableView reloadData];
        //[self salvaModificheInDatabase];
        tagsModified = YES;
    }
}

- (void) resetTag {
    //if ([_pgnGame endsWithCheckMate]) {
        [_pgnGame resetTagExceptResult];
    //}
    //else {
    //    [_pgnGame resetTag];
    //    [self initData];
    //    [_delegate saveGameResult:nil];
    //}
    [self.tableView reloadData];
}

- (void) salvaModificheInDatabase {
    
    //NSLog(@"STO SALVANDO LA SEGUENTE PARTITA IN GAME_INFO_TABLE_VIEW_CONTROLLER:   %@", [_pgnGame moves]);
    
    NSMutableArray *allGamesAndAllTags = [_pgnFileDoc.pgnFileInfo getAllGamesAndTags];
    if ([_pgnGame indexInAllGamesAllTags] == -1) {
        [allGamesAndAllTags addObject:[_pgnGame getGameForAllGamesAndAllTags]];
        [_pgnGame setIndexInAllGamesAllTags:[allGamesAndAllTags indexOfObject:[_pgnGame getGameForAllGamesAndAllTags]]];
    }
    else {
        [[_pgnFileDoc.pgnFileInfo getAllGamesAndTags] replaceObjectAtIndex:[_pgnGame indexInAllGamesAllTags] withObject:[_pgnGame getGameForAllGamesAndAllTags]];
    }
    [_pgnFileDoc.pgnFileInfo salvaTutteLePartite];
    
    
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"SAVED" object:@"GameInfo"];
}


- (void) saveTagsInGame {
    for (NSString *tag in orderedSevenTags) {
        NSString *tagValue = [gameSevenTagsDict objectForKey:tag];
        [_pgnGame replaceTagAndTagValue:tag :tagValue];
    }
    
    //NSString *result = [sevenTagDictionary objectForKey:@"Result"];
    NSString *result = [gameSevenTagsDict objectForKey:@"Result"];
    if (_delegate) {
        [_delegate saveGameResult:result];
        [_delegate aggiornaTitoli];
    }
    
    [_pgnGame saveSupplementalTag:gameSuppOtherTagsDict];
    
    if (gamePositionTagDict.count > 0) {
        [_pgnGame savePositionTag:gamePositionTagDict];
    }
    
    
    
    tagsModified = NO;
}


#pragma mark - Implementazione metodi UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Implementazione metodi UIAlertViewDelegate

- (void) displayAlert {
    UIAlertView *salvaModificheAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SAVE_GAME_TAGS_TITLE", nil) message:NSLocalizedString(@"SAVE_GAME_TAGS_ALERT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"YES", nil) otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
    salvaModificheAlertView.tag = 10;
    [salvaModificheAlertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        NSString *risposta = [alertView buttonTitleAtIndex:buttonIndex];
        if ([risposta isEqualToString:NSLocalizedString(@"YES", nil)]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - Implementazione metodi AdditionalTagDelegate

- (void) saveAdditionalTag:(NSString *)additionalTag {
    [_pgnGame addSupplementalTag:additionalTag andTagValue:@"?"];
    if (IS_PAD) {
        [supplementalTagPopover dismissPopoverAnimated:YES];
        supplementalTagPopover = nil;
    }
    //gameArray = [[_pgnGame getGameArray] mutableCopy];
    //[gameArray removeLastObject];
    [self.tableView reloadData];
}

- (void) saveSupplementalTag:(NSDictionary *)supplementalTag {
    
    for (NSString *tagName in supplementalTag.allKeys) {
        BOOL tagPresente = [[supplementalTag objectForKey:tagName] boolValue];
        if (tagPresente) {
            if (![[gameSuppTagsDict allKeys] containsObject:tagName]) {
                NSString *tagValue = @"?";
                if ([tagName hasSuffix:@"Date"]) {
                    tagValue = @"????.??.??";
                }
                [gameSuppTagsDict setObject:tagValue forKey:tagName];
                [gameSuppOtherTagsDict setObject:tagValue forKey:tagName];
            }
        }
        else {
            [gameSuppTagsDict removeObjectForKey:tagName];
            [gameSuppOtherTagsDict removeObjectForKey:tagName];
        }
    }
    
    [orderedSuppOtherTags removeAllObjects];
    for (NSString *tag in orderedSuppTags) {
        if ([gameSuppOtherTagsDict.allKeys containsObject:tag]) {
            [orderedSuppOtherTags addObject:tag];
        }
    }
    
    //[self stampa];
    
    tagsModified = YES;
    
    [self.tableView reloadData];
}

/*
- (void) stampa {
    NSLog(@"GameSuppTagsDict %@", gameSuppTagsDict);
    NSLog(@"GameSuppOtherTagsDict %@", gameSuppOtherTagsDict);
    
    NSLog(@"OrderedSevenTags %@", orderedSevenTags);
    NSLog(@"OrderedSuppTags %@", orderedSuppTags);
    NSLog(@"OrderdSuppOtherTags %@", orderedSuppOtherTags);
}
*/
@end
