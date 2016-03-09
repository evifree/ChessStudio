//
//  MainCloudTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/05/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "MainCloudTableViewController.h"
#import "SWRevealViewController.h"
#import "PgnDbManager.h"
#import "PgnFileInfoTableViewController.h"
#import "MBProgressHUD.h"

@interface MainCloudTableViewController () <UIDocumentPickerDelegate> {
    
    SettingManager *settingManager;
    
    NSMetadataQuery *_query;
    NSMutableArray * _iCloudURLs;
    NSMutableArray *listPgnDatabase;
    
    
    UISegmentedControl *segmentedControl;
    PgnFileDocument *pgnFileDocument;
    
    //NSMutableArray *listPgnFile;
    NSMutableArray *listPgnPath;
    //NSMutableArray *listPgnUrl;
    
    
    //NSString *localCloudPath;
    
    PgnDbManager *pgnDbManager;
    
    BOOL iCloudOn;
    id currentCloudToken;
    
    
    NSArray *fileSelezionatiDaEliminareCopiareSpostare;
    
    UIActionSheet *actionSheetMenu;
}

@end

@implementation MainCloudTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //self.navigationItem.title = @"iCloud";
    
    settingManager = [SettingManager sharedSettingManager];
    
    [self setupTitle];
    
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0xB0E2FF);
    
    [self checkRevealed];
    
    pgnDbManager = [PgnDbManager sharedPgnDbManager];
    
    
    iCloudOn = [settingManager iCloudOn];
    currentCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    
    //UIBarButtonItem *addFileBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewFile)];
    //self.navigationItem.rightBarButtonItem = addFileBarButtonItem;
    
    
    //UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBarButtonPressed)];
    //self.navigationItem.rightBarButtonItem = editBarButtonItem;
    
    UIBarButtonItem *actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionBarButtonItemPressed:)];
    self.navigationItem.rightBarButtonItem = actionBarButtonItem;
    
    
    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector (storeDidChange:) name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification object: [NSUbiquitousKeyValueStore defaultStore]];
    //[[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
    //[self createCloudDirectory];
    
    
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    //localCloudPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"iCloudMetadata"];
    //NSLog(@"§§§§§§§§§§§   %@", localCloudPath);
    
    //[self loadFiles];
    
    //[self removeMetadataDatabase];
    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self setRefreshControl:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshCloud:) forControlEvents:UIControlEventValueChanged];
    
    
    
    _iCloudURLs = [[NSMutableArray alloc] init];
    listPgnDatabase = [[NSMutableArray alloc] init];
    [self refresh];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self setupSegmentedControl];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)refreshCloud:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
    NSError *error = nil;
    [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:[self urlCloud] error:&error];
}

- (void) setupTitle {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    if (IS_PAD) {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:40.0];
    }
    else {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25.0];
    }
    
    //titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textColor = UIColorFromRGB(0x0000CD);
    titleLabel.text = NSLocalizedString(@"ICLOUD CHESS STUDIO", nil);
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

- (void) editBarButtonPressed {
    if (![self.tableView isEditing]) {
        //self.tableView.allowsMultipleSelectionDuringEditing = YES;
        //[self.tableView setValue:[UIColor redColor] forKey:@"multiselectCheckmarkColor"];
        [self.tableView setEditing:YES animated:YES];
    }
    else {
        //if (fileSelezionatiDaEliminare.count > 0) {
        //    NSMutableArray *arrayOfFileToDelete = [[NSMutableArray alloc] init];
        //    for (NSIndexPath *indexPath in fileSelezionatiDaEliminare) {
        //        NSString *item = [listPgnFile objectAtIndex:indexPath.row];
        //        [arrayOfFileToDelete addObject:item];
        //    }
            
        //    NSLog(@"Devo Eliminare\n%@", arrayOfFileToDelete);
        //    return;
        //}
        
        [self.tableView setEditing:NO animated:YES];
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
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MOVE_DB", nil)];
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


- (void) setupSegmentedControl {
    
    NSArray *segmentedItems = nil;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        segmentedItems = [NSArray arrayWithObjects:@"iCloud Import", @"iCloud Export", nil];
        segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedItems];
        [segmentedControl setSelectedSegmentIndex:0];
        [segmentedControl addTarget:self action:@selector(segControlChanged:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = segmentedControl;
        [segmentedControl setSelectedSegmentIndex:-1];
    }
}



- (void) segControlChanged:(UISegmentedControl *)segControl {
    NSInteger index = [segControl selectedSegmentIndex];
    //[self cambiaColoreSegControl:segControl :index];
    if (index == 0) {
        [self iCloudImport];
    }
    else if (index == 1) {
        [self iCloudExport];
    }
    
}


/*
- (void) cambiaColoreSegControl:(UISegmentedControl *)segControl :(NSInteger)index {
    
    //NSLog(@"Cambia Colore Seg Control");
    
    if (index == 0) {
        [segControl setTintColor:[UIColor blueColor]];
        [self.tableView reloadData];
    }
    else if (index == 1) {
        [segControl setTintColor:[UIColor redColor]];
    }
    else if (index == 2) {
        [segControl setTintColor:[UIColor colorWithRed:0 green:0.6 blue:0 alpha:1]];
    }
    else if (index == 3) {
        [segControl setTintColor:[UIColor blackColor]];
    }
    else if (index == 4) {
        [self iCloudImport];
    }
    else if (index == 5) {
        [self iCloudExport];
    }
    [segControl setSelectedSegmentIndex:index];
    //[[NSUbiquitousKeyValueStore defaultStore] setLongLong:index forKey:@"selectedColorIndex"];
    //[[NSUbiquitousKeyValueStore defaultStore] synchronize];
}
*/

- (void) documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        NSString *alertMessage = [NSString stringWithFormat:@"Successfully imported %@", url];
        NSLog(@"%@", alertMessage);
    }
    else if (controller.documentPickerMode == UIDocumentPickerModeExportToService) {
        NSLog(@"Exported succesfully");
    }
}

- (void) iCloudImport {
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void) iCloudExport {
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"Fischer" withExtension:@"pgn"] inMode:UIDocumentPickerModeExportToService];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void) documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"Cancelled");
}

/*
- (void)storeDidChange:(NSNotification *)notification {
    //[self updateUserDefaultsFromICloud];
    NSLog(@"Cambio Key Value");
    NSDictionary *values = [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];
    if ([values valueForKey:@"selectedColorIndex"] != nil) {
        NSUInteger selectedColorIndex = (NSUInteger)[[NSUbiquitousKeyValueStore defaultStore] longLongForKey:@"selectedColorIndex"];
        NSLog(@"Selected Color Index = %lu", (unsigned long)selectedColorIndex);
        [self cambiaColoreSegControl:segmentedControl :selectedColorIndex];
    }
}
*/

- (void) loadFiles {
    
    pgnDbManager = [PgnDbManager sharedPgnDbManager];
    //NSLog(@"%@", localCloudPath);
    //NSMutableArray *tempList = [pgnDbManager listPgnFileAndDirectoryAtPath:localCloudPath];
    //listPgnFile = [[NSMutableArray alloc] init];
    
    //for (NSString *f in tempList) {
        //NSLog(@"%@", f);
        //NSString *newFile = [f stringByReplacingOccurrencesOfString:@" " withString:@""];
        //NSLog(@"%@", newFile);
        //[listPgnFile addObject:newFile];
    //}
    
    //[self.tableView reloadData];
    
    
    //[self localToCloud];
    
    //return;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
    //NSLog(@"got cloudURL %@", cloudURL);
    if (cloudURL) {
        _query = [[NSMetadataQuery alloc] init];
        //query.predicate = [NSPredicate predicateWithFormat:@"%K like '*.pgn'", NSMetadataItemFSNameKey];
        _query.predicate = [NSPredicate predicateWithFormat:@"%K like '*.dat'", NSMetadataItemFSNameKey];
        _query.searchScopes = [NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUbiquitousDocuments:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUbiquitousDocuments:) name:NSMetadataQueryDidUpdateNotification object:nil];
        
        [_query startQuery];
    }
}


- (void) localToCloud {
    
    //for (NSString *fileName in listPgnFile) {
        
        //NSString *localPathForFile = [localCloudPath stringByAppendingPathComponent:fileName];
        //NSURL *localFileUrl = [NSURL URLWithString:localPathForFile];
        //NSLog(@"%@", localFileUrl);
        
        //NSURL *urlForCloud = [self urlForFilename:fileName];
        //NSLog(@"%@", urlForCloud);
        
        //PgnFileDocument *pgnFileDoc = [[PgnFileDocument alloc] initWithFileURL:localFileUrl];
    //}
}

- (void) createCloudDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSString *teamID = @"PULE4PCB27";
    //NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    //NSString *rootFolderIdentifier = [NSString stringWithFormat:@"%@.%@", teamID, bundleId];
    NSURL *containerUrl = [fileManager URLForUbiquityContainerIdentifier:nil];
    NSString *documentsDirectory = [[containerUrl path] stringByAppendingPathComponent:@"Documents"];
    NSString *csDir = [documentsDirectory stringByAppendingPathComponent:@"ChessStudio"];
    BOOL isDirectory = NO;
    BOOL mustCreateDocumentsDirectory = NO;
    
    //NSLog(@"%@", csDir);
    
    if ([fileManager fileExistsAtPath:csDir isDirectory:&isDirectory]) {
        if (isDirectory == NO) {
            mustCreateDocumentsDirectory = YES;
        }
    }
    else {
        mustCreateDocumentsDirectory = YES;
    }
    
    if (mustCreateDocumentsDirectory) {
        NSLog(@"Devo creare la directory");
        NSError *directoryCreationError = nil;
        if ([fileManager createDirectoryAtPath:csDir withIntermediateDirectories:YES attributes:nil error:&directoryCreationError]) {
            NSLog(@"Directory creata con successo");
        }
        else {
            NSLog(@"Directory non creata = %@", directoryCreationError);
        }
    }
    else {
        NSLog(@"Directory già esistente");
    }
}

/*
- (void) checkPgnFile {
    if (listPgnFile) {
        [listPgnFile removeAllObjects];
    }
    else {
        listPgnFile = [[NSMutableArray alloc] init];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cloudPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cloud"];
    listPgnFile = [pgnDbManager listPgnFileAndDirectoryAtPath:cloudPath];
    //for (NSString *pgnFile in listPgnFile) {
        //NSLog(@"%@", pgnFile);
    //}
}
*/

- (void) savePgnFile:(NSURL *)fromUrl :(NSString *)pgnFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cloudPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cloud"];
    NSString *filePath = [cloudPath stringByAppendingPathComponent:pgnFile];
    //NSLog(@"Devo salvare: %@", filePath);
    BOOL copiato = [pgnDbManager copyDatabase:[fromUrl path] :filePath];
    if (copiato) {
        //NSLog(@"Database %@ copiato con successo", [fromUrl path]);
    }
    else {
        //NSLog(@"Database %@ non copiato", [fromUrl path]);
    }
}


- (void) createNewFile {
    
    //UIPasteboard *clipBoard = [UIPasteboard generalPasteboard];
    //for (NSString *path in clipBoard.strings) {
        //NSLog(@"%@", path);
        //NSString *pgnFile = [path lastPathComponent];
        //NSString *destination = [localCloudPath stringByAppendingPathComponent:pgnFile];
        
        
        //NSLog(@"File da copiare con path = %@", path);
        //NSLog(@"Destinazione con path = %@", destination);
    
        //BOOL copiato = [pgnDbManager copyDatabase:path :destination];
        //if (copiato) {
            //NSLog(@"Database %@ copiato con successo", pgnFile);
        //}
        //else {
            //NSLog(@"Database %@ non copiato", pgnFile);
        //}
    //}
    
    [self loadFiles];
    
    
    return;
    
    
    
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"Choose File Name" message: @"Enter a name for your new PGN document." preferredStyle: UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = (UITextField *)alert.textFields[0];
        [self createFileNamed:textField.text];
    }];
    [alert addAction:cancelAction];
    [alert addAction:createAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)createFileNamed:(NSString *)fileName {
    NSString *trimmedFileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedFileName.length > 0) {
        NSString *targetName = [NSString stringWithFormat:@"%@.pgn", trimmedFileName];
        NSURL *saveUrl = [self urlForFilename:targetName];
        //NSLog(@"%@", saveUrl);
        pgnFileDocument = [[PgnFileDocument alloc] initWithFileURL:saveUrl];
        [pgnFileDocument saveToURL:saveUrl forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                //NSLog(@"Documento salvato in cloud");
            }
        }];
    }
}

- (NSURL *)urlForFilename:(NSString *)filename {
    // be sure to insert "Documents" into the path
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL *pathURL = [baseURL URLByAppendingPathComponent:@"Documents"];
    NSURL *destinationURL = [pathURL URLByAppendingPathComponent:filename];
    return destinationURL;
}

- (NSURL *)urlCloud {
    // be sure to insert "Documents" into the path
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL *pathURL = [baseURL URLByAppendingPathComponent:@"Documents"];
    return pathURL;
}

- (NSURL *)metadataUrlForFilename:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *localPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Documents"];
    localPath = [localPath stringByAppendingPathComponent:@"iCloudMetadata"];
    NSString *metadataPath = [localPath stringByAppendingPathComponent:filename];
    NSURL *metadataUrl = [[NSURL alloc] initFileURLWithPath:metadataPath];
    return metadataUrl;
}


#pragma mark iCloud Query

- (void) refresh {
    
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
    
    [self startQuery];
}

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

- (void)stopQuery {
    
    if (_query) {
        
        //NSLog(@"No longer watching iCloud dir...");
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:nil];
        [_query stopQuery];
        _query = nil;
    }
}

- (void) startQuery {
    
    [self stopQuery];
    
    _query = [self documentQuery];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processICloudFiles:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processICloudFiles:) name:NSMetadataQueryDidUpdateNotification object:nil];
    
    [_query startQuery];
}


- (void) processICloudFiles:(NSNotification *)notification {
    
    [_query disableUpdates];
    
    [_iCloudURLs removeAllObjects];
    [listPgnDatabase removeAllObjects];
    NSArray *queryResults = [_query results];
    
    /*
    NSArray *queryResults = [_query.results sortedArrayUsingComparator:
                        ^NSComparisonResult(id obj1, id obj2) {
                            NSMetadataItem *item1 = obj1;
                            NSMetadataItem *item2 = obj2;
                            return [[item2 valueForAttribute:NSMetadataItemFSCreationDateKey] compare: [item1 valueForAttribute:NSMetadataItemFSCreationDateKey]];
                        }];
    */
    
    
    
    for (NSMetadataItem *result in queryResults) {
        NSURL *fileURL = [result valueForAttribute:NSMetadataItemURLKey];
        //NSNumber *aBool = nil;
        
        // Don't include hidden files
        //[fileURL getResourceValue:&aBool forKey:NSURLIsHiddenKey error:nil];
        //if (aBool && ![aBool boolValue]) {
            [_iCloudURLs addObject:fileURL];
        //}
    }
    
    
    for (NSURL *url in _iCloudURLs) {
        //CFRunLoopRun();
        //PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:url];
        //[pfd openWithCompletionHandler:^(BOOL success) {
            //if (success) {
                //CFRunLoopStop(CFRunLoopGetCurrent());
            //}
        //}];
        [listPgnDatabase addObject:[url path]];
    }
    
    [listPgnDatabase sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    [self.tableView reloadData];
    
    
    /*
    
    if ([self iCloudOn]) {
        //NSLog(@"ICloud ON");
        //NSLog(@"Qui bisogna rimuovere gli eventuali file eliminati");
        NSArray *tempPgnFile = [listPgnFile copy];
        for (NSString *pgnFile in tempPgnFile) {
            NSString *datFile = [pgnFile stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"];
            NSURL *urlFile = [self urlForFilename:datFile];
            //NSLog(@"Devo vedere se esiste %@", urlFile);
            if (![_iCloudURLs containsObject:urlFile]) {
                [self removeDocumentAtUrl:urlFile];
                NSInteger index = [listPgnFile indexOfObject:pgnFile];
                [listPgnFile removeObject:pgnFile];
                [listPgnPath removeObjectAtIndex:index];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                
                //NSURL *metadataUrl = [self metadataUrlForFilename:pgnFile];
                //[self removeDocumentAtUrl:metadataUrl];
                
            }
        }
        

        
        // Add new files
        for (NSURL *fileURL in _iCloudURLs) {
            [self loadDocumentAtUrl:fileURL];
        }
    }
    else {
        //NSLog(@"iCloud OFF");
    }
    */
     
     
    [_query enableUpdates];
}

/*
- (void) removeMetadataDatabase {
    NSArray *localDatabase = [pgnDbManager listPgnFileAndDirectoryAtPath:localCloudPath];
    NSError *error = nil;
    for (NSString *ldb in localDatabase) {
        NSLog(@"?????????????????????????????  %@", ldb);
        if ([[NSFileManager defaultManager] fileExistsAtPath:ldb]) {
            [[NSFileManager defaultManager] removeItemAtPath:ldb error:&error];
        }
    }
}
*/

/*
- (void) loadDocumentAtUrl:(NSURL *)fileURL {
    PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:fileURL];
    
    if (!pfd) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"PFD NULL" message:@"PfdFileDocument NULL" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    NSLog(@"MI BLOCCO IN LOADDOCUMENT AT URL");
    [pfd openWithCompletionHandler:^(BOOL success) {
        if (!success) {
            NSLog(@"Failed to open %@", fileURL);
            return;
        }
        //PgnFileInfo *pfi = [NSKeyedUnarchiver unarchiveObjectWithFile:fileURL.path];
        [pfd.pgnFileInfo setIsInCloud:YES];
        //NSMutableArray *allGames = [pfd.pgnFileInfo getAllGamesAndTags];
        //NSLog(@"Il database contiene %lu partite", (unsigned long)allGames.count);
        //NSLog(@"PATH: %@", pfd.pgnFileInfo.savePath);
        //NSLog(@"NAME: %@", pfd.pgnFileInfo.fileName);
        //NSLog(@">>>>>>LOCAL CLOUD PATH:%@", pfd.pgnFileInfo.localCloudPath);
        
        //NSString *localCloudPathFinal = [localCloudPath stringByAppendingPathComponent:pfd.pgnFileInfo.fileName];
        //NSLog(@"*******FINAL LOCAL PATH:%@", localCloudPathFinal);
        //[pfd.pgnFileInfo setIsInCloud:YES];
        //[pfd.pgnFileInfo setLocalCloudPath:localCloudPathFinal];
        //[pfd.pgnFileInfo salvaTutteLePartite];
        
        //NSLog(@"STO PER CHIUDERE");
        [pfd closeWithCompletionHandler:^(BOOL success) {
            if (!success) {
                //NSLog(@"Failed to close %@", fileURL);
                // Continue anyway...
            }
            // Add to the list of files on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self aggiornaLista:pfd.pgnFileInfo];
            });
        }];
        
    }];
}
*/

- (void) removeDocumentAtUrl:(NSURL *)fileURL {
    
    [_query disableUpdates];
    
    // Wrap in file coordinator
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [fileCoordinator coordinateWritingItemAtURL:fileURL
                                            options:NSFileCoordinatorWritingForDeleting
                                              error:nil
                                         byAccessor:^(NSURL* writingURL) {
                                             // Simple delete to start
                                             NSFileManager* fileManager = [[NSFileManager alloc] init];
                                             [fileManager removeItemAtURL:fileURL error:nil];
                                             [_query enableUpdates];
                                         }];
    });
}

/*
- (void) aggiornaLista:(PgnFileInfo *)pfi {
    if (!listPgnFile) {
        listPgnFile = [[NSMutableArray alloc] init];
        listPgnPath = [[NSMutableArray alloc] init];
    }
    
    NSString *numGame = [NSString stringWithFormat:@"%@ games", [pfi numberOfGames]];
    
    if (![listPgnFile containsObject:[pfi fileName]]) {
        [listPgnFile addObject:[pfi fileName]];
        [listPgnPath addObject:numGame];
        //[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(listPgnFile.count - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        [listPgnFile sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [self.tableView reloadData];
        
    }
}
*/

- (void)updateUbiquitousDocuments:(NSNotification *)notification {
    
    //NSLog(@"updateUbiquitousDocuments, results = %@", _query.results);
    
    /*
    NSArray *results = [_query.results sortedArrayUsingComparator:
                        ^NSComparisonResult(id obj1, id obj2) {
                            NSMetadataItem *item1 = obj1;
                            NSMetadataItem *item2 = obj2;
                            return [[item2 valueForAttribute:NSMetadataItemFSCreationDateKey] compare: [item1 valueForAttribute:NSMetadataItemFSCreationDateKey]];
                        }];*/
    
    //for (NSMetadataItem *item in results) {
        //NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        //[self.documentURLs addObject:url];
        //[(NSMutableArray *)_documentFilenames addObject:[url lastPathComponent]];
        //NSString *database = [url lastPathComponent];
        
        
        //if (!listPgnFile) {
        //    listPgnFile = [[NSMutableArray alloc] init];
        //    listPgnPath = [[NSMutableArray alloc] init];
        //}
        
        //[listPgnFile addObject:database];
        
        
        //NSLog(@"%@", localCloudPath);
        
        //NSString *localFile = [localCloudPath stringByAppendingPathComponent:database];
        
        //NSLog(@"%@", localFile);
        
        //NSURL *urlLocalFile = [[NSURL alloc] initFileURLWithPath:localFile];
        
        //NSLog(@"LOCAL FILE:%@", urlLocalFile);
        //NSLog(@"URL:%@", url);
        
        
        //if (![listPgnFile containsObject:database]) {
        //     [listPgnFile addObject:database];
        //}
        
        //if (![listPgnPath containsObject:localFile]) {
            //[listPgnPath addObject:localFile];
        //}
        
       
        
        
        //BOOL copiato = [pgnDbManager copyDatabase:[url path] :localFile];
        
        //if (copiato) {
            //NSLog(@"File %@ copiato dal cloud in locale", database);
        //}
        //else {
            //NSLog(@"File %@ non copiato dal cloud in locale", database);
        //}
        
        
        
        //NSString *pgnLocalPath = [localFile stringByReplacingOccurrencesOfString:@".dat" withString:@".pgn"];
        //NSLog(@"PGN LOCAL PATH = %@", pgnLocalPath);
        //NSURL *pgnLocalUrl = [[NSURL alloc] initFileURLWithPath:pgnLocalPath];
        //NSLog(@"PGN LOCAL URL = %@", pgnLocalUrl);
        
        
        /*
        
        PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:urlLocalFile];
        [pfd openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"Database OK");
                PgnFileInfo *pfi = [NSKeyedUnarchiver unarchiveObjectWithFile:urlLocalFile.path];
                NSMutableArray *allGames = [pfi getAllGamesAndTags];
                for (NSString *game in allGames) {
                    //NSLog(@"%@", game);
                }
                [pfi setPath:[pgnLocalUrl path]];
                [pfi saveAllGamesAndTags:allGames];
                [listPgnFile addObject:[pgnLocalUrl lastPathComponent]];
                 [self.tableView reloadData];
            }
            else {
                NSLog(@"DATABASE KO");
            }
        }];
        */

        /*
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error;
        BOOL removed = [fm removeItemAtURL:url error:&error];
        if (removed) {
            NSLog(@"File %@ removed from cloud", database);
        }
        else {
            NSLog(@"File not removed: %@", error);
        }*/
    //}
    
    //[self.tableView reloadData];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (listPgnDatabase) {
        return listPgnDatabase.count;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
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

/*
- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *thfv = (UITableViewHeaderFooterView *)view;
        thfv.textLabel.textColor = [UIColor blackColor];
        thfv.contentView.backgroundColor = [UIColor whiteColor];
        thfv.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:10.0];
    }
}
*/

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
    
    NSString *fileData = [pgnDbManager getCreationInfo:[listPgnDatabase objectAtIndex:indexPath.row]];
    
    //NSLog(@"FILEDATA = %@", fileData);
    
    cell.detailTextLabel.text = fileData;
    
    
    /*
    NSString *pgnFile = [listPgnFile objectAtIndex:indexPath.row];
    NSString *datFile = [pgnFile stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"];
    NSString *pgnFilePath = [[self urlForFilename:datFile] path];
    
    NSString *fileData = [pgnDbManager getCreationInfo:pgnFilePath];
    
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.textLabel.text = pgnFile;
    cell.detailTextLabel.text = fileData;
    */
    
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
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //NSString *pgnFile = [[listPgnDatabase objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"];
        //NSLog(@"%@", pgnFile);
        //NSURL *pgnUrl = [_iCloudURLs objectAtIndex:indexPath.row];
        //NSLog(@"%@", pgnUrl);
        
        NSURL *selectedUrl = [[NSURL alloc] initFileURLWithPath:[listPgnDatabase objectAtIndex:indexPath.row]];
        
        //NSLog(@">>>>>>>>>>>>>>>>>       %@", selectedUrl);
        
        [self removeDocumentAtUrl:selectedUrl];
        
        //NSString *destLocal = [localCloudPath stringByAppendingPathComponent:[listPgnFile objectAtIndex:indexPath.row]];
        //NSURL *localUrl = [[NSURL alloc] initFileURLWithPath:destLocal];
        
        //NSLog(@"§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§     %@", localUrl);
        //[self removeDocumentAtUrl:localUrl];
        
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
    //NSString *item = [listPgnFile objectAtIndex:indexPath.row];
    //NSString *documentPath = [_actualPath stringByAppendingPathComponent:item];
    //NSURL *urlPath = [NSURL fileURLWithPath:documentPath];
    
    
    if (self.tableView.isEditing) {
        fileSelezionatiDaEliminareCopiareSpostare = [tableView indexPathsForSelectedRows];
        return;
    }
    
    
    [self performSelector: @selector(deselect:) withObject: tableView afterDelay: 0.1];
    
    
    NSString *pgnFileSelected = [listPgnDatabase objectAtIndex:indexPath.row];
    NSURL *pgnUrlSelected = [[NSURL alloc] initFileURLWithPath:pgnFileSelected];
    
    /*
    PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:pgnUrlSelected];
    [pfd openWithCompletionHandler:^(BOOL success) {
        if (success) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
            PgnFileInfoTableViewController *pitvc = [sb instantiateViewControllerWithIdentifier:@"PgnFileInfoTable"];
            [pitvc setPgnFileDoc:pfd];
            [self.navigationController pushViewController:pitvc animated:YES];
        }
    }];
    */
    
    NSString *fileName = [[[listPgnDatabase objectAtIndex:indexPath.row] lastPathComponent] stringByReplacingOccurrencesOfString:@".dat" withString:@".pgn"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = [UtilToView getSizeOfMBProgress];
    hud.labelText = @"Loading ...";
    hud.detailsLabelText = fileName;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:pgnUrlSelected];
        [pfd openWithCompletionHandler:^(BOOL success) {
            if (success) {
                //pfi = [pfd pgnFileInfo];
                // Do something...
                //BOOL salvato = [NSKeyedArchiver archiveRootObject:pfi toFile:pfi.savePath];
                //if (salvato) {
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
                PgnFileInfoTableViewController *pitvc = [sb instantiateViewControllerWithIdentifier:@"PgnFileInfoTable"];
                [pitvc setPgnFileDoc:pfd];
                [self.navigationController pushViewController:pitvc animated:YES];
                
                if (IS_PHONE) {
                    if (IS_IOS_7) {
                        self.navigationItem.title = @"";
                    }
                    else {
                        self.navigationItem.title = NSLocalizedString(@"BACK", nil);
                    }
                }
                //}
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        }];
    });
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        fileSelezionatiDaEliminareCopiareSpostare = [tableView indexPathsForSelectedRows];
        return;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForSwipeAccessoryButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"COPY", nil);
}

-(void)tableView:(UITableView *)tableView swipeAccessoryButtonPushedForRowAtIndexPath:(NSIndexPath *)indexPath {
    fileSelezionatiDaEliminareCopiareSpostare = [NSArray arrayWithObject:indexPath];
    
    //NSString *item = [listPgnDatabase objectAtIndex:indexPath.row];
    //NSURL *url = [[NSURL alloc] initFileURLWithPath:item];
    //NSError *error = nil;
    //NSURL *downloadUrl = [[NSFileManager defaultManager] URLForPublishingUbiquitousItemAtURL:url expirationDate:nil error:&error];
    //NSLog(@"%@", downloadUrl);
    //if (error) {
    //    NSLog(@"%@", error.localizedDescription);
    //}
    
    [self copyDatabase];
}

- (void)deselect:(UITableView *)tableView {
    [tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow] animated: YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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
        //NSLog(@"Devo copiare %lu database", (unsigned long)fileSelezionatiDaEliminareCopiareSpostare.count);
        //[self manageDatabase:@"copiare"];
        [self copyDatabase];
    }
    else if ([title isEqualToString:NSLocalizedString(@"MOVE_DB", nil)]) {
        //NSLog(@"Devo spostare %lu database", (unsigned long)fileSelezionatiDaEliminareCopiareSpostare.count);
        //[self manageDatabase:@"spostare"];
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

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:NSLocalizedString(@"NO", nil)]) {
            return;
        }
        [self deleteDatabase];
    }
    else if (alertView.tag == 200) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:NSLocalizedString(@"YES", nil)]) {
            [settingManager setICloudOn:YES];
            iCloudOn = YES;
            [self refresh];
        }
    }
    return;
}

- (void) edit {
    if (![self.tableView isEditing]) {
        self.tableView.allowsMultipleSelectionDuringEditing = YES;
        //[self.tableView setValue:UIColorFromRGB(0x4CE466) forKey:@"multiselectCheckmarkColor"];
        [self.tableView setValue:[UIColor blueColor] forKey:@"multiselectCheckmarkColor"];
        [self.tableView setEditing:YES animated:YES];
    }
    else {
        [self.tableView setEditing:NO animated:YES];
    }
}

- (void) deleteDatabase {
    for (NSIndexPath *indexPath in fileSelezionatiDaEliminareCopiareSpostare) {
        NSString *pgnFile = [listPgnDatabase objectAtIndex:indexPath.row];
        NSString *datFile = [pgnFile stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"];
        NSURL *iCloudUrl = [self findICloudUrlByDatabase:datFile];
        if (iCloudUrl) {
            NSLog(@"%@", datFile);
            NSLog(@"%@", iCloudUrl);
            [self removeDocumentAtUrl:iCloudUrl];
            
            //NSString *destLocal = [localCloudPath stringByAppendingPathComponent:pgnFile];
            //NSURL *localUrl = [[NSURL alloc] initFileURLWithPath:destLocal];
            
            //NSLog(@"§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§     %@", localUrl);
            //[self removeDocumentAtUrl:localUrl];
            
            //[listPgnFile removeObjectAtIndex:indexPath.row];
            //[listPgnFile removeObject:pgnFile];
            //[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [self.tableView reloadData];
    fileSelezionatiDaEliminareCopiareSpostare = nil;
}

- (void) copyDatabase {
    CopyFromCloudToPgnDatabaseTableViewController *cpdtvc = [[CopyFromCloudToPgnDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [cpdtvc setActualPath:nil];
    cpdtvc.delegate = self;
    
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
    cpdtvc.delegate = self;
    
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

/*
- (void) manageDatabase:(NSString *)azione {
    //for (NSIndexPath *indexPath in fileSelezionatiDaEliminareCopiareSpostare) {
        //NSString *database = [listPgnFile objectAtIndex:indexPath.row];
        //NSLog(@"Devo %@: %@", azione, database);
    //}
}
*/

- (NSURL *) findICloudUrlByDatabase:(NSString *)datFile {
    for (NSURL *url in _iCloudURLs) {
        if ([[url path] hasSuffix:datFile]) {
            return url;
        }
    }
    return nil;
}

#pragma mark Implementazione Metodo Delegate di MoveFromCloudToPgnDatabaseTableViewController

- (void) moveDatabaseFromCloud:(NSString *)database {
    
    NSString *datFile = [database stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"];
    NSURL *iCloudUrl = [self findICloudUrlByDatabase:datFile];
    if (iCloudUrl) {
        NSLog(@"%@", iCloudUrl);
        [self removeDocumentAtUrl:iCloudUrl];
    }
}



#pragma mark Helpers

- (BOOL)iCloudOn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudOn"];
}

#pragma mark CopyFromCloudToPgnDatabaseTableViewController delegate

- (void) aggiornaDopoAverCopiato {
    [self.tableView reloadData];
}

@end
