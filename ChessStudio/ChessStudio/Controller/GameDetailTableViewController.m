//
//  GameDetailTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 15/05/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "GameDetailTableViewController.h"
#import "UtilToView.h"

@interface GameDetailTableViewController () {
    
    UIAlertView *inputAlertView;
    
    NSMutableDictionary *additionalTagDictionary;
    NSMutableDictionary *tagValueDictionary;
    NSMutableArray *additionalTagArray;
    
    NSString *selectedResult;
    NSString *selectedDate;
    
    NSString *letterEco;
    NSString *firstNumberEco;
    NSString *secondNumberEco;
    
    
    UIActionSheet *doneActionSheetMenu;
    UIPopoverController *tagPopover;
    
    UITableViewCell *selectedCell;
    UIPopoverController *popoverController;
}

@end

@implementation GameDetailTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView {
    [super loadView];
    
    [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneMenuButtonPressed:)]];
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionMenuButtonPressed:)]];
    
    self.navigationItem.title = @"Save Game";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
    
    
    additionalTagDictionary = [[NSMutableDictionary alloc] init];
    tagValueDictionary = [[NSMutableDictionary alloc] init];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    for (int i=0; i<7; i++) {
        NSString *tagValue = [_pgnGame getTagValueByTagName:[UtilToView getTagRosterByIndex:i]];
        [tagValueDictionary setObject:tagValue forKey:[UtilToView getTagRosterByIndex:i]];
        //[tagValueDictionary setObject:[UtilToView getTagRosterDefaultValueByIndex:i] forKey:[UtilToView getTagRosterByIndex:i]];
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 7;
    }
    else if (section == 2) {
        return _pgnGame.getNumberOfSupplementalTag;
    }
    else if (section == 3) {
        return 1;
    }
    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"DBNAME", nil);
    }
    if (section == 1) {
        return NSLocalizedString(@"GAME_PREVIEW_SECTION_0_TITLE", nil);
    }
    if ((section == 2) && (additionalTagArray.count > 0)) {
        return NSLocalizedString(@"GAME_PREVIEW_SECTION_1_TITLE", nil);
    }
    if (section == 3) {
        return NSLocalizedString(@"GAME_PREVIEW_SECTION_2_TITLE", nil);
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 3) {
        CGSize constraint;
        CGSize size;
        
        UILabel *testSizeLabel = [[UILabel alloc] init];
        testSizeLabel.text = _pgnGame.moves;
        testSizeLabel.numberOfLines = 0;
        
        if (IS_PAD) {
            constraint = CGSizeMake(768.0, 20000.0f);
            //size = [_pgnGame.moves sizeWithFont:[UIFont fontWithName:@"Arial" size:16] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            testSizeLabel.font = [UIFont fontWithName:@"Arial" size:16.0];
            size = [testSizeLabel sizeThatFits:constraint];
        }
        else {
            constraint = CGSizeMake(400.0, 1000.0f);
            //size = [_pgnGame.moves sizeWithFont:[UIFont fontWithName:@"Arial" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            testSizeLabel.font = [UIFont fontWithName:@"Arial" size:14.0];
            size = [testSizeLabel sizeThatFits:constraint];
        }
        CGFloat height = MAX(size.height, 44.0f);
        
        return height + 20;
    }
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    
    // Configure the cell...
    
    if (indexPath.section == 0) {
        [[cell textLabel] setText: _databaseName];
        //[[cell detailTextLabel] setText:@"?"];
        //[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
    }
    else if (indexPath.section == 1) {
        NSString *tag = [[UtilToView getTagRosterByIndex:indexPath.row] stringByAppendingString:@": "];
        cell.textLabel.text = tag;
    
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        if (!label) {
            //CGSize expectedCellLabelSize = [tag sizeWithFont:cell.textLabel.font];
            CGSize expectedCellLabelSize = [tag sizeWithAttributes:@{NSFontAttributeName:cell.textLabel.font}];
            label = [[UILabel alloc] initWithFrame:CGRectMake(expectedCellLabelSize.width + 10, 7, 350, 30)];
            label.tag = 1;
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor redColor];
            label.text = [tagValueDictionary objectForKey:[UtilToView getTagRosterByIndex:indexPath.row]];
            //label.text = [_pgnGame getTagValueByTagName:[UtilToView getTagRosterByIndex:indexPath.row]];
            [cell.contentView addSubview:label];
        }
        else {
            label.text = [tagValueDictionary objectForKey:[UtilToView getTagRosterByIndex:indexPath.row]];
            //label.text = [_pgnGame getTagValueByTagName:[UtilToView getTagRosterByIndex:indexPath.row]];
        }
    }
    else if (indexPath.section == 2) {
        //NSString *tag = [[additionalTagArray objectAtIndex:indexPath.row] stringByAppendingString:@": "];
        NSString *tag = [[_pgnGame getSupplementalTagByIndex:indexPath.row] stringByAppendingString:@": "];
        cell.textLabel.text = tag;
        UILabel *label = (UILabel *)[cell viewWithTag:2];
        if (!label) {
            //CGSize expectedCellLabelSize = [tag sizeWithFont:cell.textLabel.font];
            CGSize expectedCellLabelSize = [tag sizeWithAttributes:@{NSFontAttributeName:cell.textLabel.font}];
            label = [[UILabel alloc] initWithFrame:CGRectMake(expectedCellLabelSize.width + 10, 7, 350, 30)];
            label.tag = 2;
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor blueColor];
            //label.text = [additionalTagDictionary objectForKey:[additionalTagArray objectAtIndex:indexPath.row]];
            label.text = [_pgnGame getSupplementalTagValueByIndex:indexPath.row];
            [cell.contentView addSubview:label];
        }
        else {
            //label.text = [additionalTagDictionary objectForKey:[additionalTagArray objectAtIndex:indexPath.row]];
            label.text = [_pgnGame getSupplementalTagValueByIndex:indexPath.row];
        }
    }
    else if (indexPath.section == 3) {
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        if (IS_PAD) {
            //cell.textLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:15];
            cell.textLabel.font=[UIFont fontWithName:@"Courier" size:15];
        }
        else {
            cell.textLabel.font=[UIFont fontWithName:@"Arial" size:11];
        }
        cell.textLabel.text = [_pgnGame moves];
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
    
    [self performSelector: @selector(deselectCell:) withObject:tableView afterDelay:0.1f];
    
    if (indexPath.section == 1) {//Gestione tag obbligatori
        
        selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        
        switch (indexPath.row) {
            case 0:
            case 1:
            case 3:
            case 4:
            case 5: {
                UIViewController *viewController = [[UIViewController alloc] init];
                UIView *view = [[UIView alloc] init];   //view
                UITextField *tf1 = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
                tf1.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
                tf1.borderStyle = UITextBorderStyleRoundedRect;
                tf1.backgroundColor = [UIColor whiteColor];
                tf1.textColor = [UIColor redColor];
                tf1.textAlignment = NSTextAlignmentLeft;
                tf1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                tf1.autocorrectionType = UITextAutocorrectionTypeNo;
                tf1.delegate = self;
                tf1.tag = indexPath.row + 1;
                [view addSubview:tf1];
                viewController.view = view;
                NSString *value = [tagValueDictionary objectForKey:[UtilToView getTagRosterByIndex:indexPath.row]];
                if ([value hasPrefix:@"?"]) {
                    [tf1 setPlaceholder:value];
                }
                else {
                    [tf1 setText:value];
                }
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
                viewController.navigationItem.title = [UtilToView getTagRosterByIndex:indexPath.row];
                UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
                cancelButtonItem.tag = indexPath.row + 1;
                viewController.navigationItem.leftBarButtonItem = cancelButtonItem;
                
                UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
                doneButtonItem.tag = indexPath.row + 1;
                viewController.navigationItem.rightBarButtonItem = doneButtonItem;
                
                UILabel *label = (UILabel *)[selectedCell viewWithTag:1];
                NSLog(@"%@", label);
                CGRect rect = CGRectMake(30, 1, 300, 20);
                
                popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
                [popoverController setPopoverContentSize:CGSizeMake(320, 87) animated:NO];
                [popoverController presentPopoverFromRect:rect inView:selectedCell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                [tf1 becomeFirstResponder];
                break;
            }
            case 2: {
                UIViewController *viewController = [[UIViewController alloc] init];
                UIView *view = [[UIView alloc] init];   //view
                view.backgroundColor = [UIColor grayColor];
                
                UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
                datePicker.datePickerMode = UIDatePickerModeDate;
                [view addSubview:datePicker];
                datePicker.tag = indexPath.row + 1;
                viewController.view = view;
                
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
                viewController.navigationItem.title = @"Date";
                
                UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
                cancelButtonItem.tag = indexPath.row + 1;
                viewController.navigationItem.leftBarButtonItem = cancelButtonItem;
                
                UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
                doneButtonItem.tag = indexPath.row + 1;
                viewController.navigationItem.rightBarButtonItem = doneButtonItem;
                
                popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
                [popoverController setPopoverContentSize:CGSizeMake(320, 216) animated:NO];
                
                selectedCell = [tableView cellForRowAtIndexPath:indexPath];
                CGRect rect = CGRectMake(30, 1, 300, 30);
                [popoverController presentPopoverFromRect:rect inView:selectedCell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                break;
            }
            case 6: {
                UIActionSheet *resultActionSheet = [[UIActionSheet alloc] init];
                for (NSString *result in [UtilToView getResultsArray]) {
                    [resultActionSheet addButtonWithTitle:result];
                }
                resultActionSheet.tag = indexPath.row + 1;
                resultActionSheet.delegate = self;
                
                if (IS_PHONE) {
                    resultActionSheet.cancelButtonIndex = [resultActionSheet addButtonWithTitle:@"Cancel"];
                }
                
                selectedCell = [tableView cellForRowAtIndexPath:indexPath];
                //CGSize expectedCellLabelSize = [selectedCell.textLabel.text sizeWithFont:selectedCell.textLabel.font];
                CGSize expectedCellLabelSize = [selectedCell.textLabel.text sizeWithAttributes:@{NSFontAttributeName:selectedCell.textLabel.font}];
                CGRect resultRect = CGRectMake(expectedCellLabelSize.width + 10, 5, expectedCellLabelSize.width, selectedCell.bounds.size.height);
                [resultActionSheet showFromRect:resultRect inView:selectedCell animated:YES];
                break;
            }
            default:
                break;
        }
    }
    else if (indexPath.section == 2) {
        selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        selectedResult = nil;
        selectedDate = nil;
        //NSString *tag = [additionalTagArray objectAtIndex:indexPath.row];
        NSString *tag = [_pgnGame getSupplementalTagByIndex:indexPath.row];
        if ([tag hasSuffix:@"Title"]) {
            UIActionSheet *titleActionSheet = [[UIActionSheet alloc] init];
            
            for (NSString *title in [UtilToView getTitleArray]) {
                [titleActionSheet addButtonWithTitle:title];
            }
            titleActionSheet.delegate = self;
            titleActionSheet.tag = indexPath.row + 10;
            
            if (IS_PHONE) {
                titleActionSheet.cancelButtonIndex = [titleActionSheet addButtonWithTitle:@"Cancel"];
            }
            
            //CGSize expectedCellLabelSize = [selectedCell.textLabel.text sizeWithFont:selectedCell.textLabel.font];
            CGSize expectedCellLabelSize = [tag sizeWithAttributes:@{NSFontAttributeName:selectedCell.textLabel.font}];
            CGRect myRect = CGRectMake(expectedCellLabelSize.width + 10, 5, expectedCellLabelSize.width, selectedCell.bounds.size.height);
            
            [titleActionSheet showFromRect:myRect inView:selectedCell animated:YES];
        }
        else if ([tag isEqualToString:@"EventDate"]) {
            UIViewController *viewController = [[UIViewController alloc] init];
            UIView *view = [[UIView alloc] init];   //view
            view.backgroundColor = [UIColor grayColor];
            
            UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
            datePicker.datePickerMode = UIDatePickerModeDate;
            [view addSubview:datePicker];
            datePicker.tag = indexPath.row + 10;
            viewController.view = view;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            viewController.navigationItem.title = @"EventDate";
            
            popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
            [popoverController setPopoverContentSize:CGSizeMake(320, 216) animated:NO];
            
            UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
            cancelButtonItem.tag = indexPath.row + 10;
            viewController.navigationItem.leftBarButtonItem = cancelButtonItem;
            
            UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
            doneButtonItem.tag = indexPath.row + 10;
            viewController.navigationItem.rightBarButtonItem = doneButtonItem;
            
            CGRect rect = CGRectMake(30, 1, 370, 30);
            
            [popoverController presentPopoverFromRect:rect inView:selectedCell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else if ([tag isEqualToString:@"ECO"]) {
            letterEco = @"A";
            firstNumberEco = @"0";
            secondNumberEco = @"0";
            
            UIViewController *viewController = [[UIViewController alloc] init];
            UIView *view = [[UIView alloc] init];   //view
            view.backgroundColor = [UIColor grayColor];
            UIPickerView *ecoPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
            ecoPicker.tag = indexPath.row + 10;
            ecoPicker.showsSelectionIndicator = YES;
            ecoPicker.delegate = self;
            [view addSubview:ecoPicker];
            viewController.view = view;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            viewController.navigationItem.title = @"ECO";
            
            popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
            [popoverController setPopoverContentSize:CGSizeMake(320, 216) animated:NO];
            
            UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
            cancelButtonItem.tag = indexPath.row + 10;
            viewController.navigationItem.leftBarButtonItem = cancelButtonItem;
            
            UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
            doneButtonItem.tag = indexPath.row + 10;
            viewController.navigationItem.rightBarButtonItem = doneButtonItem;
            
            CGRect rect = CGRectMake(30, 1, 370, 30);
            [popoverController presentPopoverFromRect:rect inView:selectedCell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            UIViewController *viewController = [[UIViewController alloc] init];
            UIView *view = [[UIView alloc] init];   //view
            UITextField *tf1 = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
            tf1.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
            tf1.borderStyle = UITextBorderStyleRoundedRect;
            tf1.backgroundColor = [UIColor whiteColor];
            tf1.textColor = [UIColor redColor];
            tf1.textAlignment = NSTextAlignmentLeft;
            tf1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            tf1.autocorrectionType = UITextAutocorrectionTypeNo;
            tf1.delegate = self;
            tf1.tag = indexPath.row + 10;
            [view addSubview:tf1];
            viewController.view = view;
            
            NSString *value = [additionalTagDictionary objectForKey:[additionalTagArray objectAtIndex:indexPath.row]];
            if ([value hasPrefix:@"?"]) {
                [tf1 setPlaceholder:value];
            }
            else {
                [tf1 setText:value];
            }
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            viewController.navigationItem.title = [additionalTagArray objectAtIndex:indexPath.row];
            
            UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
            cancelButtonItem.tag = indexPath.row + 10;
            viewController.navigationItem.leftBarButtonItem = cancelButtonItem;
            
            UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
            doneButtonItem.tag = indexPath.row + 10;
            viewController.navigationItem.rightBarButtonItem = doneButtonItem;
            
            CGRect rect = CGRectMake(30, 1, 300, 20);
            
            if ([tag hasSuffix:@"FideId"] || [tag hasSuffix:@"Elo"]) {
                tf1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            }
            
            popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
            [popoverController setPopoverContentSize:CGSizeMake(320, 87) animated:NO];
            [popoverController presentPopoverFromRect:rect inView:selectedCell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            [tf1 becomeFirstResponder];
        }
    }
}

#pragma mark - Gestione bottoni menu

- (void) actionMenuButtonPressed:(id) sender {
    if (doneActionSheetMenu.window ) {
        [doneActionSheetMenu dismissWithClickedButtonIndex:0 animated:YES];
        doneActionSheetMenu = nil;
    }
    if (tagPopover.isPopoverVisible) {
        [tagPopover dismissPopoverAnimated:YES];
        tagPopover = nil;
        return;
    }
    AdditionalTagTableViewController *attvc = [[AdditionalTagTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [attvc setDelegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:attvc];
    
    if (IS_PAD) {
        UIBarButtonItem *bbi = (UIBarButtonItem *)sender;
        tagPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
        [tagPopover presentPopoverFromBarButtonItem:bbi permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self.navigationController pushViewController:attvc animated:YES];
    }
    
}

- (void) doneMenuButtonPressed:(id)sender {
    if (doneActionSheetMenu.window ) {
        [doneActionSheetMenu dismissWithClickedButtonIndex:0 animated:YES];
        doneActionSheetMenu = nil;
        return;
    }
    if (tagPopover.isPopoverVisible) {
        [tagPopover dismissPopoverAnimated:YES];
        tagPopover = nil;
    }
    
    NSString *save = NSLocalizedString(@"MENU_SAVE", nil);
    NSString *saveAndExit = NSLocalizedString(@"MENU_SAVE_EXIT", nil);
    NSString *exitNoSave = NSLocalizedString(@"MENU_EXIT_NO_SAVE", nil);
    UIBarButtonItem *bbi = (UIBarButtonItem *)sender;
    doneActionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    [doneActionSheetMenu addButtonWithTitle:save];
    [doneActionSheetMenu addButtonWithTitle:saveAndExit];
    [doneActionSheetMenu addButtonWithTitle:exitNoSave];
    if (IS_PHONE) {
        doneActionSheetMenu.cancelButtonIndex = [doneActionSheetMenu addButtonWithTitle:@"Cancel"];
    }
    [doneActionSheetMenu setTag:1];
    [doneActionSheetMenu showFromBarButtonItem:bbi animated:YES];
}



- (void)deselectCell:(UITableView *)tableView {
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:NO];
}


#pragma mark - Gestione Result-Title-ECO Picker

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    //if (pickerView.tag == 3) {
    //    return 3;
    //}
    return 3;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    /*
    if (pickerView.tag == 1) {
        return [[UtilToView getResultsArray] count];
    }
    else if (pickerView.tag == 2) {
        return [[UtilToView getTitleArray] count];
    }
    else if (pickerView.tag == 3) {
    */
        if (component == 0) {
            return 5;
        }
        else if ((component == 1) || (component == 2)) {
            return 10;
        }
    //}
    return 0;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    /*
    if (pickerView.tag == 1) {
        return [[UtilToView getResultsArray] objectAtIndex:row];
    }
    else if (pickerView.tag == 2) {
        return [[UtilToView getTitleArray] objectAtIndex:row];
    }
    else if (pickerView.tag == 3) {
        if (component == 0) {
            return [[UtilToView getEcoLetterArray] objectAtIndex:row];
        }
        else {
            return [[UtilToView getEcoNumberArray] objectAtIndex:row];
        }
    }*/
    if (component == 0) {
        return [[UtilToView getEcoLetterArray] objectAtIndex:row];
    }
    else {
        return [[UtilToView getEcoNumberArray] objectAtIndex:row];
    }
    //return nil;
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    /*
    if (pickerView.tag == 1) {
        selectedResult = [[UtilToView getResultsArray] objectAtIndex:row];
    }
    else if (pickerView.tag == 2) {
        if (row == 0) {
            selectedResult = @"-";
        }
        else {
            selectedResult = [[UtilToView getTitleArray] objectAtIndex:row];
        }
    }
    else if (pickerView.tag == 3) {*/
        if (component == 0) {
            letterEco = [[UtilToView getEcoLetterArray] objectAtIndex:row];
        }
        else if (component == 1) {
            firstNumberEco = [[UtilToView getEcoNumberArray] objectAtIndex:row];
        }
        else {
            secondNumberEco = [[UtilToView getEcoNumberArray] objectAtIndex:row];
        }
    //}
}

- (void) salvaDatiInPgnGame {
    if (_pgnGame) {
        for (NSString *tag in [tagValueDictionary allKeys]) {
            NSString *tagValue = [tagValueDictionary objectForKey:tag];
            [_pgnGame setTag:tag andTagValue:tagValue];
        }
        for (NSString *additionalTag in [additionalTagDictionary allKeys]) {
            NSString *additionalTagValue = [additionalTagDictionary objectForKey:additionalTag];
            [_pgnGame addSupplementalTag:additionalTag andTagValue:additionalTagValue];
        }
        [_pgnGame printCompleteGame];
    }
}


#pragma mark - Gestione ActionSheet delegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex<0) {
        return;
    }
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        return;
    }
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {//Salva i dati senza uscire
            [self salvaDatiInPgnGame];
            [_delegate saveGameDetail:tagValueDictionary];
        }
        else if (buttonIndex == 1) {
            [self salvaDatiInPgnGame];
            [_delegate saveGameDetail:tagValueDictionary];
            //[self dismissModalViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if (buttonIndex == 2) {
            //[self dismissModalViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if (actionSheet.tag == 7) {
        [tagValueDictionary setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:[UtilToView getTagRosterByIndex:actionSheet.tag - 1]];
        //[_pgnGame setTag:[UtilToView getTagRosterByIndex:actionSheet.tag - 1] andTagValue:[actionSheet buttonTitleAtIndex:buttonIndex]];
        [self.tableView reloadData];
    }
    else if (actionSheet.tag >= 10) {
        NSString *tag = [additionalTagArray objectAtIndex:actionSheet.tag - 10];
        [additionalTagDictionary setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:tag];
        [self.tableView reloadData];
    }
}

#pragma mark - Implementazione metodi AdditionalTagTableViewController

- (void) saveAdditionalTag:(NSString *)additionalTag {
    if (!additionalTagArray) {
        additionalTagArray = [[NSMutableArray alloc] init];
    }
    if (![additionalTagArray containsObject:additionalTag]) {
        [additionalTagArray addObject:additionalTag];
        if ([additionalTag isEqualToString:@"EventDate"]) {
            [additionalTagDictionary setObject:@"????.??.??" forKey:additionalTag];
        }
        else {
            [additionalTagDictionary setObject:@"?" forKey:additionalTag];
        }
    }
    [tagPopover dismissPopoverAnimated:YES];
    tagPopover = nil;
    [self.tableView reloadData];
}

- (void) saveSupplementalTag:(NSDictionary *)supplementalTag {

}

#pragma mark - Implementazione metodi di UIBarButtonItem

- (void) cancelButtonPressed:(UIBarButtonItem *) sender {
    //NSLog(@"Cancel Button Pressed con tag = %d", sender.tag);
    if ([popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
        selectedCell = nil;
    }
}

- (void) doneButtonPressed:(UIBarButtonItem *) sender {
    //NSLog(@"Done Button Pressed con tag = %d", sender.tag);
    UINavigationController *nc = (UINavigationController *)[popoverController contentViewController];
    UIViewController *viewController = nc.viewControllers[0];
    UIView *view = viewController.view;
    switch (sender.tag) {
        case 1:
        case 2:
        case 4:
        case 5:
        case 6: {
            UITextField *tf = (UITextField *)[view viewWithTag:sender.tag];
            NSString *value = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (value.length > 0) {
                [tagValueDictionary setObject:value forKey:[UtilToView getTagRosterByIndex:sender.tag - 1]];
                //[_pgnGame setTag:[UtilToView getTagRosterByIndex:sender.tag - 1] andTagValue:value];
            }
            else {
                [tagValueDictionary setObject:[UtilToView getTagRosterDefaultValueByIndex:sender.tag - 1] forKey:[UtilToView getTagRosterByIndex:sender.tag - 1]];
            }
            break;
        }
        case 3: {
            UIDatePicker *datePicker = (UIDatePicker *)[view viewWithTag:sender.tag];
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY.MM.dd"];
            selectedDate =  [dateFormatter stringFromDate:[datePicker date]];
            [tagValueDictionary setObject:selectedDate forKey:[UtilToView getTagRosterByIndex:sender.tag - 1]];
            //[_pgnGame setTag:[UtilToView getTagRosterByIndex:sender.tag - 1] andTagValue:selectedDate];
        }
        default:
            break;
    }
    if (sender.tag >= 10) {
        UIView *selectedView = (UIView *)[view viewWithTag:sender.tag];
        if ([selectedView isKindOfClass:[UIDatePicker class]]) {
            UIDatePicker *datePicker = (UIDatePicker *)[view viewWithTag:sender.tag];
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY.MM.dd"];
            selectedDate =  [dateFormatter stringFromDate:[datePicker date]];
            [additionalTagDictionary setObject:selectedDate forKey:[additionalTagArray objectAtIndex:sender.tag - 10]];
        }
        else if ([selectedView isKindOfClass:[UIPickerView class]]) {
            NSString *eco = [[letterEco stringByAppendingString:firstNumberEco] stringByAppendingString:secondNumberEco];
            [additionalTagDictionary setObject:eco forKey:[additionalTagArray objectAtIndex:sender.tag - 10]];
        }
        else if ([selectedView isKindOfClass:[UITextField class]]) {
            UITextField *tf = (UITextField *)[view viewWithTag:sender.tag];
            NSString *value = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *tag = [additionalTagArray objectAtIndex:sender.tag - 10];
            if ([tag hasSuffix:@"Elo"]) {
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                NSNumber *numberElo = [f numberFromString:value];
                if (!numberElo) {
                    UIAlertView *errorFideIdAlertView = [[UIAlertView alloc] initWithTitle:@"ERROR!" message:@"Valore ELO Inserito non corretto!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [errorFideIdAlertView show];
                    return;
                }
            }
            else if ([tag hasSuffix:@"FideId"]) {
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                NSNumber *numberFideId = [f numberFromString:value];
                if (!numberFideId) {
                    UIAlertView *errorFideIdAlertView = [[UIAlertView alloc] initWithTitle:@"ERROR!" message:@"Valore FideId Inserito non corretto!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [errorFideIdAlertView show];
                    return;
                }
            }
            
            if (value.length > 0) {
                [additionalTagDictionary setObject:value forKey:[additionalTagArray objectAtIndex:sender.tag - 10]];
            }
            else {
                [additionalTagDictionary setObject:@"?" forKey:[additionalTagArray objectAtIndex:sender.tag - 10]];
            }
        }
    }
    [popoverController dismissPopoverAnimated:YES];
    popoverController = nil;
    selectedCell = nil;
    [self.tableView reloadData];
}

#pragma mark - Implementazione metodi UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *value = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
        if (textField.tag < 10) {
            [tagValueDictionary setObject:value forKey:[UtilToView getTagRosterByIndex:textField.tag - 1]];
        }
        else {
            [additionalTagDictionary setObject:value forKey:[additionalTagArray objectAtIndex:textField.tag - 10]];
        }
        
        selectedCell = nil;
        [self.tableView reloadData];
    }
    return YES;
}



@end
