//
//  ColorsTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/04/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "ColorsTableViewController.h"
#import "SettingManager.h"

@interface ColorsTableViewController () {
    SettingManager *settingManager;
    NSInteger colorCheckedRow;
}

@end

@implementation ColorsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    settingManager = [SettingManager sharedSettingManager];
    
    self.navigationItem.title = NSLocalizedString(@"SETTINGS_COLOR_HIGHLIGHT", nil);
    
    if (_doneButton) {
        NSString *buttonTitle = NSLocalizedString(@"DONE", @"Fatto");
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
        self.navigationItem.rightBarButtonItem = doneButtonItem;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doneButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Color";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"ORANGE", nil);
        cell.detailTextLabel.text = nil;
        cell.imageView.image = nil;
        cell.accessoryView = nil;
        if ([[settingManager colorHighLight] isEqualToString:NSLocalizedString(@"ORANGE", nil)]) {
            [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
            colorCheckedRow = indexPath.row;
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"YELLOW", nil);
        cell.detailTextLabel.text = nil;
        cell.imageView.image = nil;
        cell.accessoryView = nil;
        if ([[settingManager colorHighLight] isEqualToString:NSLocalizedString(@"YELLOW", nil)]) {
            [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
            colorCheckedRow = indexPath.row;
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"BLACK", nil);
        cell.detailTextLabel.text = nil;
        cell.imageView.image = nil;
        cell.accessoryView = nil;
        if ([[settingManager colorHighLight] isEqualToString:NSLocalizedString(@"BLACK", nil)]) {
            [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
            colorCheckedRow = indexPath.row;
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if (indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"WHITE", nil);
        cell.detailTextLabel.text = nil;
        cell.imageView.image = nil;
        cell.accessoryView = nil;
        if ([[settingManager colorHighLight] isEqualToString:NSLocalizedString(@"WHITE", nil)]) {
            [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
            colorCheckedRow = indexPath.row;
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if (indexPath.row == 4) {
        cell.textLabel.text = NSLocalizedString(@"RED", nil);
        cell.detailTextLabel.text = nil;
        cell.imageView.image = nil;
        cell.accessoryView = nil;
        if ([[settingManager colorHighLight] isEqualToString:NSLocalizedString(@"RED", nil)]) {
            [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
            colorCheckedRow = indexPath.row;
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if (indexPath.row == 5) {
        cell.textLabel.text = NSLocalizedString(@"GREEN", nil);
        cell.detailTextLabel.text = nil;
        cell.imageView.image = nil;
        cell.accessoryView = nil;
        if ([[settingManager colorHighLight] isEqualToString:NSLocalizedString(@"GREEN", nil)]) {
            [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
            colorCheckedRow = indexPath.row;
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if (indexPath.row == 6) {
        cell.textLabel.text = NSLocalizedString(@"BLUE", nil);
        cell.detailTextLabel.text = nil;
        cell.imageView.image = nil;
        cell.accessoryView = nil;
        if ([[settingManager colorHighLight] isEqualToString:NSLocalizedString(@"BLUE", nil)]) {
            [cell setAccessoryType: UITableViewCellAccessoryCheckmark];
            colorCheckedRow = indexPath.row;
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    if (indexPath.section == 0) {
        [self performSelector: @selector(deselect:) withObject: tableView afterDelay: 0.1f];
        if (indexPath.row != colorCheckedRow) {
            [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: colorCheckedRow inSection: 0]]setAccessoryType: UITableViewCellAccessoryNone];
            [[tableView cellForRowAtIndexPath: indexPath]setAccessoryType: UITableViewCellAccessoryCheckmark];
            colorCheckedRow = indexPath.row;
            NSString *selectedColor = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
            [settingManager setColorHighLight:selectedColor];
        }
    }
}

- (void)deselect:(UITableView *)tableView {
    [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
