//
//  TBDatabaseMenuTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 08/11/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "TBDatabaseMenuTableViewController.h"

@interface TBDatabaseMenuTableViewController () {

    NSArray *_listIndexFile;
    
    BOOL isPgnFile;
    
    
    
    NSMutableArray *listaCellText;
    NSMutableArray *listaCellDetail;
    
}

@property (nonatomic, assign, getter = isEditing) BOOL editing;

@end

@implementation TBDatabaseMenuTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //[self setContentSizeForViewInPopover:CGSizeMake(300, 420)];
        [self setPreferredContentSize:CGSizeMake(300.0, 420.0)];
        [self.tableView setScrollEnabled:NO];
        
    }
    return self;
}

- (id)initWithStyleAndEditMode:(UITableViewStyle)style :(BOOL)editMode {
    self = [super initWithStyle:style];
    if (self) {
        //[self setContentSizeForViewInPopover:CGSizeMake(350, 60)];
        [self setPreferredContentSize:CGSizeMake(350.0, 60.0)];
        [self.tableView setScrollEnabled:NO];
        _editing = editMode;
    }
    return self;
}

- (id)initWithStyleAndEditModeAndNumfile:(UITableViewStyle)style :(BOOL)editMode :(NSArray *)listFile {
    self = [super initWithStyle:style];
    if (self) {
        [self.tableView setScrollEnabled:NO];
        _editing = editMode;
        _listIndexFile = listFile;
        if (_listIndexFile.count > 0) {
            if (_listIndexFile.count == 1) {
                NSLog(@"INIT");
                //if (isPgnFile) {
                //    [self setPreferredContentSize:CGSizeMake(350.0, 420.0)];
                //}
                //else {
                //    [self setPreferredContentSize:CGSizeMake(350.0, 360.0)];
                //}
            }
            else {
                //[self setContentSizeForViewInPopover:CGSizeMake(350, 300)];
                [self setPreferredContentSize:CGSizeMake(350.0, 300.0)];
            }
        }
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
    
    self.navigationItem.title = NSLocalizedString(@"DATABASE-MENU", nil);
    
    
    //if (_listIndexFile.count > 0) {
    //    NSIndexPath *indexPath = [_listIndexFile objectAtIndex:0];
    //    NSString *dbName = [_listFile objectAtIndex:indexPath.row];
    //    NSLog(@"%@", dbName);
    //    isPgnFile = [dbName hasSuffix:@".pgn"];
    //}
    
    //NSLog(@"VIEW DID LOAD = %d", _listIndexFile.count);
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //NSLog(@"VIEW WILL APPEAR");
    NSString *dbName;
    if (_listIndexFile.count>0) {
        NSIndexPath *indexPath = [_listIndexFile objectAtIndex:0];
        dbName = [_listFile objectAtIndex:indexPath.row];
    }
    //NSLog(@"%@", dbName);
    isPgnFile = [dbName hasSuffix:@".pgn"];
    //NSLog(@"VIEW WILL APPEAR: %lu", (unsigned long)_listIndexFile.count);
    if (_editing) {
        if (_listIndexFile.count == 0) {
            [self setPreferredContentSize:CGSizeMake(350.0, 60.0)];
            return;
        }
        else if (_listIndexFile.count == 1 ) {
            //NSLog(@"IMPOSTO A 420");
            [self setPreferredContentSize:CGSizeMake(350.0, 420.0)];
            return;
        }
        else if (_listIndexFile.count > 1) {
            //NSLog(@"IMPOSTO A 360");
            [self setPreferredContentSize:CGSizeMake(350.0, 360.0)];
            return;
        }
        if (isPgnFile) {
            [self setPreferredContentSize:CGSizeMake(350.0, 420.0)];
        }
        else {
            [self setPreferredContentSize:CGSizeMake(350.0, 360.0)];
        }
    }
    else {
        if (_listIndexFile.count == 0 && _listFile.count == 0) {
            [self setPreferredContentSize:CGSizeMake(350.0, 300.0)];
            return;
        }
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
    if ([self isEditing]) {
        if (_listIndexFile.count > 0) {
            if (_listIndexFile.count == 1) {
                if (isPgnFile) {
                    return 7;
                }
                return 7;
            }
            else {
                return 6;
            }
        }
        return 1;
    }
    else if (_listIndexFile.count == 0 && _listFile.count == 0) {
        return 5;
    }
    return 7;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell TBDatabase Menu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if ([self isEditing]) {
        if (_listIndexFile.count > 0) {
            if (_listIndexFile.count == 1) {
                if (isPgnFile) {
                    if (indexPath.row == 0) {
                        cell.imageView.image = [UIImage imageNamed:@"DeleteDatabase"];
                        cell.textLabel.text = NSLocalizedString(@"DELETE_DB", nil);
                        cell.detailTextLabel.text = NSLocalizedString(@"DELETE-DB", nil);
                    }
                    else if (indexPath.row == 1) {
                        cell.imageView.image = [UIImage imageNamed:@"MoveDatabase"];
                        cell.textLabel.text = NSLocalizedString(@"MOVE_DB", nil);
                        cell.detailTextLabel.text = NSLocalizedString(@"MOVE-DB", nil);
                    }
                    else if (indexPath.row == 2) {
                        cell.imageView.image = [UIImage imageNamed:@"CopyDatabase"];
                        cell.textLabel.text = NSLocalizedString(@"COPY_DB", nil);
                        cell.detailTextLabel.text = NSLocalizedString(@"COPY-DB", nil);
                    }
                    else if (indexPath.row == 3) {
                        NSIndexPath *index = [_listIndexFile objectAtIndex:0];
                        NSString *dbName = [_listFile objectAtIndex:index.row];
                        //NSLog(@"%@", dbName);
                        if ([dbName hasSuffix:@".pgn"]) {
                            cell.imageView.image = [UIImage imageNamed:@"RenameDatabase"];
                            cell.textLabel.text = NSLocalizedString(@"MENU_RENAME_DATABASE", nil);
                            cell.detailTextLabel.text = NSLocalizedString(@"RENAME-DB", nil);
                        }
                        else {
                            cell.imageView.image = [UIImage imageNamed:@"RenameDatabase"];
                            cell.textLabel.text = NSLocalizedString(@"MENU_RENAME_FOLDER", nil);
                            cell.detailTextLabel.text = NSLocalizedString(@"RENAME-FOLDER", nil);
                        }
                    }
                    else if (indexPath.row == 4) {
                        cell.imageView.image = [UIImage imageNamed:@"SendDatabase"];
                        cell.textLabel.text = NSLocalizedString(@"MENU_EMAIL_DATABASE", nil);
                        cell.detailTextLabel.text = NSLocalizedString(@"EMAIL-DB", nil);
                    }
                    else if (indexPath.row == 5) {
                        cell.imageView.image = [UIImage imageNamed:@"EndManageDb"];
                        cell.textLabel.text = NSLocalizedString(@"DONE_DATABASE", nil);
                        cell.detailTextLabel.text = NSLocalizedString(@"END-MANAGE-DB", nil);
                    }
                    else if (indexPath.row == 6) {
                        cell.imageView.image = [UIImage imageNamed:@"Dropbox"];
                        cell.textLabel.text = NSLocalizedString(@"UPLOAD_DROPBOX_0", nil);
                        cell.detailTextLabel.text = NSLocalizedString(@"UPLOAD_DROPBOX", nil);
                    }
                }
                else {
                    if (indexPath.row == 0) {
                        cell.imageView.image = [UIImage imageNamed:@"DeleteDatabase"];
                        cell.textLabel.text = NSLocalizedString(@"DELETE_DB", nil);
                        cell.detailTextLabel.text = NSLocalizedString(@"DELETE-DB", nil);
                    }
                    else if (indexPath.row == 1) {
                        cell.imageView.image = [UIImage imageNamed:@"MoveDatabase"];
                        cell.textLabel.text = NSLocalizedString(@"MOVE_DB", nil);
                        cell.detailTextLabel.text = NSLocalizedString(@"MOVE-DB", nil);
                    }
                    else if (indexPath.row == 2) {
                        cell.imageView.image = [UIImage imageNamed:@"CopyDatabase"];
                        cell.textLabel.text = NSLocalizedString(@"COPY_DB", nil);
                        cell.detailTextLabel.text = NSLocalizedString(@"COPY-DB", nil);
                    }
                    else if (indexPath.row == 3) {
                        NSIndexPath *index = [_listIndexFile objectAtIndex:0];
                        NSString *dbName = [_listFile objectAtIndex:index.row];
                        //NSLog(@"%@", dbName);
                        if ([dbName hasSuffix:@".pgn"]) {
                            cell.imageView.image = [UIImage imageNamed:@"RenameDatabase"];
                            cell.textLabel.text = NSLocalizedString(@"MENU_RENAME_DATABASE", nil);
                            cell.detailTextLabel.text = NSLocalizedString(@"RENAME-DB", nil);
                        }
                        else {
                            cell.imageView.image = [UIImage imageNamed:@"RenameDatabase"];
                            cell.textLabel.text = NSLocalizedString(@"MENU_RENAME_FOLDER", nil);
                            cell.detailTextLabel.text = NSLocalizedString(@"RENAME-FOLDER", nil);
                        }
                    }
                    else if (indexPath.row == 4) {
                        cell.imageView.image = [UIImage imageNamed:@"SendDatabase"];
                        cell.textLabel.text = NSLocalizedString(@"MENU_EMAIL_DATABASE", nil);
                        cell.detailTextLabel.text = NSLocalizedString(@"EMAIL-DB", nil);
                    }
                    else if (indexPath.row == 5) {
                        cell.imageView.image = [UIImage imageNamed:@"EndManageDb"];
                        cell.textLabel.text = NSLocalizedString(@"DONE_DATABASE", nil);
                        cell.detailTextLabel.text = NSLocalizedString(@"END-MANAGE-DB", nil);
                    }
                    else if (indexPath.row == 6) {
                        cell.imageView.image = [UIImage imageNamed:@"Dropbox"];
                        cell.textLabel.text = NSLocalizedString(@"UPLOAD_DROPBOX_0", nil);
                        cell.detailTextLabel.text = NSLocalizedString(@"UPLOAD_DROPBOX", nil);
                    }
                }

            }
            else {
                if (indexPath.row == 0) {
                    cell.imageView.image = [UIImage imageNamed:@"DeleteDatabase"];
                    cell.textLabel.text = NSLocalizedString(@"DELETE_DB", nil);
                    cell.detailTextLabel.text = NSLocalizedString(@"DELETE-DB", nil);
                }
                else if (indexPath.row == 1) {
                    cell.imageView.image = [UIImage imageNamed:@"MoveDatabase"];
                    cell.textLabel.text = NSLocalizedString(@"MOVE_DB", nil);
                    cell.detailTextLabel.text = NSLocalizedString(@"MOVE-DB", nil);
                }
                else if (indexPath.row == 2) {
                    cell.imageView.image = [UIImage imageNamed:@"CopyDatabase"];
                    cell.textLabel.text = NSLocalizedString(@"COPY_DB", nil);
                    cell.detailTextLabel.text = NSLocalizedString(@"COPY-DB", nil);
                }
                else if (indexPath.row == 3) {
                    cell.imageView.image = [UIImage imageNamed:@"SendDatabase"];
                    cell.textLabel.text = NSLocalizedString(@"MENU_EMAIL_DATABASE", nil);
                    cell.detailTextLabel.text = NSLocalizedString(@"EMAIL-DB", nil);
                }
                else if (indexPath.row == 4) {
                    cell.imageView.image = [UIImage imageNamed:@"EndManageDb"];
                    cell.textLabel.text = NSLocalizedString(@"DONE_DATABASE", nil);
                    cell.detailTextLabel.text = NSLocalizedString(@"END-MANAGE-DB", nil);
                }
                else if (indexPath.row == 5) {
                    cell.imageView.image = [UIImage imageNamed:@"Dropbox"];
                    cell.textLabel.text = NSLocalizedString(@"UPLOAD_DROPBOX_0", nil);
                    cell.detailTextLabel.text = NSLocalizedString(@"UPLOAD_DROPBOX", nil);
                }
            }
        }
        else {
            if (indexPath.row == 0) {
                cell.imageView.image = [UIImage imageNamed:@"EndManageDb"];
                cell.textLabel.text = NSLocalizedString(@"DONE_DATABASE", nil);
                cell.detailTextLabel.text = NSLocalizedString(@"END-MANAGE-DB", nil);
            }
        }
    }
    else if (_listIndexFile.count == 0 && _listFile.count == 0) {
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"NewPgn"];
            cell.textLabel.text = NSLocalizedString(@"MENU_NEW_DATABASE", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"CREATE-PGN-DB", nil);
        }
        else if (indexPath.row == 1) {
            cell.imageView.image = [UIImage imageNamed:@"NewFolder"];
            cell.textLabel.text = NSLocalizedString(@"MENU_NEW_FOLDER", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"CREATE-FOLDER", nil);
        }
        else if (indexPath.row == 2) {
            cell.imageView.image = [UIImage imageNamed:@"DownloadPgn"];
            cell.textLabel.text = NSLocalizedString(@"MENU_ADD_DATABASE", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"DOWNLOAD-DB", nil);
        }
        else if (indexPath.row == 3) {
            cell.imageView.image = [UIImage imageNamed:@"PgnMentorDownload"];
            cell.textLabel.text = NSLocalizedString(@"MENU_DOWNOLAD_PGN_MENTOR", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"DOWNLOAD-PGN-MENTOR", nil);
        }
        else if (indexPath.row == 4) {
            cell.imageView.image = [UIImage imageNamed:@"Dropbox"];
            cell.textLabel.text = NSLocalizedString(@"DOWNLOAD_DROPBOX_0", nil);
            cell.detailTextLabel.text =  NSLocalizedString(@"DOWNLOAD_DROPBOX", nil);
        }
    }
    else {
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"NewPgn"];
            cell.textLabel.text = NSLocalizedString(@"MENU_NEW_DATABASE", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"CREATE-PGN-DB", nil);
        }
        else if (indexPath.row == 1) {
            cell.imageView.image = [UIImage imageNamed:@"NewFolder"];
            cell.textLabel.text = NSLocalizedString(@"MENU_NEW_FOLDER", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"CREATE-FOLDER", nil);
        }
        else if (indexPath.row == 2) {
            cell.imageView.image = [UIImage imageNamed:@"DownloadPgn"];
            cell.textLabel.text = NSLocalizedString(@"MENU_ADD_DATABASE", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"DOWNLOAD-DB", nil);
        }
        else if (indexPath.row == 3) {
            cell.imageView.image = [UIImage imageNamed:@"PasteGame"];
            cell.textLabel.text = NSLocalizedString(@"MENU_PASTE_GAME", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"PASTE-GAMES", nil);
        }
        else if (indexPath.row == 4) {
            cell.imageView.image = [UIImage imageNamed:@"ManageDb"];
            cell.textLabel.text = NSLocalizedString(@"MENU_MANAGE_DATABASE", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"MANAGE-DB", nil);
        }
        else if (indexPath.row == 5) {
            cell.imageView.image = [UIImage imageNamed:@"PgnMentorDownload"];
            cell.textLabel.text = NSLocalizedString(@"MENU_DOWNOLAD_PGN_MENTOR", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"DOWNLOAD-PGN-MENTOR", nil);
        }
        else if (indexPath.row == 6) {
            cell.imageView.image = [UIImage imageNamed:@"Dropbox"];
            cell.textLabel.text = NSLocalizedString(@"DOWNLOAD_DROPBOX_0", nil);
            cell.detailTextLabel.text =  NSLocalizedString(@"DOWNLOAD_DROPBOX", nil);
        }
    }
    
    cell.detailTextLabel.textColor = [UIColor redColor];
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *text = selectedCell.textLabel.text;
    if (_delegate) {
        [_delegate choiceMenu:text];
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
