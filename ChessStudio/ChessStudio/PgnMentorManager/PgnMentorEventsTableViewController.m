//
//  PgnMentorEventsTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 28/11/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "PgnMentorEventsTableViewController.h"
#import "ZipArchive.h"

@interface PgnMentorEventsTableViewController () {
    
    UIAlertView *downloadAlertView;
    NSURLConnection *connection;

    NSArray *tableArray;
    
    NSMutableArray *listEventsPgn;
    NSMutableArray *listEvents;
    NSMutableArray *listLinkEvents;
    
    NSInteger totalDownloaded;
    NSMutableData *totalData;
    NSInteger downloadSize;
    
    NSString *fileToDownload;
    NSString *linkFile;
}

@end

#define MENTOR @"http://www.pgnmentor.com/"

@implementation PgnMentorEventsTableViewController

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
    
    self.navigationItem.title = NSLocalizedString(@"PGN_MENTOR_EVENTS", nil);
    [self loadEvents];
    
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0XCAFF70);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Metodi per caricare i dati da PGN Mentor

- (void) loadEvents {
    
    listEvents = [[NSMutableArray alloc] init];
    listEventsPgn = [[NSMutableArray alloc] init];
    listLinkEvents = [[NSMutableArray alloc] init];
    
    HTMLSelector *selector = [HTMLSelector selectorForString:@"table"];
    tableArray = [_htmlDocument nodesMatchingParsedSelector:selector];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listEvents.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //cell.backgroundColor = UIColorFromRGB(0XCAFF70);
    
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
    static NSString *CellIdentifier = @"Cell Pgn Events";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    cell.textLabel.text = [listEvents objectAtIndex:indexPath.row];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:15];
    cell.detailTextLabel.textColor = [UIColor blueColor];
    cell.detailTextLabel.text = [listEventsPgn objectAtIndex: indexPath.row];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSString *dato = [listPlayers objectAtIndex:indexPath.row];
    //NSString *dato2 = [listPlayersPgn objectAtIndex:indexPath.row];
    fileToDownload = [listEventsPgn objectAtIndex:indexPath.row];
    linkFile = [listLinkEvents objectAtIndex:indexPath.row];
    
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
    [saveDatabase setFileToSave:[listEventsPgn objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
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
