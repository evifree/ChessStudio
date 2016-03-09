//
//  ControllerTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 16/05/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "ControllerTableViewController.h"
#import "GameSetting.h"

@interface ControllerTableViewController () {

    GameSetting *gameSetting;
    
    NSInteger indexNextGame;
    NSInteger indexPreviousGame;
    
    
    UITableViewHeaderFooterView *thfv;
    
}

@end

@implementation ControllerTableViewController

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
    
    //UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.leftBarButtonItem = doneButtonItem;
    
    self.navigationItem.title = NSLocalizedString(@"CONTROLLER_GAME", nil);
    gameSetting = [GameSetting sharedGameSetting];
    
    
    [self setupNavigationBar];
    
    
    indexNextGame = _indexGame + 2;
    indexPreviousGame = _indexGame - 1;
    if (indexPreviousGame < 0) {
        indexPreviousGame = 0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doneButtonPressed {
    if (_delegate) {
        [_delegate doneButtonPressed];
    }
    if (!IS_PAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) setupNavigationBar {
    //if (IS_IOS_7) {
        //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    //}
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (IS_IOS_7) {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_displayLoadGames) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_displayLoadGames) {
        if (section == 0) {
            return 2;
        }
        else if (section == 1) {
            return 2;
        }
        else if (section == 2) {
            return 1;
        }
    }
    else {
        if (section == 0) {
            return 2;
        }
        else if (section == 1) {
            return 1;
        }
    }

    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_displayLoadGames) {
        if (section == 0) {
            NSString *title = [_nameDatabase stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"GAME_NUMBER", nil), _indexGame + 1]];
            return title;
        }
        else if (section == 1) {
            return NSLocalizedString(@"GAME REPLAY", nil);
        }
        else if (section == 2) {
            return NSLocalizedString(@"POSITIONAL ELEMENTS", nil);
        }
    }
    else {
        if (section == 0) {
            return NSLocalizedString(@"GAME REPLAY", nil);
        }
        else if (section == 1) {
            return NSLocalizedString(@"POSITIONAL ELEMENTS", nil);
        }
    }

    return nil;
}

- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (IS_IOS_7) {
        if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
            thfv = (UITableViewHeaderFooterView *)view;
            //[thfv setFrame:CGRectMake(0, 0, thfv.frame.size.width, thfv.frame.size.height + 20)];
            thfv.textLabel.textColor = [UIColor whiteColor];
            //thfv.contentView.backgroundColor = UIColorFromRGB(0xFFD700);
            //thfv.contentView.backgroundColor = [UIColor blackColor];
            thfv.contentView.backgroundColor = [UIColor blackColor];
            thfv.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
            //thfv.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14.0];
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Controller";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    if (_displayLoadGames) {
        if (indexPath.section == 0) {
            
            //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            //cell.textLabel.adjustsFontSizeToFitWidth = YES;
            
            if (indexPath.row == 0) {
                //cell.textLabel.text = [NSLocalizedString(@"NEXT_GAME", nil) stringByAppendingString:[NSString stringWithFormat:@" %ld", (long)indexNextGame]];
                cell.textLabel.text = NSLocalizedString(@"NEXT_GAME", nil);
                //cell.detailTextLabel.textColor = [UIColor redColor];
                //cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)indexNextGame];
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"PREVIOUS_GAME", nil);
                //cell.detailTextLabel.textColor = [UIColor redColor];
                //cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPreviousGame];
            }
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"FORWARD", nil);
                //UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                //switchView.tag = 200;
                //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
                //cell.accessoryView = switchView;
                //[switchView setOn:[gameSetting forwardAnimated]];
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"BACKWARD", nil);
                //UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                //switchView.tag = 300;
                //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
                //cell.accessoryView = switchView;
                //[switchView setOn:[gameSetting backAnimated]];
            }
            else if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"LOAD_NEXT_GAME", nil);
            }
        }
        else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"PAWN STRUCTURE", nil);
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                //switchView.tag = 100;
                //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
                [switchView addTarget:self action:@selector(pawnStructureSwitched:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = switchView;
                [switchView setOn:[gameSetting pawnStructure]];
            }
        }
    }
    else {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"FORWARD", nil);
                //UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                //switchView.tag = 200;
                //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
                //cell.accessoryView = switchView;
                //[switchView setOn:[gameSetting forwardAnimated]];
            }
            else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"BACKWARD", nil);
                //UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                //switchView.tag = 300;
                //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
                //cell.accessoryView = switchView;
                //[switchView setOn:[gameSetting backAnimated]];
            }
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"PAWN STRUCTURE", nil);
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                //switchView.tag = 100;
                //[switchView addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
                [switchView addTarget:self action:@selector(pawnStructureSwitched:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = switchView;
                [switchView setOn:[gameSetting pawnStructure]];
            }
        }

    }

    
    // Configure the cell...
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_displayLoadGames) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                if (_delegate) {
                    _indexGame = [_delegate loadNextGameFromDatabase];
                    if (_indexGame == -1) {
                        return;
                    }
                    indexNextGame = _indexGame + 2;
                    indexPreviousGame = _indexGame;
                    [tableView reloadData];
                }
            }
            else if (indexPath.row == 1) {
                if (_delegate) {
                    _indexGame = [_delegate loadPreviousGameFromDatabase];
                    if (_indexGame == -1) {
                        return;
                    }
                    if (_indexGame == 0) {
                        indexPreviousGame = _indexGame;
                        indexNextGame = 2;
                    }
                    else {
                        indexPreviousGame = _indexGame;
                        indexNextGame = _indexGame + 2;
                    }
                    [tableView reloadData];
                }
            }
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                [gameSetting setForwardAnimated:YES];
                if (_delegate) {
                    if (!IS_PAD) {
                        [self dismissViewControllerAnimated:NO completion:^{
                            [_delegate startForwardAnimation];
                            return;
                        }];
                    }
                    [_delegate startForwardAnimation];
                }
            }
            else if (indexPath.row == 1) {
                [gameSetting setBackAnimated:YES];
                if (_delegate) {
                    if (!IS_PAD) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    [_delegate startBackAnimation];
                }
            }
        }
    }
    else {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                [gameSetting setForwardAnimated:YES];
                if (_delegate) {
                    if (!IS_PAD) {
                        [self dismissViewControllerAnimated:NO completion:^{
                            [_delegate startForwardAnimation];
                            return;
                        }];
                    }
                    [_delegate startForwardAnimation];
                }
            }
            else if (indexPath.row == 1) {
                [gameSetting setBackAnimated:YES];
                if (_delegate) {
                    if (!IS_PAD) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    [_delegate startBackAnimation];
                }
            }
        }
    }

}

- (void) updateSwitch:(UISwitch *)switchView {
    if (switchView.tag == 100) {
        [gameSetting setPawnStructure:switchView.on];
        if (_delegate) {
            [_delegate managePawnStructure];
        }
    }
    else if (switchView.tag == 200) {
        [gameSetting setForwardAnimated:switchView.on];
        if (_delegate) {
            if (!IS_PAD) {
                //[self dismissViewControllerAnimated:NO completion:nil];
                [self dismissViewControllerAnimated:NO completion:^{
                    [_delegate startForwardAnimation];
                    return;
                }];
            }
            [_delegate startForwardAnimation];
        }
    }
    else if (switchView.tag == 300) {
        [gameSetting setBackAnimated:switchView.on];
        if (_delegate) {
            if (!IS_PAD) {
                //[self dismissModalViewControllerAnimated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            [_delegate startBackAnimation];
        }
    }
}

- (void) pawnStructureSwitched:(UISwitch *)switchView {
    [gameSetting setPawnStructure:switchView.on];
    if (_delegate) {
        [_delegate managePawnStructure];
    }
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
