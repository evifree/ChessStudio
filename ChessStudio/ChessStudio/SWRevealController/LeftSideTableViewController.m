//
//  LeftSideTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 23/01/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "LeftSideTableViewController.h"
#import "BoardViewController.h"
#import "UtilToView.h"
#import "SWRevealViewController.h"
#import "TBDatabaseTableViewController.h"
#import "TBTwicTableViewController.h"
#import "SettingsTableViewController.h"
#import "TBHelpTableViewController.h"
#import "PgnMentorTableViewController.h"
#import "DropboxTableViewController.h"
#import "PgnDownloadViewController.h"
#import "HelpVideoTableViewController.h"
#import "NalimovBoardViewController.h"
#import "MainCloudTableViewController.h"
#import "CloudTableViewController.h"
#import "EcoTableViewController.h"

#import "MBProgressHUD.h"

@interface LeftSideTableViewController () {

    NSArray *menuSections;
    NSArray *menuItems;
    NSMutableArray *menuItemsForSection;
    NSMutableArray *detailItemsForSection;

}

@end

@implementation LeftSideTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"MENU";
    
    menuSections = @[@"DATABASE_REVEAL", @"GAME_REVEAL", @"OPENINGS_REVEAL", @"ENDINGS_REVEAL", @"SETTINGS_REVEAL", @"HELP_REVEAL"];
    
    menuItems = @[@"PGN DATABASE", @"TWIC", @"NEW GAME", @"SETTINGS", @"HELP", @"NEW POSITION", @"PGN MENTOR", @"DROPBOX"];
    
    menuItemsForSection = [[NSMutableArray alloc] init];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [menuItemsForSection addObject:@[@"PGN DATABASE", @"TWIC", @"PGN MENTOR", @"DROPBOX", @"PGN DOWNLOAD", @"ICLOUD" /*, @"ICLOUD FIRST"*/]];
    }
    else {
        [menuItemsForSection addObject:@[@"PGN DATABASE", @"TWIC", @"PGN MENTOR", @"DROPBOX", @"PGN DOWNLOAD"]];
    }
    
    [menuItemsForSection addObject:@[@"NEW GAME", @"NEW POSITION"]];
    [menuItemsForSection addObject:@[@"OPENINGS_SW"]];
    [menuItemsForSection addObject:@[@"NALIMOV"]];
    [menuItemsForSection addObject:@[@"CHESS SETTINGS"]];
    [menuItemsForSection addObject:@[@"HELP_REVEAL", @"REPORT_PROBLEM", @"HELP_VIDEOS"]];
    
    
    detailItemsForSection = [[NSMutableArray alloc] init];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [detailItemsForSection addObject:@[@"PGN DATABASE DETAIL", @"TWIC DETAIL", @"PGN MENTOR DETAIL", @"DROPBOX DETAIL", @"PGN DOWNLOAD DETAIL", @"ICLOUD DETAIL"/*, @"ICLOUD DETAIL"*/]];
    }
    else {
        [detailItemsForSection addObject:@[@"PGN DATABASE DETAIL", @"TWIC DETAIL", @"PGN MENTOR DETAIL", @"DROPBOX DETAIL", @"PGN DOWNLOAD DETAIL"]];
    }
    
    [detailItemsForSection addObject:@[@"NEW GAME DETAIL", @"NEW POSITION DETAIL"]];
    [detailItemsForSection addObject:@[@"OPENINGS_DETAIL"]];
    [detailItemsForSection addObject:@[@"NALIMOV DETAIL"]];
    [detailItemsForSection addObject:@[@"CHESS SETTINGS DETAIL"]];
    [detailItemsForSection addObject:@[@"HELP DETAIL", @"REPORT_PROBLEM_DETAIL", @"HELP_VIDEOS_DETAIL"]];
    
    
    //if (IS_PAD || IS_IPHONE_6P || IS_IPHONE_6 || IS_IPHONE_5 || IS_IPHONE_4_OR_LESS || IS_PAD_PRO) {
    [self setupTitle];
    //}
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupTitle {
    //self.navigationItem.title = @"Chess Studio Menu";
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    if (IS_PAD) {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:40.0];
        //titleLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:35.0];
    }
    else {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25.0];
        //titleLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:25.0];
    }
    
    //titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = NSLocalizedString(@"CHESS STUDIO MENU", nil);
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [menuSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[menuItemsForSection objectAtIndex:section] count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString([menuSections objectAtIndex:section], nil);
}

- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *thfv = (UITableViewHeaderFooterView *)view;
        thfv.textLabel.textColor = [UIColor whiteColor];
        //thfv.contentView.backgroundColor = [UIColor blackColor];
        thfv.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        thfv.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25.0];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0];

    cell.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0];
    
    cell.textLabel.textColor = [UIColor yellowColor];
    cell.textLabel.text = NSLocalizedString([[menuItemsForSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row], nil);
    cell.detailTextLabel.textColor = [UIColor greenColor];
    cell.detailTextLabel.text = NSLocalizedString([[detailItemsForSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row], nil);
    
    // Configure the cell...
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *testo = cell.textLabel.text;
    SWRevealViewController *rvc = self.revealViewController;
    
    if ([testo isEqualToString:NSLocalizedString(@"PGN DATABASE", nil)]) {
        TBDatabaseMenuTableViewController *databaseViewController = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"TBDatabaseTableViewController"];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:databaseViewController];
        [rvc pushFrontViewController:frontNavigationController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"TWIC", nil)]) {
        TBTwicTableViewController *twicTableViewController = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"TBTwicTableViewController"];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:twicTableViewController];
        //SWRevealViewController *rvc = self.revealViewController;
        [rvc pushFrontViewController:frontNavigationController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"PGN MENTOR", nil)]) {
        PgnMentorTableViewController *pgnMentorTable = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"PgnMentorTableViewController"];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:pgnMentorTable];
        //SWRevealViewController *rvc = self.revealViewController;
        [rvc pushFrontViewController:frontNavigationController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"DROPBOX", nil)]) {
        DropboxTableViewController *dropBoxTable = [[DropboxTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [dropBoxTable setStartDirectory:@"/"];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:dropBoxTable];
        //SWRevealViewController *rvc = self.revealViewController;
        [rvc pushFrontViewController:frontNavigationController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"NEW POSITION", nil)]) {
        BoardViewController *bvc = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"BoardViewController"];
        bvc.delegate = nil;
        [bvc setSetupPosition:YES];
        UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:bvc];
        //SWRevealViewController *rvc = self.revealViewController;
        //[rvc setFrontViewController:paneNavigationViewController animated:YES];
        [rvc pushFrontViewController:paneNavigationViewController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"NEW GAME", nil)]) {
        BoardViewController *bvc = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"BoardViewController"];
        bvc.delegate = nil;
        UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:bvc];
        //SWRevealViewController *rvc = self.revealViewController;
        //[rvc setFrontViewController:paneNavigationViewController animated:YES];
        [rvc pushFrontViewController:paneNavigationViewController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"CHESS SETTINGS", nil)]) {
        SettingsTableViewController *stvc = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:stvc];
        //SWRevealViewController *rvc = self.revealViewController;
        [rvc pushFrontViewController:frontNavigationController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"APP SETTINGS", nil)]) {
        SettingsTableViewController *stvc = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:stvc];
        //SWRevealViewController *rvc = self.revealViewController;
        [rvc pushFrontViewController:frontNavigationController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"HELP_REVEAL", nil)]) {
        TBHelpTableViewController *tbhvc = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"TBHelpTableViewController"];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:tbhvc];
        //SWRevealViewController *rvc = self.revealViewController;
        [rvc pushFrontViewController:frontNavigationController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"About", nil)]) {
        TBHelpTableViewController *tbhvc = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"TBHelpTableViewController"];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:tbhvc];
        //SWRevealViewController *rvc = self.revealViewController;
        [rvc pushFrontViewController:frontNavigationController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"PGN DOWNLOAD", nil)]) {
        PgnDownloadViewController *pgnDownload = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"PgnDownloadViewController"];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:pgnDownload];
        [rvc pushFrontViewController:frontNavigationController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"DETAIL", nil)]) {
        //SWRevealViewController *rvc = self.revealViewController;
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainSWReveal" bundle:[NSBundle mainBundle]];
        SettingsTableViewController *stvc = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:stvc];
        LeftSideTableViewController *lsvc = [storyBoard instantiateViewControllerWithIdentifier:@"LeftSideTableViewController"];
        UINavigationController *leftSideNavigationController = [[UINavigationController alloc] initWithRootViewController:lsvc];
        SWRevealViewController *childRevealViewController = [[SWRevealViewController alloc] initWithRearViewController:leftSideNavigationController frontViewController:frontNavigationController];
        childRevealViewController.rearViewRevealDisplacement = 0.0f;
        [childRevealViewController setFrontViewPosition:FrontViewPositionRight animated:NO];
        [rvc pushFrontViewController:childRevealViewController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"REPORT_PROBLEM", nil)]) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
            mailer.mailComposeDelegate = self;
            [mailer setSubject:@""];
            NSArray *toRecipients = [NSArray arrayWithObjects:NSLocalizedString(@"EMAIL", nil), nil];
            [mailer setToRecipients:toRecipients];
            NSString *emailBody = @"";
            [mailer setMessageBody:emailBody isHTML:NO];
            [self presentViewController:mailer animated:YES completion:nil];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_EMAIL_SETUP", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else if ([testo isEqualToString:NSLocalizedString(@"ECO_REVEAL", nil)]) {

    }
    else if ([testo isEqualToString:NSLocalizedString(@"FIDE_PLAYERS", nil)]) {
        
    }
    else if ([testo isEqualToString:NSLocalizedString(@"HELP_VIDEOS", nil)]) {
        HelpVideoTableViewController *hvtvc = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"HelpVideoTableViewController"];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:hvtvc];
        [rvc pushFrontViewController:frontNavigationController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"NALIMOV", nil)]) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainSWReveal" bundle:[NSBundle mainBundle]];
        NalimovBoardViewController *nbvc = [storyBoard instantiateViewControllerWithIdentifier:@"NalimovBoardViewController"];
        nbvc.delegate = nil;
        [nbvc setSetupPosition:YES];
        UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:nbvc];
        //SWRevealViewController *rvc = self.revealViewController;
        //[rvc setFrontViewController:paneNavigationViewController animated:YES];
        [rvc pushFrontViewController:paneNavigationViewController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"ICLOUD", nil)]) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainSWReveal" bundle:[NSBundle mainBundle]];
        MainCloudTableViewController *mctvc = [storyBoard instantiateViewControllerWithIdentifier:@"MainCloudTableViewController"];
        UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:mctvc];
        //CloudTableViewController *ctvc = [storyBoard instantiateViewControllerWithIdentifier:@"CloudTableViewController"];
        //UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:ctvc];
        [rvc pushFrontViewController:paneNavigationViewController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"ICLOUD FIRST", nil)]) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainSWReveal" bundle:[NSBundle mainBundle]];
        MainCloudTableViewController *mctvc = [storyBoard instantiateViewControllerWithIdentifier:@"MainCloudTableViewController"];
        UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:mctvc];
        [rvc pushFrontViewController:paneNavigationViewController animated:YES];
    }
    else if ([testo isEqualToString:NSLocalizedString(@"OPENINGS_SW", nil)]) {
        //Inserimento di MBProgress nel caso di dispositivi lenti
        
        NSString *ecoPath = [[NSBundle mainBundle] pathForResource:@"OpeningsEcoName" ofType:@"pgn"];
        NSURL *urlEcoPath = [NSURL fileURLWithPath:ecoPath];
        PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:urlEcoPath];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.minSize = [UtilToView getSizeOfMBProgress];
        //hud.labelText = @"Loading ...";
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [pfd openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    EcoTableViewController *etvc = [[UtilToView getStoryBoard] instantiateViewControllerWithIdentifier:@"EcoTableViewController"];
                    [etvc setPgnFileDoc:pfd];
                    UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:etvc];
                    [rvc pushFrontViewController:frontNavigationController animated:YES];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
            }];
        });
    }
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
