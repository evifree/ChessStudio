//
//  PgnMentorOpeningsTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 28/11/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "PgnMentorOpeningsTableViewController.h"
#import "ZipArchive.h"

@interface PgnMentorOpeningsTableViewController () {

    UIAlertView *downloadAlertView;
    NSURLConnection *connection;
    
    NSArray *tableArray;
    
    NSMutableArray *listAperturePgn;
    NSMutableArray *listMosseApertura;
    NSMutableArray *listLinkAperture;
    
    
    NSInteger totalDownloaded;
    NSMutableData *totalData;
    NSInteger downloadSize;
    
    NSString *fileToDownload;
    NSString *linkFile;
    
    NSDictionary *attributoMossa;
    CGFloat fontSize;
}

@end

#define MENTOR @"http://www.pgnmentor.com/"

@implementation PgnMentorOpeningsTableViewController

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
    
    self.navigationItem.title = NSLocalizedString(@"PGN_MENTOR_OPENINGS", nil);
    
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0XF5F5F5);
    
    if (IS_PAD) {
        attributoMossa = @{NSFontAttributeName:[UIFont fontWithName:@"SemFigBold" size:15.0]};
        fontSize = 20.0;
    }
    else if (IS_IPHONE_4_OR_LESS) {
        attributoMossa = @{NSFontAttributeName:[UIFont fontWithName:@"SemFigBold" size:11.0]};
        fontSize = 13.0;
    }
    else if (IS_IPHONE_5) {
        attributoMossa = @{NSFontAttributeName:[UIFont fontWithName:@"SemFigBold" size:11.0]};
        fontSize = 13.0;
    }
    else if (IS_IPHONE_6) {
        attributoMossa = @{NSFontAttributeName:[UIFont fontWithName:@"SemFigBold" size:13.0]};
        fontSize = 15.0;
    }
    else if (IS_IPHONE_6P) {
        attributoMossa = @{NSFontAttributeName:[UIFont fontWithName:@"SemFigBold" size:14.0]};
        fontSize = 16.0;
    }
    
    
    [self loadOpenings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Metodi per caricare i dati da PGN Mentor

- (void) loadOpenings {
    
    listAperturePgn = [[NSMutableArray alloc] init];
    listMosseApertura = [[NSMutableArray alloc] init];
    listLinkAperture = [[NSMutableArray alloc] init];
    
    HTMLSelector *selector = [HTMLSelector selectorForString:@"table"];
    tableArray = [_htmlDocument nodesMatchingParsedSelector:selector];
    
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
                        //NSLog(@"%@", [[e attributes] objectForKey:@"alt"]);
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
                        //NSLog(@"%@", [t textContent]);
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listAperturePgn.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //cell.backgroundColor = UIColorFromRGB(0XF5F5F5);
    
    if ((indexPath.row % 2) == 0) {
        UIColor *oddRowColor = [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0];
        [cell setBackgroundColor: oddRowColor];
    }
    else {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Pgn Openings";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    
    NSString *mosse = [listMosseApertura objectAtIndex:indexPath.row];
    NSMutableAttributedString *ecoAttrText = [[NSMutableAttributedString alloc] initWithString:mosse];
    [ecoAttrText setAttributes:attributoMossa range:NSMakeRange(0, [mosse length])];
    
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [listAperturePgn objectAtIndex:indexPath.row];
    //cell.detailTextLabel.text = [listMosseApertura objectAtIndex:indexPath.row];
    cell.detailTextLabel.attributedText = ecoAttrText;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.textColor = [UIColor blueColor];
    
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSString *dato = [listPlayers objectAtIndex:indexPath.row];
    //NSString *dato2 = [listPlayersPgn objectAtIndex:indexPath.row];
    fileToDownload = [listAperturePgn objectAtIndex:indexPath.row];
    linkFile = [listLinkAperture objectAtIndex:indexPath.row];
    
    //NSLog(@"%@      %@", fileToDownload, linkFile);
    
    NSURL *url = [NSURL URLWithString:linkFile];
    NSURLRequest *fileRequest = [NSURLRequest requestWithURL:url];
    
    totalDownloaded = 0;
    totalData = [[NSMutableData alloc] init];
    connection = [NSURLConnection connectionWithRequest:fileRequest delegate:self];
    
    downloadAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"DATABASE_DOWNLOADING_IOS7", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:nil, nil];
    downloadAlertView.tag = 100;
    [downloadAlertView show];
    
    [connection start];
}


#pragma mark - Implementazione delegati download

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
    if (statusCode == 404) {
        NSLog(@"Database non disponibile");
        return;
    }
    NSString *contentLengthString = [[httpResponse allHeaderFields] objectForKey:@"Content-length"];
    downloadSize = [contentLengthString integerValue];
    //NSLog(@"Download size = %d", downloadSize);
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    totalDownloaded += [data length];
    //NSLog(@"Ricevuto dati %d", totalDownloaded);
    [totalData appendData:data];
    
    //float percentByteDownloaded = 1.*totalDownloaded/downloadSize;
    //float percentByteDownloaded = 100.0*totalDownloaded/downloadSize;
    //NSLog(@"Percentuale scaricata = %f", percentByteDownloaded*100);
    //[progressView setProgress:percentByteDownloaded];
    
    //NSNumber *twicSizeNumber = [NSNumber numberWithFloat:percentByteDownloaded];
    //NSString *twicSizeString = [NSString stringWithFormat:@"%@%%", [numberFormatter stringFromNumber:twicSizeNumber]];
    //hud.detailsLabelText = twicSizeString;
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSString *errore = NSLocalizedString(@"ERROR", nil);
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:errore message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [errorAlertView show];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSLog(@"Ho finito di scaricare il Database");
    
    if (downloadAlertView) {
        [downloadAlertView dismissWithClickedButtonIndex:0 animated:YES];
        downloadAlertView = nil;
    }
    
    PgnMentorSaveDatabaseTableViewController *saveDatabase = [[PgnMentorSaveDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [saveDatabase setFileToSave:[listAperturePgn objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
    saveDatabase.delegate = self;
    UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:saveDatabase];
    if (IS_PAD) {
        boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    else {
        boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    //dispatch_async(dispatch_get_main_queue(), ^{
    [self presentViewController:boardNavigationController animated:YES completion:nil];
    //});
    
    return;
    
    
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootPath = [paths objectAtIndex:0];
    NSString *filePath = [rootPath stringByAppendingPathComponent:[linkFile lastPathComponent]];
    NSLog(@"FILEPATH = %@", filePath);
    [totalData writeToFile:filePath atomically:YES];
    
    NSString *lastPathFile = [filePath substringFromIndex:[filePath length] - 3];
    if ([lastPathFile caseInsensitiveCompare:@"ZIP"] == NSOrderedSame) {
        NSLog(@"DEVO UNZIPPARE IL FILE");
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        if ([zipArchive UnzipOpenFile:filePath]) {
            if ([zipArchive UnzipFileTo:rootPath overWrite:YES] != NO) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
    }
    */
     
    //PgnMentorSaveDatabaseTableViewController *saveDatabase = [[PgnMentorSaveDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
    //UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:saveDatabase];
    //if (IS_PAD) {
    //boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    //}
    //else {
    //    boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
    //}
    //dispatch_async(dispatch_get_main_queue(), ^{
    //[self presentModalViewController:boardNavigationController animated:YES];
    //[self presentViewController:boardNavigationController animated:YES completion:nil];
    //});
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [connection cancel];
    downloadAlertView = nil;
}


- (void) saveDatabase:(NSString *)path {
    NSString *filePath = [path stringByAppendingPathComponent:[linkFile lastPathComponent]];
    //NSLog(@"FILEPATH = %@", filePath);
    [totalData writeToFile:filePath atomically:YES];
    NSString *lastPathFile = [filePath substringFromIndex:[filePath length] - 3];
    if ([lastPathFile caseInsensitiveCompare:@"ZIP"] == NSOrderedSame) {
        //NSLog(@"DEVO UNZIPPARE IL FILE");
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        if ([zipArchive UnzipOpenFile:filePath]) {
            if ([zipArchive UnzipFileTo:path overWrite:YES] != NO) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
    }
}

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
