//
//  CloudTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 30/06/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "CloudTableViewController.h"
#import "SWRevealViewController.h"

@interface CloudTableViewController () {
    
    SettingManager *settingManager;

    UIActionSheet *actionSheetMenu;
    NSArray *fileSelezionatiDaEliminareCopiareSpostare;
    
    
    
    BOOL iCloudOn;
    id currentCloudToken;
    
    NSMetadataQuery *_query;
    NSMutableArray * _iCloudURLs;
    NSMutableArray *listPgnDatabase;
}

@end

@implementation CloudTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    settingManager = [SettingManager sharedSettingManager];
    
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0xB0E2FF);
    [self setupTitle];
    
    [self checkRevealed];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eliminaDatabaseFromCloud:) name:@"EliminaCloud" object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionBarButtonItemPressed:)];
    self.navigationItem.rightBarButtonItem = actionBarButtonItem;
    
    
    iCloudOn = [settingManager iCloudOn];
    currentCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    [self setupCloud];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) setupTitle {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:40.0];
    //titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textColor = UIColorFromRGB(0x0000CD);
    titleLabel.text = NSLocalizedString(@"iCloud", nil);
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationItem.titleView = titleLabel;
}

- (void) checkRevealed {
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window]rootViewController];
    if ([rootViewController isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *revealViewController = [self revealViewController];
        [revealViewController panGestureRecognizer];
        [revealViewController tapGestureRecognizer];
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
}

- (void) actionBarButtonItemPressed:(UIBarButtonItem *)sender {
    if (actionSheetMenu.window ) {
        [actionSheetMenu dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    
    NSString *cancelButton;
    if (IS_PAD) {
        cancelButton = @"";
    }
    else {
        cancelButton = NSLocalizedString(@"ACTIONSHEET_CANCEL", nil);
    }
    
    actionSheetMenu = [[UIActionSheet alloc] init];
    actionSheetMenu.delegate = self;
    if (self.tableView.isEditing) {
        if (fileSelezionatiDaEliminareCopiareSpostare.count > 0) {
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"COPY_DB", nil)];
            //[actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MOVE_DB", nil)];
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"DELETE_DB", nil)];
        }
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"DONE_DATABASE", nil)];
    }
    else {
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_MANAGE_DATABASE", nil)];
    }
    
    actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
    
    
    [actionSheetMenu showFromBarButtonItem:sender animated:YES];
}

- (void) edit {
    if (![self.tableView isEditing]) {
        self.tableView.allowsMultipleSelectionDuringEditing = YES;
        [self.tableView setValue:[UIColor blueColor] forKey:@"multiselectCheckmarkColor"];
        [self.tableView setEditing:YES animated:YES];
    }
    else {
        [self.tableView setEditing:NO animated:YES];
    }
}


#pragma mark iCloud Setup

- (NSMetadataQuery *) documentQuery {
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    if (query) {
        // Search documents subdir only
        [query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
        // Add a predicate for finding the documents
        NSString *filePattern = [NSString stringWithFormat:@"*.%@", PGN_EXTENSION];
        //NSString *filePattern = [NSString stringWithFormat:@"*.*"];
        [query setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@", NSMetadataItemFSNameKey, filePattern]];
    }
    return query;
}

- (void) startQuery {
    
    [self stopQuery];
    
    //NSLog(@"Starting to watch iCloud dir...");
    
    _query = [self documentQuery];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processICloudFiles:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processICloudFiles:) name:NSMetadataQueryDidUpdateNotification object:nil];
    
    [_query startQuery];
}

- (void)stopQuery {
    
    if (_query) {
        
        //NSLog(@"No longer watching iCloud dir...");
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:nil];
        [_query stopQuery];
        _query = nil;
    }
}

- (void) setupCloud {
    
    if (!currentCloudToken) {
        UIAlertView *noCloudTokenAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ICLOUD_DISABLED_SYSTEM_TITLE", nil) message:NSLocalizedString(@"ICLOUD_DISABLED_SYSTEM_MSG", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [noCloudTokenAlertView show];
        return;
    }
    
    if (!iCloudOn) {
        UIAlertView *noCloudAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ICLOUD_DISABLED_APP_TITLE", nil) message:NSLocalizedString(@"ICLOUD_DISABLED_APP_MSG", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        noCloudAlertView.tag = 200;
        [noCloudAlertView show];
        return;
    }

    _iCloudURLs = [[NSMutableArray alloc] init];
    listPgnDatabase = [[NSMutableArray alloc] init];
    [self startQuery];
}

- (void) processICloudFiles:(NSNotification *)notification {
    
    NSLog(@"RECEIVED NOTIFICATION");
    
    [_query disableUpdates];
    
    
    [_iCloudURLs removeAllObjects];
    [listPgnDatabase removeAllObjects];
    
    NSArray *queryResults = [_query results];
    for (NSMetadataItem *result in queryResults) {
        NSURL *fileURL = [result valueForAttribute:NSMetadataItemURLKey];
        NSNumber *aBool = nil;
        
        // Don't include hidden files
        [fileURL getResourceValue:&aBool forKey:NSURLIsHiddenKey error:nil];
        if (aBool && ![aBool boolValue]) {
            [_iCloudURLs addObject:fileURL];
        }
    }
    
    for (NSURL *url in _iCloudURLs) {
        [listPgnDatabase addObject:[url path]];
    }
    
    [listPgnDatabase sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    [self.tableView reloadData];
    
    [_query enableUpdates];
}

- (void) removeDocumentAtUrl:(NSURL *)fileURL {
    
    [_query disableUpdates];
    
    // Wrap in file coordinator
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [fileCoordinator coordinateWritingItemAtURL:fileURL options:NSFileCoordinatorWritingForDeleting error:nil
                                         byAccessor:^(NSURL* writingURL) {
                                             // Simple delete to start
                                             NSFileManager* fileManager = [[NSFileManager alloc] init];
                                             [fileManager removeItemAtURL:fileURL error:nil];
                                             [_query enableUpdates];
                                             NSLog(@"Database Eliminato:%@", fileURL.lastPathComponent);
                                         }];
    });
}

- (NSURL *)urlForFilename:(NSString *)filename {
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL *pathURL = [baseURL URLByAppendingPathComponent:@"Documents"];
    NSURL *destinationURL = [pathURL URLByAppendingPathComponent:filename];
    return destinationURL;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listPgnDatabase count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *text = NSLocalizedString(@"ICLOUD_MESSAGE", nil);
    CGRect rect = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth(tableView.frame), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0]} context:nil];
    
    return MAX(CGRectGetHeight(rect), 44); // keep height no smaller than Plain cells
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lblSectionName = [[UILabel alloc] init];
    lblSectionName.text = NSLocalizedString(@"ICLOUD_MESSAGE", nil);
    lblSectionName.adjustsFontSizeToFitWidth = YES;
    lblSectionName.textColor = UIColorFromRGB(0x0000CD);
    lblSectionName.numberOfLines = 0;
    lblSectionName.lineBreakMode = NSLineBreakByWordWrapping;
    lblSectionName.backgroundColor = UIColorFromRGB(0xB0E2FF);
    lblSectionName.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0];
    lblSectionName.textAlignment = NSTextAlignmentCenter;
    [lblSectionName sizeToFit];
    
    return lblSectionName;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Cloud Manager";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (IS_PAD) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    else {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    
    // Configure the cell...
    cell.imageView.image = [UIImage imageNamed:@"PgnChessIconCloud"];
    NSString *pgnFileName = [[[listPgnDatabase objectAtIndex:indexPath.row] lastPathComponent] stringByReplacingOccurrencesOfString:@".dat" withString:@".pgn"];
    cell.textLabel.text = pgnFileName;
    cell.detailTextLabel.text = [listPgnDatabase objectAtIndex:indexPath.row];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *pgnFileToDelete = [[listPgnDatabase objectAtIndex:indexPath.row] lastPathComponent];
        NSURL *pgnUrlToDelete = [self urlForFilename:pgnFileToDelete];
        NSLog(@"DELETE:%@", pgnUrlToDelete.path);
        [self removeDocumentAtUrl:pgnUrlToDelete];
        [listPgnDatabase removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        fileSelezionatiDaEliminareCopiareSpostare = [tableView indexPathsForSelectedRows];
        return;
    }
    
    [self performSelector: @selector(deselect:) withObject: tableView afterDelay: 0.1];
    
    NSString *pgnFileSelected = [listPgnDatabase objectAtIndex:indexPath.row];
    NSURL *pgnUrlSelected = [[NSURL alloc] initFileURLWithPath:pgnFileSelected];
    PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:pgnUrlSelected];
    [pfd openWithCompletionHandler:^(BOOL success) {
        if (success) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
            PgnFileInfoTableViewController *pitvc = [sb instantiateViewControllerWithIdentifier:@"PgnFileInfoTable"];
            [pitvc setPgnFileDoc:pfd];
            [self.navigationController pushViewController:pitvc animated:YES];
        }
    }];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        fileSelezionatiDaEliminareCopiareSpostare = [tableView indexPathsForSelectedRows];
        return;
    }
}

- (void)deselect:(UITableView *)tableView {
    [tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow] animated: YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForSwipeAccessoryButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"COPY", nil);
}

-(void)tableView:(UITableView *)tableView swipeAccessoryButtonPushedForRowAtIndexPath:(NSIndexPath *)indexPath {
    fileSelezionatiDaEliminareCopiareSpostare = [NSArray arrayWithObject:indexPath];
    [self copyDatabase];
}

- (void) copyDatabase {
    CopyFromCloudToPgnDatabaseTableViewController *cpdtvc = [[CopyFromCloudToPgnDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [cpdtvc setActualPath:nil];
    //cpdtvc.delegate = self;
    
    NSMutableArray *databases = [[NSMutableArray alloc] init];
    for (NSIndexPath *ip in fileSelezionatiDaEliminareCopiareSpostare) {
        //NSString *item = [localCloudPath stringByAppendingPathComponent:[listPgnFile objectAtIndex:ip.row]];
        NSString *item = [listPgnDatabase objectAtIndex:ip.row];
        [databases addObject:item];
    }
    
    [cpdtvc setDatabasesDaCopiare:databases];
    
    UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:cpdtvc];
    if (IS_PAD) {
        boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    else {
        boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:boardNavigationController animated:YES completion:nil];
    });
}

- (void) moveDatabase {
    MoveFromCloudToPgnDatabaseTableViewController *cpdtvc = [[MoveFromCloudToPgnDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [cpdtvc setActualPath:nil];
    //cpdtvc.delegate = self;
    
    NSMutableArray *databases = [[NSMutableArray alloc] init];
    for (NSIndexPath *ip in fileSelezionatiDaEliminareCopiareSpostare) {
        //NSString *item = [localCloudPath stringByAppendingPathComponent:[listPgnFile objectAtIndex:ip.row]];
        NSString *item = [listPgnDatabase objectAtIndex:ip.row];
        [databases addObject:item];
    }
    
    [cpdtvc setDatabasesDaSpostare:databases];
    
    UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:cpdtvc];
    if (IS_PAD) {
        boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    else {
        boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:boardNavigationController animated:YES completion:nil];
    });
}

#pragma mark ActionSheet Delegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex<0) {
        return;
    }
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"MENU_MANAGE_DATABASE", nil)]) {
        [self edit];
    }
    else if ([title isEqualToString:NSLocalizedString(@"DONE_DATABASE", nil)]) {
        [self edit];
    }
    else if ([title isEqualToString:NSLocalizedString(@"COPY_DB", nil)]) {
        [self copyDatabase];
    }
    else if ([title isEqualToString:NSLocalizedString(@"MOVE_DB", nil)]) {
        [self moveDatabase];
    }
    else if ([title isEqualToString:NSLocalizedString(@"DELETE_DB", nil)]) {
        //NSLog(@"Devo eliminare %lu database", (unsigned long)fileSelezionatiDaEliminareCopiareSpostare.count);
        NSString *msg;
        if (fileSelezionatiDaEliminareCopiareSpostare.count == 1) {
            msg = NSLocalizedString(@"CONFIRM_DELETE_SINGLE_DATABASE", nil);
        }
        else if (fileSelezionatiDaEliminareCopiareSpostare.count > 1) {
            msg = NSLocalizedString(@"CONFIRM_DELETE_MORE_DATABASE", nil);
        }
        
        UIAlertView *deleteDbAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONFIRM_TITLE_DELETE_DATABASE", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        deleteDbAlertView.tag = 100;
        [deleteDbAlertView show];
        return;
        //[self deleteDatabase];
    }
}

#pragma mark AlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:NSLocalizedString(@"NO", nil)]) {
            return;
        }
        //[self deleteDatabase];
    }
    else if (alertView.tag == 200) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:NSLocalizedString(@"YES", nil)]) {
            [settingManager setICloudOn:YES];
            //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            //[userDefaults setBool:YES forKey:@"iCloudOn"];
            //[userDefaults synchronize];
            iCloudOn = YES;
            [self setupCloud];
        }
    }
    return;
}

- (void) eliminaDatabaseFromCloud:(NSNotification *)notification {
    [_query disableUpdates];
    NSURL *sourceUrl = [notification object];
    NSLog(@"Devo eliminare %@", sourceUrl);
    [self edit];
    [self removeDocumentAtUrl:sourceUrl];
    [_query enableUpdates];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
