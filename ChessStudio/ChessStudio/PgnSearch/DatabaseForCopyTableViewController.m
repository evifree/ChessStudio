//
//  DatabaseForCopyTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 25/06/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "DatabaseForCopyTableViewController.h"
#import "PgnDbManager.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"

@interface DatabaseForCopyTableViewController () {
    
    PgnDbManager *pgnDbManager;
    PgnFileInfo *pgnFileInfo;
    NSArray *listFile;
    
    
    
    UIActionSheet *actionSheetMenu;
}

@end

@implementation DatabaseForCopyTableViewController

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
    
    //NSString *buttonTitle = NSLocalizedString(@"DONE", @"Fatto");
    //UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    //self.navigationItem.rightBarButtonItem = doneButtonItem;
    
    self.navigationController.toolbarHidden = NO;
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *nuovaCartellaButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil) style:UIBarButtonItemStylePlain target:self action:@selector(newDirectory)];
    UIBarButtonItem *nuovoDatabaseButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_DATABASE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(newDatabase)];
    //UIBarButtonItem *copyButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"COPY", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(copyButtonPressed)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)];
    
    NSArray *items = [NSArray arrayWithObjects:nuovaCartellaButton,flexibleItem, nuovoDatabaseButton, flexibleItem, doneButton, nil];
    self.toolbarItems = items;
    
    
    //NSMutableString *copyTitle = [[NSMutableString alloc] init];
    //[copyTitle appendString:NSLocalizedString(@"COPY", nil)];
    //[copyTitle appendString:@" "];
    //[copyTitle appendFormat:@"%d", _gamesToCopyArray.count];
    //[copyTitle appendString:@" "];
    //if (_gamesToCopyArray.count == 1) {
    //    [copyTitle appendString:@"game"];
    //}
    //else {
    //    [copyTitle appendString:@"games"];
    //}
    //[copyTitle appendString:NSLocalizedString(@"HERE", nil)];
    //[copyButton setTitle:copyTitle];
    
    //UIBarButtonItem *actionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    //self.navigationItem.rightBarButtonItem = actionButtonItem;
    
    if (!_actualPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _actualPath = [paths objectAtIndex:0];
        
        /*
         if (IS_PAD) {
         [self setNavigationTitlePad];
         }
         else {
         if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
         [self setNavigationTitlePhonePortrait];
         }
         else {
         [self setNavigationTitlePhoneLandscape];
         }
         }*/
    }
    else {
        self.navigationItem.title = [_actualPath lastPathComponent];
    }
    
    pgnDbManager = [PgnDbManager sharedPgnDbManager];
    //listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
    
    listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
    self.navigationItem.title = [_actualPath lastPathComponent];
    
    
    if (_partitaDaSalvare) {
        self.navigationItem.title = NSLocalizedString(@"MENU_SAVE_GAME_2", nil);
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) doneButtonPressed {
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listFile.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Copy";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (IS_PHONE) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    
    NSString *item = [[listFile objectAtIndex:indexPath.row] lastPathComponent];
    NSString *newPath = [_actualPath stringByAppendingPathComponent:item];
    if ([pgnDbManager isDirectoryAtPath:newPath]) {
        NSInteger numberOfItems = [pgnDbManager numberOfItemsAtPath:newPath];
        cell.imageView.image = [UIImage imageNamed:@"ChessFolder.png"];
        NSMutableString *testo = [[NSMutableString alloc] initWithString:item];
        
        //NSLog(@"Inizio = %f   Larghezza = %f", cell.textLabel.frame.origin.x, cell.textLabel.frame.size.width);
        if (numberOfItems > 0) {
            [testo appendString:@" "];
            [testo appendFormat:@"(%ld)", (long)numberOfItems];
        }
        
        cell.textLabel.text = testo;
        
        NSString *data = [pgnDbManager getCreationInfo:newPath];
        cell.detailTextLabel.text = data;
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"PgnChessIcon"];
        NSString *data = [pgnDbManager getCreationInfo:newPath];
        cell.textLabel.text = item;
        cell.detailTextLabel.text = data;
        
        
        NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:newPath error:nil];
        NSNumber *fileByteSize = [attr objectForKey:NSFileSize];
        float dimFileMb = fileByteSize.longLongValue/1048576.0;
        if (dimFileMb>=0) {
            NSNumber *fileSizeNumber = [NSNumber numberWithFloat:dimFileMb];
            NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
            numFormatter.roundingIncrement = [NSNumber numberWithDouble:0.1];
            numFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSString *dimString = [NSString stringWithFormat:@"%@", [numFormatter stringFromNumber:fileSizeNumber]];
            cell.detailTextLabel.text = [[[cell.detailTextLabel.text stringByAppendingString:@"  "] stringByAppendingString:dimString] stringByAppendingString:@" MB"];
        }
        
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    // Configure the cell...
    
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
    
    
    
    NSString *item = [listFile objectAtIndex:indexPath.row];
    
    if ([[_pgnFileDoc.pgnFileInfo getCompletePathAndName] isEqualToString:item]) {
        UIAlertView *noCopyAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"SAME_DATABASE_COPY", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noCopyAlertView show];
        return;
    }
    
    
    if ([pgnDbManager isPgnFile:item]) {
        
        
        NSString *documentPath = [_actualPath stringByAppendingPathComponent:[item lastPathComponent]];
        
        pgnFileInfo = [[PgnFileInfo alloc] initWithFilePath:documentPath];
        
        NSString *conferma;
        if (_partitaDaSalvare) {
            conferma = [NSString stringWithFormat:NSLocalizedString(@"CONFIRM_SAVE_GAME", nil), [item lastPathComponent]];
        }
        else {
            conferma = [NSString stringWithFormat:NSLocalizedString(@"CONFIRM_DATABASE_COPY", nil), _gamesToCopyArray.count, [item lastPathComponent]];
        }
        
        //NSString *conferma = [NSString stringWithFormat:NSLocalizedString(@"CONFIRM_DATABASE_COPY", nil), _gamesToCopyArray.count, [item lastPathComponent]];
        UIAlertView *confermaCopiaPartiteAlertView = [[UIAlertView alloc] initWithTitle:nil message:conferma delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
        confermaCopiaPartiteAlertView.tag = 10;
        [confermaCopiaPartiteAlertView show];
        return;
        
        
        
        
        /*
         MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
         hud.minSize = CGSizeMake(250, 150);
         hud.labelText = @"Loading ...";
         hud.detailsLabelText = item;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
         
         PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:urlPath];
         [pfd openWithCompletionHandler:^(BOOL success) {
         if (success) {
         //pfi = [pfd pgnFileInfo];
         // Do something...
         BOOL salvato = [NSKeyedArchiver archiveRootObject:pfi toFile:pfi.savePath];
         if (salvato) {
         NSLog(@"Database %@ salvato correttamente", pfi.fileName);
         UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
         PgnFileInfoTableViewController *pitvc = [sb instantiateViewControllerWithIdentifier:@"PgnFileInfoTable"];
         [pitvc setPgnFileDoc:pfd];
         [self.navigationController pushViewController:pitvc animated:YES];
         }
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         }
         }];
         });
         */
    }
    else {
        DatabaseForCopyTableViewController *dfctvc = [[DatabaseForCopyTableViewController alloc] initWithStyle:UITableViewStylePlain];
        NSString *nextPath = [_actualPath stringByAppendingPathComponent:[item lastPathComponent]];
        //NSLog(@"NextPath = %@", nextPath);
        [dfctvc setActualPath:nextPath];
        [dfctvc setPgnFileDoc:_pgnFileDoc];
        [dfctvc setGamesToCopyArray:_gamesToCopyArray];
        [dfctvc setPartitaDaSalvare:_partitaDaSalvare];
        [dfctvc setDelegate:_delegate];
        [self.navigationController pushViewController:dfctvc animated:YES];
    }
}

- (void) actionButtonPressed:(id)sender {
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
        cancelButton = NSLocalizedString(@"ACTIONSHEET_CANCEL", nil);
    }
    
    actionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_NEW_FOLDER", nil), NSLocalizedString(@"MENU_NEW_DATABASE", nil), NSLocalizedString(@"MENU_CLOSE", nil), nil];
    [actionSheetMenu showFromBarButtonItem:button animated:YES];
}

#pragma mark - Implementazione metodi ActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex<0) {
        return;
    }
    switch (buttonIndex) {
        case 0:
            [self newDirectory];
            break;
        case 1:
            [self newDatabase];
            break;
        case 2:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
}

- (void) newDirectory {
    UIAlertView *newDirectoryAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
    newDirectoryAlertView.tag = 0;
    newDirectoryAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newDirectoryAlertView show];
}

- (void) newDatabase {
    UIAlertView *newDatabaseAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_DATABASE", nil) message:NSLocalizedString(@"PGN_FORMAT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
    newDatabaseAlertView.tag = 1;
    newDatabaseAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newDatabaseAlertView show];
}


#pragma mark - Implementazione metodi AlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 10) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"OK"]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.minSize = [UtilToView getSizeOfMBProgress];
            hud.labelText = @"Saving ...";
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [pgnFileInfo appendGamesAndTagsToPgnFile:_gamesToCopyArray];
                if (_delegate) {
                    [_delegate partitaSalvataInDatabaseInModalitaReveal];
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
        return;
    }
    
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSString *nome = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([title isEqualToString:@"OK"] && nome.length>0) {
        if (alertView.tag == 0) {
            NSString *newPath = [_actualPath stringByAppendingPathComponent:nome];
            BOOL directoryCreata = [pgnDbManager createDirectory:newPath];
            if (directoryCreata) {
                listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
                [self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EnteredForeground" object:self];
            }
            else {
                UIAlertView *folderEsistenteAlertView =  [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"EXISTING_FOLDER", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [folderEsistenteAlertView show];
            }
        }
        else {
            if (![nome hasSuffix:@".pgn"]) {
                nome = [nome stringByAppendingString:@".pgn"];
            }
            NSString *newPath = [_actualPath stringByAppendingPathComponent:nome];
            BOOL databaseCreato = [pgnDbManager createDatabaseAtPath:newPath];
            if (databaseCreato) {
                listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
                [self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EnteredForeground" object:self];
            }
            else {
                UIAlertView *dbEsistenteAlertView =  [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"EXISTING_DATABASE", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [dbEsistenteAlertView show];
            }
        }
    }
}

@end
