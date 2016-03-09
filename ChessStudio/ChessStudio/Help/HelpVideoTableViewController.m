//
//  HelpVideoTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 26/02/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "HelpVideoTableViewController.h"
#import "SWRevealViewController.h"
#import "HelpVideoViewController.h"

@interface HelpVideoTableViewController () {
    
    Reachability *internetReachability;
    NetworkStatus networkStatus;

    UIActivityIndicatorView *aiv;
    
    NSArray *listVideos;
    
    NSMutableArray *listVideosDevice;

}

@end

@implementation HelpVideoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"Help Video";
    [self setupReachability];
    
    [self checkRevealed];
    
    UIRefreshControl *rf = [[UIRefreshControl alloc] init];
    [self setRefreshControl:rf];
    [rf addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.color = [UIColor blueColor];
    //aiv.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    aiv.center = CGPointMake(frame.size.width/2, frame.size.height/2 - 64);
    //aiv.center = self.tableView.center;
    [self.tableView addSubview:aiv];
    [aiv startAnimating];
    
    [self performSelectorInBackground:@selector(setupVideos) withObject:nil];
    //[self performSelector:@selector(setupVideos) withObject:nil afterDelay:3];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

- (void) setupReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];
    networkStatus = [internetReachability currentReachabilityStatus];
}

- (void) reachabilityChanged:(NSNotification *)notification {
    if (notification) {
        internetReachability = [notification object];
    }
    networkStatus = [internetReachability currentReachabilityStatus];
    if (networkStatus != NotReachable) {
        CGRect frame = [[UIScreen mainScreen] bounds];
        aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        aiv.color = [UIColor blueColor];
        aiv.center = CGPointMake(frame.size.width/2, frame.size.height/2 - 64);
        [self.tableView addSubview:aiv];
        [aiv startAnimating];
        [self performSelectorInBackground:@selector(setupVideos) withObject:nil];
    }
}

- (void) checkRevealed {
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window]rootViewController];
    if ([rootViewController isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *revealViewController = [self revealViewController];
        [revealViewController panGestureRecognizer];
        [revealViewController tapGestureRecognizer];
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    //[self.tableView reloadData];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.color = [UIColor blueColor];
    //aiv.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    aiv.center = CGPointMake(frame.size.width/2, frame.size.height/2 - 64);
    [self.view addSubview:aiv];
    [aiv startAnimating];
    [self performSelector:@selector(setupVideos) withObject:nil afterDelay:3];
    [refreshControl endRefreshing];
}

- (void) setupVideos {
    
    if (networkStatus == NotReachable) {
        [aiv stopAnimating];
        [aiv removeFromSuperview];
        aiv = nil;
        UIAlertView *noConnectionAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noConnectionAlertView show];
        return;
    }
    
    
    listVideos = [[NSArray alloc] initWithContentsOfURL:[NSURL URLWithString:@""]];
    
    listVideosDevice = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in listVideos) {
        NSString *device = [dict objectForKey:@"Device"];
        if ([device hasPrefix:@"iPad"]) {
            if (IS_PAD) {
                [listVideosDevice addObject:dict];
            }
        }
        else if ([device hasPrefix:@"iPhone"]) {
            if (!IS_PAD) {
                [listVideosDevice addObject:dict];
            }
        }
    }
    
    
    [aiv stopAnimating];
    [aiv removeFromSuperview];
    aiv = nil;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (listVideosDevice) {
        return listVideosDevice.count;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSInteger sezioneMosse = [tableView numberOfSections] - 1;
    
    //if (indexPath.section == 0) {
        CGSize constraintSize;
        CGSize size;
        
        UILabel *testSizeLabel = [[UILabel alloc] init];
        NSDictionary *dict = [listVideosDevice objectAtIndex:indexPath.row];
        testSizeLabel.text = [dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)];
        testSizeLabel.numberOfLines = 0;
        
        if (IS_PAD) {
            if (IS_PORTRAIT) {
                constraintSize = CGSizeMake(768, 20000.0f);
                //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0]}];
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                size = rect.size;
            }
            else {
                constraintSize = CGSizeMake(1024, 20000.0f);
                //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0]}];
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                size = rect.size;
            }
        }
        else if (IS_IPHONE_6) {
            if (IS_PORTRAIT) {
                constraintSize = CGSizeMake(640, 5000);
                //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0]}];
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                size = rect.size;
            }
            else {
                constraintSize = CGSizeMake(1136, 5000);
                //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0]}];
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                size = rect.size;
            }
        }
        else if (IS_IPHONE_6P) {
            if (IS_PORTRAIT) {
                constraintSize = CGSizeMake(640, 5000);
                //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0]}];
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                size = rect.size;
            }
            else {
                constraintSize = CGSizeMake(1136, 5000);
                //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0]}];
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                size = rect.size;
            }
        }
        else if (IS_IPHONE_5) {
            if (IS_PORTRAIT) {
                constraintSize = CGSizeMake(640, 5000);
                //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0]}];
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                size = rect.size;
            }
            else {
                constraintSize = CGSizeMake(1136, 5000);
                //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"ChalkboardSE-Bold" size:23.0]}];
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                size = rect.size;
            }
        }
        else if (IS_IPHONE_4_OR_LESS) {
            if (IS_PORTRAIT) {
                constraintSize = CGSizeMake(640, 3000);
                //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0]}];
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                size = rect.size;
            }
            else {
                constraintSize = CGSizeMake(960, 3000);
                //size = [[dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)] sizeWithFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0] constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:testSizeLabel.text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"ChalkboardSE-Bold" size:23.0]}];
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){constraintSize.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                size = rect.size;
            }
        }
        CGFloat height = MAX(size.height, 44.0f);
        
        //NSLog(@"HEIGHT = %f", height);
        
        return height + 20;
    //}
    return 44.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell Help Video";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            cell.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:24.0];
            cell.detailTextLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:22.0];
        }
        else {
            cell.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:26.0];
            cell.detailTextLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:24.0];
        }
    }
    else {
        if (IS_PORTRAIT) {
            cell.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:14.0];
            cell.detailTextLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:12.0];
        }
        else {
            cell.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:16.0];
            cell.detailTextLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:14.0];
        }
    }
    
    
    NSDictionary *dict = [listVideosDevice objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:NSLocalizedString(@"VIDEO_TITLE", nil)];
    //cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.detailTextLabel.textColor = [UIColor redColor];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.text = [dict objectForKey:NSLocalizedString(@"VIDEO_DESCR", nil)];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSDictionary *dict = [listVideosDevice objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    HelpVideoViewController *hvvc = [segue destinationViewController];
    [hvvc setVideoDictionary:dict];
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
