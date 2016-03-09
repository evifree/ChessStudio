//
//  CopyPgnDatabaseTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 03/06/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "CopyFromCloudToPgnDatabaseTableViewController.h"
#import "PgnDbManager.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"
#import "PgnFileDocument.h"

@interface CopyFromCloudToPgnDatabaseTableViewController () {

    PgnDbManager *pgnDbManager;
    NSArray *listFile;
    
    
    NSFileManager *fileManager;
    
    
    BOOL fileHasToBeOverwrite;
    
    NSString *fileToCopyDestinationPath;
    NSString *fileToCopySourcePath;
}

@end

@implementation CopyFromCloudToPgnDatabaseTableViewController

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
    UIBarButtonItem *copyButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"COPY_DB", nil) style:UIBarButtonItemStylePlain target:self action:@selector(copyButtonPressed:)];
    
    
    //UIImage *buttonImage = [UIImage imageNamed:@"ChessFolder.png"];
    //UIBarButtonItem *cloudButtonItem = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStylePlain target:self action:@selector(copiaDatabaseToCloud:)];
    
    
    
    
    NSMutableArray *items;
    
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    //NSLog(@"PATH:%@", _actualPath);
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    if (!_actualPath) {
        self.navigationItem.title = NSLocalizedString(@"COPY_DB_FROM_CLOUD", nil);
        items = [[NSMutableArray alloc] init];
        listFile = [NSArray arrayWithObjects:@"Chess Studio Database", nil];
    }
    else {
        
        if ([_actualPath isEqualToString:documentsPath]) {
            self.navigationItem.title = @"Chess Studio Database";
        }
        else {
            self.navigationItem.title = [_actualPath lastPathComponent];
        }
        items = [NSMutableArray arrayWithObjects:nuovaCartellaButton, flexibleItem, copyButton, nil];
        pgnDbManager = [PgnDbManager sharedPgnDbManager];
        listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
        
        NSMutableString *moveTitle = [[NSMutableString alloc] init];
        [moveTitle appendString:NSLocalizedString(@"COPY", nil)];
        [moveTitle appendString:@" "];
        [moveTitle appendFormat:@"%lu", (unsigned long)_databasesDaCopiare.count];
        [moveTitle appendString:@" "];
        if (_databasesDaCopiare.count == 1) {
            [moveTitle appendString:@"database"];
        }
        else {
            [moveTitle appendString:@"databases"];
        }
        //[moveTitle appendString:NSLocalizedString(@"HERE", nil)];
        [copyButton setTitle:moveTitle];
        
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
    NSLog(@"VIEW CONTROLLERS:%lu", (unsigned long)viewControllers.count);
    if (viewControllers.count == 1) {
        _actualPath = nil;
    }
    NSLog(@"PATH:%@", _actualPath);
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void) newDirectoryButtonPressed:(id)sender {
    UIAlertView *newDirectoryAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
    newDirectoryAlertView.tag = 1;
    newDirectoryAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newDirectoryAlertView show];
}

- (void) copyButtonPressed:(id)sender {
    
    if ([self devoCopiareSuCloud]) {
        //[self copyDatabaseToCloud:nil];
    }
    else {
        [self verifyCopyDatabaseToDocuments2];
    }
    /*
    for (NSString *db in _databasesDaCopiare) {
        fileToCopySourcePath = db;
        fileToCopyDestinationPath = [_actualPath stringByAppendingPathComponent:[db lastPathComponent]];
        if ([fileManager fileExistsAtPath:fileToCopyDestinationPath isDirectory:NO]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:[db lastPathComponent] message:[db lastPathComponent] delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
            av.tag = 200;
            [av show];
        }
        else {
            NSError *error;
            [fileManager copyItemAtPath:fileToCopySourcePath toPath:fileToCopyDestinationPath error:&error];
            listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
            [self.tableView reloadData];
            //[_delegate aggiornaDopoAverCopiato];
        }
    }*/
    
    
    //return;
    
    
    /*
    for (NSString *db in _databasesDaCopiare) {
        NSString *destPath = [_actualPath stringByAppendingPathComponent:[db lastPathComponent]];
        if ([pgnDbManager existDatabaseAtPath:destPath]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"EXISTING_DATABASE", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
    }
    for (NSString *db in _databasesDaCopiare) {
        NSString *destPath = [_actualPath stringByAppendingPathComponent:[db lastPathComponent]];
        [pgnDbManager copyDatabase:db :destPath];
    }
    listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
    [self.tableView reloadData];
    //[_delegate aggiornaDopoAverCopiato];
    */
}


/*
- (void) copyDatabaseToCloud:(id)sender {
    for (NSString *db in _databasesDaCopiare) {
        
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

- (void) doneButtonPressed:(id)sender {
    //[_delegate aggiornaDopoAverCopiato];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) verifyCopyDatabaseToDocuments {
    for (NSString *db in _databasesDaCopiare) {
        fileToCopySourcePath = [db stringByReplacingOccurrencesOfString:@".pgn" withString:@".dat"];
        NSURL *sourceUrl = [self urlForSaveCloud:fileToCopySourcePath];
        NSLog(@"%@", fileToCopySourcePath);
        fileToCopyDestinationPath = [_actualPath stringByAppendingPathComponent:[db lastPathComponent]];
        NSLog(@"Destination:%@", fileToCopyDestinationPath);
        if ([fileManager fileExistsAtPath:fileToCopyDestinationPath isDirectory:NO]) {
            //NSString *title = @"Database esistente in Documents";
            NSString *title = NSLocalizedString(@"EXISTING_DATABASE", nil);
            //NSString *msg = [NSString stringWithFormat:@"Il database %@ è già presente in cloud. Vuoi sovrascriverlo?", [db lastPathComponent]];
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"DATABASE_EXISTING_DOCUMENTS", nil), [db lastPathComponent]];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OVERWRITE", nil), nil];
            av.tag = 200;
            [av show];
        }
        else {
            
            PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:sourceUrl];
            [pfd openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    [pfd.pgnFileInfo setIsInCloud:NO];
                    [pfd.pgnFileInfo setSavePath:fileToCopyDestinationPath];
                    [pfd.pgnFileInfo setPath:fileToCopyDestinationPath];
                    [pfd.pgnFileInfo salvaTutteLePartite];
                    NSLog(@"Database salvato con successo");
                    listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
                    [self.tableView reloadData];
                }
                else {
                    NSLog(@"Problema apertura database");
                }
            }];
        }
    }
}

- (void) verifyCopyDatabaseToDocuments2 {
    for (NSString *db in _databasesDaCopiare) {
        NSString *pgnDb = [[db lastPathComponent] stringByReplacingOccurrencesOfString:@".dat" withString:@".pgn"];
        fileToCopyDestinationPath = [_actualPath stringByAppendingPathComponent:pgnDb];
        NSLog(@"DESTINATION PATH = %@", fileToCopyDestinationPath);
        fileToCopySourcePath = db;
        NSURL *sourceUrl = [[NSURL alloc] initFileURLWithPath:fileToCopySourcePath];
        NSLog(@"SOURCE URL = %@", sourceUrl);
        if ([fileManager fileExistsAtPath:fileToCopyDestinationPath isDirectory:NO]) {
            //NSString *title = @"Database esistente in Documents";
            NSString *title = NSLocalizedString(@"EXISTING_DATABASE", nil);
            //NSString *msg = [NSString stringWithFormat:@"Il database %@ è già presente in cloud. Vuoi sovrascriverlo?", [db lastPathComponent]];
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"DATABASE_EXISTING_DOCUMENTS", nil), [db lastPathComponent]];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OVERWRITE", nil), nil];
            av.tag = 200;
            [av show];
            CFRunLoopRun();
        }
        else {
            PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:sourceUrl];
            [pfd openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    [pfd.pgnFileInfo setIsInCloud:NO];
                    [pfd.pgnFileInfo setSavePath:fileToCopyDestinationPath];
                    [pfd.pgnFileInfo setPath:fileToCopyDestinationPath];
                    [pfd.pgnFileInfo salvaTutteLePartite];
                    listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
                    [self.tableView reloadData];
                    [_delegate aggiornaDopoAverCopiato];
                }
                else {
                    NSLog(@"Problema apertura database %@", [db lastPathComponent]);
                }
            }];
        }
    }
}

- (BOOL) devoCopiareSuCloud {
    
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

- (BOOL) isICloudDirectory {
    if (_actualPath) {
        if ([_actualPath rangeOfString:@"Mobile Documents"].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
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
            
            NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:newPath error:nil];
            NSNumber *fileByteSize = [attr objectForKey:NSFileSize];
            long dimensioniFile = fileByteSize.longLongValue;
            NSString *dimFormattate = [NSByteCountFormatter stringFromByteCount:dimensioniFile countStyle:NSByteCountFormatterCountStyleFile];
            cell.detailTextLabel.text = [[cell.detailTextLabel.text stringByAppendingString:@"  "] stringByAppendingString:dimFormattate];
            
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
            _actualPath = [[[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"iCloudMetadata"];
            nextPath = _actualPath;
        }
    }
    else {
        NSString *item = [listFile objectAtIndex:indexPath.row];
        nextPath = [_actualPath stringByAppendingPathComponent:[item lastPathComponent]];
    }
    
    
    CopyFromCloudToPgnDatabaseTableViewController *dfctvc = [[CopyFromCloudToPgnDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    NSLog(@"NextPath = %@", nextPath);
    [dfctvc setActualPath:nextPath];
    [dfctvc setDatabasesDaCopiare:_databasesDaCopiare];
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
            NSLog(@"SOURCE:%@", fileToCopySourcePath);
            NSLog(@"DEST:%@", fileToCopyDestinationPath);
            NSURL *sourceUrl = [[NSURL alloc] initFileURLWithPath:fileToCopySourcePath];
            
            PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:sourceUrl];
            [pfd openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    [pfd.pgnFileInfo setIsInCloud:NO];
                    [pfd.pgnFileInfo setSavePath:fileToCopyDestinationPath];
                    [pfd.pgnFileInfo setPath:fileToCopyDestinationPath];
                    [pfd.pgnFileInfo salvaTutteLePartite];
                    NSLog(@"Database salvato con successo");
                    listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
                    [self.tableView reloadData];
                    [_delegate aggiornaDopoAverCopiato];
                    CFRunLoopStop(CFRunLoopGetCurrent());
                }
                else {
                    NSLog(@"Problema apertura database");
                    CFRunLoopStop(CFRunLoopGetCurrent());
                }
            }];
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

@end
