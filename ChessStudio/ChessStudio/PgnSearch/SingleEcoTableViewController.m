//
//  SingleEcoTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 20/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "SingleEcoTableViewController.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "DatabaseForCopyTableViewController.h"

#import "EcoBoardPreviewTableViewController.h"
#import "SettingManager.h"

@interface SingleEcoTableViewController () {

    //NSMutableArray *ecoArray;
    //NSMutableDictionary *ecoDictionary;
    //NSMutableDictionary *ecoDictionaryNoDoppie;
    
    
    NSCountedSet *ecoSiglaCountedSet;  //contiene le sigle senza apici con il numero di occorrenze
    NSArray *ecoSigle;  //contiene le sigle senza apici.
    NSMutableDictionary *ecoSigleDictionary;
    NSMutableDictionary *numGamesForEcoSigla;
    
    UIBarButtonItem *actionBarButtonItem;
    UIActionSheet *actionSheetMenu;
    UIActionSheet *copyActionSheetMenu;
    
    NSArray *partiteSelezionateDaCopiareEliminare;
    NSMutableArray *gamesToDelete;
    
    
    NSMutableAttributedString *ecoAttrText;
    
    UIPopoverController *gamePreviewPopoverController;
    SettingManager *settingManager;
}

@end

@implementation SingleEcoTableViewController

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
    
    actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    self.navigationItem.rightBarButtonItem = actionBarButtonItem;
    
    if (IsChessStudioLight) {
        //if (IS_IOS_7) {
            //self.canDisplayBannerAds = YES;
        //}
    }
    
    if (_pgnFileDoc.pgnFileInfo.isInCloud) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    if (_fromSWReveal) {
        self.navigationItem.rightBarButtonItem = nil;
        settingManager = [SettingManager sharedSettingManager];
    }
    
    
    [self decidiTitolo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    if (IS_PHONE) {
//        
//        self.navigationItem.title = [NSString stringWithFormat:@"%@", _ecoTitle];
//        return;
//        
//        UIView *titoloView;
//        UILabel *label1;
//        UILabel *label2;
//        if (IS_ITALIANO) {
//            titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, self.navigationController.navigationBar.frame.size.height)];
//            label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 28)];
//            label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 150, 16)];
//        }
//        else {
//            titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
//            label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 190, 28)];
//            label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 190, 16)];
//        }
//        
//        //UIView *titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
//        //UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 190, 28)];
//        label1.font = [UIFont boldSystemFontOfSize:17.0];
//        label1.textColor = [UIColor whiteColor];
//        //label1.text = [NSString stringWithFormat:NSLocalizedString(@"ECO_TABLE_VIEW_CONTROLLER_TITLE", nil), @""];
//        label1.text = _ecoTitle;
//        label1.backgroundColor = [UIColor clearColor];
//        label1.textAlignment = NSTextAlignmentCenter;
//        [titoloView addSubview:label1];
//        
//        //UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 190, 16)];
//        label2.font = [UIFont boldSystemFontOfSize:17.0];
//        label2.text = _pgnFileDoc.pgnFileInfo.fileName;
//        label2.backgroundColor = [UIColor clearColor];
//        label2.textColor = [UIColor whiteColor];
//        label2.textAlignment = NSTextAlignmentCenter;
//        [titoloView addSubview:label2];
//        self.navigationItem.titleView = titoloView;
//    }
//    else {
//        if (_fromSWReveal) {
//            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
//            titleLabel.backgroundColor = [UIColor clearColor];
//            titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:35.0];
//            titleLabel.textColor = UIColorFromRGB(0x0000CD);
//            titleLabel.text = _ecoTitle;
//            [titleLabel setTextAlignment:NSTextAlignmentCenter];
//            titleLabel.adjustsFontSizeToFitWidth = YES;
//            self.navigationItem.titleView = titleLabel;
//        }
//        else {
//            self.navigationItem.title = [NSString stringWithFormat:@"%@ in %@", _ecoTitle, _pgnFileDoc.pgnFileInfo.fileName];
//        }
//    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (settingManager) {
        if (![settingManager ecoBoardPreviewHintDisplayed]) {
            //UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Hint" message:@"Eco Board Preview Hint" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Remind me", nil];
            //av.tag = 10;
            //[av show];
            UIAlertController *hintAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"HINT", nil) message:NSLocalizedString(@"ECO_BOARD_HINT", nil) preferredStyle:UIAlertControllerStyleAlert];
            [hintAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [settingManager setEcoBoardPreviewHintDisplayed:YES];
            }]];
            [hintAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"HINT_AGAIN", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self presentViewController:hintAlertController animated:YES completion:nil];
        }
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

- (void) decidiTitolo {
    if (IS_PHONE) {
        
        self.navigationItem.title = [NSString stringWithFormat:@"%@", _ecoTitle];
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
        label1.font = [UIFont boldSystemFontOfSize:17.0];
        label1.textColor = [UIColor whiteColor];
        //label1.text = [NSString stringWithFormat:NSLocalizedString(@"ECO_TABLE_VIEW_CONTROLLER_TITLE", nil), @""];
        label1.text = _ecoTitle;
        label1.backgroundColor = [UIColor clearColor];
        label1.textAlignment = NSTextAlignmentCenter;
        [titoloView addSubview:label1];
        
        //UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 190, 16)];
        label2.font = [UIFont boldSystemFontOfSize:17.0];
        label2.text = _pgnFileDoc.pgnFileInfo.fileName;
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = [UIColor whiteColor];
        label2.textAlignment = NSTextAlignmentCenter;
        [titoloView addSubview:label2];
        self.navigationItem.titleView = titoloView;
    }
    else {
        if (_fromSWReveal) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
            titleLabel.backgroundColor = [UIColor clearColor];
            //titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:35.0];
            //titleLabel.textColor = UIColorFromRGB(0x0000CD);
            //titleLabel.text = _ecoTitle;
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            
            NSMutableAttributedString *testoAttributed = [[NSMutableAttributedString alloc] initWithString:_ecoTitle];
            NSDictionary *attributoTesto = @{NSFontAttributeName:[UIFont fontWithName:@"PT-FuturisExtraBoldCyrillicA" size:40.0], NSForegroundColorAttributeName : [UIColor blackColor]};
            [testoAttributed setAttributes:attributoTesto range:NSMakeRange(0, [_ecoTitle length])];
            titleLabel.attributedText = testoAttributed;
            
            
            
            self.navigationItem.titleView = titleLabel;
        }
        else {
            self.navigationItem.title = [NSString stringWithFormat:@"%@ in %@", _ecoTitle, _pgnFileDoc.pgnFileInfo.fileName];
        }
    }
}

/*
- (void) setSingleEcoArray:(NSArray *)singleEcoArray {
    _singleEcoArray = [singleEcoArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSMutableArray *singleEcoArrayWithSeparator = [[NSMutableArray alloc] init];
    for (NSString *eco in _singleEcoArray) {
        NSString *ecoConSeparator = [eco stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
        [singleEcoArrayWithSeparator addObject:ecoConSeparator];
        NSLog(@"%@", ecoConSeparator);
    }
    
    ecoSiglaCountedSet = [[NSCountedSet alloc] init];
    ecoSigleDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *ecoSep in singleEcoArrayWithSeparator) {
        NSArray *ecoTemp = [ecoSep componentsSeparatedByString:separator];
        NSString *ecoSiglaConParentesi = [ecoTemp objectAtIndex:0];
        NSArray *ecoArrayApici = [ecoSiglaConParentesi componentsSeparatedByString:@"\""];
        NSString *ecoSiglaSenzaApici = [ecoArrayApici objectAtIndex:1];
        //NSLog(@"%@       %@", ecoSiglaConParentesi, ecoSiglaSenzaApici);
        [ecoSiglaCountedSet addObject:ecoSiglaSenzaApici];
        
        NSMutableArray *ecoTempArray = [[NSMutableArray alloc] init];
        for (NSString *ecoInSigleEcoArray in _singleEcoArray) {
            if ([ecoInSigleEcoArray hasPrefix:ecoSiglaConParentesi]) {
                [ecoTempArray addObject:ecoInSigleEcoArray];
            }
        }
        [ecoSigleDictionary setObject:ecoTempArray forKey:ecoSiglaSenzaApici];
    }
    
    ecoSigle = [[ecoSiglaCountedSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    for (NSString *ecoSigla in [[ecoSiglaCountedSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        //NSLog(@"%@      %d", ecoSigla, [ecoSiglaCountedSet countForObject:ecoSigla]);
    }
    
    
    
    
    
    
    NSMutableSet *openingSet = [[NSMutableSet alloc] init];
    for (NSString *op in _singleEcoArray) {
        NSArray *opArray = [op componentsSeparatedByString:separator];
        [openingSet addObject:[opArray objectAtIndex:0]];
    }
    //ecoArray = [[NSArray arrayWithArray:[openingSet allObjects]] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    
    openingSet = nil;
    
    ecoDictionary = [[NSMutableDictionary alloc] init];
    ecoDictionaryNoDoppie = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    NSMutableArray *linesNonDoppie = [[NSMutableArray alloc] init];
    
    for (NSString *eco in ecoArray) {
        lines = [[NSMutableArray alloc] init];
        linesNonDoppie = [[NSMutableArray alloc] init];
        for (NSString *ecoLine in _singleEcoArray) {
            if ([ecoLine hasPrefix:eco]) {
                [lines addObject:ecoLine];
                if (![linesNonDoppie containsObject:ecoLine]) {
                    //NSLog(@"ECOLINE %@", ecoLine);
                    [linesNonDoppie addObject:ecoLine];
                }
            }
        }
        
        
        //NSLog(@"Devo aggiungere %d linee per ECO %@", lines.count, eco);
        [ecoDictionary setObject:lines forKey:eco];
        //NSLog(@"Devo aggiungere %d linee NO DOPPIE per ECO %@", linesNonDoppie.count, eco);
        [ecoDictionaryNoDoppie setObject:linesNonDoppie forKey:eco];
    }
}*/

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (_delegate) {
        [_delegate aggiornaDopoRotazione];
    }
}

- (void) setEcoSymbol:(NSString *)ecoSymbol {
    if (ecoSymbol) {
        _ecoSymbol = [NSString stringWithFormat:@"[ECO \"%@", ecoSymbol];
    }
}

- (void) setEcoCountedSet:(NSCountedSet *)ecoCountedSet {
    _ecoCountedSet = ecoCountedSet;
    ecoSiglaCountedSet = [[NSCountedSet alloc] init];
    for (NSString *eco in [[_ecoCountedSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        if (_ecoSymbol) {
            if ([eco hasPrefix:_ecoSymbol]) {
                NSString *ecoConSeparator = [eco stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
                NSArray *ecoTemp = [ecoConSeparator componentsSeparatedByString:separator];
                NSString *ecoSiglaConParentesi = [ecoTemp objectAtIndex:0];
                NSArray *ecoArrayApici = [ecoSiglaConParentesi componentsSeparatedByString:@"\""];
                NSString *ecoSiglaSenzaApici = [ecoArrayApici objectAtIndex:1];
                [ecoSiglaCountedSet addObject:ecoSiglaSenzaApici];
                //NSLog(@"%@       %d", eco, [_ecoCountedSet countForObject:eco]);
            }
        }
        else {
            NSString *ecoConSeparator = [eco stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
            NSArray *ecoTemp = [ecoConSeparator componentsSeparatedByString:separator];
            NSString *ecoSiglaConParentesi = [ecoTemp objectAtIndex:0];
            NSArray *ecoArrayApici = [ecoSiglaConParentesi componentsSeparatedByString:@"\""];
            NSString *ecoSiglaSenzaApici = [ecoArrayApici objectAtIndex:1];
            [ecoSiglaCountedSet addObject:ecoSiglaSenzaApici];
        }

    }
    ecoSigle = [[ecoSiglaCountedSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    numGamesForEcoSigla = [[NSMutableDictionary alloc] init];
    ecoSigleDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *ecoSigla in ecoSigle) {
        int numGamesForEco = 0;
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSString *linea in [_ecoCountedSet allObjects]) {
            if ([linea rangeOfString:ecoSigla].length>0) {
                numGamesForEco += [_ecoCountedSet countForObject:linea];
                [tempArray addObject:linea];
            }
        }
        [numGamesForEcoSigla setObject:[NSNumber numberWithInt:numGamesForEco] forKey:ecoSigla];
        [ecoSigleDictionary setObject:tempArray forKey:ecoSigla];
    }
}

#pragma mark - Table view data source


- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView {
    return ecoSigle;
}

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [ecoSigle indexOfObject:title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ecoSigle.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return _singleEcoArray.count;
    
    //NSString *key = [[ecoDictionary allKeys] objectAtIndex:section];
    NSString *eco = [ecoSigle objectAtIndex:section];
    //NSArray *lines = [ecoDictionary objectForKey:key];
    //NSArray *lines = [ecoDictionaryNoDoppie objectForKey:key];
    //NSLog(@"Ho preso la chiave %@ per linee %d", key, lines.count);
    return [ecoSiglaCountedSet countForObject:eco];
}

//- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSString *eco = [ecoSigle objectAtIndex:section];
//    
//    if (_fromSWReveal) {
//        return eco;
//    }
//    
//    NSString *header;
//    NSNumber *numberGames = [numGamesForEcoSigla objectForKey:eco];
//    if (numberGames.intValue == 1) {
//        header = [eco stringByAppendingFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita"), 1];
//    }
//    else {
//        header = [eco stringByAppendingFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), numberGames.intValue];
//    }
//    return header;
//}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor orangeColor];
    label.font = [UIFont fontWithName:@"Verdana-Bold" size:22];
    label.userInteractionEnabled = YES;
    
    
    NSString *eco = [ecoSigle objectAtIndex:section];
    //eco = [[[eco substringToIndex:1] stringByAppendingString:@" "]stringByAppendingString:[eco substringFromIndex:1]];
    
    self.navigationController.navigationBar.barTintColor = [[UtilToView getEcoColor:eco] colorWithAlphaComponent:0.7];
    
    NSMutableString *header = [[NSMutableString alloc] initWithString:@"  "];
    label.backgroundColor = [[UtilToView getEcoColor:eco] colorWithAlphaComponent:0.5];
    [header appendString:eco];
    
    if (_fromSWReveal) {
        label.text = header;
        
        
        return label;
    }
    
    NSNumber *numberGames = [numGamesForEcoSigla objectForKey:eco];
    if (numberGames.intValue == 1) {
        //header = [eco stringByAppendingFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita"), 1];
        [header appendFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita"), 1];
    }
    else {
        //header = [eco stringByAppendingFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), numberGames.intValue];
        [header appendFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), numberGames.intValue];
    }
    //label.backgroundColor = [UtilToView getEcoColor:eco];
    
    
    
    
    
    label.text = header;
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 300, 40)];
    [btn setTag:section];
    [label addSubview:btn];
    [btn addTarget:self action:@selector(sectionTapped:) forControlEvents:UIControlEventTouchDown];
    
    
    return label;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *eco = [ecoSigle objectAtIndex:indexPath.section];
    UIColor *color = [UtilToView getEcoColor:eco];
    [cell setBackgroundColor:[color colorWithAlphaComponent:0.2]];
}

- (void)sectionTapped:(UIButton*)btn {
    return;
    //NSString *ecoSel = [ecoSigle objectAtIndex:btn.tag];
    //NSString *msg = [NSString stringWithFormat:@"A questo punto devo mostrare le informazioni su %@", ecoSel];
    //UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Informazioni" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //[av show];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell SingleEco";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    
    // Configure the cell...
    NSString *eco = [ecoSigle objectAtIndex:indexPath.section];
    NSArray *tempArray = [[ecoSigleDictionary objectForKey:eco] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    //NSArray *lines = [ecoDictionaryNoDoppie objectForKey:key];
    
    //NSString *line = [lines objectAtIndex:indexPath.row];
    //NSArray *lineArray = [line componentsSeparatedByString:separator];
    
    
    NSString *testo = [tempArray objectAtIndex:indexPath.row];
    NSString *testoConSeparatori = [testo stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    NSArray *testoArray = [testoConSeparatori componentsSeparatedByString:separator];
    
    NSMutableString *testoFinale = [[NSMutableString alloc] init];
    
    if (testoArray.count == 1) {
        NSString *tt = [testoArray objectAtIndex:0];
        NSArray *tArray = [tt componentsSeparatedByString:@"\""];
        [testoFinale appendString:[tArray objectAtIndex:1]];
    }
    else {
        for (int i=1; i<testoArray.count; i++) {
            NSString *tt = [testoArray objectAtIndex:i];
            NSArray *tArray = [tt componentsSeparatedByString:@"\""];
            [testoFinale appendString:[tArray objectAtIndex:1]];
            if ((testoArray.count - i) > 1 ) {
                [testoFinale appendString:@", "];
            }
        }
    }
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    
//    NSMutableAttributedString *testoAttributed = [[NSMutableAttributedString alloc] initWithString:testoFinale];
//    NSDictionary *attributoTesto = @{NSFontAttributeName:[UIFont fontWithName:@"Informator-Times-Bold" size:20.0], NSForegroundColorAttributeName : [UIColor blackColor]};
//    [testoAttributed setAttributes:attributoTesto range:NSMakeRange(0, [testoFinale length])];
//    cell.textLabel.attributedText = testoAttributed;
    
    cell.textLabel.text = testoFinale;

    
    
    
    
    NSMutableString *detail = [[NSMutableString alloc] init];
    
    
    NSUInteger n = [_ecoCountedSet countForObject:testo];
    if (n == 1) {
        [detail appendFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita"), n];
    }
    else {
        [detail appendFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), n];
    }
    
    //cell.detailTextLabel.text = detail;
    
    
    
    NSMutableString *opening = [[NSMutableString alloc] init];
    [opening appendString:eco];
    [opening appendString:@" "];
    
    if (testoArray.count == 1) {
        NSString *tt = [testoArray objectAtIndex:0];
        NSArray *tArray = [tt componentsSeparatedByString:@"\""];
        [opening appendString:[tArray objectAtIndex:1]];
    }
    else {
        for (int i=1; i<testoArray.count; i++) {
            NSString *tt = [testoArray objectAtIndex:i];
            NSArray *tArray = [tt componentsSeparatedByString:@"\""];
            [opening appendString:[tArray objectAtIndex:1]];
            if (i==1) {
                [opening appendString:@": "];
            }
            if ((testoArray.count - i) > 1 ) {
                //[chiave appendString:@", "];
            }
        }
    }
    
    if (opening.length<=7) {
        cell.detailTextLabel.text = detail;
    }
    else {
        NSString *line = [opening uppercaseString];
        if ([line hasSuffix:@": "]) {
            line = [line stringByReplacingOccurrencesOfString:@":" withString:@""];
        }
        
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        line = [line stringByReplacingOccurrencesOfString:@"E8G8" withString:@"O-O"];
        line = [line stringByReplacingOccurrencesOfString:@"DEFENCE" withString:@"DEFENSE"];
        
        
        NSUInteger n = [_ecoCountedSet countForObject:testo];
        if (n == 1) {
            [detail appendFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita"), n];
        }
        else {
            [detail appendFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), n];
        }
        
        NSDictionary *attributoMossa = @{NSFontAttributeName:[UIFont fontWithName:@"SemFigBold" size:15.0]};
        NSString *mosse = NSLocalizedString(line, nil);
        ecoAttrText = [[NSMutableAttributedString alloc] initWithString:mosse];
        [ecoAttrText setAttributes:attributoMossa range:NSMakeRange(0, [mosse length])];
        cell.detailTextLabel.attributedText = ecoAttrText;
    }
    
    
    
    cell.detailTextLabel.textColor = [UIColor blueColor];

    //[chiave appendString:testoFinale];
    
    
    if (_fromSWReveal) {
        //[cell setAccessoryType:UITableViewCellAccessoryDetailButton];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCell:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [cell addGestureRecognizer:tapGestureRecognizer];
        
    }
    
    
    
    
    // Configure the cell...
    //NSArray *ecoLine = [[_singleEcoArray objectAtIndex:indexPath.row] componentsSeparatedByString:separator];
    //cell.textLabel.text = [ecoLine objectAtIndex:0];
    //NSMutableString *detail = [[NSMutableString alloc] initWithString:[ecoLine objectAtIndex:1]];
    //[detail appendString:@" "];
    //[detail appendString:[ecoLine objectAtIndex:2]];
    //cell.detailTextLabel.text = detail;
    
    return cell;
}

- (void) setAttributoFor:(NSString *)s :(NSString *)testo :(NSDictionary *)dict {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:s options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:testo options:0 range:NSMakeRange(0, [testo length])];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        //NSLog(@"%@ = %lu  %lu", s, (unsigned long)matchRange.location, (unsigned long)matchRange.length);
        [ecoAttrText setAttributes:dict range:matchRange];
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

- (NSArray *) getGamesForEco:(NSIndexPath *)indexPath {
    NSString *ecoSigla = [ecoSigle objectAtIndex:indexPath.section];
    NSArray *lines = [[ecoSigleDictionary objectForKey:ecoSigla] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *line = [lines objectAtIndex:indexPath.row];
    line = [line stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    NSArray *opvar = [line componentsSeparatedByString:separator];
    
    return [_pgnFileDoc.pgnFileInfo findGamesByEcoOpening:opvar];
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
    
    if (_fromSWReveal) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //UIAlertView *testAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Non posso andare avanti" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[testAlertView show];
        //[self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
        return;
    }
    
    //NSString *partite = [self getGamesForEco:indexPath];
    //NSLog(@"PARTITE = %@", partite);
    //return;
    
    
    NSString *ecoSigla = [ecoSigle objectAtIndex:indexPath.section];
        
    //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    UIStoryboard *sb = [UtilToView getStoryBoard];
    GamesTableViewController *gtvc = [sb instantiateViewControllerWithIdentifier:@"GamesTableViewController"];
    [gtvc setDelegate:self];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    //hud.detailsLabelText = title;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        //NSArray *gamesFound = [_pgnFileDoc.pgnFileInfo findGamesByTagValues:parametro];
        //NSArray *gamesFound = [_pgnFileDoc.pgnFileInfo findGamesByEcoOpening:opvar];
        //NSLog(@"Numero partite trovate = %d", gamesFound.count);
        NSArray *gamesFound = [self getGamesForEco:indexPath];
        [gtvc setGames:gamesFound.mutableCopy];
        [gtvc setPlayerName:ecoSigla];
        [gtvc setPgnFileDoc:_pgnFileDoc];
        [self.navigationController pushViewController:gtvc animated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        partiteSelezionateDaCopiareEliminare = [tableView indexPathsForSelectedRows];
    }
}

- (void) tappedCell:(UITapGestureRecognizer *) gestureRecognizer {
    UITableViewCell *cell = (UITableViewCell *)[gestureRecognizer view];
    
    CGPoint tapPoint = [gestureRecognizer locationInView:cell];
    CGPoint tapPointInView = [cell convertPoint:tapPoint toView:self.view];
    
    CGRect rect;
    
    
    //In questa view la pubblicità è stata disabilitata perchè non permetteva la visualizzazione dell'anteprima. Si dovrebbe indagare meglio su questo problema.
    if (IsChessStudioLight) {
        rect = CGRectMake(tapPointInView.x, tapPointInView.y, 10.0, 10.0);
    }
    else {
        rect = CGRectMake(tapPointInView.x, tapPointInView.y, 10.0, 10.0);
    }
    NSString *game = [[cell detailTextLabel] text];
    PGNGame *previewPgnGame = [[PGNGame alloc] initWithPgn:game];
    NSString *g = [previewPgnGame getGameForCopy];
    
    
    NSString *ecoSigla = [ecoSigle objectAtIndex:[self.tableView indexPathForCell:cell].section];
    
    if ((IS_PAD) || (IS_PAD_PRO)) {
        EcoBoardPreviewTableViewController *gbptvc = [[EcoBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //[gbptvc setPgnFileDoc:_pgnFileDoc];
        //[gbptvc setNumGame:indexPath.row];
        
        
        [gbptvc setEco:ecoSigla];
        [gbptvc setOpening:cell.textLabel.text];
        [gbptvc setOpeningMoves:cell.detailTextLabel.attributedText];
        [gbptvc setGame:g];
        gamePreviewPopoverController = [[UIPopoverController alloc] initWithContentViewController:gbptvc];
        [gamePreviewPopoverController presentPopoverFromRect:rect inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        EcoBoardPreviewTableViewController *gbptvc = [[EcoBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:gbptvc];
        //[gbptvc setPgnFileDoc:_pgnFileDoc];
        //[gbptvc setNumGame:indexPath.row];
        [gbptvc setEco:ecoSigla];
        [gbptvc setOpening:cell.textLabel.text];
        [gbptvc setOpeningMoves:cell.detailTextLabel.attributedText];
        [gbptvc setGame:g];
        //gbptvc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        //gbptvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        //[self presentViewController:navController animated:YES completion:^{
        //}];
        [self.navigationController pushViewController:gbptvc animated:YES];
        //[self.navigationController presentViewController:gbptvc animated:YES completion:nil];
        //[self.navigationController pushViewController:gbptvc animated:YES];
        return;
    }
    
}

#pragma mark - GamesTableViewController delegate

- (void) aggiorna {
    [self.tableView reloadData];
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
    //copyActionSheetMenu.tag = 100;
    
    copyActionSheetMenu = [[UIActionSheet alloc] init];
    copyActionSheetMenu.tag = 100;
    copyActionSheetMenu.delegate = self;
    
    [copyActionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_COPY_GAMES", nil)];
    [copyActionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_DELETE_GAMES", nil)];
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
                    [copyArray addObjectsFromArray:[self getGamesForEco:indexPath]];
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
                    [gamesToDelete addObjectsFromArray:[self getGamesForEco:indexPath]];
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
            _ecoCountedSet = [_pgnFileDoc.pgnFileInfo getAllEcoByCountedSet];
            [self setEcoCountedSet:_ecoCountedSet];
            [self.tableView deleteRowsAtIndexPaths:partiteSelezionateDaCopiareEliminare withRowAnimation:UITableViewRowAnimationFade];
            //[_pgnFileDoc.pgnFileInfo salvaTutteLePartite];
            [self.tableView reloadData];
            [_delegate aggiorna];
        }
    }
}



- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    //NSString *game = [allGamesAndAllTags objectAtIndex:indexPath.row];
    
    NSString *game = [[[tableView cellForRowAtIndexPath:indexPath] detailTextLabel] text];
    
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
    
    if (IS_PAD) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        EcoBoardPreviewTableViewController *gbptvc = [[EcoBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //[gbptvc setPgnFileDoc:_pgnFileDoc];
        //[gbptvc setNumGame:indexPath.row];
        [gbptvc setGame:g];
        gamePreviewPopoverController = [[UIPopoverController alloc] initWithContentViewController:gbptvc];
        [gamePreviewPopoverController presentPopoverFromRect:CGRectMake((cell.frame.size.width-60), cell.frame.origin.y  , cell.frame.size.width, cell.frame.size.height) inView:tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        EcoBoardPreviewTableViewController *gbptvc = [[EcoBoardPreviewTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //[gbptvc setPgnFileDoc:_pgnFileDoc];
        //[gbptvc setNumGame:indexPath.row];
        [gbptvc setGame:g];
        gbptvc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [self.navigationController presentViewController:gbptvc animated:YES completion:nil];
        //[self.navigationController pushViewController:gbptvc animated:YES];
        return;
        
        
//        [UIView transitionFromView:self.tableView
//                            toView:gbptvc.tableView
//                          duration:0.5
//                           options:UIViewAnimationOptionTransitionCurlUp
//                        completion:^(BOOL finished) {
//                            // Do something... or not...
//                        }];
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


@end
