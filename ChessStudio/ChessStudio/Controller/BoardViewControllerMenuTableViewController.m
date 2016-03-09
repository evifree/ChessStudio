//
//  BoardViewControllerMenuTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 09/02/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "BoardViewControllerMenuTableViewController.h"
#import "NalimovBoardViewController.h"

@interface BoardViewControllerMenuTableViewController () {

}

@end

@implementation BoardViewControllerMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (_pgnGame.isEditMode) {
        if ([_delegate plycountMaggioreZero]) {
            [self.navigationController setPreferredContentSize:CGSizeMake(320.0, 550.0)];
        }
        else {
            [self.navigationController setPreferredContentSize:CGSizeMake(320.0, 400.0)];
        }
    }
    else {
        if ([_pgnGame isPosition]) {
            [self.navigationController setPreferredContentSize:CGSizeMake(320.0, 265.0)];
        }
        else {
            [self.navigationController setPreferredContentSize:CGSizeMake(320.0, 220.0)];
        }
    }
    
    
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
    
    if ([_delegate isKindOfClass:[NalimovBoardViewController class]]) {
        if (_pgnGame.isEditMode) {
            if ([_delegate plycountMaggioreZero] && [_delegate isInVariante]) {
                return 4;
            }
            else if (![_delegate plycountMaggioreZero] && [_delegate isInVariante]) {
                return 3;
            }
            else if ([_delegate plycountMaggioreZero] && ![_delegate isInVariante]) {
                if ([[_delegate getUltimaMossa] hasSuffix:@"XXX"]) {
                    return 2;
                }
                return 3;
            }
            else if (![_delegate plycountMaggioreZero] && ![_delegate isInVariante]) {
                return 2;
            }
        }
        return 0;
    }
    
    if (_pgnGame.isEditMode) {
        if ([_delegate plycountMaggioreZero] && [_delegate isInVariante]) {
            return 5;
        }
        else if (![_delegate plycountMaggioreZero] && [_delegate isInVariante]) {
            return 4;
        }
        else if ([_delegate plycountMaggioreZero] && ![_delegate isInVariante]) {
            if ([[_delegate getUltimaMossa] hasSuffix:@"XXX"]) {
                return 3;
            }
            return 4;
        }
        else if (![_delegate plycountMaggioreZero] && ![_delegate isInVariante]) {
            return 3;
        }
    }
    else {
        return 3;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([_delegate isKindOfClass:[NalimovBoardViewController class]]) {
        if (section == 0) {
            if (_pgnGame.isEditMode) {
                return 4;
            }
            else {
                return 1;
            }
        }
        else if (section == 1) {
            if (_pgnGame.isEditMode && [_delegate isInVariante]) {
                return 2;
            }
            else if (_pgnGame.isEditMode && [_delegate plycountMaggioreZero]) {
                if ([_delegate isUltimaMossaInserita] && ![[_delegate getUltimaMossa] hasSuffix:@"XXX"]) {
                    return 3;
                }
                if ([[_delegate getUltimaMossa] hasSuffix:@"XXX"]) {
                    return 1;
                }
                return 3;
            }
            else {
                return 1;
            }
        }
        else if (section == 2) {
            if (_pgnGame.isEditMode && [_delegate isInVariante]) {
                return 3;
            }
            return 1;
        }
        else if (section == 3) {
            if (_pgnGame.isEditMode && [_delegate isInVariante]) {
                return 1;
            }
        }
        return 0;
    }
    
    
    
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        if (_pgnGame.isEditMode) {
            return 5;
        }
        else if ([_pgnGame isPosition]){
            return 2;
        }
        else {
            return 1;
        }
    }
    else if (section == 2) {
        if (_pgnGame.isEditMode && [_delegate isInVariante]) {
            return 2;
        }
        else if (_pgnGame.isEditMode && [_delegate plycountMaggioreZero]) {
            if ([_delegate isUltimaMossaInserita] && ![[_delegate getUltimaMossa] hasSuffix:@"XXX"]) {
                return 3;
            }
            if ([[_delegate getUltimaMossa] hasSuffix:@"XXX"]) {
                return 1;
            }
            return 3;
        }
        else {
            return 1;
        }
    }
    else if (section == 3) {
        if (_pgnGame.isEditMode && [_delegate isInVariante]) {
            return 3;
        }
        return 1;
    }
    else if (section == 4) {
        if (_pgnGame.isEditMode && [_delegate isInVariante]) {
            return 1;
        }
    }
    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ([_delegate isKindOfClass:[NalimovBoardViewController class]]) {
        if (section == 0) {
            NSString *gameTitle = [[[NSLocalizedString(@"GAME_MENU", nil) stringByAppendingString:@"("] stringByAppendingString:[_delegate getTitleGame]] stringByAppendingString:@")"];
            return gameTitle;
        }
        else if (section == 1) {
            if (_pgnGame.isEditMode && [_delegate isInVariante]) {
                return NSLocalizedString(@"VARIANT_MENU", nil);
            }
            else if (_pgnGame.isEditMode && [_delegate plycountMaggioreZero] && ![_delegate isInVariante]) {
                if ([[_delegate getUltimaMossa] hasSuffix:@"XXX"]) {
                    return NSLocalizedString(@"OTHER_MENU", nil);
                }
                NSString *move = [NSLocalizedString(@"MOVE_MENU", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                return move;
            }
            else {
                return NSLocalizedString(@"OTHER_MENU", nil);
            }
        }
        else if (section == 2) {
            if (_pgnGame.isEditMode && [_delegate plycountMaggioreZero] && [_delegate isInVariante]) {
                NSString *move = [NSLocalizedString(@"MOVE_MENU", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                return move;
            }
            else if (_pgnGame.isEditMode) {
                return NSLocalizedString(@"OTHER_MENU", nil);
            }
            else {
                return nil;
            }
        }
        else if (section == 3) {
            return NSLocalizedString(@"OTHER_MENU", nil);
        }
        return nil;
    }
    
    
    
    
    if (section == 0) {
        return NSLocalizedString(@"MODE_MENU", nil);
    }
    else if (section == 1) {
        NSString *gameTitle = [[[NSLocalizedString(@"GAME_MENU", nil) stringByAppendingString:@"("] stringByAppendingString:[_delegate getTitleGame]] stringByAppendingString:@")"];
        return gameTitle;
    }
    else if (section == 2) {
        if (_pgnGame.isEditMode && [_delegate isInVariante]) {
            return NSLocalizedString(@"VARIANT_MENU", nil);
        }
        else if (_pgnGame.isEditMode && [_delegate plycountMaggioreZero] && ![_delegate isInVariante]) {
            if ([[_delegate getUltimaMossa] hasSuffix:@"XXX"]) {
                return NSLocalizedString(@"OTHER_MENU", nil);
            }
            NSString *move = [NSLocalizedString(@"MOVE_MENU", nil) stringByAppendingString:[_delegate getUltimaMossa]];
            return move;
        }
        else {
            return NSLocalizedString(@"OTHER_MENU", nil);
        }
    }
    else if (section == 3) {
        if (_pgnGame.isEditMode && [_delegate plycountMaggioreZero] && [_delegate isInVariante]) {
            NSString *move = [NSLocalizedString(@"MOVE_MENU", nil) stringByAppendingString:[_delegate getUltimaMossa]];
            return move;
        }
        else if (_pgnGame.isEditMode) {
            return NSLocalizedString(@"OTHER_MENU", nil);
        }
        else {
            return nil;
        }
    }
    else if (section == 4) {
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
    static NSString *CellIdentifier = @"Cell BoardViewMenu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    if ([_delegate isKindOfClass:[NalimovBoardViewController class]]) {
        if (indexPath.section == 0) {
            if (_pgnGame.isEditMode) {
                if (indexPath.row == 0) {
                    if ([_delegate esisteTestoIniziale]) {
                        cell.textLabel.text = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
                    }
                    else {
                        cell.textLabel.text = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
                    }
                }
                else if (indexPath.row == 1) {
                    cell.textLabel.text = NSLocalizedString(@"MENU_EMAIL_GAME", nil);
                }
                else if (indexPath.row == -1) {
                    cell.textLabel.text = NSLocalizedString(@"MENU_NEW_GAME", nil);
                }
                else if (indexPath.row == 2) {
                    cell.textLabel.text = NSLocalizedString(@"MENU_EDIT_GAME_DATA", nil);
                }
                else if (indexPath.row == 3) {
                    cell.textLabel.text = NSLocalizedString(@"MENU_GAME_SAVE", nil);
                }
                else if (indexPath.row == 4) {
                    cell.textLabel.text = NSLocalizedString(@"MENU_INSERT_VARIANT", nil);
                }
            }
            else {
                cell.textLabel.text = NSLocalizedString(@"MENU_EMAIL_GAME", nil);
            }
            cell.accessoryView = nil;
        }
        else if (indexPath.section == 1) {
            if (_pgnGame.isEditMode && [_delegate isInVariante]) {
                if (indexPath.row == 0) {
                    cell.textLabel.text = NSLocalizedString(@"DELETE_VARIATION", nil);
                }
                else if (indexPath.row == 1) {
                    cell.textLabel.text = NSLocalizedString(@"PROMOTE_VARIATION", nil);
                }
            }
            else if (_pgnGame.isEditMode && [_delegate plycountMaggioreZero] && ![_delegate isInVariante]) {
                if (indexPath.row == 0) {
                    if ([[_delegate getUltimaMossa] hasSuffix:@"XXX"]) {
                        cell.textLabel.text = NSLocalizedString(@"SETTINGS", nil);
                    }
                    else {
                        cell.textLabel.text = [NSLocalizedString(@"ANNOTATION_MOVE", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                    }
                }
                else if (indexPath.row == 1) {
                    cell.textLabel.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                }
                else if (indexPath.row == 2) {
                    //cell.textLabel.text = [NSLocalizedString(@"TAKE_BACK", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                    cell.textLabel.text = [NSLocalizedString(@"INSERT_VARIANT_INSTEAD_OF", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                }
            }
            else {
                if (indexPath.row == 0) {
                    cell.textLabel.text = NSLocalizedString(@"SETTINGS", nil);
                }
                else if (indexPath.row == 1) {
                    cell.textLabel.text = NSLocalizedString(@"MENU_EXIT", nil);
                }
            }
            cell.accessoryView = nil;
        }
        else if (indexPath.section == 2) {
            if (_pgnGame.isEditMode && [_delegate plycountMaggioreZero] && [_delegate isInVariante]) {
                if (indexPath.row == 0) {
                    cell.textLabel.text = [NSLocalizedString(@"ANNOTATION_MOVE", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                }
                else if (indexPath.row == 1) {
                    cell.textLabel.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                }
                else if (indexPath.row == 2) {
                    cell.textLabel.text = [NSLocalizedString(@"INSERT_VARIANT_INSTEAD_OF", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                    //cell.textLabel.text = [NSLocalizedString(@"TAKE_BACK", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                }
            }
            else if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"SETTINGS", nil);
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"MENU_EXIT", nil);
            }
            cell.accessoryView = nil;
        }
        else if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"SETTINGS", nil);
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"MENU_EXIT", nil);
            }
            cell.accessoryView = nil;
        }
        return cell;
    }
    
    
    
    
    // Configure the cell...
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"EDIT_MODE", nil);
            UISwitch *switchMode = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchMode.tag = 100;
            [switchMode setOn:_pgnGame.isEditMode];
            [switchMode addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchMode;
        }
    }
    else if (indexPath.section == 1) {
        if (_pgnGame.isEditMode) {
            if (indexPath.row == 0) {
                if ([_delegate esisteTestoIniziale]) {
                    cell.textLabel.text = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
                }
                else {
                    cell.textLabel.text = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
                }
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"MENU_EMAIL_GAME", nil);
            }
            else if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"MENU_NEW_GAME", nil);
            }
            else if (indexPath.row == 3) {
                cell.textLabel.text = NSLocalizedString(@"MENU_EDIT_GAME_DATA", nil);
            }
            else if (indexPath.row == 4) {
                cell.textLabel.text = NSLocalizedString(@"MENU_GAME_SAVE", nil);
            }
            else if (indexPath.row == 5) {
                cell.textLabel.text = NSLocalizedString(@"MENU_INSERT_VARIANT", nil);
            }
            else if (indexPath.row == 6) {
                cell.textLabel.text = NSLocalizedString(@"MENU_GAME_SAVE_AS_NEW_GAME", nil);
            }
        }
        else {
            if ([_pgnGame isPosition]) {
                if (indexPath.row == 0) {
                    cell.textLabel.text = NSLocalizedString(@"EDIT_POSITION", nil);
                }
                else if (indexPath.row == 1) {
                    cell.textLabel.text = NSLocalizedString(@"MENU_EMAIL_GAME", nil);
                }
            }
            else {
                if (indexPath.row == 0) {
                    cell.textLabel.text = NSLocalizedString(@"MENU_EMAIL_GAME", nil);
                }
            }

        }
        cell.accessoryView = nil;
    }
    else if (indexPath.section == 2) {
        if (_pgnGame.isEditMode && [_delegate isInVariante]) {
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"DELETE_VARIATION", nil);
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"PROMOTE_VARIATION", nil);
            }
        }
        else if (_pgnGame.isEditMode && [_delegate plycountMaggioreZero] && ![_delegate isInVariante]) {
            if (indexPath.row == 0) {
                if ([[_delegate getUltimaMossa] hasSuffix:@"XXX"]) {
                    cell.textLabel.text = NSLocalizedString(@"SETTINGS", nil);
                }
                else {
                    cell.textLabel.text = [NSLocalizedString(@"ANNOTATION_MOVE", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                }
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:[_delegate getUltimaMossa]];
            }
            else if (indexPath.row == 2) {
                //cell.textLabel.text = [NSLocalizedString(@"TAKE_BACK", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                cell.textLabel.text = [NSLocalizedString(@"INSERT_VARIANT_INSTEAD_OF", nil) stringByAppendingString:[_delegate getUltimaMossa]];
            }
        }
        else {
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"SETTINGS", nil);
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"MENU_EXIT", nil);
            }
        }
        cell.accessoryView = nil;
    }
    else if (indexPath.section == 3) {
        if (_pgnGame.isEditMode && [_delegate plycountMaggioreZero] && [_delegate isInVariante]) {
            if (indexPath.row == 0) {
                cell.textLabel.text = [NSLocalizedString(@"ANNOTATION_MOVE", nil) stringByAppendingString:[_delegate getUltimaMossa]];
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:[_delegate getUltimaMossa]];
            }
            else if (indexPath.row == 2) {
                cell.textLabel.text = [NSLocalizedString(@"INSERT_VARIANT_INSTEAD_OF", nil) stringByAppendingString:[_delegate getUltimaMossa]];
                //cell.textLabel.text = [NSLocalizedString(@"TAKE_BACK", nil) stringByAppendingString:[_delegate getUltimaMossa]];
            }
        }
        else if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"SETTINGS", nil);
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"MENU_EXIT", nil);
        }
        cell.accessoryView = nil;
    }
    else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"SETTINGS", nil);
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"MENU_EXIT", nil);
        }
        cell.accessoryView = nil;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"ANNOTATION_MOVE", nil)]) {
        AnnotationMoveTableViewController *amtvc = [[AnnotationMoveTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        amtvc.delegate = self;
        [amtvc setMossaDaAnnotare:[_delegate getMossaDaAnnotare]];
        [self.navigationController pushViewController:amtvc animated:YES];
        return;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") || (!IS_PAD)) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_EXIT", nil)]) {
                [_delegate exitGame];
            }
            else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"TAKE_BACK", nil)]) {
                [_delegate undoMove];
            }
            else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_GAME_SAVE", nil)]) {
                [_delegate saveGame];
            }
            else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"SETTINGS", nil)]) {
                [_delegate displaySetting];
            }
            else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_NEW_GAME", nil)]) {
                [_delegate newGame];
            }
            else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_EMAIL_GAME", nil)]) {
                [_delegate sendGameByEmail];
            }
            else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"EDIT_INITIAL_TEXT", nil)]) {
                [_delegate editInitialText];
            }
            else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"ADD_INITIAL_TEXT", nil)]) {
                [_delegate addInitialText];
            }
            else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"ANNOTATION_MOVE", nil)]) {
                [_delegate addAnnotationToMove];
            }
            else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"TEXT_AFTER", nil)]) {
                [_delegate addTextAfterMove];
            }
            else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_EDIT_GAME_DATA", nil)]) {
                [_delegate editGameData];
            }
            else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_INSERT_VARIANT", nil)]) {
                [_delegate insertVariant];
            }
            else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"INSERT_VARIANT_INSTEAD_OF", nil)]) {
                [_delegate insertVariantInsteadOf];
            }
            else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"DELETE_VARIATION", nil)]) {
                [_delegate deleteVariation];
            }
            else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"PROMOTE_VARIATION", nil)]) {
                [_delegate promuoviVariation];
            }
            else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"EDIT_POSITION", nil)]) {
                [_delegate editPosition];
            }
        }];
    }
    else if (IS_PAD) {
        if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_EXIT", nil)]) {
            [_delegate exitGame];
        }
        else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"TAKE_BACK", nil)]) {
            [_delegate undoMove];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_SAVE_GAME", nil)]) {
            [_delegate saveGame];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"SETTINGS", nil)]) {
            [_delegate displaySetting];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_NEW_GAME", nil)]) {
            [_delegate newGame];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_EMAIL_GAME", nil)]) {
            [_delegate sendGameByEmail];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"EDIT_INITIAL_TEXT", nil)]) {
            [_delegate editInitialText];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"ADD_INITIAL_TEXT", nil)]) {
            [_delegate addInitialText];
        }
        else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"ANNOTATION_MOVE", nil)]) {
            [_delegate addAnnotationToMove];
        }
        else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"TEXT_AFTER", nil)]) {
            [_delegate addTextAfterMove];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_EDIT_GAME_DATA", nil)]) {
            [_delegate editGameData];
        }
        else if ([selCell.textLabel.text isEqualToString:NSLocalizedString(@"MENU_INSERT_VARIANT", nil)]) {
            [_delegate insertVariant];
        }
        else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"INSERT_VARIANT_INSTEAD_OF", nil)]) {
            [_delegate insertVariantInsteadOf];
        }
        else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"DELETE_VARIATION", nil)]) {
            [_delegate deleteVariation];
        }
        else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"PROMOTE_VARIATION", nil)]) {
            [_delegate promuoviVariation];
        }
        else if ([selCell.textLabel.text hasPrefix:NSLocalizedString(@"EDIT_POSITION", nil)]) {
            [_delegate editPosition];
        }
    }
}

- (void) updateSwitch:(UISwitch *)switchView {
    if (switchView.tag == 100) {
        [_pgnGame setEditMode:[switchView isOn]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:self.tableView
                              duration:0.3f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^(void) {
                                if (_pgnGame.isEditMode) {
                                    if ([_delegate plycountMaggioreZero]) {
                                        [self.navigationController setPreferredContentSize:CGSizeMake(320.0, 550.0)];
                                    }
                                    else {
                                        [self.navigationController setPreferredContentSize:CGSizeMake(320.0, 400.0)];
                                    }
                                }
                                else {
                                    if ([_pgnGame isPosition]) {
                                        [self.navigationController setPreferredContentSize:CGSizeMake(320.0, 265.0)];
                                    }
                                    else {
                                        [self.navigationController setPreferredContentSize:CGSizeMake(320.0, 220.0)];
                                    }
                                }
                                [self.tableView reloadData];
                            } completion:NULL];
        });
    }
}


#pragma mark - Implementazione metodi AnnotationMoveTableViewControllerDelegate

- (void) cancelButtonPressed {
}

- (void) saveButtonPressed {
}

- (void) updateWebView {
    [_delegate updateWebViewAfterMoveAnnotation];
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
