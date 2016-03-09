//
//  AppDelegate.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "AppDelegate.h"
#import "PgnDbManager.h"
#import "TBDatabaseTableViewController.h"
#import "Appirater.h"
//#import "Options.h"
#import "SettingManager.h"
#import <DropboxSDK/DropboxSDK.h>

#include "Engines/Stockfish/Chess/position.h"
#include "Engines/Stockfish/Chess/movepick.h"
#include "Engines/Stockfish/Chess/direction.h"
#include "Engines/Stockfish/Chess/mersenne.h"
#include "Engines/Stockfish/Chess/bitboard.h"

#import "SWRevealViewController.h"
#import "CustomAnimationController.h"
#import "RightSideViewController.h"

@interface AppDelegate()<SWRevealViewControllerDelegate> {

    UIViewController *rootViewController;

}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    //else {
        //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    //}
    
    rootViewController = self.window.rootViewController;
    
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        [self setupTabBarController];
    }
    else if ([rootViewController isKindOfClass:[SWRevealViewController class]]) {
        [self setupSWRevealController];
    }
    
    // Override point for customization after application launch.
    
    [self copiaTestFileInDocuments];
    [self copiaSampleFileInDocuments];
    //[self setupAppiRater];
    [self showPresentation];
    
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if ([url isFileURL]) {
        PgnDbManager *pgnDbManager = [PgnDbManager sharedPgnDbManager];
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [searchPaths objectAtIndex:0];
        NSString *file = [url lastPathComponent];
        documentPath = [documentPath stringByAppendingPathComponent:file];
        [pgnDbManager moveDatabase:url.path :documentPath];
        NSString *inboxToDelete = [url.path stringByDeletingLastPathComponent];
        [pgnDbManager deleteDirectoryAtPath:inboxToDelete];
    }
    
    sleep(2.0);
    
    [application setStatusBarHidden:NO];
    
    [self performSelectorInBackground:@selector(backgroundInit:) withObject:nil];
    
    
    if (IsChessStudioLight && IS_IOS_7) {
        [UIViewController prepareInterstitialAds];
    }
    
    
    //Impostazioni Dropbox
    NSString *appKey = @"";
    NSString *appSecret = @"";
    NSString *root = kDBRootDropbox;
    DBSession* session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    [DBSession setSharedSession:session];
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        //[self setupCloud];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //NSLog(@"ENTRO IN BACKGROUND");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //NSLog(@"RIENTRO IN FOREGROUND");
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *inboxPath = [documentPath stringByAppendingPathComponent:@"Inbox"];
    PgnDbManager *pgnDbManager = [PgnDbManager sharedPgnDbManager];
    NSArray *pgnFiles = [pgnDbManager listPgnFileAndDirectoryAtPath:inboxPath];
    for (NSString *pgnFile in pgnFiles) {
        NSString *pathPgnFile = [inboxPath stringByAppendingPathComponent:pgnFile];
        NSString *docPath = [searchPaths objectAtIndex:0];
        NSString *destination = [docPath stringByAppendingPathComponent:pgnFile];
        [pgnDbManager moveDatabase:pathPgnFile :destination];
    }
    /*
    if ([pgnDbManager deleteDirectoryAtPath:inboxPath]) {
        NSLog(@"Directory %@ rimossa", inboxPath);
    }
    else {
        NSLog(@"Directory %@ non rimossa", inboxPath);
    }
    */
    
    //UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    //NSMutableArray *tabBarArray = [NSMutableArray arrayWithArray:[tabBarController viewControllers]];
    //UINavigationController *nc = [tabBarArray objectAtIndex:0];
    //UIViewController *vc = [nc.viewControllers objectAtIndex:0];
    //if ([vc isKindOfClass:[TBDatabaseTableViewController class]]) {
    //    TBDatabaseTableViewController *tbdtvc = (TBDatabaseTableViewController *)vc;
    //    [tbdtvc reloadData];
    //}
    
    if (pgnFiles.count > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EnteredForeground" object:nil];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) setupCloud {
    //id currentCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *localCloudPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Documents"];
    localCloudPath = [localCloudPath stringByAppendingPathComponent:@"iCloudMetadata"];
    if (![fileManager fileExistsAtPath:localCloudPath]) {
        NSLog(@"CLOUD PATH NON ESISTE");
        NSError *error;
        if (![fileManager createDirectoryAtPath:localCloudPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"ERROR CREATING CLOUD DIRECTORY: %@", error.debugDescription);
        }
        else {
            NSLog(@"CLOUD DIRECTORY CREATA CON SUCCESSO: %@", localCloudPath);
        }
    }
    else {
        NSLog(@"CLOUD PATH ESISTE: %@", localCloudPath);
    }
    
    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector (storeDidChange:) name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification object: [NSUbiquitousKeyValueStore defaultStore]];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudKeysChanged:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
    //[[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

//- (void)storeDidChange:(NSNotification *)notification {
    //[self updateUserDefaultsFromICloud];
//    NSLog(@"Cambio Key Value");
//    NSDictionary *values = [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];
//    if ([values valueForKey:@"selectedColorIndex"] != nil) {
//        NSUInteger selectedColorIndex = (NSUInteger)[[NSUbiquitousKeyValueStore defaultStore] longLongForKey:@"selectedColorIndex"];
//        NSLog(@"Selected Color Index = %lu", (unsigned long)selectedColorIndex);
//    }
//}


- (void) setupTabBarController {
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    NSMutableArray *tabBarArray = [NSMutableArray arrayWithArray:[tabBarController viewControllers]];
    [tabBarArray removeObjectAtIndex:2];
    [tabBarController setViewControllers:tabBarArray];
    
    //if (IS_IOS_7) {
        
        //UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"ECO" image:[UIImage imageNamed:@"info.png"] tag:3];
        //UIViewController *newViewController = [[UIViewController alloc] init];
        //[tabBarArray insertObject:newViewController atIndex:2];
        //[tabBarArray removeObjectAtIndex:2];
        //[tabBarController setViewControllers:tabBarArray];
        
        for (int i=0; i<tabBarArray.count; i++) {
            UITabBarController *tbc = [tabBarArray objectAtIndex:i];
            UITabBarItem *tbi = [tbc tabBarItem];
            NSString *title = tbi.title;
            if ([title isEqualToString:@"Databases"]) {
                [tbi setImage:[UIImage imageNamed:@"TabBarDatabase"]];
                [tbi setSelectedImage:[UIImage imageNamed:@"TabBarDatabase"]];
            }
            else if ([title isEqualToString:@"TWIC"]) {
                [tbi setImage:[UIImage imageNamed:@"TabBarTwic"]];
                [tbi setSelectedImage:[UIImage imageNamed:@"TabBarTwic"]];
            }
            else if ([title isEqualToString:@"ECO"]) {
                [tbi setImage:[UIImage imageNamed:@"ECO7"]];
                [tbi setSelectedImage:[UIImage imageNamed:@"ECO7"]];
            }
            else if ([title isEqualToString:@"Settings"] || [title isEqualToString:@"Impostazioni"]) {
                [tbi setImage:[UIImage imageNamed:@"TabBarSettings"]];
                [tbi setSelectedImage:[UIImage imageNamed:@"TabBarSettings"]];
            }
            else if ([title isEqualToString:@"Help"]) {
                [tbi setImage:[UIImage imageNamed:@"TabBarInfo"]];
                [tbi setSelectedImage:[UIImage imageNamed:@"TabBarInfo"]];
                [tbi setTitle:NSLocalizedString(@"HELP", @"Informazioni")];
            }
        }
        
        if (IsChessStudioLight) {
            UITabBar *tabBar = tabBarController.tabBar;
            //tabBar.barTintColor = [UIColor whiteColor];
            //tabBar.barStyle = UIBarStyleBlack;
            tabBar.translucent = NO;
        }
    //}
}

- (void) setupSWRevealController {
    SWRevealViewController *revealViewController = (SWRevealViewController *)rootViewController;
    revealViewController.delegate = self;
    if (IS_PAD_PRO) {
        [revealViewController setRearViewRevealWidth:520.0];
        [revealViewController setRightViewRevealWidth:520.0];
    }
    else if (IS_PAD) {
        [revealViewController setRearViewRevealWidth:500.0];
        [revealViewController setRightViewRevealWidth:500.0];
    }
    else {
        [revealViewController setRearViewRevealWidth:260.0];
    }
}

- (id <UIViewControllerAnimatedTransitioning>)revealController:(SWRevealViewController *)revealController animationControllerForOperation:(SWRevealControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if ( operation != SWRevealControllerOperationReplaceRightController )
        return nil;
    
    if ( [toVC isKindOfClass:[RightSideViewController class]] )
    {
        if ( [(RightSideViewController *)toVC wantsCustomAnimation] )
        {
            id<UIViewControllerAnimatedTransitioning> animationController = [[CustomAnimationController alloc] init];
            return animationController;
        }
    }
    
    return nil;
}

- (void) copiaTestFileInDocuments {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *fileCopiati = [def stringForKey:@"FILE_COPIATI"];
    //NSLog(@"FILE COPIATI = %@", fileCopiati);
    if (fileCopiati) {
        //NSLog(@"NON DEVO COPIARE i FILE");
        return;
    }
    //NSLog(@"DEVO COPIARE I FILE");
    
    NSString *fischerPath = [[NSBundle mainBundle] pathForResource:@"Fischer" ofType:@"pgn"];
    NSString *botvinnikPath = [[NSBundle mainBundle] pathForResource:@"Botvinnik" ofType:@"pgn"];
    //NSLog(@"%@", fischerPath);
    //NSLog(@"%@", botvinnikPath);
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *fischerFile = [fischerPath lastPathComponent];
    NSString *botvinnikFile = [botvinnikPath lastPathComponent];
    //NSLog(@"%@", fischerFile);
    //NSLog(@"%@", botvinnikFile);
    NSString *destFischerPath = [documentPath stringByAppendingPathComponent:fischerFile];
    NSString *destBotvinnikPath = [documentPath stringByAppendingPathComponent:botvinnikFile];
    //NSLog(@"%@", destFischerPath);
    //NSLog(@"%@", destBotvinnikPath);
    PgnDbManager *pgnDbManager = [PgnDbManager sharedPgnDbManager];
    if (![pgnDbManager existDatabaseAtPath:destFischerPath]) {
        //NSLog(@"Devo copiare il database di Fischer");
        [pgnDbManager copyDatabase:fischerPath :destFischerPath];
    }
    if (![pgnDbManager existDatabaseAtPath:destBotvinnikPath]) {
        //NSLog(@"Devo copiare il database di Botvinnik");
        [pgnDbManager copyDatabase:botvinnikPath :destBotvinnikPath];
    }
    [def setObject:@"FILE_COPIATI" forKey:@"FILE_COPIATI"];
    [def synchronize];
}

- (void) copiaSampleFileInDocuments {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *positionsCopiato = [def stringForKey:@"SAMPLE"];
    if (positionsCopiato) {
        return;
    }
    NSString *positionPath = [[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"pgn"];
    
    if (!positionPath) {
        return;
    }
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *positionFile = [positionPath lastPathComponent];
    NSString *destPositionPath = [documentPath stringByAppendingPathComponent:positionFile];
    PgnDbManager *pgnDbManager = [PgnDbManager sharedPgnDbManager];
    if (![pgnDbManager existDatabaseAtPath:destPositionPath]) {
        [pgnDbManager copyDatabase:positionPath :destPositionPath];
        [def setObject:@"SAMPLE" forKey:@"SAMPLE"];
        [def synchronize];
    }
}

- (void) setupAppiRater {
    if (IsChessStudioLight) {
        [Appirater setAppId:@"694586937"];
        [Appirater setDebug:YES];
        [Appirater showPrompt];
    }
    else {
        [Appirater setAppId:@"684224545"];
        [Appirater setDebug:YES];
        [Appirater showPrompt];
    }
}

- (void) showPresentation {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *presentation = [def stringForKey:@"PRESENTATION"];
    if (presentation) {
        return;
    }
    //UIAlertView *presentationAlertView = [[UIAlertView alloc] initWithTitle:@"Presentation" message:@"Messaggio di presentazione" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //[presentationAlertView show];
}

- (void) backgroundInit:(id)object {
    //NSLog(@"Eseguo background init");
    /* Chess init */
    Chess::init_mersenne();
    Chess::init_direction_table();
    Chess::init_bitboards();
    Chess::Position::init_zobrist();
    Chess::Position::init_piece_square_tables();
    Chess::MovePicker::init_phase_table();
    
    // Make random number generation less deterministic, for book moves
    int i = abs(Chess::get_system_time() % 10000);
    for (int j = 0; j < i; j++)
        Chess::genrand_int32();
    
    [self loadStandardDefaults];
}


- (void) loadStandardDefaults {
    
    [SettingManager sharedSettingManager];
}

//iOS8

- (void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}


- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //NSLog(@"%@", deviceToken);
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    token = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateActive) {
        
        NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
        
        //NSString *msg = [apsInfo objectForKey:@"alert"];
        //NSLog(@"MSG = %@", msg);
        
        NSDictionary *testoInfo = [apsInfo objectForKey:@"alert"];
        NSString *msg = [testoInfo objectForKey:@"body"];
        //NSLog(@"TESTO = %@", mess);
        
        NSString *title = @"";
        if (IsChessStudioLight) {
            title = @"Chess Studio Light";
        }
        else {
            title = @"Chess Studio";
        }
        
        UIAlertView *notificationAlertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [notificationAlertView show];
    }
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App Linked con successo");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxLinked" object:[NSNumber numberWithBool:[[DBSession sharedSession] isLinked]]];
        }
        else {
            //NSLog(@"Forse hai premuto Cancel");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxLinkCanceled" object:[NSNumber numberWithBool:[[DBSession sharedSession] isLinked]]];
        }
        return YES;
    }
    return NO;
}

@end
