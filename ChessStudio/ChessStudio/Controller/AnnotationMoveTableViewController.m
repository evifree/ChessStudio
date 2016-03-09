//
//  AnnotationMoveTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 31/05/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "AnnotationMoveTableViewController.h"
#import "UtilToView.h"
#import "BoardViewControllerMenuTableViewController.h"

@interface AnnotationMoveTableViewController () {
    NSString *titleForSection;
    
    NSIndexPath *lastMoveAnnotationIndexPath;
    NSIndexPath *lastPositionAnnotationIndexPath;
    NSIndexPath *lastMovePrefixIndexPath;
    
    
    NSString *moveAnnotation;
    NSString *positionAnnotation;
    NSString *movePrefix;
}

@end

@implementation AnnotationMoveTableViewController

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
    
    //[self setContentSizeForViewInPopover:CGSizeMake(350, 450)];
    [self setPreferredContentSize:CGSizeMake(350, 450)];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
        
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    self.navigationItem.title = titleForSection;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setMossaDaAnnotare:(PGNMove *)mossaDaAnnotare {
    _mossaDaAnnotare = mossaDaAnnotare;
    titleForSection = [_mossaDaAnnotare getMossaPerVarianti];
    
    NSLog(@"%@", titleForSection);
    
    moveAnnotation = nil;
    positionAnnotation = nil;
    movePrefix = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    //return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [[UtilToView getMoveAnnotationText] count];
    }
    if (section == 1) {
        return [[UtilToView getPositionAnnotationText] count];
    }
    return [[UtilToView getPrefixAnnotationText] count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        //return [NSString stringWithFormat:@"Annotation for %@", titleForSection];
        return NSLocalizedString(@"MOVE_ANNOTATION", nil);
    }
    else if (section == 1) {
        //return [NSString stringWithFormat:@"Position annotation after %@", titleForSection];
        return NSLocalizedString(@"POSITION_ANNOTATION", nil);
    }
    else if (section == 2) {
        //return [NSString stringWithFormat:@"Prefix for %@", titleForSection];
        return NSLocalizedString(@"PREFIX_ANNOTATION", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Annotation Move";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    if (indexPath.section == 0) {
        //cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif", [[UtilToView getMoveAnnotationImage] objectAtIndex:indexPath.row]]];
        //cell.textLabel.text = [[UtilToView getMoveAnnotationText] objectAtIndex:indexPath.row];
        [cell addSubview:[self getLabelAttributedString:indexPath.row]];
        if (indexPath.row < 7) {
            if ([_mossaDaAnnotare containsNag:[NSString stringWithFormat:@"%ld", (long)indexPath.row]]) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                lastMoveAnnotationIndexPath = indexPath;
            }
            else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
        if (indexPath.row == 7 || indexPath.row == 8) {
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
            sw.tag = indexPath.row;
            [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            if ([_mossaDaAnnotare containsNag:[NSString stringWithFormat:@"%@", [[UtilToView getMoveAnnotationImage] objectAtIndex:indexPath.row]]]) {
                [sw setOn:YES];
            }
            else {
                [sw setOn:NO];
            }
        }
    }
    
    if (indexPath.section == 1) {
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif", [[UtilToView getPositionAnnotationImage] objectAtIndex:indexPath.row]]];
        cell.textLabel.text = [[UtilToView getPositionAnnotationText] objectAtIndex:indexPath.row];
    }
    
    if (indexPath.section == 2) {
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.gif", [[UtilToView getPrefixAnnotationImage] objectAtIndex:indexPath.row]]];
        cell.textLabel.text = [[UtilToView getPrefixAnnotationText] objectAtIndex:indexPath.row];
    }
    
    // Configure the cell...
    
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell accessoryType] == UITableViewCellAccessoryCheckmark) {
        return;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row < 7) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            //moveAnnotation = cell.textLabel.text;
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastMoveAnnotationIndexPath];
            [oldCell setAccessoryType:UITableViewCellAccessoryNone];
            lastMoveAnnotationIndexPath = indexPath;
            moveAnnotation = [[UtilToView getMoveAnnotationImage] objectAtIndex:indexPath.row];
            [_mossaDaAnnotare setMoveAnnotation:moveAnnotation];
            self.navigationItem.title = [_mossaDaAnnotare getMossaPerVarianti];
            [_delegate updateWebView];
        }
    }
    else if (indexPath.section == 1) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        positionAnnotation = cell.textLabel.text;
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastPositionAnnotationIndexPath];
        [oldCell setAccessoryType:UITableViewCellAccessoryNone];
        lastPositionAnnotationIndexPath = indexPath;
    }
    else if (indexPath.section == 2) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        movePrefix = cell.textLabel.text;
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastMovePrefixIndexPath];
        [oldCell setAccessoryType:UITableViewCellAccessoryNone];
        lastMovePrefixIndexPath = indexPath;
    }
}


- (void) switchChanged:(id) sender {
    UISwitch *sw = (UISwitch *)sender;
    moveAnnotation = [[UtilToView getMoveAnnotationImage] objectAtIndex:sw.tag];
    if ([sw isOn]) {
        [_mossaDaAnnotare setMoveAnnotation:moveAnnotation];
    }
    else {
        [_mossaDaAnnotare removeMoveAnnotation:moveAnnotation];
    }
    self.navigationItem.title = [_mossaDaAnnotare getMossaPerVarianti];
    [_delegate updateWebView];
}

#pragma mark - Implementazione metodi con Attributed String per cambiare i segni

- (UILabel *) getLabelAttributedString:(NSInteger)riga {
    NSDictionary *attributoW = @{NSFontAttributeName:[UIFont fontWithName:@"ISChess" size:20.0]};
    
    NSString *testo = nil;
    if (riga == 0) {
        testo = [NSString stringWithFormat:@"      %@", [[UtilToView getMoveAnnotationText] objectAtIndex:riga]];
    }
    else if (riga == 1) {
        testo = [NSString stringWithFormat:@"]     %@", [[UtilToView getMoveAnnotationText] objectAtIndex:riga]];
    }
    else if (riga == 2) {
        testo = [NSString stringWithFormat:@"_     %@", [[UtilToView getMoveAnnotationText] objectAtIndex:riga]];
    }
    else if (riga == 3) {
        testo = [NSString stringWithFormat:@"^     %@", [[UtilToView getMoveAnnotationText] objectAtIndex:riga]];
    }
    else if (riga == 4) {
        testo = [NSString stringWithFormat:@"\u0060     %@", [[UtilToView getMoveAnnotationText] objectAtIndex:riga]];
    }
    else if (riga == 5) {
        testo = [NSString stringWithFormat:@"a     %@", [[UtilToView getMoveAnnotationText] objectAtIndex:riga]];
    }
    else if (riga == 6) {
        testo = [NSString stringWithFormat:@"b     %@", [[UtilToView getMoveAnnotationText] objectAtIndex:riga]];
    }
    else if (riga == 7) {
        testo = [NSString stringWithFormat:@"d     %@", [[UtilToView getMoveAnnotationText] objectAtIndex:riga]];
    }
    else if (riga == 8) {
        testo = [NSString stringWithFormat:@"N     %@", [[UtilToView getMoveAnnotationText] objectAtIndex:riga]];
    }
    NSLog(@"%@", testo);
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:testo];
    [attrStr addAttributes:attributoW range:NSMakeRange(0, 1)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 300, 44)];
    label.text = testo;
    
    if (riga == 8) {
        return label;
    }
    
    [label setAttributedText:attrStr];
    return label;
}



#pragma mark - Implementazione metodi azioni button

- (void) cancelButtonPressed {
    moveAnnotation = nil;
    positionAnnotation = nil;
    movePrefix = nil;
    
    if ([_delegate isKindOfClass:[BoardViewControllerMenuTableViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    
    if (IS_PHONE) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [_delegate cancelButtonPressed];
    }
}

- (void) saveButtonPressed {
    if (moveAnnotation) {
        NSLog(@"Devo Salvare Move Annotation = %@", moveAnnotation);
    }
    if (positionAnnotation) {
        NSLog(@"Devo Salvare Position Annotation = %@", positionAnnotation);
    }
    if (movePrefix) {
        NSLog(@"Devo Salvare Prefix annotation = %@", movePrefix);
    }
    
    if ([_delegate isKindOfClass:[BoardViewControllerMenuTableViewController class]]) {
        [_delegate updateWebView];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    
    if (IS_PHONE) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [_delegate saveButtonPressed];
    }
}

@end
