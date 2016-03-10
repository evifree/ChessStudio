//
//  TBHelpTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 06/05/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "TBHelpTableViewController.h"
#import "DescriptionViewController.h"
#import "ManualOnlineViewController.h"
#import "UtilToView.h"
#import "SWRevealViewController.h"

@interface TBHelpTableViewController ()

@end

@implementation TBHelpTableViewController

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
    
    //if (IS_IOS_7) {
        //self.edgesForExtendedLayout = UIRectEdgeNone;
    //}
    
    
    UIImageView *sfondo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-Portrait~ipad.png"]];
    //[sfondo setFrame:self.tableView.frame];
    sfondo.alpha = 0.2;
    if (IS_IOS_7) {
        //self.tableView.backgroundColor = [UIColor clearColor];
        //[self.view addSubview:sfondo];
    }
    else {
        self.tableView.backgroundView = sfondo;
    }
    
    if (IsChessStudioLight) {
        if (IS_IOS_7) {
            self.canDisplayBannerAds = YES;
        }
    }
    
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window]rootViewController];
    
    if ([rootViewController isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *revealViewController = [self revealViewController];
        [revealViewController panGestureRecognizer];
        [revealViewController tapGestureRecognizer];
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon.png"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Chess Studio Help";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 ) {
        return 1;
    }
    else if (section == 1) {
        return 1;
    }
    else if (section == 2) {
        return 1;
    }
    else if (section == 3) {
        return 1;
    }
    
    return 22;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"HELP_SECTION_0", nil);
    }
    else if (section == 1) {
        return NSLocalizedString(@"HELP_SECTION_1", nil);
    }
    else if (section == 2) {
        return NSLocalizedString(@"HELP_SECTION_3", nil);
        //return NSLocalizedString(@"HELP_SECTION_2", nil);
    }
    return NSLocalizedString(@"HELP_SECTION_3", nil);
}

- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (IS_IOS_7) {
        if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
            UITableViewHeaderFooterView *thfv = (UITableViewHeaderFooterView *)view;
            thfv.textLabel.textColor = [UIColor whiteColor];
            //thfv.contentView.backgroundColor = UIColorFromRGB(0xFFD700);
            thfv.contentView.backgroundColor = [UIColor blackColor];
            //thfv.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
            thfv.textLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:20];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell TBHelp";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSString *riga;
    
    if (IS_PAD) {
        cell.textLabel.adjustsFontSizeToFitWidth = NO;
    }
    else {
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    if (indexPath.section == 0) {
        riga = [@"MAIN" stringByAppendingFormat:@"%ld", (long)indexPath.row];
    }
    else if (indexPath.section == 1) {
        riga = [@"MANUAL" stringByAppendingFormat:@"%ld", (long)indexPath.row];
    }
    else if (indexPath.section == 2) {
        riga = [@"EMAIL" stringByAppendingFormat:@"%ld", (long)indexPath.row];
        //riga = [@"HELP" stringByAppendingFormat:@"%d", indexPath.row];
    }
    else if (indexPath.section == 3) {
        //riga = [@"EMAIL" stringByAppendingFormat:@"%d", indexPath.row];
    }
    NSString *testo = NSLocalizedString(riga, nil);
    if (![testo hasPrefix:@"HELP"]) {
        cell.textLabel.text = testo;
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else {
        cell.textLabel.text = @"";
        [cell setAccessoryType:UITableViewCellAccessoryNone];
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
    if ([cell.textLabel.text isEqualToString:@""]) {
        return;
    }
    
    if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"MAIN0", nil)]) {
        
        UIStoryboard *sb = [UtilToView getStoryBoard];
        DescriptionViewController *dvc = [sb instantiateViewControllerWithIdentifier:@"DescriptionViewController"];
        [dvc setSection:indexPath.section];
        [dvc setRigaHelp:indexPath.row];
        if (IS_PHONE) {
            self.navigationItem.title = @"Help";
        }
        [self.navigationController pushViewController:dvc animated:YES];
        return;
    }

    if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"MANUAL0", nil)]) {
        //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
        UIStoryboard *sb = [UtilToView getStoryBoard];
        ManualOnlineViewController *manualViewController = [sb instantiateViewControllerWithIdentifier:@"ManualOnlineViewController"];
        
        if (IS_PHONE) {
            if (IS_IOS_7) {
                //self.navigationItem.title = @"";
                self.navigationItem.title = NSLocalizedString(@"BACK", nil);
            }
            else {
                self.navigationItem.title = NSLocalizedString(@"BACK", nil);
            }
        }
        
        [self.navigationController pushViewController:manualViewController animated:YES];
        return;
    }
    
    
    if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"EMAIL0", nil)]) {
        [self manageEmail];
        return;
    }
    
    UIStoryboard *sb = [UtilToView getStoryBoard];
    DescriptionViewController *dvc = [sb instantiateViewControllerWithIdentifier:@"DescriptionViewController"];
    [dvc setSection:indexPath.section];
    [dvc setRigaHelp:indexPath.row];
    if (IS_PHONE) {
        self.navigationItem.title = @"Help";
    }
    [self.navigationController pushViewController:dvc animated:YES];
}


#pragma mark - Gestione email

- (void) manageEmail {
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@""];
        
        //NSArray *toRecipients = [NSArray arrayWithObjects:@"infoEAI@enea.it", nil];
        NSArray *toRecipients = [NSArray arrayWithObjects:NSLocalizedString(@"EMAIL", nil), nil];
        [mailer setToRecipients:toRecipients];
        
        NSString *emailBody = @"";
        [mailer setMessageBody:emailBody isHTML:NO];
        //[self presentModalViewController:mailer animated:YES];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_EMAIL_SETUP", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
