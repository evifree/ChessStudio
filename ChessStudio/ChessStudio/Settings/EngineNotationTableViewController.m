//
//  EngineNotationTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/12/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "EngineNotationTableViewController.h"
#import "Options.h"
#import "SettingManager.h"

@interface EngineNotationTableViewController () {

    NSArray *contents;
    NSInteger checkedRow;
    
    SettingManager *settingManager;

}

@end

@implementation EngineNotationTableViewController

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
    [self setTitle: NSLocalizedString(@"ENGINE_NOTATION", nil)];
    contents = [NSArray arrayWithObjects:NSLocalizedString(@"LETTER", nil), NSLocalizedString(@"FIGURINE", nil), nil];
    
    settingManager = [SettingManager sharedSettingManager];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSString *notation = nil;
    if ([[Options sharedOptions] figurineNotation]) {
        notation = NSLocalizedString(@"FIGURINE", nil);
        //cell.textLabel.text = notation;
    }
    else {
        notation = NSLocalizedString(@"LETTER", nil);
        //cell.textLabel.text = notation;
    }
    
    cell.textLabel.text = [contents objectAtIndex:indexPath.row];
    
    if ([notation isEqualToString:cell.textLabel.text]) {
        [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
        checkedRow = indexPath.row;
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
    
    [self performSelector: @selector(deselect:) withObject: tableView afterDelay: 0.1f];
    if (indexPath.row != checkedRow) {
        UITableViewCell *selCell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *notation = selCell.textLabel.text;
        if ([notation isEqualToString:NSLocalizedString(@"FIGURINE", nil)]) {
            [[Options sharedOptions] setFigurineNotation:YES];
            [settingManager setEngineFigurineNotation:YES];
            //NSLog(@"Figurine notation = YES");
        }
        else {
            [[Options sharedOptions] setFigurineNotation:NO];
            [settingManager setEngineFigurineNotation:NO];
            //NSLog(@"Figurine notation = NO");
        }
        [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: checkedRow inSection: 0]]setAccessoryType: UITableViewCellAccessoryNone];
        [[tableView cellForRowAtIndexPath: indexPath]setAccessoryType: UITableViewCellAccessoryCheckmark];
        checkedRow = indexPath.row;
        if (_delegate) {
            [_delegate aggiornaEngineNotationInTable];
        }
    }
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)deselect:(UITableView *)tableView {
    [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

@end
