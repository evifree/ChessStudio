//
//  DropboxTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 05/12/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "DropboxTableViewController.h"
#import "SWRevealViewController.h"

@interface DropboxTableViewController () {

    NSMutableArray *listDirectory;
    NSMutableArray *listFiles;
    
    NSMutableCharacterSet *setSlash;
    
    UIAlertView *dropboxAlertView;
    
    BOOL isRevealed;

}

@end

@implementation DropboxTableViewController

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
    
    isRevealed = NO;
    
    self.navigationController.toolbarHidden = NO;
    
    setSlash = [[NSMutableCharacterSet alloc] init];
    [setSlash addCharactersInString:@"/"];
    
    if (_databasesDaCopiare.count > 0) {
        UIBarButtonItem *moveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DROPBOX_UPLOAD_DB", nil) style:UIBarButtonItemStylePlain target:self action:@selector(moveButtonPressed:)];
        UIBarButtonItem *nuovaCartellaButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil) style:UIBarButtonItemStylePlain target:self action:@selector(newDirectoryButtonPressed:)];
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        NSArray *items = [NSArray arrayWithObjects:nuovaCartellaButton, flexibleItem, moveButton, nil];
        self.toolbarItems = items;
    }
    
    listDirectory = [[NSMutableArray alloc] init];
    listFiles = [[NSMutableArray alloc] init];
    
    [self checkRevealed];
    
    
    if (!isRevealed) {
        UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_CLOSE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)];
        self.navigationItem.rightBarButtonItem = doneBarButtonItem;
    }
    
    
    if (![[DBSession sharedSession] isLinked]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLinked:) name:@"DropboxLinked" object:nil];
        [[DBSession sharedSession] linkFromController:self];
        return;
    }
    
    
    
    _dbRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    _dbRestClient.delegate = self;
    
    
    if ([_startDirectory isEqualToString:@"/"]) {
        self.navigationItem.title = @"Dropbox";
    }
    else {
        self.navigationItem.title = [_startDirectory stringByTrimmingCharactersInSet:setSlash];
        [setSlash addCharactersInString:_startDirectory];
    }
    
    
    [_dbRestClient loadMetadata:_startDirectory];
    

    
}

- (void) checkRevealed {
    UIViewController *sourceViewController = self.parentViewController.parentViewController;
    if (sourceViewController) {
        //NSLog(@"%@", sourceViewController);
        SWRevealViewController *revealViewController = [self revealViewController];
        [revealViewController panGestureRecognizer];
        [revealViewController tapGestureRecognizer];
        
        if ([_startDirectory isEqualToString:@"/"]) {
            UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon.png"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
            self.navigationItem.leftBarButtonItem = revealButtonItem;
        }
        isRevealed = YES;
    }
}

- (void) dropboxLinked:(NSNotification *)notification {
    //NSLog(@"Notifica ricevuta da DropboxTableviewController");
    //NSLog(@"NOME = %@", notification.name);
    //giordano.vicoli@gmail.com
    
    _dbRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    _dbRestClient.delegate = self;
    
    
    if ([_startDirectory isEqualToString:@"/"]) {
        self.navigationItem.title = @"Root";
    }
    else {
        self.navigationItem.title = [_startDirectory stringByTrimmingCharactersInSet:setSlash];
        [setSlash addCharactersInString:_startDirectory];
    }
    
    
    [_dbRestClient loadMetadata:_startDirectory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doneButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) newDirectoryButtonPressed:(id)sender {
    //NSLog(@"Devo creare una directory in Dropbox");
    
    UIAlertView *newDirectoryAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
    newDirectoryAlertView.tag = 4;
    newDirectoryAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newDirectoryAlertView show];
    
    
    //[_dbRestClient createFolder:@"Pippo"];
}

- (void) moveButtonPressed:(id)sender {
    for (NSString *db in _databasesDaCopiare) {
        NSString *file = [db lastPathComponent];
        //NSString *filePath = [db stringByDeletingLastPathComponent];
        //NSLog(@"FILE = %@      FILEPATH = %@    DESTINATION = %@", file, db, _startDirectory);
        dropboxAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"DROPBOX_UPLOADING", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:nil, nil];
        dropboxAlertView.tag = 3;
        [dropboxAlertView show];
        
        [_dbRestClient uploadFile:file toPath:_startDirectory withParentRev:nil fromPath:db];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listDirectory.count;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    DBMetadata *child = [listDirectory objectAtIndex:indexPath.row];
    if (!child.isDirectory) {
        NSString *pathExtension = [child.filename pathExtension];
        NSString *pathExtensionUpper = [pathExtension uppercaseString];
        if ([pathExtensionUpper isEqualToString:@"PGN"]) {
            UIColor *pgnRowColor = UIColorFromRGB(0xFFF68F);
            [cell setBackgroundColor: pgnRowColor];
        }
        else {
            [cell setBackgroundColor:[UIColor clearColor]];
        }
    }
    else {
        [cell setBackgroundColor:[UIColor clearColor]];
    }*/
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Dropbox Files";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    DBMetadata *child = [listDirectory objectAtIndex:indexPath.row];
    
    if (child.isDirectory) {
        cell.imageView.image = [UIImage imageNamed:@"FolderDropbox"];
        //NSLog(@"DIRECTORY = %@", child.path);
        //cell.textLabel.text = [[child.path stringByTrimmingCharactersInSet:setSlash] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *dirArray = [child.path componentsSeparatedByString:@"/"];
        //cell.textLabel.text = [child.path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        cell.textLabel.text = [dirArray objectAtIndex:dirArray.count - 1];
    }
    else {
        NSString *pathExtension = [child.filename pathExtension];
        NSString *pathExtensionUpper = [pathExtension uppercaseString];
        if ([pathExtensionUpper isEqualToString:@"PGN"]) {
            cell.imageView.image = [UIImage imageNamed:@"PgnChessIcon"];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"DropboxFile"];
        }
        cell.textLabel.text = child.filename;
    }
    // Configure the cell...
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBMetadata *child = [listDirectory objectAtIndex:indexPath.row];
    if (child.isDirectory) {
        NSString *startDir = child.path;//[[child.path stringByTrimmingCharactersInSet:setSlash] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        DropboxTableViewController *dtvc = [[DropboxTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [dtvc setDatabasesDaCopiare:_databasesDaCopiare];
        [dtvc setStartDirectory:startDir];
        [self.navigationController pushViewController:dtvc animated:YES];
    }
    else {
        NSString *pathExtension = [child.filename pathExtension];
        NSString *pathExtensionUpper = [pathExtension uppercaseString];
        if ([pathExtensionUpper isEqualToString:@"PGN"]) {
            NSString *title = NSLocalizedString(@"DOWNLOAD_DATABASE_DROPBOX", nil);
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"DROPBOX_CONFIRM_DOWNLOAD", nil), child.filename];
            UIAlertView *pgnDownAlertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
            pgnDownAlertView.tag = 1;
            [pgnDownAlertView show];
        }
        else {
            NSString *title = NSLocalizedString(@"DROPBOX_WRONG_FORMAT", nil);
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"DROPBOX_WRONG_SELECTED_DATABASE", nil)];
            UIAlertView *pgnNotDownAlertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [pgnNotDownAlertView show];
        }
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

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            DBMetadata *child = [listDirectory objectAtIndex:indexPath.row];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *localPath = [documentsDirectory stringByAppendingPathComponent:child.filename];
            
            dropboxAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"DATABASE_DOWNLOADING_IOS7", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:nil, nil];
            dropboxAlertView.tag = 2;
            [dropboxAlertView show];
            [_dbRestClient loadFile:child.path intoPath:localPath];
        }
    }
    else if (alertView.tag == 2) {
        [_dbRestClient cancelAllRequests];
        //NSLog(@"Ho cancellato la richiesta di download");
    }
    else if (alertView.tag == 3) {
        [_dbRestClient cancelAllRequests];
        //NSLog(@"Ho cancellato la richiesta di upload");
    }
    else if (alertView.tag == 4) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
            NSString *newFolder = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            //NSLog(@"%@", newFolder);
            NSString *path = [_startDirectory stringByAppendingPathComponent:newFolder];
            //NSLog(@"%@", path);
            [_dbRestClient createFolder:path];
        }
    }
}

- (void) restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    
    //[dropboxAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    
    [listDirectory removeAllObjects];
    
    for (DBMetadata *child in metadata.contents) {
        [listDirectory addObject:child];
    }
    
    [self.tableView reloadData];
    
}

- (void) restClient:(DBRestClient *)client loadedSearchResults:(NSArray *)results forPath:(NSString *)path keyword:(NSString *)keyword {
    
    //NSLog(@"Metodo loaded search result eseguito");
    
    //NSLog(@"Ci sono %d risultati", results.count);
}

- (void) restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    //NSLog(@"ERROR LOADING METADATA: %@", error);
    //[dropboxAlertView dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *dropboxLoadMetadataErrorAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"DROPBOX_ERROR_LOAD_METADATA", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [dropboxLoadMetadataErrorAlertView show];
}

- (void) restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    //NSLog(@"File Load into path %@", destPath);
    [dropboxAlertView dismissWithClickedButtonIndex:0 animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxLoadedFile" object:[NSNumber numberWithBool:[[DBSession sharedSession] isLinked]]];
}

- (void) restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    //NSLog(@"There was an error loading the file: %@", error);
    [dropboxAlertView dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *dropboxDownloadErrorAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"DROPBOX_ERROR_DOWNLOADING", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [dropboxDownloadErrorAlertView show];
}

- (void) restClient:(DBRestClient *)restClient searchFailedWithError:(NSError *)error {
    //NSLog(@"There was an error searching the file: %@", error);
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    //NSLog(@"File uploaded successfully to path: %@", metadata.path);
    [_dbRestClient loadMetadata:_startDirectory];
    [dropboxAlertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    //NSLog(@"File upload failed with error: %@", error);
    [dropboxAlertView dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *dropboxUploadErrorAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"DROPBOX_ERROR_UPLOADING", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [dropboxUploadErrorAlertView show];
}

- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata *)folder{
    //NSLog(@"Created Folder Path %@",folder.path);
    //NSLog(@"Created Folder name %@",folder.filename);
    [_dbRestClient loadMetadata:_startDirectory];
}

- (void)restClient:(DBRestClient *)client createFolderFailedWithError:(NSError *)error{
    //NSLog(@"Error creating folder %@",error);
    UIAlertView *dropboxNewFolderErrorAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"DROPBOX_ERROR_CREATE_FOLDER", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [dropboxNewFolderErrorAlertView show];
}

@end
