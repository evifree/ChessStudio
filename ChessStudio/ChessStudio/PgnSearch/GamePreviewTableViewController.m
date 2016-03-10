//
//  GamePreviewTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "GamePreviewTableViewController.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "PGNUtil.h"
#import "PGNAnalyzer.h"
#import "DatabaseForCopyTableViewController.h"
#import "DateTagViewController.h"
#import "TagGamePreviewCell.h"
#import "EcoTagViewController.h"
#import "SettingManager.h"

@interface GamePreviewTableViewController () {
    
    NSString *_game;
    NSString *_moves;
    
    NSMutableArray *gameArray;
    NSString *movesNoSymbols;
    
    
    CGFloat dimLabelLength;
    
    UIBarButtonItem *actionButton;
    UIActionSheet *actionSheetMenu;
    
    
    UIPopoverController *popoverController;
    UINavigationController *navigationController;
    TagGamePreviewCell *selectedCell;
    NSString *selectedTag;
    NSString *selectedValue;
    UITextField *tf1;
    
    UIMenuController *menuController;
    
    BOOL didDismiss;
    
    
    PGNGame *copiaPgnGame;
    
    
    
    //NSMutableDictionary *sevenTagDictionary;
    //NSMutableDictionary *suppTagDictionary;
    //NSArray *sevenTag;
    //NSArray *suppTag;
    //NSMutableArray *orderedSuppTag;
    
    
    
    
    
    NSArray *orderedSevenTags;
    NSMutableArray *orderedSuppTags;
    NSMutableArray *orderedSuppOtherTags;
    
    NSMutableDictionary *gameSevenTagsDict;
    NSMutableDictionary *gameSuppTagsDict;
    NSMutableDictionary *gameOtherTagsDict;
    NSMutableDictionary *gamePositionTagDict;
    NSMutableDictionary *gameSuppOtherTagsDict;
    
 }

@end

@implementation GamePreviewTableViewController

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
    
    if (_pgnFileDoc) {
        actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
        self.navigationItem.rightBarButtonItem = actionButton;
    }
    
    //menuController = [UIMenuController sharedMenuController];
    didDismiss = NO;
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedGameInfoNotification:) name:@"SAVED" object:@"GameInfo"];
    
    
    
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
    //self.navigationItem.title = [[[[[gameArray objectAtIndex:4] componentsSeparatedByString:@"\""] objectAtIndex:1] stringByAppendingString:@" - "] stringByAppendingString:[[[gameArray objectAtIndex:5] componentsSeparatedByString:@"\""] objectAtIndex:1]];
    [self setupTitle];
    if (IS_PAD) {
        dimLabelLength = 650.0;
        //dimLabelLength = 350.0;
    }
    else if (IS_IPHONE_6P) {
        dimLabelLength = 350.0;
    }
    else if (IS_IPHONE_6) {
        dimLabelLength = 320.0;
    }
    else {
        dimLabelLength = 200.0;
        //dimLabelLength = 250.0;
    }
    
    if (didDismiss) {
        didDismiss = NO;
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
        [self.tableView reloadData];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        if (actionSheetMenu) {
            [actionSheetMenu dismissWithClickedButtonIndex:-1 animated:YES];
            actionSheetMenu = nil;
        }
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (IsChessStudioLight) {
        if (IS_IOS_7) {
            self.canDisplayBannerAds = YES;
        }
    }
    
    //NSLog(@"Oggetto = %@", [_pgnGame moves]);
    //NSLog(@"Copia = %@", [copiaPgnGame moves]);
}

- (void) setupTitle {
    NSString *w = [gameSevenTagsDict objectForKey:@"White"];
    NSString *b = [gameSevenTagsDict objectForKey:@"Black"];
    self.navigationItem.title = [[w stringByAppendingString:@" - "] stringByAppendingString:b];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) setPgnGame:(PGNGame *)pgnGame {
    _pgnGame = pgnGame;
    
    //NSLog(@"L'indice della partita è %ld", [_pgnGame indexInAllGamesAllTags]);
    
    NSString *gameForIndex = [_pgnGame getGameForAllGamesAndAllTags];
    NSInteger index = [_pgnFileDoc.pgnFileInfo getIndexOfGame:gameForIndex];
    
    if (index == -1) {
        gameForIndex = [_pgnGame getOriginalPgn];
        index = [_pgnFileDoc.pgnFileInfo getIndexOfGame:gameForIndex];
        //NSLog(@"Ora l'indice ricalcolato della partita è %ld", index);
    }
    
    //NSLog(@"L'indice della partita è %ld", index);
    [_pgnGame setIndexInAllGamesAllTags:index];
    
    [self initData];
}

- (void) initData {
    _moves = [_pgnGame getGameMovesForPreview];
    movesNoSymbols = _moves;
    
    //NSLog(@"Moves: %@", _moves);
    
    gameArray = [[_pgnGame getGameArray] mutableCopy];
    [gameArray removeLastObject];
    
    gameSevenTagsDict = [_pgnGame getSevenTag];
    gameSuppTagsDict = [_pgnGame getSupplementalTagApp];
    gameOtherTagsDict = [_pgnGame getOtherTagApp];
    gamePositionTagDict = [_pgnGame getPositionTagDict];
    gameSuppOtherTagsDict = [[NSMutableDictionary alloc] initWithDictionary:gameSuppTagsDict];
    [gameSuppOtherTagsDict addEntriesFromDictionary:gameOtherTagsDict];
    
    //NSLog(@"%@", gameSevenTagsDict);
    //NSLog(@"%@", gameSuppTagsDict);
    //NSLog(@"%@", gameOtherTagsDict);
    //NSLog(@"%@", gamePositionTagDict);
    //NSLog(@"%@", gameSuppOtherTagsDict);
    
    //NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  HO ESEGUITO INIT_DATA IN GAME PREVIEW");
}

/*
- (void) ordinaSupplementalTags {
    NSMutableArray *tempSuppTag = [[NSMutableArray alloc] init];
    for (NSString *st in suppTag) {
        if ([orderedSuppTag containsObject:st]) {
            [tempSuppTag addObject:st];
        }
    }
    
    [orderedSuppTag removeAllObjects];
    [orderedSuppTag addObjectsFromArray:tempSuppTag];
    
    NSArray *suppTagOrdered = [UtilToView getSupplementalTagValues];
    NSMutableArray *newSuppTagOrdered = [[NSMutableArray alloc] init];
    for (NSString *st in suppTagOrdered) {
        if ([orderedSuppTag containsObject:st]) {
            [newSuppTagOrdered addObject:st];
        }
    }
    
    [orderedSuppTag removeAllObjects];
    [orderedSuppTag addObjectsFromArray:newSuppTagOrdered];
}
*/

- (BOOL) canBecomeFirstResponder {
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (gamePositionTagDict.count>0) {
        if (gameSuppOtherTagsDict.count > 0) {
            return 4;
        }
        else {
            return 3;
        }
    }
    else {
        if (gameSuppOtherTagsDict.count > 0) {
            return 3;
        }
        else {
            return 2;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 7;
    }
    if (section == 1) {
        if (gamePositionTagDict.count>0) {
            return 2;
        }
        else {
            if (gameSuppOtherTagsDict.count > 0) {
                return gameSuppOtherTagsDict.count;
            }
            else {
                return 1;
            }
        }
    }
    if (section == 2) {
        if (gamePositionTagDict.count>0) {
            if (gameSuppOtherTagsDict.count > 0) {
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
    //return [[[[gameArray objectAtIndex:section] componentsSeparatedByString:@"\""] objectAtIndex:0]stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger sezioneMosse = [tableView numberOfSections] - 1;
    
    if (indexPath.section == sezioneMosse) {
        CGSize constraint;
        CGSize size;
        
        UILabel *testSizeLabel = [[UILabel alloc] init];
        testSizeLabel.text = _moves;
        testSizeLabel.numberOfLines = 0;
        
        if (IS_PAD) {
            if (IS_PORTRAIT) {
                constraint = CGSizeMake(768, 20000.0f);
                //size = [_moves sizeWithFont:[UIFont fontWithName:@"Courier" size:16] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                testSizeLabel.font = [UIFont fontWithName:@"Courier" size:16.0];
                size = [testSizeLabel sizeThatFits:constraint];
            }
            else {
                constraint = CGSizeMake(1024, 20000.0f);
                //size = [_moves sizeWithFont:[UIFont fontWithName:@"Courier" size:16] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                testSizeLabel.font = [UIFont fontWithName:@"Courier" size:16.0];
                size = [testSizeLabel sizeThatFits:constraint];
            }
        }
        else if (IS_IPHONE_5) {
            if (IS_PORTRAIT) {
                constraint = CGSizeMake(640, 5000);
                //size = [_moves sizeWithFont:[UIFont fontWithName:@"Courier" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                testSizeLabel.font = [UIFont fontWithName:@"Courier" size:14.0];
                size = [testSizeLabel sizeThatFits:constraint];
            }
            else {
                constraint = CGSizeMake(1136, 5000);
                //size = [_moves sizeWithFont:[UIFont fontWithName:@"Courier" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                testSizeLabel.font = [UIFont fontWithName:@"Courier" size:14.0];
                size = [testSizeLabel sizeThatFits:constraint];
            }
        }
        else if (IS_PHONE) {
            if (IS_PORTRAIT) {
                constraint = CGSizeMake(640, 3000);
                //size = [_moves sizeWithFont:[UIFont fontWithName:@"Courier" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                testSizeLabel.font = [UIFont fontWithName:@"Courier" size:14.0];
                size = [testSizeLabel sizeThatFits:constraint];
            }
            else {
                constraint = CGSizeMake(960, 3000);
                //size = [_moves sizeWithFont:[UIFont fontWithName:@"Courier" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                testSizeLabel.font = [UIFont fontWithName:@"Courier" size:14.0];
                size = [testSizeLabel sizeThatFits:constraint];
            }
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
    static NSString *CellIdentifier = @"Cell GamePreview";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    TagGamePreviewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    
    //if (cell == nil) {
    //    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //}
    
    
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
    
    
    if (indexPath.section == 0) {
        
        //NSString *tag = [[[[gameArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"\""] objectAtIndex:0]stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
        
        NSString *tag = [orderedSevenTags objectAtIndex:indexPath.row];
        
        NSMutableString *testo = [[NSMutableString alloc] initWithString:tag];
        [testo appendString:@":  "];
        cell.textLabel.text = testo;
        //CGSize expectedCellLabelSize = [testo sizeWithFont:cell.textLabel.font];
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
            label.textColor = [UIColor redColor];
            //label.text = [[[gameArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"\""] objectAtIndex:1];
            //label.text = [sevenTagDictionary objectForKey:tag];
            label.text = [gameSevenTagsDict objectForKey:tag];
            [cell.contentView addSubview:label];
        }
        else {
            //label.text = [[[gameArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"\""] objectAtIndex:1];
            //label.text = [sevenTagDictionary objectForKey:tag];
            label.text = [gameSevenTagsDict objectForKey:tag];
        }
        
        //UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapCell:)];
        //doubleTapRecognizer.numberOfTapsRequired = 1;
        //[cell addGestureRecognizer:doubleTapRecognizer];
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [cell addGestureRecognizer:recognizer];
        
        return cell;
    }
    
    if (indexPath.section == 1 && gamePositionTagDict.count > 0) {
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
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [cell addGestureRecognizer:recognizer];
        
        return cell;
    }
    
    if (indexPath.section == 1 && gamePositionTagDict.count == 0) {
        
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
            
            UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            [cell addGestureRecognizer:recognizer];
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
                cell.textLabel.text = _moves;
            }
            else {
                cell.textLabel.text = _moves;
                //cell.textLabel.text = movesNoSymbols;
            }
            
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
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
            
            UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            [cell addGestureRecognizer:recognizer];
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
                cell.textLabel.text = _moves;
            }
            else {
                cell.textLabel.text = _moves;
                //cell.textLabel.text = movesNoSymbols;
            }
        
            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
        
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
            cell.textLabel.text = _moves;
        }
        else {
            cell.textLabel.text = _moves;
            //cell.textLabel.text = movesNoSymbols;
        }
        
        [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
        
        //cell.textLabel.text = [pgnAnalyzer getParsedGameWithChessSymbolsAndNoComments];
        
        return cell;
    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 1) {
        
        UITableViewCell *selectedCellToDelete = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *tag = [selectedCellToDelete.textLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@": "]];
        if ([tag isEqualToString:@"FEN"] || [tag isEqualToString:@"SetUp"]) {
            return NO;
        }
        
        
        return YES;
    }
    return NO;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        //UITableViewCell *selectedCellToDelete = [self.tableView cellForRowAtIndexPath:indexPath];
        //NSString *tag = [selectedCellToDelete.textLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@": "]];
        NSString *tag = [orderedSuppTags objectAtIndex:indexPath.row];
        //NSString *tagValue = [_pgnGame getTagValueByTagName:tag];
        NSString *tagValue = [gameSuppOtherTagsDict objectForKey:tag];
        //UILabel *label = (UILabel *)[selectedCellToDelete viewWithTag:1];
        NSLog(@"Devo eliminare la cella: %@ con valore %@", tag, tagValue);
        [_pgnGame removeTag:tag];
        [orderedSuppTags removeObject:tag];
        tagValue = [_pgnGame getTagValueByTagName:tag];
        NSLog(@"Verifica tag: %@ con valore %@", tag, tagValue);
        //gameArray = [[_pgnGame getGameArray] mutableCopy];
        //[gameArray removeLastObject];
        //NSLog(@"Nuovo Valore per game array = %d", gameArray.count);
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
        [[_pgnFileDoc.pgnFileInfo getAllGamesAndTags] replaceObjectAtIndex:[_pgnGame indexInAllGamesAllTags] withObject:[_pgnGame getGameForAllGamesAndAllTags]];
        
        //[tableView reloadData];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.tableView isEditing]) {
        return UITableViewCellEditingStyleNone;
    }
    if (indexPath.section == 1 && [self.tableView isEditing] && (gameArray.count - 7 - 1) == indexPath.row) {
        return UITableViewCellEditingStyleInsert;
    }
    else {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}
*/


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    //NSString *tag = [gameArray objectAtIndex:fromIndexPath.row + 7];
    
    NSString *tag = [orderedSuppTags objectAtIndex:fromIndexPath.row];
    NSLog(@"TagSelezionato = %@", tag);
    [orderedSuppTags removeObject:tag];
    //[gameArray removeObject:tag];
    //[gameArray insertObject:tag atIndex:toIndexPath.row + 7];
    
    //for (NSString *t in gameArray) {
    //    NSLog(@"%@", t);
    //}
    //NSLog(@"\n");
    //[_pgnGame aggiornaOrdineTagArray:gameArray];
    
    
    
    
    
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    if (indexPath.section == 1) {
        return NO;
    }
    return NO;
}

/*
- (BOOL) tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"ShouldShowmenu chiamato");
    if (indexPath.section == 0) {
        return YES;
    }
    return NO;
}

- (BOOL) tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    NSLog(@"canPerformaction");
    if (action == @selector(editMenuPressed:)) {
        NSLog(@"CanPerformEdit");
        return YES;
    }
    return NO;
}

- (void) tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    NSLog(@"PerformAction chiamato");
}
*/

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    
    if (_pgnFileDoc.pgnFileInfo.isInCloud) {
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        selectedCell = (TagGamePreviewCell *)[recognizer view];
        
        [self becomeFirstResponder];
        
        CGPoint tapPoint = [recognizer locationInView:selectedCell];
        //CGPoint tapPointInView = [selectedCell convertPoint:tapPoint toView:self.view];
        
        //CGRect rect = rect = CGRectMake(tapPointInView.x, tapPointInView.y, 10.0, 10.0);
        
        CGRect newRect = CGRectMake(tapPoint.x, selectedCell.frame.origin.y + 20, 10.0, 10.0);
        
        
        /*
        if (IsChessStudioLight && self.canDisplayBannerAds) {
            rect = CGRectMake(tapPointInView.x, tapPointInView.y - 66, 10.0, 10.0);
        }
        else {
            
        }*/
        
        selectedTag = [selectedCell.textLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@": "]];
        
        //NSLog(@"Tag selezionato = %@", selectedTag);
        
        if ([selectedTag isEqualToString:@"FEN"] || [selectedTag isEqualToString:@"SetUp"]) {
            UIAlertView *tagPositionAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"SETUP_POSITION_EDIT_TAG", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [tagPositionAlertView show];
            return;
        }
        
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:selectedCell];
        UIMenuItem *editItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"EDIT", nil) action:@selector(editMenuPressed:)];
        UIMenuItem *delItem = nil;
        
        if (selectedIndexPath.section > 0) {
            delItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"DELETE", nil) action:@selector(delMenuPressed:)];
        }
        
        if (!menuController) {
            menuController = [UIMenuController sharedMenuController];
        }
        
        [menuController setMenuItems:[NSArray arrayWithObjects:editItem, delItem, nil]];
        
        //UIMenmenuController = [UIMenuController sharedMenuController];
        
        //[menuController setTargetRect:selectedCell.frame inView:selectedCell.superview];
        
        [menuController setTargetRect:newRect inView:self.tableView];
        [menuController setMenuVisible:YES animated:YES];
    }
}

/*
- (void) didDoubleTapCell:(UITapGestureRecognizer *)sender {
    
    
    [self performSelector: @selector(deselect:) withObject:self.tableView afterDelay: 0.1f];
    
    UITableViewCell *cell = (UITableViewCell *)sender.view;
    
    NSString *tagSelector = cell.textLabel.text;
    if ([tagSelector hasPrefix:@"Event"]) {
        NSLog(@"Devo gestire modifica Event");
    }
    else if ([tagSelector hasPrefix:@"Site"]) {
        NSLog(@"Devo gestire modifica Site");
    }
    else if ([tagSelector hasPrefix:@"Date"]) {
        DateTagViewController *dtvc = [[DateTagViewController alloc] init];
        UINavigationController *tagNavigationController = [[UINavigationController alloc] initWithRootViewController:dtvc];
        if (IS_PAD) {
            tagNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        else {
            tagNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        [self presentModalViewController:tagNavigationController animated:YES];
    }
    else if ([tagSelector hasPrefix:@"Round"]) {
        NSLog(@"Devo gestire modifica Round");
    }
    else if ([tagSelector hasPrefix:@"White"]) {
        NSLog(@"Devo gestire modifica White");
    }
    else if ([tagSelector hasPrefix:@"Black"]) {
        NSLog(@"Devo gestire modifica Black");
    }
    else if ([tagSelector hasPrefix:@"Result"]) {
        NSLog(@"Devo gestire modifica Result");
    }
    return;
    
    
    //PgnTagFieldViewController *pgnTagFieldVC = [[PgnTagFieldViewController alloc] init];
    //UINavigationController *pgnTagFieldNavigationController = [[UINavigationController alloc] initWithRootViewController:pgnTagFieldVC];
    //if (IS_PAD) {
    //    pgnTagFieldNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    //}
    //else {
    //    pgnTagFieldNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
    //}
    //[self presentModalViewController:pgnTagFieldNavigationController animated:YES];
}
*/

- (void)deselect:(UITableView *)tableView {
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated: YES];
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
    
    //if (indexPath.section == 1) {
        //if (indexPath.row == 0) {
            //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
            //GamePreviewOnTextViewController *gpotv = [sb instantiateViewControllerWithIdentifier:@"GamePreviewOnTextView"];
            //[gpotv setMoves:_moves];
            //[self.navigationController pushViewController:gpotv animated:YES];
        //}
        
        //return;
    //}
    
    if (indexPath.section == 0) {
        
        //[self performSelector: @selector(deselect:) withObject:self.tableView afterDelay: 0.1f];
        //selectedCell = (TagGamePreviewCell *)[tableView cellForRowAtIndexPath:indexPath];
        //selectedTag = [selectedCell.textLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@": "]];
        return;
    }
    NSInteger sezioneMosse = [tableView numberOfSections] - 1;
    
    
    if (indexPath.section == sezioneMosse) {
        if (indexPath.row == 0) {
            //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
            UIStoryboard *sb = [UtilToView getStoryBoard];
            BoardViewController *bvc = [sb instantiateViewControllerWithIdentifier:@"BoardViewController"];
            [bvc setDelegate:self];
            bvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:bvc];
            
            
            if (IsChessStudioLight && IS_IOS_7) {
                bvc.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
            }
            
            //NSMutableString *game = [[NSMutableString alloc] initWithString:movesNoSymbols];
            
            //PGNGame *pgnGame = [[PGNGame alloc] initWithPgn:_game];

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.minSize = [UtilToView getSizeOfMBProgress];
                hud.labelText = @"Loading ...";
            
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                    
                    @try {
                        [bvc setPgnGame:_pgnGame];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@", exception.description);
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        NSString *title = NSLocalizedString(@"TITLE_ERROR_IN_GAME_PREVIEW", nil);
                        NSString *message = NSLocalizedString(@"MSG_ERROR_IN_GAME_PREVIEW", nil);
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertView show];
                        return;
                    }
                    
                
                    //[bvc setPgnGame:_pgnGame];
                    [bvc setPgnFileDoc:_pgnFileDoc];
                    //[self presentModalViewController:boardNavigationController animated:YES];
                    [self presentViewController:boardNavigationController animated:YES completion:nil];
                    didDismiss = YES;
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
            
            //[bvc setGameToView:game];
            
            //[self.navigationController pushViewController:bvc animated:YES];
            //[self presentModalViewController:boardNavigationController animated:YES];
        }
    }
}

- (void) actionButtonPressed:(id)sender {
    if (actionSheetMenu.window ) {
        [actionSheetMenu dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    NSString *cancelButton;
    if (IS_PAD) {
        cancelButton = @"";
    }
    else {
        cancelButton = NSLocalizedString(@"MENU_CANCEL", nil);
    }
    
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    
    
    //actionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    actionSheetMenu = [[UIActionSheet alloc] init];
    actionSheetMenu.delegate = self;
    actionSheetMenu.tag = 100;
    //[actionSheetMenu addButtonWithTitle:NSLocalizedString(@"EDIT", nil)];
    //[actionSheetMenu addButtonWithTitle:NSLocalizedString(@"TAG", nil)];
    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_COPY_ONE_GAME", nil)];
    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_EMAIL_GAME", nil)];
    actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
    //if (IS_PHONE) {
    //    actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_CANCEL", nil)];
    //}
    [actionSheetMenu showFromBarButtonItem:button animated:YES];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex<0) {
        return;
    }
    
    if (actionSheet.tag == 1) {
        NSString *result = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([result isEqualToString:NSLocalizedString(@"MENU_CANCEL", nil)]) {
            return;
        }
        if (![result isEqualToString:selectedValue]) {
            NSLog(@"Devo salvare Result = %@", result);
            [_pgnGame replaceTagAndTagValue:selectedTag :result];
            //gameArray = [[_pgnGame getGameArray] mutableCopy];
            //[gameArray removeLastObject];
            //_moves = [_pgnGame moves];
            [self initData];
            [self.tableView reloadData];
            [self salvaModificheInDatabase];
        }
        return;
    }
    
    if (actionSheet.tag == 100) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if ([title isEqualToString:NSLocalizedString(@"TAG", nil)]) {
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
            return;
        }
        
        
        if ([title isEqualToString:NSLocalizedString(@"MENU_COPY_ONE_GAME", nil)]) {
            DatabaseForCopyTableViewController *dfctvc = [[DatabaseForCopyTableViewController alloc] initWithStyle:UITableViewStylePlain];
            _game = [_pgnGame getGameForCopy];
            NSArray *copyGameArray = [NSArray arrayWithObject:_game];
            [dfctvc setPgnFileDoc:_pgnFileDoc];
            [dfctvc setGamesToCopyArray:copyGameArray];
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
        if ([title isEqualToString:NSLocalizedString(@"EDIT", nil)]) {
            if (![self.tableView isEditing]) {
                actionButton = self.navigationItem.rightBarButtonItem;
                UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
                self.navigationItem.rightBarButtonItem = doneButton;
                [self.tableView setEditing:YES animated:YES];
            }
        }
        if ([title isEqualToString:NSLocalizedString(@"MENU_EMAIL_GAME", nil)]) {
            [self manageGameByEmail];
        }
    }
}

- (void) doneButtonPressed {
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = actionButton;
}

- (void) manageGameByEmail {
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@""];
        
        //NSArray *toRecipients = [NSArray arrayWithObjects:NSLocalizedString(@"EMAIL", nil), nil];
        [mailer setToRecipients:[[SettingManager sharedSettingManager] getRecipients]];
        
        //UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
        //NSData *imageData = UIImagePNGRepresentation(myImage);
        //[mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"mobiletutsImage"];
        
        
        //[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        //[[self.view superview].superview.superview.layer renderInContext:UIGraphicsGetCurrentContext()];
        /*
         UIGraphicsBeginImageContext([UIScreen mainScreen].bounds.size);
         [boardView.layer renderInContext:UIGraphicsGetCurrentContext()];
         UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         NSData *imageData = UIImagePNGRepresentation(image);
         [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"game"];
         */
        //[imageData writeToFile:@"image1.jpeg" atomically:YES];
        
        NSString *emailBody = @"";
        if (_pgnGame) {
            emailBody = [_pgnGame getGameForMail];
            //emailBody = [_gameWebView getMosseWebPerEmail];
        }
        [mailer setMessageBody:emailBody isHTML:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self presentModalViewController:mailer animated:YES];
            [self presentViewController:mailer animated:YES completion:nil];
        });
        //[self presentModalViewController:mailer animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"NO_EMAIL_SETUP", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) editMenuPressed:(id)sender {
    
    //if ([selectedTag isEqualToString:@"FEN"] || [selectedTag isEqualToString:@"SetUp"]) {
    //    UIAlertView *editPositionTagAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"La modifica di questo tag potrebbe essre pericolosa" delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"OK", nil];
    //    editPositionTagAlertView.tag = 0;
    //    [editPositionTagAlertView show];
    //    return;
    //}
    
    if ([selectedTag isEqualToString:@"Date"]  || [selectedTag hasSuffix:@"Date"]) {
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
        return;
    }
    
    if ([selectedTag isEqualToString:@"Result"] || [selectedTag hasSuffix:@"Title"]) {
        selectedValue = [_pgnGame getTagValueByTagName:selectedTag];
        UIActionSheet *resultActionSheet = [[UIActionSheet alloc] init];
        
        if ([selectedTag isEqualToString:@"Result"]) {
            for (NSString *result in [UtilToView getResultsArray]) {
                [resultActionSheet addButtonWithTitle:result];
            }
        }
        else if ([selectedTag hasSuffix:@"Title"]) {
            for (NSString *title in [UtilToView getTitleArray]) {
                [resultActionSheet addButtonWithTitle:title];
            }
        }
        
        resultActionSheet.delegate = self;
        resultActionSheet.tag = 1;
        //if (IS_PHONE) {
            resultActionSheet.cancelButtonIndex = [resultActionSheet addButtonWithTitle:NSLocalizedString(@"MENU_CANCEL", nil)];
        //}
        //CGSize expectedCellLabelSize = [selectedCell.textLabel.text sizeWithFont:selectedCell.textLabel.font];
        CGSize expectedCellLabelSize = [selectedCell.textLabel.text sizeWithAttributes:@{NSFontAttributeName: selectedCell.textLabel.font}];
        CGRect resultRect = CGRectMake(expectedCellLabelSize.width + 10, 5, expectedCellLabelSize.width, selectedCell.bounds.size.height);
        [resultActionSheet showFromRect:resultRect inView:selectedCell animated:YES];
        return;
    }
    
    if ([selectedTag isEqualToString:@"ECO"]) {
        selectedValue = [_pgnGame getTagValueByTagName:selectedTag];
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
        return;
    }
    
    //if ([selectedTag isEqualToString:@"Event"] || [selectedTag isEqualToString:@"Site"] || [selectedTag isEqualToString:@"Round"] || [selectedTag isEqualToString:@"White"] || [selectedTag isEqualToString:@"Black"] || [selectedTag hasSuffix:@"FideId"] || [selectedTag hasSuffix:@"Elo"] || [selectedTag isEqualToString:@"Opening"] || [selectedTag isEqualToString:@"Variation"] || [selectedTag isEqualToString:@"SubVariation"]) {
        UIViewController *viewController = [[UIViewController alloc] init];
    
    
        if (IS_IOS_7) {
            viewController.edgesForExtendedLayout = UIRectEdgeNone;
        }
    
    
        UIView *view = [[UIView alloc] init];   //view
        view.backgroundColor = [UIColor grayColor];
        tf1 = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        tf1.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        tf1.borderStyle = UITextBorderStyleRoundedRect;
        tf1.backgroundColor = [UIColor whiteColor];
        tf1.textColor = [UIColor redColor];
        tf1.textAlignment = NSTextAlignmentLeft;
        tf1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tf1.autocorrectionType = UITextAutocorrectionTypeNo;
        tf1.delegate = self;
    
        tf1.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    
        //tf1.tag = indexPath.row + 1;
        [view addSubview:tf1];
        viewController.view = view;
        selectedValue = [_pgnGame getTagValueByTagName:selectedTag];
        
        //NSLog(@"VALUE = %@", selectedValue);
        
        if (selectedValue.length == 0) {
            selectedValue = @"?";
        }
        if ([selectedValue hasPrefix:@"?"]) {
            [tf1 setPlaceholder:selectedValue];
        }
        else {
            [tf1 setText:selectedValue];
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
        [tf1 becomeFirstResponder];
        return;
    //}
}

- (void) delMenuPressed:(id)sender {
    
    
    [gameSuppTagsDict removeObjectForKey:selectedTag];
    [gameOtherTagsDict removeObjectForKey:selectedTag];
    [gameSuppOtherTagsDict removeObjectForKey:selectedTag];
    
    [orderedSuppOtherTags removeAllObjects];
    for (NSString *tag in orderedSuppTags) {
        if ([gameSuppOtherTagsDict.allKeys containsObject:tag]) {
            [orderedSuppOtherTags addObject:tag];
        }
    }
    
    
    [_pgnGame removeTag:selectedTag];
    gameArray = [[_pgnGame getGameArray] mutableCopy];
    [gameArray removeLastObject];
    
    
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:selectedCell];

    if (gameSuppOtherTagsDict.count > 0) {
        [self.tableView deleteRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:[selectedIndexPath section]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self salvaModificheInDatabase];
    [self.tableView reloadData];
}

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

#pragma mark - Implementazione metodi per salvare i dati dopo le modifiche

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
        [_pgnGame replaceTagAndTagValue:selectedTag :nuovaData];
        gameArray = [[_pgnGame getGameArray] mutableCopy];
        [gameArray removeLastObject];
        
        selectedCell = nil;
        selectedTag = nil;
        
        [self initData];
        [self.tableView reloadData];
        [self salvaModificheInDatabase];
    }
}

- (void) saveTextButtonPressed {
    NSString *tfValue = [tf1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
        [_pgnGame replaceTagAndTagValue:selectedTag :tfValue];
        gameArray = [[_pgnGame getGameArray] mutableCopy];
        [gameArray removeLastObject];
        selectedCell = nil;
        selectedTag = nil;
        tf1 = nil;
        
        
        //NSLog(@"Prima di salvare la partita stampo l'index di PGNGame = %d", [_pgnGame indexInAllGamesAllTags]);
        
        [self initData];
        [self.tableView reloadData];
        [self salvaModificheInDatabase];
        [self setupTitle];
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
        [_pgnGame replaceTagAndTagValue:selectedTag :newEco];
        gameArray = [[_pgnGame getGameArray] mutableCopy];
        [gameArray removeLastObject];
        selectedCell = nil;
        selectedTag = nil;
        tf1 = nil;
        [self initData];
        [self.tableView reloadData];
        [self salvaModificheInDatabase];
    }
}


- (void) salvaModificheInDatabase {
    //NSLog(@"Sto salvando in salvamodificheInDatabase");
    [[_pgnFileDoc.pgnFileInfo getAllGamesAndTags] replaceObjectAtIndex:[_pgnGame indexInAllGamesAllTags] withObject:[_pgnGame getGameForAllGamesAndAllTags]];
    [_pgnFileDoc.pgnFileInfo salvaTutteLePartite];
    if (_delegate) {
        [_delegate aggiorna:_pgnGame];
    }
}

#pragma mark - Implementazione metodi UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Implementazione metodi UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *comando = [alertView buttonTitleAtIndex:buttonIndex];
    NSLog(@"%@", comando);
    if (alertView.tag == 0) {
        NSLog(@"Devo gestire l'edit del tag");
    }
    else if (alertView.tag == 1) {
        NSLog(@"Devo gestire il delete del tag");
    }
}

#pragma mark - Implementazione metodi BoardViewControllerDelegate

- (void) updateGamePreviewTableViewController {
    [self initData];
    [self.tableView reloadData];
}

- (void) updatePgnGame:(PGNGame *)pgnGame {
    _pgnGame = pgnGame;
}

#pragma mark - Implementazione metodo ricezione Notifica da GameInfoTableViewController per aggiornare la partita salvata

- (void) receivedGameInfoNotification:(NSNotification *) notification {
    //NSLog(@"Game Preview ha ricevuto la notifica con name = %@", notification.name);
    //NSString *s = [notification object];
    //NSLog(@"OGGETTO NOTIFICA = %@", s);
    [self initData];
    [self.tableView reloadData];
}

#pragma mark - Implementazione metodi AdditionalTagTableViewControllerDelegate

- (void) saveAdditionalTag:(NSString *)additionalTag {
    [_pgnGame addSupplementalTag:additionalTag andTagValue:@"?"];
    if (IS_PAD) {
        //[supplementalTagPopover dismissPopoverAnimated:YES];
        //supplementalTagPopover = nil;
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
    
    //tagsModified = YES;
    
    [self.tableView reloadData];
}

#pragma mark - Implementazione metodi delegate di BoardViewController

- (PGNGame *) getNextGame {
    if (_delegate) {
       PGNGame *pgn = [_delegate getNextGame];
        if (pgn) {
            [self setPgnGame:pgn];
            return pgn;
        }
    }
    return nil;
}

- (PGNGame *) getPreviousGame {
    if (_delegate) {
        PGNGame *pgn = [_delegate getPreviousGame];
        if (pgn) {
            [self setPgnGame:pgn];
            return pgn;
        }
    }
    return nil;
}

@end
