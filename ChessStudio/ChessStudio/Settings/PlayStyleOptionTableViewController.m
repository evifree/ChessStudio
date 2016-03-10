//
//  PlayStyleOptionTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/12/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PlayStyleOptionTableViewController.h"
#import "Options.h"

@interface PlayStyleOptionTableViewController () {
    NSArray *contents;
    NSString *slotName;
    NSInteger checkedRow;
}

@end

@implementation PlayStyleOptionTableViewController

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
    contents = [NSArray arrayWithObjects: @"Passive", @"Solid", @"Active", @"Aggressive", @"Suicidal", nil];
    slotName = @"playStyle";
    [self setTitle:NSLocalizedString(@"ENGINE_PLAY_STYLE", nil)];
    
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
    return contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [contents objectAtIndex:indexPath.row];
    if ([cell.textLabel.text isEqualToString:[[Options sharedOptions]valueForKey:slotName]]) {
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
        [[Options sharedOptions] setValue: [[[tableView cellForRowAtIndexPath: indexPath] textLabel] text] forKey: slotName];
        [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: checkedRow inSection: 0]]setAccessoryType: UITableViewCellAccessoryNone];
        [[tableView cellForRowAtIndexPath: indexPath]setAccessoryType: UITableViewCellAccessoryCheckmark];
        checkedRow = indexPath.row;
        if (_delegate) {
            [_delegate aggiornaPlayStyleInTable];
        }
    }
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)deselect:(UITableView *)tableView {
    [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

@end
