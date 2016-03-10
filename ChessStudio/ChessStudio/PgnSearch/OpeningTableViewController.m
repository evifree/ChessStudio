//
//  OpeningTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "OpeningTableViewController.h"
#import "GamesTableViewController.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "GamePreviewTableViewController.h"

@interface OpeningTableViewController () {
    //NSArray *openingArray;
    //NSArray *ecoArray;
    //NSMutableDictionary *ecoDictionary;
    //NSMutableDictionary *ecoDictionaryNoDoppie;
    
    
    NSDictionary *allEcoByDictionary;
    NSArray *sortedEcoArray;
    NSMutableArray *ecoArrayWithSeparator;
    NSArray *ecoStringSortedArray;
    NSMutableDictionary *ecoStringArrayDictionary;
    NSArray *ecoStringFromEcoSet;
    NSMutableArray *ecoForIndex;
    
    NSCountedSet *ecoCountedSet;
    
    NSString *pattern;
    NSRegularExpression *regex;
    
    
    NSMutableDictionary *ecoGameArrayDictionary;
}

@end

@implementation OpeningTableViewController

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
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (IS_PHONE) {
        
        
        UIView *titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 190, 28)];
        label1.font = [UIFont boldSystemFontOfSize:17.0];
        label1.textColor = [UIColor whiteColor];
        label1.text = [NSString stringWithFormat:NSLocalizedString(@"OPENING_TABLE_VIEW_CONTROLLER_TITLE", nil), @""];
        label1.backgroundColor = [UIColor clearColor];
        label1.textAlignment = NSTextAlignmentCenter;
        [titoloView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 190, 16)];
        label2.font = [UIFont boldSystemFontOfSize:17.0];
        label2.text = _pgnFileDoc.pgnFileInfo.fileName;
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = [UIColor whiteColor];
        label2.textAlignment = NSTextAlignmentCenter;
        [titoloView addSubview:label2];
        self.navigationItem.titleView = titoloView;
    }
    else {
        NSString *titolo = [NSString stringWithFormat:NSLocalizedString(@"OPENING_TABLE_VIEW_CONTROLLER_TITLE", nil), _pgnFileDoc.pgnFileInfo.fileName];
        self.navigationItem.title = titolo;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Memory warning from OpeningTableViewController");
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (IS_PHONE) {
        return NO;
    }
    if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        return YES;
    }
    return NO;
}

- (void) setPgnFileDoc:(PgnFileDocument *)pgnFileDoc {
    _pgnFileDoc = pgnFileDoc;
    
    //ecoArrayWithSeparator = [[NSMutableArray alloc] init];
    allEcoByDictionary = [_pgnFileDoc.pgnFileInfo getAllEcoByDictionary];
    sortedEcoArray = [[allEcoByDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

    
    /*
    ecoCountedSet = [_pgnFileDoc.pgnFileInfo getAllEcoByCountedSet];
    
    
    NSMutableSet *ecoStringSet = [[NSMutableSet alloc] init];
    for (NSString *key in sortedEcoArray) {
        NSString *ecoString = [key substringWithRange:NSMakeRange(0, 11)];
        //NSLog(@"ECO STRING = %@", ecoString);
        [ecoStringSet addObject:ecoString];
    }

    ecoStringFromEcoSet = [[ecoStringSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    ecoStringArrayDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *ecoString in ecoStringSet.allObjects) {
        NSMutableArray *lineeForEco = [[NSMutableArray alloc] init];
        for (NSString *key in allEcoByDictionary) {
            if ([key hasPrefix:ecoString]) {
                [lineeForEco addObject:key];
            }
        }
        [ecoStringArrayDictionary setObject:lineeForEco forKey:ecoString];
    }
    
    ecoStringSortedArray = [ecoStringArrayDictionary.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    ecoForIndex = [[NSMutableArray alloc] init];
    for (NSString *eco in ecoStringFromEcoSet) {
        NSArray *ecoNoApici = [eco componentsSeparatedByString:@"\""];
        [ecoForIndex addObject:[ecoNoApici objectAtIndex:1]];
    }
    
    
    
    
    //for (NSString *ecoString in ecoStringSortedArray) {
    //    NSArray *lineeForEco = [ecoStringArrayDictionary objectForKey:ecoString];
        //NSLog(@"%@            %d", ecoString, lineeForEco.count);
    //    for (NSString *line in lineeForEco) {
    //        NSNumber *numpartite = [allEcoByDictionary objectForKey:line];
            //NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>    %@               %d", line, numpartite.intValue);
    //    }
    //}
    
    //openingArray = [[_pgnFileDoc.pgnFileInfo getAllEco] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    
    //for (NSString *open in openingArray) {
    //    NSLog(@"%@", open);
    //}
    
    //NSLog(@"Ho contato %d partite utili", openingArray.count);
    
    
    //NSMutableSet *openingSet = [[NSMutableSet alloc] init];
    
    //for (NSString *op in openingArray) {
    //    NSArray *opArray = [op componentsSeparatedByString:separator];
    //    [openingSet addObject:[opArray objectAtIndex:0]];
    //}
    
    
    //ecoArray = [[NSArray arrayWithArray:[openingSet allObjects]] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    //openingSet = nil;
    
    //for (NSString *o in ecoArray) {
    //    NSLog(@"In EcoArray  %@", o);
    //}
    
    //for (NSString *o in openingArray) {
        //NSLog(@"In openingArray  %@", o);
    //}
    
    
    //ecoArray contiene tutti gli ECO non ripetuti e ordinati
    //opening array contiene tutti i valori delle aperture con |
    
    
    //ecoDictionary = [[NSMutableDictionary alloc] init];
    //ecoDictionaryNoDoppie = [[NSMutableDictionary alloc] init];
    
    //NSMutableArray *aperture = [[NSMutableArray alloc] init];
    //NSMutableArray *apertureNoDoppie = [[NSMutableArray alloc] init];
    
    //for (NSString *eco in ecoArray) {
    //    for (NSString *ecoLine in openingArray) {
    //        if ([ecoLine hasPrefix:eco]) {
    //            [aperture addObject:ecoLine];
    //            if (![apertureNoDoppie containsObject:ecoLine]) {
    //                [apertureNoDoppie addObject:ecoLine];
    //            }
    //        }
    //    }
    //    [ecoDictionary setObject:aperture forKey:eco];
    //    [ecoDictionaryNoDoppie setObject:apertureNoDoppie forKey:eco];
    //    aperture = [[NSMutableArray alloc] init];
    //    apertureNoDoppie = [[NSMutableArray alloc] init];
    //}
    */
    /*
    for (NSString *eco in ecoArray) {
        NSArray *linee = [ecoDictionary objectForKey:eco];
        for (NSString *ll in linee) {
            NSLog(@"In EcoDictionary  %@     %@", eco, ll);
        }
        
    }
    
    for (NSString *eco in ecoArray) {
        NSArray *lineeNodoppie = [ecoDictionaryNoDoppie objectForKey:eco];
        for (NSString *ll in lineeNodoppie) {
            NSLog(@"In EcoDictionaryNoDoppie  %@     %@", eco, ll);
        }
    }
    */
    
    //int numeroTotale = 0;
    
    //for (NSString *eco in ecoArray) {
    //    NSArray *linee = [ecoDictionary objectForKey:eco];
    //    NSArray *lineeNoDoppie = [ecoDictionaryNoDoppie objectForKey:eco];
    //    NSLog(@"Per %@ ci sono %d in ecodictionary e %d in ecodictionaryNoDoppie", eco, linee.count, lineeNoDoppie.count);
        //numeroTotale += linee.count;
    //}
    
    //return;
    
    
    
    //NSMutableArray *lines = [[NSMutableArray alloc] init];
    //NSMutableArray *linesNonDoppie = [[NSMutableArray alloc] init];
    

    
    
    //for (NSString *eco in ecoArray) {
    //    lines = [[NSMutableArray alloc] init];
    //    linesNonDoppie = [[NSMutableArray alloc] init];
    //    for (NSString *ecoLine in openingArray) {
    //        if ([ecoLine hasPrefix:eco]) {
    //            [lines addObject:ecoLine];
    //            if (![linesNonDoppie containsObject:ecoLine]) {
                    //NSLog(@"ECOLINE %@", ecoLine);
    //                [linesNonDoppie addObject:ecoLine];
    //            }
    //        }
    //    }
        
        
        //NSLog(@"Devo aggiungere %d linee per ECO %@", lines.count, eco);
    //    [ecoDictionary setObject:lines forKey:eco];
        //NSLog(@"Devo aggiungere %d linee NO DOPPIE per ECO %@", linesNonDoppie.count, eco);
    //    [ecoDictionaryNoDoppie setObject:linesNonDoppie forKey:eco];
    //}
    
    ecoGameArrayDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *eco in sortedEcoArray) {
        NSMutableString *parametro = [[NSMutableString alloc] init];
        NSString *lineaScelta = eco;
        lineaScelta = [lineaScelta stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
        lineaScelta = [lineaScelta stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
        [parametro appendString:lineaScelta];
        
        [parametro replaceOccurrencesOfString:@"(" withString:@"\\(" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [lineaScelta length])];
        [parametro replaceOccurrencesOfString:@")" withString:@"\\)" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [lineaScelta length])];
        
        NSRange range = [lineaScelta rangeOfString:@"Opening"];
        if (range.length == 0) {
            [parametro appendString:@"(?!\\[Opening)"];
        }
        
        range = [lineaScelta rangeOfString:@"Variation"];
        if (range.length == 0) {
            [parametro appendString:@"(?!\\[Variation)"];
        }
        
        range = [lineaScelta rangeOfString:@"Subvariation"];
        if (range.length == 0) {
            [parametro appendString:@"(?!\\[Subvariation)"];
        }
        NSArray *gamesFound = [_pgnFileDoc.pgnFileInfo findGamesByTagValues:parametro];
        [ecoGameArrayDictionary setObject:gamesFound forKey:eco];
    }
}


#pragma mark - Table view data source

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView {
    return ecoForIndex;
}

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [ecoForIndex indexOfObject:title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sortedEcoArray.count;
    //return ecoStringFromEcoSet.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray *games = [ecoGameArrayDictionary objectForKey:[sortedEcoArray objectAtIndex:section]];
    return games.count;
    
    
    NSString *key = [ecoStringFromEcoSet objectAtIndex:section];
    NSArray *lineeForEco = [ecoStringArrayDictionary objectForKey:key];
    
    int numPartiteForEco = 0;
    for (NSString *line in lineeForEco) {
        NSNumber *numpartite = [allEcoByDictionary objectForKey:line];
        numPartiteForEco += numpartite.intValue;
    }
    
    if (section == 0) {
        NSLog(@"section 0 righe = %d", numPartiteForEco);
    }
    
    return numPartiteForEco;
    //return lineeForEco.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {    
    NSString *key = [ecoStringFromEcoSet objectAtIndex:section];
    NSArray *lineeForEco = [ecoStringArrayDictionary objectForKey:key];
    
    int numPartiteForEco = 0;
    for (NSString *line in lineeForEco) {
        NSNumber *numpartite = [allEcoByDictionary objectForKey:line];
        numPartiteForEco += numpartite.intValue;
    }
    
    NSArray *keyArray = [key componentsSeparatedByString:@"\""];
    
    NSString *finalKey = [keyArray objectAtIndex:1];
    
    
    NSMutableString *title = [[NSMutableString alloc] initWithString:finalKey];
    [title appendString:@" "];
    if (numPartiteForEco == 1) {
        [title appendFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita"), numPartiteForEco];
    }
    else {
        [title appendFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), numPartiteForEco];
    }
    return title;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor orangeColor];
    label.font = [UIFont fontWithName:@"Verdana-Bold" size:17];
    label.adjustsFontSizeToFitWidth = YES;
    
    NSMutableString *titolo = [[NSMutableString alloc] initWithString:@"  "];
    NSString *eco = [sortedEcoArray objectAtIndex:section];
    NSString *ecoKey = [[eco componentsSeparatedByString:@"\""] objectAtIndex:1];
    eco = [eco stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    NSArray *ecoArray = [eco componentsSeparatedByString:separator];
    NSString *ecoComp1;
    for (NSString *ecoComp in ecoArray) {
        NSArray *array = [ecoComp componentsSeparatedByString:@"\""];
        //NSString *ecoComp1 = [ecoComp stringByReplacingOccurrencesOfString:@"[" withString:@""];
        //ecoComp1 = [ecoComp1 stringByReplacingOccurrencesOfString:@"]" withString:@""];
        //ecoComp1 = [ecoComp1 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        //ecoComp1 = [ecoComp1 stringByReplacingOccurrencesOfString:@"ECO " withString:@""];
        ecoComp1 = [array objectAtIndex:1];
        [titolo appendString:ecoComp1];
        if ([ecoArray indexOfObject:ecoComp] < ecoArray.count - 1) {
            [titolo appendString:@" - "];
        }
    
    }
    NSString *titoloFinale = titolo;
    //titoloFinale = [titoloFinale stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    label.text = titoloFinale;
    
    if ([ecoKey hasPrefix:@"A"]) {
        //label.backgroundColor = [UIColor greenColor];
        label.backgroundColor = UIColorFromRGB(0xD3E0A8);
    }
    else if ([ecoKey hasPrefix:@"B"]) {
        //label.backgroundColor = [UIColor yellowColor];
        label.backgroundColor = UIColorFromRGB(0xFDFCAC);
    }
    else if ([ecoKey hasPrefix:@"C"]) {
        //label.backgroundColor = [UIColor cyanColor];
        label.backgroundColor = UIColorFromRGB(0xC4E2EC);
    }
    else if ([ecoKey hasPrefix:@"D"]) {
        //label.backgroundColor = [UIColor redColor];
        label.backgroundColor = UIColorFromRGB(0xE9BFC0);
    }
    else {
        //label.backgroundColor = [UIColor orangeColor];
        label.backgroundColor = UIColorFromRGB(0xE9DBAA);
    }
    
    
    return label;
    
    /*
    NSString *key = [ecoStringFromEcoSet objectAtIndex:section];
    NSArray *lineeForEco = [ecoStringArrayDictionary objectForKey:key];
    
    int numPartiteForEco = 0;
    for (NSString *line in lineeForEco) {
        NSNumber *numpartite = [allEcoByDictionary objectForKey:line];
        numPartiteForEco += numpartite.intValue;
    }
    
    NSArray *keyArray = [key componentsSeparatedByString:@"\""];
    
    NSString *finalKey = [keyArray objectAtIndex:1];
    
    
    NSMutableString *title = [[NSMutableString alloc] initWithString:@"  "];
    [title appendString:finalKey];
    [title appendString:@" "];
    if (numPartiteForEco == 1) {
        [title appendFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita"), numPartiteForEco];
    }
    else {
        [title appendFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), numPartiteForEco];
    }
    
    if ([finalKey hasPrefix:@"A"]) {
        //label.backgroundColor = [UIColor greenColor];
        label.backgroundColor = UIColorFromRGB(0xD3E0A8);
    }
    else if ([finalKey hasPrefix:@"B"]) {
        //label.backgroundColor = [UIColor yellowColor];
        label.backgroundColor = UIColorFromRGB(0xFDFCAC);
    }
    else if ([finalKey hasPrefix:@"C"]) {
        //label.backgroundColor = [UIColor cyanColor];
        label.backgroundColor = UIColorFromRGB(0xC4E2EC);
    }
    else if ([finalKey hasPrefix:@"D"]) {
        //label.backgroundColor = [UIColor redColor];
        label.backgroundColor = UIColorFromRGB(0xE9BFC0);
    }
    else {
        //label.backgroundColor = [UIColor orangeColor];
        label.backgroundColor = UIColorFromRGB(0xE9DBAA);
    }
    

    label.text = title;
    
    return label;
     */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Opening";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    NSString *key = [sortedEcoArray objectAtIndex:indexPath.section];
    NSArray *games = [ecoGameArrayDictionary objectForKey:key];
    NSString *testo = [games objectAtIndex:indexPath.row];
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
    cell.textLabel.text = testoFinale;
    
    
    return cell;
    
    /*
    NSString *key = [ecoStringFromEcoSet objectAtIndex:indexPath.section];
    NSArray *lineeForEco = [[ecoStringArrayDictionary objectForKey:key] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSString *lineEco = [lineeForEco objectAtIndex:indexPath.row];
    NSString *testo;
    if (lineEco.length > 11) {
        testo = [lineEco substringFromIndex:11];
    }
    else {
        testo = lineEco;
    }
    
    testo = [testo stringByReplacingOccurrencesOfString:@"][" withString:replaceSeparator];
    NSArray *testoArray = [testo componentsSeparatedByString:separator];
    
    NSMutableString *testoFinale = [[NSMutableString alloc] init];
    
    for (int i=0; i<testoArray.count; i++) {
        NSString *tt = [testoArray objectAtIndex:i];
        NSArray *tArray = [tt componentsSeparatedByString:@"\""];
        [testoFinale appendString:[tArray objectAtIndex:1]];
        if ((testoArray.count - i) > 1 ) {
            [testoFinale appendString:@", "];
        }
    }
    
    cell.textLabel.text = testoFinale;
    
    NSNumber *numpartite = [allEcoByDictionary objectForKey:lineEco];
    
    NSMutableString *detail = [[NSMutableString alloc] init];
    int np = numpartite.intValue;
    
    if (np == 1) {
        [detail appendFormat:NSLocalizedString(@"NUM_GAMES_SINGOLAR", @"1 partita")];
    }
    else {
        [detail appendFormat:NSLocalizedString(@"NUM_GAMES_PLURAL", @"n partite"), np];
    }
    
    cell.detailTextLabel.text = detail;
    */
    
    NSString *game = [self getGamesForEco:indexPath];
    
    NSArray *matches = [regex matchesInString:game options:0 range:NSMakeRange(0, [game length])];
    
    NSMutableArray *dati = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *cr in matches) {
        //NSString *s0 = [game substringWithRange:cr.range];
        //NSLog(@"%@", s0);
        
        NSString *s = [[[game substringWithRange:cr.range] componentsSeparatedByString:@"\""] objectAtIndex:1];
        //NSLog(@"%@", s);
        [dati addObject:s];
    }
    
    
    cell.textLabel.text = [[[dati objectAtIndex:2] stringByAppendingString:@" - "] stringByAppendingString:[dati objectAtIndex:3]];
    
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
    
    cell.detailTextLabel.text = detail;
    
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
    
    //NSString *key = [ecoArray objectAtIndex:indexPath.section];
    ///NSArray *lines = [ecoDictionaryNoDoppie objectForKey:key];
    //NSString *line = [lines objectAtIndex:indexPath.row];
    //NSArray *opvar = [line componentsSeparatedByString:separator];
    
    //NSLog(@"LINE = %@", line);
    
    //NSString *gameSel = [self getGamesForEco:indexPath];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    GamePreviewTableViewController *gptvc = [sb instantiateViewControllerWithIdentifier:@"GamePreviewTable"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    //hud.detailsLabelText = title;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        //NSString *moves = [_pgnFileDoc.pgnFileInfo findGameMovesByTagPairs:gameSel];
        //[gptvc setGame:gameSel];
        //[gptvc setMoves:moves];
        [gptvc setPgnFileDoc:_pgnFileDoc];
        [self.navigationController pushViewController:gptvc animated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
    
    
    return;
    
    NSMutableString *parametro = [[NSMutableString alloc] init];
    
    NSString *key = [ecoStringFromEcoSet objectAtIndex:indexPath.section];
    
    //NSLog(@"%@", key);
    
    NSArray *linee = [[ecoStringArrayDictionary objectForKey:key] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSString *lineaScelta = [linee objectAtIndex:indexPath.row];
    
    //NSLog(@"LINEA SCELTA-0: %@", lineaScelta);
    
    lineaScelta = [lineaScelta stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
    lineaScelta = [lineaScelta stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
    
    [parametro appendString:lineaScelta];
    
    //NSLog(@"LINEA SCELTA-1: %@", lineaScelta);
    
    
    [parametro replaceOccurrencesOfString:@"(" withString:@"\\(" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [lineaScelta length])];
    [parametro replaceOccurrencesOfString:@")" withString:@"\\)" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [lineaScelta length])];
    
    NSRange range = [lineaScelta rangeOfString:@"Opening"];
    if (range.length == 0) {
        NSLog(@"Devo Aggiungere Opening");
        [parametro appendString:@"(?!\\[Opening)"];
    }
    
    range = [lineaScelta rangeOfString:@"Variation"];
    if (range.length == 0) {
        NSLog(@"Devo Aggiungere Variation");
        [parametro appendString:@"(?!\\[Variation)"];
    }
    
    range = [lineaScelta rangeOfString:@"Subvariation"];
    if (range.length == 0) {
        NSLog(@"Devo Aggiungere Subvariation");
        [parametro appendString:@"(?!\\[Subvariation)"];
    }

    //NSLog(@"PARAMETRO = %@", parametro);
    
    /*
    NSMutableString *eco = [[NSMutableString alloc] initWithString:@"\\[ECO \""];
    [eco appendString:key];
    [eco appendString:@"\"\\]"];
    
    [parametro appendString:eco];
    
    NSMutableString *opening;
    NSMutableString *variation;
    NSMutableString *subvariation;
    
    
    if ((opvar.count == 2) && [key isEqualToString:[opvar objectAtIndex:1]]) {        
        [parametro appendString:@"(?!\\[Opening)(?!\\[Variation)(?!\\[Subvariation)"];
    }
    else {
        
        if (opvar.count > 1 && [opvar objectAtIndex:1]) {
            opening = [[NSMutableString alloc] initWithString:@"\\[Opening \""];
            NSString *openingValue = [[opvar objectAtIndex:1] stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
            openingValue = [openingValue stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
            [opening appendString:openingValue];
            [opening appendString:@"\"\\]"];
        }
        else {
            opening = [[NSMutableString alloc] initWithString:@"(?!\\[Opening)"];
        }
        
        if (opvar.count > 2 && [opvar objectAtIndex:2]) {
            variation = [[NSMutableString alloc] initWithString:@"\\[Variation \""];
            NSString *varValue = [[opvar objectAtIndex:2]stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
            varValue = [varValue stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
            [variation appendString:varValue];
            [variation appendString:@"\"\\]"];
        }
        else {
            variation = [[NSMutableString alloc] initWithString:@"(?!\\[Variation)"];
        }
        
        if (opvar.count > 3 && [opvar objectAtIndex:3]) {
            subvariation = [[NSMutableString alloc] initWithString:@"\\[Subvariation \""];
            NSString *subVarValue = [[opvar objectAtIndex:3] stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
            subVarValue = [subVarValue stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
            [subvariation appendString:subVarValue];
            [subvariation appendString:@"\"\\]"];
        }
        else {
            subvariation = [[NSMutableString alloc] initWithString:@"(?!\\[Subvariation)"];
        }
        
        [parametro appendString:opening];
        [parametro appendString:variation];
        [parametro appendString:subvariation];
        
    }
    */
    //NSString *msg = [[[[eco stringByAppendingString:@" - "] stringByAppendingString:opening] stringByAppendingString:@" - "] stringByAppendingString:var];
    
    //NSLog(@"Devo Cercare %@", parametro);
    
    //UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Selected var" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
    //[av show];
    //NSMutableArray *tagArray = [[NSMutableArray alloc] init];
    //[tagArray addObject:eco];
    //[tagArray addObject:opening];
    //[tagArray addObject:var];
    
    //NSArray *gamesFound = [_pgnFileDoc.pgnFileInfo findGamesByTagValues:parametro];
    //NSLog(@"Ho trovato %d partite", gamesFound.count);
    
    
    
    
    /*
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    GamesTableViewController *gtvc = [sb instantiateViewControllerWithIdentifier:@"GamesTableViewController"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    //hud.detailsLabelText = title;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        NSArray *gamesFound = [_pgnFileDoc.pgnFileInfo findGamesByTagValues:parametro];
        [gtvc setGames:gamesFound];
        [gtvc setPgnFileDoc:_pgnFileDoc];
        [self.navigationController pushViewController:gtvc animated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    */
}

- (NSString *) getGamesForEco:(NSIndexPath *)indexPath {
    NSMutableString *parametro = [[NSMutableString alloc] init];
    NSString *key = [ecoStringFromEcoSet objectAtIndex:indexPath.section];
    NSArray *linee = [[ecoStringArrayDictionary objectForKey:key] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSString *lineaScelta = [linee objectAtIndex:0];
    lineaScelta = [lineaScelta stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
    lineaScelta = [lineaScelta stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
    [parametro appendString:lineaScelta];
    
    [parametro replaceOccurrencesOfString:@"(" withString:@"\\(" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [lineaScelta length])];
    [parametro replaceOccurrencesOfString:@")" withString:@"\\)" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [lineaScelta length])];
    
    
    key = [key stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
    key = [key stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
    parametro = [[NSMutableString alloc] initWithString:key];
    
    NSRange range = [lineaScelta rangeOfString:@"Opening"];
    if (range.length == 0) {
        //[parametro appendString:@"(?!\\[Opening)"];
    }
    
    range = [lineaScelta rangeOfString:@"Variation"];
    if (range.length == 0) {
        //[parametro appendString:@"(?!\\[Variation)"];
    }
    
    range = [lineaScelta rangeOfString:@"Subvariation"];
    if (range.length == 0) {
        //[parametro appendString:@"(?!\\[Subvariation)"];
    }
    
    //NSLog(@"%@", parametro);
    
    NSArray *gamesFound = [_pgnFileDoc.pgnFileInfo findGamesByTagValues:parametro];
    //NSLog(@"Games found = %d", gamesFound.count);
    
    return [gamesFound objectAtIndex:indexPath.row];
}

@end
