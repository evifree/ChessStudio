//
//  TBDatabaseTableViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 12/03/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "TBDatabaseTableViewController.h"
#import "PgnDbManager.h"
#import "PgnFileDocument.h"
#import "PgnFileInfo.h"
#import "PgnFileInfoTableViewController.h"
#import "MBProgressHUD.h"
#import "PgnDownloadViewController.h"
#import "UtilToView.h"
#import "PGNPastedGame.h"
#import "PgnPastedGameViewController.h"
#import "PgnPastedGameTableViewController.h"
#import "TBDatabaseCollectionViewController.h"
#import "SettingManager.h"
#import "PgnMentorTableViewController.h"
#import "DropboxTableViewController.h"

//#import "ChessBoardViewController.h"

//#import "PGN.h"

#import "SWRevealViewController.h"


@interface TBDatabaseTableViewController () {

    PgnDbManager *pgnDbManager;
    NSMutableArray *listFile;
    
    
    
    NSArray *fileSelezionatiDaEliminareSpostare;
    
    PgnFileInfo *pfi;
    
    //MainPopoverViewController *mpvc;
    //UIPopoverController *popoverController;
    //SEL action;
    //id target;
    UIActionSheet *actionSheetMenu;
    UIBarButtonItem *actionButton;
    
    
    //UIView *titoloView;
    
    NSString *rootPath;
    
    NSString *documentPattern;
    NSRegularExpression *documentRegex;
    
    
    
    //UISegmentedControl *dispSegmentedControl;
    UIPopoverController *actionButtonPopoverController;
    
    
    BOOL showRevealIcon;
    BOOL isAppWithReveal;
    
    
    //NSMetadataQuery *_query;
    //NSMutableArray *_iCloudURLs;
    NSMutableArray *_iCloudDatabase;
    
    
    
    SWRevealViewController *revealViewController;
}

@end

@implementation TBDatabaseTableViewController

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
    
    //self.navigationController.navigationBar.delegate = self;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //NSMutableArray *tabBarArray = [NSMutableArray arrayWithArray:[self.tabBarController viewControllers]];
    //[tabBarArray removeObjectAtIndex:2];
    //[self.tabBarController setViewControllers:tabBarArray];
    
    //self.navigationController.toolbarHidden = NO;
    
    
    if (IsChessStudioLight) {
        //UIImageView *sfondo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CSSfondo.png"]];
        //[sfondo setFrame:self.tableView.frame];
        //sfondo.alpha = 0.1;
        //self.tableView.backgroundView = sfondo;
        
        
        //if (IS_IOS_7) {
            self.canDisplayBannerAds = YES;
        //}
        
    }
    
    
    documentPattern = @"Documents";
    documentRegex = [[NSRegularExpression alloc] initWithPattern:documentPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    rootPath = [paths objectAtIndex:0];
    
    
    if (!_actualPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _actualPath = [paths objectAtIndex:0];
        showRevealIcon = YES;
        
        /*
        if (IS_PAD) {
            [self setNavigationTitlePad];
        }
        else {
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
                [self setNavigationTitlePhonePortrait];
            }
            else {
                [self setNavigationTitlePhoneLandscape];
            }
        }*/
    }
    else {
        //self.navigationItem.title = [_actualPath lastPathComponent];
        //NSLog(@"Actual Path esiste quindi non devo visualizzare Reveal");
        showRevealIcon = NO;
    }
    [self decidiTitolo];
    pgnDbManager = [PgnDbManager sharedPgnDbManager];
    listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredForeground:) name:@"EnteredForeground" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLoadedFile:) name:@"DropboxLoadedFile" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLinked:) name:@"DropboxLinked" object:nil];
    
    
    
    //UIBarButtonItem *gridBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Grid2"] style:UIBarButtonItemStyleBordered target:self action:@selector(goToGridDisplay)];
    //self.navigationItem.leftBarButtonItem = gridBarButtonItem;
    
    
    
    
    //[self.navigationItem setHidesBackButton:NO];
    
    
    //dispSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"List", @"Grid", nil]];
    //[dispSegmentedControl setWidth:70.0 forSegmentAtIndex:0];
    //[dispSegmentedControl setWidth:70.0 forSegmentAtIndex:1];
    //[dispSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBordered];
    //[dispSegmentedControl setSelectedSegmentIndex:0];
    //[dispSegmentedControl setImage:[UIImage imageNamed:@"List2"] forSegmentAtIndex:0];
    //[dispSegmentedControl setImage:[UIImage imageNamed:@"Grid2"] forSegmentAtIndex:1];
    //[dispSegmentedControl addTarget:self action:@selector(displayModeChanged:) forControlEvents:UIControlEventValueChanged];
    //self.navigationItem.titleView = dispSegmentedControl;
    
    
    
    
    //UIBarButtonItem *addFolderBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FolderAdd"] style:UIBarButtonItemStyleBordered target:nil action:nil];
    //UIBarButtonItem *manageDbBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ManageDatabase"] style:UIBarButtonItemStyleBordered target:nil action:nil];
    //UIBarButtonItem *downloadDbBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DownloadDatabase"] style:UIBarButtonItemStyleBordered target:nil action:nil];
    //UIBarButtonItem *pasteGamesBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PasteGames"] style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    //[self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:addFolderBarButtonItem, manageDbBarButtonItem, downloadDbBarButtonItem, pasteGamesBarButtonItem, nil]];
    
    
    
    //UIBarButtonItem *newChessBoardBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newChessBoardButtonPressed)];
    //self.navigationItem.leftBarButtonItem = newChessBoardBarButtonItem;
    
    isAppWithReveal = NO;
    
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window]rootViewController];
    
    if ([rootViewController isKindOfClass:[SWRevealViewController class]]) {
        isAppWithReveal = YES;
        if (showRevealIcon) {
            revealViewController = [self revealViewController];
            [revealViewController panGestureRecognizer];
            [revealViewController tapGestureRecognizer];
            
            UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(revealToggleLocal:)];
            self.navigationItem.leftBarButtonItem = revealButtonItem;
        }
        
        //UIImage *image = [[UIImage imageNamed:@"CSIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
        

        /*
        self.navigationController.toolbarHidden = NO;
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *addPgnBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FolderAdd"] style:UIBarButtonItemStyleBordered target:self action:@selector(newDirectory)];
        UIBarButtonItem *newDatabaseBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newDatabase)];
        UIBarButtonItem *pasteGamesBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PasteGames"] style:UIBarButtonItemStyleBordered target:self action:@selector(managePasteGame)];
        self.toolbarItems = [NSArray arrayWithObjects:addPgnBarButtonItem, flex, newDatabaseBarButtonItem, flex, pasteGamesBarButtonItem, nil];
        */
        
        
        //UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
        //self.navigationItem.rightBarButtonItem = editButtonItem;
    }
    
    
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0xB0E2FF);
    
    
    
    
    //[self initCloud];
}

/*
- (void) newChessBoardButtonPressed {
    ChessBoardViewController *cbvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChessBoardViewController"];
    cbvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UINavigationController *cbnc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChessBoardNavigationController"];
    cbnc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self presentModalViewController:boardNavigationController animated:YES];
        [self presentViewController:cbnc animated:YES completion:nil];
    });
}
*/

- (void) revealToggleLocal:(UIBarButtonItem *) sender {
    if ([actionButtonPopoverController isPopoverVisible]) {
        [actionButtonPopoverController dismissPopoverAnimated:YES];
        actionButtonPopoverController = nil;
    }
    if ([self.tableView isEditing]) {
        [self.tableView setEditing:NO animated:YES];
    }
    [revealViewController revealToggle:sender];
}

- (void) displayModeChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        NSLog(@"Devo visualizzare la lista");
    }
    else if (sender.selectedSegmentIndex == 1) {
        UIStoryboard *sb = [UtilToView getStoryBoard];
        TBDatabaseCollectionViewController *tbdcvc = [sb instantiateViewControllerWithIdentifier:@"TBDatabaseCollectionViewController"];
        //UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        //TBDatabaseCollectionViewController *tbdcvc = [[TBDatabaseCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
        //UINavigationController *navController = [sb instantiateViewControllerWithIdentifier:@"TBDatabaseCollectionNavigationController"];
        //TBDatabaseCollectionViewController *tbdcvc = (TBDatabaseCollectionViewController *)[navController visibleViewController];
        [tbdcvc setListFile:listFile];
        //self.navigationItem.title = @"";
        [self.navigationController pushViewController:tbdcvc animated:NO];
        //[self presentViewController:navController animated:NO completion:nil];
    }
}

- (void) goToGridDisplay {
    UIStoryboard *sb = [UtilToView getStoryBoard];
    TBDatabaseCollectionViewController *tbdcvc = [sb instantiateViewControllerWithIdentifier:@"TBDatabaseCollectionViewController"];
    [tbdcvc setListFile:listFile];
    [self.navigationController pushViewController:tbdcvc animated:NO];
}

- (void) enteredForeground:(NSNotification *) notification {
    //NSLog(@"ENTERED FOREGROUND");
    listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
    [self.tableView reloadData];
}

- (void) dropboxLoadedFile:(NSNotification *) notification {
    NSLog(@"ESEGUO NOTIFICA");
    listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
    [self.tableView reloadData];
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    [self connectToDropbox];
    //});
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //    sleep(1);
    //    [self connectToDropbox];
    //});
}

- (void) dropboxLinked:(NSNotification *)notification {
    NSLog(@"Notifica Dropbox ricevuta da TBDatabaseTableViewController");
    [self performSelector:@selector(connectToDropbox) withObject:nil afterDelay:0.3];
    //[self connectToDropbox];
}


- (void) decidiTitolo {
    NSArray *matches = [documentRegex matchesInString:_actualPath options:0 range:NSMakeRange(0, [_actualPath length])];
    NSString *lastPath = [_actualPath lastPathComponent];
    if ([lastPath isEqualToString:@"Documents"]) {
        if (matches.count > 1) {
            self.navigationItem.title = lastPath;
        }
        else {
            if (IS_PHONE) {
                if (IS_PORTRAIT) {
                    [self setNavigationTitlePhonePortrait];
                }
                else {
                    self.navigationItem.title = @"Chess Studio DataBase";
                }
            }
            else {
                //self.navigationItem.title = @"Chess Studio DataBase";
                [self setNavigationTitlePad:@"Chess Studio Database"];
            }
        }
    }
    else {
        if (IS_PAD) {
            [self setNavigationTitlePad:lastPath];
        }
        else if (IS_PAD_PRO) {
            [self setNavigationTitlePad:lastPath];
        }
        else {
            self.navigationItem.title = lastPath;
        }
    }
}

- (void) setActualPath:(NSString *)actualPath {
    _actualPath = actualPath;
    listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //[self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
    listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
    [self.tableView reloadData];
    
    if (IS_PAD) {
        [self setNavigationTitlePad];
    }
    else if (IS_PAD_PRO) {
        [self setNavigationTitlePad];
    }
    else {
        if (IS_PORTRAIT) {
            [self setNavigationTitlePhonePortrait];
        }
        else {
            [self setNavigationTitlePhoneLandscape];
        }
    }
    //[dispSegmentedControl setSelectedSegmentIndex:0];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        if (actionSheetMenu) {
            [actionSheetMenu dismissWithClickedButtonIndex:-1 animated:YES];
            actionSheetMenu = nil;
        }
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
    [self.tableView reloadData];
    return;
    /*
    if (IS_PAD) {
        [self setNavigationTitlePad];
    }
    else {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
            [self setNavigationTitlePhonePortrait];
        }
        else {
            [self setNavigationTitlePhoneLandscape];
        }
    }*/
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //NSLog(@"WILL ROTATE");
    if (IS_PAD) {
        [self setNavigationTitlePad];
    }
    else if (IS_PAD_PRO) {
        [self setNavigationTitlePad];
    }
    else {
        
        return;
        
        if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
            //NSLog(@"WillRotate: Devo settare il portrait");
            [self setNavigationTitlePhonePortrait];
        }
        else {
            //NSLog(@"WillRotate: Devo settare il landscape");
            [self setNavigationTitlePhoneLandscape];
        }
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //NSLog(@"DID ROTATE");
    if (IS_PAD) {
        [self setNavigationTitlePad];
    }
    else if (IS_PAD_PRO) {
        [self setNavigationTitlePad];
    }
    else {
        
        if (IS_PORTRAIT) {
            //NSLog(@"DidRotate: Devo aggiornare portrait");
            [self setNavigationTitlePhonePortrait];
        }
        else if (IS_LANDSCAPE) {
            //NSLog(@"DidRotate: Devo aggiornare landscape");
            [self setNavigationTitlePhoneLandscape];
        }
        
        
        return;
        
        if ((fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            //NSLog(@"DidRotate: Devo aggiornare portrait");
            [self setNavigationTitlePhonePortrait];
        }
        else {
            [self setNavigationTitlePhoneLandscape];
            //NSLog(@"DidRotate: Devo aggiornare landscape");
        }
    }
}


- (void) setNavigationTitlePad {
    NSArray *matches = [documentRegex matchesInString:_actualPath options:0 range:NSMakeRange(0, [_actualPath length])];
    NSString *lastPath = [_actualPath lastPathComponent];
    if ([lastPath isEqualToString:@"Documents"]) {
        if (matches.count > 1) {
            self.navigationItem.title = lastPath;
        }
        else {
            self.navigationItem.title = @"Chess Studio DataBase";
        }
    }
    else {
        self.navigationItem.title = lastPath;
    }
}


- (void) setNavigationTitlePad:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    if (IS_PAD) {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:35.0];
    }
    else if (IS_PAD_PRO) {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:35.0];
    }
    else {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25.0];
    }
    
    //titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textColor = UIColorFromRGB(0x0000CD);
    titleLabel.text = title;
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationItem.titleView = titleLabel;
}

- (void) setNavigationTitlePhonePortrait {
    
    //NSLog(@"NAVIGATION TITLE PHONE PORTRAIT");
    
    self.navigationItem.title = nil;
    self.navigationItem.titleView = nil;
    
    UIColor *coloreTitolo;
    if (IS_IOS_7) {
        coloreTitolo = [UIColor blackColor];
    }
    else {
        coloreTitolo = [UIColor whiteColor];
    }
    
    self.navigationItem.title = @"Database";
    
    //return;
    
    /*
    UIView *titoloView;
    UILabel *label1;
    UILabel *label2;
    if (IS_ITALIANO) {
        titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
        label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 170, 28)];
        label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 170, 16)];
    }
    else {
        titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
        label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 190, 28)];
        label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 190, 16)];
    }
    
    //titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
    label1.font = [UIFont boldSystemFontOfSize:18.0];
    label1.textColor = coloreTitolo;
    label1.text = @"Chess Studio";
    label1.backgroundColor = [UIColor clearColor];
    if (IS_IOS_7) {
        label1.textAlignment = NSTextAlignmentCenter;
    }
    else {
        label1.textAlignment = UITextAlignmentCenter;
    }
    [titoloView addSubview:label1];
    
    label2.font = [UIFont boldSystemFontOfSize:18.0];
    label2.text = @"Database";
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = coloreTitolo;
    if (IS_IOS_7) {
        label2.textAlignment = NSTextAlignmentCenter;
    }
    else {
        label2.textAlignment = UITextAlignmentCenter;
    }
    [titoloView addSubview:label2];
    self.navigationItem.titleView = titoloView;
     */
}

- (void) setNavigationTitlePhoneLandscape {
    self.navigationItem.titleView = nil;
    self.navigationItem.title = @"Chess Studio DataBase";
}

/*
- (BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    NSLog(@"SHOULD POP ITEM");
    if (actionSheetMenu) {
        
        
        return NO;
    }
    return YES;
}

- (void) navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
    NSLog(@"DID POP ITEM");
    [self.navigationController popViewControllerAnimated:YES];
}
*/

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    //if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
    //    return YES;
    //}
    //if (IS_PHONE) {
    //    return YES;
    //}
    //if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
        //return YES;
    //}
    return YES;
}

/*
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (IS_PAD) {
        [self setNavigationTitlePad];
    }
    else if (IS_PHONE) {
        if (fromInterfaceOrientation == UIInterfaceOrientationPortrait) {
            [self setNavigationTitlePhoneLandscape];
        }
        else {
            [self setNavigationTitlePhonePortrait];
        }
    }
}*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_iCloudDatabase && _iCloudDatabase.count>0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_iCloudDatabase && _iCloudDatabase.count>0) {
        if (section == 1) {
            return _iCloudDatabase.count;
        }
    }
    return listFile.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell TBDatabase";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    if (IS_PHONE) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    if (IS_PAD_PRO) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    
    if (indexPath.section == 0) {
        NSString *item = [listFile objectAtIndex:indexPath.row];
        NSString *newPath = [_actualPath stringByAppendingPathComponent:item];
        if ([pgnDbManager isDirectoryAtPath:newPath]) {
            NSInteger numberOfItems = [pgnDbManager numberOfItemsAtPath:newPath];
            cell.imageView.image = [UIImage imageNamed:@"ChessFolder.png"];
            NSMutableString *testo = [[NSMutableString alloc] initWithString:item];
            
            //NSLog(@"Inizio = %f   Larghezza = %f", cell.textLabel.frame.origin.x, cell.textLabel.frame.size.width);
            if (numberOfItems > 0) {
                [testo appendString:@" "];
                [testo appendFormat:@"(%ld)", (long)numberOfItems];
            }
            
            cell.textLabel.text = testo;
            
            NSString *data = [pgnDbManager getCreationInfo:newPath];
            cell.detailTextLabel.text = data;
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"PgnChessIcon"];
            NSString *data = [pgnDbManager getCreationInfo:newPath];
            cell.textLabel.text = item;
            cell.detailTextLabel.text = data;
            
            
            NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:newPath error:nil];
            NSNumber *fileByteSize = [attr objectForKey:NSFileSize];
            
            long dimensioniFile = fileByteSize.longLongValue;
            NSString *dimFormattate = [NSByteCountFormatter stringFromByteCount:dimensioniFile countStyle:NSByteCountFormatterCountStyleFile];
            cell.detailTextLabel.text = [[cell.detailTextLabel.text stringByAppendingString:@"  "] stringByAppendingString:dimFormattate];
            
        }
    }
    else if (indexPath.section == 1) {
        NSString *item = [_iCloudDatabase objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"PgnChessIconCloud"];
        cell.textLabel.text = item;
    }
    

    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
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

- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *thfv = (UITableViewHeaderFooterView *)view;
        thfv.textLabel.textColor = [UIColor blackColor];
        //thfv.contentView.backgroundColor = [UIColor blackColor];
        thfv.contentView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.9];
        thfv.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:22.0];
    }
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //return 40.0;
    if (section == 0) {
        //return 44.0;
    }
    
    if (tableView.numberOfSections == 2) {
        return 30.0;
    }
    
    return 0.0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView.numberOfSections == 2) {
        if (section == 0) {
            return @"PGN Database";
        }
        else if (section == 1) {
            return @"iCloud Database";
        }
    }
    return nil;
}

 - (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
     return nil;
     
     if (section == 0) {
         
         UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(100,0, 320, 44)];
         
         NSArray *segControlArray = [NSArray arrayWithObjects:@"Alphabet", @"Size", @"Date", nil];
         UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:segControlArray];
         [segControl setFrame:CGRectMake(60.0, 0, 200.0, 30.0)];
         [headerView addSubview:segControl];
         return headerView;
     }
     
     
     
     UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 500, 40)];
     //[toolbar setBackgroundColor:[UIColor orangeColor]];
     //[toolbar setTintColor:[UIColor orangeColor]];
     //[toolbar setOpaque:YES];
     
     UIBarButtonItem *grid = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Grid2"] style:UIBarButtonItemStylePlain target:self action:@selector(goToGridDisplay)];
     UIBarButtonItem *addFolderBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FolderAdd"] style:UIBarButtonItemStylePlain target:nil action:nil];
     UIBarButtonItem *b1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:nil action:nil];
     UIBarButtonItem *b2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
     UIBarButtonItem *download = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DownloadDatabase"] style:UIBarButtonItemStylePlain target:nil action:nil];
     UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
     toolbar.items = [NSArray arrayWithObjects:grid, flex, addFolderBarButtonItem, flex, download, flex, b1, flex, b2, nil];
     return toolbar;
     
     
     UISegmentedControl *dispSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"List", @"Grid", nil]];
     [dispSegmentedControl setWidth:70.0 forSegmentAtIndex:0];
     [dispSegmentedControl setWidth:70.0 forSegmentAtIndex:1];
     [dispSegmentedControl setSelectedSegmentIndex:1];
     [dispSegmentedControl setImage:[UIImage imageNamed:@"List"] forSegmentAtIndex:0];
     [dispSegmentedControl setImage:[UIImage imageNamed:@"Grid"] forSegmentAtIndex:1];
     [dispSegmentedControl addTarget:self action:@selector(displayModeChanged:) forControlEvents:UIControlEventValueChanged];
     //self.navigationItem.titleView = dispSegmentedControl;
     return dispSegmentedControl;
     UILabel *label = [[UILabel alloc] init];
     label.backgroundColor = [UIColor yellowColor];
     label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25.0];
     label.adjustsFontSizeToFitWidth = YES;
     label.text = @"";
     return label;
 }


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        fileSelezionatiDaEliminareSpostare = [NSArray arrayWithObject:indexPath];
        
        UIAlertController *confirmDeleteAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIRM_TITLE_DELETE_DATABASE", nil) message:NSLocalizedString(@"CONFIRM_DELETE_SINGLE_DATABASE", nil) preferredStyle:UIAlertControllerStyleAlert];
        [confirmDeleteAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *item = [listFile objectAtIndex:indexPath.row];
            NSString *documentPath = [_actualPath stringByAppendingPathComponent:item];
            if ([pgnDbManager isDirectoryAtPath:documentPath]) {
                //UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Delete directory" message:@"Sei sicuro di voler eliminare la directory?" delegate:self cancelButtonTitle:@"Cancle" otherButtonTitles:@"OK", nil];
                //confirm.alertViewStyle = UIAlertViewStyleDefault;
                //[confirm show];
                
                if ([pgnDbManager deleteDirectoryAtPath:documentPath]) {
                    //[listFile removeObjectAtIndex:indexPath.row];
                    listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
                
            }
            else {
                if ([pgnDbManager deleteDatabaseAtPath:documentPath]) {
                    if (pfi.savePath) {
                        [pgnDbManager deleteDatabaseAtPath:pfi.savePath];
                    }
                    listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
            [tableView reloadData];
        }]];
        
        [confirmDeleteAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:confirmDeleteAlertController animated:YES completion:^{
        }];
        
//        return;
//        
//        
//        UIAlertView *deleteDbAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONFIRM_TITLE_DELETE_DATABASE", nil) message:NSLocalizedString(@"CONFIRM_DELETE_SINGLE_DATABASE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
//        deleteDbAlertView.tag = 700;
//        [deleteDbAlertView show];
//        return;
//        
//        NSString *item = [listFile objectAtIndex:indexPath.row];
//        NSString *documentPath = [_actualPath stringByAppendingPathComponent:item];
//        if ([pgnDbManager isDirectoryAtPath:documentPath]) {
//            //UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Delete directory" message:@"Sei sicuro di voler eliminare la directory?" delegate:self cancelButtonTitle:@"Cancle" otherButtonTitles:@"OK", nil];
//            //confirm.alertViewStyle = UIAlertViewStyleDefault;
//            //[confirm show];
//            
//            if ([pgnDbManager deleteDirectoryAtPath:documentPath]) {
//                //[listFile removeObjectAtIndex:indexPath.row];
//                listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
//                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            }
//            
//        }
//        else {
//            if ([pgnDbManager deleteDatabaseAtPath:documentPath]) {
//                if (pfi.savePath) {
//                    [pgnDbManager deleteDatabaseAtPath:pfi.savePath];
//                }
//                listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
//                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            }
//        }
//        return;
        
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(NSString *)tableView:(UITableView *)tableView titleForSwipeAccessoryButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return NSLocalizedString(@"COPY", nil);
    return NSLocalizedString(@"MORE", nil);
}

-(void)tableView:(UITableView *)tableView swipeAccessoryButtonPushedForRowAtIndexPath:(NSIndexPath *)indexPath {
    //fileSelezionatiDaEliminareSpostare = [NSArray arrayWithObject:indexPath];
    //[self copyPgnDatabases];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"COPY_DB", nil) style:UIAlertControllerStyleActionSheet handler:^(UIAlertAction * _Nonnull action) {
        fileSelezionatiDaEliminareSpostare = [NSArray arrayWithObject:indexPath];
        [self copyPgnDatabases];
        //tableView.editing = NO;
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MOVE_DB", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        fileSelezionatiDaEliminareSpostare = [NSArray arrayWithObject:indexPath];
        //[self iCloudExport];
        //[self iCloudExport:UIDocumentPickerModeExportToService];
        //tableView.editing = NO;
        [self movePgnDatabase];
    }]];
    
    if ([[listFile objectAtIndex:indexPath.row] hasSuffix:@".pgn"]) {
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_RENAME_DATABASE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            fileSelezionatiDaEliminareSpostare = [NSArray arrayWithObject:indexPath];
            //[self iCloudSposta];
            //[self iCloudExport:UIDocumentPickerModeMoveToService];
            //tableView.editing = NO;
            [self renamePgnDatabase];
        }]];
    }
    else {
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_RENAME_FOLDER", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            fileSelezionatiDaEliminareSpostare = [NSArray arrayWithObject:indexPath];
            //[self iCloudSposta];
            //[self iCloudExport:UIDocumentPickerModeMoveToService];
            //tableView.editing = NO;
            [self renameFolder];
        }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_EMAIL_DATABASE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        fileSelezionatiDaEliminareSpostare = [NSArray arrayWithObject:indexPath];
        //[self iCloudImport];
        //tableView.editing = NO;
        [self manageFileForEmail];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"UPLOAD_DROPBOX_0", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        fileSelezionatiDaEliminareSpostare = [NSArray arrayWithObject:indexPath];
        //[self iCloudImport];
        //tableView.editing = NO;
        
        if ([[DBSession sharedSession] isLinked]) {
            [self connectToDropbox];
        }
        else {
            [[DBSession sharedSession] linkFromController:self];
        }
        
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        tableView.editing = NO;
    }]];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIPopoverPresentationController *popover = [alertController popoverPresentationController];
    popover.sourceView = tableView;
    popover.sourceRect = CGRectMake((cell.frame.size.width-155), cell.frame.origin.y  , cell.frame.size.width, cell.frame.size.height);
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}


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
    
    if (self.tableView.isEditing) {
        fileSelezionatiDaEliminareSpostare = [tableView indexPathsForSelectedRows];
        return;
    }
    
    
    NSString *item = [listFile objectAtIndex:indexPath.row];
    
    //PGN *pgnFile = [[PGN alloc] initWithFilename:item];
    //[pgnFile initializeGameIndices];
    //NSLog(@"Nel database ci sono %d partite", pgnFile.numberOfGames);
    
    
    if ([pgnDbManager isPgnFile:item]) {
        
        NSString *documentPath = [_actualPath stringByAppendingPathComponent:item];
        NSURL *urlPath = [NSURL fileURLWithPath:documentPath];
        
        //NSLog(@"Indirizzo file = %@", documentPath);
        //PgnFileInfo *pgnFileInfo = [[PgnFileInfo alloc] initWithFilePath:documentPath];
        
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.minSize = [UtilToView getSizeOfMBProgress];
        hud.labelText = @"Loading ...";
        hud.detailsLabelText = item;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
            PgnFileDocument *pfd = [[PgnFileDocument alloc] initWithFileURL:urlPath];
            [pfd openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    pfi = [pfd pgnFileInfo];
                    // Do something...
                    //BOOL salvato = [NSKeyedArchiver archiveRootObject:pfi toFile:pfi.savePath];
                    //if (salvato) {
                        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
                        PgnFileInfoTableViewController *pitvc = [sb instantiateViewControllerWithIdentifier:@"PgnFileInfoTable"];
                        [pitvc setPgnFileDoc:pfd];
                        [self.navigationController pushViewController:pitvc animated:YES];
                        
                        if (IS_PHONE) {
                            if (IS_IOS_7) {
                                self.navigationItem.title = @"";
                            }
                            else {
                                self.navigationItem.title = NSLocalizedString(@"BACK", nil);
                            }
                        }
                    //}
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
            }];
        });
    }
    else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
        TBDatabaseTableViewController *tbdtvc = [sb instantiateViewControllerWithIdentifier:@"TBDatabaseTableViewController"];
        NSString *nextPath = [_actualPath stringByAppendingPathComponent:item];
        //NSLog(@"NextPath = %@", nextPath);
        [tbdtvc setActualPath:nextPath];
        [self.navigationController pushViewController:tbdtvc animated:YES];
    }
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        fileSelezionatiDaEliminareSpostare = [tableView indexPathsForSelectedRows];
    }
}

- (IBAction)buttonActionPressed:(id)sender {
    /*
    if (isAppWithReveal) {
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
        actionSheetMenu = [[UIActionSheet alloc] init];
        
        if ([self.tableView isEditing]) {
            if (fileSelezionatiDaEliminareSpostare.count>0) {
                [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"DELETE_DB", nil)];
                [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MOVE_DB", nil)];
                
                if (fileSelezionatiDaEliminareSpostare.count == 1) {
                    
                    NSIndexPath *indexPath = [fileSelezionatiDaEliminareSpostare objectAtIndex:0];
                    NSString *dbName = [listFile objectAtIndex:indexPath.row];
                    
                    if ([dbName hasSuffix:@".pgn"]) {
                        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_RENAME_DATABASE", nil)];
                    }
                    else {
                        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_RENAME_FOLDER", nil)];
                    }
                }
                
                [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_EMAIL_DATABASE", nil)];
                
                [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"DONE_DATABASE", nil)];
                [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"UPLOAD_DROPBOX_0", nil)];
                actionSheetMenu.delegate = self;
                actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
            }
            else {
                [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"DONE_DATABASE", nil)];
                actionSheetMenu.delegate = self;
                actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
            }
        }
        else {
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_MANAGE_DATABASE", nil)];
        }
        actionSheetMenu.delegate = self;
        actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
        [actionSheetMenu showFromBarButtonItem:button animated:YES];
        return;
    }
    */
    
    
    if (IS_PAD) {
        TBDatabaseMenuTableViewController *tbMenuTableViewController;
        if ([self.tableView isEditing]) {
            if (fileSelezionatiDaEliminareSpostare.count>0) {
                tbMenuTableViewController = [[TBDatabaseMenuTableViewController alloc] initWithStyleAndEditModeAndNumfile:UITableViewStylePlain :[self.tableView isEditing] :fileSelezionatiDaEliminareSpostare];
            }
            else {
                tbMenuTableViewController = [[TBDatabaseMenuTableViewController alloc] initWithStyleAndEditMode:UITableViewStylePlain :[self.tableView isEditing]];
            }
        }
        else {
            tbMenuTableViewController = [[TBDatabaseMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];
        }
        
        [tbMenuTableViewController setListFile:listFile];
        tbMenuTableViewController.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tbMenuTableViewController];
        actionButtonPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
        [actionButtonPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        return;
    }
    
    
    
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
    
    actionSheetMenu = [[UIActionSheet alloc] init];
    
    if ([self.tableView isEditing]) {
        if (fileSelezionatiDaEliminareSpostare.count>0) {
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"DELETE_DB", nil)];
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MOVE_DB", nil)];
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"COPY_DB", nil)];
            
            if (fileSelezionatiDaEliminareSpostare.count == 1) {
                
                NSIndexPath *indexPath = [fileSelezionatiDaEliminareSpostare objectAtIndex:0];
                NSString *dbName = [listFile objectAtIndex:indexPath.row];
                
                if ([dbName hasSuffix:@".pgn"]) {
                    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_RENAME_DATABASE", nil)];
                }
                else {
                    [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_RENAME_FOLDER", nil)];
                }
            }
            
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_EMAIL_DATABASE", nil)];
            
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"DONE_DATABASE", nil)];
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"UPLOAD_DROPBOX_0", nil)];
            //[actionSheetMenu addButtonWithTitle:NSLocalizedString(@"UPLOAD iCLOUD", nil)];
            actionSheetMenu.delegate = self;
            actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
        }
        else {
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"DONE_DATABASE", nil)];
            actionSheetMenu.delegate = self;
            actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
        }
    }
    else if (fileSelezionatiDaEliminareSpostare.count == 0 && listFile.count == 0) {
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_NEW_DATABASE", nil)];
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_ADD_DATABASE", nil)];
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil)];
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_DOWNOLAD_PGN_MENTOR", nil)];
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"DOWNLOAD_DROPBOX_0", nil)];
        actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
    }
    else {
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_NEW_DATABASE", nil)];
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_ADD_DATABASE", nil)];
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil)];
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_MANAGE_DATABASE", nil)];
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_PASTE_GAME", nil)];
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_DOWNOLAD_PGN_MENTOR", nil)];
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"DOWNLOAD_DROPBOX_0", nil)];
        actionSheetMenu.delegate = self;
        
        actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
        
    }
    [actionSheetMenu showFromBarButtonItem:button animated:YES];
}


//Implementazione metodi UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex<0) {
        return;
    }
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([self.tableView isEditing]) {
        if ([title isEqualToString:NSLocalizedString(@"DONE_DATABASE", nil)]) {
            fileSelezionatiDaEliminareSpostare = nil;
            [self.tableView setEditing:NO animated:YES];
        }
        else if ([title isEqualToString:NSLocalizedString(@"DELETE_DB", nil)]) {
            
            NSString *msg;
            if (fileSelezionatiDaEliminareSpostare.count == 1) {
                msg = NSLocalizedString(@"CONFIRM_DELETE_SINGLE_DATABASE", nil);
            }
            else if (fileSelezionatiDaEliminareSpostare.count > 1) {
                msg = NSLocalizedString(@"CONFIRM_DELETE_MORE_DATABASE", nil);
            }
            
            
            UIAlertView *deleteDbAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONFIRM_TITLE_DELETE_DATABASE", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
            deleteDbAlertView.tag = 700;
            [deleteDbAlertView show];
            return;
            /*
            NSMutableArray *arrayOfFileToDelete = [[NSMutableArray alloc] init];
            for (NSIndexPath *indexPath in fileSelezionatiDaEliminareSpostare) {
                NSString *item = [listFile objectAtIndex:indexPath.row];
                NSLog(@"ITEM = %@", item);
                NSString *documentPath = [_actualPath stringByAppendingPathComponent:item];
                NSLog(@"%@", documentPath);
                [pgnDbManager deleteDatabaseAtPath:documentPath];
                [arrayOfFileToDelete addObject:item];
                //[listFile removeObject:item];
            }
            for (NSString *item in arrayOfFileToDelete) {
                [listFile removeObject:item];
            }
            [self.tableView deleteRowsAtIndexPaths:fileSelezionatiDaEliminareSpostare withRowAnimation:UITableViewRowAnimationFade];
            fileSelezionatiDaEliminareSpostare = nil;
            [self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
            return;
            */
        }
        else if ([title isEqualToString:NSLocalizedString(@"MENU_RENAME_DATABASE", nil)]) {
            UIAlertView *renameAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"MENU_RENAME_DATABASE", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
            NSIndexPath *indexPath = [fileSelezionatiDaEliminareSpostare objectAtIndex:0];
            NSString *dbName = [listFile objectAtIndex:indexPath.row];
            if ([dbName hasSuffix:@".pgn"]) {
                dbName = [dbName stringByDeletingPathExtension];
                //NSLog(@"DB NAME SENZA ESTENSIONE = %@", dbName);
            }
            renameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *alertTextField = [renameAlertView textFieldAtIndex:0];
            alertTextField.text = dbName;
            renameAlertView.tag = 900;
            renameAlertView.delegate = self;
            [renameAlertView show];
        }
        else if ([title isEqualToString:NSLocalizedString(@"MENU_RENAME_FOLDER", nil)]) {
            UIAlertView *renameAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"MENU_RENAME_FOLDER", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
            NSIndexPath *indexPath = [fileSelezionatiDaEliminareSpostare objectAtIndex:0];
            NSString *folderName = [listFile objectAtIndex:indexPath.row];
            renameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *alertTextField = [renameAlertView textFieldAtIndex:0];
            alertTextField.text = folderName;
            renameAlertView.tag = 800;
            renameAlertView.delegate = self;
            [renameAlertView show];
        }
        else if ([title isEqualToString:NSLocalizedString(@"MOVE_DB", nil)]) {
    
            MovePgnDatabaseTableViewController *mpdtvc = [[MovePgnDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
            [mpdtvc setActualPath:nil];
            [mpdtvc setDelegate:self];
            
            
            //CopyDatabaseTableViewController *cdtvc = [[CopyDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
            //[cdtvc setActualPath:rootPath];
            //cdtvc.delegate = self;
            
            NSMutableArray *databases = [[NSMutableArray alloc] init];
            for (NSIndexPath *ip in fileSelezionatiDaEliminareSpostare) {
                NSString *item = [_actualPath stringByAppendingPathComponent:[listFile objectAtIndex:ip.row]];
                [databases addObject:item];
            }
            
            [mpdtvc setDatabasesDaSpostare:databases];
            UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:mpdtvc];
            if (IS_PAD) {
                boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            else {
                boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:boardNavigationController animated:YES completion:nil];
            });
        }
        else if ([title isEqualToString:NSLocalizedString(@"MENU_EMAIL_DATABASE", nil)]) {
            [self manageFileForEmail];
        }
        else if ([title isEqualToString:NSLocalizedString(@"UPLOAD_DROPBOX_0", nil)]) {
            
            if ([[DBSession sharedSession] isLinked]) {
                [self connectToDropbox];
            }
            else {
                //NSLog(@"Devi Attivare Dropbox");
                [[DBSession sharedSession] linkFromController:self];
            }
        }
        else if ([title isEqualToString:NSLocalizedString(@"UPLOAD iCLOUD", nil)]) {
            [self uploadToCloud];
        }
        else if ([title isEqualToString:NSLocalizedString(@"COPY_DB", nil)]) {
            [self copyPgnDatabases];
            return;
            
            
            CopyPgnDatabaseTableViewController *cpdtvc = [[CopyPgnDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
            
            [cpdtvc setActualPath:nil];
            cpdtvc.delegate = self;
            
            NSMutableArray *databases = [[NSMutableArray alloc] init];
            for (NSIndexPath *ip in fileSelezionatiDaEliminareSpostare) {
                NSString *item = [_actualPath stringByAppendingPathComponent:[listFile objectAtIndex:ip.row]];
                [databases addObject:item];
            }
            
            [cpdtvc setDatabasesDaCopiare:databases];
            
            UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:cpdtvc];
            if (IS_PAD) {
                boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            else {
                boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:boardNavigationController animated:YES completion:nil];
            });
        }
    }
    else {
        if ([title isEqualToString:NSLocalizedString(@"MENU_NEW_FOLDER", nil)]) {
            [self newDirectory];
            return;
        }
        if ([title isEqualToString: NSLocalizedString(@"MENU_NEW_DATABASE", nil)]) {
            [self newDatabase];
            return;
        }
        if ([title isEqualToString:NSLocalizedString(@"MENU_ADD_DATABASE", nil)]) {
            [self addDatabase];
            return;
        }
        if ([title isEqualToString:NSLocalizedString(@"MENU_MANAGE_DATABASE", nil)]) {
            [self edit];
            return;
        }
        if ([title isEqualToString:NSLocalizedString(@"MENU_PASTE_GAME", nil)]) {
            [self managePasteGame];
            return;
        }
        if ([title isEqualToString:NSLocalizedString(@"MENU_DOWNOLAD_PGN_MENTOR", nil)]) {
            [self choiceMenu:NSLocalizedString(@"MENU_DOWNOLAD_PGN_MENTOR", nil)];
            return;
        }
        if ([title isEqualToString:NSLocalizedString(@"DOWNLOAD_DROPBOX_0", nil)]) {
            
            if ([[DBSession sharedSession] isLinked]) {
                [self connectToDropbox];
            }
            else {
                //NSLog(@"Devi Attivare Dropbox");
                [[DBSession sharedSession] linkFromController:self];
                //UIAlertView *dropboxAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Connessione Dropbox" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                //[dropboxAlertView show];
            }
        }
    }
}

- (void) manageFileForEmail {
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:NSLocalizedString(@"EMAIL_SUBJECT", nil)];
        
        //NSArray *toRecipients = [NSArray arrayWithObjects:NSLocalizedString(@"EMAIL", nil), nil];
        [mailer setToRecipients:[[SettingManager sharedSettingManager] getRecipients]];
        
        NSUInteger numDatabase = 0;
        NSString *item;
        for (NSIndexPath *ip in fileSelezionatiDaEliminareSpostare) {
            NSString *nome = [listFile objectAtIndex:ip.row];
            item = [_actualPath stringByAppendingPathComponent:[listFile objectAtIndex:ip.row]];
            if ([item hasSuffix:@".pgn"]) {
                NSData *fileData = [NSData dataWithContentsOfFile:item];
                [mailer addAttachmentData:fileData mimeType:@"text/plain" fileName:nome];
                numDatabase++;
            }
        }
        
        
        
        //UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
        //NSData *imageData = UIImagePNGRepresentation(myImage);
        //[mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"mobiletutsImage"];
        
        //UIGraphicsBeginImageContextWithOptions(boardView.bounds.size, self.view.opaque, 0.0);
        //UIGraphicsBeginImageContext([UIScreen mainScreen].bounds.size);
        //[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        //[[self.view superview].superview.superview.layer renderInContext:UIGraphicsGetCurrentContext()];
        //UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        //UIGraphicsEndImageContext();
        //NSData *imageData = UIImagePNGRepresentation(image);
        
        
        //[imageData writeToFile:@"image1.jpeg" atomically:YES];
        
        if (numDatabase == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_DATABASE_SELECTED", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        
        
        NSString *emailBody = @"";
        [mailer setMessageBody:emailBody isHTML:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self presentModalViewController:mailer animated:YES];
            [self presentViewController:mailer animated:YES completion:nil];
        });
        //[self presentModalViewController:mailer animated:YES];
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
            //fileSelezionatiDaEliminareSpostare = nil;
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            fileSelezionatiDaEliminareSpostare = nil;
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            fileSelezionatiDaEliminareSpostare = nil;
            break;
    }
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Implementazione metodi MainPopoverViewControllerDelegate

//- (void) dismiss:(id)sender {
//    NSLog(@"Eseguo dismiss");
//    [popoverController dismissPopoverAnimated:YES];
//}

- (void) newDirectory {
    UIAlertView *newDirectoryAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_FOLDER", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
    newDirectoryAlertView.tag = 0;
    newDirectoryAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newDirectoryAlertView show];
}

- (void) newDatabase {
//    UIAlertView *newDatabaseAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_NEW_DATABASE", nil) message:NSLocalizedString(@"PGN_FORMAT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
//    newDatabaseAlertView.tag = 1;
//    newDatabaseAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [newDatabaseAlertView show];
//    
//    return;
    
    UIAlertController *newDatabaseAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MENU_NEW_DATABASE", nil) message:NSLocalizedString(@"PGN_FORMAT", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    [newDatabaseAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"NEW_DATABASE_PLACEHOLDER", nil);
    }];
    
    [newDatabaseAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = newDatabaseAlertController.textFields.firstObject;
        NSString *dbName =  [[textField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([dbName isEqualToString:@""]) {
            dbName = NSLocalizedString(@"NEW_DATABASE_PLACEHOLDER", nil);
        }
        if (![dbName hasSuffix:@".pgn"]) {
            dbName = [dbName stringByAppendingString:@".pgn"];
        }
        NSString *newPath = [_actualPath stringByAppendingPathComponent:dbName];
        BOOL databaseCreato = [pgnDbManager createDatabaseAtPath:newPath];
        if (databaseCreato) {
            listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
            //[self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
            [self.tableView reloadData];
        }
        else {
            UIAlertView *dbEsistenteAlertView =  [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"EXISTING_DATABASE", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [dbEsistenteAlertView show];
        }
    }]];
    
    [newDatabaseAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:newDatabaseAlertController animated:YES completion:nil];
    
    
}

- (void) addDatabase {
    UIStoryboard *sb;
    if (IS_PAD) {
        sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    }
    else {
        sb = [UIStoryboard storyboardWithName:@"iPhone" bundle:[NSBundle mainBundle]];
    }
    
    if (IS_PHONE) {
        if (IOS_6) {
            self.navigationItem.title = @"Back";
        }
        else {
            self.navigationItem.title = @"";
        }
    }
    
    PgnDownloadViewController *pdvc = [sb instantiateViewControllerWithIdentifier:@"PgnDownloadViewController"];
    [self.navigationController pushViewController:pdvc animated:YES];
    //pdvc.modalPresentationStyle = UIModalPresentationFormSheet;
    //[self.navigationController presentModalViewController:pdvc animated:YES];
}

- (void) edit {
    if (![self.tableView isEditing]) {
        self.tableView.allowsMultipleSelectionDuringEditing = YES;
        //[self.tableView setValue:UIColorFromRGB(0x4CE466) forKey:@"multiselectCheckmarkColor"];
        [self.tableView setValue:[UIColor redColor] forKey:@"multiselectCheckmarkColor"];
        [self.tableView setEditing:YES animated:YES];
        //actionButton = self.navigationItem.rightBarButtonItem;
        //UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
        //self.navigationItem.rightBarButtonItem = doneButton;
    }
    else {
        [self.tableView setEditing:NO animated:YES];
    }
}

- (void) managePasteGame {
    
    if (IsChessStudioLight) {
        UIAlertView *lightAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"LIGHT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"OK", nil];
        lightAlertView.tag = 1000;
        [lightAlertView show];
        return;
    }
    
    UIStoryboard *sb;
    if (IS_PAD) {
        sb = [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    }
    else {
        sb = [UIStoryboard storyboardWithName:@"iPhone" bundle:[NSBundle mainBundle]];
    }
    

    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    if (pasteBoard.string.length == 0) {
        UIAlertView *noGamesToPast = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"EMPTY_CLIPBOARD", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [noGamesToPast show];
        return;
    }
    
    //UINavigationController *pastedGameNavigationController = [sb instantiateViewControllerWithIdentifier:@"PgnPastedGameNavigationController"];
    //PgnPastedGameViewController *ppgvc = (PgnPastedGameViewController *)[pastedGameNavigationController visibleViewController];
    //[ppgvc setCallingViewController:[self.class description]];
    
    UINavigationController *pastedGameNavigationController = [sb instantiateViewControllerWithIdentifier:@"PgnPastedGameTableNavigationController"];
    PgnPastedGameTableViewController *ppgtvc = (PgnPastedGameTableViewController *)[pastedGameNavigationController visibleViewController];
    [ppgtvc setCallingViewController:[self.class description]];
    [self presentViewController:pastedGameNavigationController animated:YES completion:nil];
}

- (void) doneButtonPressed {
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = actionButton;
    //[self.navigationItem.rightBarButtonItem setAction:action];
    //[self.navigationItem.rightBarButtonItem setTarget:target];
}

- (void) closePopover {
    //NSLog(@"Chiudo popover");
    //[popoverController dismissPopoverAnimated:YES];
    //popoverController = nil;
    //mpvc = nil;
    //if (!self.tableView.isEditing) {
    //    [self.navigationItem.rightBarButtonItem setAction:action];
    //}
}

- (void) popoverViewWillDisappear {
    //NSLog(@"Devo fare qualcosa prima che il popover scompaia");
    //if (self.tableView.isEditing) {
    //    return;
    //}
    //[self.navigationItem.rightBarButtonItem setAction:action];
    //[self.navigationItem.rightBarButtonItem setTarget:target];
}

//Implementazione metodi AlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 700) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil)]) {
            return;
        }
        NSMutableArray *arrayOfFileToDelete = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in fileSelezionatiDaEliminareSpostare) {
            NSString *item = [listFile objectAtIndex:indexPath.row];
            //NSLog(@"ITEM = %@", item);
            NSString *documentPath = [_actualPath stringByAppendingPathComponent:item];
            //NSLog(@"%@", documentPath);
            
            
            [pgnDbManager deleteDatabaseAtPath:documentPath];
            [arrayOfFileToDelete addObject:item];
            
            //[listFile removeObject:item];
        }
        for (NSString *item in arrayOfFileToDelete) {
            [listFile removeObject:item];
        }
        [self.tableView deleteRowsAtIndexPaths:fileSelezionatiDaEliminareSpostare withRowAnimation:UITableViewRowAnimationFade];
        fileSelezionatiDaEliminareSpostare = nil;
        //[self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
        [self.tableView reloadData];
        return;
    }
    
    
    if (alertView.tag == 800) { //Gestione rinomina una cartella
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        NSString *folderName = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([title isEqualToString:@"OK"]) {
            if (folderName.length > 0) {
                //NSLog(@"PATH: %@    NOME: %@",_actualPath, folderName);
                NSIndexPath *ip = [fileSelezionatiDaEliminareSpostare objectAtIndex:0];
                NSString *oldFolderName = [listFile objectAtIndex:ip.row];
                //NSLog(@"Cartella da rinominare = %@", oldFolderName);
                if ([pgnDbManager renameDatabase:_actualPath :oldFolderName :folderName]) {
                    [listFile replaceObjectAtIndex:ip.row withObject:folderName];
                    fileSelezionatiDaEliminareSpostare = nil;
                    [self.tableView reloadData];
                }
                else {
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"EXISTING_FOLDER", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [errorAlertView show];
                }
            }
            else {
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"CORRECT_FOLDER", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [errorAlertView show];
            }
        }
        return;
    }
    
    
    if (alertView.tag == 900) { //Gestione rinomina un database
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        NSString *dbName = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([title isEqualToString:@"OK"]) {
            if (dbName.length>0) {
                dbName = [dbName stringByAppendingString:@".pgn"];
                //NSLog(@"PATH: %@    NOME: %@",_actualPath, dbName);
                NSIndexPath *ip = [fileSelezionatiDaEliminareSpostare objectAtIndex:0];
                NSString *oldDbName = [listFile objectAtIndex:ip.row];
                //NSLog(@"File da rinominare = %@", oldDbName);
                if ([pgnDbManager renameDatabase:_actualPath :oldDbName :dbName]) {
                    [listFile replaceObjectAtIndex:ip.row withObject:dbName];
                    [self.tableView reloadData];
                    fileSelezionatiDaEliminareSpostare = nil;
                }
                else {
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"EXISTING_DATABASE", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [errorAlertView show];
                }
            }
            else {
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"CORRECT_DATABASE", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [errorAlertView show];
            }
        }
        return;
    }
    
    //Gestione ChessStudioLight in caso superamento numero mosse consentito
    if (alertView.tag == 1000) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"CHESS_STUDIO_APP_STORE", nil)]];
        }
        return;
    }
    
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSString *nome = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([title isEqualToString:@"OK"] && nome.length>0) {
        if (alertView.tag == 0) {
            NSString *newPath = [_actualPath stringByAppendingPathComponent:nome];
            BOOL directoryCreata = [pgnDbManager createDirectory:newPath];
            if (directoryCreata) {
                listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
                [self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
            }
            else {
                UIAlertView *folderEsistenteAlertView =  [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"EXISTING_FOLDER", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [folderEsistenteAlertView show];
            }
        }
        else {
            if (![nome hasSuffix:@".pgn"]) {
                nome = [nome stringByAppendingString:@".pgn"];
            }
            NSString *newPath = [_actualPath stringByAppendingPathComponent:nome];
            BOOL databaseCreato = [pgnDbManager createDatabaseAtPath:newPath];
            if (databaseCreato) {
                listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
                [self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
            }
            else {
                UIAlertView *dbEsistenteAlertView =  [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"EXISTING_DATABASE", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [dbEsistenteAlertView show];
            }
        }
    }
}

#pragma mark - Sposta database delegate

- (void) aggiorna {
    //NSLog(@"Il metodo aggiorna viene chiamato");
    listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
    [self.tableView reloadData];
    fileSelezionatiDaEliminareSpostare = nil;
}

#pragma mark - Copy PGN database delegate

- (void) aggiornaDopoAverCopiato {
    NSLog(@"ACTUAL PATH = %@", _actualPath);
    listFile = [pgnDbManager listPgnFileAndDirectoryAtPath:_actualPath];
    [self.tableView reloadData];
    fileSelezionatiDaEliminareSpostare = nil;
}

#pragma mark - Metodi TBDatabaseMenu Delegate

- (void) choiceMenu:(NSString *)selectedMenu {
    if (actionButtonPopoverController) {
        [actionButtonPopoverController dismissPopoverAnimated:YES];
        actionButtonPopoverController = nil;
    }
    if ([selectedMenu isEqualToString:NSLocalizedString(@"MENU_NEW_DATABASE", nil)]) {
        [self newDatabase];
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"MENU_NEW_FOLDER", nil)]) {
        [self newDirectory];
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"MENU_ADD_DATABASE", nil)]) {
        [self addDatabase];
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"MENU_PASTE_GAME", nil)]) {
        [self managePasteGame];
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"MENU_MANAGE_DATABASE", nil)]) {
        [self edit];
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"DONE_DATABASE", nil)]) {
        fileSelezionatiDaEliminareSpostare = nil;
        [self.tableView setEditing:NO animated:YES];
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"MENU_EMAIL_DATABASE", nil)]) {
        [self manageFileForEmail];
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"DELETE_DB", nil)]) {
        
        NSString *msg;
        if (fileSelezionatiDaEliminareSpostare.count == 1) {
            msg = NSLocalizedString(@"CONFIRM_DELETE_SINGLE_DATABASE", nil);
        }
        else if (fileSelezionatiDaEliminareSpostare.count > 1) {
            msg = NSLocalizedString(@"CONFIRM_DELETE_MORE_DATABASE", nil);
        }
        
        
        UIAlertView *deleteDbAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONFIRM_TITLE_DELETE_DATABASE", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
        deleteDbAlertView.tag = 700;
        [deleteDbAlertView show];
        return;
        
        
        
        /*
        for (NSIndexPath *indexPath in fileSelezionatiDaEliminareSpostare) {
            NSString *item = [listFile objectAtIndex:indexPath.row];
            NSString *documentPath = [_actualPath stringByAppendingPathComponent:item];
            [pgnDbManager deleteDatabaseAtPath:documentPath];
            [listFile removeObject:item];
        }
        [self.tableView deleteRowsAtIndexPaths:fileSelezionatiDaEliminareSpostare withRowAnimation:UITableViewRowAnimationFade];
        fileSelezionatiDaEliminareSpostare = nil;
        [self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
        */
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"MOVE_DB", nil)]) {
        
        [self movePgnDatabase];
        
//        MovePgnDatabaseTableViewController *mpdtvc = [[MovePgnDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
//        [mpdtvc setActualPath:nil];
//        [mpdtvc setDelegate:self];
//        
//        NSMutableArray *databases = [[NSMutableArray alloc] init];
//        for (NSIndexPath *ip in fileSelezionatiDaEliminareSpostare) {
//            NSString *item = [_actualPath stringByAppendingPathComponent:[listFile objectAtIndex:ip.row]];
//            [databases addObject:item];
//        }
//        
//        [mpdtvc setDatabasesDaSpostare:databases];
//        UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:mpdtvc];
//        if (IS_PAD) {
//            boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
//        }
//        else {
//            boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self presentViewController:boardNavigationController animated:YES completion:nil];
//        });
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"MENU_RENAME_FOLDER", nil)]) {
        [self renameFolder];
//        UIAlertView *renameAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"MENU_RENAME_FOLDER", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
//        NSIndexPath *indexPath = [fileSelezionatiDaEliminareSpostare objectAtIndex:0];
//        NSString *folderName = [listFile objectAtIndex:indexPath.row];
//        renameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//        UITextField *alertTextField = [renameAlertView textFieldAtIndex:0];
//        alertTextField.text = folderName;
//        renameAlertView.tag = 800;
//        renameAlertView.delegate = self;
//        [renameAlertView show];
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"MENU_RENAME_DATABASE", nil)]) {
        [self renamePgnDatabase];
        
//        UIAlertView *renameAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"MENU_RENAME_DATABASE", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
//        NSIndexPath *indexPath = [fileSelezionatiDaEliminareSpostare objectAtIndex:0];
//        NSString *dbName = [listFile objectAtIndex:indexPath.row];
//        if ([dbName hasSuffix:@".pgn"]) {
//            dbName = [dbName stringByDeletingPathExtension];
//            //NSLog(@"DB NAME SENZA ESTENSIONE = %@", dbName);
//        }
//        renameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//        UITextField *alertTextField = [renameAlertView textFieldAtIndex:0];
//        alertTextField.text = dbName;
//        renameAlertView.tag = 900;
//        renameAlertView.delegate = self;
//        [renameAlertView show];
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"MENU_DOWNOLAD_PGN_MENTOR", nil)]) {
        UIStoryboard *sb = [UtilToView getStoryBoard];
        PgnMentorTableViewController *pmtvc = [sb instantiateViewControllerWithIdentifier:@"PgnMentorTableViewController"];
        [self.navigationController pushViewController:pmtvc animated:YES];
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"UPLOAD_DROPBOX_0", nil)]) {
        if ([[DBSession sharedSession] isLinked]) {
            [self connectToDropbox];
            /*
            NSMutableArray *databases = [[NSMutableArray alloc] init];
            for (NSIndexPath *ip in fileSelezionatiDaEliminareSpostare) {
                NSString *item = [_actualPath stringByAppendingPathComponent:[listFile objectAtIndex:ip.row]];
                [databases addObject:item];
            }
            
            
            DropboxTableViewController *dtvc = [[DropboxTableViewController alloc] initWithStyle:UITableViewStylePlain];
            [dtvc setDatabasesDaCopiare:databases];
            [dtvc setStartDirectory:@"/"];
            UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:dtvc];
            if (IS_PAD) {
                boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            else {
                boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
            }
            [self presentViewController:boardNavigationController animated:YES completion:nil];
            */
        }
        else {
            //NSLog(@"Devi Attivare Dropbox");
            [[DBSession sharedSession] linkFromController:self];
        }
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"DOWNLOAD_DROPBOX_0", nil)]) {
        
        if (IsChessStudioLight) {
            UIAlertView *lightAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"DROPBOX_LIGHT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"OK", nil];
            lightAlertView.tag = 1000;
            [lightAlertView show];
            return;
        }
        
        if ([[DBSession sharedSession] isLinked]) {
            [self connectToDropbox];
            /*
            NSMutableArray *databases = [[NSMutableArray alloc] init];
            for (NSIndexPath *ip in fileSelezionatiDaEliminareSpostare) {
                NSString *item = [_actualPath stringByAppendingPathComponent:[listFile objectAtIndex:ip.row]];
                [databases addObject:item];
            }
            
            
            DropboxTableViewController *dtvc = [[DropboxTableViewController alloc] initWithStyle:UITableViewStylePlain];
            [dtvc setDatabasesDaCopiare:databases];
            [dtvc setStartDirectory:@"/"];
            UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:dtvc];
            if (IS_PAD) {
                boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            else {
                boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
            }
            [self presentViewController:boardNavigationController animated:YES completion:nil];
            */
        }
        else {
            //NSLog(@"Devi Attivare Dropbox");
            [[DBSession sharedSession] linkFromController:self];
            //UIAlertView *dropboxAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Connessione Dropbox" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            //[dropboxAlertView show];
        }
    }
    else if ([selectedMenu isEqualToString:NSLocalizedString(@"COPY_DB", nil)]) {
        
        
        [self copyPgnDatabases];
        return;
        
        CopyPgnDatabaseTableViewController *cpdtvc = [[CopyPgnDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
        //[cdtvc setActualPath:_actualPath];
        
        //NSString *pathForCopyPgnDatabase = [rootPath stringByDeletingLastPathComponent];
        
        [cpdtvc setActualPath:nil];
        cpdtvc.delegate = self;
        
        NSMutableArray *databases = [[NSMutableArray alloc] init];
        for (NSIndexPath *ip in fileSelezionatiDaEliminareSpostare) {
            NSString *item = [_actualPath stringByAppendingPathComponent:[listFile objectAtIndex:ip.row]];
            [databases addObject:item];
        }
        
        [cpdtvc setDatabasesDaCopiare:databases];
        UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:cpdtvc];
        if (IS_PAD) {
            boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        else {
            boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self presentModalViewController:boardNavigationController animated:YES];
            [self presentViewController:boardNavigationController animated:YES completion:nil];
        });
        //[self presentModalViewController:boardNavigationController animated:YES];
        
        
        
        return;
        
        
        
        NSLog(@"Devo copiare il database nella clipboard");
        UIPasteboard *clipBoard = [UIPasteboard generalPasteboard];
        NSLog(@"Ci sono %lu file da copiare nella clipboard", (unsigned long)fileSelezionatiDaEliminareSpostare.count);
        NSMutableArray *fileArray = [[NSMutableArray alloc] init];
        //NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSIndexPath *ip in fileSelezionatiDaEliminareSpostare) {
            NSString *item = [listFile objectAtIndex:ip.row];
            NSLog(@"File da copiare = %@", item);
            NSString *pathFinale = [_actualPath stringByAppendingPathComponent:item];
            NSLog(@"%@", pathFinale);
            //[fileArray addObject:pathFinale];
            
            [fileArray addObject:pathFinale];
        }
        NSArray *pathArray = [NSArray arrayWithArray:fileArray];
        clipBoard.strings = pathArray;
        [self uploadToCloud];
    }
}

- (void) renamePgnDatabase {
    UIAlertView *renameAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"MENU_RENAME_DATABASE", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
    NSIndexPath *indexPath = [fileSelezionatiDaEliminareSpostare objectAtIndex:0];
    NSString *dbName = [listFile objectAtIndex:indexPath.row];
    if ([dbName hasSuffix:@".pgn"]) {
        dbName = [dbName stringByDeletingPathExtension];
        //NSLog(@"DB NAME SENZA ESTENSIONE = %@", dbName);
    }
    renameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertTextField = [renameAlertView textFieldAtIndex:0];
    alertTextField.text = dbName;
    renameAlertView.tag = 900;
    renameAlertView.delegate = self;
    [renameAlertView show];
}

- (void) renameFolder {
    UIAlertView *renameAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"MENU_RENAME_FOLDER", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"OK", nil];
    NSIndexPath *indexPath = [fileSelezionatiDaEliminareSpostare objectAtIndex:0];
    NSString *folderName = [listFile objectAtIndex:indexPath.row];
    renameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertTextField = [renameAlertView textFieldAtIndex:0];
    alertTextField.text = folderName;
    renameAlertView.tag = 800;
    renameAlertView.delegate = self;
    [renameAlertView show];
}

- (void) movePgnDatabase {
    MovePgnDatabaseTableViewController *mpdtvc = [[MovePgnDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [mpdtvc setActualPath:nil];
    [mpdtvc setDelegate:self];
    
    NSMutableArray *databases = [[NSMutableArray alloc] init];
    for (NSIndexPath *ip in fileSelezionatiDaEliminareSpostare) {
        NSString *item = [_actualPath stringByAppendingPathComponent:[listFile objectAtIndex:ip.row]];
        [databases addObject:item];
    }
    
    [mpdtvc setDatabasesDaSpostare:databases];
    UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:mpdtvc];
    if (IS_PAD) {
        boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    else {
        boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:boardNavigationController animated:YES completion:nil];
    });
}

- (void) copyPgnDatabases {
    CopyPgnDatabaseTableViewController *cpdtvc = [[CopyPgnDatabaseTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [cpdtvc setActualPath:nil];
    cpdtvc.delegate = self;
    
    NSMutableArray *databases = [[NSMutableArray alloc] init];
    for (NSIndexPath *ip in fileSelezionatiDaEliminareSpostare) {
        NSString *item = [_actualPath stringByAppendingPathComponent:[listFile objectAtIndex:ip.row]];
        [databases addObject:item];
    }
    
    [cpdtvc setDatabasesDaCopiare:databases];
    UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:cpdtvc];
    if (IS_PAD) {
        boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    else {
        boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:boardNavigationController animated:YES completion:nil];
    });
}

- (void) uploadToCloud {
    NSIndexPath *indexPath = [fileSelezionatiDaEliminareSpostare objectAtIndex:0];
    NSString *dbName = [listFile objectAtIndex:indexPath.row];
    NSLog(@"File da inviare a iCloud: %@", dbName);
    NSString *fileConPath = [_actualPath stringByAppendingPathComponent:dbName];
    NSLog(@"File completo di path da inviare a iCloud: %@", fileConPath);
    NSURL *urlFinalePath = [[NSURL alloc] initFileURLWithPath:fileConPath];
    NSLog(@"URL FINALE:%@", urlFinalePath);
    PgnFileDocument *pgnFileDocument = [[PgnFileDocument alloc] initWithFileURL:urlFinalePath];
    [pgnFileDocument openWithCompletionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"Documento aperto");
            
            PgnFileInfo *pgnFileInfo = [pgnFileDocument pgnFileInfo];
            
            [pgnFileInfo setIsInCloud:YES];
            
            BOOL salvato = [NSKeyedArchiver archiveRootObject:pgnFileInfo toFile:pgnFileInfo.savePath];
            
            
            if (salvato) {
                NSString *fileString = pgnFileInfo.savePath;
                NSLog(@"Path PgnFileInfo = %@", pgnFileInfo.savePath);
                NSLog(@"FileString = %@", fileString);
                
                NSURL *urlForSaveCloud = [self urlForSaveCloud:dbName];
                NSLog(@"URL FOR SAVE CLOUD = %@", urlForSaveCloud);
                
                NSString *lastPath = [pgnFileInfo.savePath lastPathComponent];
                urlForSaveCloud = [self urlForSaveCloud:lastPath];
                
                //NSLog(@"NEW FILE CLOUD PATH: %@", [pgnFileInfo cloudPath]);
                
                NSLog(@"NUOVO PATH CLOUD = %@", [urlForSaveCloud path]);
                
                
                //NSString *newFileString = [NSString stringWithFormat:@"file://%@", fileString];
                NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:fileString];
                NSURL *destURL = urlForSaveCloud;
                
                
                NSLog(@"fileURL: %@", fileURL);
                NSLog(@"destURL: %@", destURL);
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:destURL.path]) {
                    NSLog(@"Il file %@ esiste nella dir destinazione", destURL.path);
                }
                else {
                    NSLog(@"A questo punto devo inviare il file su cloud");
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                        NSError * error;
                        BOOL moved = [[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:fileURL destinationURL:destURL error:&error];
                        if (moved) {
                            NSLog(@"Moved %@ to %@", fileURL, destURL);
                            //[self loadDocAtURL:destURL];
                        } else {
                            NSLog(@"Failed to move %@ to %@: %@", fileURL, destURL, error.localizedDescription);
                        }
                    });
                }
            }
            else {
                NSLog(@"FILE NON SALVATO");
            }

            
            
            /*
            [pgnFileDocument saveToURL:urlForSaveCloud forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"Documento salvato");
                }
                else {
                    NSLog(@"Documento non salvato");
                }
            }];*/
        }
        else {
            NSLog(@"Documento non aperto");
        }
    }];
}

- (NSURL *)urlForSaveCloud:(NSString *)filename {
    // be sure to insert "Documents" into the path
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL *pathURL = [baseURL URLByAppendingPathComponent:@"Documents"];
    NSURL *destinationURL = [pathURL URLByAppendingPathComponent:filename];
    return destinationURL;
}

- (void) connectToDropbox {
    NSMutableArray *databases = [[NSMutableArray alloc] init];
    for (NSIndexPath *ip in fileSelezionatiDaEliminareSpostare) {
        NSString *item = [_actualPath stringByAppendingPathComponent:[listFile objectAtIndex:ip.row]];
        [databases addObject:item];
    }
        
    DropboxTableViewController *dtvc = [[DropboxTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [dtvc setDatabasesDaCopiare:databases];
    [dtvc setStartDirectory:@"/"];
    UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:dtvc];
    if (IS_PAD) {
        boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    else {
        boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    [self presentViewController:boardNavigationController animated:YES completion:nil];
}


/*
#pragma mark - Gestione iCloud (prova per poter inserire file in iCloud in questa interfaccia)

#define PGN_EXTENSION @"dat"

- (void) initCloud {
    _iCloudURLs = [[NSMutableArray alloc] init];
    _iCloudDatabase = [[NSMutableArray alloc] init];
    [self refresh];
}

- (void) refresh {
    [self startQuery];
}

- (NSMetadataQuery *) documentQuery {
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    if (query) {
        // Search documents subdir only
        [query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
        // Add a predicate for finding the documents
        NSString *filePattern = [NSString stringWithFormat:@"*.%@", PGN_EXTENSION];
        [query setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@", NSMetadataItemFSNameKey, filePattern]];
    }
    return query;
}

- (void) startQuery {
    
    [self stopQuery];
    
    NSLog(@"Starting to watch iCloud dir...");
    
    _query = [self documentQuery];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processICloudFiles:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processICloudFiles:) name:NSMetadataQueryDidUpdateNotification object:nil];
    
    [_query startQuery];
}

- (void)stopQuery {
    
    if (_query) {
        
        NSLog(@"No longer watching iCloud dir...");
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:nil];
        [_query stopQuery];
        _query = nil;
    }
}

- (void) processICloudFiles:(NSNotification *)notification {
    [_query disableUpdates];
    
    [_iCloudURLs removeAllObjects];
    [_iCloudDatabase removeAllObjects];
    NSArray *queryResults = [_query results];
    
    for (NSMetadataItem *result in queryResults) {
        NSURL *fileURL = [result valueForAttribute:NSMetadataItemURLKey];
        [_iCloudURLs addObject:fileURL];
        NSString *pgnFile = [[fileURL lastPathComponent] stringByReplacingOccurrencesOfString:@".dat" withString:@".pgn"];
        [_iCloudDatabase addObject:pgnFile];
    }
    NSLog(@"Found %lu iCloud files.", (unsigned long)_iCloudURLs.count);
    
    for (NSURL *fileUrl in _iCloudURLs) {
        NSLog(@"%@", fileUrl);
    }
    
    
    //for (NSString *pgnFile in _iCloudDatabase) {
        //if (![listFile containsObject:pgnFile]) {
            //[listFile addObject:pgnFile];
        //}
    //}
    
    [_iCloudDatabase sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.tableView reloadData];
    
    [_query enableUpdates];
}*/

@end
