//
//  PgnMentorSaveDatabaseTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 29/11/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "PgnMentorSaveDatabaseTableViewController.h"
#import "PgnDbManager.h"

@interface PgnMentorSaveDatabaseTableViewController () {

    PgnDbManager *pgnDbManager;
    NSArray *listFile;
    
    
    BOOL fileSaved;

}

@end

@implementation PgnMentorSaveDatabaseTableViewController

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
    
    self.navigationController.toolbarHidden = NO;
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *nuovaCartellaButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil) style:UIBarButtonItemStylePlain target:self action:@selector(newDirectoryButtonPressed:)];
    //UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelButtonPressed:)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE_DATABASE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPressed:)];
    
    
    
    NSArray *items = [NSArray arrayWithObjects:nuovaCartellaButton, flexibleItem, saveButton, flexibleItem, cancelButton, nil];
    self.toolbarItems = items;
    
    self.navigationItem.title = _fileToSave;
    
    
    
    pgnDbManager = [PgnDbManager sharedPgnDbManager];
    
    if (!_rootPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _rootPath = [paths objectAtIndex:0];
    }
    
    listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_rootPath];
    
    
    fileSaved = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    static NSString *CellIdentifier = @"Cell Save Database";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (IS_PHONE) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    
    NSString *item = [[listFile objectAtIndex:indexPath.row] lastPathComponent];
    NSString *newPath = [_rootPath stringByAppendingPathComponent:item];
    if ([pgnDbManager isDirectoryAtPath:newPath]) {
        NSInteger numberOfItems = [pgnDbManager numberOfItemsAtPath:newPath];
        cell.imageView.image = [UIImage imageNamed:@"ChessFolder.png"];
        NSMutableString *testo = [[NSMutableString alloc] initWithString:item];
        
        //NSLog(@"Inizio = %f   Larghezza = %f", cell.textLabel.frame.origin.x, cell.textLabel.frame.size.width);
        if (numberOfItems > 0) {
            [testo appendString:@" "];
            [testo appendFormat:@"(%d)", (int)numberOfItems];
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
        float dimFileMb = fileByteSize.longLongValue/1048576.0;
        if (dimFileMb>=0) {
            NSNumber *fileSizeNumber = [NSNumber numberWithFloat:dimFileMb];
            NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
            numFormatter.roundingIncrement = [NSNumber numberWithDouble:0.1];
            numFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSString *dimString = [NSString stringWithFormat:@"%@", [numFormatter stringFromNumber:fileSizeNumber]];
            cell.detailTextLabel.text = [[[cell.detailTextLabel.text stringByAppendingString:@"  "] stringByAppendingString:dimString] stringByAppendingString:@" MB"];
        }
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        cell.userInteractionEnabled = NO;
        cell.textLabel.enabled = NO;
        cell.detailTextLabel.enabled = NO;
        cell.imageView.alpha = 0.5;
    }
    
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
    PgnMentorSaveDatabaseTableViewController *pmsdvc = [[PgnMentorSaveDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
    NSString *nextPath = [_rootPath stringByAppendingPathComponent:[item lastPathComponent]];
    pmsdvc.delegate = _delegate;
    //NSLog(@"NextPath = %@", nextPath);
    [pmsdvc setRootPath:nextPath];
    //[pmsdvc setDatabasesDaSpostare:_databasesDaSpostare];
    //pmsdvc.delegate = _delegate;
    [pmsdvc setFileToSave:_fileToSave];
    [self.navigationController pushViewController:pmsdvc animated:YES];
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

#pragma mark - Implementazione metodi Button

- (void) cancelButtonPressed:(id)sender {
    if (!fileSaved) {
        UIAlertView *areYouSureAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"SAVE_DATABASE_ALERT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
        areYouSureAlertView.tag = 2;
        [areYouSureAlertView show];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveButtonPressed:(id)sender {
    if (_delegate) {
        [_delegate saveDatabase:_rootPath];
        listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_rootPath];
        [self.tableView reloadData];
        fileSaved = YES;
    }
}

- (void) newDirectoryButtonPressed:(id)sender {
    UIAlertView *newDirectoryAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
    newDirectoryAlertView.tag = 1;
    newDirectoryAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newDirectoryAlertView show];
}

#pragma mark - Implementazione metodi AlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        NSString *nome = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([title isEqualToString:@"OK"] && nome.length>0) {
            NSString *newPath = [_rootPath stringByAppendingPathComponent:nome];
            BOOL directoryCreata = [pgnDbManager createDirectory:newPath];
            if (directoryCreata) {
                listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_rootPath];
                [self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
            }
            else {
                UIAlertView *folderEsistenteAlertView =  [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"EXISTING_FOLDER", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [folderEsistenteAlertView show];
            }
        }
    }
    else if (alertView.tag == 2) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"OK"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
