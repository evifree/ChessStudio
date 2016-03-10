//
//  EmailRecipientsTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 06/12/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "EmailRecipientsTableViewController.h"

@interface EmailRecipientsTableViewController () {

    //NSInteger checkedRow;
    
    //NSMutableArray *emailRecipientsArray;
    NSMutableDictionary *emailRecipientsDictionary;
    NSArray *emailRecipientsSorted;
}

@end

@implementation EmailRecipientsTableViewController

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
    
    [self loadEmailRecipients];
    
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    //self.navigationItem.rightBarButtonItem = addBarButtonItem;
    
    NSArray *items = [NSArray arrayWithObjects:addBarButtonItem, self.editButtonItem, nil];
    self.navigationItem.rightBarButtonItems = items;
    
    self.navigationItem.title = NSLocalizedString(@"EMAIL_RECIPIENTS_TITLE", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadEmailRecipients {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:@"EmailRecipients.json"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    
    if (!fileExists) {
        //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString *rootPath = [paths objectAtIndex:0];
        filePath = [cacheDirectory stringByAppendingPathComponent:@"EmailRecipients.json"];
        NSError *error = nil;
        NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        [outputStream open];
        //emailRecipientsArray = [[NSMutableArray alloc] init];
        emailRecipientsDictionary = [[NSMutableDictionary alloc] init];
        //[emailRecipientsArray addObject:@"chess.studio.app@gmail.com"];
        [emailRecipientsDictionary setObject:@"1" forKey:@"chess.studio.app@gmail.com"];
        //[NSJSONSerialization writeJSONObject:emailRecipientsArray toStream:outputStream options:0 error:&error];
        [NSJSONSerialization writeJSONObject:emailRecipientsDictionary toStream:outputStream options:0 error:&error];
        [outputStream close];
        emailRecipientsSorted = [[emailRecipientsDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        return;
    }
    NSError *error = nil;
    //NSLog(@"File json caricato correttamente");
    //NSLog(@"FilePath = %@", filePath);
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:kNilOptions error:&error];
    //emailRecipientsArray = data.mutableCopy;
    emailRecipientsDictionary = data.mutableCopy;
    
    emailRecipientsSorted = [[emailRecipientsDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void) saveEmailRecipientsToFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:@"EmailRecipients.json"];
    NSError *error = nil;
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [outputStream open];
    //[NSJSONSerialization writeJSONObject:emailRecipientsArray toStream:outputStream options:0 error:&error];
    [NSJSONSerialization writeJSONObject:emailRecipientsDictionary toStream:outputStream options:0 error:&error];
    [outputStream close];
}

- (void) addButtonPressed:(UIBarButtonItem *)sender {
    if ([self.tableView isEditing]) {
        return;
    }
    UIAlertView *newDirectoryAlertView = [[UIAlertView alloc] initWithTitle:@"New Recipient" message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
    newDirectoryAlertView.tag = 0;
    newDirectoryAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newDirectoryAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        NSString *recipient = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([title isEqualToString:@"OK"] && recipient.length>0) {
            //[emailRecipientsArray addObject:recipient];
            [emailRecipientsDictionary setObject:@"0" forKey:recipient];
            emailRecipientsSorted = [[emailRecipientsDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [self.tableView reloadData];
            [self saveEmailRecipientsToFile];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    //return emailRecipientsArray.count;
    return emailRecipientsDictionary.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Email Recipients";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell Email Recipient";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    //cell.textLabel.text = [emailRecipientsArray objectAtIndex:indexPath.row];
    NSString *key = [emailRecipientsSorted objectAtIndex:indexPath.row];
    cell.textLabel.text = key;
    if ([[emailRecipientsDictionary objectForKey:key] isEqualToString:@"1"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
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


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *key = [emailRecipientsSorted objectAtIndex:indexPath.row];
        [emailRecipientsDictionary removeObjectForKey:key];
        [self saveEmailRecipientsToFile];
        
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
    
    if (tableView.isEditing) {
        return;
    }
    
    
    [self performSelector: @selector(deselect:) withObject: tableView afterDelay: 0.1f];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *key = cell.textLabel.text;
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [emailRecipientsDictionary setObject:@"0" forKey:key];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [emailRecipientsDictionary setObject:@"1" forKey:key];
    }
    
    [self saveEmailRecipientsToFile];
    
    if (_delegate) {
        [_delegate aggiornaEmailRecipientsInTable:emailRecipientsDictionary];
    }
    
    //if (indexPath.row != checkedRow) {
        //[[Options sharedOptions] setValue: [[[tableView cellForRowAtIndexPath: indexPath] textLabel] text] forKey: slotName];
        //[[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: checkedRow inSection: 0]]setAccessoryType: UITableViewCellAccessoryNone];
        //[[tableView cellForRowAtIndexPath: indexPath]setAccessoryType: UITableViewCellAccessoryCheckmark];
        //checkedRow = indexPath.row;
        //if (_delegate) {
        //    [_delegate aggiornaEmailRecipientsInTable];
        //}
    //}
    //[[self navigationController] popViewControllerAnimated:YES];
}

- (void)deselect:(UITableView *)tableView {
    [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
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
