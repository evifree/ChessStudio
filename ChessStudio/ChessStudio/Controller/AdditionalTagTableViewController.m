//
//  AdditionalTagTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 16/05/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "AdditionalTagTableViewController.h"
#import "UtilToView.h"
#import "GamePreviewTableViewController.h"

@interface AdditionalTagTableViewController () {

    NSDictionary *tagDictionary;
    NSMutableDictionary *tagSelected;
    
    BOOL oneTagSelected;
    
}

@end

@implementation AdditionalTagTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //[self setContentSizeForViewInPopover: CGSizeMake(320.0f, 720.0f)];
        [self setPreferredContentSize:CGSizeMake(320.0f, 720.0f)];
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
    
    self.navigationController.toolbarHidden = YES;
    
    oneTagSelected = NO;
    
    //tagDictionary = [UtilToView getAdditionalTagSectionValues];
    tagDictionary = [UtilToView getSupplementalTagSectionValues];
    tagSelected = [[NSMutableDictionary alloc] init];
    self.navigationItem.title = NSLocalizedString(@"SUPPLEMENTAL_TAGS", nil);
    
    for (NSString *tagSection in tagDictionary.allKeys) {
        NSArray *tagArray = [tagDictionary objectForKey:tagSection];
        for (NSString *tagName in tagArray) {
            //if ([_pgnGame supplementalTagIsPresent:tagName]) {
            if ([_orderedSupplementalTag containsObject:tagName]) {
                [tagSelected setObject:[NSNumber numberWithBool:YES] forKey:tagName];
            }
            else {
                [tagSelected setObject:[NSNumber numberWithBool:NO] forKey:tagName];
            }
        }
    }
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonItemPressed)];
    self.navigationItem.rightBarButtonItem = saveBarButtonItem;
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonItemPressed)];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) saveButtonItemPressed {
    if (_delegate) {
        [_delegate saveSupplementalTag:tagSelected];
    }
    oneTagSelected = YES;
    
    if ([_delegate isKindOfClass:[GamePreviewTableViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void) cancelButtonItemPressed {
    if (oneTagSelected) {
        [self displayAlert];
        return;
    }
    if ([_delegate isKindOfClass:[GamePreviewTableViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[UtilToView getAdditionalTagSection] count];
    //return [[UtilToView getAdditionalTagSection] count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section<[[UtilToView getAdditionalTagSection] count]) {
        NSString *tagSection = [[UtilToView getAdditionalTagSection] objectAtIndex:section];
        NSArray *tagArray = [tagDictionary objectForKey:tagSection];
        return tagArray.count;
    }
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section<[[UtilToView getAdditionalTagSection] count]) {
        return [[UtilToView getAdditionalTagSection] objectAtIndex:section];
    }
    return NSLocalizedString(@"TAG_CUSTOM", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    if (indexPath.section<[[UtilToView getAdditionalTagSection] count]) {
        NSString *tagSection = [[UtilToView getAdditionalTagSection] objectAtIndex:indexPath.section];
        NSArray *tagArray = [tagDictionary objectForKey:tagSection];
        NSString *tagName = [tagArray objectAtIndex:indexPath.row];
        cell.textLabel.text = tagName;
        /*
        if ([_pgnGame supplementalTagIsPresent:tagName]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }*/
        
        BOOL presente = [[tagSelected objectForKey:tagName] boolValue];
        if (presente) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
    }
    else {
        cell.textLabel.text = NSLocalizedString(@"TAG_NEW", nil);
    }
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
      <#DetailViewController#>*detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    [self performSelector: @selector(deselectCell:) withObject:tableView afterDelay:0.1f];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *tagSel = nil;
    if (indexPath.section < [[UtilToView getAdditionalTagSection] count]) {
        NSString *tagSection = [[UtilToView getAdditionalTagSection] objectAtIndex:indexPath.section];
        NSArray *tagArray = [tagDictionary objectForKey:tagSection];
        tagSel = [tagArray objectAtIndex:indexPath.row];
        //NSLog(@"TAG SEL = %@", tagSel);
    }
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [tagSelected setObject:[NSNumber numberWithBool:NO] forKey:tagSel];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tagSelected setObject:[NSNumber numberWithBool:YES] forKey:tagSel];
    }
    
    oneTagSelected = YES;
}

- (void)deselectCell:(UITableView *)tableView {
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:NO];
}

#pragma mark - Implementazione metodi UIAlertViewDelegate

- (void) displayAlert {
    UIAlertView *salvaModificheAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SAVE_SELECTED_TAGS_TITLE", nil) message:NSLocalizedString(@"SAVE_SELECTED_TAGS_ALERT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"YES", nil) otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
    salvaModificheAlertView.tag = 10;
    [salvaModificheAlertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        NSString *risposta = [alertView buttonTitleAtIndex:buttonIndex];
        if ([risposta isEqualToString:NSLocalizedString(@"YES", nil)]) {
            if ([_delegate isKindOfClass:[GamePreviewTableViewController class]]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

@end
