//
//  TBDatabaseCollectionViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 06/11/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "TBDatabaseCollectionViewController.h"
#import "PgnDbManager.h"

@interface TBDatabaseCollectionViewController () {

    PgnDbManager *pgnDbManager;
    
    NSString *rootPath;
    NSString *actualPath;
    
    NSString *documentPattern;
    NSRegularExpression *documentRegex;
    
    BOOL isEditing;
    NSMutableArray *listEditingFile;
}

@end

@implementation TBDatabaseCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self != nil) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([TBDatabaseCollectionCell class]) bundle:[NSBundle mainBundle]];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"DbCellIdentifier"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    //listEditingFile = [[NSMutableArray alloc] init];
    
    isEditing = NO;
    
    pgnDbManager = [PgnDbManager sharedPgnDbManager];
    
    documentPattern = @"Documents";
    documentRegex = [[NSRegularExpression alloc] initWithPattern:documentPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    rootPath = [paths objectAtIndex:0];
    actualPath = [paths objectAtIndex:0];
    
    [self decidiTitolo];
    
    
    //UISegmentedControl *dispSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"List", @"Grid", nil]];
    //[dispSegmentedControl setWidth:70.0 forSegmentAtIndex:0];
    //[dispSegmentedControl setWidth:70.0 forSegmentAtIndex:1];
    //[dispSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBordered];
    //[dispSegmentedControl setSelectedSegmentIndex:1];
    //[dispSegmentedControl setImage:[UIImage imageNamed:@"List"] forSegmentAtIndex:0];
    //[dispSegmentedControl setImage:[UIImage imageNamed:@"Grid"] forSegmentAtIndex:1];
    //[dispSegmentedControl addTarget:self action:@selector(displayModeChanged:) forControlEvents:UIControlEventValueChanged];
    //self.navigationItem.titleView = dispSegmentedControl;
    
    
    
    [self.navigationItem setHidesBackButton:YES];
    
    UIBarButtonItem *tableBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"List2"] style:UIBarButtonItemStylePlain target:self action:@selector(goToTableDisplay)];
    self.navigationItem.leftBarButtonItem = tableBarButton;
    
    UIBarButtonItem *addFolderBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FolderAdd"] style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *manageDbBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ManageDatabase"] style:UIBarButtonItemStylePlain target:self action:@selector(manageBarButtonPressed:)];
    //UIBarButtonItem *downloadDbBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DownloadDatabase"] style:UIBarButtonItemStyleBordered target:nil action:nil];
    //UIBarButtonItem *pasteGamesBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PasteGames"] style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    //[self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:addFolderBarButtonItem, manageDbBarButtonItem, downloadDbBarButtonItem, pasteGamesBarButtonItem, nil]];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:addFolderBarButtonItem, manageDbBarButtonItem, nil]];
}

- (void) displayModeChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        //[self dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    else if (sender.selectedSegmentIndex == 1) {
        //UIStoryboard *sb = [UtilToView getStoryBoard];
        //TBDatabaseCollectionViewController *tbdcvc = [sb instantiateViewControllerWithIdentifier:@"TBDatabaseCollectionViewController"];
        //UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        //TBDatabaseCollectionViewController *tbdcvc = [[TBDatabaseCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
        //UINavigationController *navController = [sb instantiateViewControllerWithIdentifier:@"TBDatabaseCollectionNavigationController"];
        //[self.navigationController pushViewController:tbdcvc animated:NO];
        //[self presentViewController:navController animated:NO completion:nil];
    }
}

- (void) goToTableDisplay {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void) manageBarButtonPressed:(UIBarButtonItem *)sender {
    if (isEditing) {
        isEditing = NO;
        [sender setImage:[UIImage imageNamed:@"ManageDatabase"]];
    }
    else {
        self.collectionView.allowsMultipleSelection = YES;
        isEditing = YES;
        [sender setImage:[UIImage imageNamed:@"ManageDatabaseSelected"]];
    }
    [self.collectionView reloadData];
}

- (void) setListFile:(NSMutableArray *)listFile {
    NSLog(@"Eseguo setListFile");
    _listFile = listFile;
    listEditingFile = [[NSMutableArray alloc] initWithCapacity:_listFile.count];
    for (int i=0; i<_listFile.count; i++) {
        NSNumber *boolNumber = [NSNumber numberWithBool:NO];
        //[listEditingFile replaceObjectAtIndex:i withObject:boolNumber];
        [listEditingFile addObject:boolNumber];
        NSLog(@"Ho inserito il valoe %d", i);
    }
    for (NSNumber *n in listEditingFile) {
        NSLog(@"Valore = %d", n.boolValue);
    }
}

- (void) bottonePremuto:(TBDatabaseCollectionCell *)sender {
    NSString *file = sender.cellLabel.text;
    
    NSUInteger index = [_listFile indexOfObject:file];
    
    //NSLog(@"Hai premuto il bottone con %@ con numero = %d", file, index);
    
    BOOL editing = [[listEditingFile objectAtIndex:index] boolValue];
    editing = !editing;
    [listEditingFile replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:editing]];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) decidiTitolo {
    NSArray *matches = [documentRegex matchesInString:actualPath options:0 range:NSMakeRange(0, [actualPath length])];
    NSString *lastPath = [actualPath lastPathComponent];
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
                self.navigationItem.title = @"Chess Studio DataBase";
            }
        }
    }
    else {
        self.navigationItem.title = lastPath;
    }
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


- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return _listFile.count;
    }
    else if (section == 1) {
        return 4;
    }
    return 10;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PgnDatabaseCell" forIndexPath:indexPath];
    TBDatabaseCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DbCellIdentifier" forIndexPath:indexPath];
    
    cell.layer.borderWidth=1.0f;
    cell.layer.borderColor=[UIColor blueColor].CGColor;
    [cell setEditMode:isEditing];
    NSNumber *boolNumber = [listEditingFile objectAtIndex:indexPath.row];
    BOOL fileEditing = [boolNumber boolValue];
    
    NSString *item = [_listFile objectAtIndex:indexPath.row];
    NSString *newPath = [actualPath stringByAppendingPathComponent:item];
    
    if (indexPath.section == 0) {
        if ([pgnDbManager isDirectoryAtPath:newPath]) {
            //cell.cellImageView.image = [UIImage imageNamed:@"ChessFolder.png"];
            [cell setFile:NO];
        }
        else {
            //cell.cellImageView.image = [UIImage imageNamed:@"PgnChess.png"];
            [cell setFile:YES];
        }
        [cell setCheckedBoxButton:fileEditing];
        cell.cellLabel.text = [_listFile objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1) {
        //cell.backgroundColor = [UIColor greenColor];
        cell.cellImageView.image = [UIImage imageNamed:@"PgnChess.png"];
        cell.cellLabel.text = @"Questo è un testo";
    }
    else if (indexPath.section == 2) {
        //cell.backgroundColor = [UIColor blueColor];
        cell.cellImageView.image = [UIImage imageNamed:@"ChessFolder.png"];
        cell.cellLabel.text = @"Questa è una cartella";
    }
    cell.cellLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

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
