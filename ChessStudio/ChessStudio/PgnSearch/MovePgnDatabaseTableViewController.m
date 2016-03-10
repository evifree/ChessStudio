//
//  CopyPgnDatabaseTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 03/06/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "MovePgnDatabaseTableViewController.h"
#import "PgnDbManager.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "PgnFileDocument.h"

@interface MovePgnDatabaseTableViewController () {

    PgnDbManager *pgnDbManager;
    NSArray *listFile;
    
    
    NSFileManager *fileManager;
    
    
    BOOL fileHasToBeOverwrite;
    
    NSString *fileToMoveDestinationPath;
    NSString *fileToMoveSourcePath;
    
    BOOL thereIsAFolderToCopy;
}

@end

@implementation MovePgnDatabaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    pgnDbManager = [PgnDbManager sharedPgnDbManager];
    
    fileManager = [NSFileManager defaultManager];
    [fileManager setDelegate:self];
    fileHasToBeOverwrite = NO;
    
    self.navigationController.toolbarHidden = NO;
    
    
    
    
   
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *nuovaCartellaButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil) style:UIBarButtonItemStylePlain target:self action:@selector(newDirectoryButtonPressed:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    UIBarButtonItem *moveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MOVE_DB", nil) style:UIBarButtonItemStylePlain target:self action:@selector(moveButtonPressed:)];
    
    
    //UIImage *buttonImage = [UIImage imageNamed:@"ChessFolder.png"];
    //UIBarButtonItem *cloudButtonItem = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStylePlain target:self action:@selector(copiaDatabaseToCloud:)];
    
    
    
    
    NSMutableArray *items;
    
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    pgnDbManager = [PgnDbManager sharedPgnDbManager];
    
    thereIsAFolderToCopy = NO;
    for (NSString *path in _databasesDaSpostare) {
        if ([pgnDbManager isDirectoryAtPath:path]) {
            thereIsAFolderToCopy = YES;
            break;
        }
    }
    
    NSLog(@"PATH:%@", _actualPath);
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    if (!_actualPath) {
        self.navigationItem.title = NSLocalizedString(@"MOVE_DB", nil);
        items = [[NSMutableArray alloc] init];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            if (thereIsAFolderToCopy) {
                listFile = [NSArray arrayWithObjects:@"Chess Studio Database", nil];
            }
            else {
                if ([[NSFileManager defaultManager] ubiquityIdentityToken]) {
                    listFile = [NSArray arrayWithObjects:@"Chess Studio Database", @"iCloud", nil];
                }
                else {
                    listFile = [NSArray arrayWithObjects:@"Chess Studio Database", nil];
                }
            }
        }
        else {
            listFile = [NSArray arrayWithObjects:@"Chess Studio Database", nil];
        }
    }
    else {
        if ([_actualPath isEqualToString:documentsPath]) {
            self.navigationItem.title = @"Chess Studio Database";
        }
        else {
            self.navigationItem.title = [_actualPath lastPathComponent];
        }
        
        /*
        if ([[_actualPath lastPathComponent] isEqualToString:@"iCloudMetadata"]) {
            self.navigationItem.title = @"Cloud";
            items = [NSArray arrayWithObjects:flexibleItem, moveButton, nil];
        }
        else {
            items = [NSArray arrayWithObjects:nuovaCartellaButton, flexibleItem, moveButton, nil];
        }*/
        
        
        if ([self isICloudDirectory]) {
            self.navigationItem.title = NSLocalizedString(@"ICLOUD", nil);
            items = [NSMutableArray arrayWithObjects:flexibleItem, moveButton, flexibleItem, nil];
            listFile = [pgnDbManager listOfCloudDatabaseAtPath:_actualPath];
        }
        else {
            items = [NSMutableArray arrayWithObjects:nuovaCartellaButton, flexibleItem, moveButton, nil];
            listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
        }
        
        //listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
        
        NSMutableString *moveTitle = [[NSMutableString alloc] init];
        [moveTitle appendString:NSLocalizedString(@"MOVE", nil)];
        [moveTitle appendString:@" "];
        [moveTitle appendFormat:@"%lu", (unsigned long)_databasesDaSpostare.count];
        [moveTitle appendString:@" "];
        if (_databasesDaSpostare.count == 1) {
            [moveTitle appendString:@"database"];
        }
        else {
            [moveTitle appendString:@"databases"];
        }
        //[moveTitle appendString:NSLocalizedString(@"HERE", nil)];
        [moveButton setTitle:moveTitle];
        
    }
    
    self.toolbarItems = items;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;
    //NSLog(@"VIEW CONTROLLERS:%lu", (unsigned long)viewControllers.count);
    if (viewControllers.count == 1) {
        _actualPath = nil;
    }
    //NSLog(@"PATH:%@", _actualPath);
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL) isICloudDirectory {
    if (_actualPath) {
        if ([_actualPath rangeOfString:@"Mobile Documents"].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}


- (void) newDirectoryButtonPressed:(id)sender {
    UIAlertView *newDirectoryAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
    newDirectoryAlertView.tag = 1;
    newDirectoryAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newDirectoryAlertView show];
}

- (void) moveButtonPressed:(id)sender {
    
    if ([self devoSpostareSuCloud]) {
        //NSLog(@"Devo copiare i file su iCloud");
        //[self moveDatabaseToCloud:nil];
        //NSLog(@"Ricarico _actualPath: %@", _actualPath);
        [self verifyMoveDatabaseToCloud];
    }
    else {
        [self verifyMoveDatabaseToDocuments];
        //[self moveDatabaseFromCloudToMain];
    }
    
    /*
    for (NSString *db in _databasesDaSpostare) {
        NSString *destPath = [_actualPath stringByAppendingPathComponent:[db lastPathComponent]];
        if ([pgnDbManager existDatabaseAtPath:destPath]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"EXISTING_DATABASE", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
    }
    for (NSString *db in _databasesDaSpostare) {
        NSString *destPath = [_actualPath stringByAppendingPathComponent:[db lastPathComponent]];
        //[pgnDbManager copyDatabase:db :destPath];
        [pgnDbManager moveDatabase:db :destPath];
    }
    //NSLog(@"Ricarico _actualPath: %@", _actualPath);
    listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
    [self.tableView reloadData];
    [_delegate aggiornaDopoAverCopiato];
    */
}

- (void) verifyMoveDatabaseToDocuments {
    for (NSString *db in _databasesDaSpostare) {
        fileToMoveSourcePath = db;
        fileToMoveDestinationPath = [_actualPath stringByAppendingPathComponent:[db lastPathComponent]];
        if ([fileManager fileExistsAtPath:fileToMoveDestinationPath isDirectory:NO]) {
            NSString *title = NSLocalizedString(@"EXISTING_DATABASE", nil);
            //NSString *msg = [NSString stringWithFormat:@"Il database %@ è già presente in cloud. Vuoi sovrascriverlo?", [db lastPathComponent]];
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"DATABASE_EXISTING_DOCUMENTS_MOVING", nil), [db lastPathComponent]];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OVERWRITE", nil), nil];
            av.tag = 200;
            [av show];
            CFRunLoopRun();
        }
        else {
            NSError *error;
            [fileManager moveItemAtPath:fileToMoveSourcePath toPath:fileToMoveDestinationPath error:&error];
            listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
            [self.tableView reloadData];
            [_delegate aggiornaDopoAverCopiato];
        }
    }
}

- (void) verifyMoveDatabaseToCloud {
    for (NSString *db in _databasesDaSpostare) {
        fileToMoveSourcePath = db;
        fileToMoveDestinationPath = [_actualPath stringByAppendingPathComponent:[[db lastPathComponent]stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"]];
        if ([fileManager fileExistsAtPath:fileToMoveDestinationPath isDirectory:NO]) {
            NSString *title = NSLocalizedString(@"EXISTING_DATABASE_CLOUD", nil);
            //NSString *msg = [NSString stringWithFormat:@"Il database %@ è già presente in cloud. Vuoi sovrascriverlo?", [db lastPathComponent]];
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"DATABASE_EXISTING_CLOUD_MOVING", nil), [db lastPathComponent]];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OVERWRITE", nil), nil];
            av.tag = 300;
            [av show];
            CFRunLoopRun();
        }
        else {
            NSLog(@"Il database %@ non esiste in cloud e deve essere salvato.", [db lastPathComponent]);
            [self moveDatabaseToCloud];
        }
    }
}

/*
- (void) moveDatabaseToCloud:(id)sender {
    for (NSString *db in _databasesDaSpostare) {
        
        //NSString *destPath = [_actualPath stringByAppendingPathComponent:[db lastPathComponent]];
        //NSLog(@"SOURCE PATH:%@", db);
        //NSLog(@"DEST PATH:%@", destPath);
        //NSLog(@"CLOUD PATH:%@", [self urlForSaveCloud:[db lastPathComponent]]);
        NSURL *urlSourcePath = [[NSURL alloc] initFileURLWithPath:db];
        
        if ([pgnDbManager isDirectoryAtPath:db]) {
            NSLog(@"%@ è una directory e devo saltarla per ora", db);
            
            continue;
            
            NSString *dirName = [db lastPathComponent];
            NSURL *dirUrl = [self urlForSaveCloud:dirName];
            NSLog(@"DIRECTORY DA CREARE SU ICLOUD:%@", dirUrl);
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:[dirUrl path]]) {
                NSError *dirCreationError = nil;
                BOOL directoryCreataCloud = [fileManager createDirectoryAtURL:dirUrl withIntermediateDirectories:YES attributes:nil error:&dirCreationError];
                if (directoryCreataCloud) {
                    NSLog(@"Directory %@ creata con successo", dirName);
                }
                else {
                    NSLog(@"Directory non creata:%@", dirCreationError);
                }
            }
            
            
            
            continue;
        }
        
        
        
        PgnFileDocument *pgnFileDocument = [[PgnFileDocument alloc] initWithFileURL:urlSourcePath];
        [pgnFileDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                PgnFileInfo *pgnFileInfo = [pgnFileDocument pgnFileInfo];
                [pgnFileInfo setIsInCloud:YES];
                BOOL salvato = [NSKeyedArchiver archiveRootObject:pgnFileInfo toFile:pgnFileInfo.savePath];
                if (salvato) {
                    
                    NSString *fileString = pgnFileInfo.savePath;
                    NSLog(@"FILESTRING = %@", fileString);
                    NSURL *urlCloud = [self urlForSaveCloud:[fileString lastPathComponent]];
                    //NSLog(@"CLOUD URL :%@", urlCloud);
                    
                    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:fileString];
                    NSURL *destURL = urlCloud;
                    
                    
                    NSLog(@"fileURL: %@", fileURL);
                    NSLog(@"destURL: %@", destURL);
                    
                    if ([[NSFileManager defaultManager] fileExistsAtPath:destURL.path]) {
                        NSLog(@"Il file %@ esiste nella dir destinazione", destURL.path);
                    }
                    else {
                        NSLog(@"A questo punto devo inviare il file su cloud");
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                            NSError * error;
                            BOOL moved = [[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:fileURL destinationURL:destURL error:&error];
                            if (moved) {
                                NSLog(@"Moved %@ to %@", fileURL, destURL);
                                //[self loadDocAtURL:destURL];
                                NSString *cloudMetadataPath = [_actualPath stringByAppendingPathComponent:[urlSourcePath lastPathComponent]];
                                NSLog(@"DEVO COPIARE %@", urlSourcePath.path);
                                NSLog(@"CLOUD METADATA: %@", cloudMetadataPath);
                                BOOL movedToCloudMetadata = [[NSFileManager defaultManager] moveItemAtPath:[urlSourcePath path] toPath:cloudMetadataPath error:&error];
                                if (movedToCloudMetadata) {
                                    NSLog(@"COPIATO FILE TO CLOUDMETADATA");
                                    listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
                                    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                                    if (_delegate) {
                                        [self performSelectorOnMainThread:@selector(aggiornaDelegate) withObject:nil waitUntilDone:YES];
                                    }
                                }
                                
                            } else {
                                NSLog(@"Failed to move %@ to %@: %@", fileURL, destURL, error.localizedDescription);
                            }
                        });
                    }
                }
                else {
                    NSLog(@"FILE NON SALVATO!");
                }
            }
            else {
                NSLog(@"DOCUMENTO NON APERTO!");
            }
        }];
    }
}
*/

- (void) moveDatabaseToCloud {
    NSURL *urlFileSource = [[NSURL alloc] initFileURLWithPath:fileToMoveSourcePath];
    NSString *fileDatToCopySourcePath = [fileToMoveSourcePath stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"];
    NSURL *urlFileDatSource = [[NSURL alloc] initFileURLWithPath:fileDatToCopySourcePath];
    PgnFileDocument *pgnFileDocument = [[PgnFileDocument alloc] initWithFileURL:urlFileSource];
    [pgnFileDocument openWithCompletionHandler:^(BOOL success) {
        if (success) {
            PgnFileInfo *pgnFileInfo = [pgnFileDocument pgnFileInfo];
            [pgnFileInfo setIsInCloud:YES];
            NSLog(@"DIRECTORY SAVE = %@", pgnFileInfo.savePath);
            BOOL salvatoFileDat = [NSKeyedArchiver archiveRootObject:pgnFileInfo toFile:pgnFileInfo.savePath];
            if (salvatoFileDat) {
                NSURL *iCloudUrl = [self urlForSaveCloud:[pgnFileInfo.savePath lastPathComponent]];
                NSError * errorCloud = nil;
                NSLog(@"CLOUD SOURCE:%@", urlFileDatSource);
                NSLog(@"CLOUD DEST:%@", iCloudUrl);
                //BOOL moved = [fileManager setUbiquitous:YES itemAtURL:urlFileDatSource destinationURL:iCloudUrl error:&errorCloud];
                BOOL moved = [fileManager moveItemAtURL:urlFileDatSource toURL:iCloudUrl error:&errorCloud];
                if (moved) {
                    NSLog(@"HO COPIATO CORRETTAMENTE IL FILE SU CLOUD");
                    listFile = [pgnDbManager listOfCloudDatabaseAtPath:_actualPath];
                    NSError *errorRemoving;
                    BOOL removed = [fileManager removeItemAtURL:urlFileSource error:&errorRemoving];
                    if (removed) {
                        NSLog(@"DATABASE %@ REMOVED:", urlFileSource.path);
                    }
                    else {
                        NSLog(@"ERROR REMOVING:%@", errorRemoving.localizedDescription);
                        NSLog(@"%@", urlFileSource.path);
                    }
                    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                    [_delegate aggiornaDopoAverCopiato];
                } else {
                    NSLog(@"Failed to move %@ to %@: %@", urlFileSource, iCloudUrl, errorCloud.localizedDescription);
                }
                
                
                
                /*
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    NSError * errorCloud = nil;
                    NSLog(@"CLOUD SOURCE:%@", urlFileDatSource);
                    NSLog(@"CLOUD DEST:%@", iCloudUrl);
                    BOOL moved = [fileManager setUbiquitous:YES itemAtURL:urlFileDatSource destinationURL:iCloudUrl error:&errorCloud];
                    if (moved) {
                        NSString *cloudMetadataPath = [_actualPath stringByAppendingPathComponent:[urlFileSource lastPathComponent]];
                        NSLog(@"DEVO COPIARE %@", urlFileSource.path);
                        NSLog(@"CLOUD METADATA: %@", cloudMetadataPath);
                        NSError *errorMetadata = nil;
                        BOOL copiedToCloudMetadata = [fileManager copyItemAtPath:[urlFileSource path] toPath:cloudMetadataPath error:&errorMetadata];
                        if (copiedToCloudMetadata) {
                            NSLog(@"COPIATO FILE TO CLOUDMETADATA");
                            listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
                            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                            NSError *errorRemove = nil;
                            [fileManager removeItemAtURL:urlFileSource error:&errorRemove];
                            if (!errorRemove) {
                                NSLog(@"Il database %@ è stato rimosso", urlFileSource);
                                NSObject *delegate1 = (NSObject *)_delegate;
                                [delegate1 performSelectorOnMainThread:@selector(aggiornaDopoAverCopiato) withObject:nil waitUntilDone:YES];
                            }
                            else {
                                NSLog(@"Non è stato possibile rimuovere il file %@ perchè %@", urlFileSource, errorRemove.description);
                            }
                        }
                        else {
                            NSLog(@"NON COPIATO FILE TO CLOUDMETADATA:%@", errorMetadata.localizedDescription);
                        }
                        
                    } else {
                        NSLog(@"Failed to move %@ to %@: %@", urlFileSource, iCloudUrl, errorCloud.localizedDescription);
                    }
                });*/
            }
        }
    }];
}

- (void) deleteDatabaseOnCloud {
    //NSURL *urlFileSource = [[NSURL alloc] initFileURLWithPath:fileToCopySourcePath];
    NSString *database = [fileToMoveSourcePath lastPathComponent];
    database = [database stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"];
    NSURL *iCloudUrl = [self urlForSaveCloud:database];
    NSLog(@"Devo eliminare %@", iCloudUrl);
    //NSString *cloudMetadataPath = [_actualPath stringByAppendingPathComponent:[fileToMoveSourcePath lastPathComponent]];
    //NSLog(@"Devo anche eliminare %@", cloudMetadataPath);
    NSError *errorCloud = nil;
    //NSError *errorMetaCloud = nil;
    //[fileManager evictUbiquitousItemAtURL:iCloudUrl error:&errorCloud];
    [fileManager removeItemAtURL:iCloudUrl error:&errorCloud];
    if (!errorCloud) {
        //[fileManager removeItemAtPath:cloudMetadataPath error:&errorMetaCloud];
        //if (errorMetaCloud) {
            //NSLog(@"ERROR DELETING METACLOUD = %@", errorMetaCloud.description);
        //}
    }
    else {
        NSLog(@"ERROR DELETING CLOUD = %@", errorCloud.description);
    }
    if (!errorCloud) {
        NSLog(@"OPERAZIONE ESEGUITA CON SUCCESSO");
    }
}

- (void) doneButtonPressed:(id)sender {
    //[_delegate aggiornaDopoAverCopiato];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) aggiornaDelegate {
    [_delegate aggiornaDopoAverCopiato];
}

- (BOOL) devoSpostareSuCloud {
    
    if ([self isICloudDirectory]) {
        return YES;
    }
    
    return NO;
    
    if (_actualPath) {
        if ([_actualPath hasSuffix:@"/Library/Application Support/Documents/iCloudMetadata"]) {
            return YES;
        }
        //if ([_actualPath containsString:@"/Library/Application Support/Documents/iCloudMetadata"]) {
        //    return YES;
        //}
    }
    return NO;
}

- (NSURL *)urlForSaveCloud:(NSString *)filename {
    // be sure to insert "Documents" into the path
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
    return listFile.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Copy PGN Database";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (IS_PHONE) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    // Configure the cell...
    
    if (!_actualPath) {
        cell.textLabel.text = [listFile objectAtIndex:indexPath.row];
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"ChessFolder.png"];
        }
        else if (indexPath.row == 1) {
            cell.imageView.image = [UIImage imageNamed:@"CloudFolder"];
        }
    }
    else {
        NSString *item = [[listFile objectAtIndex:indexPath.row] lastPathComponent];
        NSString *newPath = [_actualPath stringByAppendingPathComponent:item];
        if ([pgnDbManager isDirectoryAtPath:newPath]) {
            int numberOfItems = (int)[pgnDbManager numberOfItemsAtPath:newPath];
            cell.imageView.image = [UIImage imageNamed:@"ChessFolder.png"];
            NSMutableString *testo = [[NSMutableString alloc] initWithString:item];
            
            //NSLog(@"Inizio = %f   Larghezza = %f", cell.textLabel.frame.origin.x, cell.textLabel.frame.size.width);
            if (numberOfItems > 0) {
                [testo appendString:@" "];
                [testo appendFormat:@"(%d)", numberOfItems];
            }
            
            cell.textLabel.text = testo;
            
            NSString *data = [pgnDbManager getCreationInfo:newPath];
            cell.detailTextLabel.text = data;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.userInteractionEnabled = YES;
            cell.textLabel.enabled = YES;
            cell.detailTextLabel.enabled = YES;
            cell.imageView.alpha = 1.0;
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"PgnChess.png"];
            NSString *data = [pgnDbManager getCreationInfo:newPath];
            cell.textLabel.text = item;
            cell.detailTextLabel.text = data;
            
            if ([self isICloudDirectory]) {
                cell.imageView.image = [UIImage imageNamed:@"PgnChessIconCloud.png"];
                cell.textLabel.text = [item stringByReplacingOccurrencesOfString:@".dat" withString:@".pgn"];
            }
            else {
                cell.imageView.image = [UIImage imageNamed:@"PgnChessIcon.png"];
                NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:newPath error:nil];
                NSNumber *fileByteSize = [attr objectForKey:NSFileSize];
                long dimensioniFile = fileByteSize.longLongValue;
                NSString *dimFormattate = [NSByteCountFormatter stringFromByteCount:dimensioniFile countStyle:NSByteCountFormatterCountStyleFile];
                cell.detailTextLabel.text = [[cell.detailTextLabel.text stringByAppendingString:@"  "] stringByAppendingString:dimFormattate];
            }
            
            
            //NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:newPath error:nil];
            //NSNumber *fileByteSize = [attr objectForKey:NSFileSize];
            //long dimensioniFile = fileByteSize.longLongValue;
            //NSString *dimFormattate = [NSByteCountFormatter stringFromByteCount:dimensioniFile countStyle:NSByteCountFormatterCountStyleFile];
            //cell.detailTextLabel.text = [[cell.detailTextLabel.text stringByAppendingString:@"  "] stringByAppendingString:dimFormattate];
            
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            cell.userInteractionEnabled = NO;
            cell.textLabel.enabled = NO;
            cell.detailTextLabel.enabled = NO;
            cell.imageView.alpha = 0.5;
        }
    }
    

    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
    
    NSString *nextPath;
    
    if (!_actualPath) {
        
        if (indexPath.row == 0) {
            _actualPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            nextPath = _actualPath;
        }
        else if (indexPath.row == 1) {
            //_actualPath = [[[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"iCloudMetadata"];
            //nextPath = _actualPath;
            
            NSURL *cloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
            cloudURL = [cloudURL URLByAppendingPathComponent:@"Documents"];
            _actualPath = [cloudURL path];
            nextPath = _actualPath;
        }
    }
    else {
        NSString *item = [listFile objectAtIndex:indexPath.row];
        nextPath = [_actualPath stringByAppendingPathComponent:[item lastPathComponent]];
    }
    
    
    MovePgnDatabaseTableViewController *dfctvc = [[MovePgnDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    //NSLog(@"NextPath = %@", nextPath);
    [dfctvc setActualPath:nextPath];
    [dfctvc setDatabasesDaSpostare:_databasesDaSpostare];
    dfctvc.delegate = _delegate;
    [self.navigationController pushViewController:dfctvc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Implementazione metodi AlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        NSString *nome = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([title isEqualToString:@"OK"] && nome.length>0) {
            NSString *newPath = [_actualPath stringByAppendingPathComponent:nome];
            BOOL directoryCreata = [pgnDbManager createDirectory:newPath];
            if (directoryCreata) {
                listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
                [self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
            }
            else {
                UIAlertView *folderEsistenteAlertView =  [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"EXISTING_FOLDER", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [folderEsistenteAlertView show];
            }
        }
    }
    else if (alertView.tag == 200) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:NSLocalizedString(@"CANCEL", nil)]) {
            fileHasToBeOverwrite = NO;
            CFRunLoopStop(CFRunLoopGetCurrent());
        }
        else if ([title isEqualToString:NSLocalizedString(@"OVERWRITE", nil)]) {
            fileHasToBeOverwrite = YES;
            NSLog(@"SOURCE:%@", fileToMoveSourcePath);
            NSLog(@"DEST:%@", fileToMoveDestinationPath);
            NSError *errorRemove = nil;
            [fileManager removeItemAtPath:fileToMoveDestinationPath error:&errorRemove];
            if (!errorRemove) {
                NSError *errorMove = nil;
                [fileManager moveItemAtPath:fileToMoveSourcePath toPath:fileToMoveDestinationPath error:&errorMove];
                if (!errorMove) {
                    listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
                    [self.tableView reloadData];
                    [_delegate aggiornaDopoAverCopiato];
                }
                else {
                    NSLog(@"ERROR MOVE: %@", errorMove.localizedDescription);
                }
            }
            CFRunLoopStop(CFRunLoopGetCurrent());
        }
    }
    else if (alertView.tag == 300) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:NSLocalizedString(@"CANCEL", nil)]) {
            fileHasToBeOverwrite = NO;
            CFRunLoopStop(CFRunLoopGetCurrent());
        }
        else if ([title isEqualToString:NSLocalizedString(@"OVERWRITE", nil)]) {
            fileHasToBeOverwrite = YES;
            NSLog(@"SOURCE:%@", fileToMoveSourcePath);
            NSLog(@"DEST:%@", fileToMoveDestinationPath);
            [self deleteDatabaseOnCloud];
            [self moveDatabaseToCloud];
            CFRunLoopStop(CFRunLoopGetCurrent());
        }
    }
    
}

#pragma mark - Implementazione metodi NSFileManagerDelegate

- (BOOL) fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    NSLog(@"SHOULD PROCEED COPY");
    if ([error code] == NSFileWriteFileExistsError) {
        NSLog(@"Metodo delegate NSFileManager: se dico YES copio lo stesso");
        return YES;
    }
    return NO;
}

- (BOOL) fileManager:(NSFileManager *)fileManager shouldCopyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    NSLog(@"FILE MANAGER SHOULD COPY");
    return YES;
}

- (BOOL) fileManager:(NSFileManager *)fileManager shouldMoveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    NSLog(@"FILEMANAGER SHOULD MOVE ITEM AT PATH");
    return YES;
}


@end
