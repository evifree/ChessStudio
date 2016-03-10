//
//  TapOnPieceTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/04/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "TapOnPieceTableViewController.h"
#import "SettingManager.h"

@interface TapOnPieceTableViewController () {

    SettingManager *settingManager;
    NSInteger colorCheckedRow;
}

@end

@implementation TapOnPieceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = NSLocalizedString(@"SETTINGS_TAP_PIECE", nil);
    
    if (_doneButton) {
        NSString *buttonTitle = NSLocalizedString(@"DONE", @"Fatto");
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
        self.navigationItem.rightBarButtonItem = doneButtonItem;
    }

    
    
    settingManager = [SettingManager sharedSettingManager];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        return 7;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    else if (section == 1) {
        return @"Colori";
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Tap";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_TAP_PIECE", nil);
            cell.detailTextLabel.text = @"Tap starting square";
            cell.imageView.image = nil;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            //switchView.tag = 401;
            //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [switchView addTarget:self action:@selector(tapStartingSwitched:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
            [switchView setOn:[settingManager tapPieceToMove]];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_SHOW_LEGAL_MOVES", nil);;
            cell.detailTextLabel.text = nil;
            cell.imageView.image = nil;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            //switchView.tag = 402;
            //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [switchView addTarget:self action:@selector(legalMovesSwitched:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
            [switchView setOn:[settingManager showLegalMoves]];
        }
    }
    else if (indexPath.section == 1) {
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
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Devo impostare la forma del simbolo";
            cell.detailTextLabel.text = nil;
            cell.imageView.image = nil;
            cell.accessoryView = nil;
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Devo impostare il colore delle forme";
            cell.detailTextLabel.text = nil;
            cell.imageView.image = nil;
            cell.accessoryView = nil;
        }
    }
    
    return cell;
}

- (void) updateSwitch:(UISwitch *)switchView {
    if (switchView.tag == 401) {
        [settingManager setTapPieceToMove:[switchView isOn]];
    }
    else if (switchView.tag == 402) {
        [settingManager setShowLegalMoves:[switchView isOn]];
    }
}

- (void) tapStartingSwitched:(UISwitch *)switchView {
    [settingManager setTapPieceToMove:[switchView isOn]];
}

- (void) legalMovesSwitched:(UISwitch *)switchView {
    [settingManager setShowLegalMoves:[switchView isOn]];
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
    
    if (indexPath.section == 1) {
        [self performSelector: @selector(deselect:) withObject: tableView afterDelay: 0.1f];
        if (indexPath.row != colorCheckedRow) {
            [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: colorCheckedRow inSection: 1]]setAccessoryType: UITableViewCellAccessoryNone];
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
