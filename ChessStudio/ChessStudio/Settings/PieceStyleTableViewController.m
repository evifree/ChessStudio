//
//  PieceStyleTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 04/02/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "PieceStyleTableViewController.h"
#import "SettingManager.h"
#import "UtilToView.h"

@interface PieceStyleTableViewController () {

    NSArray *contents;
    NSInteger checkedRow;
    
    SettingManager *settingManager;

}

@end

@implementation PieceStyleTableViewController

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
    
    self.navigationItem.title = NSLocalizedString(@"PIECES", nil);
    
    contents = [UtilToView getTipoPezziArray];
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
    return contents.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
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
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    NSString *tp = [contents objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[tp lowercaseString]];
    cell.imageView.transform = CGAffineTransformMakeScale(0.7, 0.8);
    
    if ([tp hasPrefix:[settingManager pieceType]]) {
        [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
        checkedRow = indexPath.row;
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSelector: @selector(deselect:) withObject: tableView afterDelay: 0.1f];
    if (indexPath.row != checkedRow) {
        [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: checkedRow inSection: 0]]setAccessoryType: UITableViewCellAccessoryNone];
        [[tableView cellForRowAtIndexPath: indexPath]setAccessoryType: UITableViewCellAccessoryCheckmark];
        checkedRow = indexPath.row;
        
        [settingManager setPieceType:[contents objectAtIndex:indexPath.row]];
        if (_delegate) {
            [_delegate updateFromPieceStyle];
        }
    }
    [[self navigationController] popViewControllerAnimated:YES];
}



- (void)deselect:(UITableView *)tableView {
    [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
