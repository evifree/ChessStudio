//
//  CopyDatabaseTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 29/06/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "CopyDatabaseTableViewController.h"
#import "PgnDbManager.h"
#import "MBProgressHUD.h"
#import "UtilToView.h"

@interface CopyDatabaseTableViewController () {

    PgnDbManager *pgnDbManager;
    NSArray *listFile;

}

@end

@implementation CopyDatabaseTableViewController

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
    
    
    self.navigationItem.title = [_actualPath lastPathComponent];
    
    self.navigationController.toolbarHidden = NO;
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *nuovaCartellaButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil) style:UIBarButtonItemStylePlain target:self action:@selector(newDirectoryButtonPressed:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    UIBarButtonItem *moveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MOVE_DB", nil) style:UIBarButtonItemStylePlain target:self action:@selector(moveButtonPressed:)];
    
    
    
    NSArray *items = [NSArray arrayWithObjects:nuovaCartellaButton, flexibleItem, moveButton, flexibleItem, cancelButton, nil];
    self.toolbarItems = items;
    
    //UIBarButtonItem *actionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    //self.navigationItem.rightBarButtonItem = actionButtonItem;
    
    pgnDbManager = [PgnDbManager sharedPgnDbManager];
    //listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
    
    listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
    //listFile = [pgnDbManager listDirectory:_actualPath];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    static NSString *CellIdentifier = @"Cell Copy Database";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    if (IS_PHONE) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    
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
        
        
        /*
        float dimFileMb = fileByteSize.longLongValue/1048576.0;
        if (dimFileMb>=0) {
            NSNumber *fileSizeNumber = [NSNumber numberWithFloat:dimFileMb];
            NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
            numFormatter.roundingIncrement = [NSNumber numberWithDouble:0.1];
            numFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSString *dimString = [NSString stringWithFormat:@"%@", [numFormatter stringFromNumber:fileSizeNumber]];
            cell.detailTextLabel.text = [[[cell.detailTextLabel.text stringByAppendingString:@"  "] stringByAppendingString:dimString] stringByAppendingString:@" MB"];
        }
        */
         
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
    CopyDatabaseTableViewController *dfctvc = [[CopyDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
    NSString *nextPath = [_actualPath stringByAppendingPathComponent:[item lastPathComponent]];
    //NSLog(@"NextPath = %@", nextPath);
    [dfctvc setActualPath:nextPath];
    [dfctvc setDatabasesDaSpostare:_databasesDaSpostare];
    dfctvc.delegate = _delegate;
    [self.navigationController pushViewController:dfctvc animated:YES];
}

- (void) actionButtonPressed:(id)sender {
    
}

- (void) newDirectoryButtonPressed:(id)sender {
    UIAlertView *newDirectoryAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
    newDirectoryAlertView.tag = 1;
    newDirectoryAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newDirectoryAlertView show];
}

- (void) moveButtonPressed:(id)sender {
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
        [pgnDbManager moveDatabase:db :destPath];
    }
    listFile = [pgnDbManager listCompletePathPgnFileAndDirectoryAtPath:_actualPath];
    [self.tableView reloadData];
    [_delegate aggiorna];
}

- (void) cancelButtonPressed:(id)sender {
    [_delegate aggiorna];
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
}


@end
