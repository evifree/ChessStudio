//
//  TBTwicTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 12/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "TBTwicTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PgnDbManager.h"
#import "TwicWebViewController.h"
#import "ZipArchive.h"
#import "MBProgressHUD.h"
#import "PgnFileDocument.h"
#import "PgnFileInfo.h"
#import "PgnFileInfoTableViewController.h"
#import "Reachability.h"
#import "UtilToView.h"
#import "SWRevealViewController.h"

@interface TBTwicTableViewController () {
    
    
    NSFileManager *fileManager;
    NSString *twicDocumentPath;
    
    int numeroBase;
    NSMutableDictionary *listTwic;

    NSArray *listDownloadedTwic;
    
    PgnDbManager *pgnDbManager;
    
    
    //Variabili per il download del twic
    NSMutableString *finalTwicPath;
    NSInteger downloadSize;
    NSInteger totalDownloaded;
    NSMutableData *totalData;
    NSURLConnection *_connection;
    MBProgressHUD *hud;
    NSNumberFormatter *numberFormatter;
    
    
    UIActionSheet *actionSheetMenu;
    UIBarButtonItem *actionButton;
    
    
    UIAlertView *alert;
    UIProgressView *progressView;
    
    
    CGFloat buttonWebOffset;
    CGFloat buttonDownloadOffset;
    
    
    UIView *titoloView;
    
    Reachability *internetReachability;
}

@end

@implementation TBTwicTableViewController

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
    
    
    //pgnDbManager = [PgnDbManager sharedPgnDbManager];
    //listDownloadedTwic = [pgnDbManager listDownloadedTwic];
    
    fileManager = [NSFileManager defaultManager];
    [self loadTwic];
    
    [self refreshTwicTable];
    
    /*
    if (IS_PAD) {
        [self setNavigationTitlePadPortrait];
    }
    else {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
            [self setNavigationTitlePhonePortrait];
        }
        else {
            [self setNavigationTitlePhoneLandscape];
        }
    }
    */
    
    
    /*
    numeroBase = 920;
    listTwic = [[NSMutableDictionary alloc] init];
    
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setYear:2012];
    [comp setMonth:6];
    [comp setDay:25];
    [comp setHour:16];
    [comp setMinute:5];
    NSCalendar *cal1 = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *dataIniziale = [cal1 dateFromComponents:comp];
    
    [listTwic setObject:dataIniziale forKey:[NSNumber numberWithInt:numeroBase]];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:7];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *date = [cal dateByAddingComponents:comps toDate:dataIniziale options:0];
    NSLog(@"%@", dataIniziale);
    NSLog(@"%@", date);
    
    //Calcolo del lunedi della settimana corrente
    
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:today];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay:0 - ([weekdayComponents weekday] - 2)];
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
    
    NSLog(@"Lunedi: %@", beginningOfWeek);
    
    NSTimeInterval beginInterval = [beginningOfWeek timeIntervalSinceNow];
    
    int numeroTweek = numeroBase;
    
    int giorni = 0;
    BOOL stop = NO;
    while (!stop) {
        numeroTweek++;
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        giorni += 7;
        [comps setDay:giorni];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDate *date = [cal dateByAddingComponents:comps toDate:dataIniziale options:0];
        
        [listTwic setObject:date forKey:[NSNumber numberWithInt:numeroTweek]];
        
        //NSLog(@"%@",date);
        NSTimeInterval newInterval = [date timeIntervalSinceNow];
        NSTimeInterval diff = beginInterval - newInterval;
        //NSLog(@"Differenza:%f", diff);
        if (diff < 86400) {
            stop = YES;
        }
    }
    */
    
    if (IS_IOS_6) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [self setRefreshControl:refreshControl];
        [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    }
    
    if (IsChessStudioLight) {
        //if (IS_IOS_7) {
            self.canDisplayBannerAds = YES;
        //}
    }
    
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window]rootViewController];
    
    if ([rootViewController isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *revealViewController = [self revealViewController];
        [revealViewController panGestureRecognizer];
        [revealViewController tapGestureRecognizer];
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon.png"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
    
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0xC0C0C0);

}

- (void)refresh:(UIRefreshControl *)refreshControl {
    //NSLog(@"Mi sto rinfrescando alla ricerca di nuowi TWIC");
    [self refreshTwicTable];
    [self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
    [refreshControl endRefreshing];
}

- (void) refreshTwicTable {
    numeroBase = 920;
    listTwic = [[NSMutableDictionary alloc] init];
    
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setYear:2012];
    [comp setMonth:6];
    [comp setDay:25];
    [comp setHour:16];
    [comp setMinute:5];
    NSCalendar *cal1 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *dataIniziale = [cal1 dateFromComponents:comp];
    
    [listTwic setObject:dataIniziale forKey:[NSNumber numberWithInt:numeroBase]];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:7];
    //NSCalendar *cal = [NSCalendar currentCalendar];
    //NSDate *date = [cal dateByAddingComponents:comps toDate:dataIniziale options:0];
    //NSLog(@"Data iniziale %@", dataIniziale);
    //NSLog(@"Data Finale %@", date);
    
    //Calcolo del lunedi della settimana corrente
    
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:today];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay:0 - ([weekdayComponents weekday] - 2)];
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
    
    //NSLog(@"Lunedi: %@", beginningOfWeek);
    
    NSTimeInterval beginInterval = [beginningOfWeek timeIntervalSinceNow];
    
    int numeroTweek = numeroBase;
    
    int giorni = 0;
    BOOL stop = NO;
    while (!stop) {
        numeroTweek++;
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        giorni += 7;
        [comps setDay:giorni];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDate *date = [cal dateByAddingComponents:comps toDate:dataIniziale options:0];
        
        [listTwic setObject:date forKey:[NSNumber numberWithInt:numeroTweek]];
        
        //NSLog(@"%@",date);
        NSTimeInterval newInterval = [date timeIntervalSinceNow];
        NSTimeInterval diff = beginInterval - newInterval;
        //NSLog(@"Differenza:%f", diff);
        if (diff < 86400) {
            stop = YES;
        }
    }
    
    //numeroTweek++;
    //NSDate *dd = [[NSDate alloc] init];
    //[listTwic setObject:dd forKey:[NSNumber numberWithInt:numeroTweek]];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
    //[self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (IS_PAD) {
        [self setNavigationTitlePadPortrait];
    }
    else if (IS_PAD_PRO) {
        [self setNavigationTitlePadPortrait];
    }
    else {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
            [self setNavigationTitlePhonePortrait];
        }
        else {
            [self setNavigationTitlePhoneLandscape];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setNavigationTitlePadPortrait {
    titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, self.navigationController.navigationBar.frame.size.height)];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 281, 28)];
    label1.font = [UIFont fontWithName:@"Georgia-Bold" size:26];
    label1.textColor = [UIColor redColor];
    label1.text = @"The Week In Chess";
    label1.backgroundColor = [UIColor clearColor];
    
    [titoloView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 500, 16)];
    label2.font = [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:16];
    label2.textColor = [UIColor blackColor];
    label2.text = @"Daily Chess News and Games. Weekly digest for download. By Mark Crowther.";
    label2.backgroundColor = [UIColor clearColor];
    
    [titoloView addSubview:label2];
    
    self.navigationItem.titleView = titoloView;
}

- (void) setNavigationTitlePhonePortrait {
    
    titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44.0)];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 190, 28)];
    label1.font = [UIFont fontWithName:@"Georgia-Bold" size:18];
    label1.textColor = [UIColor redColor];
    label1.text = @"The Week In Chess";
    label1.backgroundColor = [UIColor clearColor];
    [titoloView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 19, 300, 16)];
    label2.adjustsFontSizeToFitWidth = YES;
    label2.font = [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:8.5];
    label2.textColor = [UIColor blackColor];
    label2.text = @"Daily Chess News and Games. Weekly digest for download.";
    label2.backgroundColor = [UIColor clearColor];
    
    [titoloView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(80, 28, 100, 16)];
    label3.adjustsFontSizeToFitWidth = YES;
    label3.font = [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:8.5];
    label3.textColor = [UIColor blackColor];
    label3.text = @"By Mark Crowther.";
    label3.backgroundColor = [UIColor clearColor];
    
    [titoloView addSubview:label3];
    
    self.navigationItem.titleView = titoloView;
}

- (void) setNavigationTitlePhoneLandscape {
    titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 32)];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 190, 22)];
    label1.font = [UIFont fontWithName:@"Georgia-Bold" size:18];
    label1.textColor = [UIColor redColor];
    label1.text = @"The Week In Chess";
    label1.backgroundColor = [UIColor clearColor];
    [titoloView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, 300, 16)];
    label2.font = [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:8.5];
    label2.textColor = [UIColor blackColor];
    label2.text = @"Daily Chess News and Games. Weekly digest for download. By Mark Crowther.";
    label2.backgroundColor = [UIColor clearColor];
    
    [titoloView addSubview:label2];
    
    self.navigationItem.titleView = titoloView;
}


- (void) loadTwic {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    twicDocumentPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"twic"];
    if (![fileManager fileExistsAtPath:twicDocumentPath]) {
        NSError *error;
        if (![fileManager createDirectoryAtPath:twicDocumentPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"ERROR CREATING TWIC DIRECTORY: %@", error.debugDescription);
        }
    }
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:twicDocumentPath error:nil];
    NSPredicate *filtroTwic = [NSPredicate predicateWithFormat:@"(self BEGINSWITH 'twic') && (self ENDSWITH '.pgn')"];
    listDownloadedTwic = [dirContents filteredArrayUsingPredicate:filtroTwic];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

//- (NSUInteger) supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskAll;
//}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if (IS_PAD) {
        [self setNavigationTitlePadPortrait];
    }
    else if (IS_PHONE) {
        if (IS_PORTRAIT) {
            [self setNavigationTitlePhonePortrait];
        }
        else {
            [self setNavigationTitlePhoneLandscape];
        }
    }
    [self.tableView reloadData];
    
}

#pragma mark - Posizionamento dei button download e web

- (CGRect) getButtonDownloadFrame {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            return CGRectMake(768 - 150.0, 5, 50, 50);
        }
        else {
            return CGRectMake(1024 - 150.0, 5, 50, 50);
        }
    }
    
    if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            return CGRectMake(320.0 - 105.0, 5, 50, 50);
        }
        else {
            return CGRectMake(480.0 - 105.0, 5, 50, 50);
        }
    }
    
    if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            return CGRectMake(320.0 - 105.0, 5, 50, 50);
        }
        else {
            return CGRectMake(568.0 - 105.0, 5, 50, 50);
        }
    }
    
    if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            return CGRectMake(375.0 - 110.0, 5, 50, 50);
        }
        else {
            return CGRectMake(667.0 - 110.0, 5, 50, 50);
        }
    }
    
    if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            return CGRectMake(414.0 - 110.0, 5, 50, 50);
        }
        else {
            return CGRectMake(736.0 - 110.0, 5, 50, 50);
        }
    }
    else if (IS_PAD_PRO) {
        if (IS_PORTRAIT) {
            return CGRectMake(1024 - 150.0, 5, 50, 50);
        }
        else {
            return CGRectMake(1366 - 150.0, 5, 50, 50);
        }
    }

    NSLog(@"Dispositivo non verificato  (getButtonDownloadFrame)");
    return CGRectMake(320.0 - 105.0, 5, 50, 50);  //istruzione messa per capire alcuni crash che si verificano ogni tanto
    return CGRectZero;
}

- (CGRect) getButtonWebFrame {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            return CGRectMake(768 - 100.0, 5, 50, 50);
        }
        else {
            return CGRectMake(1024 - 100.0, 5, 50, 50);
        }
    }
    
    if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            return CGRectMake(320 - 65.0, 5, 50, 50);
        }
        else {
            return CGRectMake(480 - 65.0, 5, 50, 50);
        }
    }
    
    if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            return CGRectMake(320 - 65.0, 5, 50, 50);
        }
        else {
            return CGRectMake(568 - 65.0, 5, 50, 50);
        }
    }
    
    if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            return CGRectMake(375.0 - 70.0, 5, 50, 50);
        }
        else {
            return CGRectMake(667.0 - 70.0, 5, 50, 50);
        }
    }
    
    if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            return CGRectMake(414.0 - 70.0, 5, 50, 50);
        }
        else {
            return CGRectMake(736.0 - 70.0, 5, 50, 50);
        }
    }
    else if (IS_PAD_PRO) {
        if (IS_PORTRAIT) {
            return CGRectMake(1024 - 100.0, 5, 50, 50);
        }
        else {
            return CGRectMake(1366 - 100.0, 5, 50, 50);
        }
    }
    
    NSLog(@"Dispositivo non verificato  (getButtonWebFrame)");
    
    return CGRectMake(320.0 - 105.0, 5, 50, 50);  //istruzione messa per capire alcuni crash che si verificano ogni tanto
    return CGRectZero;
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listTwic.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell TBTwic";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    UIButton *buttonDownload = (UIButton *)[cell viewWithTag:3];
    if (!buttonDownload) {
        buttonDownload = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //if (IS_PHONE) {
        //    buttonDownload.frame = CGRectMake(cell.contentView.frame.size.width - 105.0, 5, 50, 50);
        //}
        //else {
        //    buttonDownload.frame = CGRectMake(cell.contentView.frame.size.width - 150.0, 5, 50, 50);
        //}
        
        //CGRect buttonFrame = [self getButtonDownloadFrame];
        
        //buttonDownload.frame = [self getButtonDownloadFrame];
        
        //[buttonDownload setFrame:buttonFrame];
        
        //NSLog(@"W = %f    H = %f", buttonDownload.frame.size.width, buttonDownload.frame.size.height);
        
        
        UIImage *originalImage = [UIImage imageNamed:@"buttonDownload.png"];
        //UIImage *scaledImage = [UIImage imageWithCIImage:originalImage.CGImage scale:(originalImage.scale*2.0) orientation:(originalImage.imageOrientation)];
        
        buttonDownload.contentMode = UIViewContentModeScaleAspectFit;
        
        buttonDownload.tag = 3;
        buttonDownload.hidden = NO;
        [buttonDownload setImage:originalImage forState:UIControlStateNormal];
        [buttonDownload addTarget:self action:@selector(buttonDownloadPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:buttonDownload];
    }
    
    buttonDownload.frame = [self getButtonDownloadFrame];
    
    //if (IS_PAD) {
    //    if (UIInterfaceOrientationIsPortrait([self interfaceOrientation])) {
    //        buttonDownload.frame = CGRectMake(768 - 150.0, 5, 50, 50);
    //    }
    //    else {
    //        buttonDownload.frame = CGRectMake(1024 - 150.0, 5, 50, 50);
    //    }
    //}

    
    UIButton *buttonWeb = (UIButton *)[cell viewWithTag:4];
    if (!buttonWeb) {
        buttonWeb = [UIButton buttonWithType:UIButtonTypeCustom];
        //if (IS_PHONE) {
        //    buttonWeb.frame = CGRectMake(cell.contentView.frame.size.width - 65.0, 5, 50, 50);
        //}
        //else {
        //    buttonWeb.frame = CGRectMake(cell.contentView.frame.size.width - 100.0, 5, 50, 50);
        //}
        
        //buttonWeb.frame = [self getButtonWebFrame];
        
        buttonWeb.tag = 4;
        [buttonWeb setImage:[UIImage imageNamed:@"buttonInfo.png"] forState:UIControlStateNormal];
        [buttonWeb addTarget:self action:@selector(buttonWebPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:buttonWeb];
    }
    
    buttonWeb.frame = [self getButtonWebFrame];
    
    //if (IS_PAD) {
    //    if (UIInterfaceOrientationIsPortrait([self interfaceOrientation])) {
    //        buttonWeb.frame = CGRectMake(768 - 100.0, 5, 50, 50);
    //    }
    //    else {
    //        buttonWeb.frame = CGRectMake(1024 - 100.0, 5, 50, 50);
    //    }
    //}
    
    
    int nt = numeroBase + (int)listTwic.count - 1 - (int)indexPath.row;
    NSDate *dateTweek = [listTwic objectForKey:[NSNumber numberWithInt:nt]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    //[dateFormatter setDateFormat:@"dd/MM/yyyy"];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormatter stringFromDate:dateTweek];
    NSString *tweekString = [NSString stringWithFormat:@"TWIC %d", nt];
    //NSString *twicNumero = [NSString stringWithFormat:@"%d", nt];
    
    cell.imageView.image = [UIImage imageNamed:@"twic.png"];
    
    NSString *tw = [[@"twic" stringByAppendingString:[NSString stringWithFormat:@"%d", nt]] stringByAppendingString:@".pgn"];
    
    if ([listDownloadedTwic containsObject:tw]) {
        buttonDownload.hidden = YES;
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.imageView.layer.borderColor = [UIColor greenColor].CGColor;
        if (IS_PAD) {
            cell.imageView.layer.borderWidth = 3.0;
        }
        else {
            cell.imageView.layer.borderWidth = 2.0;
        }
    }
    else {
        buttonDownload.hidden = NO;
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        cell.imageView.layer.borderWidth = 0.0;
    }
    
    
    // Configure the cell...
    cell.textLabel.text = tweekString;
    cell.detailTextLabel.text = dateString;
    
    NSString *twPath = [twicDocumentPath stringByAppendingPathComponent:tw];
    NSDictionary *attr = [fileManager attributesOfItemAtPath:twPath error:nil];
    NSNumber *twicByteSize = [attr objectForKey:NSFileSize];
    
    long dimensioniFile = twicByteSize.longLongValue;
    if (dimensioniFile > 0) {
        NSString *dimFormattate = [NSByteCountFormatter stringFromByteCount:dimensioniFile countStyle:NSByteCountFormatterCountStyleFile];
        cell.detailTextLabel.text = [[cell.detailTextLabel.text stringByAppendingString:@"  "] stringByAppendingString:dimFormattate];
    }
    
    /*
    float dimTwicMb = twicByteSize.longLongValue/1048576.0;
    if (dimTwicMb>0) {
        NSNumber *twicSizeNumber = [NSNumber numberWithFloat:dimTwicMb];
        NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
        numFormatter.roundingIncrement = [NSNumber numberWithDouble:0.1];
        numFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSString *dimString = [NSString stringWithFormat:@"%@", [numFormatter stringFromNumber:twicSizeNumber]];
        cell.detailTextLabel.text = [[[cell.detailTextLabel.text stringByAppendingString:@"  "] stringByAppendingString:dimString] stringByAppendingString:@" MB"];
    }*/
    
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.row % 2) == 0) {
        UIColor *oddRowColor = [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0];
        [cell setBackgroundColor: oddRowColor];
    }
    else {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    //NSLog(@"Eseguo canEditRow");
    //UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    //NSString *twic = selectedCell.textLabel.text;
    //NSLog(@"TWIC = %@", twic);
    //NSArray *twicArray = [twic componentsSeparatedByString:@" "];
    //NSString *numeroTwic = [twicArray objectAtIndex:1];
    NSUInteger numeroTwic = numeroBase + listTwic.count - 1 - indexPath.row;
    NSString *twicToDelete = [[NSString stringWithFormat:@"twic%ld", (long)numeroTwic]stringByAppendingString:@".pgn"];
    //NSLog(@"Twic to delete = %@", twicToDelete);
    if ([listDownloadedTwic containsObject:twicToDelete]) {
        return YES;
    }
    return NO;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
        //NSString *twic = selectedCell.textLabel.text;
        //NSArray *numeroTwic = [[twic componentsSeparatedByString:@" "] objectAtIndex:1];
        
        
        int numeroTwic = numeroBase + (int)listTwic.count - 1 - (int)indexPath.row;
        
        NSString *twicPgnToDelete = [[NSString stringWithFormat:@"twic%d", numeroTwic]stringByAppendingString:@".pgn"];
        NSString *twicDatToDelete = [[NSString stringWithFormat:@"twic%d", numeroTwic]stringByAppendingString:@".dat"];
        NSLog(@"Devo eliminare %@ e %@", twicPgnToDelete, twicDatToDelete);
        NSString *twicPgnPathToDelete = [twicDocumentPath stringByAppendingPathComponent:twicPgnToDelete];
        NSString *twicDatPathTodelete = [twicDocumentPath stringByAppendingPathComponent:twicDatToDelete];
        NSLog(@"Path da eleiminare %@ e %@", twicPgnPathToDelete, twicDatPathTodelete);
        if ([fileManager removeItemAtPath:twicPgnPathToDelete error:nil]) {
            [fileManager removeItemAtPath:twicDatPathTodelete error:nil];
            [self loadTwic];
            NSArray *ipArray = [[NSArray alloc] initWithObjects:(indexPath), nil];
            [self.tableView reloadRowsAtIndexPaths:ipArray withRowAnimation:UITableViewRowAnimationTop];
            //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *twic = selectedCell.textLabel.text;
    NSArray *twicArray = [twic componentsSeparatedByString:@" "];
    NSString *numeroTwic = [twicArray objectAtIndex:1];
    NSString *twicToDelete = [[NSString stringWithFormat:@"twic%@", numeroTwic]stringByAppendingString:@".pgn"];
    if ([listDownloadedTwic containsObject:twicToDelete]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    if (tableView.isEditing) {
        return;
    }
    
    int numeroTwic = numeroBase + (int)listTwic.count - 1 - (int)indexPath.row;
    NSString *twicToOpen = [[NSString stringWithFormat:@"twic%d", numeroTwic]stringByAppendingString:@".pgn"];
    if ([listDownloadedTwic containsObject:twicToOpen]) {
        NSString *twicToOpenPath = [twicDocumentPath stringByAppendingPathComponent:twicToOpen];
        NSURL *urlPath = [NSURL fileURLWithPath:twicToOpenPath];
        MBProgressHUD *hudOpen = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hudOpen.minSize = [UtilToView getSizeOfMBProgress];
        hudOpen.labelText = @"Loading ...";
        hudOpen.detailsLabelText = twicToOpen;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:urlPath];
            [pfd openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    //PgnFileInfo *pfi = [pfd pgnFileInfo];
                    //BOOL salvato = [NSKeyedArchiver archiveRootObject:pfi toFile:pfi.savePath];
                    //if (salvato) {
                        //NSLog(@"Database %@ salvato correttamente", pfi.fileName);
                        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
                        PgnFileInfoTableViewController *pitvc = [sb instantiateViewControllerWithIdentifier:@"PgnFileInfoTable"];
                        [pitvc setPgnFileDoc:pfd];
                        [self.navigationController pushViewController:pitvc animated:YES];
                    //}
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        });
    }
}


- (void) buttonDownloadPressed:(UIButton *)sender {
    
    if (self.tableView.isEditing) {
        return;
    }
    
    internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];

    if (networkStatus == NotReachable) {
        UIAlertView *notReachableAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_INTERNET", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [notReachableAlertView show];
        return;
    }
    
    numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.roundingIncrement = [NSNumber numberWithDouble:0.1];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    //NSNumber *twicSizeNumber = [NSNumber numberWithFloat:0.0];
    //NSString *twicSizeString = [NSString stringWithFormat:@"%@%%", [numberFormatter stringFromNumber:twicSizeNumber]];
    
    UITableViewCell *cell = nil;
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        cell = (UITableViewCell *)[[sender superview] superview];
    }
    else {
        if (IS_IOS_7) {
            cell = (UITableViewCell *)[[[sender superview] superview] superview];
        }
        else {
            cell = (UITableViewCell *)[[sender superview] superview];
        }
    }
    
    //NSLog(@"Twic selezionato = %@", cell.textLabel.text);
    NSInteger riga = [self.tableView indexPathForCell:cell].row;
    NSInteger nt = numeroBase + listTwic.count - 1 - riga;
    
    finalTwicPath = [[NSMutableString alloc] initWithString:@"http://www.theweekinchess.com/zips/twic"];
    [finalTwicPath appendFormat:@"%ld", (long)nt];
    [finalTwicPath appendString:@"g.zip"];
    NSURL *url = [NSURL URLWithString:finalTwicPath];
    NSURLRequest *twicUrlRequest = [NSURLRequest requestWithURL:url];
    totalDownloaded = 0;
    totalData = [[NSMutableData alloc] init];
    _connection = [NSURLConnection connectionWithRequest:twicUrlRequest delegate:self];
    
    /*
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.minSize = CGSizeMake(250, 150);
    NSString *detailtext = [@"The Week In Chess " stringByAppendingFormat:@"%d", nt];
    hud.labelText = [@"Downloading " stringByAppendingString:detailtext];
    hud.detailsLabelText = twicSizeString;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [connection start];
    });
    */
    
    NSString *message;
    if (IS_IOS_7) {
        message = NSLocalizedString(@"DATABASE_DOWNLOADING_IOS7", nil);
    }
    else {
        message = @" ";
    }
    
    NSString *detailtext = [@"TWIC " stringByAppendingFormat:@"%ld", (long)nt];
    NSString *alertTitle = [NSLocalizedString(@"TWIC DOWNLOAD ", nil) stringByAppendingString:detailtext];
    alert = [[UIAlertView alloc] initWithTitle:alertTitle message:message delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:nil];
    if (!IS_IOS_7) {
        UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 40, 25, 25)];
        progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [progress performSelectorInBackground:@selector(startAnimating) withObject:self];
        [alert addSubview:progress];
        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progressView.frame = CGRectMake(20, 70, 240, 5);
        progressView.progress = 0.0;
        [alert addSubview:progressView];
    }
    [_connection start];
    //NSLog(@"Faccio partire ALERT");
    [alert show];
    
}

- (void) buttonWebPressed:(UIButton *)sender {
    
    if (self.tableView.isEditing) {
        return;
    }
    
    internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [internetReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        UIAlertView *notReachableAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_INTERNET", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [notReachableAlertView show];
        return;
    }
    
    UITableViewCell *cell = nil;
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        cell = (UITableViewCell *)[[sender superview] superview];
    }
    else {
        if (IS_IOS_7) {
            cell = (UITableViewCell *)[[[sender superview] superview] superview];
        }
        else {
            cell = (UITableViewCell *)[[sender superview] superview];
        }
    }
    
    NSInteger riga = [self.tableView indexPathForCell:cell].row;
    NSInteger nt = numeroBase + listTwic.count - 1 - riga;
    self.title = @"TWIC";
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    TwicWebViewController *twvc = [sb instantiateViewControllerWithIdentifier:@"TwicWebViewController"];
    [twvc setTwicNumber:nt];
    [self.navigationController pushViewController:twvc animated:YES];
}

//Implementazione delegato alertView

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSLog(@"Annullo il download");
    [_connection cancel];
}

//Implementazione delegato Download

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"DidReceiveResponse");
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
    if (statusCode == 404) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        [connection cancel];
        UIAlertView *noTwicAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TWIC ND", nil) message:NSLocalizedString(@"TWIC ND1", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [noTwicAlertView show];
        return;
    }
    [alert show];
    NSString *contentLengthString = [[httpResponse allHeaderFields] objectForKey:@"Content-length"];
    //NSLog(@"ContentLength: %@", contentLengthString);
    downloadSize = [contentLengthString integerValue];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //NSLog(@"Did Receive Data");
    totalDownloaded += [data length];
    //NSLog(@"Ricevuto dati %d", totalDownloaded);
    [totalData appendData:data];
    
    float percentByteDownloaded = 1.*totalDownloaded/downloadSize;
    //float percentByteDownloaded = 100.0*totalDownloaded/downloadSize;
    //NSLog(@"Percentuale scaricata = %f", percentByteDownloaded);
    [progressView setProgress:percentByteDownloaded];
    
    NSNumber *twicSizeNumber = [NSNumber numberWithFloat:percentByteDownloaded];
    NSString *twicSizeString = [NSString stringWithFormat:@"%@%%", [numberFormatter stringFromNumber:twicSizeNumber]];
    hud.detailsLabelText = twicSizeString;
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //NSLog(@"Did Fail With Error");
    NSString *errore = NSLocalizedString(@"ERROR", nil);
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:errore message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [errorAlertView show];
    [_connection cancel];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSLog(@"File Scaricato correttamente");
    NSString *zipFilePath = [twicDocumentPath stringByAppendingPathComponent:[finalTwicPath lastPathComponent]];
    //NSString *filePath = [[twicDocumentPath stringByAppendingString:[risu objectAtIndex:1]] stringByAppendingString:@".zip"];
    //NSLog(@"File 0 %@", zipFilePath);
    [totalData writeToFile:zipFilePath atomically:YES];
    
    NSString *lastPathFile = [zipFilePath substringFromIndex:[zipFilePath length] - 3];
    if ([lastPathFile caseInsensitiveCompare:@"ZIP"] == NSOrderedSame) {
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        if ([zipArchive UnzipOpenFile:zipFilePath]) {
            if ([zipArchive UnzipFileTo:twicDocumentPath overWrite:YES] != NO) {
                [fileManager removeItemAtPath:zipFilePath error:nil];
                [self loadTwic];
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        }
        else {
            UIAlertView *noTwicAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TWIC ND", nil) message:NSLocalizedString(@"TWIC ND1", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noTwicAlertView show];
            [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        }
    }
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

- (IBAction)buttonActionPressed:(id)sender {
    if (actionSheetMenu.window ) {
        [actionSheetMenu dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    NSString *cancelButton;
    if (IS_PAD) {
        cancelButton = @"";
    }
    else {
        cancelButton = NSLocalizedString(@"ACTIONSHEET_CANCEL", nil);
    }
    //actionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelButton destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"MENU_EDIT_TWIC", nil), nil];
    
    
    actionSheetMenu = [[UIActionSheet alloc] init];
    actionSheetMenu.delegate = self;
    
    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_EDIT_TWIC", nil)];
    actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
    
    
    [actionSheetMenu showFromBarButtonItem:button animated:YES];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex<0) {
        return;
    }
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"MENU_EDIT_TWIC", nil)]) {
        [self edit];
        return;
    }
}

- (void) edit {
    if (![self.tableView isEditing]) {
        [self.tableView setEditing:YES animated:YES];
        actionButton = self.navigationItem.rightBarButtonItem;
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE_OK", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    else {
        [self.tableView setEditing:NO animated:YES];
    }
}

- (void) doneButtonPressed {
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = actionButton;
}

@end
