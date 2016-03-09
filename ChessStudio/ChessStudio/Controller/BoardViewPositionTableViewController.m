//
//  BoardViewPositionTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/02/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "BoardViewPositionTableViewController.h"

@interface BoardViewPositionTableViewController ()

@end

@implementation BoardViewPositionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //[self.navigationController setPreferredContentSize:CGSizeMake(320.0, 280.0)];
    [self.navigationController setPreferredContentSize:CGSizeMake(320.0, 240)];
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.leftBarButtonItem = doneButtonItem;
    
    self.navigationItem.title = @"Menu";

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
        return 2;
    }
    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"SETUP_POSITION", nil);
    }
    else if (section == 1) {
        return NSLocalizedString(@"OTHER_MENU", nil);
    }
    return nil;
}

- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *thfv = (UITableViewHeaderFooterView *)view;
        //[thfv setFrame:CGRectMake(0, 0, thfv.frame.size.width, thfv.frame.size.height + 20)];
        thfv.textLabel.textColor = [UIColor yellowColor];
        //thfv.contentView.backgroundColor = UIColorFromRGB(0xFFD700);
        //thfv.contentView.backgroundColor = [UIColor blackColor];
        thfv.contentView.backgroundColor = [UIColor blackColor];
        thfv.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
        //thfv.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14.0];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell BoardViewPositionMenu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"MENU_POSITION_CLEAR", nil);
        }
        else if (indexPath.row == 1) {
            //cell.textLabel.text = NSLocalizedString(@"MENU_POSITION_SAVE", nil);
            cell.textLabel.text = NSLocalizedString(@"MENU_POSITION_COMPLETE", nil);
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"MENU_FLIP_BOARD", nil);
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"SETTINGS", nil);
        }
    }
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") || (!IS_PAD)) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_FLIP_BOARD", nil)]) {
                [_delegate flipBoard];
            }
            else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"SETTINGS", nil)]) {
                [_delegate displaySetting];
            }
            else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_POSITION_CLEAR", nil)]) {
                [_delegate clearPosition];
            }
            else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_POSITION_COMPLETE", nil)]) {
                [_delegate savePosition];
            }
        }];
    }
    else if (IS_PAD) {
        if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_FLIP_BOARD", nil)]) {
            [_delegate flipBoard];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"SETTINGS", nil)]) {
            [_delegate displaySetting];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_POSITION_CLEAR", nil)]) {
            [_delegate clearPosition];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_POSITION_COMPLETE", nil)]) {
            [_delegate savePosition];
        }
    }
    /*
    else {
        if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_FLIP_BOARD", nil)]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [_delegate flipBoard];
            }];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"SETTINGS", nil)]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [_delegate displaySetting];
            }];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_POSITION_CLEAR", nil)]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [_delegate clearPosition];
            }];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_POSITION_SAVE", nil)]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [_delegate savePosition];
            }];
        }
    }*/
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
