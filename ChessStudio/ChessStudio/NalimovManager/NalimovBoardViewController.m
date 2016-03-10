//
//  BoardViewController.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "NalimovBoardViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UtilToView.h"

#import "PGNParser.h"
#import "PGNMove.h"
#import "PGNGame.h"

#import "PGNAnalyzer.h"

#import "MBProgressHUD.h"

#import "DDFileReader.h"

#import "GameWebView.h"

#import "BookManager.h"
#import "OpeningBookManager.h"

#import "SettingManager.h"

#import "SWRevealViewController.h"

#import "Reachability.h"

@interface NalimovBoardViewController () {
    
    //NSData *buffer;

    SettingManager *settingManager;
    
    BoardModel *boardModel;
    BoardView *boardView;
    
    SetupPositionView *setupPositionView;
    NSString *selectedPieceForSetupPosition;
    
    int casaPartenza;
    int casaArrivo;
    
    
    CGFloat dimSquare;

    
    BOOL flipped;
    
    UIActionSheet *actionSheetMenu;
    //UIActionSheet *actionSheetMoves;
    UIActionSheet *actionSheetMenuGame;
    
    UIView *colorView;
    
    
    //GVPartita *partita;
    PieceButton *pezzoMosso;
    PieceButton *pezzoCatturato;
    PieceButton *pedoneAppenaPromosso;
    //GVMossa *ultimaMossa;
    
    PGNParser *pgnParser;
    
    //PGNGame *pgnGame;
    
    
    
    //NSMutableArray *pgnMoves;
    
    
    PGNMove *prossimaMossa;
    PGNMove *mossaEseguita;
    PGNMove *pgnRootMove;
    PGNMove *resultMove;
    BOOL stopNextMove;
    BOOL stopPrevMove;
    UIAlertView *variantiAlertView;
    
    
    
    NSString *pieceType;
    NSString *coordinate;
    NSString *squares;
    //NSString *notation;
    //NSString *vistaMotore;
    
    //BOOL saltaVarianti;
    
    UIPopoverController *annotationMovePopoverController;
    AnnotationMoveTableViewController *amtvc;
    
    UIPopoverController *controllerPopoverController;
    
    
    //NSMutableArray *stackFen;
    
    UIView *titoloView;
    UILabel *primaRigaTitolo;
    UILabel *secondaRigaTitolo;
    UILabel *terzaRigaTitolo;
    
    
    EngineController *engineController;
    Options *options;
    
    NSString *startFenPosition;
    
    UILabel *analysisView;
    UILabel *searchStatsView;
    UIView *engineView;
    
    
    UILongPressGestureRecognizer *boardViewLongPressGestureRecognizer;
    UITapGestureRecognizer *boardViewTapGestureRecognizer;
    
    enum BoardSize sizeBoard;
    
    BookManager *bookManager;
    
    OpeningBookManager *openingBookManager;
    //UILabel *openingBookView;
    
    NSArray *bookMovesForTap;
    
    GameSetting *gameSetting;
    ControllerTableViewController *controllerTableViewController;
    UINavigationController *controllerNavigationController;
    
    //UIToolbar *gameReplayToolbar;
    
    
    
    
    //Variabili da utilizzare per la promozione delle varianti
    NSInteger lineaDaPromuovere;
    PGNMove *tempProssimaMossa;
    
    
    
    
    NSArray *defaultToolbarItems;
    
    SWRevealViewController *revealViewController;
    
    
    UIPopoverController *boardViewMenuPopoverController;
    
    int candidateSquareTo;
    
    UITapGestureRecognizer *tapTitleGestureRecognizer;
    UIView *navigationBarTapView;
    
    UILabel *fenLabel;
    
    SelectionPieceView *selectionPieceView;
    UITableView *_tableView;
    NSMutableArray *_tableViewData;
    NetworkStatus networkStatus;
    //UISegmentedControl *colorSegControl;
    //UISegmentedControl *setupSegControl;
    //UIButton *clearButton;
    //UISwitch *nalimovSwitch;
    ControlNalimovView *controlNalimovView;
    
    UILabel *letterLabel;
    UILabel *numberLabel;
    
    BOOL nalimovTableBase;
    BOOL selectedMove;
    BOOL nalimovCheck;
}


@end

@implementation NalimovBoardViewController

@synthesize delegate = _delegate;
@synthesize gameModel = _gameModel;
@synthesize gameWebView = _gameWebView;
@synthesize gameToView = _gameToView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) awakeFromNib {
    
    //NSLog(@"ESEGUO AWAKE FROM NIB");
    
    //NSLog(@"Sto iniziando awakeFromNib in BoardViewController");
    
    if (IS_IOS_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    settingManager = [SettingManager sharedSettingManager];
    
    //_insertMode = YES;
    
    boardModel = [[BoardModel alloc] init];
    [boardModel setupInitialPosition];
    
    
    pedoneAppenaPromosso = nil;
    
    
    if (IsChessStudioLight) {
        startFenPosition = nil;
    }
    else {
        startFenPosition = @"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    }
    
    //vistaMotore = [settingManager vistaMotore];
    //notation = [settingManager notation];
    
    //NSLog(@"Sto finendo awakeFromNib in BoardViewController");
    
    
    gameSetting = [GameSetting sharedGameSetting];
    [gameSetting reset];
    
    
    //Inizializzazione variabili da usare per la promozione delle varianti
    lineaDaPromuovere = -1;
    tempProssimaMossa = nil;
    
    
    nalimovTableBase = YES;
    selectedMove = YES;
    nalimovCheck = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //(NSLog(@"ESEGUO VIEW_DID_LOAD");
    
    flipped = NO;
    
    if (_setupPosition) {
        [boardModel clearBoard];
        [settingManager setBoardSize:BIG];
    }

    [self gestisciToolbarInSetupPosition];
    
    casaPartenza = -1;
    casaArrivo = -1;
    
    
    [self initMoveListWebView];
    
    
    UIBarButtonItem *actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    //self.navigationItem.rightBarButtonItem = actionBarButtonItem;

    CGFloat dimSquareColorView;
    
    if (IS_PAD) {
        dimSquareColorView = 30.0;
    }
    else {
        if (IS_PORTRAIT) {
            dimSquareColorView = 10.0;
        }
        else {
            dimSquareColorView = 15.0;
        }
    }
    
    
    colorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, dimSquareColorView, dimSquareColorView)];
    [colorView setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *colorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:colorView];
    [colorBarButtonItem setEnabled:NO];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:actionBarButtonItem, colorBarButtonItem, nil];
    
    [self evidenziaAChiToccaMuovere];
    //openingBookManager = [[OpeningBookManager alloc] initManager];
    
    if (_gameToView) {
        [self aggiornaWebView];
    }
    else {
        if (_setupPosition) {
            [self initNewPosition];
        }
        else {
            [self initNewGame];
        }
    }
    
    //saltaVarianti = NO;
    
    [self setupNavigationTitle];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"panno2.png"]];
    self.view.backgroundColor = [UIColor colorWithRed:0.000 green:0.557 blue:0.165 alpha:1.000];
    
    boardViewLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(boardViewLongPressed:)];
    boardViewLongPressGestureRecognizer.minimumPressDuration = 1.30f;
    [boardView addGestureRecognizer:boardViewLongPressGestureRecognizer];
    
    
    boardViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(boardViewTapped:)];
    boardViewTapGestureRecognizer.numberOfTapsRequired = 1;
    [boardView addGestureRecognizer:boardViewTapGestureRecognizer];
    
    
    //UIPinchGestureRecognizer *boardViewPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(boardViewPinched:)];
    //[boardView addGestureRecognizer:boardViewPinchGesture];
    
    //UIPanGestureRecognizer *boardViewPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(boardViewPan:)];
    //[boardView addGestureRecognizer:boardViewPanGesture];
    
    //openingBookManager = [[OpeningBookManager alloc] initManagerWithBookName:@"guibook.bin"];
    //openingBookManager = [[OpeningBookManager alloc] initManager];
    
    
    
    //NSLog(@"Sto finendo viewDidLoad in BoardViewController");
    
    
    //if (IsChessStudioLight && IS_IOS_7) {
        //self.canDisplayBannerAds = YES;
        //_rectangleAdView = [[ADBannerView alloc] initWithAdType:ADAdTypeMediumRectangle];
        //_rectangleAdView = [[ADBannerView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        //_rectangleAdView.adType = ADAdTypeMediumRectangle;
        //_rectangleAdView.delegate = self;
    //}
    
    
    //if (IsChessStudioLight) {
        //_varianteSuButton.enabled = NO;
        //_varianteSuButton.image = nil;
        //_azioneButton.enabled = NO;
        //_azioneButton.image = nil;
    //}
    
    
    
    
    defaultToolbarItems = [self toolbarItems];
    
    [self checkRevealed];
    
    //NSLog(@"Nalimov TableBase");
    
    [self setupReachability];
    
    [self setNavigationTitle:@"Nalimov Tablebase"];
    
}

- (void)viewDidUnload {
    [self setGameWebView:nil];
    //[self setToolbar:nil];
    [super viewDidUnload];
}


- (void) loadView {
    [super loadView];
    //NSLog(@"ESEGUO LOAD VIEW");
}

- (void) setupReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
    networkStatus = [internetReachability currentReachabilityStatus];
    [internetReachability startNotifier];
}

- (void) reachabilityChanged:(NSNotification *)notification {
    Reachability *reachability = [notification object];
    //if (reachability == [Reachability reachabilityForInternetConnection]) {
        networkStatus = [reachability currentReachabilityStatus];
        if (networkStatus == NotReachable) {
            NSLog(@"Non esiste connessione");
        }
        else if (networkStatus == ReachableViaWiFi) {
            NSLog(@"WiFi Ok");
        }
        else if (networkStatus == ReachableViaWWAN) {
            NSLog(@"Reachable WAN");
        }
    //}
}


- (void) checkRevealed {
    revealViewController = nil;
    UIViewController *sourceViewController = self.parentViewController.parentViewController;
    if ([sourceViewController isKindOfClass:[SWRevealViewController class]]) {
        revealViewController = [self revealViewController];
        [revealViewController panGestureRecognizer];
        [revealViewController tapGestureRecognizer];
        [revealViewController disablePanGesture];
        //UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon.png"] style:UIBarButtonItemStyleBordered target:revealViewController action:@selector(revealToggle:)];
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SWRevealIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(boardViewControllerRevealToggle)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
    //NSLog(@"%@", sourceViewController);
    //NSLog(@"%@", self.parentViewController);
    //NSLog(@"%@", self.parentViewController.parentViewController);
}

- (void) setNavigationTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    if (IS_PAD) {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:35.0];
    }
    else if (IS_IPHONE_6P) {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:24.0];
    }
    else if (IS_IPHONE_6) {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:23.0];
    }
    else if (IS_IPHONE_5) {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:22.0];
    }
    else {
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0];
    }
    
    //titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textColor = UIColorFromRGB(0x0000CD);
    titleLabel.text = title;
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationItem.titleView = titleLabel;
    
    UITapGestureRecognizer *tapTitleLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTitleLabel:)];
    [titleLabel setUserInteractionEnabled:YES];
    [titleLabel addGestureRecognizer:tapTitleLabel];
}


- (void) tapOnTitleLabel:(id)sender {
    AboutNalimovViewController *aboutNalimovViewControler = [[AboutNalimovViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:aboutNalimovViewControler];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
}


- (void) initMoveListWebView {
    
    [_gameWebView removeFromSuperview];
    _gameWebView = nil;
    //return;
    
    _gameWebView = [[GameWebView alloc] initWithFrame:CGRectMake(10, 10, 100, 80)];
    
    _gameWebView.delegate = self;
    _gameWebView.opaque = NO;
    _gameWebView.userInteractionEnabled = YES;
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [_gameWebView addGestureRecognizer:rightSwipeRecognizer];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandle)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [_gameWebView addGestureRecognizer:leftSwipeRecognizer];
    
    //_gameWebView = [[GameWebView alloc] initWithFrame:CGRectMake(0.0, 768.0, 768.0, 148.0)];  //Senza finestra motore
    //_gameWebView = [[GameWebView alloc] initWithFrame:CGRectMake(0.0, 768.0, 768.0, 110.0)];    //Con Finestra motore
    //_gameWebView.delegate = self;
    //_gameWebView.opaque = NO;
    //_gameWebView.userInteractionEnabled = YES;
    //[self.view addSubview:_gameWebView];
    
    //moveListWebView = [[GameWebView alloc] initWithFrame:CGRectMake(0.0, 768.0, 768.0, 110.0)];    //Con Finestra motore
    //moveListWebView.delegate = self;
    //moveListWebView.userInteractionEnabled = YES;
    //[self.view addSubview:moveListWebView];
    
    //NSLog(@"Dimensioni MoveListWebView     X=%f      Y=%f       W=%f        H=%f", moveListWebView.frame.origin.x, moveListWebView.frame.origin.y, moveListWebView.frame.size.width, moveListWebView.frame.size.height);
}


- (BOOL) canBecomeFirstResponder {
    return YES;
}

/*
- (void) boardViewLongPressed:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        
        CGPoint tapPoint = [recognizer locationInView:self.view];
        //CGPoint tapPointInView = [self.view convertPoint:tapPoint toView:self.view];
        CGRect rect = CGRectMake(tapPoint.x - 30, tapPoint.y, 70.0, 10.0);
        
        UIMenuItem *bigSizeItem = [[UIMenuItem alloc] initWithTitle:@"Big" action:@selector(bigSizeItemPressed:)];
        UIMenuItem *mediumSizeItem = [[UIMenuItem alloc] initWithTitle:@"Medium" action:@selector(mediumSizeItemPressed:)];
        UIMenuItem *smallSizeItem = [[UIMenuItem alloc] initWithTitle:@"Small" action:@selector(smallSizeItemPressed:)];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        if (sizeBoard == BIG) {
            [menuController setMenuItems:[NSArray arrayWithObjects:mediumSizeItem, smallSizeItem, nil]];
        }
        else if (sizeBoard == MEDIUM) {
            [menuController setMenuItems:[NSArray arrayWithObjects:bigSizeItem, smallSizeItem, nil]];
        }
        else if (sizeBoard == SMALL) {
            [menuController setMenuItems:[NSArray arrayWithObjects:bigSizeItem, mediumSizeItem, nil]];
        }
        [menuController setTargetRect:rect inView:self.view];
        [menuController setMenuVisible:YES animated:YES];
    }
}
*/

- (void) boardViewControllerRevealToggle {
    [self stopEngineController];
    
    if (actionSheetMenuGame.window ) {
        [actionSheetMenuGame dismissWithClickedButtonIndex:0 animated:YES];
        actionSheetMenuGame = nil;
    }
    if (actionSheetMenu.window ) {
        [actionSheetMenu dismissWithClickedButtonIndex:0 animated:YES];
        actionSheetMenu = nil;
        return;
    }
    if (annotationMovePopoverController.isPopoverVisible) {
        [annotationMovePopoverController dismissPopoverAnimated:YES];
        annotationMovePopoverController = nil;
        return;
    }
    
    if (controllerPopoverController.isPopoverVisible) {
        [controllerPopoverController dismissPopoverAnimated:YES];
        controllerPopoverController = nil;
        return;
    }
    
    if (boardViewMenuPopoverController.isPopoverVisible) {
        [boardViewMenuPopoverController dismissPopoverAnimated:NO];
        boardViewMenuPopoverController = nil;
    }
    
    if ([_pgnGame isEditMode]) {
        //[_pgnGame setEditMode:NO];
    }
    
    //Controllo per chiedere se si è sicuri di salvare la partita
    if ([_pgnGame isModified]) {
        
        if (_setupPosition) {
            UIAlertView *saveGameAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE_POSITION", nil) message:NSLocalizedString(@"SAVE_POSITION_ALERT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"YES", nil) otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
            saveGameAlertView.tag = -200;
            [saveGameAlertView show];
            return;
        }
        
        
        UIAlertView *saveGameAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE_GAME", nil) message:NSLocalizedString(@"SAVE_GAME_ALERT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"YES", nil) otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
        saveGameAlertView.tag = -100;
        [saveGameAlertView show];
        return;
    }
    
    if (revealViewController) {
        [revealViewController revealToggleAnimated:YES];
    }
}

- (void) boardViewLongPressed:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (IS_PHONE) {
        if (IS_LANDSCAPE) {
            return;
        }
    }
    
    if (_setupPosition) {
        return;
    }
    
    [self becomeFirstResponder];
    
    CGPoint tapPoint = [longPressGestureRecognizer locationInView:self.view];
    CGPoint tapPointInView = [self.view convertPoint:tapPoint toView:boardView];
    
    if (![boardView tapInCentro:tapPointInView :2]) {
        return;
    }
    
    
    CGRect rect = CGRectMake(tapPoint.x - 30, tapPoint.y, 70.0, 10.0);
    
    UIMenuItem *bigSizeItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"BIG", nil) action:@selector(bigSizeItemPressed:)];
    UIMenuItem *mediumSizeItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"MEDIUM", nil) action:@selector(mediumSizeItemPressed:)];
    UIMenuItem *smallSizeItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"SMALL", nil) action:@selector(smallSizeItemPressed:)];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if ([settingManager boardSize] == BIG) {
        [menuController setMenuItems:[NSArray arrayWithObjects:mediumSizeItem, smallSizeItem, nil]];
    }
    else if ([settingManager boardSize] == MEDIUM) {
        [menuController setMenuItems:[NSArray arrayWithObjects:bigSizeItem, smallSizeItem, nil]];
    }
    else if ([settingManager boardSize] == SMALL) {
        [menuController setMenuItems:[NSArray arrayWithObjects:bigSizeItem, mediumSizeItem, nil]];
    }
    [menuController setTargetRect:rect inView:self.view];
    [menuController setMenuVisible:YES animated:YES];
}

- (void) boardViewTapped:(UITapGestureRecognizer *)tapRecognizer {
    
    if (IS_PHONE) {
        if (IS_LANDSCAPE) {
            return;
        }
    }
    
    if (_setupPosition) {
        return;
    }
    
    [self becomeFirstResponder];
    
    CGPoint tapPoint = [tapRecognizer locationInView:self.view];
    CGPoint tapPointInView = [self.view convertPoint:tapPoint toView:boardView];
    
    if (![boardView tapInCentro:tapPointInView :2]) {
        return;
    }
    
    
    CGRect rect = CGRectMake(tapPoint.x - 30, tapPoint.y, 70.0, 10.0);
        
    UIMenuItem *bigSizeItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"BIG", nil) action:@selector(bigSizeItemPressed:)];
    UIMenuItem *mediumSizeItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"MEDIUM", nil) action:@selector(mediumSizeItemPressed:)];
    UIMenuItem *smallSizeItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"SMALL", nil) action:@selector(smallSizeItemPressed:)];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if ([settingManager boardSize] == BIG) {
        [menuController setMenuItems:[NSArray arrayWithObjects:mediumSizeItem, smallSizeItem, nil]];
    }
    else if ([settingManager boardSize] == MEDIUM) {
        [menuController setMenuItems:[NSArray arrayWithObjects:bigSizeItem, smallSizeItem, nil]];
    }
    else if ([settingManager boardSize] == SMALL) {
        [menuController setMenuItems:[NSArray arrayWithObjects:bigSizeItem, mediumSizeItem, nil]];
    }
    [menuController setTargetRect:rect inView:self.view];
    [menuController setMenuVisible:YES animated:YES];
}

- (void) bigSizeItemPressed:(id)sender {
    sizeBoard = BIG;
    
    [settingManager setBoardSize:BIG];
    [self replaceBoard];
}

- (void) mediumSizeItemPressed:(id)sender {
    sizeBoard = MEDIUM;
    
    [settingManager setBoardSize:MEDIUM];
    [self replaceBoard];
}

- (void) smallSizeItemPressed:(id)sender {
    sizeBoard = SMALL;
    
    [settingManager setBoardSize:SMALL];
    [self replaceBoard];
}

- (void) setupNalimovComponents {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(dimSquare*8+40, 0, 200, dimSquare*8) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.layer.cornerRadius = 10.0;
        //_tableView.backgroundView.backgroundColor = nil;
        _tableView.backgroundColor = [UIColor colorWithRed:0.000 green:0.557 blue:0.165 alpha:0.800];
        _tableView.layer.borderWidth = 2.0;
        _tableView.layer.borderColor = [UIColor yellowColor].CGColor;
        _tableView.layer.borderColor = [UIColor clearColor].CGColor;
        [_tableView setSeparatorColor:[UIColor yellowColor]];
        [_tableView setShowsVerticalScrollIndicator:NO];
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(handleNalimovRefresh:) forControlEvents:UIControlEventValueChanged];
        [_tableView addSubview:refreshControl];
    }
    
    if (!selectionPieceView) {
        selectionPieceView = [[SelectionPieceView alloc] initWithSquareSize:dimSquare];
        selectionPieceView.delegate = self;
        selectionPieceView.center = CGPointMake(boardView.center.x, dimSquare*9 + 10);
    }
    
    if (!controlNalimovView) {
        controlNalimovView = [[ControlNalimovView alloc] initWithSquareSize:dimSquare];
        controlNalimovView.delegate = self;
        controlNalimovView.center = CGPointMake(_tableView.center.x, dimSquare*9 + 10);
    }
    
    if (!fenLabel) {
        fenLabel = [[UILabel alloc] initWithFrame:CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 25)];
        [fenLabel setBackgroundColor:[UIColor whiteColor]];
        UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        [fenLabel setFont:boldFont];
        fenLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:fenLabel];
        NSString *fen = [NSString stringWithFormat:@" FEN: %@", [boardModel fenNotation]];
        [fenLabel setText:fen];
    }
}

- (void) removeNalimovComponents {
    if (boardView) {
        [boardView setNalimovCoordinates:nil];
        boardView.delegate = nil;
        [boardView removeFromSuperview];
        boardView = nil;
    }
    if (selectionPieceView) {
        [selectionPieceView removeFromSuperview];
    }
    if (controlNalimovView) {
        [controlNalimovView removeFromSuperview];
    }
    if (fenLabel) {
        [fenLabel removeFromSuperview];
    }
    if (_tableView) {
        [_tableView removeFromSuperview];
    }
}


- (void) setupNalimovPad:(UIDeviceOrientation)deviceOrientation {
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    [self removeNalimovComponents];
    
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    [self setupInitialPosition];
    [self initBoardViewCoordinates];
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    if (flipped) {
        [boardView flipPosition];
    }
    boardView.center = [settingManager getNalimovBoardViewCenter:dimSquare :deviceOrientation];
    //if ([settingManager boardWithEdge]) {
    //    UIView *borderView = [self getBoardViewWithEdge:UIDeviceOrientationPortrait];
    //    [self.view addSubview:borderView];
    //}
    [self.view addSubview:boardView];
    _tableView.frame = [settingManager getNalimovTableViewFrame:dimSquare :deviceOrientation];
    fenLabel.frame = [settingManager getNalimovFenLabelFrame:dimSquare :deviceOrientation];
    selectionPieceView.frame = [settingManager getNalimovSelectionViewFrame:dimSquare :deviceOrientation];
    [self.view addSubview:selectionPieceView];
    controlNalimovView.frame = [settingManager getNalimovControlViewFrame:dimSquare :deviceOrientation];
    [self.view addSubview:controlNalimovView];
    [self.view addSubview:_tableView];
    [self.view addSubview:fenLabel];
}

/*
- (void) setupNalimovPadPortrait {
    dimSquare = [settingManager getSquareSizeNalimovPortrait];
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    [self removeNalimovComponents];
    
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    [self setupInitialPosition];
    [self initBoardViewCoordinates];
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    if (flipped) {
        [boardView flipPosition];
    }
    //boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
    boardView.center = [settingManager getNalimovBoardViewCenter:dimSquare];
    if ([settingManager boardWithEdge]) {
        UIView *borderView = [self getBoardViewWithEdge:UIDeviceOrientationPortrait];
        [self.view addSubview:borderView];
    }
    [self.view addSubview:boardView];
    //_tableView.frame = CGRectMake(dimSquare*8+40, 0, 200, dimSquare*8);
    _tableView.frame = [settingManager getNalimovTableViewFrame:dimSquare];
    //fenLabel.frame = CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 25);
    fenLabel.frame = [settingManager getNalimovFenLabelFrame:dimSquare];
    //selectionPieceView.center = CGPointMake(boardView.center.x, dimSquare*9 + 10);
    //selectionPieceView.frame = CGRectMake(dimSquare, dimSquare*8 + 10, dimSquare*6, dimSquare*2);
    selectionPieceView.frame = [settingManager getNalimovSelectionViewFrame:dimSquare];
    [self.view addSubview:selectionPieceView];
    //controlNalimovView.center = CGPointMake(_tableView.center.x, dimSquare*9 + 10);
    //controlNalimovView.frame = CGRectMake(dimSquare*8 + 40 + 40, dimSquare*8 + 10, dimSquare*2, dimSquare*2);
    controlNalimovView.frame = [settingManager getNalimovControlViewFrame:dimSquare];
    [self.view addSubview:controlNalimovView];
    [self.view addSubview:_tableView];
    [self.view addSubview:fenLabel];
}
*/

/*
- (void) setupNalimovPadLandscape {
    dimSquare = [settingManager getSquareSizeNalimovLandscape];
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    [self removeNalimovComponents];
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    [self setupInitialPosition];
    [self initBoardViewCoordinates];
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    if (flipped) {
        [boardView flipPosition];
    }
    //boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
    boardView.center = [settingManager getNalimovBoardViewCenter:dimSquare];
    if ([settingManager boardWithEdge]) {
        UIView *borderView = [self getBoardViewWithEdge:UIDeviceOrientationPortrait];
        [self.view addSubview:borderView];
    }
    [self.view addSubview:boardView];
    [self setupInitialPosition];
    [self initBoardViewCoordinates];
    
    //selectionPieceView.center = CGPointMake(dimSquare*8 + dimSquare*3 + 10, dimSquare);
    //selectionPieceView.frame = CGRectMake(dimSquare*8 + 10, 0, dimSquare*6, dimSquare*2);
    selectionPieceView.frame = [settingManager getNalimovSelectionViewFrame:dimSquare];
    [self.view addSubview:selectionPieceView];
    
    //controlNalimovView.center = CGPointMake(dimSquare*8 + dimSquare  + 10, dimSquare*3 + 10);
    //controlNalimovView.frame = CGRectMake(dimSquare*8 + 10, dimSquare*2 + 10, dimSquare*2, dimSquare*2);
    controlNalimovView.frame = [settingManager getNalimovControlViewFrame:dimSquare];
    [self.view addSubview:controlNalimovView];
    [self.view addSubview:_tableView];
    
    
    //_tableView.frame = CGRectMake(dimSquare*8 + dimSquare*2 + 20, dimSquare*2+10, 150, dimSquare*8 - dimSquare*2 - 80);
    _tableView.frame = [settingManager getNalimovTableViewFrame:dimSquare];
    //fenLabel.frame = CGRectMake(dimSquare*8 + 10, dimSquare*8 - 26, 1024-dimSquare*8-20, 25);
    fenLabel.frame = [settingManager getNalimovFenLabelFrame:dimSquare];
    [self.view addSubview:fenLabel];
}
*/

- (void) presentNalimovBoardView {
    
    if (IS_PORTRAIT) {
        dimSquare = [settingManager getSquareSizeNalimovPortrait];
    }
    else {
        dimSquare = [settingManager getSquareSizeNalimovLandscape];
    }
    [self setupNalimovComponents];
    if (IS_PORTRAIT) {
        [self setupNalimovPad:UIDeviceOrientationPortrait];
    }
    else {
        [self setupNalimovPad:UIDeviceOrientationLandscapeRight];
    }
    //[self setupNalimovPad];
    
    return;
    
    
    
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    
    if (boardView) {
        [boardView removeFromSuperview];
        boardView.delegate = nil;
        boardView = nil;
    }
    
    dimSquare = [settingManager getSquareSizeNalimov];
    
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    [self setupInitialPosition];
    [self initBoardViewCoordinates];
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
        else {
            boardView.center = CGPointMake(dimSquare*8/2 + 40.0, dimSquare*8/2 + 40.0);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
        else {
            boardView.center = CGPointMake(dimSquare*8/2 + 40.0, dimSquare*8/2 + 40.0);
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
        else {
            boardView.center = CGPointMake(dimSquare*8/2 + 40.0, dimSquare*8/2 + 40.0);
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
        else {
            boardView.center = CGPointMake(dimSquare*8/2 + 40.0, dimSquare*8/2 + 40.0);
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
        else {
            boardView.center = CGPointMake(dimSquare*8/2 + 40.0, dimSquare*8/2 + 40.0);
        }
    }
    
    [self.view addSubview:boardView];
    
    //if (!colorSegControl) {
    //    NSArray *segArray = [NSArray arrayWithObjects:@"White to move", @"Black to move", nil];
    //    colorSegControl = [[UISegmentedControl alloc] initWithItems:segArray];
    //    if (IS_IPHONE_4_OR_LESS) {
    //        if (IS_PORTRAIT) {
    //            colorSegControl.frame = CGRectMake(0, 0, 120, 18);
    //            [colorSegControl setTitle:@"White" forSegmentAtIndex:0];
    //            [colorSegControl setTitle:@"Black" forSegmentAtIndex:1];
    //        }
    //    }
    //    else if (IS_IPHONE_6) {
    //        if (IS_PORTRAIT) {
    //            colorSegControl.frame = CGRectMake(0, 0, 120, 18);
    //            [colorSegControl setTitle:@"White" forSegmentAtIndex:0];
    //            [colorSegControl setTitle:@"Black" forSegmentAtIndex:1];
    //        }
    //    }
    //    colorSegControl.center = CGPointMake(dimSquare*8/2 + 40.0, 20.0);
    //    colorSegControl.tintColor = [UIColor yellowColor];
    //    [colorSegControl setSelectedSegmentIndex:0];
    //    [colorSegControl addTarget:self action:@selector(segControlChanged:) forControlEvents:UIControlEventValueChanged];
    //    [self.view addSubview:colorSegControl];
    //}
    
    if (!_tableView) {
        if (IS_PAD) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(dimSquare*8+40, 0, 200, dimSquare*8) style:UITableViewStylePlain];
        }
        else if (IS_IPHONE_6P) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(dimSquare*8+5+5, 0.0, 95, dimSquare*8) style:UITableViewStylePlain];
        }
        else if (IS_IPHONE_6) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(dimSquare*8+5, 0, 70, dimSquare*8) style:UITableViewStylePlain];
        }
        else if (IS_IPHONE_5) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(dimSquare*8+0+5, 0, 70, dimSquare*8) style:UITableViewStylePlain];
        }
        else if (IS_IPHONE_4_OR_LESS) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(dimSquare*8+0+5, 0, 70, dimSquare*8) style:UITableViewStylePlain];
        }
        //[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Nalimov Cell"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.layer.cornerRadius = 10.0;
        //_tableView.backgroundView.backgroundColor = nil;
        _tableView.backgroundColor = [UIColor colorWithRed:0.000 green:0.557 blue:0.165 alpha:0.800];
        _tableView.layer.borderWidth = 2.0;
        _tableView.layer.borderColor = [UIColor yellowColor].CGColor;
        [_tableView setSeparatorColor:[UIColor yellowColor]];
        [_tableView setShowsVerticalScrollIndicator:NO];
        [self.view addSubview:_tableView];
        
        
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(handleNalimovRefresh:) forControlEvents:UIControlEventValueChanged];
        [_tableView addSubview:refreshControl];
    }
    
    if (!selectionPieceView) {
        selectionPieceView = [[SelectionPieceView alloc] initWithSquareSize:dimSquare];
        selectionPieceView.delegate = self;
        selectionPieceView.center = CGPointMake(boardView.center.x, dimSquare*9 + 10);
        [self.view addSubview:selectionPieceView];
    }
    
    if (!controlNalimovView) {
        controlNalimovView = [[ControlNalimovView alloc] initWithSquareSize:dimSquare];
        controlNalimovView.delegate = self;
        controlNalimovView.center = CGPointMake(_tableView.center.x, dimSquare*9 + 10);
        [self.view addSubview:controlNalimovView];
    }
    

    if (!fenLabel) {
        if (IS_PAD) {
            fenLabel = [[UILabel alloc] initWithFrame:CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 25)];
        }
        else if (IS_IPHONE_6) {
            fenLabel = [[UILabel alloc] initWithFrame:CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 20)];
        }
        else if (IS_IPHONE_6P) {
            fenLabel = [[UILabel alloc] initWithFrame:CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 20)];
        }
        else if (IS_IPHONE_5) {
            fenLabel = [[UILabel alloc] initWithFrame:CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 20)];
        }
        else if (IS_IPHONE_4_OR_LESS) {
            fenLabel = [[UILabel alloc] initWithFrame:CGRectMake(dimSquare, dimSquare*8+40+20+dimSquare*2+20, dimSquare*8, 20)];
        }

        
        [fenLabel setBackgroundColor:[UIColor whiteColor]];
        UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        [fenLabel setFont:boldFont];
        fenLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:fenLabel];
        NSString *fen = [NSString stringWithFormat:@" FEN: %@", [boardModel fenNotation]];
        [fenLabel setText:fen];
    }
    

    //if (!setupSegControl) {
    //    NSArray *setupSegArray = [NSArray arrayWithObjects:@"Setup", @"Move", nil];
    //    setupSegControl = [[UISegmentedControl alloc] initWithItems:setupSegArray];
    //    if (IS_IPHONE_4_OR_LESS) {
    //        if (IS_PORTRAIT) {
    //            setupSegControl.frame = CGRectMake(0, 0, 90, 18);
    //        }
    //    }
    //    else if (IS_IPHONE_6) {
    //        if (IS_PORTRAIT) {
    //            setupSegControl.frame = CGRectMake(0, 0, 90, 18);
    //        }
    //    }
    //    setupSegControl.center = CGPointMake(_tableView.center.x, 20.0);
    //    setupSegControl.tintColor = [UIColor whiteColor];
    //    [setupSegControl setSelectedSegmentIndex:0];
    //    [setupSegControl addTarget:self action:@selector(setupSegControlChanged:) forControlEvents:UIControlEventValueChanged];
    //    [self.view addSubview:setupSegControl];
    //}
    
    //if (!clearButton) {
    //    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [clearButton setFrame:CGRectMake(0, 0, 200, 20)];
    //    clearButton.tintColor = [UIColor blackColor];
    //    clearButton.titleLabel.textColor = [UIColor whiteColor];
    //    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    //    [clearButton addTarget:self action:@selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //    clearButton.center = CGPointMake(_tableView.center.x, _tableView.frame.size.height + 70);
    //    [self.view addSubview:clearButton];
    //}
    
    //if (!nalimovSwitch) {
    //    nalimovSwitch = [[UISwitch alloc] init];
    //    [nalimovSwitch setOn:nalimovCheck];
    //    nalimovSwitch.center = CGPointMake(clearButton.center.x, clearButton.center.y + 40);
    //    [nalimovSwitch addTarget:self action:@selector(nalimovSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    //    [self.view addSubview:nalimovSwitch];
    //}
    
    if (!letterLabel) {
        [self addLetterLabel];
    }
    
    if (!numberLabel) {
        [self addNumberLabel];
    }
}

- (void) handleNalimovRefresh:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
    
    if ([self isNalimovEnabled]) {
        [self getNalimovResult];
    }
}

- (void) addLetterLabelOld {
    NSString *lettere = @"";
    if (IS_PAD) {
        if (flipped) {
            lettere = @"      h           g            f           e            d            c             b            a";
        }
        else {
            lettere = @"      a           b            c           d            e            f             g            h";
        }
    }
    else if (IS_IPHONE_6P) {
        if (flipped) {
            lettere = @"    h         g          f         e          d          c           b          a";
        }
        else {
            lettere = @"   a     b      c     d      e      f    g    h";
        }
    }
    
    
    letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, dimSquare*8+40+6, dimSquare*8, 16)];
    [letterLabel setBackgroundColor:[UIColor clearColor]];
    letterLabel.textColor = [UIColor whiteColor];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    [letterLabel setFont:boldFont];
    letterLabel.text = lettere;
    [self.view addSubview:letterLabel];
}

- (void) addLetterLabel {
    return;
    int k=0;
    int offsetX = 0;
    if (IS_PAD) {
        offsetX = 8;
    }
    else if (IS_IPHONE_6P) {
        offsetX = 20;
    }
    else if (IS_IPHONE_6) {
        offsetX = 23;
    }
    else if (IS_IPHONE_5) {
        offsetX = 15;
    }
    else if (IS_IPHONE_4_OR_LESS) {
        offsetX = 15.0;
    }
    if (!flipped) {
        for (int i=97; i<=104; i++) {
            k++;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(offsetX + dimSquare*(k), dimSquare*8+40+5, 10, 16)];
            label.textColor = [UIColor whiteColor];
            label.adjustsFontSizeToFitWidth = YES;
            UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
            [label setFont:boldFont];
            [label setBackgroundColor:[UIColor clearColor]];
            label.text = [NSString stringWithFormat:@"%c", i];
            label.tag = 1000 + i;
            [self.view addSubview:label];
        }
    }
    else {
        for (int i=104; i>=97; i--) {
            k++;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(offsetX + dimSquare*(k), dimSquare*8+40+5, 10, 16)];
            label.textColor = [UIColor whiteColor];
            label.adjustsFontSizeToFitWidth = YES;
            UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
            [label setFont:boldFont];
            [label setBackgroundColor:[UIColor clearColor]];
            label.text = [NSString stringWithFormat:@"%c", i];
            label.tag = 1000 + i;
            [self.view addSubview:label];
        }
    }
}

- (void) removeLetterLabel {
    return;
    for (int i=97; i<=104; i++) {
        UIView *v = [self.view viewWithTag:1000 + i];
        if (v) {
            [v removeFromSuperview];
        }
    }
    
    
    if (letterLabel) {
        [letterLabel removeFromSuperview];
        letterLabel = nil;
    }
}

- (void) addNumberLabel {
    return;
    int k=0;
    int offsetY = 0;
    if (IS_PAD) {
        offsetY = 8;
    }
    else if (IS_IPHONE_6P) {
        offsetY = 18;
    }
    else if (IS_IPHONE_6) {
        offsetY = 21.0;
    }
    else if (IS_IPHONE_5) {
        offsetY = 25.0;
    }
    else if (IS_IPHONE_4_OR_LESS) {
        offsetY = 25.0;
    }
    if (flipped) {
        for (int i=1; i<=8; i++) {
            k++;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, offsetY + dimSquare*(k), 10, 12)];
            label.textColor = [UIColor whiteColor];
            UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
            [label setFont:boldFont];
            [label setBackgroundColor:[UIColor clearColor]];
            label.text = [NSString stringWithFormat:@"%d", i];
            label.tag = 1000 + i;
            [self.view addSubview:label];
        }
    }
    else {
        for (int i=8; i>=1; i--) {
            k++;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, offsetY + dimSquare*(k), 10, 12)];
            label.textColor = [UIColor whiteColor];
            UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
            [label setFont:boldFont];
            [label setBackgroundColor:[UIColor clearColor]];
            label.text = [NSString stringWithFormat:@"%d", i];
            label.tag = 1000 + i;
            [self.view addSubview:label];
        }
    }
}

- (void) removeNumberLabel {
    return;
    for (int i=1; i<=8; i++) {
        UIView *v = [self.view viewWithTag:1000 + i];
        if (v) {
            [v removeFromSuperview];
        }
    }
    /*
    for (int i=1; i<=8; i++) {
        for (UIView *v in [self.view subviews]) {
            if ([v isKindOfClass:[UILabel class]]) {
                UILabel *l = (UILabel *)v;
                NSString *t = [NSString stringWithFormat:@"%d", i];
                if ([l.text isEqualToString:t]) {
                    [l removeFromSuperview];
                }
            }
        }
    }*/
}

//- (void) segControlChanged:(UISegmentedControl *)segControl {
//    NSInteger index = [segControl selectedSegmentIndex];
//    if (index == 0) {
//        [boardModel setWhiteHasToMove:YES];
//    }
//    else if (index == 1) {
//        [boardModel setWhiteHasToMove:NO];
//    }
//    [self evidenziaAChiToccaMuovere];
//    [self setupPgnGame];
//    [self getNalimovResult];
//}

//- (void) setupSegControlChanged:(UISegmentedControl *)sender {
//    NSInteger index = [sender selectedSegmentIndex];
//    if (index == 0) {
//        _setupPosition = YES;
//        selectedMove = YES;
//        [colorSegControl setUserInteractionEnabled:YES];
//        [selectionPieceView setUserInteractionEnabled:YES];
//    }
//    else if (index == 1) {
//        _setupPosition = NO;
//        selectedMove = NO;
//        [colorSegControl setUserInteractionEnabled:NO];
//        [selectionPieceView setUserInteractionEnabled:NO];
//    }
//}

//- (void) clearButtonPressed:(UIButton *)sender {
//    [_tableViewData removeAllObjects];
//    [_tableView reloadData];
//    [boardModel setupInitialPosition];
//    [boardModel clearBoard];
//    [self setupInitialPosition];
//    [colorSegControl setSelectedSegmentIndex:0];
//    [self segControlChanged:colorSegControl];
//    [setupSegControl setSelectedSegmentIndex:0];
//    [self setupSegControlChanged:setupSegControl];
//    NSString *fen = [NSString stringWithFormat:@" FEN: %@", [boardModel fenNotation]];
//    [fenLabel setText:fen];
    
//    mossaEseguita = nil;
//    [self initNewPosition];
//}

//- (void) nalimovSwitchChanged:(UISwitch *)ns {
//    nalimovCheck = [ns isOn];
//    if (nalimovCheck) {
//        [self getNalimovResult];
//    }
//    else {
//        [_tableViewData removeAllObjects];
//        [_tableView reloadData];
//    }
//}



- (void) clearBoard {
    [_tableViewData removeAllObjects];
    [_tableView reloadData];
    [boardModel setupInitialPosition];
    [boardModel clearBoard];
    [self setupInitialPosition];
    [self evidenziaAChiToccaMuovere];
    //[colorSegControl setSelectedSegmentIndex:0];
    //[self segControlChanged:colorSegControl];
    //[setupSegControl setSelectedSegmentIndex:0];
    //[self setupSegControlChanged:setupSegControl];
    NSString *fen = [NSString stringWithFormat:@" FEN: %@", [boardModel fenNotation]];
    [fenLabel setText:fen];
    mossaEseguita = nil;
    [self initNewPosition];
    [selectionPieceView setUserInteractionEnabled:YES];
    _setupPosition = YES;
    selectedMove = NO;
    boardView.layer.borderColor = [UIColor clearColor].CGColor;
    boardView.layer.borderWidth = 0.0;
}

- (void) switchColor:(UIColor *)color {
    if ([color isEqual:[UIColor whiteColor]]) {
        [boardModel setWhiteHasToMove:YES];
    }
    else if ([color isEqual:[UIColor blackColor]]) {
        [boardModel setWhiteHasToMove:NO];
    }
    [self evidenziaAChiToccaMuovere];
    [self setupPgnGame];
    [self getNalimovResult];
}

- (void) moveSelection {
    
    if (![boardModel isPositionForNalimovTablebase]) {
        return;
    }
    
    _setupPosition = NO;
    selectedMove = NO;
    [selectionPieceView setUserInteractionEnabled:NO];
}


- (void) setupSelection {
    _setupPosition = YES;
    selectedMove = YES;
    //[colorSegControl setUserInteractionEnabled:YES];
    [selectionPieceView setUserInteractionEnabled:YES];
}

- (BOOL) isNalimovEnabled {
    return [boardModel isPositionForNalimovTablebase];
}


- (void) presentBoardView {
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    
    if (boardView) {
        [boardView removeFromSuperview];
        boardView.delegate = nil;
        boardView = nil;
    }
    
    dimSquare = [settingManager getSquareSizeNalimov];
    
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    [self setupInitialPosition];
    [self initBoardViewCoordinates];
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            CGFloat delta = (768.0 - ([settingManager getSquareSizePortrait]*8))/2.0;
            boardView.center = CGPointMake(delta + ([settingManager getSquareSizePortrait] * 4), [settingManager getSquareSizePortrait] * 4);
        }
        else {
            //boardView.center = CGPointMake((dimSquare*8)/2, (dimSquare*8)/2);
            //boardView.center = CGPointMake([settingManager getSquareSizeLandscape]*8/2, [settingManager getSquareSizeLandscape]*8/2);
            boardView.center = CGPointMake([settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4, [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4);
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            CGFloat delta = (320.0 - ([settingManager getSquareSizePortrait]*8))/2.0;
            boardView.center = CGPointMake(delta + ([settingManager getSquareSizePortrait] * 4), [settingManager getSquareSizePortrait] * 4);
        }
        else {
            //boardView.center = CGPointMake((dimSquare*8)/2, (dimSquare*8)/2);
            boardView.center = CGPointMake([settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4, [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4);
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            CGFloat delta = (320.0 - ([settingManager getSquareSizePortrait]*8))/2.0;
            boardView.center = CGPointMake(delta + ([settingManager getSquareSizePortrait] * 4), [settingManager getSquareSizePortrait] * 4);
        }
        else {
            //boardView.center = CGPointMake((dimSquare*8)/2, (dimSquare*8)/2);
            //boardView.center = CGPointMake([settingManager getSquareSizeLandscape]*8/2, [settingManager getSquareSizeLandscape]*8/2);
            boardView.center = CGPointMake([settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4, [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4);
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            CGFloat delta = (375.0 - ([settingManager getSquareSizePortrait]*8))/2.0;
            boardView.center = CGPointMake(delta + ([settingManager getSquareSizePortrait] * 4), [settingManager getSquareSizePortrait] * 4);
        }
        else {
            boardView.center = CGPointMake([settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4, [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            CGFloat delta = (414.0 - ([settingManager getSquareSizePortrait]*8))/2.0;
            boardView.center = CGPointMake(delta + ([settingManager getSquareSizePortrait] * 4), [settingManager getSquareSizePortrait] * 4);
        }
        else {
            boardView.center = CGPointMake([settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4, [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4);
        }
    }

    
    //[boardView addGestureRecognizer:boardViewTapGestureRecognizer];
    [boardView addGestureRecognizer:boardViewLongPressGestureRecognizer];
    
    //if (![_pgnGame isEditMode]) {
    //    [boardView addLeftAndRightSwipeGestureRecognizer];
    //}
    
    [boardView setFrame:CGRectMake(boardView.frame.origin.x, boardView.frame.origin.y, dimSquare*8, dimSquare*8)];
    
    
    
    if ([settingManager boardWithEdge]) {
        UIView *borderView = [self getBoardViewWithEdge];
        [self.view addSubview:borderView];
    }
    
    
    [boardView managePawnStructure];
    [self.view addSubview:boardView];
    
    [_gameWebView removeFromSuperview];
    //[self gestioneEngineView];
}


- (UIView *) getBoardViewWithEdge {
    CGRect border;
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, 96.0*8, 96.0*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, 72.0*8, 72.0*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, 48.0*8, 48.0*8);
            }
        }
        else if (IS_LANDSCAPE) {
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, 82.5*8, 82.5*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, 61.875*8, 61.875*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, 41.25*8, 41.25*8);
            }
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, 40.0*8, 40.0*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, 30.0*8, 30.0*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, 20.0*8, 20.0*8);
            }
        }
        else if (IS_LANDSCAPE) {
            CGFloat tempSize = 0.0;
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                tempSize = 32.0;
            }
            else {
                tempSize = 29.5;
            }
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, 40.0*8, 40.0*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, 30.0*8, 30.0*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, 20.0*8, 20.0*8);
            }
        }
        else if (IS_LANDSCAPE) {
            CGFloat tempSize = 0.0;
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                tempSize = 32.0;
            }
            else {
                tempSize = 29.5;
            }
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, 46.875*8, 46.875*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, 36.875*8, 36.875*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, 26.875*8, 26.875*8);
            }
        }
        else if (IS_LANDSCAPE) {
            CGFloat tempSize = 38.875;
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, 51.75*8, 51.75*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, 41.75*8, 41.75*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, 31.75*8, 31.75*8);
            }
        }
        else if (IS_LANDSCAPE) {
            CGFloat tempSize = 40.75;
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
        }
    }

    
    //UIView *borderView = [[UIView alloc] initWithFrame:border];
    //borderView.tag = 2000;
    //borderView.center = boardView.center;
    //[self setBorderViewCoordinates:borderView];
    //return borderView;
    
    UIImageView *borderImageView = [[UIImageView alloc] initWithImage:[self getEdge:border]];
    borderImageView.tag = 2000;
    borderImageView.center = boardView.center;
    return borderImageView;
}


- (UIView *) getBoardViewWithEdge:(UIDeviceOrientation)deviceOrientation {
    CGRect border;
    
    if (IS_PAD) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, 96.0*8, 96.0*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, 72.0*8, 72.0*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, 48.0*8, 48.0*8);
            }
        }
        else if ((deviceOrientation == UIDeviceOrientationLandscapeLeft) || (deviceOrientation == UIDeviceOrientationLandscapeRight)) {
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, 82.5*8, 82.5*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, 61.875*8, 61.875*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, 41.25*8, 41.25*8);
            }
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, 40.0*8, 40.0*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, 30.0*8, 30.0*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, 20.0*8, 20.0*8);
            }
        }
        else if ((deviceOrientation == UIDeviceOrientationLandscapeLeft) || (deviceOrientation == UIDeviceOrientationLandscapeRight)) {
            CGFloat tempSize = 0.0;
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                tempSize = 32.0;
            }
            else {
                tempSize = 29.5;
            }
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, 40.0*8, 40.0*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, 30.0*8, 30.0*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, 20.0*8, 20.0*8);
            }
        }
        else if ((deviceOrientation == UIDeviceOrientationLandscapeLeft) || (deviceOrientation == UIDeviceOrientationLandscapeRight)) {
            CGFloat tempSize = 0.0;
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                tempSize = 32.0;
            }
            else {
                tempSize = 29.5;
            }
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, 46.875*8, 46.875*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, 36.875*8, 36.875*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, 26.875*8, 26.875*8);
            }
        }
        else if ((deviceOrientation == UIDeviceOrientationLandscapeLeft) || (deviceOrientation == UIDeviceOrientationLandscapeRight)) {
            CGFloat tempSize = 38.875;
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
        }
    }
    else if (IS_IPHONE_6P) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, 51.75*8, 51.75*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, 41.75*8, 41.75*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, 31.75*8, 31.75*8);
            }
        }
        else if ((deviceOrientation == UIDeviceOrientationLandscapeLeft) || (deviceOrientation == UIDeviceOrientationLandscapeRight)) {
            CGFloat tempSize = 40.75;
            if ([settingManager boardSize] == BIG) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == MEDIUM) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
            else if ([settingManager boardSize] == SMALL) {
                border = CGRectMake(0, 0, tempSize*8, tempSize*8);
            }
        }
    }
    
    //UIView *borderView = [[UIView alloc] initWithFrame:border];
    //borderView.tag = 2000;
    //borderView.center = boardView.center;
    //[self setBorderViewCoordinates:borderView];
    
    UIImageView *borderImageView = [[UIImageView alloc] initWithImage:[self getEdge:border]];
    borderImageView.tag = 2000;
    borderImageView.center = boardView.center;
    return borderImageView;
    
    
    //return borderView;
}

- (UIImage *) getEdge:(CGRect)border {
    CGSize destinationSize = border.size;
    UIImage *originalImage = nil;
    if (flipped) {
        originalImage = [UIImage imageNamed:@"EdgeFlipped"];
        //originalImage = [UIImage imageNamed:@"Edge"];
    }
    else {
        //originalImage = [UIImage imageNamed:@"EdgeFlipped"];
        originalImage = [UIImage imageNamed:@"EdgeNoFlipped"];
    }
    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect:border];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (void) clearEdge {
    if ([settingManager boardWithEdge]) {
        UIImageView *borderView = (UIImageView *)[self.view viewWithTag:2000];
        if (borderView) {
            [borderView setFrame:CGRectZero];
        }
    }
}

- (void) removeEdge {
    if ([settingManager boardWithEdge]) {
        UIImageView *borderView = (UIImageView *)[self.view viewWithTag:2000];
        if (borderView) {
            [borderView removeFromSuperview];
            borderView = nil;
        }
    }
}

- (void) restoreEdge {
    if ([settingManager boardWithEdge]) {
        UIView *borderView = [self getBoardViewWithEdge];
        [self.view addSubview:borderView];
    }
}

- (void) setBorderViewCoordinates:(UIView *)borderView {
    borderView.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(1, 20, 10, 10)];
    NSLog(@"LABEL CGRECT = %f    %f", label.frame.size.width, label.frame.size.height);
    [label setText:@"8"];
    //label.center = CGPointMake(3, 25);
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor blackColor]];
    [borderView addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(20, 307, 10, 10)];
    [label setText:@"a"];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor blackColor]];
    [borderView addSubview:label];
}

- (void) removeBoardViewWithEdge {
    UIView *borderView = [self.view viewWithTag:2000];
    if (borderView) {
        [borderView removeFromSuperview];
        borderView = nil;
        NSLog(@"Ho rimosso BorderView");
    }
}

- (void) presentGameWebView {
    //[_gameWebView removeFromSuperview];
    //NSLog(@"Dimensioni r: X=%f    Y=%f      W=%f       H=%f", r.origin.x, r.origin.y, r.size.width, r.size.height);
    [_gameWebView setFrame:[settingManager getNalimovWebViewFrame]];
    //NSLog(@"Dimensioni GWV: X=%f    Y=%f      W=%f       H=%f", _gameWebView.frame.origin.x, _gameWebView.frame.origin.y, _gameWebView.frame.size.width, _gameWebView.frame.size.height);
    [_gameWebView refresh];
    [self.view addSubview:_gameWebView];
    
    //NSLog(@"PresentGameWebView:%@", _gameWebView);
}

- (void) presentEngineView {
    
    if (IsChessStudioLight & !startFenPosition) {
        return;
    }
    
    if (_setupPosition) {
        return;
    }
    
    if ([settingManager isEngineViewClosed]) {
        return;
    }
    
    if (engineView) {
        [engineView removeFromSuperview];
        engineView = nil;
    }
    
    
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            [self presentEngineViewPadPortrait];
        }
        else {
            [self presentEngineViewPadLandscape];
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            [self presentEngineViewPhonePortrait];
        }
        else {
            [self presentEngineViewPhoneLandscape];
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            [self presentEngineViewPhone5Portrait];
        }
        else {
            [self presentEngineViewPhone5Landscape];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            [self presentEngineViewPhone6Portrait];
        }
        else {
            [self presentEngineViewPhone6Landscape];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            [self presentEngineViewPhone6PPortrait];
        }
        else {
            [self presentEngineViewPhone6PLandscape];
        }
    }
}

- (void) presentEngineViewPadPortrait {
    NSLog(@"Eseguo PresentEngineView");
    engineView = [[UIView alloc] initWithFrame:[UtilToView getPadPortraitEngineViewFrame]];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(2.0, 4.0, 50.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(65, 0.0, 703.0, 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 13.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 19.0, 703.0, 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 13.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    [engineView addSubview: searchStatsView];
}

- (void) presentEngineViewPadLandscape {
    engineView = [[UIView alloc] initWithFrame:CGRectMake(660.0, 622.0, 364.0, 38.0)];
    [engineView setFrame:CGRectMake(_gameWebView.frame.origin.x, _gameWebView.frame.size.height, _gameWebView.frame.size.width, 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(2.0, 4.0, 50.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 0.0, 299.0, 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 13.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 19.0, 299.0, 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 13.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    [engineView addSubview: searchStatsView];
}

- (void) presentEngineViewPhone5Portrait {
    engineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 320.0 + 140.0 - 38.0, 320.0, 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //button.frame = CGRectMake(2.0, 4.0, 50.0, 30.0);
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    //[button sizeToFit];
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 0.0, 320.0 - 55.0, 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 19.0, 320.0 - 55.0, 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
}

- (void) presentEngineViewPhone5Landscape {
    
    CGFloat squareSize = [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft];
    
    engineView = [[UIView alloc] initWithFrame:CGRectMake(squareSize*8, (squareSize*8 - 38.0), (568.0 - squareSize*8), 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    if (IS_ITALIANO) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
    }
    else {
        [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, (568.0 - squareSize*8 - 40), 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 19.0, (568.0 - squareSize*8 - 40), 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
}

- (void) presentEngineViewPhonePortrait {
    if ([settingManager boardSize] == BIG) {
        engineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 320.0 + 52.0 - 19.0, 320.0, 19.0)];
        [engineView setBackgroundColor:[UIColor whiteColor]];
        engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        engineView.layer.borderWidth = 1.0;
        //[self.view addSubview:engineView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(1.0, 2.0, 27.0, 17.0);
        
        [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        if ([self isEngineRunning]) {
            [button setTitle:NSLocalizedString(@"STOP_ENGINE_PHONE", nil) forState:UIControlStateNormal];
        }
        else {
            [button setTitle:NSLocalizedString(@"START_ENGINE_PHONE", nil) forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        if (IS_ITALIANO) {
            [button.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
        }
        else {
            [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
        }
        
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [engineView addSubview:button];
        
        analysisView = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 0.0, 320.0 - 30.0, 19.0)];
        [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
        [analysisView setBackgroundColor: [UIColor lightTextColor]];
        //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        //analysisView.layer.borderWidth = 1.0;
        [engineView addSubview:analysisView];
        
        [self.view addSubview:engineView];
    }
    else {
        engineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 320.0 + 52.0 - 38.0, 320.0, 38.0)];
        [engineView setBackgroundColor:[UIColor whiteColor]];
        engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        engineView.layer.borderWidth = 1.0;
        //[self.view addSubview:engineView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(1.0, 2.0, 40.0, 30.0);
        
        [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        if ([self isEngineRunning]) {
            [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
        }
        else {
            [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        if (IS_ITALIANO) {
            [button.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
        }
        else {
            [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
        }
        
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [engineView addSubview:button];
        
        analysisView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, (320.0 - 40), 19.0)];
        [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
        [analysisView setBackgroundColor: [UIColor lightTextColor]];
        //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        //analysisView.layer.borderWidth = 1.0;
        [engineView addSubview:analysisView];
        
        searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 19.0, (320.0 - 40), 19.0)];
        [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
        [searchStatsView setBackgroundColor: [UIColor whiteColor]];
        //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        //searchStatsView.layer.borderWidth = 1.0;
        [engineView addSubview: searchStatsView];
        
        [self.view addSubview:engineView];
    }

}

- (void) presentEngineViewPhoneLandscape {
    
    //CGFloat squareSize = [settingManager getSquareSize];
    CGFloat squareSize = [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft];
    
    engineView = [[UIView alloc] initWithFrame:CGRectMake(squareSize*8, (squareSize*8 - 38.0), (480.0 - squareSize*8), 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    if (IS_ITALIANO) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
    }
    else {
        [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, (480.0 - squareSize*8 - 40), 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 19.0, (480.0 - squareSize*8 - 40), 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
}

- (void) presentEngineViewPhone6Portrait {
    engineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 375.0 + 184.0 - 38.0, 375.0, 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //button.frame = CGRectMake(2.0, 4.0, 50.0, 30.0);
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    //[button sizeToFit];
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 0.0, 375.0 - 55.0, 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 19.0, 375.0 - 55.0, 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
}

- (void) presentEngineViewPhone6Landscape {
    CGFloat squareSize = [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft];
    
    engineView = [[UIView alloc] initWithFrame:CGRectMake(squareSize*8, (squareSize*8 - 38.0), (667.0 - squareSize*8), 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    if (IS_ITALIANO) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
    }
    else {
        [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, (667.0 - squareSize*8 - 40), 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 19.0, (667.0 - squareSize*8 - 40), 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];

}

- (void) presentEngineViewPhone6PPortrait {
    engineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 414.0 + 214.0 - 38.0, 414.0, 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //button.frame = CGRectMake(2.0, 4.0, 50.0, 30.0);
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    //[button sizeToFit];
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 0.0, 414.0 - 55.0, 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 19.0, 414.0 - 55.0, 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
}

- (void) presentEngineViewPhone6PLandscape {
    CGFloat squareSize = [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft];
    
    engineView = [[UIView alloc] initWithFrame:CGRectMake(squareSize*8, (squareSize*8 - 38.0), (736.0 - squareSize*8), 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    if (IS_ITALIANO) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
    }
    else {
        [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, (736.0 - squareSize*8 - 40), 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 19.0, (736.0 - squareSize*8 - 40), 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
}

- (void) replaceBoard {
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    
    dimSquare = [settingManager getSquareSize];
    //squares = [settingManager squares];
    
    
    //NSLog(@"DIMSQUARE = %f", dimSquare);
    
    if (boardView) {
        [boardView removeFromSuperview];
        boardView.delegate = nil;
        boardView = nil;
    }
    //boardView = [[BoardView alloc] initWithSquareSizeAndSquareType:dimSquare :squares];
    boardView = [[BoardView alloc] initWithSettingManager];
    boardView.delegate = self;
    [self setupInitialPosition];
    [self initBoardViewCoordinates];
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    //if (flipped) {
        //[boardView flipPosition];
    //}
    
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            //boardView.center = CGPointMake((self.view.center.x), (dimSquare*8)/2);
            //boardView.center = CGPointMake(self.view.center.x, ([settingManager getSquareSizePortrait] * 8)/2);
            CGFloat delta = (768.0 - ([settingManager getSquareSizePortrait]*8))/2.0;
            boardView.center = CGPointMake(delta + ([settingManager getSquareSizePortrait] * 4), [settingManager getSquareSizePortrait] * 4);
        }
        else {
            //boardView.center = CGPointMake((dimSquare*8)/2, (dimSquare*8)/2);
            //boardView.center = CGPointMake([settingManager getSquareSizeLandscape]*4, [settingManager getSquareSizeLandscape]*4);
            boardView.center = CGPointMake([settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4, [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4);
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            //boardView.center = CGPointMake((self.view.center.x), (dimSquare*8)/2);
            boardView.center = CGPointMake((self.view.center.x), ([settingManager getSquareSizePortrait]*8)/2);
        }
        else {
            //boardView.center = CGPointMake((dimSquare*8)/2, (dimSquare*8)/2);
            boardView.center = CGPointMake([settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4, [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4);
        }
    }
    else if (IS_PHONE) {
        if (IS_PORTRAIT) {
            //boardView.center = CGPointMake((self.view.center.x), (dimSquare*8)/2);
            boardView.center = CGPointMake((self.view.center.x), ([settingManager getSquareSizePortrait]*8)/2);
        }
        else {
            boardView.center = CGPointMake((dimSquare*8)/2, (dimSquare*8)/2);
        }
    }
    
    [boardView setFrame:CGRectMake(boardView.frame.origin.x, boardView.frame.origin.y, 2.0, 2.0)];

    //[self.view addSubview:boardView];
    
    [UIView animateWithDuration:0.0f animations:^{
        
        if (flipped) {
            [boardView flipPosition];
        }
        
        [boardView setFrame:CGRectMake(boardView.frame.origin.x, boardView.frame.origin.y, dimSquare*8, dimSquare*8)];
        //[_gameWebView setFrame:CGRectMake(0.0, dimSquare*8, 768.0, (768.0 - dimSquare*8)+130.0)];
        //[self manageGameWebViewFrame];
        //[self gestioneGameWebView];
        [self gestioneEngineView];
        //[self manageEngineViewFrame];
    }  completion:^(BOOL finished){
        //[boardView addGestureRecognizer:boardViewLongPressGestureRecognizer];
        //[self gestioneEngineView];
        
        [boardView addGestureRecognizer:boardViewLongPressGestureRecognizer];
        
        //if (![_pgnGame isEditMode]) {
        //    [boardView addLeftAndRightSwipeGestureRecognizer];
        //}
        
        //[boardView addGestureRecognizer:boardViewTapGestureRecognizer];
    }];
    
    if ([settingManager boardWithEdge]) {
        UIView *borderView = [self getBoardViewWithEdge];
        [self.view addSubview:borderView];
    }
    
    [boardView managePawnStructure];
    
    
    if ([_pgnGame isEditMode]) {
        [boardView removeLeftAndRightSwipeGestureRecognizer];
    }
    else {
        [boardView addLeftAndRightSwipeGestureRecognizer];
    }
    
    
    
    [self.view addSubview:boardView];
    
}


- (void) manageGameWebViewFrame {
    
    //NSLog(@"Sto eseguendo ManageGameWebViewFrame");
    
    //dimSquare = [settingManager getSquareSizeNalimov];
    
    //NSLog(@"ORA SQUARE_SIZE = %f", dimSquare);
    
    [_gameWebView setFrame:[settingManager getNalimovWebViewFrame]];
    
    //NSLog(@"###################################################");
    //NSLog(@"Dimensioni web View dopo manageGameWebViewFrame");
    //NSLog(@"Origine   X=%f      Y=%f", _gameWebView.frame.origin.x, _gameWebView.frame.origin.y);
    //NSLog(@"Dimensioni    Larghezza=%f    Altezza = %f", _gameWebView.frame.size.width, _gameWebView.frame.size.height);
    //NSLog(@"###################################################");
    
}

- (void) rightSwipeHandle {
    [self avantiButtonPressed:nil];
}

- (void) leftSwipeHandle {
    [self indietroButtonPressed:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    
    //NSLog(@"Nalimov view will appear");
    
    [super viewWillAppear:animated];
    //[boardModel printPosition];
    //[self presentBoardView];
    [self presentNalimovBoardView];
    //[_gameWebView removeFromSuperview];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //NSLog(@"Nalimov view did appear");
    
    [self presentGameWebView];
    //[self presentEngineView];
    
    /*
    if (_setupPosition) {
        if (setupPositionView) {
            if (IS_PAD) {
                return;
            }
            [setupPositionView removeFromSuperview];
            setupPositionView = nil;
        }
        //setupPositionView = [[SetupPositionView alloc] initWithSquareSizeAndSquareTypeAndPieceType:[settingManager getSquareSize] :[settingManager squares] :[settingManager getPieceTypeToLoad]];
        setupPositionView = [[SetupPositionView alloc] initWithSettingManager];
        setupPositionView.delegate = self;
        //[self.view addSubview:setupPositionView];
        //[self gestisciToolbarInSetupPosition];
    }
    */
    /*
    if ([gameSetting forwardAnimated] && !IS_PAD) {
        [self replayGameForward:nil finished:NO context:0];
    }
    else if ([gameSetting backAnimated] && !IS_PAD) {
        [self replayGameBack:nil finished:NO context:0];
    }
    */
    
    /*
    if (![_pgnGame isEditMode]) {
        [boardView addLeftAndRightSwipeGestureRecognizer];
    }
    */
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (actionSheetMenu) {
        [actionSheetMenu dismissWithClickedButtonIndex:-1 animated:YES];
        actionSheetMenu = nil;
    }
    if (actionSheetMenuGame) {
        [actionSheetMenuGame dismissWithClickedButtonIndex:-1 animated:YES];
        actionSheetMenuGame = nil;
    }
    //[_delegate saveGame:[boardModel listaMosse]];
    //[self dismissModalViewControllerAnimated:YES];
    //if (![self.presentedViewController isBeingDismissed]) {
    //    [self dismissViewControllerAnimated:YES completion:^{}];
    //}
}


- (void) gestioneInterfacciaGrafica {
    [self gestioneGameWebView];
    [self gestioneEngineView];
    //[self gestioneOpeningBookView];
}


- (void) gestioneGameWebView {
    NSLog(@"Eseguo gestioneGameWebView");
    [_gameWebView setFrame:[settingManager getNalimovWebViewFrame]];
    [_gameWebView refresh];
    
    //NSLog(@"***************************************************");
    //NSLog(@"Dimensioni web View dopo gestioneGameWebView");
    //NSLog(@"Origine   X=%f      Y=%f", _gameWebView.frame.origin.x, _gameWebView.frame.origin.y);
    //NSLog(@"Dimensioni    Larghezza=%f    Altezza = %f", _gameWebView.frame.size.width, _gameWebView.frame.size.height);
    //NSLog(@"***************************************************");
}

- (void) gestioneEngineView {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            [self openEngineViewPadPortrait];
        }
        else {
            [self openEngineViewPadLandscape];
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            [self openEngineViewPhonePortrait];
        }
        else {
            [self openEngineViewPhoneLandscape];
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            [self openEngineViewPhone5Portrait];
        }
        else {
            [self openEngineViewPhone5Landscape];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            [self openEngineViewPhone6Portrait];
        }
        else {
            [self openEngineViewPhone6Landscape];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            [self openEngineViewPhone6PPortrait];
        }
        else {
            [self openEngineViewPhone6PLandscape];
        }
    }
}

- (void) modifyPiecesType {
    pieceType = [settingManager getPieceTypeToLoad];
    [boardView modifyPieces:@""];
    //if (_setupPosition && setupPositionView) {
    //    [setupPositionView modificaTipoPezzi:@""];
    //}
    if (selectionPieceView) {
        //[selectionPieceView removeFromSuperview];
        //selectionPieceView = [[SelectionPieceView alloc] initForNalimov];
        //selectionPieceView.delegate = self;
        //[self.view addSubview:selectionPieceView];
        [selectionPieceView modificaTipoPezzi:@""];
        selectionPieceView.center = CGPointMake(boardView.center.x, dimSquare*9 + 10);
    }
}

- (void) modifyCoordinates {
    
    UIView *borderView = [self.view viewWithTag:2000];
    if (borderView) {
        //[borderView removeFromSuperview];
        //borderView = nil;
        //[self replaceBoard];
    }
    
    if ([[settingManager coordinate] isEqualToString:NSLocalizedString(@"NO_COORDINATES", nil)]) {
        //[boardView setCoordinates:nil];
        [boardView setNalimovCoordinates:nil];
    }
    else if ([[settingManager coordinate] isEqualToString: NSLocalizedString(@"ALGEBRAIC", nil)]) {
        //[boardView setCoordinates:nil];
        //[boardView setCoordinates:[boardModel algebricSquares]];
        [boardView setNalimovCoordinates:nil];
        [boardView setNalimovCoordinates:[boardModel algebricSquares]];
    }
    else if ([[settingManager coordinate] isEqualToString:NSLocalizedString(@"NUMERIC", nil)]) {
        //[boardView setCoordinates:nil];
        //[boardView setCoordinates:[boardModel numericSquares]];
        [boardView setNalimovCoordinates:nil];
        [boardView setNalimovCoordinates:[boardModel numericSquares]];
    }
    else if ([[settingManager coordinate] isEqualToString:NSLocalizedString(@"DEVELOPMENT", nil)]) {
        //[boardView setCoordinates:nil];
        //[boardView setCoordinates];
        [boardView setNalimovCoordinates:nil];
        [boardView setNalimovCoordinates];
    }
    else if ([[settingManager coordinate] isEqualToString:NSLocalizedString(@"EDGE", nil)]) {
        [boardView setCoordinates:nil];
        //[boardView setNalimovCoordinates:nil];
        //[self replaceBoard];
        
        UIAlertView *noEdgeAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EDGE_COORDINATES_TITLE", nil) message:NSLocalizedString(@"EDGE_COORDINATES_MSG", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noEdgeAlertView show];
    }
}

- (void) modifyBoardSquares {
    [boardView setTipoSquare:@""];
    //if (_setupPosition && setupPositionView) {
    //    [setupPositionView modificaTipoSquare:@""];
    //}
    if (selectionPieceView) {
        [selectionPieceView modificaTipoSquare:@""];
        selectionPieceView.center = CGPointMake(boardView.center.x, dimSquare*9 + 10);
    }
    if (controlNalimovView) {
        [controlNalimovView modificaTipoSquare:@""];
        controlNalimovView.center = CGPointMake(_tableView.center.x, dimSquare*9 + 10);
    }
}

- (void) modifyMoveNotation {
    //[_gameWebView setNotation:[settingManager notation]];
    [self aggiornaWebView];
}

- (void) modifyBoardSize {
    [self replaceBoard];
}

- (void) modifyVistaMotore {
    if ([settingManager isEngineViewOpen]) {
        NSLog(@"Devo aprire Vista Motore");
        [options setShowAnalysis:YES];
        if (IS_PAD) {
            if (IS_PORTRAIT) {
                [self openEngineViewPadPortrait];
            }
            else {
                [self openEngineViewPadLandscape];
            }
        }
        else if (IS_IPHONE_5) {
            [self openEngineViewPhone5Portrait];
        }
        else if (IS_PHONE) {
            [self openEngineViewPhonePortrait];
        }
    }
    else {
        NSLog(@"Devo chiudere Vista Motore");
        [engineView removeFromSuperview];
        [self manageGameWebViewFrame];
        [options setShowAnalysis:NO];
        engineView = nil;
    }
}

- (void) modifyShowBookMoves {
    [self aggiornaWebView];
}

- (void) modifyShowEco {
    [self aggiornaWebView];
}

- (BOOL) isEngineViewOpened {
    if ([settingManager isEngineViewOpen]) {
        return YES;
    }
    else return NO;
    if (engineView) {
        return YES;
    }
    return NO;
}

- (BOOL) isEngineRunning {
    if (engineController) {
        if (engineController.engineThreadIsRunning) {
            return YES;
        }
    }
    return NO;
}

- (NSString *) getStartFenPosition {
    return startFenPosition;
}

//Fine Implementazione metodi delegate di SettingsTableViewController


- (void) initBoardViewCoordinates {

    if ([[settingManager coordinate] isEqualToString:NSLocalizedString(@"NO_COORDINATES", nil)]) {
        [boardView setNalimovCoordinates:nil];
    }
    else if ([[settingManager coordinate] isEqualToString:NSLocalizedString(@"ALGEBRAIC", nil)]) {
        [boardView setNalimovCoordinates:[boardModel algebricSquares]];
    }
    else if ([[settingManager coordinate] isEqualToString:NSLocalizedString(@"NUMERIC", nil)]) {
        [boardView setNalimovCoordinates:[boardModel numericSquares]];
    }
    else if ([[settingManager coordinate] isEqualToString:NSLocalizedString(@"DEVELOPMENT", nil)]) {
        [boardView setNalimovCoordinates];
    }
    else if ([[settingManager coordinate] isEqualToString:NSLocalizedString(@"EDGE", nil)]) {
        [boardView setNalimovCoordinates:nil];
        [self removeBoardViewWithEdge];
    }
}

- (void) aggiornaOrientamentoDaSettings {
    [self aggiornaOrientamento];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)tapActionOnWebView:(UITapGestureRecognizer *)sender {

    //NSLog(@"Tap Gesture Ok");
    
    //int scrollPosition = [[_gameWebView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
    //int moveTop = [[_gameWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"mossaevidenziata\").offsetTop;"] intValue];
    //int parentHeight = [[_gameWebView stringByEvaluatingJavaScriptFromString:@"window.innerheight"] intValue];
    //NSLog(@"ScrollPosition= %d --  sizePage = %d --- parentHeight = %d", scrollPosition, moveTop, parentHeight);
    //int scrollPos = moveTop - (parentHeight/2);
    //NSLog(@"ScrollPos:%d", scrollPos);
    
    //NSString *javascript = [NSString stringWithFormat:@"window.scrollBy(0, %d);", scrollPos];
    //[_gameWebView stringByEvaluatingJavaScriptFromString:javascript];
    //[_gameWebView loadHTMLString:@"" baseURL:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if ([gameSetting backAnimated] || [gameSetting forwardAnimated]) {
        [self pauseAnimation];
    }
    
    [self clearEdge];
    [self removeNavigationTitleGestureRecognizer];
    
    if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        dimSquare = [settingManager getSquareSizeNalimovLandscape];
        [self setupNalimovPad:UIDeviceOrientationLandscapeRight];
    }
    else if ((toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)||(toInterfaceOrientation == UIInterfaceOrientationPortrait)) {
        dimSquare = [settingManager getSquareSizeNalimovPortrait];
        [self setupNalimovPad:UIDeviceOrientationPortrait];
    }
    
    /*
    if (IS_PAD) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = [settingManager getSquareSizeNalimovLandscape];
            [self setupNalimovPad:UIDeviceOrientationLandscapeRight];
        }
        else if ((toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)||(toInterfaceOrientation == UIInterfaceOrientationPortrait)) {
            dimSquare = [settingManager getSquareSizeNalimovPortrait];
            [self setupNalimovPad:UIDeviceOrientationPortrait];
        }
    }
    else if (IS_IPHONE_6P) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = [settingManager getSquareSizeNalimovLandscape];
            [self setupNalimovPad:UIDeviceOrientationLandscapeRight];
        }
        else {
            dimSquare = [settingManager getSquareSizeNalimovPortrait];
            [self setupNalimovPad:UIDeviceOrientationPortrait];
        }
    }
    else if (IS_IPHONE_6) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = [settingManager getSquareSizeNalimovLandscape];
            [self setupNalimovPad:UIDeviceOrientationLandscapeRight];
        }
        else {
            dimSquare = [settingManager getSquareSizeNalimovPortrait];
            [self setupNalimovPad:UIDeviceOrientationPortrait];
        }
    }
    else if (IS_IPHONE_5) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = [settingManager getSquareSizeNalimovLandscape];
            [self setupNalimovPad:UIDeviceOrientationLandscapeRight];
        }
        else {
            dimSquare = [settingManager getSquareSizeNalimovPortrait];
            [self setupNalimovPad:UIDeviceOrientationPortrait];
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            dimSquare = [settingManager getSquareSizeNalimovLandscape];
            [self setupNalimovPad:UIDeviceOrientationLandscapeRight];
        }
        else {
            dimSquare = [settingManager getSquareSizeNalimovPortrait];
            [self setupNalimovPad:UIDeviceOrientationPortrait];
        }
    }*/
}


- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //NSLog(@"Sto eseguendo will animate");
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    //[self setupInitialPosition];
    //[self initBoardViewCoordinates];
    [self setupNavigationTitleGestureRecognizer];
    
    [self manageGameWebViewFrame];
    
    /*
    if (IS_PAD) {
        if ((fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            [self manageGameWebViewFrame];
            //if (IS_PORTRAIT) {
                //[self gestisciEngineViewPortrait];
            //}
            //else {
                //[self gestisciEngineViewLandscape];
            //}
        }
        else if ((fromInterfaceOrientation == UIInterfaceOrientationPortrait) || (fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
            //NSLog(@"Considero from = PORTRAIT ma lo gestico come PORTRAIT");
            [self manageGameWebViewFrame];
            //if (IS_PORTRAIT) {
            //    [self gestisciEngineViewPortrait];
            //}
            //else {
            //    [self gestisciEngineViewLandscape];
            //}
        }
        else {
            //NSLog(@"Considero from = PORTRAIT ma lo gestico come landscape");
            [self manageGameWebViewFrame];
            //[self gestisciEngineViewLandscape];
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if ((fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            //[self manageGameWebViewFrame];
            [self gestioneGameWebView];
            //[self gestioneEngineView];
        }
        else {
            //[self manageGameWebViewFrame];
            [self gestioneGameWebView];
            //[self gestisciEngineViewPhoneLandscape];
            //[self gestioneEngineView];
        }
    }
    else if (IS_IPHONE_5) {
        if ((fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            //[self manageGameWebViewFrame];
            //[self openEngineViewPhone5Portrait];
            [self gestioneGameWebView];
            //[self gestioneEngineView];
        }
        else {
            //[self manageGameWebViewFrame];
            //[self openEngineViewPhone5Landscape];
            [self gestioneGameWebView];
            //[self gestioneEngineView];
        }
    }
    else if (IS_IPHONE_6) {
        if ((fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            //[self manageGameWebViewFrame];
            //[self openEngineViewPhone5Portrait];
            [self gestioneGameWebView];
            //[self gestioneEngineView];
        }
        else {
            //[self manageGameWebViewFrame];
            //[self openEngineViewPhone5Landscape];
            [self gestioneGameWebView];
            //[self gestioneEngineView];
        }
    }
    else if (IS_IPHONE_6P) {
        if ((fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
            //[self manageGameWebViewFrame];
            //[self openEngineViewPhone5Portrait];
            [self gestioneGameWebView];
            //[self gestioneEngineView];
        }
        else {
            //[self manageGameWebViewFrame];
            //[self openEngineViewPhone5Landscape];
            [self gestioneGameWebView];
            //[self gestioneEngineView];
        }
    }*/
    
    [boardView managePawnStructure];
    
    if ([gameSetting backAnimated] || [gameSetting forwardAnimated]) {
        [self startAnimation];
    }
}

- (void) gestisciToolbarInSetupPosition {
    if (_setupPosition) {
        if (IS_PORTRAIT) {
            if (IS_IPHONE_4_OR_LESS || (IS_PAD)) {
                self.navigationController.toolbarHidden = NO;
            }
            else {
                self.navigationController.toolbarHidden = NO;
            }
        }
        else {
            self.navigationController.toolbarHidden = NO;
        }
    }
    else {
        self.navigationController.toolbarHidden = NO;
    }
}


- (void) gestisciEngineViewPhonePortrait {
    if (engineView) {
        //[engineView setFrame:CGRectMake(_gameWebView.frame.origin.x, _gameWebView.frame.size.height + boardView.frame.size.height, _gameWebView.frame.size.width, 19.0)];
    }
}

- (void) gestisciEngineViewPhoneLandscape {
    if (engineView) {
        [engineView setFrame:CGRectMake(_gameWebView.frame.origin.x, _gameWebView.frame.size.height, _gameWebView.frame.size.width, 38.0)];
    }
}

- (void) gestisciPadCheRuotaToPortrait {
    
    NSLog(@"Gestisco PAD che ruota to PORTRAIT");
    
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    
    [boardView removeFromSuperview];
    boardView = nil;
    //boardView = [[BoardView alloc] initWithSquareSizeAndSquareType:dimSquare :squares];
    //boardView = [[BoardView alloc] initWithSettingManager];
    
    dimSquare = [settingManager getSquareSizeNalimovPortrait];
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    //[self setupInitialPosition];
    //[self initBoardViewCoordinates];
    boardView.delegate = self;
    
    [selectionPieceView removeFromSuperview];
    //selectionPieceView.delegate = nil;
    //selectionPieceView = nil;
    [controlNalimovView removeFromSuperview];
    //controlNalimovView.delegate = nil;
    //controlNalimovView = nil;
    [_tableView removeFromSuperview];
    
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    //CGFloat delta = (768.0 - ([settingManager getSquareSizePortrait]*8))/2.0;
    
    //boardView.center = CGPointMake(delta + ([settingManager getSquareSizePortrait] * 4), [settingManager getSquareSizePortrait] * 4);
    boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
    
    //NSLog(@"TO PORTRAIT:%f - %f      SIZE:%f", boardView.center.x, boardView.center.y, dimSquare);
    
    if ([settingManager boardWithEdge]) {
        UIView *borderView = [self getBoardViewWithEdge:UIDeviceOrientationPortrait];
        [self.view addSubview:borderView];
    }
    
    [self.view addSubview:boardView];
    
    _tableView.frame = CGRectMake(dimSquare*8+40, 0, 200, dimSquare*8);
    fenLabel.frame = CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 25);
    
    //selectionPieceView = [[SelectionPieceView alloc] initWithSquareSize:dimSquare];
    //selectionPieceView.delegate = self;
    selectionPieceView.center = CGPointMake(boardView.center.x, dimSquare*9 + 10);
    [self.view addSubview:selectionPieceView];
    
    //controlNalimovView = [[ControlNalimovView alloc] initWithSquareSize:dimSquare];
    //controlNalimovView.delegate = self;
    controlNalimovView.center = CGPointMake(_tableView.center.x, dimSquare*9 + 10);
    [self.view addSubview:controlNalimovView];
    [self.view addSubview:_tableView];
    

    
    [boardView addGestureRecognizer:boardViewLongPressGestureRecognizer];

    if ([_pgnGame isEditMode]) {
        [boardView removeLeftAndRightSwipeGestureRecognizer];
    }
    else {
        [boardView addLeftAndRightSwipeGestureRecognizer];
    }
    
    //[_gameWebView setFrame:CGRectMake(0, 768, 768, 148)];
    //[_gameWebView refresh];
}

- (void) gestisciPadCheRuotaToLandscape {
    
    NSLog(@"Gestisco PAD che sta ruotando in LANDSCAPE");
    
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    
    [boardView removeFromSuperview];
    boardView = nil;
    
    [selectionPieceView removeFromSuperview];
    //selectionPieceView.delegate = nil;
    //selectionPieceView = nil;
    [controlNalimovView removeFromSuperview];
    //controlNalimovView.delegate = nil;
    //controlNalimovView = nil;
    [_tableView removeFromSuperview];
    
    //boardView = [[BoardView alloc] initWithSquareSizeAndSquareType:dimSquare :squares];
    //boardView = [[BoardView alloc] initWithSettingManager];
    dimSquare = [settingManager getSquareSizeNalimovLandscape];
    //NSLog(@"DimSquare = %f", dimSquare);
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    //[self.view addSubview:boardView];
    //[self setupInitialPosition];
    //[self initBoardViewCoordinates];
    boardView.delegate = self;
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
    
    
    //_tableView.center = CGPointMake(dimSquare*8 + dimSquare*2 + 50, dimSquare*3);
    
    
    //NSLog(@"TO LANDSCAPE:%f - %f      SIZE:%f", boardView.center.x, boardView.center.y, dimSquare);
    
    
    if ([settingManager boardWithEdge]) {
        UIView *borderView = [self getBoardViewWithEdge:UIDeviceOrientationLandscapeLeft];
        [self.view addSubview:borderView];
    }
    
    
    
    [self.view addSubview:boardView];
    
    //selectionPieceView = [[SelectionPieceView alloc] initWithSquareSize:dimSquare];
    //selectionPieceView.delegate = self;
    selectionPieceView.center = CGPointMake(dimSquare*8 + dimSquare*3 + 10, dimSquare);
    [self.view addSubview:selectionPieceView];
    
    //controlNalimovView = [[ControlNalimovView alloc] initWithSquareSize:dimSquare];
    //controlNalimovView.delegate = self;
    controlNalimovView.center = CGPointMake(dimSquare*8 + dimSquare  + 10, dimSquare*3 + 10);
    [self.view addSubview:controlNalimovView];
    [self.view addSubview:_tableView];
    
    
    _tableView.frame = CGRectMake(dimSquare*8 + dimSquare*2 + 20, controlNalimovView.frame.origin.y, 150, dimSquare*8 - dimSquare*2 - 80);
    fenLabel.frame = CGRectMake(dimSquare*8 + 10, dimSquare*8 - 26, 1024-dimSquare*8-20, 25);
    
    [boardView addGestureRecognizer:boardViewLongPressGestureRecognizer];
    
    if ([_pgnGame isEditMode]) {
        [boardView removeLeftAndRightSwipeGestureRecognizer];
    }
    else {
        [boardView addLeftAndRightSwipeGestureRecognizer];
    }
    
}

- (void) gestisciPhone4CheRuotaToPortrait {
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    [boardView removeFromSuperview];
    boardView = nil;
    
    [selectionPieceView removeFromSuperview];
    //selectionPieceView.delegate = nil;
    //selectionPieceView = nil;
    [controlNalimovView removeFromSuperview];
    //controlNalimovView.delegate = nil;
    //controlNalimovView = nil;
    [_tableView removeFromSuperview];
    [fenLabel removeFromSuperview];
    
    dimSquare = [settingManager getSquareSizeNalimovPortrait];
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
    [self.view addSubview:boardView];
    
    _tableView.frame = CGRectMake(dimSquare*8+0+5, 0, 70, dimSquare*8);
    [self.view addSubview:_tableView];
    
    //selectionPieceView = [[SelectionPieceView alloc] initWithSquareSize:dimSquare];
    //selectionPieceView.delegate = self;
    //selectionPieceView.center = CGPointMake(boardView.center.x, dimSquare*9 + 10);
    selectionPieceView.frame = CGRectMake(25, dimSquare*8 + 5, dimSquare*6, dimSquare*2);
    [self.view addSubview:selectionPieceView];
    
    //controlNalimovView = [[ControlNalimovView alloc] initWithSquareSize:dimSquare];
    //controlNalimovView.delegate = self;
    //controlNalimovView.center = CGPointMake(_tableView.center.x, dimSquare*9 + 10);
    controlNalimovView.frame = CGRectMake(dimSquare*8 + 7, dimSquare*8 + 5, dimSquare*2, dimSquare*2);
    [self.view addSubview:controlNalimovView];
    
    
}


- (void) gestisciPhone4CheRuotaToLandscape {
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    [boardView removeFromSuperview];
    boardView = nil;
    
    [selectionPieceView removeFromSuperview];
    //selectionPieceView.delegate = nil;
    //selectionPieceView = nil;
    [controlNalimovView removeFromSuperview];
    //controlNalimovView.delegate = nil;
    //controlNalimovView = nil;
    [_tableView removeFromSuperview];
    
    dimSquare = [settingManager getSquareSizeNalimovLandscape];
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
    
    [self.view addSubview:boardView];
    
    //selectionPieceView = [[SelectionPieceView alloc] initWithSquareSize:dimSquare];
    //selectionPieceView.delegate = self;
    //selectionPieceView.center = CGPointMake(dimSquare*8 + dimSquare*3 + 10, dimSquare);
    selectionPieceView.frame = CGRectMake(dimSquare*8 + 10, 0, dimSquare*6, dimSquare*2);
    [self.view addSubview:selectionPieceView];
    
    //controlNalimovView = [[ControlNalimovView alloc] initWithSquareSize:dimSquare];
    //controlNalimovView.delegate = self;
    //controlNalimovView.center = CGPointMake(dimSquare*8 + dimSquare  + 10, dimSquare*3 + 5);
    controlNalimovView.frame = CGRectMake(dimSquare*8 + 10, dimSquare*2 + 2, dimSquare*2, dimSquare*2);
    [self.view addSubview:controlNalimovView];
    
    _tableView.frame = CGRectMake(dimSquare*8 + dimSquare*2 + 20, dimSquare*2 + 2, 100, dimSquare*8 - dimSquare*2 - 80);
    fenLabel.frame = CGRectMake(dimSquare*8, dimSquare*8-73, 480-dimSquare*8, 15);
    
    [self.view addSubview:_tableView];
    [self.view addSubview:fenLabel];
}

- (void) gestisciPhone5CheRuotaToPortrait {
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    [boardView removeFromSuperview];
    boardView = nil;
    
    [selectionPieceView removeFromSuperview];
    //selectionPieceView.delegate = nil;
    //selectionPieceView = nil;
    [controlNalimovView removeFromSuperview];
    //controlNalimovView.delegate = nil;
    //controlNalimovView = nil;
    [_tableView removeFromSuperview];
    [fenLabel removeFromSuperview];
    
    dimSquare = [settingManager getSquareSizeNalimovPortrait];
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
    
    [self.view addSubview:boardView];
    
    _tableView.frame = CGRectMake(dimSquare*8+0+5, 0, 70, dimSquare*8);
    
    //selectionPieceView = [[SelectionPieceView alloc] initWithSquareSize:dimSquare];
    //selectionPieceView.delegate = self;
    selectionPieceView.center = CGPointMake(boardView.center.x, dimSquare*9 + 10);
    [self.view addSubview:selectionPieceView];
    
    //controlNalimovView = [[ControlNalimovView alloc] initWithSquareSize:dimSquare];
    //controlNalimovView.delegate = self;
    controlNalimovView.center = CGPointMake(_tableView.center.x, dimSquare*9 + 10);
    [self.view addSubview:controlNalimovView];
    
    fenLabel.frame = CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 20);
    
    [self.view addSubview:_tableView];
    [self.view addSubview:fenLabel];
}

- (void) gestisciPhone5CheRuotaToLandscape {
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    [boardView removeFromSuperview];
    boardView = nil;
    
    [selectionPieceView removeFromSuperview];
    //selectionPieceView.delegate = nil;
    //selectionPieceView = nil;
    [controlNalimovView removeFromSuperview];
    //controlNalimovView.delegate = nil;
    //controlNalimovView = nil;
    [_tableView removeFromSuperview];
    [fenLabel removeFromSuperview];
    
    dimSquare = [settingManager getSquareSizeNalimovLandscape];
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
    
    [self.view addSubview:boardView];
    
    //selectionPieceView = [[SelectionPieceView alloc] initWithSquareSize:dimSquare];
    //selectionPieceView.delegate = self;
    //selectionPieceView.center = CGPointMake(dimSquare*8 + dimSquare*3 + 10, dimSquare);
    selectionPieceView.frame = CGRectMake(dimSquare*8 + 10, 0, dimSquare*6, dimSquare*2);
    [self.view addSubview:selectionPieceView];
    
    //controlNalimovView = [[ControlNalimovView alloc] initWithSquareSize:dimSquare];
    //controlNalimovView.delegate = self;
    //controlNalimovView.center = CGPointMake(dimSquare*8 + dimSquare + 10, dimSquare*3 + 10);
    controlNalimovView.frame = CGRectMake(dimSquare*8 + 10, dimSquare*2 + 2, dimSquare*2, dimSquare*2);
    [self.view addSubview:controlNalimovView];
    
    _tableView.frame = CGRectMake(dimSquare*8 + dimSquare*6 + 20, 0, 90, dimSquare*4 + 10);
    fenLabel.frame = CGRectMake(dimSquare*8 + 10, dimSquare*4 + 20, 568-dimSquare*8 - 20, 15);
    
    [self.view addSubview:_tableView];
    [self.view addSubview:fenLabel];
}

- (void) gestisciPhone6CheRuotaToPortrait {
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    [boardView removeFromSuperview];
    boardView = nil;
    
    [selectionPieceView removeFromSuperview];
    //selectionPieceView.delegate = nil;
    //selectionPieceView = nil;
    [controlNalimovView removeFromSuperview];
    //controlNalimovView.delegate = nil;
    //controlNalimovView = nil;
    [_tableView removeFromSuperview];
    [fenLabel removeFromSuperview];
    
    dimSquare = [settingManager getSquareSizeNalimovPortrait];
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
    
    [self.view addSubview:boardView];
    
    _tableView.frame = CGRectMake(dimSquare*8+5, 0, 70, dimSquare*8);
    [self.view addSubview:_tableView];
    
    selectionPieceView.center = CGPointMake(boardView.center.x, dimSquare*9 + 10);
    [self.view addSubview:selectionPieceView];
    
    controlNalimovView.center = CGPointMake(_tableView.center.x, dimSquare*9 + 10);
    [self.view addSubview:controlNalimovView];
    
    fenLabel.frame = CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 20);
    [self.view addSubview:fenLabel];
}

- (void) gestisciPhone6CheRuotaToLandscape {
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    [boardView removeFromSuperview];
    boardView = nil;
    
    [selectionPieceView removeFromSuperview];
    //selectionPieceView.delegate = nil;
    //selectionPieceView = nil;
    [controlNalimovView removeFromSuperview];
    //controlNalimovView.delegate = nil;
    //controlNalimovView = nil;
    [_tableView removeFromSuperview];
    [fenLabel removeFromSuperview];
    
    dimSquare = [settingManager getSquareSizeNalimovLandscape];
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
    
    [self.view addSubview:boardView];
    
    //selectionPieceView.center = CGPointMake(dimSquare*8 + dimSquare*3 + 10, dimSquare);
    selectionPieceView.frame = CGRectMake(dimSquare*8 + 10, 0, dimSquare*6, dimSquare*2);
    [self.view addSubview:selectionPieceView];
    
    //controlNalimovView.center = CGPointMake(dimSquare*8 + dimSquare + 15, dimSquare*3 + 5);
    controlNalimovView.frame = CGRectMake(dimSquare*8 + 10, dimSquare*2 + 2, dimSquare*2, dimSquare*2);
    [self.view addSubview:controlNalimovView];
    
    _tableView.frame = CGRectMake(dimSquare*8 + dimSquare*6 + 20, 0, 90, dimSquare*4 + 5);
    [self.view addSubview:_tableView];
    
    fenLabel.frame = CGRectMake(dimSquare*8 + 15, dimSquare*4 + 15, 667-dimSquare*8 - 20, 15);
    [self.view addSubview:fenLabel];
}

- (void) gestisciPhone6PCheRuotaToPortrait {
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    [boardView removeFromSuperview];
    boardView = nil;
    
    [selectionPieceView removeFromSuperview];
    //selectionPieceView.delegate = nil;
    //selectionPieceView = nil;
    [controlNalimovView removeFromSuperview];
    //controlNalimovView.delegate = nil;
    //controlNalimovView = nil;
    [_tableView removeFromSuperview];
    [fenLabel removeFromSuperview];
    
    dimSquare = [settingManager getSquareSizeNalimovPortrait];
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
    
    [self.view addSubview:boardView];
    
    _tableView.frame = CGRectMake(dimSquare*8+5+5, 0.0, 95, dimSquare*8);
    [self.view addSubview:_tableView];
    
    selectionPieceView.center = CGPointMake(boardView.center.x, dimSquare*9 + 10);
    [self.view addSubview:selectionPieceView];
    
    controlNalimovView.center = CGPointMake(_tableView.center.x, dimSquare*9 + 10);
    [self.view addSubview:controlNalimovView];
    
    fenLabel.frame = CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 20);
    [self.view addSubview:fenLabel];
}

- (void) gestisciPhone6PCheRuotaToLandscape {
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    [boardView removeFromSuperview];
    boardView = nil;
    
    [selectionPieceView removeFromSuperview];
    //selectionPieceView.delegate = nil;
    //selectionPieceView = nil;
    [controlNalimovView removeFromSuperview];
    //controlNalimovView.delegate = nil;
    //controlNalimovView = nil;
    [_tableView removeFromSuperview];
    [fenLabel removeFromSuperview];
    
    dimSquare = [settingManager getSquareSizeNalimovLandscape];
    boardView = [[BoardView alloc] initWithSquareSize:dimSquare];
    boardView.delegate = self;
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    boardView.center = CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
    
    [self.view addSubview:boardView];
    
    //selectionPieceView.center = CGPointMake(dimSquare*8 + dimSquare*3 + 10, dimSquare);
    selectionPieceView.frame = CGRectMake(dimSquare*8 + 10, 0, dimSquare*6, dimSquare*2);
    [self.view addSubview:selectionPieceView];
    
    //controlNalimovView.center = CGPointMake(dimSquare*8 + dimSquare + 15, dimSquare*3 + 5);
    controlNalimovView.frame = CGRectMake(dimSquare*8 + 10, dimSquare*2 + 2, dimSquare*2, dimSquare*2);
    [self.view addSubview:controlNalimovView];
    
    _tableView.frame = CGRectMake(dimSquare*8 + dimSquare*6 + 20, 0, 90, dimSquare*4 + 5);
    [self.view addSubview:_tableView];
    
    fenLabel.frame = CGRectMake(dimSquare*8 + 17, dimSquare*4 + 15, 736-dimSquare*8 - 23, 15);
    [self.view addSubview:fenLabel];
}


- (void) gestisciPhoneCheRuotaToLandscape {
    
    //NSLog(@"GESTISCO PHONE LANDSCAPE");
    
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    
    //dimSquare = 28.0;
    [boardView removeFromSuperview];
    boardView = nil;
    //boardView = [[BoardView alloc] initWithSquareSizeAndSquareType:dimSquare :squares];
    
    boardView = [[BoardView alloc] initWithSquareSize:[settingManager getSquareSizeNalimov]];
    
    
    //NSLog(@"%f    %f     %f     %f", boardView.frame.origin.x, boardView.frame.origin.y, boardView.frame.size.width, boardView.frame.size.height);
    
    //[boardView setFrame:CGRectMake(0.0, 0.0, 224.0, 224.0)];
    
    //[self.view addSubview:boardView];
    
    //[self setupInitialPosition];
    //[self initBoardViewCoordinates];
    boardView.delegate = self;
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    boardView.center = CGPointMake([settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4.0, [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*4);
    
    //[self openEngineView];
    
    if (secondaRigaTitolo) {
        [secondaRigaTitolo removeFromSuperview];
        [terzaRigaTitolo removeFromSuperview];
        NSMutableString *titolo = [[NSMutableString alloc] init];
        [titolo appendString:secondaRigaTitolo.text];
        [titolo appendString:@" "];
        [titolo appendString:[terzaRigaTitolo text]];
        [secondaRigaTitolo setText:titolo];
        [secondaRigaTitolo setTextAlignment:NSTextAlignmentCenter];
        [titoloView addSubview:secondaRigaTitolo];
    }
    

    if ([settingManager boardWithEdge]) {
        UIView *borderView = [self getBoardViewWithEdge:UIDeviceOrientationLandscapeLeft];
        [self.view addSubview:borderView];
    }
    
    [self.view addSubview:boardView];
    [boardView addGestureRecognizer:boardViewLongPressGestureRecognizer];
    
    if ([_pgnGame isEditMode]) {
        [boardView removeLeftAndRightSwipeGestureRecognizer];
    }
    else {
        [boardView addLeftAndRightSwipeGestureRecognizer];
    }
    
    
    if (engineView) {
        [engineView removeFromSuperview];
        engineView = nil;
    }
}

- (void) gestisciPhoneCheRuotaToPortrait {
    //NSLog(@"GESTISCO PHONE PORTRAIT");
    
    CGFloat dimensione = 0.0;
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
        dimensione = 320.0;
    }
    else if (IS_IPHONE_6) {
        dimensione = 375.0;
    }
    else if (IS_IPHONE_6P) {
        dimensione = 414.0;
    }
    
    
    BOOL tempFlipped = NO;
    if (flipped) {
        tempFlipped = flipped;
        flipped = NO;
    }
    
    [boardView removeFromSuperview];
    boardView = nil;
    //boardView = [[BoardView alloc] initWithSquareSizeAndSquareType:dimSquare :squares];
    //boardView = [[BoardView alloc] initWithSquareSize:[settingManager getSquareSizePortrait]];
    boardView = [[BoardView alloc] initWithSquareSize:[settingManager getSquareSize:UIDeviceOrientationPortrait]];
    
    //[boardView setFrame:CGRectMake(0.0, 0.0, 320.0, 320.0)];
    
    CGFloat delta = (dimensione - ([settingManager getSquareSizePortrait]*8))/2.0;
    boardView.center = CGPointMake(delta + ([settingManager getSquareSizePortrait] * 4), [settingManager getSquareSizePortrait] * 4);
    
    //[self.view addSubview:boardView];
    
    //[self setupInitialPosition];
    //[self initBoardViewCoordinates];
    boardView.delegate = self;
    
    if (tempFlipped) {
        flipped = tempFlipped;
        tempFlipped = NO;
    }
    
    
    if (flipped) {
        [boardView flipPosition];
    }
    
    [secondaRigaTitolo removeFromSuperview];
    secondaRigaTitolo.text = [secondaRigaTitolo.text stringByReplacingOccurrencesOfString:terzaRigaTitolo.text withString:@""];
    secondaRigaTitolo.text = [secondaRigaTitolo.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [titoloView addSubview:secondaRigaTitolo];
    [titoloView addSubview:terzaRigaTitolo];
    
    if ([settingManager boardWithEdge]) {
        UIView *borderView = [self getBoardViewWithEdge:UIDeviceOrientationPortrait];
        [self.view addSubview:borderView];
    }
    
    [self.view addSubview:boardView];
    [boardView addGestureRecognizer:boardViewLongPressGestureRecognizer];
    
    if ([_pgnGame isEditMode]) {
        [boardView removeLeftAndRightSwipeGestureRecognizer];
    }
    else {
        [boardView addLeftAndRightSwipeGestureRecognizer];
    }
    
    if (engineView) {
        [engineView removeFromSuperview];
        engineView = nil;
    }
}


- (void) initNewPosition {
    if (IsChessStudioLight) {
        [settingManager setVistaMotore:NSLocalizedString(@"ENGINE_VIEW_CLOSED", nil)];
    }
    
    pgnParser = [[PGNParser alloc] initWithGame];
    pgnRootMove = [[PGNMove alloc] initWithFullMove:nil];
    prossimaMossa = pgnRootMove;
    stopNextMove = YES;
    stopPrevMove = YES;
    
    resultMove = [[PGNMove alloc] initWithFullMove:@"*"];
    
    [pgnRootMove setFen:[boardModel fenNotation]];
    _pgnGame = [[PGNGame alloc] init];
    [_pgnGame setModified:YES];
    
    [_gameWebView setOpening:nil];
    
    [self aggiornaWebView];
    [self setupNavigationTitle];
}


- (void) initNewGame {
    
    if (IsChessStudioLight) {
        [settingManager setVistaMotore:NSLocalizedString(@"ENGINE_VIEW_CLOSED", nil)];
    }
    
    pgnParser = [[PGNParser alloc] initWithGame];
    pgnRootMove = [[PGNMove alloc] initWithFullMove:nil];
    prossimaMossa = pgnRootMove;
    stopNextMove = YES;
    stopPrevMove = YES;
    
    resultMove = [[PGNMove alloc] initWithFullMove:@"*"];
    
    
    [pgnRootMove setFen:[boardModel fenNotation]];
    //NSLog(@"FEN INIZIALE DA INIT NEW GAME = %@", pgnRootMove.fen);
    _pgnGame = [[PGNGame alloc] init];
    [_pgnGame setModified:YES];
    
    //NSLog(@"FEN INIZIALE = %@", [pgnRootMove fenForBookMoves]);
    [self sendMoveToEngine:pgnRootMove];
    
    [_gameWebView setOpening:nil];
    
    [self aggiornaWebView];
    [self setupNavigationTitle];
    
    if (bookManager) {
        [bookManager interrogaBook:[pgnRootMove fen]];
    }
}

- (void) resetGame {
    mossaEseguita = nil;
    
    
    flipped = NO;
    [_gameWebView resetGame];
    [boardModel setupInitialPosition];
    
    [self replaceBoard];
    
    [self evidenziaAChiToccaMuovere];
    [self initNewGame];
}

- (void) resetPosition {
    [self clearBoard];
    //return;
    //[boardModel clearBoard];
    //[boardView removeFromSuperview];
    //boardView = [[BoardView alloc] initWithSquareSizeAndSquareType:dimSquare :squares];
    //[self initBoardViewCoordinates];
    //[self.view addSubview:boardView];
    //boardView.delegate = self;
}

- (void) setupNavigationTitle {
    
    if (!_pgnGame) {
        return;
    }
    
    if ([_pgnGame isNewGame]) {
        if (titoloView) {
            self.navigationItem.titleView = nil;
            titoloView = nil;
        }
        if (_setupPosition) {
            self.navigationItem.title = NSLocalizedString(@"MENU_NEW_POSITION", nil);
        }
        else {
            self.navigationItem.title = NSLocalizedString(@"MENU_NEW_GAME", nil);
        }
        //[self setupNavigationTitleGestureRecognizer];
        return;
    }
    [self setupTitoli];
}

- (void) setupTitoli {
    NSString *bianco = [_pgnGame getTagValueByTagName:@"White"];
    NSString *nero = [_pgnGame getTagValueByTagName:@"Black"];
    
    NSMutableString *titolo2 = [[NSMutableString alloc] init];
    [titolo2 appendString:[_pgnGame getTagValueByTagName:@"Result"]];
    [titolo2 appendString:@" "];
    
    NSString *eco = [_pgnGame getTagValueByTagName:@"ECO"];
    if (eco) {
        [titolo2 appendString:eco];
        [titolo2 appendString:@" "];
    }
    
    
    [titolo2 appendString:[_pgnGame getTagValueByTagName:@"Event"]];
    
    titoloView = nil;
    
    if (IS_PAD) {
        
        [titolo2 appendString:@" - "];
        [titolo2 appendString:[_pgnGame getTagValueByTagName:@"Site"]];
        [titolo2 appendString:@" "];
        [titolo2 appendString:[_pgnGame getTagValueByTagName:@"Date"]];
        
        
        titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, self.navigationController.navigationBar.frame.size.height)];
        //UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 400, 28)];
        
        primaRigaTitolo = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 400, 28)];
        
        primaRigaTitolo.textAlignment = NSTextAlignmentCenter;
        primaRigaTitolo.adjustsFontSizeToFitWidth = YES;
        primaRigaTitolo.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
        primaRigaTitolo.textColor = [UIColor redColor];
        primaRigaTitolo.text = [[bianco stringByAppendingString:@" - "] stringByAppendingString:nero];
        primaRigaTitolo.backgroundColor = [UIColor clearColor];
        [titoloView addSubview:primaRigaTitolo];
        
        //UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 500, 16)];
        secondaRigaTitolo = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 500, 16)];
        secondaRigaTitolo.textAlignment = NSTextAlignmentCenter;
        secondaRigaTitolo.adjustsFontSizeToFitWidth = YES;
        secondaRigaTitolo.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:16];
        secondaRigaTitolo.textColor = [UIColor blackColor];
        secondaRigaTitolo.text = titolo2;
        secondaRigaTitolo.backgroundColor = [UIColor clearColor];
        [titoloView addSubview:secondaRigaTitolo];
    }
    else {
        titoloView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 44.0)];
        [titoloView setBackgroundColor:[UIColor clearColor]];
        
        //UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 190, 28)];
        primaRigaTitolo = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 190, 24)];
        primaRigaTitolo.textAlignment = NSTextAlignmentCenter;
        primaRigaTitolo.adjustsFontSizeToFitWidth = YES;
        primaRigaTitolo.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:16];
        primaRigaTitolo.textColor = [UIColor redColor];
        primaRigaTitolo.text = [[bianco stringByAppendingString:@" - "] stringByAppendingString:nero];
        primaRigaTitolo.backgroundColor = [UIColor clearColor];
        [titoloView addSubview:primaRigaTitolo];
        
        //UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, 200, 16)];
        secondaRigaTitolo = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, 180, 16)];
        secondaRigaTitolo.textAlignment = NSTextAlignmentCenter;
        secondaRigaTitolo.adjustsFontSizeToFitWidth = YES;
        secondaRigaTitolo.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:8.5];
        secondaRigaTitolo.textColor = [UIColor blackColor];
        secondaRigaTitolo.text = titolo2;
        secondaRigaTitolo.backgroundColor = [UIColor clearColor];
        
        [titoloView addSubview:secondaRigaTitolo];
        
        NSMutableString *titolo3 = [[NSMutableString alloc] init];
        [titolo3 appendString:[_pgnGame getTagValueByTagName:@"Site"]];
        [titolo3 appendString:@" "];
        [titolo3 appendString:[_pgnGame getTagValueByTagName:@"Date"]];
        
        //UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 200, 16)];
        terzaRigaTitolo = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 180, 16)];
        terzaRigaTitolo.textAlignment = NSTextAlignmentCenter;
        terzaRigaTitolo.adjustsFontSizeToFitWidth = YES;
        terzaRigaTitolo.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:8.5];
        terzaRigaTitolo.textColor = [UIColor blackColor];
        terzaRigaTitolo.text = titolo3;
        terzaRigaTitolo.backgroundColor = [UIColor clearColor];
        
        [titoloView addSubview:terzaRigaTitolo];
        
    }
    [titoloView sizeToFit];
    
    self.navigationItem.titleView = titoloView;
    //[self.navigationItem.titleView sizeToFit];
    
    [self setupNavigationTitleGestureRecognizer];

}

- (void) setupNavigationTitleGestureRecognizer {
    //tapTitleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(manageTapOnNavigationTitle)];
    //tapTitleGestureRecognizer.numberOfTapsRequired = 1;
    //CGRect frame = CGRectMake(self.view.frame.size.width/4, 0, self.view.frame.size.width/2, 44);
    //navigationBarTapView = [[UIView alloc] initWithFrame:frame];
    //navigationBarTapView.backgroundColor = [UIColor clearColor];
    //[navigationBarTapView setUserInteractionEnabled:YES];
    //[navigationBarTapView addGestureRecognizer:tapTitleGestureRecognizer];
    //[self.navigationController.navigationBar addSubview:navigationBarTapView];
}

- (void) removeNavigationTitleGestureRecognizer {
    //[navigationBarTapView removeGestureRecognizer:tapTitleGestureRecognizer];
    //[navigationBarTapView removeFromSuperview];
    //tapTitleGestureRecognizer = nil;
    //navigationBarTapView = nil;
}

- (void) manageTapOnNavigationTitle {
    
    if (actionSheetMenu) {
        [actionSheetMenu dismissWithClickedButtonIndex:-1 animated:YES];
        actionSheetMenu = nil;
    }
    if (actionSheetMenuGame.window ) {
        [actionSheetMenuGame dismissWithClickedButtonIndex:0 animated:YES];
        actionSheetMenuGame = nil;
    }
    if (annotationMovePopoverController.isPopoverVisible) {
        [annotationMovePopoverController dismissPopoverAnimated:YES];
        annotationMovePopoverController = nil;
    }
    
    if (_setupPosition) {
        return;
    }
    
    
    if (!_pgnGame.isEditMode) {
        [self showGameInfoNoModify];
        return;
    }
    if ([_pgnGame userCanEditGameData]) {
        [self showGameInfo];
    }
    else {
        UIAlertView *noMovesAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ALERT_NO_MOVES_MESSAGE", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noMovesAlertView show];
    }
    
    //[self showGameInfo];
}

- (void) parseGame {
    
    //NSLog(@"Start parseGame in BoardViewController");
    
    //pgnParser = [[PGNParser alloc] init];
    
    PGNAnalyzer *pgnAnalyzer;
    
    if ([_pgnGame isPosition]) {
        if ([_pgnGame getGameType] == POSITION_WITH_MOVES) {
            //NSLog(@"Devo analizzare una posizione con mosse = %@", _gameToView);
            
            pgnParser = [[PGNParser alloc] initWithPosition];
            
            //NSLog(@"PGN PARSER CREATO");
            [pgnParser setFenPosition:[_pgnGame getFenPosition]];
        
            //NSLog(@"PGNPARSER SETTATO FEN");
            
            pgnAnalyzer = [[PGNAnalyzer alloc] initWithPosition:_gameToView];
            [pgnAnalyzer setFenParser:[_pgnGame getFenParser]];
            
            //NSLog(@"PGNANALYZER CREATO");
            //[pgnAnalyzer parsePositionToTokenArray];
            [pgnAnalyzer parsePositionToTokenArrayWithGraffa];
            
            //NSLog(@"TOKEN ARRAY CON GRAFFA SUPERATA");
            
            [pgnAnalyzer parsePositionToDeleteTrePunti];
            
            //NSLog(@"PARSE TO DELETE TRE PUNTI SUPERATA");
            
            //[pgnAnalyzer parsePositionToListMoves];
            [pgnAnalyzer parsePositionToListMovesWithGraffa];
            
            //NSLog(@"PARSE TO LIST MOVES CON GRAFFA SUPERATA");
            
            
            //[pgnAnalyzer parsePositionToListMoves2];
            [boardModel setWhiteHasToMove:YES];
            pgnRootMove = [pgnAnalyzer getRadice];
            
            //NSLog(@"OTTENUTA RADICE SUPERATA");
            
            //NSLog(@"PLYCOUNT RADICE = %lu", (unsigned long)[pgnRootMove plyCount]);
            //NSLog(@"FEN RADICE = %@", [pgnRootMove fen]);
            
            //[pgnRootMove visitaAlberoToGetFen];
            
            for (PGNMove *move in [pgnRootMove getNextMoves]) {
                //NSLog(@"MOSSE IN RADICE = %@", move.description);
                    
                //NSLog(@"PARSE TRE MOVES DA SUPERARE PER MOSSA = %@", move.description);
                    
                if ([move isFirstMoveAfterRootWithDots]) {
                    [move setEvidenzia:YES];
                    [boardModel setWhiteHasToMove:NO];
                    [self evidenziaAChiToccaMuovere];
                }
                    
                [pgnParser parseTreeMovesPositionWithMoves:move];
                    
                //NSLog(@"PARSE TRE MOVES SUPERATA PER MOSSA = %@", move.description);
            }

            

            
            if ([boardModel whiteHasToMove]) {
                prossimaMossa = pgnRootMove;
            }
            else {
                prossimaMossa = [[pgnRootMove getNextMoves] objectAtIndex:0];
            }
            
            resultMove = [pgnRootMove getLastMove];
            //[pgnRootMove visitaAlberoToGetGraffe];
            [pgnRootMove removeResultMove];
            stopNextMove = NO;
            stopPrevMove = YES;
    
            if ([pgnAnalyzer numerazioneMosseModificata]) {
                //NSLog(@"Index della partita prima di salvare = %d", [_pgnGame indexInAllGamesAllTags]);
                //NSLog(@"Devo salvare la numerazione delle mosse modificata. Qua si dovrebbe chiedere all'utente ma salvo lo stesso");
                [self salvaModificheInDatabase];
                //NSLog(@"Index della partita dopo aver salvato = %d", [_pgnGame indexInAllGamesAllTags]);
                
                
                //UIAlertView *wrongGameNumberingAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"WRONG_GAME_NUMBERING", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:NSLocalizedString(@"WRONG_GAME_NUMBERING_SAVE", nil), NSLocalizedString(@"WRONG_GAME_NUMBERING_NO_SAVE", nil), nil];
                //wrongGameNumberingAlertView.tag = 900;
                //[wrongGameNumberingAlertView show];
                
                
            }
            
            return;
            
        }
        else if ([_pgnGame getGameType] == POSITION_WITHOUT_MOVES) {
            
            //NSLog(@"Devo analizzare una posizione senza mosse con gameToview = %@", _gameToView);
            
            pgnParser = [[PGNParser alloc] initWithPosition];
            [pgnParser setFenPosition:[_pgnGame getFenPosition]];
            
            //_gameToView = [[NSMutableString alloc] initWithString:[_pgnGame moves]];
            
            pgnAnalyzer = [[PGNAnalyzer alloc] initWithPosition:_gameToView];
            [pgnAnalyzer setFenParser:[_pgnGame getFenParser]];
            //[pgnAnalyzer parsePositionToTokenArray];
            [pgnAnalyzer parsePositionToTokenArrayWithGraffa];
            //[pgnAnalyzer parsePositionToDeleteTrePunti];
            [pgnAnalyzer parsePositionToListMovesWithGraffa];
            [boardModel setWhiteHasToMove:YES];
            
            pgnRootMove = [pgnAnalyzer getRadice];
            for (PGNMove *move in [pgnRootMove getNextMoves]) {
                //NSLog(@"MOSSE IN RADICE = %@", move.description);
                
                if ([move isFirstMoveAfterRootWithDots]) {
                    [move setEvidenzia:YES];
                    [boardModel setWhiteHasToMove:NO];
                    [self evidenziaAChiToccaMuovere];
                }
                
                [pgnParser parseTreeMovesPositionWithMoves:move];
                //[pgnParser parseTreeMoves:move];
            }
            
            if ([boardModel whiteHasToMove]) {
                prossimaMossa = pgnRootMove;
                //NSLog(@"Stampo Prossima mossa con mossa al bianco = %@ e plycount = %d", prossimaMossa.fullMove, [boardModel getPlyCount]);
            }
            else {
                prossimaMossa = [[pgnRootMove getNextMoves] objectAtIndex:0];
                
                //NSLog(@"Stampo Prossima mossa con mossa al nero = %@ e plycount = %d", prossimaMossa.fullMove, [boardModel getPlyCount]);
            }
            
            resultMove = [pgnRootMove getLastMove];
            //[pgnRootMove visitaAlberoToGetGraffe];
            [pgnRootMove removeResultMove];
            stopNextMove = YES;
            stopPrevMove = YES;
            return;
        }
    }
    else {
        if ([_pgnGame getGameType] == GAME_WITH_MOVES) {
            //NSLog(@"Devo analizzare una partita con mosse");
            pgnParser = [[PGNParser alloc] initWithGame];
            pgnAnalyzer = [[PGNAnalyzer alloc] initWithGame:_gameToView];
            //[pgnAnalyzer parseGameToTokenArray];
            [pgnAnalyzer parseGameToTokenArrayWithGraffa];
            [pgnAnalyzer parseGameToDeleteTrePunti];
            //[pgnAnalyzer parseGameToListMoves];
            [pgnAnalyzer parseGameToListMovesWithGraffa];
            [boardModel setWhiteHasToMove:YES];
            pgnRootMove = [pgnAnalyzer getRadice];
            for (PGNMove *move in [pgnRootMove getNextMoves]) {
                //NSLog(@"MOSSE IN RADICE = %@", move.description);
                //[pgnParser parseTreeMoves:move];
                [pgnParser parseTreeMovesGameWithMoves:move];
            }
            prossimaMossa = pgnRootMove;
            
            
            resultMove = [pgnRootMove getLastMove];
            
            //NSLog(@"RESULT MOVE = %@", resultMove.fullMove);
            
            //[pgnRootMove visitaAlberoToGetGraffe];
            [pgnRootMove removeResultMove];
            stopNextMove = NO;
            stopPrevMove = YES;
            
            
            //[pgnRootMove visitaAlberoToGetTextAfterGraffe];
            
            return;
            
        }
        else if ([_pgnGame getGameType] == GAME_WITHOUT_MOVES) {
            //NSLog(@"Devo analizzare una partita senza mosse");
            pgnParser = [[PGNParser alloc] initWithGame];
            pgnAnalyzer = [[PGNAnalyzer alloc] initWithGame:_gameToView];
            //[pgnAnalyzer parseGameToTokenArray];
            [pgnAnalyzer parseGameToTokenArrayWithGraffa];
            [pgnAnalyzer parseGameToDeleteTrePunti];
            //[pgnAnalyzer parseGameToListMoves];
            [pgnAnalyzer parseGameToListMovesWithGraffa];
            pgnRootMove = [pgnAnalyzer getRadice];
            for (PGNMove *move in [pgnRootMove getNextMoves]) {
                //NSLog(@"MOSSE IN RADICE = %@", move.description);
                [pgnParser parseTreeMoves:move];
            }
            prossimaMossa = pgnRootMove;
            
            resultMove = [pgnRootMove getLastMove];
            //[pgnRootMove visitaAlberoToGetGraffe];
            [pgnRootMove removeResultMove];
            stopNextMove = YES;
            stopPrevMove = YES;
            return;
        }
    }
    
    
    //pgnRootMove = [pgnAnalyzer getRadice];
    
    //[pgnRootMove visitaAlberoToGetMainLine];
    
    //PGNMove *m = [[pgnRootMove getNextMoves] objectAtIndex:0];
    //NSLog(@"PRIMA MOSSA = %@", m.description);
    
    //Il seguente commento è necessario per eseguire il parsing delle mosse durante la partita e non all'inizio
    //for (PGNMove *move in [pgnRootMove getNextMoves]) {
    //    NSLog(@"MOSSE IN RADICE = %@", move.description);
        
        //@try {
    //        [pgnParser parseTreeMoves:move];
        //}
        //@catch (NSException *exception) {
            //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ECCEZIONE" message:@"Errore nelle mosse" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //[alertView show];
            //break;
        //}
        //@finally {
            //return;
        //}
        
    
    //}
    
    //prossimaMossa = pgnRootMove;
    
    
    //[pgnRootMove visitaAlberoToGetMainLine];
    //[pgnRootMove visitaAlberoToGetFen];
    
    resultMove = [pgnRootMove getLastMove];
    //NSLog(@"ResultMove = %@", resultMove.fullMove);
    
    [pgnRootMove visitaAlberoToGetTextAfterGraffe];
    
    
    [pgnRootMove removeResultMove];
    
    
    //[pgnRootMove visitaAlberoToGetMainLine];
    
    stopNextMove = NO;
    stopPrevMove = YES;
    
    //pgnGame = [pgnParser getGame];
    //pgnMoves = [pgnGame getMoves];
    
    
    //[self aggiornaWebView];
    
    
    //NSLog(@"End parseGame in BoardViewController");
    
    //[self setupNavigationTitle];
    
    //[_gameWebView setGameToViewArray:[pgnAnalyzer visitaAlberoAnticipato2AndGetGameArray]];
    //[_gameWebView setGameToView:[pgnAnalyzer visitaAlberoAnticipato2AndGetGameArray]];
    
    //return;
    
    //for (PGNMove *pgnMove in pgnMoves) {
    //    NSString *fromSquare = [NSString stringWithFormat:@"%d", pgnMove.fromSquare];
    //    NSString *toSquare = [NSString stringWithFormat:@"%d", pgnMove.toSquare];
    //    NSLog(@"%@%@-%@    %@     %@        %@", pgnMove.piece, fromSquare, toSquare, pgnMove.move, pgnMove.log, pgnMove.getCompleteMove);
    //}
    
    //[_gameWebView setPgnGame:pgnGame];
    //[_gameWebView setParsedGame:[pgnAnalyzer getParsedGame]];
    //[_gameWebView setGameToViewArray:[pgnAnalyzer getParsedGameArray]];
    
    
    
    //[pgnAnalyzer printParsedArray];
    //[pgnAnalyzer printParsedGame];

    //return;
    /*
    [pgnParser parse:_gameToViewWithBlank];
    
    pgnGame = [pgnParser getGame];
    pgnMoves = [pgnGame getMoves];
    for (PGNMove *pgnMove in pgnMoves) {
        NSString *fromSquare = [NSString stringWithFormat:@"%d", pgnMove.fromSquare];
        NSString *toSquare = [NSString stringWithFormat:@"%d", pgnMove.toSquare];
        NSLog(@"%@%@-%@    %@     %@", pgnMove.piece, fromSquare, toSquare, pgnMove.move, pgnMove.log);
    }
    [_gameWebView setPgnGame:pgnGame];
    */ 
}

- (void) setPgnGame:(PGNGame *)pgnGame {
    
    //buffer = [NSKeyedArchiver archivedDataWithRootObject: pgnGame];
    
    //NSLog(@"INDEX OF PGN_GAME = %d", [pgnGame indexInAllGamesAllTags]);
    
    
    
    
    [pgnGame backupMoves];
    
    _pgnGame = pgnGame;
    
    
    //NSLog(@"L'indice della partita ricevuta è %d", [_pgnGame indexInAllGamesAllTags]);
    
    if ([_pgnGame isPosition]) {
        [boardModel setStartFromFen:YES];
        [boardModel setFenNotation:[_pgnGame getTagValueByTagName:@"FEN"]];
        _gameToView = [[NSMutableString alloc] initWithString:[_pgnGame moves]];
        //NSLog(@"GameToView In BoardViewController setPgnGame = %@", _gameToView);
        startFenPosition = [_pgnGame getTagValueByTagName:@"FEN"];
        
        NSLog(@"Start Plycount in Position = %lu", (unsigned long)[_pgnGame getStartPlycount]);
        
        
        [self parseGame];
    }
    else {
        startFenPosition = @"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
        _gameToView = [[NSMutableString alloc] initWithString:[_pgnGame moves]];
        _gameToViewArray = [_pgnGame getGameArray];
        [self parseGame];
    }
}

- (void) setGameToView:(NSMutableString *)gameToView {
    _gameToView = gameToView;
    //_insertMode = NO;
    [self parseGame];
}

- (void) setGameToViewArray:(NSArray *)gameToViewArray {
    _gameToViewArray = gameToViewArray;
    if (!_pgnGame) {
        _pgnGame = [[PGNGame alloc] init];
    }
    //for (NSString *s in _gameToViewArray) {
    //    NSLog(@"Valore in gameArray: %@", s);
    //    [_pgnGame addCompleteTag:s];
    //}
}


- (void) setGameModel:(BoardModel *)gameModel {
    _gameModel = gameModel;
    boardModel = gameModel;
    //[boardModel printPosition];
    //NSLog(@"Ricevuto Game Model");
}


- (void) setupInitialPosition {
    PieceButton *pb;
    //dimSquare = [settingManager getSquareSize];
    pieceType = [settingManager getPieceTypeToLoad];
    squares = [settingManager squares];
    
    for (int i=0; i<64; i++) {
        NSString *square = [boardModel findContenutoBySquareNumber:i];
        if (![square hasSuffix:@"m"]) {
            if ([square hasSuffix:@"r"]) {
                pb = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:square];
            }
            else {
                if ([square hasSuffix:@"k"]) {
                    pb = [[[KingButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:square];
                }
                else {
                    if ([square hasSuffix:@"q"]) {
                        pb = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:square];
                }
                    else {
                        if ([square hasSuffix:@"n"]) {
                            pb = [[[KnightButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:square];
                        }
                        else {
                            if ([square hasSuffix:@"b"]) {
                                pb = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:square];
                            }
                            else {
                                if ([square hasSuffix:@"p"]) {
                                    pb = [[[PawnButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:square];
                                }
                            }
                        }
                    }
                }
            }
            //[pb setSquareNumber:[[boardModel.numericSquares objectAtIndex:i] intValue]];
            [pb setCasaIniziale:i];
            [pb setDelegate:self];
            [pb setSquareValue:i];
            if (flipped) {
                [pb flip];
            }
            //NSLog(@"PEZZO NUOVO FRAME:  X=%f     Y=%f     W=%f    H=%f", pb.frame.origin.x, pb.frame.origin.y, pb.frame.size.width, pb.frame.size.height);
            [boardView addSubview:pb];
        }
        else {
            PieceButton *pb = [boardView findPieceBySquareTag:i];
            if (pb) {
                [pb removeFromSuperview];
            }
        }
    }
}

- (void) clearBoardView {
    for (int i=0; i<64; i++) {
        PieceButton *pb = [boardView findPieceBySquareTag:i];
        if (pb) {
            [pb removeFromSuperview];
        }
    }
}


- (void) generaMossePseudoLegali {
    for (int i=0; i<64; i++) {
        PieceButton *pb = [boardView findPieceBySquareTag:i];
        if (pb) {
            [pb generaMossePseudoLegali];
            //NSLog(@"Dati: %@,   tag = %d,   numero casa:%d", pb.titleLabel.text, pb.tag, pb.squareNumber);
        }
    }
}



- (void) creaEcoFenFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *file = [documentPath stringByAppendingPathComponent:@"ecomast.txt"];
    DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:file];
    NSString *line = nil;
    NSMutableDictionary *eco = [[NSMutableDictionary alloc] init];
    NSString *value = nil;
    NSMutableString *key = nil;
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([line hasPrefix:@"A"] || [line hasPrefix:@"B"] || [line hasPrefix:@"C"] || [line hasPrefix:@"D"] || [line hasPrefix:@"E"]) {
            line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            value = line;
        }
        else if (line.length > 0) {
            if (!key) {
                key = [[NSMutableString alloc] initWithString:line];
                [key appendString:@" "];
            }
            else {
                [key appendString:line];
                [key appendString:@" "];
            }
        }
        else {
            NSString *finalKey = key;
            finalKey = [finalKey stringByReplacingOccurrencesOfString:@"1/2" withString:@""];
            finalKey = [finalKey stringByReplacingOccurrencesOfString:@"." withString:@". "];
            finalKey = [finalKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [eco setObject:value forKey:finalKey];
            line = nil;
            value = nil;
            key = nil;
        }
    }
    
    NSString *savePath = [documentPath stringByAppendingPathComponent:@"eco.plist"];
    [eco writeToFile:savePath atomically:YES];
}

- (void) eco2fen {
    NSString *savePath;
    //NSUInteger riga = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *ecofenPath = [paths objectAtIndex:0];
    NSString *file = [ecofenPath stringByAppendingPathComponent:@"mosse2eco.plist"];
    NSDictionary *eco = [[NSDictionary alloc] initWithContentsOfFile:file];
    
    NSMutableDictionary *ecoFen = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in [eco allKeys]) {
        PGNAnalyzer *pgnAnalyzer = [[PGNAnalyzer alloc] initWithGame:key];
        [pgnAnalyzer parseGameToTokenArray];
        [pgnAnalyzer parseGameToDeleteTrePunti];
        [pgnAnalyzer parseGameToListMoves];
        PGNParser *parser = [[PGNParser alloc] init];
        PGNMove *pgnRoot = [pgnAnalyzer getRadice];
        for (PGNMove *move in [pgnRoot getNextMoves]) {
            [parser parseTreeMoves:move];
        }
        PGNMove *lastMove = [pgnRoot getLastMove];
        [ecoFen setObject:[eco objectForKey:key] forKey:lastMove.fen];
        //riga++;
        //NSLog(@"Riga %d eseguita", riga);
    }
    savePath = [ecofenPath stringByAppendingPathComponent:@"fen2eco2.plist"];
    [ecoFen writeToFile:savePath atomically:YES];
}

- (void) mosse2ecoTag {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *ecoPath = [paths objectAtIndex:0];
    NSString *file = [ecoPath stringByAppendingPathComponent:@"eco.txt"];
    DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:file];
    NSString *line = nil;
    NSMutableDictionary *eco = [[NSMutableDictionary alloc] init];
    NSMutableString *value = nil;
    NSMutableString *key = nil;
    while ((line = [reader readLine])) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([line hasPrefix:@"["]) {
            if (!value) {
                value = [[NSMutableString alloc] initWithString:line];
            }
            else {
                [value appendString:separator];
                [value appendString:line];
            }
        }
        else if (line.length>0) {
            if (!key) {
                key = [[NSMutableString alloc] initWithString:line];
                [key appendString:@" "];
            }
            else {
                [key appendString:line];
                [key appendString:@" "];
            }
            
            if ([key hasSuffix:@"* "]) {
                NSString *finalKey = key;
                finalKey = [finalKey stringByReplacingOccurrencesOfString:@"*" withString:@""];
                //finalKey = [finalKey stringByReplacingOccurrencesOfString:@"." withString:@". "];
                finalKey = [finalKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [eco setObject:value forKey:finalKey];
                line = nil;
                value = nil;
                key = nil;
            }
        }
        else if (line.length == 0) {
        
        }
        /*
        else {
            NSString *finalKey = key;
            finalKey = [finalKey stringByReplacingOccurrencesOfString:@"*" withString:@""];
            finalKey = [finalKey stringByReplacingOccurrencesOfString:@"." withString:@". "];
            finalKey = [finalKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [eco setObject:value forKey:finalKey];
            line = nil;
            value = nil;
            key = nil;
        }*/
    }
    NSString *savePath = [ecoPath stringByAppendingPathComponent:@"mosse2eco.plist"];
    [eco writeToFile:savePath atomically:YES];
}

- (void) gestisciToccoBreve:(PieceButton *)pieceButton {
    
    if (IsChessStudioLight) {
        if ([boardModel getPlyCount] > 29) {
            UIAlertView *lightAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"LIGHT_MOVES", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"OK", nil];
            lightAlertView.tag = 1000;
            [lightAlertView show];
            return;
        }
    }
    
    if (!_pgnGame.isEditMode) {
        NSString *title = NSLocalizedString(@"TITLE_EDIT_MODE", nil);
        UIAlertView *noInsertModeAlertView = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"ALERT_NO_INSERT_MODE_2", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        noInsertModeAlertView.tag = 100;
        [noInsertModeAlertView show];
        return;
    }
    
    
    if ([boardView candidatesPiecesAreHilighted] && ![settingManager tapDestination]) {
        UIAlertView *tapDestinationAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_TAP_ARRIVAL_SQUARE", nil) message:NSLocalizedString(@"SETTINGS_TAP_ARRIVAL_SQUARE_DISABLED", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        tapDestinationAlertView.tag = 700;
        [tapDestinationAlertView show];
        [boardView clearCanditatesPieces];
        [boardView clearArrivalSquare:candidateSquareTo];
        candidateSquareTo = -1;
        return;
    }
    
    if ([boardView candidatesPiecesAreHilighted]) {
        //NSLog(@"Siccome sono presenti dei pezzi candidati alla mossa li devo muovere");
        if (pieceButton) {
            if ([boardView selectedPieceIsCandidatePiece:(int)pieceButton.tag]) {
                //NSLog(@"Il pezzo che devo muovere sembra essere %@", pieceButton.titleLabel.text);
                //NSLog(@"Casa Partenza = %ld", (long)pieceButton.tag);
                //NSLog(@"Casa arrivo = %d", candidateSquareTo);
                
                [self setCasaPartenza:(int)pieceButton.tag];
                [self setCasaArrivo:candidateSquareTo];
                int resultCheckCasaArrivo = [self checkCasaArrivo:candidateSquareTo];
                if (resultCheckCasaArrivo == -2) {
                    [boardView muoviPezzo:(int)pieceButton.tag :candidateSquareTo];
                    return;
                }
                
                [boardView muoviPezzo:(int)pieceButton.tag :candidateSquareTo];
                //[boardView muoviPezzoAvanti:pieceButton.tag :candidateSquareTo :pieceButton];
                [self gestisciMossaCompleta];
                [boardView clearCanditatesPieces];
                [boardView clearArrivalSquare:candidateSquareTo];
                return;
            }
            else {
                //NSLog(@"Pezzo candidato = %d", pieceButton.tag);
                //NSLog(@"Il pezzo selezionato non è tra quelli candidati");
                if (pieceButton.tag == candidateSquareTo) {
                    [boardView clearCanditatesPieces];
                    [boardView clearArrivalSquare:candidateSquareTo];
                    candidateSquareTo = -1;
                    return;
                }
            }
        }
    }
    
    
    
    [boardView clearCanditatesPieces];
    [boardView clearArrivalSquare:candidateSquareTo];
    
    
    if (([pieceButton.titleLabel.text hasPrefix:@"b"] && [boardModel whiteHasToMove]) || ([pieceButton.titleLabel.text hasPrefix:@"w"] && ![boardModel whiteHasToMove])) {
        
        /*
        if (![settingManager tapPieceToMove]) {
            UIAlertView *tapPieceAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_TAP_PIECE", nil) message:NSLocalizedString(@"SETTINGS_TAP_PIECE_DISABLED", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
            tapPieceAlertView.tag = 600;
            [tapPieceAlertView show];
            [boardView clearHilightedAndControlledSquares];
            return;
        }*/
        
        //NSLog(@"Devo catturare il pezzo in %d", pieceButton.tag);
        PieceButton *pieceButtonTapped = [boardView findPieceButtonTapped];
        int squareTag = (int)pieceButton.tag;
        int squareFrom = (int)pieceButtonTapped.tag;
        [self setCasaPartenza:squareFrom];
        //NSLog(@"Devo muovere il pezzo da %d a %d", casaPartenza, squareTag);
        NSArray *mosseLegali = [[pieceButtonTapped pseudoLegalMoves] allObjects];
        NSNumber *squareTo = [NSNumber numberWithInteger:squareTag];
        if ([mosseLegali containsObject:squareTo]) {
            
            
            
             if (![settingManager tapPieceToMove]) {
             UIAlertView *tapPieceAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_TAP_PIECE", nil) message:NSLocalizedString(@"SETTINGS_TAP_PIECE_DISABLED", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
             tapPieceAlertView.tag = 600;
             [tapPieceAlertView show];
             [boardView clearHilightedAndControlledSquares];
             return;
             }
            
            
            
            
            
            [self setCasaArrivo:squareTag];
            //[self checkCasaArrivo:squareTag];
            //[boardView muoviPezzo:squareFrom :squareTag];
            
            [boardView clearHilightedAndControlledSquares];
            int resultCheckCasaArrivo = [self checkCasaArrivo:squareTag];
            if (resultCheckCasaArrivo == -2) {
                [boardView muoviPezzo:squareFrom :squareTag];
                return;
            }
            
            [boardView muoviPezzoAvanti:squareFrom :squareTag :pieceButton];
            [self gestisciMossaCompleta];
        }
        else {
            //NSLog(@"Gestione mosse candidate");
            //NSLog(@"Devo verificare quali pezzi possono catturare il pezzo in %d", (int)pieceButton.tag);
            //NSLog(@"Il pezzo da catturare è %@", pieceButton.titleLabel.text);
            NSMutableArray *listaPezzi;
            if ([boardModel whiteHasToMove]) {
                listaPezzi = [boardModel getListaPezziCheControllano:(int)pieceButton.tag :@"b" :0];
            }
            else {
                listaPezzi = [boardModel getListaPezziCheControllano:(int)pieceButton.tag :@"w" :-1];
            }
            
            //NSLog(@"%@", listaPezzi);
            
            
            //Controlla le case possibili che si verificano con il pedone che sarebbe costretto a muoversi indietro
            NSMutableArray *caseImpossibili = [[NSMutableArray alloc] init];
            for (NSString *casaOrigine in listaPezzi) {
                NSString *pezzo = [boardModel findContenutoBySquareNumber:[casaOrigine intValue]];
                if (![boardModel whiteHasToMove] && [pezzo hasPrefix:@"w"]) {
                    [caseImpossibili addObject:casaOrigine];
                }
                if ([boardModel whiteHasToMove] && [pezzo hasPrefix:@"b"]) {
                    [caseImpossibili addObject:casaOrigine];
                }
            }
            
            if (caseImpossibili.count>0) {
                [listaPezzi removeObjectsInArray:caseImpossibili];
            }
            
            
            NSMutableArray *caseProibiteCausaScacco = [[NSMutableArray alloc] init];
            for (NSString *casa in listaPezzi) {
                //NSLog(@"Devo vedere se il pezzo nella casa %@ può andare nella casa %d", casa, squareTag);
                int cp = [casa intValue];
                int ca = (int)pieceButton.tag;
                //NSLog(@"Devo vedere se il pezzo nella casa %d può andare nella casa %d", cp, ca);
                if ([boardModel reSottoScacco:cp :ca]) {
                    //NSLog(@"Se muovo il pezzo nella casa %d il re sarebbe sotto scacco!!", cp);
                    [caseProibiteCausaScacco addObject:casa];
                }
            }
            
            if (caseProibiteCausaScacco.count>0) {
                [listaPezzi removeObjectsInArray:caseProibiteCausaScacco];
            }
            
            [boardView hilightCandidatesPieces:listaPezzi];
            if (listaPezzi.count > 0) {
                [boardView hilightArrivalSquare:(int)pieceButton.tag];
            }
            
            candidateSquareTo = (int)pieceButton.tag;
            
            
        }
        return;
    }
    
    if ([boardView isHilighted:[pieceButton tag]]) {
        [boardView clearStartSquare:[pieceButton tag]];
    }
    else {
        [boardView hiLightStartSquare:[pieceButton tag]];
    }
    
    NSMutableSet *mossePseudoLegali = [pieceButton generaMosse];
    NSArray *mossePseudoLegaliArray = [mossePseudoLegali allObjects];
    
    //for (NSNumber *n in [mossePseudoLegali allObjects]) {
    //    NSLog(@"PRIMA   %d", [n intValue]);
    //}
    
    
    if ([boardModel canCaptureEnPassant]) {
        if ([pieceButton.titleLabel.text hasSuffix:@"p"]) {
            int casaEnPassant = [boardModel casaEnPassant];
            if ([boardModel whiteHasToMove] && [pieceButton.titleLabel.text hasPrefix:@"w"]) {
                int casaPedone = (int)pieceButton.tag;
                if (((casaPedone + 7) == casaEnPassant) || ((casaPedone + 9) == casaEnPassant)) {
                    [mossePseudoLegali addObject:[NSNumber numberWithInt:[boardModel casaEnPassant]]];
                }
            }
            else {
                int casaPedone = (int)pieceButton.tag;
                if (((casaPedone - 7) == casaEnPassant) || ((casaPedone - 9) == casaEnPassant)) {
                    [mossePseudoLegali addObject:[NSNumber numberWithInt:[boardModel casaEnPassant]]];
                }
            }
        }
    }
    
    mossePseudoLegaliArray = [mossePseudoLegali allObjects];
    
    for (NSNumber *n in mossePseudoLegaliArray) {
        NSInteger casaFinale = [n integerValue];
        int result = [self controllaCasaArrivo:pieceButton :casaFinale];
        if (result == -1) {
            [mossePseudoLegali removeObject:n];
        }
    }
    
    mossePseudoLegaliArray = [mossePseudoLegali allObjects];
    for (NSNumber *n in mossePseudoLegaliArray) {
        int finalSquare = (int)[n integerValue];
        if ([self reSottoScacco:finalSquare]) {
            [mossePseudoLegali removeObject:n];
        }
    }
    
    //for (NSNumber *n in [mossePseudoLegali allObjects]) {
    //    NSLog(@"DOPO   %d", [n intValue]);
    //}
    
    
    if ([boardView isHilighted:[pieceButton tag]]) {
        if ([settingManager showLegalMoves]) {
            [boardView hiLightControlledSquares:[mossePseudoLegali allObjects]];
        }
    }
    else {
        [boardView clearControlledSquares:[mossePseudoLegali allObjects]];
    }
    
    
    
    
    
    //NSLog(@"START mosse2eco");
    //[self mosse2ecoTag];
    //NSLog(@"FINE mosse2eco");
    
    return;
    
    //NSLog(@"CreaEcoFenFile Start");
    //[self creaEcoFenFile];
    //NSLog(@"CreaEcoFenFile ha terminato");
    //NSLog(@"eco2fen start");
    [self eco2fen];
    //NSLog(@"eco2fen ha terminato");
    return;
    
    
    //NSString *fen = [[pgnRootMove getLastMove] fen];
    //NSLog(@"FEN = %@", fen);
    //[boardModel stampaStackfFen];
    //[boardView stampaPezziCatturati];
    //return;
    
    
    /*
    if (_insertMode) {
        if (pieceButton) {
            NSArray *movimenti = [pieceButton movimenti];
            NSMutableString *listaMovimenti = [[NSMutableString alloc] init];
            for (NSNumber *m in movimenti) {
                NSString *mov = [m stringValue];
                [listaMovimenti appendString:mov];
                [listaMovimenti appendString:@" "];
            }
            NSLog(@"Lista dei movimenti per %@ partito da %d =   %@", pieceButton.titleLabel.text, pieceButton.casaIniziale, listaMovimenti);
        }
    
        
        
        
        //for (int k=0; k<stackFen.count; k++) {
        //    NSNumber *key = [NSNumber numberWithUnsignedInt:k];
        //    NSString *fen = [stackFen objectForKey:key];
        //    NSLog(@"%@", fen);
        //}
    }*/


    //[prossimaMossa visitaAlberoIndietro];
    //NSUInteger numMosse = [prossimaMossa getNumeroMosse:@"B"];
    //NSLog(@"Numero mosse per wn = %d", numMosse);
    //return;
    
    //NSString *fen = [boardModel fenNotation];
    //NSLog(@"FEN = %@", fen);
    
    //[boardModel setFenNotation:fen];
    
    //UIAlertView *fenAlertView = [[UIAlertView alloc] initWithTitle:@"FEN" message:fen delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //[fenAlertView show];
    
    //return;
    
    /*
    if (_insertMode) {
        if (pieceButton) {
            NSLog(@"Gestisco tocco breve di %u", [pieceButton casaIniziale]);
            NSString *titolo = [NSString stringWithFormat:@"Hai selezionato il pezzo %@", pieceButton.titleLabel.text];
            UIActionSheet *pieceActionSheet = [[UIActionSheet alloc] initWithTitle:titolo delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:@"Test1", @"Test2", nil];
            pieceActionSheet.tag = 2;
            [pieceActionSheet showFromRect:pieceButton.frame inView:boardView animated:YES];
            NSLog(@"Casa Iniziale = %u", [pieceButton casaIniziale]);
            NSArray *movimenti = [pieceButton movimenti];
            NSLog(@"Questo pezzo è stato mosso %d volte", movimenti.count);
            NSMutableString *listaMovimenti = [[NSMutableString alloc] init];
            for (NSNumber *m in movimenti) {
                NSString *mov = [m stringValue];
                [listaMovimenti appendString:mov];
                [listaMovimenti appendString:@" "];
            }
            NSLog(@"Lista dei movimenti %@", listaMovimenti);
        }
    }*/

     
    //UIAlertView *annotazioneAlertView = [[UIAlertView alloc] initWithTitle:@"Annotazione Mossa" message:@"Puoi annotare la mossa selezionata" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"!", @"!?", @"?!", @"!!", @"??", nil];
    //annotazioneAlertView.tag = 3;
    //[annotazioneAlertView show];
}

- (void) gestisciDragAndDrop:(PieceButton *)pieceButton {
    [boardView clearCanditatesPieces];
    [boardView clearHilightedAndControlledSquares];
    candidateSquareTo = -1;
}

- (BOOL) checkDragAndDrop {
    if (![settingManager dragAndDrop]) {
        UIAlertView *dragAndDropAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_DRAG_AND_DROP", nil) message:NSLocalizedString(@"SETTINGS_DRAG_AND_DROP_DISABLED", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        dragAndDropAlertView.tag = 500;
        [dragAndDropAlertView show];
        return NO;
    }
    return YES;
}

/*
- (BOOL) checkTapPieceToMove {
    if (candidateSquareTo >= 0) {
        return YES;
    }
    
    if (![settingManager tapPieceToMove]) {
        UIAlertView *tapPieceAlertView = [[UIAlertView alloc] initWithTitle:@"Tap to move" message:@"Tap Piece non permesso" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [tapPieceAlertView show];
        return NO;
    }
    return YES;
}
*/


- (int) controllaCasaArrivo:(PieceButton *)pezzo :(NSInteger)casaFinale {
    if (casaPartenza == casaFinale) {
        return -1;
    }
    if ([boardModel sonoPezziDelloStessoColore:casaPartenza :(int)casaFinale]) {
        return -1;
    }
    
    if ([pezzo.titleLabel.text hasSuffix:@"wk"] &&  casaPartenza == 4 && casaFinale == 6) {
        if ([boardModel biancoPuoArroccareCorto]) {
            return 1;
        }
        return -1;
    }
    if ([pezzo.titleLabel.text hasSuffix:@"wk"] &&  casaPartenza == 4 && casaFinale == 2) {
        if ([boardModel biancoPuoArroccareLungo]) {
            return 1;
        }
        return -1;
    }
    if ([pezzo.titleLabel.text hasSuffix:@"bk"] && casaPartenza == 60 && casaFinale == 62) {
        if ([boardModel neroPuoArroccareCorto]) {
            return 1;
        }
        return -1;
    }
    if ([pezzo.titleLabel.text hasSuffix:@"bk"] && casaPartenza == 60 && casaFinale == 58) {
        if ([boardModel neroPuoArroccareLungo]) {
            return 1;
        }
        return -1;
    }
    
    return 0;
}

- (BOOL) isSetupPosition {
    return _setupPosition;
}

- (void) checkSetupPosition:(NSUInteger)squareTag {
    //NSLog(@"Eseguo metodo piecebutton con tag = %d", squareTag);
    PieceButton *pb = [boardView findPieceBySquareTag:(int)squareTag];
    [pb removeFromSuperview];
    [boardModel setPiece:squareTag :EMPTY];
    //[boardModel printPosition];
    
    if ([boardModel isPositionForNalimovTablebase]) {
        //NSLog(@"Con questa posizione posso calcolare Nalimov Tablebase");
        boardView.layer.borderColor = [UIColor clearColor].CGColor;
        boardView.layer.borderWidth = 0.0;
        [self setupPgnGame];
        [self getNalimovResult];
    }
    else {
        //NSLog(@"Con questa posizione NON posso calcolare Nalimov Tablebase");
        [self clearNalimovTableView];
        [self setupPgnGame];
        //UIAlertView *noNalimovAlertView = [[UIAlertView alloc] initWithTitle:@"nalimov Tablebase" message:@"Analisi Nalimov Non Permessa" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[noNalimovAlertView show];
        boardView.layer.borderColor = [UIColor redColor].CGColor;
        boardView.layer.borderWidth = 8.0;
    }
    
}

- (void) setCasaPartenza:(int)fromSquareTag {
    
    if (_setupPosition) {
        //NSLog(@"Sono in modalità setup position e devo fare qualcos'altro");
        return;
    }
    
    casaPartenza = fromSquareTag;
    //NSLog(@"BoardViewController --> Casa partenza: %d", casaPartenza);
}

- (void) setCasaArrivo:(int)toSquareTag {
    casaArrivo = toSquareTag;
    //NSLog(@"BoardViewController --> Casa arrivo: %d", casaArrivo);
}

- (int) checkCasaArrivo:(int)toSquareTag {
    
    //NSLog(@"Inizio Check casa Arrivo");
    
    if (IsChessStudioLight) {
        if ([boardModel getPlyCount] > 29) {
            UIAlertView *lightAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"LIGHT_MOVES", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"OK", nil];
            lightAlertView.tag = 1000;
            [lightAlertView show];
            return -1;
        }
    }
    
    
    if (_setupPosition && !nalimovTableBase) {
        return -3;
    }
    
    if (!_pgnGame.isEditMode) {
        NSString *title = NSLocalizedString(@"TITLE_EDIT_MODE", nil);
        UIAlertView *noInsertModeAlertView = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"ALERT_NO_INSERT_MODE_2", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        noInsertModeAlertView.tag = 100;
        [noInsertModeAlertView show];
        return -1;
    }
    
    if (![boardModel colorePezzoOk:casaPartenza]) {
        //NSLog(@"Colore Pezzo non OK");
        return -1;
    }

    [self setCasaArrivo:toSquareTag];
    
    if (casaPartenza == casaArrivo) {
        return -1;
    }
    if ([boardModel sonoPezziDelloStessoColore:casaPartenza :casaArrivo]) {
        return -1;
    }
    
    pezzoMosso = [boardView findPieceBySquareTag:casaPartenza];

    //NSLog(@"Pezzo Mosso: %@ con tag %d in casa %d", pezzoMosso.titleLabel.text, pezzoMosso.tag, toSquareTag);
    //NSLog(@"Numero case concesse: %d", pezzoMosso.pseudoLegalMoves.count);
    //for (NSNumber *numb in pezzoMosso.pseudoLegalMoves) {
    //    NSLog(@"Casa concessa: %d", numb.intValue);
    //}
    
    
    //Istruzioni per ripristinare la casa enPassant quando si torna indietro con le mosse
    //NSInteger vecchiaCasaEnPassant = -1;
    if (prossimaMossa) {
        //NSLog(@"FEN MOSSA Precendente = %@ ", prossimaMossa.fen);
        [boardModel ripristinaCasaEnPassant:prossimaMossa.fen :pezzoMosso.titleLabel.text :casaPartenza :casaArrivo];
        /*
        vecchiaCasaEnPassant = [boardModel searchCasaEnPassantInFen:prossimaMossa.fen];
        NSLog(@"VECCHIA CASA EN PASSANT = %d", vecchiaCasaEnPassant);
        if (vecchiaCasaEnPassant > -1) {
            [boardModel setCanCaptureEnPassant:YES];
            [boardModel setCasaEnPassant:vecchiaCasaEnPassant];
            if ([pezzoMosso.titleLabel.text hasSuffix:@"wp"]) {
                [boardModel setColorCanCaptureEnPassant:@"w"];
            }
            else if ([pezzoMosso.titleLabel.text hasSuffix:@"bp"]) {
                [boardModel setColorCanCaptureEnPassant:@"b"];
            }
        }*/
    }
    
    
    if ([pezzoMosso.titleLabel.text hasSuffix:@"wp"] && [boardModel canCaptureEnPassant]) {
        [pezzoMosso.pseudoLegalMoves addObject:[NSNumber numberWithInt:[boardModel casaEnPassant]]];
    }
    
    if ([pezzoMosso.titleLabel.text hasSuffix:@"bp"] && [boardModel canCaptureEnPassant]) {
        [pezzoMosso.pseudoLegalMoves addObject:[NSNumber numberWithInt:[boardModel casaEnPassant]]];
    }
    
    
    
    if (![pezzoMosso.pseudoLegalMoves containsObject:[NSNumber numberWithInt:toSquareTag]]) {
        return -1;
    }
    
    NSString *contenutoCasaArrivo = [boardModel findContenutoBySquareNumber:toSquareTag];
    
    
    int sn = [boardModel convertTagValueToSquareValue:casaArrivo];
    
    if ([pezzoMosso.titleLabel.text hasSuffix:@"wk"] &&  casaPartenza == 4 && casaArrivo == 6) {
        if ([boardModel biancoPuoArroccareCorto]) {
            //NSLog(@"Devo gestire l'arrocco corto del bianco");
            //PieceButton *torre = [boardView findPieceBySquareTag:7];
            //[torre removeFromSuperview];
            //[boardView addSubview:torre];
            //[torre setSquareValue:5];
            [boardView manageCastle:4 :7];//Arrocco Corto Bianco
            return 1;
        }
        else return -1;
    }
    if ([pezzoMosso.titleLabel.text hasSuffix:@"wk"] && casaPartenza == 4 && casaArrivo == 2) {
        if ([boardModel biancoPuoArroccareLungo]) {
            //NSLog(@"Devo gestire l'arrocco lungo del bianco");
            //PieceButton *torre = [boardView findPieceBySquareTag:0];
            //[torre removeFromSuperview];
            //[boardView addSubview:torre];
            //[torre setSquareValue:3];
            [boardView manageCastle:4 :0];//Arrocco Lungo Bianco
            return 1;
        }
        else return -1;
        
    }
    if ([pezzoMosso.titleLabel.text hasSuffix:@"bk"] && casaPartenza == 60 && casaArrivo == 62) {
        if ([boardModel neroPuoArroccareCorto]) {
            //NSLog(@"Devo gestire l'arrocco corto del nero");
            //PieceButton *torre = [boardView findPieceBySquareTag:63];
            //[torre removeFromSuperview];
            //[boardView addSubview:torre];
            //[torre setSquareValue:61];
            [boardView manageCastle:60 :63];//Arrocco Corto Nero
            return 1;
        }
        else return -1;
    }
    if ([pezzoMosso.titleLabel.text hasSuffix:@"bk"] && casaPartenza == 60 && casaArrivo == 58) {
        if ([boardModel neroPuoArroccareLungo]) {
            //NSLog(@"Devo gestire l'arrocco lungo del nero");
            //PieceButton *torre = [boardView findPieceBySquareTag:56];
            //[torre removeFromSuperview];
            //[boardView addSubview:torre];
            //[torre setSquareValue:59];
            [boardView manageCastle:60 :56];
            return 1;
        }
        else return -1;
    }
    
    if ([contenutoCasaArrivo isEqualToString:EMPTY]) {   //MOSSA SENZA CATTURA
        
        if ([pezzoMosso.titleLabel.text hasSuffix:@"wp"] && [boardModel canCaptureEnPassant] && casaArrivo == [boardModel casaEnPassant]) {   //Gestione cattura EnPassant Bianco
            //PieceButton *pawn = [boardView findPieceBySquareTag:[boardModel casaEnPassant] - 8];
            //[pawn removeFromSuperview];
            
            //if (casaArrivo == [boardModel casaEnPassant]) {
                //NSLog(@"IL BIANCO CATTURA EN PASSANT nella casa %d", boardModel.casaEnPassant);
                [boardView manageCapture:[boardModel casaEnPassant] - 8];
            //}
        }
        
        if ([pezzoMosso.titleLabel.text hasSuffix:@"bp"] && [boardModel canCaptureEnPassant] && casaArrivo == [boardModel casaEnPassant]) {   //Gestione cattura EnPassant Nero
            //PieceButton *pawn = [boardView findPieceBySquareTag:[boardModel casaEnPassant] + 8];
            //[pawn removeFromSuperview];
            //if (casaArrivo == [boardModel casaEnPassant]) {
                //NSLog(@"IL NERO CATTURA EN PASSANT nella casa %d", boardModel.casaEnPassant);
                [boardView manageCapture:[boardModel casaEnPassant] + 8];
            //}
        }
        
        
        //INIZIO GESTIONE PROMOZIONE PEDONE
        
        if (!selectedMove) {
            if ([pezzoMosso.titleLabel.text hasSuffix:@"wp"] && (sn%10 == 8)) {  //Gestione Promozione Pedone Bianco senza presa
                
                
                [self showPromotionMenu:pezzoMosso.titleLabel.text :NO];
                return -2;
                
                
                if (IS_IOS_7) {
                    UIAlertView *promoView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WHITE_PROMOTION", nil) message:NSLocalizedString(@"SELECT_PIECE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"♕", @"♖", @"♗", @"♘", nil];
                    promoView.tag = 10;
                    [promoView show];
                    return -2;
                }
                
                
                UIAlertView *promoView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WHITE_PROMOTION", nil) message:NSLocalizedString(@"SELECT_PIECE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"wq", @"wr", @"wb", @"wn", nil];
                promoView.tag = 10;
                [promoView show];
                return -2;
            }
            
            if ([pezzoMosso.titleLabel.text hasSuffix:@"bp"] && (sn%10 == 1)) {  //Gestione Promozione Pedone Nero senza presa
                
                [self showPromotionMenu:pezzoMosso.titleLabel.text :NO];
                return -2;
                
                if (IS_IOS_7) {
                    UIAlertView *promoView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"BLACK_PROMOTION", nil) message:NSLocalizedString(@"SELECT_PIECE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"♛", @"♜", @"♝", @"♞", nil];
                    promoView.tag = 10;
                    [promoView show];
                    return -2;
                }
                
                
                UIAlertView *promoView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"BLACK_PROMOTION", nil) message:NSLocalizedString(@"SELECT_PIECE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"bq", @"br", @"bb", @"bn", nil];
                promoView.tag = 10;
                [promoView show];
                return -2;
            }
            return 0;
        }
    }
    
    //pezzoCatturato = [boardView findPieceBySquareTag:toSquareTag];
    //if (pezzoCatturato) {
    //    [pezzoCatturato removeFromSuperview];
    //}
    [boardView manageCapture:toSquareTag];//Se nella casella di arrivi c'è un pezzo viene catturato
    
    
    if (!selectedMove) {
        if ([pezzoMosso.titleLabel.text hasSuffix:@"wp"] && (sn%10 == 8)) { //Gestione Promozione Pedone Bianco con presa
            
            
            [self showPromotionMenu:pezzoMosso.titleLabel.text :YES];
            return -2;
            
            if (IS_IOS_7) {
                UIAlertView *promoView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WHITE_PROMOTION", nil) message:NSLocalizedString(@"SELECT_PIECE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"♕", @"♖", @"♗", @"♘", nil];
                promoView.tag = 20;
                [promoView show];
                return -2;
            }
            
            UIAlertView *promoView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WHITE_PROMOTION", nil) message:NSLocalizedString(@"SELECT_PIECE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"wq", @"wr", @"wb", @"wn", nil];
            promoView.tag = 20;
            [promoView show];
            return -2;
        }
        
        if ([pezzoMosso.titleLabel.text hasSuffix:@"bp"] && (sn%10 == 1)) { //Gestione Promozione Pedone Nero con presa
            
            
            [self showPromotionMenu:pezzoMosso.titleLabel.text :YES];
            return -2;
            
            if (IS_IOS_7) {
                UIAlertView *promoView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"BLACK_PROMOTION", nil) message:NSLocalizedString(@"SELECT_PIECE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"♛", @"♜", @"♝", @"♞", nil];
                promoView.tag = 20;
                [promoView show];
                return -2;
            }
            
            
            UIAlertView *promoView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"BLACK_PROMOTION", nil) message:NSLocalizedString(@"SELECT_PIECE", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"MENU_CANCEL", nil) otherButtonTitles:@"bq", @"br", @"bb", @"bn", nil];
            promoView.tag = 20;
            [promoView show];
            return -2;
        }
    }
    
    return 1;
}

- (BOOL) reSottoScacco:(int)toSquareTag {
    if ([boardModel sonoPezziDelloStessoColore:casaPartenza :toSquareTag]) {
        return NO;
    }
    
//    // Le istruzioni seguenti gestiscono la presa en passant quando la spinta del pedone di 2 passi ha datto lo scacco al Re.
//    if ([boardModel canCaptureEnPassant] && toSquareTag == [boardModel casaEnPassant] && [[boardModel findContenutoBySquareNumber:casaPartenza] hasSuffix:@"p"]) {
//        return NO;
//    }
//    if ([boardModel canCaptureEnPassant] && toSquareTag != [boardModel casaEnPassant] && [[boardModel findContenutoBySquareNumber:casaPartenza] hasSuffix:@"p"]) {
//        return YES;
//    }
    
    return [boardModel reSottoScacco:casaPartenza :toSquareTag];
}

- (int) checkConfiniScacchieraPerPedone:(int)casaOrigine :(int)casaDestinazione {
    int casaOrigineConvertita = [boardModel convertTagValueToSquareValue:casaOrigine];
    int differenza = casaDestinazione - casaOrigine;
    //NSLog(@"Check Confini scacchiera Pedone    Casa Origine = %d   casa Destinazione = %d    Casa Origine Convertita = %d", casaOrigine, casaDestinazione, casaOrigineConvertita);
    int destinazione;
    NSString *destinazioneString;
    switch (differenza) {
        case 8:
            destinazione = casaOrigineConvertita - 1;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case -8:
            destinazione = casaOrigineConvertita + 1;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 9:
            destinazione = casaOrigineConvertita + 11;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case -9:
            destinazione = casaOrigineConvertita - 11;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 7:
            destinazione = casaOrigineConvertita - 9;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case -7:
            destinazione = casaOrigineConvertita + 9;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        default:
            break;
    }
    return 0;
}



- (int) checkConfiniScacchieraPerAlfiere:(int)casaOrigine :(int)casaDestinazione {
    int casaOrigineConvertita = [boardModel convertTagValueToSquareValue:casaOrigine];
    int differenza = casaDestinazione - casaOrigine;
    int destinazione = 0;
    NSString *destinazioneString;
    switch (differenza) {
        case 7:
            destinazione = casaOrigineConvertita - 9;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case -7:
            destinazione = casaOrigineConvertita + 9;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case -9:
            destinazione = casaOrigineConvertita - 11;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 9:
            destinazione = casaOrigineConvertita + 11;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        default:
            break;
    }
    return 0;
}

- (int) checkConfiniScacchieraPerTorre:(int)casaOrigine :(int)casaDestinazione {
    int casaOrigineConvertita = [boardModel convertTagValueToSquareValue:casaOrigine];
    int differenza = casaDestinazione - casaOrigine;
    int destinazione = 0;
    NSString *destinazioneString;
    switch (differenza) {
        case -1:
            destinazione = casaOrigineConvertita - 10;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 1:
            destinazione = casaOrigineConvertita + 10;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case -8:
            destinazione = casaOrigineConvertita - 1;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 8:
            destinazione = casaOrigineConvertita + 1;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        default:
            break;
    }
    return 0;
}


- (int) checkConfiniScacchieraPerCavallo:(int)casaOrigine :(int)casaDestinazione {
    int casaOrigineConvertita = [boardModel convertTagValueToSquareValue:casaOrigine];
    int differenza = casaDestinazione - casaOrigine;
    int destinazione = 0;
    NSString *destinazioneString;
    switch (differenza) {
        case -10:
            destinazione = casaOrigineConvertita - 21;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 10:
            destinazione = casaOrigineConvertita + 21;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case -6:
            destinazione = casaOrigineConvertita + 19;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 6:
            destinazione = casaOrigineConvertita - 19;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case -17:
            destinazione = casaOrigineConvertita - 12;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 17:
            destinazione = casaOrigineConvertita + 12;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case -15:
            destinazione = casaOrigineConvertita + 8;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 15:
            destinazione = casaOrigineConvertita - 8;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        default:
            break;
    }
    return 0;
}

- (int) checkConfiniScacchieraPerDonnaRe:(int)casaOrigine :(int)casaDestinazione {
    int casaOrigineConvertita = [boardModel convertTagValueToSquareValue:casaOrigine];
    int differenza = casaDestinazione - casaOrigine;
    int destinazione = 0;
    NSString *destinazioneString;
    //NSLog(@"DIFFERENZA DONNA = %d", differenza);
    switch (differenza) {
        case -1:
            destinazione = casaOrigineConvertita - 10;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            //NSLog(@"DESTINAZIONE = %@", destinazioneString);
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 1:
            destinazione = casaOrigineConvertita + 10;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            //NSLog(@"DESTINAZIONE = %@", destinazioneString);
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case -8:
            destinazione = casaOrigineConvertita - 1;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            //NSLog(@"DESTINAZIONE = %@", destinazioneString);
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 8:
            destinazione = casaOrigineConvertita + 1;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            //NSLog(@"DESTINAZIONE = %@", destinazioneString);
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 7:
            destinazione = casaOrigineConvertita - 9;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            //NSLog(@"DESTINAZIONE = %@", destinazioneString);
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case -7:
            destinazione = casaOrigineConvertita + 9;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            //NSLog(@"DESTINAZIONE = %@", destinazioneString);
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case -9:
            destinazione = casaOrigineConvertita - 11;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            //NSLog(@"DESTINAZIONE = %@", destinazioneString);
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        case 9:
            destinazione = casaOrigineConvertita + 11;
            destinazioneString = [NSString stringWithFormat:@"%d", destinazione];
            //NSLog(@"DESTINAZIONE = %@", destinazioneString);
            if (![boardModel laCasaSiTrovaNeiConfiniDellaScacchiera:destinazioneString]) {
                return -1;
            }
            break;
        default:
            break;
    }
    
    return 0;
}



- (void) aggiornaWebView {
    
    
    if ([_pgnGame isEditMode]) {
        [_pgnGame setModified:YES];
    }
    
    //[self checkResultMove:mossaEseguita];
    //NSLog(@"Start AggiornaWebView");
    //NSLog(@"RESULT MOVE = %@", resultMove.fullMove);
    [pgnRootMove addResultMove:resultMove];
    
    
    [pgnRootMove resetWebArray];
    [pgnRootMove visitaAlberoAnticipato2];
    NSArray *gameArray = [pgnRootMove getGameArrayDopoAlberoAnticipato2];
    //[_gameWebView setPgnMovesArray:gameArray];
    
    //NSLog(@"%@", gameArray);
   
    [_gameWebView setRootMove:pgnRootMove];
    
    [self checkResultMove:mossaEseguita];
    [_gameWebView setPgnMovesArray:gameArray];
    
    [pgnRootMove removeResultMove];
    
    
     //NSLog(@"End AggiornaWebView");
}

- (void) aggiornaWebViewNalimov {
    
    
    if ([_pgnGame isEditMode]) {
        [_pgnGame setModified:YES];
    }
    
    //[self checkResultMove:mossaEseguita];
    //NSLog(@"Start AggiornaWebView");
    //NSLog(@"RESULT MOVE = %@", resultMove.fullMove);
    [pgnRootMove addResultMove:resultMove];
    
    
    [pgnRootMove resetWebArray];
    [pgnRootMove visitaAlberoAnticipato2];
    NSArray *gameArray = [pgnRootMove getGameArrayDopoAlberoAnticipato2];
    //[_gameWebView setPgnMovesArray:gameArray];
    
    [_gameWebView setRootMove:pgnRootMove];
    
    //[self checkResultMove:mossaEseguita];
    [_gameWebView setPgnMovesArray:gameArray];
    
    [pgnRootMove removeResultMove];
    
    
    //NSLog(@"End AggiornaWebView");
}

//- (void) aggiornaWebViewDopoButtonAvantiPressed {
    
//}



- (void) checkResultMove:(PGNMove *) mossa {
    
    if (mossa) {
        //NSLog(@"MOSSA ESISTE");
    }
    else {
        //NSLog(@"MOSSA NON ESISTE");
        return;
    }
    
    //NSLog(@"Eseguo checkresultmove");
    if ([mossa livelloVariante] > 0) {
        //NSLog(@"VARIANTE");
        return;
    }
    else {
        //NSLog(@"VARIANTE PRINCIPALE");
    }
    if ([mossa checkMate]) {
        //NSLog(@"MOSSA SCACCO MATTO = %@", mossa.fullMove);
        if ([boardModel whiteHasToMove]) {
            //resultMove = [[PGNMove alloc] initWithFullMove:@"0-1"];
            [resultMove setMove:@"0-1"];
            [resultMove setFullMove:@"0-1"];
            [resultMove setEndGameMark:@"0-1"];
        }
        else if (![boardModel whiteHasToMove]) {
            //resultMove = [[PGNMove alloc] initWithFullMove:@"1-0"];
            [resultMove setMove:@"1-0"];
            [resultMove setFullMove:@"1-0"];
            [resultMove setEndGameMark:@"1-0"];
        }
        [_pgnGame setCheckMate:YES];
    }
    else {
        //NSLog(@"MOSSA NORMALE = %@", mossa.fullMove);
        //resultMove = [[PGNMove alloc] initWithFullMove:@"*"];
        //[resultMove setMove:@"*"];
        //[resultMove setFullMove:@"*"];
        //[resultMove setEndGameMark:@"*"];
        [_pgnGame setCheckMate:NO];
    }
}


- (void) gestisciMossaCompleta {
    //NSLog(@"INIZIO   Gestisci Mossa Completa");
    
    //PGNMove *pgnMove = nil;
    mossaEseguita = nil;
    
    //if (boardModel.canCaptureEnPassant) {
        //mossaEseguita = [boardModel completaMossaEnPassant:casaPartenza :casaArrivo];
        mossaEseguita = [boardModel muoviPezzo:casaPartenza :casaArrivo];
    //}
    //else {
        //mossaEseguita = [boardModel muoviPezzo:casaPartenza :casaArrivo];
    //}
    
    /*
    if ([mossaEseguita checkMate]) {
        if ([boardModel whiteHasToMove]) {
            resultMove = [[PGNMove alloc] initWithFullMove:@"0-1"];
        }
        else if (![boardModel whiteHasToMove]) {
            resultMove = [[PGNMove alloc] initWithFullMove:@"1-0"];
        }
    }
    else {
        resultMove = [[PGNMove alloc] initWithFullMove:@"*"];
    }
    */
    
    /*
    if ([boardModel kingCheckedMate]) {
        NSLog(@"Il re é matto");
    }
    else {
        NSLog(@"Il Re non è matto");
    }*/
    
    
    //NSLog(@"ULTIMA MOSSA INSERITA %@", _ultimaMossa);
    //NSLog(@"PLYCOUNT = %d", [boardModel getPlyCount]);
    //NSLog(@"MOSSA ESEGUITA = %@", [mossaEseguita getMossaDaStampare]);
    
    
    BOOL mossaDuplicata = NO;
    if ([prossimaMossa getNextMoves]) {
        for (PGNMove *pgnMoveGiaInserita  in [prossimaMossa getNextMoves]) {
            if ([mossaEseguita isEqualToMove:pgnMoveGiaInserita ]) {
                NSLog(@"Hai inserito una mossa già presente: %@", mossaEseguita.fullMove);
                mossaEseguita = pgnMoveGiaInserita;
                mossaDuplicata = YES;
                break;
            }
        }
    }
    
    if (mossaDuplicata) {
        [prossimaMossa setEvidenzia:NO];
        prossimaMossa = mossaEseguita;
        [mossaEseguita setEvidenzia:YES];
    }
    
    if (!mossaDuplicata) {
        if (![prossimaMossa getNextMoves]) {
            [prossimaMossa setEvidenzia:NO];
            [mossaEseguita setEvidenzia:YES];
            [prossimaMossa addNextMove:mossaEseguita];
            [mossaEseguita addPrevMove:prossimaMossa];
            prossimaMossa = mossaEseguita;
        }
        else {
            //NSLog(@"Devo gestire l'inserimento di una nuova variante");
            //NSLog(@"PLYCOUNT PER QUESTA MOSSA = %d", mossaEseguita.plyCount);
            NSString *message = [mossaEseguita getMossaPerVarianti];
            NSString *title = NSLocalizedString(@"NEW_MOVE", nil);
            NSString *cancel = NSLocalizedString(@"MENU_CANCEL", nil);
            UIAlertView *newVarAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:nil, nil];
            [newVarAlertView addButtonWithTitle:NSLocalizedString(@"NEW_VARIATION", nil)];
            [newVarAlertView addButtonWithTitle:NSLocalizedString(@"NEW_MAIN_LINE", nil)];
            [newVarAlertView addButtonWithTitle:NSLocalizedString(@"OVERWRITE", nil)];
            newVarAlertView.tag = 200;
            [newVarAlertView show];
            return;
        }
    }
    

    
    if (boardModel.getPlyCount>0) {
        stopNextMove = NO;
        stopPrevMove = NO;
    }
    
    [self evidenziaAChiToccaMuovere];
    
    //Le seguenti istruzioni servono per spostare il commento di inizio partita alla prima mossa della partita
    if ([mossaEseguita isFirstMoveAfterRoot]) {
        if ([pgnRootMove textAfterWithGraffe]) {
            NSString *rootMoveTextAfter = [pgnRootMove textAfterWithGraffe];
            [mossaEseguita setTextBefore:rootMoveTextAfter];
            [pgnRootMove setTextAfter:nil];
        }
    }
    
    //[pgnGame insertMove:mossaEseguita];
    
    //[_gameWebView addLastMove:pgnGame];
    
    //[boardModel listaMosse];
    
    
    casaPartenza = -1;
    casaArrivo = -1;
    pezzoCatturato = nil;
    
    //NSLog(@"BOARDVIEWCONTROLLER: CASA PARTENZA = %d    CASA ARRIVO = %d", mossaEseguita.fromSquare, mossaEseguita.toSquare);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [pgnParser parseMoveForward:mossaEseguita];
        //[self aggiornaWebView];
        
        //NSLog(@"BOARDVIEWCONTROLLER: CASA PARTENZA = %d    CASA ARRIVO = %d", mossaEseguita.fromSquare, mossaEseguita.toSquare);
        
        [mossaEseguita setFen:[boardModel fenNotation]];
        //NSLog(@"FEN DELLA MOSSA APPENA ESEGUITA = %@", mossaEseguita.fen);
        
        
        [self sendMoveToEngine:mossaEseguita];
        [self aggiornaWebView];
        
        
        //[pgnRootMove visitaAlberoToGetMainLine];
        
        //NSLog(@"GAME   =   %@", [pgnRootMove getGameDopoAlberoAnticipato2]);
        
        //[_gameWebView setGameToViewArray:[pgnRootMove getGameArrayDopoAlberoAnticipato2]];
        //[_gameWebView setGameArray:[pgnRootMove getGameArrayDopoAlberoAnticipato2] :mossaEseguita];
        //[_gameWebView setWebGameArray:[pgnRootMove getGameArrayDopoAlberoAnticipato2]];
        
        
        
        //NSLog(@"FEN MOSSA INSERITA = %@", mossaEseguita.fen);
        
        //NSLog(@"gestisciMossaCompleta:   %@", [pgnRootMove getGameWithNagsDopoAlberoAnticipato2]);
        [_pgnGame setMoves:[pgnRootMove getGameWithNagsDopoAlberoAnticipato2]];
        
        
        //[self trovaECO];
        [bookManager interrogaBook:[mossaEseguita fen]];
        
        
        
        //if (!_setupPosition) {
            [self performSelectorOnMainThread:@selector(getNalimovResult) withObject:nil waitUntilDone:YES];
        //}
        
    });
    
    //[_gameWebView addLastMove:pgnGame];
    
    //[_gameWebView addMove:mossaEseguita];
    
    //[stackFen setObject:[boardModel fenNotation] forKey:[NSNumber numberWithUnsignedInt:[boardModel getPlyCount]]];
    
    //NSLog(@"MOVES:   %@", [pgnRootMove getGameWithNagsDopoAlberoAnticipato2]);
    
    //[_pgnGame setMoves:[pgnRootMove getGameWithNagsDopoAlberoAnticipato2]];  //Sembra inutile questa istruzione
    
    
    //[boardModel printPosition];
    
    //NSLog(@"PARTITA:    %@", _pgnGame.moves);
    
    //NSLog(@"FINE   Gestisci Mossa Completa");
}

- (void) gestisciMossaCompletaConPromozione:(NSString *)pezzoPromosso {
    //NSLog(@"Ho promosso il pedone dalla casa %d alla casa %d", casaPartenza, casaArrivo);
    //NSLog(@"Il pezzo promosso è %@", pezzoPromosso);
    //PGNMove *pgnMove = [boardModel promuoviPezzo:casaPartenza :casaArrivo :pezzoPromosso];
    
    mossaEseguita = nil;
    mossaEseguita = [boardModel promuoviPezzo:casaPartenza :casaArrivo :pezzoPromosso];
    
    //NSLog(@"MOSSA ESEGUITA = %@", [pgnMove getMossaDaStampare]);
    //NSLog(@"MOSSA ESEGUITA = %@", [mossaEseguita getMossaDaStampare]);
    
    
    BOOL mossaDuplicata = NO;
    if ([prossimaMossa getNextMoves]) {
        for (PGNMove *pgnMoveGiaInserita  in [prossimaMossa getNextMoves]) {
            //NSLog(@"Mossa già inserita = %@", [pgnMoveGiaInserita getMossaDaStampare]);
            if ([mossaEseguita isEqualToMove:pgnMoveGiaInserita]) {
                //NSLog(@"Hai inserito una mossa già presente: %@", mossaEseguita.fullMove);
                mossaEseguita = pgnMoveGiaInserita;
                mossaDuplicata = YES;
                break;
            }
        }
    }
    
    if (mossaDuplicata) {
        [prossimaMossa setEvidenzia:NO];
        prossimaMossa = mossaEseguita;
        [mossaEseguita setEvidenzia:YES];
    }
    
    if (!mossaDuplicata) {
        if (![prossimaMossa getNextMoves]) {
            [prossimaMossa setEvidenzia:NO];
            [mossaEseguita setEvidenzia:YES];
            [prossimaMossa addNextMove:mossaEseguita];
            [mossaEseguita addPrevMove:prossimaMossa];
            prossimaMossa = mossaEseguita;
        }
        else {
            //NSLog(@"Devo gestire l'inserimento di una nuova variante");
            NSString *message = [mossaEseguita getMossaPerVarianti];
            NSString *title = NSLocalizedString(@"NEW_MOVE", nil);
            NSString *cancel = NSLocalizedString(@"MENU_CANCEL", nil);
            UIAlertView *newVarAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:nil, nil];
            [newVarAlertView addButtonWithTitle:NSLocalizedString(@"NEW_VARIATION", nil)];
            [newVarAlertView addButtonWithTitle:NSLocalizedString(@"NEW_MAIN_LINE", nil)];
            [newVarAlertView addButtonWithTitle:NSLocalizedString(@"OVERWRITE", nil)];
            newVarAlertView.tag = 200;
            [newVarAlertView show];
            return;
        }
    }
    
    
    /*
    [prossimaMossa setEvidenzia:NO];
    [mossaEseguita setEvidenzia:YES];
    
    //[prossimaMossa addNextMove:pgnMove];
    [prossimaMossa addNextMove:mossaEseguita];
    //[pgnMove addPrevMove:prossimaMossa];
    [mossaEseguita addPrevMove:prossimaMossa];
    //prossimaMossa = pgnMove;
    prossimaMossa = mossaEseguita;
    */
    
    if (boardModel.getPlyCount>0) {
        stopNextMove = NO;
        stopPrevMove = NO;
    }
    
    
    [self evidenziaAChiToccaMuovere];
    //[pgnGame insertMove:pgnMove];
    //[_gameWebView addLastMove:pgnGame];
    
    
    if ([mossaEseguita isFirstMoveAfterRoot]) {
        if ([pgnRootMove textAfterWithGraffe]) {
            NSString *rootMoveTextAfter = [pgnRootMove textAfterWithGraffe];
            [mossaEseguita setTextBefore:rootMoveTextAfter];
            [pgnRootMove setTextAfter:nil];
        }
    }
    
    
    casaPartenza = -1;
    casaArrivo = -1;
    pezzoCatturato = nil;
    pedoneAppenaPromosso = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[pgnParser parseMoveForward:pgnMove];
        //[pgnRootMove visitaAlberoAnticipato2];
        //[_gameWebView setGameToViewArray:[pgnRootMove getGameArrayDopoAlberoAnticipato2]];
        //[pgnParser parseMoveForward:pgnMove];
        [pgnParser parseMoveForward:mossaEseguita];
        
        [mossaEseguita setFen:[boardModel fenNotation]];
        
        [self sendMoveToEngine:mossaEseguita];
        [self aggiornaWebView];
        
        
        //NSLog(@"FEN DOPO PROMOZIONE = %@", mossaEseguita.fen);
        
        //NSLog(@"gestisciMossaCompletaConPromozione:   %@", [pgnRootMove getGameWithNagsDopoAlberoAnticipato2]);
        [_pgnGame setMoves:[pgnRootMove getGameWithNagsDopoAlberoAnticipato2]];
        
        
        //[self trovaECO];
        
        
        [self performSelectorOnMainThread:@selector(getNalimovResult) withObject:nil waitUntilDone:YES];
        
    });
    
    //NSMutableArray *movesArray = (NSMutableArray *)[boardModel.listaMosse componentsSeparatedByString:@" "];
    //[_gameWebView setMovesArray:movesArray];
}


- (void) gestisciCancelSuInserimentoVarianti {
    
    if ([mossaEseguita promoted]) {
        //NSLog(@"Devo gestire Cancel su una promozione");
        if (mossaEseguita.capture) {
            //NSLog(@"Devo gestire cancel su una promozione con cattura");
            PieceButton *pb = [boardView findPieceBySquareTag:casaArrivo];
            [pb removeFromSuperview];
            PieceButton *pezzoCatturatoInPromozione = [boardView getLastCapturedPiece];
            [pedoneAppenaPromosso setSquareValue:casaPartenza];
            [boardView addSubview:pezzoCatturatoInPromozione];
            [boardView addSubview:pedoneAppenaPromosso];
            [mossaEseguita setFromSquare:casaPartenza];
            [mossaEseguita setToSquare:casaArrivo];
            [mossaEseguita setCaptured:pezzoCatturatoInPromozione.titleLabel.text];
            [boardModel mossaIndietroConPromozione:mossaEseguita];
            casaPartenza = -1;
            casaArrivo = -1;
            pezzoCatturato = nil;
            pedoneAppenaPromosso = nil;
            //[boardModel printPosition];
            return;
        }
        else {
            //NSLog(@"Devo gestire cancel su una promozione senza cattura");
            PieceButton *pb = [boardView findPieceBySquareTag:casaArrivo];
            [pb removeFromSuperview];
            [pedoneAppenaPromosso setSquareValue:casaPartenza];
            [boardView addSubview:pedoneAppenaPromosso];
            [mossaEseguita setFromSquare:casaPartenza];
            [mossaEseguita setToSquare:casaArrivo];
            [mossaEseguita setCaptured:pb.titleLabel.text];
            [boardModel mossaIndietroConPromozione:mossaEseguita];
            casaPartenza = -1;
            casaArrivo = -1;
            pezzoCatturato = nil;
            pedoneAppenaPromosso = nil;
            //[boardModel printPosition];
            return;
        }
    }

    if (mossaEseguita.capture) {
        pezzoCatturato = [boardView getLastCapturedPiece];
        [boardView manageCaptureBack];
    }
    [boardView muoviPezzoIndietro:casaArrivo :casaPartenza :nil];
    NSString *pezzoMangiato = EMPTY;
    if (pezzoCatturato) {
        //NSLog(@"Pezzocatturato = %@", pezzoCatturato.titleLabel.text);
        pezzoMangiato = pezzoCatturato.titleLabel.text;
    }
    [boardModel mossaIndietro:casaArrivo :casaPartenza :pezzoMangiato];
    //[boardModel mossaIndietro:mossaEseguita.toSquare :mossaEseguita.fromSquare :mossaEseguita.captured];
    casaPartenza = -1;
    casaArrivo = -1;
    pezzoCatturato = nil;
    pedoneAppenaPromosso = nil;
}

- (void) gestisciSovrascriviSuInserimentoVarianti {
    
    PGNMove *primaMossa = nil;
    if (![prossimaMossa fullMove]) {
        //NSLog(@"Devo vediere se esiste un commento iniziale");
        primaMossa = [pgnRootMove getFirstMoveAfterRoot];
        //NSLog(@"Prima mossa dopo root = %@", primaMossa.fullMove);
    }
    
    [prossimaMossa setEvidenzia:NO];
    [prossimaMossa overwriteNextMoves:mossaEseguita];
    [mossaEseguita addPrevMove:prossimaMossa];
    prossimaMossa = mossaEseguita;
    [mossaEseguita setEvidenzia:YES];
    
    
    //Devo gestire l'eventuale commento iniziale che è memorizzato in textBefore di prossimaMossa
    if (primaMossa) {
        if ([primaMossa textBeforeWithGraffe]) {
            //NSLog(@"C'è un testo iniziale = %@", [primaMossa textBeforeWithGraffe]);
            [mossaEseguita setTextBefore:[primaMossa textBeforeWithGraffe]];
            [primaMossa setTextBefore:nil];
        }
    }
    
    
    if (boardModel.getPlyCount>0) {
        stopNextMove = NO;
        stopPrevMove = NO;
    }
    
    [self evidenziaAChiToccaMuovere];
    
    //[pgnGame insertMove:mossaEseguita];
    
    //[_gameWebView addLastMove:pgnGame];
    
    [boardModel listaMosse];
    
    casaPartenza = -1;
    casaArrivo = -1;
    pezzoCatturato = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [pgnParser parseMoveForward:mossaEseguita];
        //[pgnRootMove visitaAlberoAnticipato2];
        //[_gameWebView setGameToViewArray:[pgnRootMove getGameArrayDopoAlberoAnticipato2]];
        
        [mossaEseguita setFen:[boardModel fenNotation]];
        
        [self sendMoveToEngine:mossaEseguita];
        [self aggiornaWebView];
        
        
        
        //[self sendMoveToEngine:mossaEseguita];
        
        //NSLog(@"gestisciSovrascriviVarianti:   %@", [pgnRootMove getGameWithNagsDopoAlberoAnticipato2]);
        [_pgnGame setMoves:[pgnRootMove getGameWithNagsDopoAlberoAnticipato2]];
        
        
        [self performSelectorOnMainThread:@selector(getNalimovResult) withObject:nil waitUntilDone:YES];
        
        //[self trovaECO];
    });
}

- (void) gestisciNuovaVarianteSuInserimentoVarianti {
    [prossimaMossa setEvidenzia:NO];
    [mossaEseguita setEvidenzia:YES];
    [prossimaMossa addNextMove:mossaEseguita];
    [mossaEseguita addPrevMove:prossimaMossa];
    prossimaMossa = mossaEseguita;
    
    if (boardModel.getPlyCount>0) {
        stopNextMove = NO;
        stopPrevMove = NO;
    }
    
    [self evidenziaAChiToccaMuovere];
    
    //[pgnGame insertMove:mossaEseguita];
    
    //[_gameWebView addLastMove:pgnGame];
    
    //[boardModel listaMosse];
    
    casaPartenza = -1;
    casaArrivo = -1;
    pezzoCatturato = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [pgnParser parseMoveForward:mossaEseguita];
        //[pgnRootMove visitaAlberoAnticipato2];
        //[_gameWebView setWebGameArray:[pgnRootMove getGameArrayDopoAlberoAnticipato2]];
        
        [mossaEseguita setFen:[boardModel fenNotation]];
        
        [self sendMoveToEngine:mossaEseguita];
        [self aggiornaWebView];
        
        //NSLog(@"FEN DELLA MOSSA APPENA ESEGUITA = %@", mossaEseguita.fen);
        
        
        //[self sendMoveToEngine:mossaEseguita];
        
        //NSLog(@"gestisciNuovavariante:   %@", [pgnRootMove getGameWithNagsDopoAlberoAnticipato2]);
        [_pgnGame setMoves:[pgnRootMove getGameWithNagsDopoAlberoAnticipato2]];
        
        
        [self performSelectorOnMainThread:@selector(getNalimovResult) withObject:nil waitUntilDone:YES];
        
        //[self trovaECO];
    });
    

    
}

- (void) gestisciNuovaLineaPrincipaleSuInserimentoVarianti {
    //NSLog(@"ProssimaMossa = %@", prossimaMossa.fullMove);
    
    PGNMove *primaMossa = nil;
    if (![prossimaMossa fullMove]) {
        //NSLog(@"Devo vediere se esiste un commento iniziale");
        primaMossa = [pgnRootMove getFirstMoveAfterRoot];
        //NSLog(@"Prima mossa dopo root = %@", primaMossa.fullMove);
    }
    
    
    [prossimaMossa setEvidenzia:NO];
    [prossimaMossa promoteNextMoveToMainLine:mossaEseguita];
    [mossaEseguita addPrevMove:prossimaMossa];
    
    
    //Devo gestire l'eventuale commento iniziale che è memorizzato in textBefore di prossimaMossa
    if (primaMossa) {
        if ([primaMossa textBeforeWithGraffe]) {
            //NSLog(@"C'è un testo iniziale = %@", [primaMossa textBeforeWithGraffe]);
            [mossaEseguita setTextBefore:[primaMossa textBeforeWithGraffe]];
            [primaMossa setTextBefore:nil];
        }
    }
    
    
    prossimaMossa = mossaEseguita;
    [mossaEseguita setEvidenzia:YES];
    
    if (boardModel.getPlyCount>0) {
        stopNextMove = NO;
        stopPrevMove = NO;
    }
    
    [self evidenziaAChiToccaMuovere];
    
    //[pgnGame insertMove:mossaEseguita];
    
    //[_gameWebView addLastMove:pgnGame];
    
    [boardModel listaMosse];
    
    casaPartenza = -1;
    casaArrivo = -1;
    pezzoCatturato = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [pgnParser parseMoveForward:mossaEseguita];
        
        [mossaEseguita setFen:[boardModel fenNotation]];
        
        
        [self sendMoveToEngine:mossaEseguita];
        
        [self aggiornaWebView];
        
        //NSLog(@"gestisciNuovaLineaPrincipale:   %@", [pgnRootMove getGameWithNagsDopoAlberoAnticipato2]);
        [_pgnGame setMoves:[pgnRootMove getGameWithNagsDopoAlberoAnticipato2]];
        
        [self performSelectorOnMainThread:@selector(getNalimovResult) withObject:nil waitUntilDone:YES];
        
        //[self trovaECO];
    });
}

- (void) gestisciUndoLastMove {
    PGNMove *primaMossa = nil;
    if (![prossimaMossa fullMove]) {
        //NSLog(@"Devo vediere se esiste un commento iniziale");
        primaMossa = [pgnRootMove getFirstMoveAfterRoot];
        //NSLog(@"Prima mossa dopo root = %@", primaMossa.fullMove);
    }
    
    
    //NSLog(@"MOSSA ESEGUITA = %@", mossaEseguita);
    //NSLog(@"PROSSIMA MOSSA = %@", prossimaMossa);
    
    [prossimaMossa setEvidenzia:NO];
    [prossimaMossa undoLastMove];
    //[mossaEseguita addPrevMove:prossimaMossa];
    //prossimaMossa = mossaEseguita;
    //[mossaEseguita setEvidenzia:YES];
    
    
    //Devo gestire l'eventuale commento iniziale che è memorizzato in textBefore di prossimaMossa
    if (primaMossa) {
        if ([primaMossa textBeforeWithGraffe]) {
            //NSLog(@"C'è un testo iniziale = %@", [primaMossa textBeforeWithGraffe]);
            //[mossaEseguita setTextBefore:[primaMossa textBeforeWithGraffe]];
            [primaMossa setTextBefore:nil];
        }
    }
    
    
    if (boardModel.getPlyCount>0) {
        stopNextMove = NO;
        stopPrevMove = NO;
    }
    
    [self evidenziaAChiToccaMuovere];
    
    //[pgnGame insertMove:mossaEseguita];
    
    //[_gameWebView addLastMove:pgnGame];
    
    [boardModel listaMosse];
    
    casaPartenza = -1;
    casaArrivo = -1;
    pezzoCatturato = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[pgnParser parseMoveForward:mossaEseguita];
        //[pgnRootMove visitaAlberoAnticipato2];
        //[_gameWebView setGameToViewArray:[pgnRootMove getGameArrayDopoAlberoAnticipato2]];
        
        //[mossaEseguita setFen:[boardModel fenNotation]];
        
        //[self sendMoveToEngine:mossaEseguita];
        [self aggiornaWebView];
        
        
        
        //[self sendMoveToEngine:mossaEseguita];
        
        //NSLog(@"gestisciSovrascriviVarianti:   %@", [pgnRootMove getGameWithNagsDopoAlberoAnticipato2]);
        [_pgnGame setMoves:[pgnRootMove getGameWithNagsDopoAlberoAnticipato2]];
        
        
        //[self trovaECO];
    });
}


- (void) trovaECO {
    /*
    if (!fen2eco) {
        return;
    }
    NSString *tempEco = [fen2eco objectForKey:mossaEseguita.fen];
    if (tempEco) {
        ECO = tempEco;
    }
    if (ECO) {
        //NSLog(@"ECO = %@", ECO);
    }
    else {
        //NSLog(@"ECO non disponibile");
    }*/
}


- (void) trovaECO:(PGNMove *) pgnMove {
    
    if (openingBookManager) {
        NSArray *opArray = [openingBookManager getOpening:[pgnMove fenForBookMoves]];
        
        //NSLog(@"**************************   ECO    **************************");
        //for (NSString *op in opArray) {
            //NSLog(@"%@", op);
        //}
        //NSLog(@"**************************   ECO    **************************");
        
        NSMutableString *ecoString = [[NSMutableString alloc] init];
        for (NSString *s in opArray) {
            [ecoString appendString:s];
            [ecoString appendString:@" "];
        }
        //NSLog(@"ECO STRING LENGTH = %d", ecoString.length);
        if (ecoString.length == 0) {
            ecoString = nil;
        }
        
        //NSLog(@"ECO STRING = %@", ecoString);
        
        [_gameWebView setOpening:ecoString];
    }
}

- (void) trovaECOConFen:(NSString *)fen {
    NSArray *fenArray;
    fenArray = [fen componentsSeparatedByString:@" "];
    NSMutableString *newFen = [[NSMutableString alloc] init];
    for (int i=0; i<3; i++) {
        [newFen appendString:[fenArray objectAtIndex:i]];
        [newFen appendString:@" "];
    }
    [newFen appendString:@"-"];

    if (openingBookManager) {
        NSArray *opArray = [openingBookManager getOpening:newFen];
        NSMutableString *ecoString = [[NSMutableString alloc] init];
        for (NSString *s in opArray) {
            [ecoString appendString:s];
            [ecoString appendString:@" "];
        }
        //NSLog(@"ECO STRING LENGTH = %d", ecoString.length);
        if (ecoString.length == 0) {
            ecoString = nil;
        }
        [_gameWebView setOpening:ecoString];
    }

}

- (void) trovaBook:(PGNMove *) pgnMove {
    if (openingBookManager) {
        
        //NSLog(@"MOSSA = %@", [pgnMove getCompleteMove]);
        //NSLog(@"Devo trovare Book Moves per FEN = %@", [pgnMove fenForBookMoves]);
        
        NSArray *bookMovesArray = [openingBookManager getBookMovesArrayForFen:[pgnMove fenForBookMoves]];
        NSArray *bookMoves = [bookMovesArray objectAtIndex:0];
        bookMovesForTap = [bookMovesArray objectAtIndex:1];
        //for (NSString *s in bookMovesArray) {
        //    NSLog(@"%@", s);
        //}
        [_gameWebView setBookMovesArray:bookMoves];
    }
    
    if (bookManager) {
        NSString *bookMoves = [bookManager getBookMoves:[pgnMove fen]];
        [_gameWebView setBookMoves:bookMoves];
    }
}

- (void) trovaBookConFen:(NSString *)fen {
    NSArray *fenArray;
    fenArray = [fen componentsSeparatedByString:@" "];
    NSMutableString *newFen = [[NSMutableString alloc] init];
    for (int i=0; i<3; i++) {
        [newFen appendString:[fenArray objectAtIndex:i]];
        [newFen appendString:@" "];
    }
    [newFen appendString:@"-"];
    
    if (openingBookManager) {
        
        NSArray *bookMovesArray = [openingBookManager getBookMovesArrayForFen:newFen];
        NSArray *bookMoves = [bookMovesArray objectAtIndex:0];
        bookMovesForTap = [bookMovesArray objectAtIndex:1];
        //for (NSString *s in bookMovesArray) {
        //    NSLog(@"%@", s);
        //}
        [_gameWebView setBookMovesArray:bookMoves];
    }
    
    if (bookManager) {
        NSString *bookMoves = [bookManager getBookMoves:newFen];
        [_gameWebView setBookMoves:bookMoves];
    }
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString *numeroMossaSelezionata = [[[request URL] path] lastPathComponent];
        
        if ([numeroMossaSelezionata hasPrefix:@"b"]) {
            NSLog(@"Hai selezionato %@", numeroMossaSelezionata);
            NSString *indexString = [numeroMossaSelezionata stringByReplacingOccurrencesOfString:@"b" withString:@""];
            NSLog(@"Index String = %@", indexString);
            NSString *bookMove = [bookMovesForTap objectAtIndex:[indexString intValue]];
            
            NSString *fromSquare = [bookMove substringToIndex:2];
            NSString *toSquare = [bookMove substringFromIndex:2];
            
            //NSString *msg = [NSString stringWithFormat:@"%@ %@", fromSquare, toSquare];
            
            casaPartenza = [boardModel getSquareTagFromAlgebricValue:fromSquare];
            casaArrivo = [boardModel getSquareTagFromAlgebricValue:toSquare];
            [self gestisciMossaCompleta];
            
            //[boardModel printPosition];
            //prossimaMossa = mossaEseguita;
            //stopNextMove = NO;
            //[self showNextMove:mossaEseguita];
            
            
            //msg = [NSString stringWithFormat:@"%d %d", casaPartenza, casaArrivo];
            //UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //[av show];
            
            [self performSelector:@selector(aggiornaScacchiera) withObject:nil afterDelay:0.1];
            
            //[boardView muoviPezzoAvanti:mossaEseguita];
            
            return YES;
        }
        

        int numeroMossafinale = [numeroMossaSelezionata intValue];
        
        PGNMove *pgnMoveSel = [_gameWebView getMoveByNumber:numeroMossafinale];
        
        if ([pgnMoveSel evidenzia]) {
            CGRect rect = CGRectMake(_gameWebView.lastTouchPosition.x, _gameWebView.lastTouchPosition.y, 5.0, 10.0);
            
            [self becomeFirstResponder];
            
            
            
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            UIMenuItem *insVarItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"MENU_CONTROLLER_INS_VARIANT", nil) action:@selector(insVarMenuPressed:)];
            UIMenuItem *addAnnotationItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"MENU_CONTROLLER_ADD_ANNOTATION", nil) action:@selector(addAnnotationMenuPressed:)];
            UIMenuItem *addTextItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"MENU_CONTROLLER_ADD_TEXT", nil) action:@selector(addTextMenuPressed:)];
            UIMenuItem *delVariantItem = nil;
            UIMenuItem *promoteVarItem = nil;
            if ([prossimaMossa inVariante]) {
                delVariantItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"DELETE_VARIATION", nil) action:@selector(delVariantMenuPressed:)];
                promoteVarItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"PROMOTE_VARIATION", nil) action:@selector(promoteVariantMenuPressed:)];
            }
            
            [menuController setMenuItems:[NSArray arrayWithObjects:insVarItem, addAnnotationItem, addTextItem, delVariantItem, promoteVarItem, nil]];
            [menuController setTargetRect:rect inView:_gameWebView];
            [menuController setMenuVisible:YES animated:YES];
            
            //UIViewController *controller = [[UIViewController alloc] init];
            //[controller.view setBackgroundColor:[UIColor clearColor]];
            //UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
            //[popover presentPopoverFromRect:rect inView:_gameWebView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

            return NO;
        }
        
        
        
        [boardModel setFenNotation:[pgnMoveSel fen]];
        [pgnParser setFenPosition:[pgnMoveSel fen]];
        [self clearBoardView];
        [self setupInitialPosition];
        prossimaMossa = pgnMoveSel;
        [prossimaMossa setEvidenzia:YES];
        
        [self trovaECO:prossimaMossa];
        [self trovaBook:prossimaMossa];
        
        [_gameWebView aggiornaWebViewAvanti:prossimaMossa];
        if ([prossimaMossa getNextMoves]) {
            stopNextMove = NO;
        }
        else {
            stopNextMove = YES;
        }
        if (prossimaMossa.plyCount == 0) {
            stopPrevMove = YES;
        }
        else {
            stopPrevMove = NO;
        }
        [self evidenziaAChiToccaMuovere];
        
        [self sendMoveToEngine:prossimaMossa];
        

        [boardView managePawnStructure];
        
        [self getNalimovResult];
        
        return YES;
        
    }
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    //NSLog(@"webViewDidFinishLoad");
    //NSString *javascript = @"document.getElementById(\"mossaevidenziata\").scrollIntoView(false);";
    
    NSString *javascript = @"document.getElementById(\"selected\").scrollIntoView(false);";
    [webView stringByEvaluatingJavaScriptFromString:javascript];
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];//Impedisci il touch pressed su UIWebView che fa comparire la finestra Open/Copy
    return;
    
    CGFloat offsetHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    CGFloat clientHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.clientHeight"] floatValue];
    NSLog(@"offsetHeight = %f       clientheight = %f", offsetHeight, clientHeight);
    
    //CGFloat offsetTop = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"mossaevidenziata\").offsetTop;"] floatValue];
    CGFloat offsetTop = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"selected\").offsetTop;"] floatValue];
    NSLog(@"OffsetTop = %f", offsetTop);
    CGFloat innerHeight = [[webView stringByEvaluatingJavaScriptFromString:@"window.innerHeight"] floatValue];
    NSLog(@"InnerHeight = %f", innerHeight);
    
    if ((innerHeight - offsetTop) < 23) {
        NSLog(@"Devo muovere su di una riga");
        //NSString *javascript = [NSString stringWithFormat:@"window.scrollBy(0, %f);", 23.0];
        //NSString *javascript = @"document.getElementById(\"mossaevidenziata\").scrollIntoView(false);";
        NSString *javascript = @"document.getElementById(\"selected\").scrollIntoView(false);";
        [webView stringByEvaluatingJavaScriptFromString:javascript];
    }
}


- (void) aggiornaScacchiera {
    [boardView muoviPezzoAvanti:mossaEseguita];
}

- (void) insVarMenuPressed:(id)sender {
    if (!_pgnGame.isEditMode) {
        NSString *title = NSLocalizedString(@"TITLE_EDIT_MODE", nil);
        UIAlertView *noInsertModeAlertView = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"ALERT_NO_INSERT_MODE_2", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        noInsertModeAlertView.tag = 100;
        [noInsertModeAlertView show];
        return;
    }
    [self indietroButtonPressed:nil];
    [self getNalimovResult];
}

- (void) addAnnotationMenuPressed:(id)sender {
    if (!_pgnGame.isEditMode) {
        NSString *title = NSLocalizedString(@"TITLE_EDIT_MODE", nil);
        UIAlertView *noInsertModeAlertView = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"ALERT_NO_INSERT_MODE_2", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        noInsertModeAlertView.tag = 100;
        [noInsertModeAlertView show];
        return;
    }
    if (IS_PAD) {
        CGRect rect = CGRectMake(_gameWebView.lastTouchPosition.x, _gameWebView.lastTouchPosition.y, 5.0, 10.0);
        amtvc = [[AnnotationMoveTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        amtvc.delegate = self;
        [amtvc setMossaDaAnnotare:prossimaMossa];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:amtvc];
        annotationMovePopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
            dispatch_async(dispatch_get_main_queue(), ^{
                [annotationMovePopoverController presentPopoverFromRect:rect inView:_gameWebView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            });
    }
    else {
        [self addAnnotationToMove];
    }
}

- (void) addTextMenuPressed:(id)sender {
    if (!_pgnGame.isEditMode) {
        NSString *title = NSLocalizedString(@"TITLE_EDIT_MODE", nil);
        UIAlertView *noInsertModeAlertView = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"ALERT_NO_INSERT_MODE_2", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        noInsertModeAlertView.tag = 100;
        [noInsertModeAlertView show];
        return;
    }
    if (IS_PAD) {
        CGRect rect = CGRectMake(_gameWebView.lastTouchPosition.x, _gameWebView.lastTouchPosition.y, 5.0, 10.0);
        TextCommentPopoverViewController *tcpvc = [[TextCommentPopoverViewController alloc] init];
        [tcpvc setPgnMove:prossimaMossa];
        [tcpvc setTextBefore:NO];
        tcpvc.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tcpvc];
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navController];
        [popover presentPopoverFromRect:rect inView:_gameWebView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self addTextAfterMove];
    }
}

- (void) delVariantMenuPressed:(id)sender {
    if (!_pgnGame.isEditMode) {
        NSString *title = NSLocalizedString(@"TITLE_EDIT_MODE", nil);
        UIAlertView *noInsertModeAlertView = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"ALERT_NO_INSERT_MODE_2", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        noInsertModeAlertView.tag = 100;
        [noInsertModeAlertView show];
        return;
    }
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DELETE_VARIATION", nil) message:NSLocalizedString(@"CONFIRM_DELETE_VARIATION", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:NSLocalizedString(@"DELETE_VARIATION", nil), nil];
    av.tag = 30;
    [av show];
}

- (void) promoteVariantMenuPressed:(id)sender {
    [self verificaPromoteVariante];
}

/*
- (void) webViewDidFinishLoad:(UIWebView *)webView {
    
    int offsetHeight = [[_gameWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] intValue];
    int moveTop = [[_gameWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"mossaevidenziata\").offsetTop;"] intValue];
    int parentHeight = [[_gameWebView stringByEvaluatingJavaScriptFromString:@"window.innerheight"] intValue];
    int scrollPos = moveTop - (parentHeight/2);
    
    if (scrollPos < 0) {
        scrollPos = 0;
    } else if ((scrollPos + parentHeight)>offsetHeight) {
        scrollPos = offsetHeight - parentHeight;
    }
    
    //NSInteger height = [[_gameWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    //NSString *javascript = [NSString stringWithFormat:@"window.scrollBy(0, %d);", height];
    NSString *javascript = [NSString stringWithFormat:@"window.scrollBy(0, %d);", scrollPos];
    [_gameWebView stringByEvaluatingJavaScriptFromString:javascript];
}
*/

/*
- (int) checkConfiniScacchieraPerAlfiere:(int)squareNumber {
    int convertedSquare = [boardModel convertTagValueToSquareValue:squareNumber];
    NSLog(@"Converted Square = %d", convertedSquare);
    NSString *squareString = [NSString stringWithFormat:@"%d",convertedSquare];
    if ([squareString hasPrefix:@"1"] || [squareString hasPrefix:@"8"] || [squareString hasSuffix:@"8"] || [squareString hasSuffix:@"1"]) {
        //NSLog(@"CheckConfini      SQUARESTRING = %@", squareString);
        return -1;
    }
    return 0;
}
*/


- (int) checkTheSquare:(int)squareNumber :(NSString *)pieceToMove :(int)squareValue {
    
    if (squareNumber < 0 || squareNumber > 63 ) {
        return -1;
    }
    
    //int tempSquareNumber = squareNumber;
    
    squareNumber = [boardModel convertTagValueToSquareValue:squareNumber];
    
    //NSLog(@"SQUARE NUMBER INPUT = %d     SQUARE NUMBER CONVERTITO = %d", tempSquareNumber,  squareNumber);
    
    if (![boardModel.numericSquares containsObject:[NSNumber numberWithInt:squareNumber]]) {
        return -1;
    }
    
    NSString *pieceInBoard = [boardModel trovaContenutoConNumeroCasa:squareNumber];
    if ([pieceInBoard hasPrefix:@"w"]  && [pieceToMove hasPrefix:@"w"]) {
        return -1;
    }
    if ([pieceInBoard hasPrefix:@"b"]  && [pieceToMove hasPrefix:@"b"]) {
        return -1;
    }
    
    if ([pieceInBoard hasPrefix:@"b"]  && [pieceToMove hasPrefix:@"w"]  && [pieceToMove hasSuffix:@"p"]) {
        return -1;
    }
    
    if ([pieceInBoard hasPrefix:@"w"]  && [pieceToMove hasPrefix:@"b"]  && [pieceToMove hasSuffix:@"p"]) {
        return -1;
    }
    
    if ([pieceInBoard hasPrefix:@"b"]  && [pieceToMove hasPrefix:@"w"]) {
        return 1;
    }
    if ([pieceInBoard hasPrefix:@"w"]  && [pieceToMove hasPrefix:@"b"]) {
        return 1;
    }
    return 0;
}

- (int) checkTheSquareForPawn:(int)squareNumber :(NSString *)pieceToMove :(int)squareValue {
    
    if (squareNumber < 0 || squareNumber > 63 ) {
        return -1;
    }
    
    int diffValue = abs(squareNumber - squareValue);
    
    squareNumber = [boardModel convertTagValueToSquareValue:squareNumber];
    
    
    if (![boardModel.numericSquares containsObject:[NSNumber numberWithInt:squareNumber]]) {
        return -1;
    }
    
    NSString *pieceInBoard = [boardModel trovaContenutoConNumeroCasa:squareNumber];
    
    if (diffValue == 7 || diffValue == 9) {
        if ([pieceInBoard isEqualToString:EMPTY]) {
            return -1;
        }
        if ([pieceToMove hasPrefix:@"w"]  && [pieceInBoard hasPrefix:@"w"]) {
            return -1;
        }
        if ([pieceToMove hasPrefix:@"b"]  && [pieceInBoard hasPrefix:@"b"]) {
            return -1;
        }
        return 0;
    }
    
    
    if (![pieceInBoard isEqualToString:EMPTY]) {
        //NSLog(@"Piece in Board: %@", pieceInBoard);
        return -1;
    }
    
    
    if ([pieceInBoard hasPrefix:@"w"]  && [pieceToMove hasPrefix:@"w"]) {
        return -1;
    }
    
    if ([pieceInBoard hasPrefix:@"b"]  && [pieceToMove hasPrefix:@"b"]) {
        return -1;
    }
    
    return 0;
}

- (int) checkTheSquareForKing:(int)squareNumber :(NSString *)pieceToMove :(int)squareValue {
    
    if (squareNumber < 0 || squareNumber > 63 ) {
        return -1;
    }
    
    squareNumber = [boardModel convertTagValueToSquareValue:squareNumber];
    
    //NSLog(@"CheckTheSquareforKing:  %d", squareNumber);
    
    
    NSString *pieceInBoard = [boardModel trovaContenutoConNumeroCasa:squareNumber];
    
    if ([pieceInBoard hasPrefix:@"w"]  && [pieceToMove hasPrefix:@"w"]) {
        return -1;
    }
    if ([pieceInBoard hasPrefix:@"b"]  && [pieceToMove hasPrefix:@"b"]) {
        return -1;
    }
    
    if ([pieceToMove hasPrefix:@"w"]  && squareNumber == 71) {
        //NSLog(@"Devo valutare arrocco corto del bianco");
    }
    
    if ([pieceToMove hasPrefix:@"w"]  && squareNumber == 31) {
        //NSLog(@"Devo valutare arrocco lungo del bianco");
    }
    
    if ([pieceToMove hasPrefix:@"b"]  && squareNumber == 78) {
        //NSLog(@"Devo valutare arrocco corto del nero");
    }
    
    if ([pieceToMove hasPrefix:@"b"]  && squareNumber == 38) {
        //NSLog(@"Devo valutare arrocco lungo del nero");
    }
    
    return 0;
    
}


- (IBAction)flipButtonPressed:(id)sender {
    flipped = !flipped;
    //[self removeEdge];
    //[self removeLetterLabel];
    //[self removeNumberLabel];
    [boardView flipPosition];
    //[self restoreEdge];
    //[self addLetterLabel];
    //[self addNumberLabel];
}


- (void) evidenziaAChiToccaMuovere {
    //NSLog(@"Evidenzia tratto");
    if ([boardModel whiteHasToMove]) {
        //NSLog(@"Mossa al bianco");
        [colorView setBackgroundColor:[UIColor whiteColor]];
        //[colorSegControl setSelectedSegmentIndex:0];
        [controlNalimovView setColor:@"White"];
    }
    else {
        //NSLog(@"Mossa al nero");
        [colorView setBackgroundColor:[UIColor blackColor]];
        //[colorSegControl setSelectedSegmentIndex:1];
        [controlNalimovView setColor:@"Black"];
    }
    //[self setupPgnGame];
    //[self getNalimovResult];
}


- (void) showNextMove:(PGNMove *)nextMove {
    
    if (nextMove && !stopNextMove) {
        
        if (nextMove.promoted) {
            //PieceButton *promotedPieceButton = [[[PieceButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType :nextMove.pezzoPromosso];
            //PieceButton *promotedPieceButton = [self creaPezzoPerPromozione:nextMove.pezzoPromosso];
            PieceButton *promotedPieceButton = [self rimettiInGiocoPezzoCatturato:nextMove];
            //[promotedPieceButton setDelegate:self];
            //if (flipped) {
            //    [promotedPieceButton flip];
            //}
            PieceButton *capturedDurinPromotionPieceButton = nil;
            if (nextMove.capture) {
                //capturedDurinPromotionPieceButton = [boardView findPieceBySquareTag:nextMove.toSquare];
                //[boardView manageCapture:nextMove.toSquare];
                capturedDurinPromotionPieceButton = [self rimettiInGiocoPezzoCatturato:nextMove];
            }
            //[boardView mossaAvantiPromozioneECattura:nextMove.fromSquare :nextMove.toSquare :promotedPieceButton :capturedDurinPromotionPieceButton];
            [boardView muoviPezzoAvantiEPromuovi:nextMove :promotedPieceButton];
            [boardModel mossaAvantiConPromozione:nextMove];
        }
        else if (nextMove.enPassantCapture) {
            //[boardView manageCapture:nextMove.enPassantPieceSquare];
            //[boardView mossaAvantiEnPassant:nextMove.fromSquare :nextMove.toSquare :nextMove.enPassantPieceSquare];
            [boardView muoviPezzoAvanti:nextMove];
            [boardModel mossaAvantiEnPassant:nextMove.fromSquare :nextMove.toSquare :nextMove.enPassantPieceSquare];
        }
        else {
            //PieceButton *capturedPieceButton = nil;
            //if (nextMove.capture) {
            //    [boardView manageCapture:nextMove.toSquare];
            //}
            //[boardView gestisciCatturaAvanti:nextMove];
            //[boardView muoviPezzoAvanti:nextMove.fromSquare :nextMove.toSquare :capturedPieceButton];
            [boardView muoviPezzoAvanti:nextMove];
            [boardModel mossaAvanti:nextMove.fromSquare :nextMove.toSquare];
        }
        [self evidenziaAChiToccaMuovere];
        
        
        //NSLog(@"FEN MOSSA ESEGUITA = %@", nextMove.fen);
        //[self trovaECO:nextMove];
    }
}

- (void) showPrevMove:(PGNMove *)prevMove {
    if (prevMove) {
        if (prevMove.promoted) {
            
            float fx;
            float fy;
            
            unsigned int square = prevMove.toSquare;
            
            fx = (float) ( square % 8 ) * dimSquare;
            fy = (dimSquare * 7) -floor( square / 8 ) * dimSquare;
            
            CGRect toSquareRect = CGRectMake(fx, fy, dimSquare, dimSquare);
            
            
            
            //NSString *pedonePromosso = [prevMove.color stringByAppendingString:@"p"];
            //PieceButton *pedonePromosso = [[[PawnButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType :[prevMove.color stringByAppendingString:@"p"]];
            PieceButton *pedonePromosso = [[[PawnButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType :[prevMove.color stringByAppendingString:@"p"]];
            
            
            
            
            [pedonePromosso setDelegate:self];
            if (flipped) {
                [pedonePromosso flip];
            }
            PieceButton *pezzoCatturatoInPromozione = nil;
            if (prevMove.capture) {
                
                pezzoCatturatoInPromozione = [self rimettiInGiocoPezzoCatturatoInPromozione:prevMove];
                
                //capturedDurinPromotionPieceButton = [[[PieceButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:@"zur96":prevMove.captured];
                //capturedDurinPromotionPieceButton = [self rigeneraPezzo:prevMove.captured];
                //[capturedDurinPromotionPieceButton setDelegate:self];
                //if (flipped) {
                //    [capturedDurinPromotionPieceButton flip];
                //}
                //[boardView manageCaptureBack];
            }
            //[boardView mossaIndietroPromozioneECattura:prevMove.toSquare :prevMove.fromSquare :promotedPieceButton :capturedDurinPromotionPieceButton];
            [boardView muoviPezzoIndietroPromosso:prevMove :pedonePromosso :pezzoCatturatoInPromozione];
            [boardModel mossaIndietroConPromozione:prevMove];
        }
        else if (prevMove.enPassantCapture) {
            //if (boardModel.whiteHasToMove) {
                //pedoneEnPassant = [[[PieceButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType :WHITE_PAWN];
            //}
            //else {
                //pedoneEnPassant = [[[PieceButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType :BLACK_PAWN];
            //}
            
            PieceButton *pedoneEnPassant = [self rimettiInGiocoPezzoCatturato:prevMove];
            //[boardView addSubview:pedoneEnPassant];
            
            //[pedoneEnPassant setDelegate:self];
            //[pedoneEnPassant setSquareValue:prevMove.enPassantPieceSquare];
            //if (flipped) {
            //    [pedoneEnPassant flip];
            //}
            //[boardView manageCaptureBack];
            [boardModel mossaIndietroEnPassant:prevMove.toSquare :prevMove.fromSquare :prevMove.enPassantPieceSquare];
            //[boardView mossaIndietroEnPassant:prevMove.toSquare :prevMove.fromSquare :pedoneEnPassant];
            [boardView muoviPezzoIndietro:prevMove :pedoneEnPassant];
        }
        else {
            
            PieceButton *pezzoCatturatoDaRimettereInGioco = nil;
            if (prevMove.capture) {
                
                pezzoCatturatoDaRimettereInGioco = [self rimettiInGiocoPezzoCatturato:prevMove];
                //[boardView gestisciCatturaIndietro:prevMove :capturedPieceButton];
                //[boardView manageCaptureBack];
                //capturedButton = [self rigeneraPezzo:prevMove.captured];
                //[capturedButton setDelegate:self];
                //if (flipped) {
                //    [capturedButton flip];
                //}
            }
            
            //NSLog(@"Eseguo questa parte in showPrevMove");
            //[boardModel printPosition];
            //[boardView muoviPezzoIndietro:prevMove.toSquare :prevMove.fromSquare :nil];
            [boardView muoviPezzoIndietro:prevMove :pezzoCatturatoDaRimettereInGioco];
            [boardModel mossaIndietro:prevMove.toSquare :prevMove.fromSquare :prevMove.captured];
        }
        
        //NSLog(@"FEN MOSSA ESEGUITA = %@", prevMove.fen);
        //[boardModel printPosition];
        
        [self evidenziaAChiToccaMuovere];
        
        //[self trovaECO:prevMove];
    }
}

/*
- (void) goForward {
    if (prossimaMossa) {
        prossimaMossa = [[prossimaMossa getNextMoves] objectAtIndex:0];
        [pgnParser parseMoveForward:prossimaMossa];
        
        if (prossimaMossa.promoted) {
            //PieceButton *promotedPieceButton = [[[PieceButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType :nextMove.pezzoPromosso];
            //[promotedPieceButton setDelegate:self];
            //if (flipped) {
            //    [promotedPieceButton flip];
            //}
            //PieceButton *capturedDurinPromotionPieceButton = nil;
            //if (prossimaMossa.capture) {
            //    [boardView manageCapture:prossimaMossa.toSquare];
            //}
            //[boardView mossaAvantiPromozioneECattura:nextMove.fromSquare :nextMove.toSquare :promotedPieceButton :capturedDurinPromotionPieceButton];
            [boardModel mossaAvantiConPromozione:prossimaMossa];
        }
        else if (prossimaMossa.enPassantCapture) {
            //[boardView manageCapture:prossimaMossa.enPassantPieceSquare];
            //[boardView mossaAvantiEnPassant:prossimaMossa.fromSquare :prossimaMossa.toSquare :prossimaMossa.enPassantPieceSquare];
            [boardModel mossaAvantiEnPassant:prossimaMossa.fromSquare :prossimaMossa.toSquare :prossimaMossa.enPassantPieceSquare];
        }
        else {
            //PieceButton *capturedPieceButton = nil;
            //if (prossimaMossa.capture) {
            //    [boardView manageCapture:prossimaMossa.toSquare];
            //}
            //[boardView muoviPezzoAvanti:prossimaMossa.fromSquare :prossimaMossa.toSquare :capturedPieceButton];
            [boardModel mossaAvanti:prossimaMossa.fromSquare :prossimaMossa.toSquare];
        }
        //[self evidenziaAChiToccaMuovere];
    }
}
*/

/*
- (void) vaiAvanti:(PGNMove *)pgnMove {
    prossimaMossa = pgnMove;
    [pgnParser parseMoveForward:prossimaMossa];
    [prossimaMossa setEvidenzia:YES];
    [self showNextMove:prossimaMossa];
    //[_gameWebView aggiornaWebViewAvanti:prossimaMossa];
    if (stopPrevMove) {
        stopPrevMove = !stopPrevMove;
    }
    if ([prossimaMossa endGameMarked]) {
        stopNextMove = YES;
        prossimaMossa = [prossimaMossa getPrevMove];
    }
}

- (void) vaiIndietro:(PGNMove *)pgnMove {
    if ([prossimaMossa evidenzia]) {
        [prossimaMossa setEvidenzia:NO];
    }
    [self showPrevMove:prossimaMossa];
    [pgnParser parseMoveBack:prossimaMossa];
    
    if (stopNextMove) {
        stopNextMove = !stopNextMove;
    }
    
    prossimaMossa = pgnMove;
    [prossimaMossa setEvidenzia:YES];
    //[_gameWebView aggiornaWebViewIndietro:prossimaMossa];
}
*/


- (IBAction)avantiButtonPressed:(id)sender {
    
    //NSLog(@"INIZIO AVANTI BUTTON PRESSED CON VARIANTI");
    
    //if ([gameSetting animated]) {
    //    [gameSetting accelera];
    //    return;
    //}
    
    //if ([self isSetupPosition]) {
        //return;
    //}
    
    
    if (stopNextMove) {
        //NSLog(@"Non ci sono più mosse avanti");
        return;
    }
    
    
    if (prossimaMossa) {
        
        NSArray *varianti = [prossimaMossa getNextMoves];
        
        if (varianti) {
            
            if ([prossimaMossa evidenzia]) {
                [prossimaMossa setEvidenzia:NO];
            }
            
            //if (saltaVarianti) {
            //    NSLog(@"Devo saltare le varianti");
            //}
            //else {
            //    NSLog(@"Non devo saltare le varianti");
            //}
            
            if (varianti.count > 1 /*&& !saltaVarianti*/) {
                NSString *cancel = NSLocalizedString(@"MENU_CANCEL", nil);
                NSString *title = NSLocalizedString(@"VARIATIONS", nil);
                NSString *msg = nil;
                variantiAlertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancel otherButtonTitles:nil];
                variantiAlertView.tag = 5;
                for (PGNMove *moveVar in prossimaMossa.getNextMoves) {
                    if ([prossimaMossa.getNextMoves indexOfObject:moveVar] == 0) {
                        NSString *testo = [[moveVar getMossaPerVarianti] stringByAppendingString:NSLocalizedString(@"MAIN_LINE", nil)];
                        [variantiAlertView addButtonWithTitle:testo];
                    }
                    else {
                        [variantiAlertView addButtonWithTitle:[moveVar getMossaPerVarianti]];
                    }
                }
            }
            else if (varianti.count == 1) {
                variantiAlertView = nil;
                
                prossimaMossa = [[prossimaMossa getNextMoves] objectAtIndex:0];
                
                [pgnParser parseMoveForward:prossimaMossa];
                
                if (![prossimaMossa isValid]) {
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MOVE_NOT_VALID", nil), [prossimaMossa fullMove]];
                    UIAlertView *noValidMoveAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"INVALID_MOVE", nil) message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    noValidMoveAlertView.tag = 7;
                    [noValidMoveAlertView show];
                    return;
                }
                
                
                if ([prossimaMossa endGameMarked]) {
                    stopNextMove = YES;
                    prossimaMossa = [prossimaMossa getPrevMove];
                }
            }
        }
        else {
            variantiAlertView = nil;
            //tempMove = nil;
            stopNextMove = YES;
            //NSLog(@"varianti = nil    Prossima mossa = %@", prossimaMossa.description);
        }
    }
    
    
    if (variantiAlertView /*&& !saltaVarianti*/) {
        [variantiAlertView show];
    }
    else {
        [prossimaMossa setEvidenzia:YES];
        [self showNextMove:prossimaMossa];
        
        //NSLog(@"Devo valutare Plycount = %lu della mossa %@", (unsigned long)prossimaMossa.plyCount, prossimaMossa.description);
        //NSLog(@"Start PlyCount = %lu", (unsigned long)[_pgnGame getStartPlycount]);
        
        //NSDictionary *userInfo = [NSDictionary dictionaryWithObject:prossimaMossa forKey:@"MOSSA"];
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"EngineNotification" object:prossimaMossa userInfo:userInfo];
        
        
        [self sendMoveToEngine:prossimaMossa];
        
        [_gameWebView aggiornaWebViewAvanti:prossimaMossa];
        
        /*
        NSString *bm = [openingBookManager getBookMovesForFen:[prossimaMossa fenForBookMoves]];
        if (openingBookView) {
            if (bm) {
                [openingBookView setText: [NSString stringWithFormat: @" Book: %@", bm]];
            }
            else {
                [openingBookView setText:@" Book:"];
            }
        }*/
        
    }
    
    
    
    if (stopPrevMove) {
        stopPrevMove = !stopPrevMove;
    }
    
    [self getNalimovResult];
    
    
    //[boardModel stampaStackfFen];
    
    //NSLog(@"FINE AVANTI BUTTON PRESSED CON VARIANTI");
}

- (IBAction)indietroButtonPressed:(id)sender {
    
    //NSLog(@"INIZIO INDIETRO BUTTON PRESSED CON VARIANTI");
    
    //[boardModel printPosition];
    
    //if ([gameSetting animated]) {
    //    [gameSetting decelera];
    //    return;
    //}
    
    //if ([self isSetupPosition]) {
    //    return;
    //}
    
    
    if (stopPrevMove) {
        //NSLog(@"Non ci sono più mosse indietro");
        //NSLog(@"Plycount attuale = %d", [boardModel getPlyCount]);
        return;
    }
    
    if ([prossimaMossa isFirstMoveAfterRootWithDots]) {
        //NSLog(@"MOSSA = %@", prossimaMossa.fullMove);
        //NSLog(@"Hai raggiunto la base");
        return;
    }
    
    if ([prossimaMossa evidenzia]) {
        [prossimaMossa setEvidenzia:NO];
    }
    
    //NSLog(@"PROSSIMA MOSSA = %@", prossimaMossa.fullMove);
    
    [self showPrevMove:prossimaMossa];
    
    
    [pgnParser parseMoveBack:prossimaMossa];
    
    
    if (stopNextMove) {
        stopNextMove = !stopNextMove;
    }
    
    //NSLog(@"Devo valutare Plycount = %lu della mossa %@", (unsigned long)prossimaMossa.plyCount, prossimaMossa.description);
    //NSLog(@"Start PlyCount = %lu", (unsigned long)[_pgnGame getStartPlycount]);
    if (prossimaMossa.plyCount > ([_pgnGame getStartPlycount] + 1) /*&& ![prossimaMossa isFirstMoveAfterRoot]*/) {
        prossimaMossa = [prossimaMossa getPrevMove];
        //NSLog(@"Plycount mossa selezionata = %lu", (unsigned long)prossimaMossa.plyCount);
        if ([prossimaMossa isRootMove]) {
            //NSLog(@"Mossa con plycount %lu è RootMove", (unsigned long)prossimaMossa.plyCount);
        }
    }
    else {
        stopPrevMove = YES;
        prossimaMossa = [prossimaMossa getPrevMove];
        //NSLog(@"Prossima Mossa = %@", prossimaMossa.fullMove);
    }
    
    /*
    if ([prossimaMossa isFirstMoveAfterRoot]) {
        NSLog(@"Questa mossa è la prima dopo root move anche se plycount = %d", prossimaMossa.plyCount);
        stopPrevMove = YES;
        prossimaMossa = [prossimaMossa getPrevMove];
    }
    else {
        NSLog(@"Questa mossa non è la prima dopo root move");
    }*/
    
    [prossimaMossa setEvidenzia:YES];
    
    if (_pgnGame.isEditMode && [prossimaMossa daQuestaMossaEsisteDiramazione]) {
        //NSLog(@"Da questa mossa si diramano più varianti");
        //boardModel = [stackBoardModel objectAtIndex:0];
    }
    
    //[self aggiornaWebView];
    
    [boardModel setFenNotation:[prossimaMossa fen]];
    
    
    [self sendMoveToEngine:prossimaMossa];
    
    [_gameWebView aggiornaWebViewIndietro:prossimaMossa];
    
    
    [self getNalimovResult];
    
    //NSDictionary *userInfo = [NSDictionary dictionaryWithObject:prossimaMossa forKey:@"MOSSA"];
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"EngineNotification" object:prossimaMossa userInfo:userInfo];
    
    

}


- (void) displayBoardViewMenu:(UIBarButtonItem *)sender {
    
    if (_setupPosition) {
        BoardViewPositionTableViewController *bvmptvc = [[BoardViewPositionTableViewController alloc] initWithStyle:UITableViewStylePlain];
        bvmptvc.delegate = self;
        UINavigationController *boardViewMenuNavigationController = [[UINavigationController alloc] initWithRootViewController:bvmptvc];
        if (IS_PAD) {
            boardViewMenuPopoverController = [[UIPopoverController alloc] initWithContentViewController:boardViewMenuNavigationController];
            [boardViewMenuPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            boardViewMenuNavigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:boardViewMenuNavigationController animated:YES completion:nil];
        }
        return;
    }
    
    BoardViewControllerMenuTableViewController *bvcmtvc = [[BoardViewControllerMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [bvcmtvc setPgnGame:_pgnGame];
    bvcmtvc.delegate = self;
    UINavigationController *boardViewMenuNavigationController = [[UINavigationController alloc] initWithRootViewController:bvcmtvc];
    //[boardViewMenuNavigationController setPreferredContentSize:CGSizeMake(280.0, 500.0)];
    if (IS_PAD) {
        boardViewMenuPopoverController = [[UIPopoverController alloc] initWithContentViewController:boardViewMenuNavigationController];
        [boardViewMenuPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        boardViewMenuNavigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:boardViewMenuNavigationController animated:YES completion:nil];
    }
}

- (IBAction)backButtonPressed:(id)sender {  //Pulsante in alto a sinistra
    if (actionSheetMenu) {
        [actionSheetMenu dismissWithClickedButtonIndex:-1 animated:YES];
        actionSheetMenu = nil;
    }
    if (actionSheetMenuGame.window ) {
        [actionSheetMenuGame dismissWithClickedButtonIndex:0 animated:YES];
        actionSheetMenuGame = nil;
        return;
    }
    if (annotationMovePopoverController.isPopoverVisible) {
        [annotationMovePopoverController dismissPopoverAnimated:YES];
        annotationMovePopoverController = nil;
        return;
    }
    
    if (controllerPopoverController.isPopoverVisible) {
        [controllerPopoverController dismissPopoverAnimated:YES];
        controllerPopoverController = nil;
        return;
    }
    
    if (boardViewMenuPopoverController.isPopoverVisible) {
        [boardViewMenuPopoverController dismissPopoverAnimated:YES];
        boardViewMenuPopoverController = nil;
        return;
    }
    
    NSString *cancelButton;
    if (IS_PAD) {
        cancelButton = @"";
    }
    else {
        cancelButton = NSLocalizedString(@"ACTIONSHEET_CANCEL", nil);
    }
    
    
    UIBarButtonItem *bbi = (UIBarButtonItem *)sender;
    
    //actionSheetMenuGame = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    actionSheetMenuGame = [[UIActionSheet alloc] init];
    actionSheetMenuGame.delegate = self;
    
    if (_setupPosition) {
        [actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_POSITION_CLEAR", nil)];
        [actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_POSITION_SAVE", nil)];
        //[actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_POSITION_SAVE_EXIT", nil)];
        [actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_EXIT", nil)];
        actionSheetMenuGame.tag = 3;
    }
    else {
        if (_pgnGame.isEditMode) {
            //[actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"EXIT_EDIT_MODE", nil)];
            if (_delegate) {
                [actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_NEW_GAME", nil)];
            }
            //[actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_NEW_GAME", nil)];
            [actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_EDIT_GAME_DATA", nil)];
            //[actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_EMAIL_GAME", nil)];
            [actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_SAVE_GAME", nil)];
            [actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_SAVE_GAME_EXIT", nil)];
            [actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_EXIT", nil)];
        }
        else {
            //[actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"ENTER_EDIT_MODE", nil)];
            //[actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_EMAIL_GAME", nil)];
            
            if ([_delegate respondsToSelector:@selector(getPreviousGame)] && [_delegate respondsToSelector:@selector(getNextGame)]) {
                [actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"NEXT_GAME", nil)];
                [actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"PREVIOUS_GAME", nil)];
            }
            
            [actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"MENU_EXIT", nil)];
        }
        actionSheetMenuGame.tag = 2;
    }
    
    //actionSheetMenuGame.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
    
    //if (IS_PHONE) {
    actionSheetMenuGame.cancelButtonIndex = [actionSheetMenuGame addButtonWithTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil)];
    //}
    
    [actionSheetMenuGame showFromBarButtonItem:bbi animated:YES];
}



- (void) actionButtonPressed:(UIBarButtonItem *)sender {   //Pulsante in alto a destra
    if (actionSheetMenuGame.window ) {
        [actionSheetMenuGame dismissWithClickedButtonIndex:0 animated:YES];
        actionSheetMenuGame = nil;
    }
    if (actionSheetMenu.window ) {
        [actionSheetMenu dismissWithClickedButtonIndex:0 animated:YES];
        actionSheetMenu = nil;
        return;
    }
    if (annotationMovePopoverController.isPopoverVisible) {
        [annotationMovePopoverController dismissPopoverAnimated:YES];
        annotationMovePopoverController = nil;
        return;
    }
    
    if (controllerPopoverController.isPopoverVisible) {
        [controllerPopoverController dismissPopoverAnimated:YES];
        controllerPopoverController = nil;
        return;
    }
    
    if ([self isRevealed]) {
        [self displayBoardViewMenu:sender];
        return;
    }
    
    
    NSString *cancelButton;
    if (IS_PAD) {
        cancelButton = @"";
    }
    else {
        cancelButton = NSLocalizedString(@"ACTIONSHEET_CANCEL", nil);
    }
    
    
    //NSString *buttonEdit = nil;
    NSString *buttonAnnotaUltimaMossa = nil;
    //NSString *buttonCommentaUltimaMossa = nil;
    NSString *buttonTextAfter = nil;
    //NSString *buttonTextBefore = nil;
    NSString *buttonInitialText = nil;
    NSString *buttonSettings = NSLocalizedString(@"SETTINGS", nil);
    
    NSString *buttonInsertVariant = nil;
    
    //actionSheetMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    actionSheetMenu = [[UIActionSheet alloc] init];
    actionSheetMenu.delegate = self;
    actionSheetMenu.tag = 0;
    
    if (_setupPosition) {
        if (!IS_IPHONE_5) {
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_FLIP_BOARD", nil)];
        }
        
        [actionSheetMenu addButtonWithTitle:buttonSettings];
        
        //if (IS_PHONE) {
        actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_CANCEL", nil)];
        //}
        
        [actionSheetMenu showFromBarButtonItem:sender animated:YES];
        return;
    }
    
    
    
    if (_pgnGame.isEditMode) {
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"EXIT_EDIT_MODE", nil)];
        
        if ([boardModel getPlyCount] > 0) { //Gestione partita o posizione con mosse
            //if ([pgnRootMove movesHasBeenInserted]) { //Gestione partita o posizione con mosse
            NSString *ultima = [prossimaMossa getMossaPerVarianti];
            if ([ultima hasSuffix:@"XXX"]) {
                buttonAnnotaUltimaMossa = nil;
                //buttonTextBefore = nil;
                buttonInitialText = nil;
                buttonTextAfter = nil;
                //ultima = [ultima stringByReplacingOccurrencesOfString:@"XXX" withString:@"..."];
                buttonAnnotaUltimaMossa = nil;
            }
            else {
                buttonAnnotaUltimaMossa = [NSLocalizedString(@"ANNOTATION_MOVE", nil) stringByAppendingString:ultima];
                buttonTextAfter = [NSLocalizedString(@"TEXT_AFTER", nil) stringByAppendingString:ultima];
                if ([prossimaMossa textBefore]) {
                    //buttonTextBefore = [NSLocalizedString(@"TEXT_BEFORE", nil) stringByAppendingString:ultima];
                    buttonInitialText = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
                }
                else {
                    //buttonTextBefore = nil;
                    buttonInitialText = nil;
                }
                buttonInsertVariant = [NSLocalizedString(@"INSERT_VARIANT_INSTEAD_OF", nil) stringByAppendingString:ultima];
            }
            
            if ([pgnRootMove existInitialText]) {
                buttonInitialText = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
            }
            else {
                buttonInitialText = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
            }
            
        }
        else { //Gestione partita o posizione senza mosse
            if (pgnRootMove.textAfter) {
                //NSLog(@"Devo gestire una partita senza mosse con commento iniziale");
                buttonInitialText = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
            }
            else {
                //NSLog(@"Devo gestire una partita senza mosse senza commento iniziale");
                buttonInitialText = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
            }
            if ([pgnRootMove movesHasBeenInserted]) {
                if ([pgnRootMove existInitialText]) {
                    buttonInitialText = NSLocalizedString(@"EDIT_INITIAL_TEXT", nil);
                }
                else {
                    buttonInitialText = NSLocalizedString(@"ADD_INITIAL_TEXT", nil);
                }
            }
        }
        
        
        if (buttonAnnotaUltimaMossa) {
            [actionSheetMenu addButtonWithTitle:buttonAnnotaUltimaMossa];
        }
        //if (buttonTextBefore) {
        //    [actionSheetMenu addButtonWithTitle:buttonTextBefore];
        //}
        
        if (buttonInitialText) {
            [actionSheetMenu addButtonWithTitle:buttonInitialText];
        }
        
        if (buttonTextAfter) {
            [actionSheetMenu addButtonWithTitle:buttonTextAfter];
        }
        
        
        if ([prossimaMossa inVariante]) {
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"DELETE_VARIATION", nil)];
            [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"PROMOTE_VARIATION", nil)];
        }
        
        if (buttonInsertVariant) {
            [actionSheetMenu addButtonWithTitle:buttonInsertVariant];
        }
        
        
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_EMAIL_GAME", nil)];
        [actionSheetMenu addButtonWithTitle:buttonSettings];
    }
    else {
        //buttonEdit = NSLocalizedString(@"EDIT_GAME", nil);
        //[actionSheetMenu addButtonWithTitle:buttonEdit];
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"ENTER_EDIT_MODE", nil)];
        [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_EMAIL_GAME", nil)];
        [actionSheetMenu addButtonWithTitle:buttonSettings];
        [actionSheetMenu addButtonWithTitle:@"Game Moves Web View"];
    }
    
    actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:cancelButton];
    
    //if (IS_PHONE) {
    //    actionSheetMenu.cancelButtonIndex = [actionSheetMenu addButtonWithTitle:NSLocalizedString(@"MENU_CANCEL", nil)];
    //}
    
    [actionSheetMenu showFromBarButtonItem:sender animated:YES];
}

- (IBAction)varianteSuButtonPressed:(id)sender {  //Pulsante in Basso a destra
    
    if ([self isSetupPosition]) {
        return;
    }

    if (!prossimaMossa || prossimaMossa.isRootMove) {
        NSString *msg = NSLocalizedString(@"VARIANTE_SU_MSG_0", nil);
        NSString *title = NSLocalizedString(@"VARIANTE_SU_TITLE_0", nil);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    
    //NSLog(@"MOSSA ATTUALE = %@", prossimaMossa.getCompleteMove);
    
    if ([prossimaMossa inVariante]) {
        NSInteger numeroVarianti = 0;
        do {
            prossimaMossa = [prossimaMossa getPrevMove];
            //NSLog(@"MOSSA = %@", prossimaMossa.getCompleteMove);
            if (prossimaMossa.getNextMoves) {
                //NSLog(@"Numero varianti = %lu", (unsigned long)[[prossimaMossa getNextMoves] count]);
                numeroVarianti = [[prossimaMossa getNextMoves] count];
            }
        } while (numeroVarianti == 1);
        
        [boardModel setFenNotation:[prossimaMossa fen]];
        [pgnParser setFenPosition:[prossimaMossa fen]];
        [self clearBoardView];
        [self setupInitialPosition];
        [prossimaMossa setEvidenzia:YES];
        [self sendMoveToEngine:prossimaMossa];
        
        //[_gameWebView aggiornaWebViewAvanti:prossimaMossa];
        [_gameWebView aggiornaWebViewIndietro:prossimaMossa];
        
        if ([prossimaMossa getNextMoves]) {
            stopNextMove = NO;
        }
        else {
            stopNextMove = YES;
        }
        if (prossimaMossa.plyCount == 0) {
            stopPrevMove = YES;
        }
        else {
            stopPrevMove = NO;
        }
        [self evidenziaAChiToccaMuovere];
    }
    else {
        NSString *msg = NSLocalizedString(@"VARIANTE_SU_MSG", nil);
        NSString *title = NSLocalizedString(@"VARIANTE_SU_TITLE_0", nil);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
    }
}


- (IBAction)controllerButtonPressed:(UIBarButtonItem *)sender {  //Pulsante in basso a sinistra
    
    //Le classi che vengono utilizzate si trovano nella cartella ControlManagement
    
    if (actionSheetMenuGame.window ) {
        [actionSheetMenuGame dismissWithClickedButtonIndex:0 animated:YES];
        actionSheetMenuGame = nil;
        return;
    }
    if (actionSheetMenu.window ) {
        [actionSheetMenu dismissWithClickedButtonIndex:0 animated:YES];
        actionSheetMenu = nil;
        return;
    }
    if (annotationMovePopoverController.isPopoverVisible) {
        [annotationMovePopoverController dismissPopoverAnimated:YES];
        annotationMovePopoverController = nil;
        return;
    }
    
    if (controllerPopoverController.isPopoverVisible) {
        [controllerPopoverController dismissPopoverAnimated:YES];
        controllerPopoverController = nil;
        return;
    }
    
    if ([self isSetupPosition]) {
        return;
    }
    
    
    controllerTableViewController = [[ControllerTableViewController alloc] initWithStyle:UITableViewStylePlain];
    controllerTableViewController.delegate = self;
    
    if (_delegate && [_delegate respondsToSelector:@selector(getNextGame)]) {
        //if ([_pgnGame isEditMode]) {
        //    [controllerTableViewController setDisplayLoadGames:NO];
        //}
        //else {
            [controllerTableViewController setDisplayLoadGames:YES];
            [controllerTableViewController setIndexGame:[_pgnGame indexInAllGamesAllTags]];
            [controllerTableViewController setNameDatabase:[_pgnFileDoc.pgnFileInfo fileName]];
        //}
    }
    else {
        [controllerTableViewController setDisplayLoadGames:NO];
    }
    
    
    //if (_pgnFileDoc.pgnFileInfo) {
    //    [controllerTableViewController setIndexGame:[_pgnGame indexInAllGamesAllTags]];
    //    [controllerTableViewController setNameDatabase:[_pgnFileDoc.pgnFileInfo fileName]];
    //}
    //[ctvc setContentSizeForViewInPopover:CGSizeMake(350.0, 450.0)];
    //[controllerTableViewController setContentSizeForViewInPopover:CGSizeMake(270.0, 300.0)];
    controllerNavigationController = [[UINavigationController alloc] initWithRootViewController:controllerTableViewController];
    [controllerNavigationController setPreferredContentSize:CGSizeMake(270.0, 300.0)];
    
    //[boardModel printPosition];
    
    if (IS_PAD) {
        controllerPopoverController = [[UIPopoverController alloc] initWithContentViewController:controllerNavigationController];
        [controllerPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        controllerNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
        //[self presentModalViewController:controllerNavigationController animated:YES];
        [self presentViewController:controllerNavigationController animated:YES completion:nil];
        //[self.navigationController pushViewController:controllerTableViewController animated:YES];
    }
    
    /*
    if (_insertMode) {
        UIViewController *vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        [vc setContentSizeForViewInPopover:CGSizeMake(200.0, 200.0)];
        vc.view.backgroundColor = [UIColor yellowColor];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
        if (IS_PAD) {
            controllerPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
            [controllerPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            [self.navigationController pushViewController:vc animated:YES];
        }
    }*/
}


- (void) gestisciEngineViewLandscape {
    if (sizeBoard == BIG) {
        [analysisView setFrame:CGRectMake(55.0, 0.0, 299.0, 19.0)];
        [searchStatsView setFrame:CGRectMake(55.0, 19.0, 299.0, 19.0)];
        [engineView setFrame:CGRectMake(660.0, 622.0, 364.0, 38.0)];
    }
    else if (sizeBoard == MEDIUM) {
        //[analysisView setFrame:CGRectMake(55.0, 0.0, 299.0, 19.0)];
        //[searchStatsView setFrame:CGRectMake(55.0, 19.0, 299.0, 19.0)];
        //[engineView setFrame:CGRectMake(660.0, 622.0, 364.0, 38.0)];
        [engineView setFrame:CGRectMake([settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*8, 622.0, (1024.0 - [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*8), 38)];
        [searchStatsView setFrame:CGRectMake(55.0, 19.0, (1024.0 - [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*8 - 65.0), 19.0)];
        [analysisView setFrame:CGRectMake(55.0, 0.0, (1024.0 - [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*8 - 65.0), 19.0)];
    }
    else if (sizeBoard == SMALL) {
        [engineView setFrame:CGRectMake([settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*8, 622.0, (1024.0 - [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*8), 38)];
        [searchStatsView setFrame:CGRectMake(55.0, 19.0, (1024.0 - [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*8 - 65.0), 19.0)];
        [analysisView setFrame:CGRectMake(55.0, 0.0, (1024.0 - [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft]*8 - 65.0), 19.0)];
    }
}

- (void) gestisciEngineViewPortrait {
    [analysisView setFrame:CGRectMake(65.0, 0.0, 703.0, 19.0)];
    [searchStatsView setFrame:CGRectMake(65.0, 19.0, 703.0, 19.0)];
    [engineView setFrame:CGRectMake(0.0, 879.0, 768.0, 38.0)];
    return;
    if (sizeBoard == BIG) {
        [analysisView setFrame:CGRectMake(65.0, 0.0, 703.0, 19.0)];
        [searchStatsView setFrame:CGRectMake(65.0, 19.0, 703.0, 19.0)];
        [engineView setFrame:CGRectMake(0.0, 879.0, 768.0, 38.0)];
    }
    else if (sizeBoard == MEDIUM) {
        [analysisView setFrame:CGRectMake(65.0, 0.0, 703.0, 38.0)];
        [searchStatsView setFrame:CGRectMake(65.0, 19.0, 703.0, 38.0)];
        [engineView setFrame:CGRectMake(0.0, 841.0, 768.0, 76.0)];
    }
    else if (sizeBoard == SMALL) {
        [analysisView setFrame:CGRectMake(65.0, 0.0, 703.0, 57.0)];
        [searchStatsView setFrame:CGRectMake(65.0, 19.0, 703.0, 57.0)];
        [engineView setFrame:CGRectMake(0.0, 805.0, 768.0, 114.0)];
    }
}


- (void) openEngineView {
    if (IsChessStudioLight) {
        return;
    }
    if (![settingManager isEngineViewOpen]) {
        return;
    }
    if (IS_PAD) {
        //if (engineController.engineThreadIsRunning) {
        //    return;
        //}
        //[_gameWebView setFrame:[UtilToView getPadPortraitMovesFrameWithEngine]];
        [_gameWebView refresh];
        
        if (engineView) {
            [self.view addSubview:engineView];
            return;
        }
        
        engineView = [[UIView alloc] initWithFrame:[UtilToView getPadPortraitEngineViewFrame]];
        [engineView setBackgroundColor:[UIColor whiteColor]];
        engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        engineView.layer.borderWidth = 1.0;
        [self.view addSubview:engineView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(2.0, 4.0, 50.0, 30.0);
        
        [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        [button setTitle:@"Start\nEngine" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
        [engineView addSubview:button];
        
        analysisView = [[UILabel alloc] initWithFrame:CGRectMake(65, 0.0, 703.0, 19.0)];
        [analysisView setFont: [UIFont systemFontOfSize: 13.0]];
        [analysisView setBackgroundColor: [UIColor lightTextColor]];
        //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        //analysisView.layer.borderWidth = 1.0;
        [engineView addSubview:analysisView];
        
        searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 19.0, 703.0, 19.0)];
        [searchStatsView setFont: [UIFont systemFontOfSize: 13.0]];
        [searchStatsView setBackgroundColor: [UIColor whiteColor]];
        //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        //searchStatsView.layer.borderWidth = 1.0;
        [engineView addSubview: searchStatsView];
    }
    else if (IS_IPHONE_5) {
        //if (engineController.engineThreadIsRunning) {
        //    return;
        //}
        [_gameWebView setFrame:CGRectMake(0.0, 320.0, 320.0, 140.0 - 38.0)];
        [_gameWebView refresh];
        
        if (engineView) {
            [self.view addSubview:engineView];
            return;
        }
        
        
        engineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 320.0 + 140.0 - 38.0, 320.0, 38.0)];
        [engineView setBackgroundColor:[UIColor whiteColor]];
        engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        engineView.layer.borderWidth = 1.0;
        [self.view addSubview:engineView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //button.frame = CGRectMake(2.0, 4.0, 50.0, 30.0);
        button.frame = CGRectMake(0.0, 12.0, 30.0, 30.0);
        
        [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        
        [engineView addSubview:button];
        
        analysisView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 0.0, 320.0 - 55.0, 19.0)];
        [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
        [analysisView setBackgroundColor: [UIColor lightTextColor]];
        //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        //analysisView.layer.borderWidth = 1.0;
        [engineView addSubview:analysisView];
        
        searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 19.0, 320.0 - 55.0, 19.0)];
        [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
        [searchStatsView setBackgroundColor: [UIColor whiteColor]];
        //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        //searchStatsView.layer.borderWidth = 1.0;
        [engineView addSubview: searchStatsView];
    }
    else if (IS_PHONE) {
        [self openEngineViewPhonePortrait];
        return;
        if (engineController.engineThreadIsRunning) {
            return;
        }
        //[_gameWebView setFrame:CGRectMake(0.0, 320.0, 320.0, 140.0 - 38.0)];
        [_gameWebView setFrame:CGRectMake(boardView.frame.size.width, 0, 480 - boardView.frame.size.width, boardView.frame.size.height - 38.0)];
        [_gameWebView refresh];
        engineView = [[UIView alloc] initWithFrame:CGRectMake(boardView.frame.size.width, boardView.frame.size.height - 38, 320.0, 38.0)];
        [engineView setBackgroundColor:[UIColor whiteColor]];
        engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        engineView.layer.borderWidth = 1.0;
        [self.view addSubview:engineView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        //CGSize stringsize = [@"Start\nEngine" sizeWithFont:[UIFont systemFontOfSize:11.0]];
        
        button.frame = CGRectMake(0.0, 12.0, 30.0, 30.0);
        //button.frame = CGRectMake(2.0, 4.0, stringsize.width, stringsize.height);
        
        [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        
        if (engineController.engineThreadIsRunning) {
            [button setTitle:@"Stop\nEngine" forState:UIControlStateNormal];
        }
        else {
            [button setTitle:@"Start\nEngine" forState:UIControlStateNormal];
        }
        [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [button sizeToFit];
        
        [engineView addSubview:button];
        
        analysisView = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 0.0, 320.0 - 105.0, 19.0)];
        [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
        [analysisView setBackgroundColor: [UIColor lightTextColor]];
        //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        //analysisView.layer.borderWidth = 1.0;
        //analysisView.lineBreakMode = UILineBreakModeTailTruncation;
        [engineView addSubview:analysisView];
        
        searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 19.0, 320.0 - 105.0, 19.0)];
        [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
        [searchStatsView setBackgroundColor: [UIColor whiteColor]];
        //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        //searchStatsView.layer.borderWidth = 1.0;
        [engineView addSubview: searchStatsView];
    }
}


- (void) openEngineViewPadPortrait {
    if (IsChessStudioLight && !startFenPosition) {
        [self manageGameWebViewFrame];
        return;
    }
    
    if (_setupPosition) {
        return;
    }
    
    if (![settingManager isEngineViewOpen]) {
        [self manageGameWebViewFrame];
        return;
    }
    //[_gameWebView setFrame:[UtilToView getPadPortraitMovesFrameWithEngine]];
    //[_gameWebView refresh];
    [self manageGameWebViewFrame];
    
    if (engineView) {
        [self.view addSubview:engineView];
        return;
    }
    
    //UIImage *sfondoEngine = [UIImage imageNamed:@"sfondoEngine7.png"];
    
    engineView = [[UIView alloc] initWithFrame:[UtilToView getPadPortraitEngineViewFrame]];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    //[engineView setBackgroundColor:[UIColor colorWithRed:76.0 green:217.0 blue:100.0 alpha:1.0]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    //engineView.layer.backgroundColor = [UIColor colorWithRed:76.0 green:217.0 blue:100.0 alpha:1.0].CGColor;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(2.0, 4.0, 50.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [engineView addSubview:button];
    
    //button.backgroundColor = [UIColor colorWithPatternImage:sfondoEngine];
    //engineView.backgroundColor = [UIColor colorWithPatternImage:sfondoEngine];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(65, 0.0, 703.0, 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 13.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //[analysisView setBackgroundColor:[UIColor colorWithRed:76.0 green:217.0 blue:100.0 alpha:1.0]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    //analysisView.backgroundColor = [UIColor colorWithPatternImage:sfondoEngine];
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 19.0, 703.0, 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 13.0]];
    //searchStatsView.backgroundColor = [UIColor colorWithPatternImage:sfondoEngine];
    //[searchStatsView setBackgroundColor:[UIColor colorWithRed:76.0 green:217.0 blue:100.0 alpha:1.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
}

- (void) openEngineViewPadLandscape {
    if (IsChessStudioLight && !startFenPosition) {
        [self manageGameWebViewFrame];
        return;
    }
    
    if (_setupPosition) {
        return;
    }
    
    if (![settingManager isEngineViewOpen]) {
        [self manageGameWebViewFrame];
        return;
    }
    
    //[_gameWebView setFrame:CGRectMake(660, 0, 364, 622)];
    //[_gameWebView refresh];
    
    [self gestioneGameWebView];
    
    if (engineView) {
        //if (sizeBoard == BIG) {
        
            [engineView setFrame:CGRectMake(_gameWebView.frame.origin.x, _gameWebView.frame.size.height, _gameWebView.frame.size.width, 38.0)];
        //}
        //[self.view addSubview:engineView];
        return;
    }
    
    engineView = [[UIView alloc] initWithFrame:CGRectMake(660.0, 622.0, 364.0, 38.0)];
    [engineView setFrame:CGRectMake(_gameWebView.frame.origin.x, _gameWebView.frame.size.height, _gameWebView.frame.size.width, 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(2.0, 4.0, 50.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 0.0, 299.0, 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 13.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 19.0, 299.0, 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 13.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
    
}

- (void) openEngineViewPhonePortrait {
    
    NSLog(@"Sto Eseguendo OpenEngineViewPhonePortrait");
    
    if (IsChessStudioLight & !startFenPosition) {
        [self manageGameWebViewFrame];
        return;
    }
    
    if (_setupPosition) {
        return;
    }
    
    if ([settingManager isEngineViewClosed]) {
        [self manageGameWebViewFrame];
        return;
    }
    
    [engineView removeFromSuperview];
    engineView = nil;
    //[_gameWebView setFrame:CGRectMake(0.0, 320.0, 320.0, 52.0 - 19.0)];
    //[_gameWebView refresh];
    //[self manageGameWebViewFrame];
    [self gestioneGameWebView];
    
    if (engineView) {
        [self.view addSubview:engineView];
        return;
    }
    
    if ([settingManager boardSize] == BIG) {
        engineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 320.0 + 52.0 - 19.0, 320.0, 19.0)];
        [engineView setBackgroundColor:[UIColor whiteColor]];
        engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        engineView.layer.borderWidth = 1.0;
        //[self.view addSubview:engineView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(1.0, 2.0, 27.0, 17.0);
        
        [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        if ([self isEngineRunning]) {
            [button setTitle:NSLocalizedString(@"STOP_ENGINE_PHONE", nil) forState:UIControlStateNormal];
        }
        else {
            [button setTitle:NSLocalizedString(@"START_ENGINE_PHONE", nil) forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        if (IS_ITALIANO) {
            [button.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
        }
        else {
            [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
        }
        
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [engineView addSubview:button];
        
        analysisView = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 0.0, 320.0 - 30.0, 19.0)];
        [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
        [analysisView setBackgroundColor: [UIColor lightTextColor]];
        //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        //analysisView.layer.borderWidth = 1.0;
        [engineView addSubview:analysisView];
        
        [self.view addSubview:engineView];
    }
    else {
        engineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 320.0 + 52.0 - 38.0, 320.0, 38.0)];
        [engineView setBackgroundColor:[UIColor whiteColor]];
        engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        engineView.layer.borderWidth = 1.0;
        //[self.view addSubview:engineView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(1.0, 2.0, 40.0, 30.0);
        
        [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        if ([self isEngineRunning]) {
            [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
        }
        else {
            [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        if (IS_ITALIANO) {
            [button.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
        }
        else {
            [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
        }
        
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [engineView addSubview:button];
        
        analysisView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, (320.0 - 40), 19.0)];
        [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
        [analysisView setBackgroundColor: [UIColor lightTextColor]];
        //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        //analysisView.layer.borderWidth = 1.0;
        [engineView addSubview:analysisView];
        
        searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 19.0, (320.0 - 40), 19.0)];
        [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
        [searchStatsView setBackgroundColor: [UIColor whiteColor]];
        //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        //searchStatsView.layer.borderWidth = 1.0;
        [engineView addSubview: searchStatsView];
        
        [self.view addSubview:engineView];
    }

}

- (void) openEngineViewPhoneLandscape {
    
    NSLog(@"ESEGUO OPENENGINEVIEW_PHONE_LANDSCAPE");
    
    if (IsChessStudioLight & !startFenPosition) {
        [self manageGameWebViewFrame];
        return;
    }
    
    if (_setupPosition) {
        return;
    }
    
    if ([settingManager isEngineViewClosed]) {
        [self manageGameWebViewFrame];
        return;
    }
    
    [engineView removeFromSuperview];
    engineView = nil;
    
    [self gestioneGameWebView];
    
    //if (engineView) {
    //    [self.view addSubview:engineView];
    //    return;
    //}
    
    CGFloat square = [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft];
    
    
    engineView = [[UIView alloc] initWithFrame:CGRectMake(square*8, (square*8 - 38.0), (480.0 - square*8), 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    if (IS_ITALIANO) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
    }
    else {
        [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, (480.0 - square*8 - 40), 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 19.0, (480.0 - square*8 - 40), 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
    
    
}

- (void) openEngineViewPhone5Portrait {
    
    
    if (IsChessStudioLight & !startFenPosition) {
        [self manageGameWebViewFrame];
        return;
    }
    
    if (_setupPosition) {
        return;
    }
    
    
    if ([settingManager isEngineViewClosed]) {
        [self manageGameWebViewFrame];
        return;
    }
    
    //[_gameWebView setFrame:CGRectMake(0.0, 320.0, 320.0, 140.0 - 38.0)];
    //[_gameWebView refresh];
    [self manageGameWebViewFrame];
    
    if (engineView) {
        [self.view addSubview:engineView];
        return;
    }
    
    
    engineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 320.0 + 140.0 - 38.0, 320.0, 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //button.frame = CGRectMake(2.0, 4.0, 50.0, 30.0);
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    //[button sizeToFit];
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 0.0, 320.0 - 55.0, 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 19.0, 320.0 - 55.0, 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
}

- (void) openEngineViewPhone5Landscape {
    
    NSLog(@"Sto eseguendo openEngineViewPhone5Landscape");
    
    if (IsChessStudioLight & !startFenPosition) {
        [self manageGameWebViewFrame];
        return;
    }
    
    if (_setupPosition) {
        return;
    }
    
    if ([settingManager isEngineViewClosed]) {
        [self manageGameWebViewFrame];
        return;
    }
    
    [engineView removeFromSuperview];
    engineView = nil;
    
    [self manageGameWebViewFrame];
    
    //if (engineView) {
    //    [self.view addSubview:engineView];
    //    return;
    //}
    
    CGFloat square = [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft];
    
    engineView = [[UIView alloc] initWithFrame:CGRectMake(square*8, (square*8 - 38.0), (568.0 - square*8), 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    if (IS_ITALIANO) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
    }
    else {
        [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, (568.0 - square*8 - 40), 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 19.0, (568.0 - square*8 - 40), 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
    
    
}

- (void) openEngineViewPhone6Portrait {
    if (IsChessStudioLight & !startFenPosition) {
        [self manageGameWebViewFrame];
        return;
    }
    
    if (_setupPosition) {
        return;
    }
    
    
    if ([settingManager isEngineViewClosed]) {
        [self manageGameWebViewFrame];
        return;
    }
    
    //[_gameWebView setFrame:CGRectMake(0.0, 320.0, 320.0, 140.0 - 38.0)];
    //[_gameWebView refresh];
    [self manageGameWebViewFrame];
    
    if (engineView) {
        [self.view addSubview:engineView];
        return;
    }
    
    engineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 375.0 + 184.0 - 38.0, 375.0, 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //button.frame = CGRectMake(2.0, 4.0, 50.0, 30.0);
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    //[button sizeToFit];
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 0.0, 375.0 - 55.0, 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 19.0, 375.0 - 55.0, 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
}

- (void) openEngineViewPhone6Landscape {
    NSLog(@"Sto eseguendo openEngineViewPhone6Landscape");
    
    if (IsChessStudioLight & !startFenPosition) {
        [self manageGameWebViewFrame];
        return;
    }
    
    if (_setupPosition) {
        return;
    }
    
    if ([settingManager isEngineViewClosed]) {
        [self manageGameWebViewFrame];
        return;
    }
    
    [engineView removeFromSuperview];
    engineView = nil;
    
    [self manageGameWebViewFrame];
    
    //if (engineView) {
    //    [self.view addSubview:engineView];
    //    return;
    //}
    
    CGFloat square = [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft];
    
    engineView = [[UIView alloc] initWithFrame:CGRectMake(square*8, (square*8 - 38.0), (667.0 - square*8), 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    if (IS_ITALIANO) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
    }
    else {
        [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, (667.0 - square*8 - 40), 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 19.0, (667.0 - square*8 - 40), 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
}

- (void) openEngineViewPhone6PPortrait {
    if (IsChessStudioLight & !startFenPosition) {
        [self manageGameWebViewFrame];
        return;
    }
    
    if (_setupPosition) {
        return;
    }
    
    
    if ([settingManager isEngineViewClosed]) {
        [self manageGameWebViewFrame];
        return;
    }
    
    //[_gameWebView setFrame:CGRectMake(0.0, 320.0, 320.0, 140.0 - 38.0)];
    //[_gameWebView refresh];
    [self manageGameWebViewFrame];
    
    if (engineView) {
        [self.view addSubview:engineView];
        return;
    }
    
    engineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 414.0 + 214.0 - 38.0, 414.0, 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //button.frame = CGRectMake(2.0, 4.0, 50.0, 30.0);
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    //[button sizeToFit];
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 0.0, 414.0 - 55.0, 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 19.0, 414.0 - 55.0, 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
}

- (void) openEngineViewPhone6PLandscape {
    NSLog(@"Sto eseguendo openEngineViewPhone6PLandscape");
    
    if (IsChessStudioLight & !startFenPosition) {
        [self manageGameWebViewFrame];
        return;
    }
    
    if (_setupPosition) {
        return;
    }
    
    if ([settingManager isEngineViewClosed]) {
        [self manageGameWebViewFrame];
        return;
    }
    
    [engineView removeFromSuperview];
    engineView = nil;
    
    [self manageGameWebViewFrame];
    
    //if (engineView) {
    //    [self.view addSubview:engineView];
    //    return;
    //}
    
    CGFloat square = [settingManager getFixedSquareSize:UIDeviceOrientationLandscapeLeft];
    
    engineView = [[UIView alloc] initWithFrame:CGRectMake(square*8, (square*8 - 38.0), (736.0 - square*8), 38.0)];
    [engineView setBackgroundColor:[UIColor whiteColor]];
    engineView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    engineView.layer.borderWidth = 1.0;
    [self.view addSubview:engineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(1.0, 5.0, 40.0, 30.0);
    
    [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    if ([self isEngineRunning]) {
        [button setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    else {
        [button setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    if (IS_ITALIANO) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:9.0]];
    }
    else {
        [button.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    }
    
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(buttonEnginePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [engineView addSubview:button];
    
    analysisView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, (736.0 - square*8 - 40), 19.0)];
    [analysisView setFont: [UIFont systemFontOfSize: 11.0]];
    [analysisView setBackgroundColor: [UIColor lightTextColor]];
    //analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //analysisView.layer.borderWidth = 1.0;
    [engineView addSubview:analysisView];
    
    searchStatsView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 19.0, (736.0 - square*8 - 40), 19.0)];
    [searchStatsView setFont: [UIFont systemFontOfSize: 11.0]];
    [searchStatsView setBackgroundColor: [UIColor whiteColor]];
    //searchStatsView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
    //searchStatsView.layer.borderWidth = 1.0;
    [engineView addSubview: searchStatsView];
}

- (void) closeEngineView {
    if (IsChessStudioLight) {
        return;
    }
    if (IS_PAD) {
        if (searchStatsView) {
            [searchStatsView removeFromSuperview];
            searchStatsView = nil;
        }
        if (analysisView) {
            [analysisView removeFromSuperview];
            analysisView = nil;
        }
        if (engineView) {
            [engineView removeFromSuperview];
            engineView = nil;
        }
        [_gameWebView setFrame:[UtilToView getPadPortraitMovesFrameWithoutEngine]];
    }
}

- (void) startEngineController {
    
    //openingBookManager = [[BookManager alloc] initWithBook:nil];
    //if (openingBookManager) {
    //    NSLog(@"Opening Book OK");
    //    [openingBookManager interrogaBook:@"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"];
    //}
    //else {
    //    NSLog(@"Opening Book KO");
    //}
    
    if (engineController.engineThreadIsRunning) {
        return;
    }
    options = [Options sharedOptions];
    [options setPermanentBrain:NO];
    //[options setStrength:5];
    //[options setGameLevel:LEVEL_10S_PER_MOVE];
    engineController = [[EngineController alloc] initWithoutGameController];
    [engineController setStartFenPosition:startFenPosition];
    [engineController sendCommand: @"uci"];
    
    [engineController sendCommand: @"isready"];
    [engineController sendCommand: @"ucinewgame"];
    if ([[Options sharedOptions] permanentBrain])
        [engineController setOption: @"Ponder" value: @"true"];
    else
        [engineController setOption: @"Ponder" value: @"false"];
    
    [engineController setOption: @"Skill Level" value: [NSString stringWithFormat: @"%d", [[Options sharedOptions] strength]]];
    [engineController commitCommands];
    
    engineController.delegate = self;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:prossimaMossa forKey:@"MOSSA"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EngineNotification" object:prossimaMossa userInfo:userInfo];
}

- (void) buttonEnginePressed:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"START_ENGINE_PAD", nil)]) {
        [sender setTitle:NSLocalizedString(@"STOP_ENGINE_PAD", nil) forState:UIControlStateNormal];
        [self startEngineController];
    }
    else if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"START_ENGINE_PHONE", nil)]) {
        [sender setTitle:NSLocalizedString(@"STOP_ENGINE_PHONE", nil) forState:UIControlStateNormal];
        [self startEngineController];
    }
    else if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"STOP_ENGINE_PAD", nil)]) {
        [sender setTitle:NSLocalizedString(@"START_ENGINE_PAD", nil) forState:UIControlStateNormal];
        [self stopEngineController];
    }
    else if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"STOP_ENGINE_PHONE", nil)]) {
        [sender setTitle:NSLocalizedString(@"START_ENGINE_PHONE", nil) forState:UIControlStateNormal];
        [self stopEngineController];
    }
}

- (void) stopEngineController {
    if (!engineController) {
        return;
    }
    if (engineController.engineThreadIsRunning) {
        [engineController quit];
        engineController = nil;
    }
}

- (void) sendMoveToEngine:(PGNMove *)move {
    
    if (IsChessStudioLight && !startFenPosition) {
        return;
    }
    
    //if (bookManager) {
    //    [bookManager interrogaBook:[move fen]];
    //}
    
    [self trovaBook:move];
    
    [self trovaECO:move];
    
    
    if (!engineController) {
        return;
    }
    
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:prossimaMossa forKey:@"MOSSA"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EngineNotification" object:self userInfo:userInfo];
}


- (void) setupPgnGame {
    //[boardModel setNumberFirstMoveInSetupPosition:1];
    //[boardModel setBiancoPuoArroccareCorto:NO];
    //[boardModel setBiancoPuoArroccareLungo:NO];
    //[boardModel setNeroPuoArroccareCorto:NO];
    //[boardModel setNeroPuoArroccareLungo:NO];
    [boardModel setupForNalimov];
    startFenPosition = [boardModel calcFenNotationWithNumberFirstMove];
    
    BOOL toccaMuovereAlBianco = [boardModel whiteHasToMove];
    
    _pgnGame = [[PGNGame alloc] initWithFen:[boardModel fenNotation]];
    [_pgnGame setEditMode:YES];
    [boardModel setStartFromFen:YES];
    //[boardModel setFenNotation:[_pgnGame getTagValueByTagName:@"FEN"]];
    
    if (!toccaMuovereAlBianco) {
        [_pgnGame setMoves:@"1. XXX *"];
        _gameToView = [[NSMutableString alloc] initWithString:[_pgnGame moves]];
        [self parseGame];
        [boardModel setWhiteHasToMove:toccaMuovereAlBianco];
        [self evidenziaAChiToccaMuovere];
        [self aggiornaWebView];
        prossimaMossa = [[pgnRootMove getNextMoves] objectAtIndex:0];
        [prossimaMossa setFen:startFenPosition];
        
        //NSLog(@"FEN POSITION = %@", [prossimaMossa fenForBookMoves]);
        //NSLog(@"Tocca muovere al Nero");
    }
    else {
        //[_pgnGame setMoves:@""];
        _gameToView = [[NSMutableString alloc] initWithString:[_pgnGame moves]];
        //NSLog(@"POSITION SETUP GAME = %@", _gameToView);
        [self parseGame];
        resultMove = [[PGNMove alloc] initWithFullMove:@"*"];
        [self aggiornaWebView];
        [prossimaMossa setFen:startFenPosition];
        //NSLog(@"Tocca muovere al Bianco");
    }
    
    [_gameWebView setFrame:[settingManager getNalimovWebViewFrame]];
    [_gameWebView refresh];
    
}

- (void) getNalimovResultOld {
    
    if (networkStatus == NotReachable) {
        UIAlertView *notReachableAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_INTERNET", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [notReachableAlertView show];
        return;
    }
    
    NSString *completeAddress;
    NSString *firstPartaddress = @"http://www.k4it.de/egtb/fetch.php?obid=et30.8461838087532669&reqid=req0.5&hook=null&action=egtb&fen=";
    NSString *secondPartAddress = @" egtb&fen=";
    completeAddress = [firstPartaddress stringByAppendingString:[boardModel fenNotationNalimov]];
    completeAddress = [completeAddress stringByAppendingString:[boardModel fenNotationNalimov]];
    completeAddress = [completeAddress stringByAppendingString:secondPartAddress];
    completeAddress = [completeAddress stringByAppendingString:[boardModel fenNotation]];
    
    NSString *completeAddressEscaped = [completeAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", completeAddressEscaped);
    
    NSURL *url = [NSURL URLWithString:completeAddressEscaped];
    
    
    //url = [NSURL URLWithString:@"http://www.k4it.de/egtb/fetch.php?obid=et30.9277639305219054&reqid=req0.48456263076514006&hook=null&action=egtb&fen=4k3/8/8/8/8/8/1B4B1/4K3%20egtb&fen=4k3/8/8/8/8/8/1B4B1/4K3%20w%20-%20-%200%201"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
        return;
    }
    
    NSString *risu = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
    
    if ([risu rangeOfString:@"Error"].location != NSNotFound) {
        NSLog(@"Dati insufficienti");
        NSLog(@"%@", risu);
        //return;
    }
    
    NSLog(@"%@", risu);
    
    NSArray *risuArray = [risu componentsSeparatedByString:@"\n"];
    NSMutableArray *movesArray = [[NSMutableArray alloc] initWithArray:risuArray];
    [movesArray removeObjectAtIndex:0];
    
    NSMutableArray *mosseBianco = [[NSMutableArray alloc] init];
    NSMutableArray *mosseNero = [[NSMutableArray alloc] init];
    BOOL mosseDelBianco = YES;
    for (NSString *s in movesArray) {
        if ([s hasPrefix:@"NEXTCOLOR"]) {
            mosseDelBianco = NO;
        }
        if (mosseDelBianco) {
            if ([self hasLeadingNumberInString:s]) {
                NSArray *a = [s componentsSeparatedByString:@":"];
                NSString *m = [a objectAtIndex:0];
                NSString *m1 = [self convertDevelopmentNotation:m];
                NSString *mf = [NSString stringWithFormat:@"%@:%@", m1, [a objectAtIndex:1]];
                [mosseBianco addObject:mf];
            }
            
        }
        else {
            if ([self hasLeadingNumberInString:s]) {
                NSArray *a = [s componentsSeparatedByString:@":"];
                NSString *m = [a objectAtIndex:0];
                NSString *m1 = [self convertDevelopmentNotation:m];
                NSString *mf = [NSString stringWithFormat:@"%@:%@", m1, [a objectAtIndex:1]];
                [mosseNero addObject:mf];
            }
        }
    }
    
    //for (NSString *s in mosseBianco) {
        //NSLog(@"*********** %@", s);
    //}
    //for (NSString *s in mosseNero) {
        //NSLog(@"$$$$$$$$$$$ %@", s);
    //}
    
    if ([boardModel whiteHasToMove]) {
        _tableViewData = [[NSMutableArray alloc] initWithArray:mosseBianco];
    }
    else {
        _tableViewData = [[NSMutableArray alloc] initWithArray:mosseNero];
    }
    
    
    [_tableView reloadData];
}

- (void) getNalimovResult {
    if (networkStatus == NotReachable) {
        UIAlertView *notReachableAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_INTERNET", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [notReachableAlertView show];
        return;
    }
    
    if (!nalimovCheck) {
        return;
    }
    
    NSString *completeAddress;
    NSString *firstPartaddress = @"http://www.k4it.de/egtb/fetch.php?obid=et30.8461838087532669&reqid=req0.5&hook=null&action=egtb&fen=";
    NSString *secondPartAddress = @" egtb&fen=";
    NSString *fenNalimov = [boardModel fenNotationNalimov];
    completeAddress = [firstPartaddress stringByAppendingString:fenNalimov];
    completeAddress = [completeAddress stringByAppendingString:fenNalimov];
    completeAddress = [completeAddress stringByAppendingString:secondPartAddress];
    completeAddress = [completeAddress stringByAppendingString:[boardModel fenNotation]];
    
    NSString *completeAddressEscaped = [completeAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@", completeAddressEscaped);
    
    NSURL *url = [NSURL URLWithString:completeAddressEscaped];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"error:%@", error.localizedDescription);
                                   //[self stopIndicatorView];
                                   return;
                               }
                               
                               NSString *risu = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               if ([risu rangeOfString:@"Error"].location != NSNotFound) {
                                   NSLog(@"Dati insufficienti");
                                   //NSLog(@"%@", risu);
                                   //return;
                               }
                               
                               NSArray *risuArray = [risu componentsSeparatedByString:@"\n"];
                               NSMutableArray *movesArray = [[NSMutableArray alloc] initWithArray:risuArray];
                               [movesArray removeObjectAtIndex:0];
                               
                               NSMutableArray *mosseBianco = [[NSMutableArray alloc] init];
                               NSMutableArray *mosseNero = [[NSMutableArray alloc] init];
                               BOOL mosseDelBianco = YES;
                               for (NSString *s in movesArray) {
                                   if ([s hasPrefix:@"NEXTCOLOR"]) {
                                       mosseDelBianco = NO;
                                   }
                                   if (mosseDelBianco) {
                                       if ([self hasLeadingNumberInString:s]) {
                                           NSArray *a = [s componentsSeparatedByString:@":"];
                                           NSString *m = [a objectAtIndex:0];
                                           NSString *m1 = [self convertDevelopmentNotation:m];
                                           NSString *mf = [NSString stringWithFormat:@"%@:%@", m1, [a objectAtIndex:1]];
                                           [mosseBianco addObject:mf];
                                       }
                                       
                                   }
                                   else {
                                       if ([self hasLeadingNumberInString:s]) {
                                           NSArray *a = [s componentsSeparatedByString:@":"];
                                           NSString *m = [a objectAtIndex:0];
                                           NSString *m1 = [self convertDevelopmentNotation:m];
                                           NSString *mf = [NSString stringWithFormat:@"%@:%@", m1, [a objectAtIndex:1]];
                                           [mosseNero addObject:mf];
                                       }
                                   }
                               }
                               
                               if ([boardModel whiteHasToMove]) {
                                   _tableViewData = [[NSMutableArray alloc] initWithArray:mosseBianco];
                               }
                               else {
                                   _tableViewData = [[NSMutableArray alloc] initWithArray:mosseNero];
                               }
                               
                               [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                               
                               //[_tableView reloadData];
                               //[self performSelectorOnMainThread:@selector(stopIndicatorView) withObject:nil waitUntilDone:YES];
                               //[_tableView setUserInteractionEnabled:YES];
                               
                           }];
}

- (BOOL) hasLeadingNumberInString:(NSString *)s {
    if (s)
        return [s length] && isnumber([s characterAtIndex:0]);
    else
        return NO;
}

- (NSString *) convertDevelopmentNotation:(NSString *)s {
    if (s) {
        //NSArray *a = [s componentsSeparatedByString:@":"];
        //NSString *m = [a objectAtIndex:0];
        NSArray *ma = [s componentsSeparatedByString:@"-"];
        if ([ma count] == 3) {
            //NSLog(@"PROMOZIONE");
            NSString *sp = [ma objectAtIndex:0];
            NSString *sa = [ma objectAtIndex:1];
            NSString *pp = [ma objectAtIndex:2];
            switch ([pp intValue]) {
                case 2:
                case 8:
                    pp = @"Q";
                    break;
                case 3:
                case 9:
                    pp = @"R";
                    break;
                case 4:
                case 10:
                    pp = @"B";
                    break;
                case 5:
                case 11:
                    pp = @"N";
                    break;
                default:
                    break;
            }
            NSString *p = [boardModel getPieceSymbolAtSquareTag:[sp intValue]];
            NSString *acp = [boardModel getAlgebricValueFromSquareTag:[sp intValue]];
            NSString *aca = [boardModel getAlgebricValueFromSquareTag:[sa intValue]];
            return [NSString stringWithFormat:@"%@%@-%@=%@", p, acp, aca, pp];
        }
        else {
            NSString *sp = [ma objectAtIndex:0];
            NSString *sa = [ma objectAtIndex:1];
            NSString *p = [boardModel getPieceSymbolAtSquareTag:[sp intValue]];
            NSString *acp = [boardModel getAlgebricValueFromSquareTag:[sp intValue]];
            NSString *aca = [boardModel getAlgebricValueFromSquareTag:[sa intValue]];
            return [NSString stringWithFormat:@"%@%@-%@", p, acp, aca];
        }
    }
    return nil;
}

- (void) checkSquare:(int)squareTag {
    
    if (_setupPosition && selectedPieceForSetupPosition) {
        
        if ([selectedPieceForSetupPosition hasSuffix:@"p"]) {
            if ((squareTag>=0 && squareTag<=7) || (squareTag>=56 && squareTag<=63)) {
                return;
            }
        }
        
        if (boardModel.getNumberPiecesInBoard == 3 && IsChessStudioLight) {
            UIAlertView *lightAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"LIGHT_NALIMOV", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [lightAlertView show];
            return;
        }
        
        PieceButton *pb = [self setupPiece:selectedPieceForSetupPosition];
        pb.delegate = self;
        if (flipped) {
            [pb flip];
        }
        [pb setSquareValue:squareTag];
        [boardView addSubview:pb];
        [boardModel setPiece:squareTag :selectedPieceForSetupPosition];
        
        NSString *fen = [NSString stringWithFormat:@" FEN: %@", [boardModel fenNotation]];
        [fenLabel setText:fen];
        
        if ([boardModel isPositionForNalimovTablebase]) {
            //NSLog(@"Con questa posizione posso calcolare Nalimov Tablebase");
            
            boardView.layer.borderColor = [UIColor clearColor].CGColor;
            boardView.layer.borderWidth = 0.0;
            
        }
        else {
            //NSLog(@"Con questa posizione NON posso calcolare Nalimov Tablebase");
            
            
            
            
            [self clearNalimovTableView];
            [self setupPgnGame];
            
            //UIAlertView *noNalimovAlertView = [[UIAlertView alloc] initWithTitle:@"nalimov Tablebase" message:@"Analisi Nalimov Non Permessa" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //[noNalimovAlertView show];
            
            boardView.layer.borderColor = [UIColor redColor].CGColor;
            boardView.layer.borderWidth = 8.0;
            
            return;
        }
        
        
        [self setupPgnGame];
        
        [self getNalimovResult];
        
        return;
    }
    
    if (!_setupPosition && selectedPieceForSetupPosition) {
        //NSLog(@"Non devo fare niente");
        //return;
    }
    
    if (_setupPosition && !selectedPieceForSetupPosition) {
        //NSLog(@"Nessun pezzo selezionato per setup");
        return;
    }
    
    
    //NSLog(@"A questo punto devo gestire il secondo tap e spostare il pezzo selezionato con il primo tap");
    
    if (!_pgnGame.isEditMode) {
        NSString *title = NSLocalizedString(@"TITLE_EDIT_MODE", nil);
        UIAlertView *noInsertModeAlertView = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"ALERT_NO_INSERT_MODE_2", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        noInsertModeAlertView.tag = 100;
        [noInsertModeAlertView show];
        return;
    }
    
    
    if (candidateSquareTo == squareTag) {
        [boardView clearCanditatesPieces];
        [boardView clearArrivalSquare:squareTag];
        candidateSquareTo = -1;
        return;
    }
    
    if ([boardView candidatesPiecesAreHilighted]) {
        [boardView clearCanditatesPieces];
        [boardView clearArrivalSquare:candidateSquareTo];
        //return;
    }
    
    
    PieceButton *pieceButtonTapped = [boardView findPieceButtonTapped];
    
    if (!pieceButtonTapped) {
        
        //NSLog(@"BoardViewController: Analizzo squaretag %d", squareTag);
        
        NSMutableArray *listaPezzi;
        if ([boardModel whiteHasToMove]) {
            listaPezzi = [boardModel getListaPezziCheControllano:squareTag :@"b" :0];
        }
        else {
            listaPezzi = [boardModel getListaPezziCheControllano:squareTag :@"w" :-1];
        }
        
        if (listaPezzi.count > 0) {
            //NSLog(@"%@", listaPezzi);
        }
        
        
        //Controlla le case possibili che si verificano con il pedone che sarebbe costretto a muoversi indietro
        NSMutableArray *caseImpossibili = [[NSMutableArray alloc] init];
        for (NSString *casaOrigine in listaPezzi) {
            NSString *pezzo = [boardModel findContenutoBySquareNumber:[casaOrigine intValue]];
            if (![boardModel whiteHasToMove] && [pezzo hasPrefix:@"w"]) {
                [caseImpossibili addObject:casaOrigine];
            }
            if ([boardModel whiteHasToMove] && [pezzo hasPrefix:@"b"]) {
                [caseImpossibili addObject:casaOrigine];
            }
        }
        
        if (caseImpossibili.count>0) {
            [listaPezzi removeObjectsInArray:caseImpossibili];
        }
        
        
        NSMutableArray *caseProibiteCausaScacco = [[NSMutableArray alloc] init];
        for (NSString *casa in listaPezzi) {
            //NSLog(@"Devo vedere se il pezzo nella casa %@ può andare nella casa %d", casa, squareTag);
            int cp = [casa intValue];
            int ca = squareTag;
            //NSLog(@"Devo vedere se il pezzo nella casa %d può andare nella casa %d", cp, ca);
            if ([boardModel reSottoScacco:cp :ca]) {
                //NSLog(@"Se muovo il pezzo nella casa %d il re sarebbe sotto scacco!!", cp);
                [caseProibiteCausaScacco addObject:casa];
            }
        }
        
        if (caseProibiteCausaScacco.count>0) {
            [listaPezzi removeObjectsInArray:caseProibiteCausaScacco];
        }
        
        
        if ([boardModel canCaptureEnPassant]) {
            int casaEnPassant = [boardModel casaEnPassant];
            NSLog(@"Casa En Passant = %d", casaEnPassant);
            //[listaPezzi addObject:[NSString stringWithFormat:@"%d", [boardModel casaEnPassant]]];
            if ([boardModel whiteHasToMove]) {
                if (squareTag == casaEnPassant) {
                    int casa1 = casaEnPassant - 9;
                    int casa2 = casaEnPassant - 7;
                    int casa3 = casaEnPassant - 8;
                    NSString *contenutoCasa3 = [boardModel findContenutoBySquareNumber:casa3];
                    NSString *contenutoCasa1 = [boardModel findContenutoBySquareNumber:casa1];
                    if ([contenutoCasa1 hasSuffix:@"wp"] && [contenutoCasa3 hasSuffix:@"bp"]) {
                        [listaPezzi addObject:[NSNumber numberWithInt:casa1]];
                    }
                    NSString *contenutoCasa2 = [boardModel findContenutoBySquareNumber:casa2];
                    if ([contenutoCasa2 hasSuffix:@"wp"] && [contenutoCasa3 hasSuffix:@"bp"]) {
                        [listaPezzi addObject:[NSNumber numberWithInt:casa2]];
                    }
                }
            }
            else {
                if (squareTag == casaEnPassant) {
                    int casa1 = casaEnPassant + 9;
                    int casa2 = casaEnPassant + 7;
                    NSString *contenutoCasa1 = [boardModel findContenutoBySquareNumber:casa1];
                    if ([contenutoCasa1 hasSuffix:@"bp"]) {
                        [listaPezzi addObject:[NSNumber numberWithInt:casa1]];
                    }
                    NSString *contenutoCasa2 = [boardModel findContenutoBySquareNumber:casa2];
                    if ([contenutoCasa2 hasSuffix:@"bp"]) {
                        [listaPezzi addObject:[NSNumber numberWithInt:casa2]];
                    }
                }
            }
            
        }
        //NSLog(@"%@", listaPezzi);
        
        [boardView hilightCandidatesPieces:listaPezzi];
        if (listaPezzi.count > 0) {
            [boardView hilightArrivalSquare:squareTag];
        }
        
        
        candidateSquareTo = squareTag;
        
        return;
       
        
        if ([boardModel whiteHasToMove]) {
            if ([boardModel casaSottoAttacco:squareTag :@"b"]) {
                NSLog(@"La casa %d è sotto attacco dai pezzi neri", squareTag);
            }
        }
        else {
            if ([boardModel casaSottoAttacco:squareTag :@"w"]) {
                NSLog(@"La casa %d è sotto attacco dai pezzi bianchi", squareTag);
            }
        }
        
        return;
        
        if ([boardModel casaSottoAttacco:squareTag :@"b"]) {
            NSLog(@"La casa %d è sotto attacco dai pezzi bianchi", squareTag);
        }
        else {
            NSLog(@"La casa %d non è sotto attacco dai pezzi bianchi", squareTag);
        }
        if ([boardModel casaSottoAttacco:squareTag :@"w"]) {
            NSLog(@"La casa %d è sotto attacco dai pezzi neri", squareTag);
        }
        else {
            NSLog(@"La casa %d non è sotto attacco dai pezzi neri", squareTag);
        }
        
        
        return;
    }
    
    NSLog(@"Ho selezionato la casa di arrivo");
    
    if (![settingManager tapPieceToMove]) {
        UIAlertView *tapPieceAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_TAP_PIECE", nil) message:NSLocalizedString(@"SETTINGS_TAP_PIECE_DISABLED", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        tapPieceAlertView.tag = 600;
        [tapPieceAlertView show];
        [boardView clearHilightedAndControlledSquares];
        return;
    }
    
    int squareFrom = (int)pieceButtonTapped.tag;
    NSArray *mosseLegali = [[pieceButtonTapped pseudoLegalMoves] allObjects];
    NSNumber *squareTo = [NSNumber numberWithInt:squareTag];
    if ([mosseLegali containsObject:squareTo]) {
        [boardView clearHilightedAndControlledSquares];
        int resultCheckCasaArrivo = [self checkCasaArrivo:squareTag];
        if (resultCheckCasaArrivo == -2) {
            [boardView muoviPezzo:squareFrom :squareTag];
            return;
        }
        [boardView muoviPezzo:squareFrom :squareTag];
        [self gestisciMossaCompleta];
    }
    else {
        NSLog(@"La mossa non è possibile");
        [boardView clearHilightedAndControlledSquares];
    }
}


- (void) manageRightSwipeOnBoardView {
    //if (casaPartenza != -1) {
        //PieceButton *pb = [boardView findPieceBySquareTag:casaPartenza];
        //[pb setSquareValue:casaPartenza];
    //    casaPartenza = -1;
    //    return;
    //}
    
    if (_delegate && [_delegate respondsToSelector:@selector(getNextGame)]) {
        if ([_pgnGame isEditMode]) {
            return;
        }
        else {
            [self loadNextGame];
        }
    }
}

- (void) manageLeftSwipeOnBoardView {
    //if (casaPartenza != -1) {
        //PieceButton *pb = [boardView findPieceBySquareTag:casaPartenza];
        //[pb setSquareValue:casaPartenza];
    //     casaPartenza = -1;
    //    return;
    //}
    
    if (_delegate && [_delegate respondsToSelector:@selector(getNextGame)]) {
        if ([_pgnGame isEditMode]) {
            return;
        }
        else {
            [self loadPreviousGame];
        }
    }
}


- (void) willPresentAlertView:(UIAlertView *)alertView {
    
    
    if (alertView.tag == 3) {
        [alertView setBackgroundColor:[UIColor lightGrayColor]];
        for (UIView* view in [alertView subviews]) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if ([button.titleLabel.text isEqualToString:@"!"]) {
                    [button setFrame:CGRectMake(50, 96, 30, 30)];
                    [button setTitle:@"!" forState:UIControlStateNormal && UIControlStateHighlighted];
                }
            }
        }
        return;
    }
    
    
    if (alertView.tag == 10 || alertView.tag == 20) {
        
        [alertView setBackgroundColor:[UIColor lightGrayColor]];
        for (UIView* view in [alertView subviews]) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                NSString *path = [[pieceType stringByAppendingString:button.titleLabel.text] stringByAppendingString:@".png"];
                UIImage *image = [UIImage imageNamed:path];
                if ([button.titleLabel.text isEqualToString:@"wq"]) {
                    [button setFrame:CGRectMake(50, 96, 96, 96)];
                    [button setBackgroundImage:image forState:UIControlStateNormal];
                    [button setBackgroundImage:image forState:UIControlStateHighlighted];
                    [button setTitle:@"" forState:UIControlStateNormal && UIControlStateHighlighted];
                }
                if ([button.titleLabel.text isEqualToString:@"wr"]) {
                    [button setFrame:CGRectMake(146, 96, 96, 96)];
                    [button setBackgroundImage:image forState:UIControlStateNormal];
                    [button setBackgroundImage:image forState:UIControlStateHighlighted];
                    [button setTitle:@"" forState:UIControlStateNormal && UIControlStateHighlighted];
                }
                if ([button.titleLabel.text isEqualToString:@"wb"]) {
                    [button setFrame:CGRectMake(50, 192, 96, 96)];
                    [button setBackgroundImage:image forState:UIControlStateNormal];
                    [button setBackgroundImage:image forState:UIControlStateHighlighted];
                    [button setTitle:@"" forState:UIControlStateNormal && UIControlStateHighlighted];
                }
                if ([button.titleLabel.text isEqualToString:@"wn"]) {
                    [button setFrame:CGRectMake(146, 192, 96, 96)];
                    button.adjustsImageWhenHighlighted = NO;
                    [button setBackgroundImage:image forState:UIControlStateNormal];
                    [button setBackgroundImage:image forState:UIControlStateHighlighted];
                    [button setTitle:@"" forState:UIControlStateNormal && UIControlStateHighlighted];
                }
                
                if ([button.titleLabel.text isEqualToString:@"bq"]) {
                    [button setFrame:CGRectMake(50, 96, 96, 96)];
                    [button setBackgroundImage:image forState:UIControlStateNormal];
                    [button setBackgroundImage:image forState:UIControlStateHighlighted];
                    [button setTitle:@"" forState:UIControlStateNormal && UIControlStateHighlighted];
                }
                if ([button.titleLabel.text isEqualToString:@"br"]) {
                    [button setFrame:CGRectMake(146, 96, 96, 96)];
                    [button setBackgroundImage:image forState:UIControlStateNormal];
                    [button setBackgroundImage:image forState:UIControlStateHighlighted];
                    [button setTitle:@"" forState:UIControlStateNormal && UIControlStateHighlighted];
                }
                if ([button.titleLabel.text isEqualToString:@"bb"]) {
                    [button setFrame:CGRectMake(50, 192, 96, 96)];
                    [button setBackgroundImage:image forState:UIControlStateNormal];
                    [button setBackgroundImage:image forState:UIControlStateHighlighted];
                    [button setTitle:@"" forState:UIControlStateNormal && UIControlStateHighlighted];
                }
                if ([button.titleLabel.text isEqualToString:@"bn"]) {
                    [button setFrame:CGRectMake(146, 192, 96, 96)];
                    button.adjustsImageWhenHighlighted = NO;
                    [button setBackgroundImage:image forState:UIControlStateNormal];
                    [button setBackgroundImage:image forState:UIControlStateHighlighted];
                    [button setTitle:@"" forState:UIControlStateNormal && UIControlStateHighlighted];
                }
            }
        }
        return;
    }

}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 3) {
        return;
    }
    
    if (alertView.tag == -200) {  //Controllo se si è salvata la posizione
        NSString *comando = [alertView buttonTitleAtIndex:buttonIndex];
        if ([comando isEqualToString:NSLocalizedString(@"YES", nil)]) {
            if ([_pgnGame isEditMode]) {
                [_pgnGame setEditMode:NO];
            }
            [self resetPosition];
            if (revealViewController) {
                [_pgnGame setModified:NO];
                [revealViewController revealToggleAnimated:YES];
            }
            else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
    
    if (alertView.tag == -100) {  //Controllo se si è salvata la partita
        NSString *comando = [alertView buttonTitleAtIndex:buttonIndex];
        if ([comando isEqualToString:NSLocalizedString(@"YES", nil)]) {
            if ([_pgnGame isEditMode]) {
                [_pgnGame setEditMode:NO];
            }
            if (revealViewController) {
                [_pgnGame setModified:NO];
                [revealViewController revealToggleAnimated:YES];
            }
            else {
                [_pgnGame restoreMoves];
                [_pgnGame setModified:NO];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        return;
    }
    
    
    if (alertView.tag == 100) {
        if (buttonIndex > 0) {
            if (buttonIndex == 1) {
                //_insertMode = !_insertMode;
                [_pgnGame setEditMode:!_pgnGame.isEditMode];
                if ([_pgnGame isEditMode]) {
                    [boardView removeLeftAndRightSwipeGestureRecognizer];
                }
                else {
                    [boardView addLeftAndRightSwipeGestureRecognizer];
                }
            }
        }
    }
    
    if (alertView.tag == 5) { //Mossa non valida
        if (buttonIndex > 0) {
            prossimaMossa = [[prossimaMossa getNextMoves] objectAtIndex:buttonIndex - 1];
            [pgnParser parseMoveForward:prossimaMossa];
            
            if (![prossimaMossa isValid]) {
                NSString *message = [NSString stringWithFormat:@"La mossa %@ non è valida!", [prossimaMossa fullMove]];
                UIAlertView *noValidMoveAlertView = [[UIAlertView alloc] initWithTitle:@"No Valid Move" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                noValidMoveAlertView.tag = 7;
                [noValidMoveAlertView show];
                return;
            }
            
            
            [self showNextMove:prossimaMossa];
            [prossimaMossa setEvidenzia:YES];
            [self sendMoveToEngine:prossimaMossa];
            [_gameWebView aggiornaWebViewAvanti:prossimaMossa];
            //[self aggiornaWebView];
            
            [self getNalimovResult];
            
            //NSDictionary *userInfo = [NSDictionary dictionaryWithObject:prossimaMossa forKey:@"MOSSA"];
            //[[NSNotificationCenter defaultCenter]postNotificationName:@"EngineNotification" object:prossimaMossa userInfo:userInfo];
            
        }
        return;
    }
    
    if (alertView.tag == 7) {
        prossimaMossa = [prossimaMossa getPrevMove];
        //NSLog(@"Sono tornato alla mossa %@", prossimaMossa.fullMove);
        return;
    }
    
    if (alertView.tag == 8) {
        if (buttonIndex == 1) {
            [self resetGame];
        }
        return;
    }
    
    if (alertView.tag == 9) {
        if (buttonIndex == 1) {
            [self resetPosition];
        }
        return;
    }
    
    if (alertView.tag == 200) { //Gestione nuove varianti
        switch (buttonIndex) {
            case 0:
                [self gestisciCancelSuInserimentoVarianti];
                break;
            case 1:
                [self gestisciNuovaVarianteSuInserimentoVarianti];
                break;
            case 2:
                [self gestisciNuovaLineaPrincipaleSuInserimentoVarianti];
                break;
            case 3:
                [self gestisciSovrascriviSuInserimentoVarianti];
                break;
            default:
                break;
        }
        return;
    }
    
    
    //Gestione promozione del pedone senza cattura
    
    if (alertView.tag == 10) { //Promozione del pedone
        //NSLog(@"Scelta = %d", buttonIndex);
        //PieceButton *pb;
        if (buttonIndex == 0) {
            pedoneAppenaPromosso = [boardView findPieceBySquareTag:casaArrivo];
            [pedoneAppenaPromosso removeFromSuperview];
            [pedoneAppenaPromosso setSquareValue:casaPartenza];
            [boardView addSubview:pedoneAppenaPromosso];
            pedoneAppenaPromosso = nil;
            //[boardView addSubview:pezzoCatturato];
            //[boardView manageCaptureBack];
            return;
        }
        NSString *pz = [alertView buttonTitleAtIndex:buttonIndex];
        
        if (IS_IOS_7) {
            if ([pz isEqualToString:@"♕"]) {
                pz = @"wq";
            }
            else if ([pz isEqualToString:@"♖"]) {
                pz = @"wr";
            }
            else if ([pz isEqualToString:@"♗"]) {
                pz = @"wb";
            }
            else if ([pz isEqualToString:@"♘"]) {
                pz = @"wn";
            }
            
            if ([pz isEqualToString:@"♛"]) {
                pz = @"bq";
            }
            else if ([pz isEqualToString:@"♜"]) {
                pz = @"br";
            }
            else if ([pz isEqualToString:@"♝"]) {
                pz = @"bb";
            }
            else if ([pz isEqualToString:@"♞"]) {
                pz = @"bn";
            }
        }
        
        
        pedoneAppenaPromosso = [boardView findPieceBySquareTag:casaArrivo];
        [pedoneAppenaPromosso removeFromSuperview];
        PieceButton *pb;
        switch (buttonIndex) {
            case 1:
                pb = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pz];
                break;
            case 2:
                pb = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pz];
                break;
            case 3:
                pb = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pz];
                break;
            case 4:
                pb = [[[KnightButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pz];
                break;
        }
        [pb setDelegate:self];
        
        if (flipped) {
            [pb flip];
        }
        
        
        [pb setSquareValue:casaArrivo];
        [boardView addSubview:pb];
        [self gestisciMossaCompletaConPromozione:pz];
        [self getNalimovResult];
        return;
    }
    
    //Gestione promozione del pedone con cattura
    
    if (alertView.tag == 20) {
        PieceButton *pb;
        if (buttonIndex == 0) {
            pedoneAppenaPromosso = [boardView findPieceBySquareTag:casaArrivo];
            [pedoneAppenaPromosso removeFromSuperview];
            [pedoneAppenaPromosso setSquareValue:casaPartenza];
            [boardView addSubview:pedoneAppenaPromosso];
            [boardView manageCaptureBack];
            pedoneAppenaPromosso = nil;
            return;
        }
        NSString *pz = [alertView buttonTitleAtIndex:buttonIndex];
        
        if (IS_IOS_7) {
            if ([pz isEqualToString:@"♕"]) {
                pz = @"wq";
            }
            else if ([pz isEqualToString:@"♖"]) {
                pz = @"wr";
            }
            else if ([pz isEqualToString:@"♗"]) {
                pz = @"wb";
            }
            else if ([pz isEqualToString:@"♘"]) {
                pz = @"wn";
            }
            
            if ([pz isEqualToString:@"♛"]) {
                pz = @"bq";
            }
            else if ([pz isEqualToString:@"♜"]) {
                pz = @"br";
            }
            else if ([pz isEqualToString:@"♝"]) {
                pz = @"bb";
            }
            else if ([pz isEqualToString:@"♞"]) {
                pz = @"bn";
            }
        }

        pedoneAppenaPromosso = [boardView findPieceBySquareTag:casaArrivo];
        [pedoneAppenaPromosso removeFromSuperview];
        switch (buttonIndex) {
            case 1:
                pb = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pz];
                break;
            case 2:
                pb = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pz];
                break;
            case 3:
                pb = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pz];
                break;
            case 4:
                pb = [[[KnightButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pz];
                break;
        }
        [pb setDelegate:self];
        
        if (flipped) {
            [pb flip];
        }
        
        [pb setSquareValue:casaArrivo];
        [boardView addSubview:pb];
        [self gestisciMossaCompletaConPromozione:pz];
        [self getNalimovResult];
        return;
    }
    
    
    if (alertView.tag == 30) {
        NSString *scelta = [alertView buttonTitleAtIndex:buttonIndex];
        if ([scelta isEqualToString:NSLocalizedString(@"DELETE_VARIATION", nil)]) {
            //NSLog(@"Devo eliminare la variante che contiene la mossa %@  con livello variante %d", [prossimaMossa getMossaPerVarianti], [prossimaMossa livelloVariante]);
            [self eliminaVariante];
        }
        return;
    }
    
    if (alertView.tag == 40) {
        NSString *scelta = [alertView buttonTitleAtIndex:buttonIndex];
        //NSLog(@"%@ con index = %d", scelta, buttonIndex);
        if ([scelta isEqualToString:NSLocalizedString(@"PROMOTE_TO_MAIN_LINE", nil)]) {
            [self promoteToMainLine];
        }
        else if ([scelta isEqualToString:NSLocalizedString(@"PROMOTE_AS_FIRST", nil)]) {
            [self promoteAsFirst];
        }
        else if ([scelta isEqualToString:NSLocalizedString(@"PROMOTE_POSITION", nil)]) {
            [self promoteUp];
        }
        /*
        if (buttonIndex == 1) {
            [self promoteToMainLine];
        }
        else if (buttonIndex == 2) {
            [self promoteAsFirst];
        }
        else if (buttonIndex == 3) {
            [self promoteUp];
        }*/
        return;
    }
    
    if (alertView.tag == 50) {
        NSString *scelta = [alertView buttonTitleAtIndex:buttonIndex];
        //NSLog(@"%@ con index = %d", scelta, buttonIndex);
        if ([scelta isEqualToString:NSLocalizedString(@"TO_MAIN_LINE", nil)]) {
            [self promoteToMainLine];
        }
        /*
        if (buttonIndex == 1) {
            [self promoteToMainLine];
        }*/
        return;
    }
    
    if (alertView.tag == 60) {
        NSString *scelta = [alertView buttonTitleAtIndex:buttonIndex];
        NSLog(@"%@", scelta);
        if ([scelta isEqualToString:NSLocalizedString(@"PROMOTE_UP", nil)]) {
            [self promoteVariationSuperior];
        }
        /*
        if (buttonIndex == 1) {
            //[self promoteToMainLine];
        }
        else if (buttonIndex == 2) {
            [self promoteVariationSuperior];
        }*/
        return;
    }
    
    if (alertView.tag == 900) {
        NSString *scelta = [alertView buttonTitleAtIndex:buttonIndex];
        if ([scelta isEqualToString:NSLocalizedString(@"WRONG_GAME_NUMBERING_SAVE", nil)]) {
            [self salvaModificheInDatabase];
            return;
        }
    }
    
    
    if (alertView.tag == 500) {
        NSString *comando = [alertView buttonTitleAtIndex:buttonIndex];
        if ([comando isEqualToString:NSLocalizedString(@"YES", nil)]) {
            [settingManager setDragAndDrop:YES];
            return;
        }
    }
    
    if (alertView.tag == 600) {
        NSString *comando = [alertView buttonTitleAtIndex:buttonIndex];
        if ([comando isEqualToString:NSLocalizedString(@"YES", nil)]) {
            [settingManager setTapPieceToMove:YES];
            return;
        }
    }
    
    if (alertView.tag == 700) {
        NSString *comando = [alertView buttonTitleAtIndex:buttonIndex];
        if ([comando isEqualToString:NSLocalizedString(@"YES", nil)]) {
            [settingManager setTapDestination:YES];
            return;
        }
    }
    
    
    
    //Gestione ChessStudioLight in caso superamento numero mosse consentito
    if (alertView.tag == 1000) {
        [boardView clearHilightedAndControlledSquares];
        [boardView clearCanditatesPieces];
        [boardView clearArrivalSquare:candidateSquareTo];
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"CHESS_STUDIO_APP_STORE", nil)]];
        }
    }
    
}


- (void) willPresentActionSheet:(UIActionSheet *)actionSheet {
    if (actionSheet.tag == 1) {
        for (UIView *asView in actionSheet.subviews) {
            if ([asView isKindOfClass:[UILabel class]]) {
                [((UILabel *)asView) setFont:[UIFont boldSystemFontOfSize:20.f]];
            }
        }
    }
    if (actionSheet.tag == 2) {
        for (UIView *asView in actionSheet.subviews) {
            if ([asView isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)asView;
                if ([button.titleLabel.text isEqualToString:@"Test1"]) {
                    [button setFrame:CGRectMake(50, 96, 96, 96)];
                    [button setTitle:@"!" forState:UIControlStateNormal && UIControlStateHighlighted];
                    [button setTintColor:[UIColor yellowColor]];
                }
                if ([button.titleLabel.text isEqualToString:@"Test2"]) {
                    [button setFrame:CGRectMake(146, 96, 96, 96)];
                    [button setTitle:@"?" forState:UIControlStateNormal && UIControlStateHighlighted];
                }
            }
        }
    }
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex<0) {
        return;
    }
    NSString *comando;
    switch (actionSheet.tag) {
        case 0:
            comando = [actionSheet buttonTitleAtIndex:buttonIndex];
            if ([comando hasPrefix:NSLocalizedString(@"EDIT_GAME", nil)]) {
                //_insertMode = !_insertMode;
                [_pgnGame setEditMode:!_pgnGame.isEditMode];
                if ([_pgnGame isEditMode]) {
                    [boardView removeLeftAndRightSwipeGestureRecognizer];
                }
                else {
                    [boardView addLeftAndRightSwipeGestureRecognizer];
                }
            }
            else if ([comando hasPrefix:NSLocalizedString(@"ANNOTATION_MOVE", nil)]) {
                [self addAnnotationToMove];
                /*
                amtvc = [[AnnotationMoveTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                amtvc.delegate = self;
                [amtvc setMossaDaAnnotare:prossimaMossa];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:amtvc];
                if (IS_PAD) {
                    annotationMovePopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [annotationMovePopoverController presentPopoverFromBarButtonItem:[self.navigationItem.rightBarButtonItems objectAtIndex:0] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                    });
                }
                else {
                    [self.navigationController pushViewController:amtvc animated:YES];
                }
                */
            }
            else if ([comando hasPrefix:NSLocalizedString(@"TEXT_BEFORE", nil)]) {
                //TextCommentTableViewController *tctvc = [[TextCommentTableViewController alloc] initWithStyle:UITableViewStylePlain];
                //[tctvc setBoardModel:boardModel];
                //[tctvc setBoardView:boardView];
                //[self.navigationController pushViewController:tctvc animated:YES];
                
                //orientationPrimaDiInserireTesto = [[UIApplication sharedApplication] statusBarOrientation];
                
                TextCommentViewController *tcvc = [[TextCommentViewController alloc] init];
                tcvc.delegate = self;
                [tcvc setBoardModel:boardModel];
                //if (mossaEseguita) {
                //    [tcvc setPgnMove:mossaEseguita];
                //}
                //else {
                    [tcvc setPgnMove:prossimaMossa];
                //}
                [tcvc setTextBefore:YES];
                
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tcvc];
                navController.modalPresentationStyle = UIModalPresentationFullScreen;
                navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self presentModalViewController:navController animated:YES];
                    [self presentViewController:navController animated:YES completion:nil];
                });
                //[self presentModalViewController:navController animated:YES];
                return;
            }
            else if ([comando hasPrefix:NSLocalizedString(@"TEXT_AFTER", nil)]) {
                [self addTextAfterMove];
                /*
                TextCommentViewController *tcvc = [[TextCommentViewController alloc] init];
                tcvc.delegate = self;
                [tcvc setBoardModel:boardModel];
                [tcvc setPgnMove:prossimaMossa];
                [tcvc setTextBefore:NO];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tcvc];
                navController.modalPresentationStyle = UIModalPresentationFullScreen;
                navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:navController animated:YES completion:nil];
                });
                */
                return;
            }
            else if ([comando hasPrefix:NSLocalizedString(@"EDIT_INITIAL_TEXT", nil)]) {
                
                [self editInitialText];
                /*
                TextCommentViewController *tcvc = [[TextCommentViewController alloc] init];
                tcvc.delegate = self;
                [tcvc setBoardModel:boardModel];
                if ([pgnRootMove movesHasBeenInserted]) {
                    PGNMove *firstMoveAfterRoot = [pgnRootMove getFirstMoveAfterRoot];
                    [tcvc setPgnMove:firstMoveAfterRoot];
                    [tcvc setTextBefore:YES];
                }
                else {
                    [tcvc setPgnMove:pgnRootMove];
                    [tcvc setTextBefore:NO];
                }
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tcvc];
                navController.modalPresentationStyle = UIModalPresentationFullScreen;
                navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:navController animated:YES completion:nil];
                });
                */
                return;
            }
            else if ([comando hasPrefix:NSLocalizedString(@"ADD_INITIAL_TEXT", nil)]) {
                
                [self addInitialText];
                /*
                TextCommentViewController *tcvc = [[TextCommentViewController alloc] init];
                tcvc.delegate = self;
                [tcvc setBoardModel:boardModel];
                if ([pgnRootMove movesHasBeenInserted]) {
                    PGNMove *firstMoveAfterRoot = [pgnRootMove getFirstMoveAfterRoot];
                    [tcvc setPgnMove:firstMoveAfterRoot];
                    [tcvc setTextBefore:YES];
                }
                else {
                    [tcvc setPgnMove:pgnRootMove];
                    [tcvc setTextBefore:NO];
                }
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tcvc];
                navController.modalPresentationStyle = UIModalPresentationFullScreen;
                navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:navController animated:YES completion:nil];
                });
                */
                return;
            }
            else if ([comando hasPrefix:NSLocalizedString(@"INSERT_VARIANT_INSTEAD_OF", nil)]) {
                [self indietroButtonPressed:nil];
            }
            else if ([comando hasPrefix:NSLocalizedString(@"SETTINGS", nil)]) {
                UIStoryboard *sb = [UtilToView getStoryBoard];
                SettingsTableViewController *stvc = [sb instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
                stvc.delegate = self;
                UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:stvc];
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
            }
            else if ([comando isEqualToString:NSLocalizedString(@"MENU_EDIT_GAME_DATA", nil)]) {
                if ([_pgnGame userCanEditGameData]) {
                    //NSLog(@"ESEGUO SHOW GAME INFO");
                    [self showGameInfo];
                }
                else {
                    UIAlertView *noMovesAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ALERT_NO_MOVES_MESSAGE", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [noMovesAlertView show];
                }
            }
            else if ([comando isEqualToString:NSLocalizedString(@"MENU_EMAIL_GAME", nil)]) {
                [self manageGameByEmail];
            }
            else if ([comando isEqualToString:NSLocalizedString(@"EXIT_EDIT_MODE", nil)]  || [comando isEqualToString:NSLocalizedString(@"ENTER_EDIT_MODE", nil)]) {
                //_insertMode = !_insertMode;
                [_pgnGame setEditMode:!_pgnGame.isEditMode];
                if ([_pgnGame isEditMode]) {
                    [boardView removeLeftAndRightSwipeGestureRecognizer];
                }
                else {
                    [boardView addLeftAndRightSwipeGestureRecognizer];
                }
            }
            else if ([comando isEqualToString:NSLocalizedString(@"MENU_FLIP_BOARD", nil)]) {
                [self flipButtonPressed:nil];
            }
            else if ([comando isEqualToString:NSLocalizedString(@"DELETE_VARIATION", nil)]) {
                //NSString *titolo = [NSString stringWithFormat:@"%@    Livello:%d", [prossimaMossa getMossaPerVarianti], [prossimaMossa livelloVariante]];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DELETE_VARIATION", nil) message:NSLocalizedString(@"CONFIRM_DELETE_VARIATION", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:NSLocalizedString(@"DELETE_VARIATION", nil), nil];
                av.tag = 30;
                [av show];
            }
            else if ([comando isEqualToString:NSLocalizedString(@"PROMOTE_VARIATION", nil)]) {
                [self verificaPromoteVariante];
            }
            break;
        case 1:
            if (buttonIndex == 0) {
                //NSLog(@"Devo annullare la nuova variante e rispristinare la situazione iniziale");
                [boardView muoviPezzoIndietro:casaArrivo :casaPartenza :pezzoCatturato];
                pezzoCatturato = nil;
                //[boardModel printPosition];
                return;
            }
            if (buttonIndex == 1) {
                //NSLog(@"Devo inserire una nuova variante");
                return;
            }
            if (buttonIndex == 2) {
                //NSLog(@"Devo annullare la variate precedente e sovrascriverla");
                [boardModel stampaMosse];
                //[boardModel muoviPezzo:casaPartenza :casaArrivo];
                [boardModel sovrascriviMossa:casaPartenza :casaArrivo];
                //[boardModel printPosition];
                //NSLog(@"%@", boardModel.listaMosse);
                //[partita sovrascriviMossa:ultimaMossa];
                [boardModel stampaMosse];
                //NSLog(@"%@", boardModel.listaMosse);
                //[_gameWebView insertNewMoves:boardModel.listaMosse];
                [self evidenziaAChiToccaMuovere];
                return;
            }
            break;
        case 2:
            comando = [actionSheet buttonTitleAtIndex:buttonIndex];
            if (_pgnGame.isEditMode) {
                if ([comando isEqualToString:NSLocalizedString(@"MENU_NEW_GAME", nil)]) {
                    UIAlertView *newGameAlertView = [[UIAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                    [newGameAlertView setTitle:NSLocalizedString(@"NEW_GAME_TITLE", nil)];
                    [newGameAlertView setMessage:NSLocalizedString(@"NEW_GAME_MESSAGE", nil)];
                    [newGameAlertView setTag:8];
                    [newGameAlertView show];
                }
                else if ([comando isEqualToString:NSLocalizedString(@"MENU_EDIT_GAME_DATA", nil)]) {
                    if ([_pgnGame userCanEditGameData]) {
                        //NSLog(@"ESEGUO SHOW GAME INFO");
                        [self showGameInfo];
                    }
                    else {
                        UIAlertView *noMovesAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ALERT_NO_MOVES_MESSAGE", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [noMovesAlertView show];
                    }
                }
                else if ([comando isEqualToString:NSLocalizedString(@"MENU_EMAIL_GAME", nil)]) {
                    [self manageGameByEmail];
                }
                else if ([comando isEqualToString:NSLocalizedString(@"MENU_SAVE_GAME", nil)]) {
                    if ([_pgnGame userCanEditGameData]) {
                        //if ([_pgnGame sevenTagsAreAllEmpty]) {
                        //    [self showGameInfo];
                        //    return;
                        //}
                        [self salvaModificheInDatabase];
                        if ([_delegate respondsToSelector:@selector(updateGamePreviewTableViewController)]) {
                            [_delegate updateGamePreviewTableViewController];
                        }
                        if ([_delegate respondsToSelector:@selector(updateTBPgnFileTableViewController)]) {
                            [_delegate updateTBPgnFileTableViewController];
                        }
                        [_pgnGame setModified:NO];
                        [self setupNavigationTitle];
                    }
                    else {
                        UIAlertView *noMovesAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ALERT_NO_SAVE_MESSAGE", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [noMovesAlertView show];
                    }
                }
                else if ([comando isEqualToString:NSLocalizedString(@"MENU_SAVE_GAME_EXIT", nil)]) {
                    [self stopEngineController];
                    //if ([_pgnGame userCanEditGameData]) {
                        //if ([_pgnGame sevenTagsAreAllEmpty]) {
                        //    [self showGameInfo];
                        //    return;
                        //}
                        [self salvaModificheInDatabase];
                        if ([_delegate respondsToSelector:@selector(updateGamePreviewTableViewController)]) {
                            [_delegate updateGamePreviewTableViewController];
                        }
                        if ([_delegate respondsToSelector:@selector(updateTBPgnFileTableViewController)]) {
                            [_delegate updateTBPgnFileTableViewController];
                        }
                        [_pgnGame setModified:NO];
                    [_pgnGame setEditMode:NO];
                    if (revealViewController) {
                        [revealViewController revealToggleAnimated:YES];
                    }
                    else {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    //}
                }
                else if ([comando isEqualToString:NSLocalizedString(@"MENU_EXIT", nil)]) {
                    [self stopEngineController];
                    //Controllo per chiedere se si è sicuri di salvare la partita
                    if ([_pgnGame isModified]) {
                        UIAlertView *saveGameAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE_GAME", nil) message:NSLocalizedString(@"SAVE_GAME_ALERT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"YES", nil) otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
                        saveGameAlertView.tag = -100;
                        [saveGameAlertView show];
                        return;
                    }
                    
                    if ([_pgnGame isEditMode]) {
                        [_pgnGame setEditMode:NO];
                    }
                    
                    if (revealViewController) {
                        [revealViewController revealToggleAnimated:YES];
                    }
                    else {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
                else if ([comando isEqualToString:NSLocalizedString(@"EXIT_EDIT_MODE", nil)]) {
                    //_insertMode = !_insertMode;
                    [_pgnGame setEditMode:!_pgnGame.isEditMode];
                    if ([_pgnGame isEditMode]) {
                        [boardView removeLeftAndRightSwipeGestureRecognizer];
                    }
                    else {
                        [boardView addLeftAndRightSwipeGestureRecognizer];
                    }
                }
            }
            else {
                if ([comando isEqualToString:NSLocalizedString(@"MENU_EMAIL_GAME", nil)]) {
                    [self manageGameByEmail];
                }
                else if ([comando isEqualToString:NSLocalizedString(@"MENU_EXIT", nil)]) {
                    [self stopEngineController];
                    
                    //Controllo per chiedere se si è sicuri di salvare la partita
                    if ([_pgnGame isModified]) {
                        UIAlertView *saveGameAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE_GAME", nil) message:NSLocalizedString(@"SAVE_GAME_ALERT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"YES", nil) otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
                        saveGameAlertView.tag = -100;
                        [saveGameAlertView show];
                        return;
                    }
                    
                    if ([_pgnGame isEditMode]) {
                        [_pgnGame setEditMode:NO];
                    }
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else if ([comando isEqualToString:NSLocalizedString(@"ENTER_EDIT_MODE", nil)]) {
                     //_insertMode = !_insertMode;
                    [_pgnGame setEditMode:!_pgnGame.isEditMode];
                    if ([_pgnGame isEditMode]) {
                        [boardView removeLeftAndRightSwipeGestureRecognizer];
                    }
                    else {
                        [boardView addLeftAndRightSwipeGestureRecognizer];
                    }
                }
                else if ([comando isEqualToString:NSLocalizedString(@"NEXT_GAME", nil)]) {
                    [self loadNextGame];
                    
                    //[self performSelector:@selector(confrontaConFen) withObject:nil afterDelay:0.2];
                    
                    
                }
                else if ([comando isEqualToString:NSLocalizedString(@"PREVIOUS_GAME", nil)]) {
                    [self loadPreviousGame];
                }
            }
            break;
        case 3:
            comando = [actionSheet buttonTitleAtIndex:buttonIndex];
            if ([comando isEqualToString:NSLocalizedString(@"MENU_EXIT", nil)]) {
                if (revealViewController) {
                    [revealViewController revealToggleAnimated:YES];
                }
                else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
            else if ([comando isEqualToString:NSLocalizedString(@"MENU_POSITION_CLEAR", nil)]) {
                
                UIAlertView *newGameAlertView = [[UIAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"Ok", nil];
                [newGameAlertView setTitle:NSLocalizedString(@"NEW_POSITION_TITLE", nil)];
                [newGameAlertView setMessage:NSLocalizedString(@"NEW_POSITION_MESSAGE", nil)];
                [newGameAlertView setTag:9];
                [newGameAlertView show];
                
                
                
                //[boardModel clearBoard];
                //[boardView removeFromSuperview];
                //boardView = [[BoardView alloc] initWithSquareSizeAndSquareType:dimSquare :squares];
                //[self initBoardViewCoordinates];
                //[self.view addSubview:boardView];
                //boardView.delegate = self;
            }
            else if ([comando isEqualToString:NSLocalizedString(@"MENU_POSITION_SAVE", nil)]) {
                
                
                //UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 300, 300)];
                //[testView setBackgroundColor:[UIColor redColor]];
                //[self.view addSubview:testView];
                
                SideToMoveViewController *stmvc;
                UINavigationController *setupNavigationController;
                UIAlertView *positionKOAlertView;
                NSInteger checkupPosition = [boardModel checkSetupPosition];
                
                if (checkupPosition>=0 && checkupPosition<=5) {
                    [self evidenziaAChiToccaMuovere];
                    stmvc = [[SideToMoveViewController alloc] initWithSquaresAndPieceType:squares :pieceType];
                    stmvc.delegate = self;
                    [stmvc setBoardModel:boardModel];
                    setupNavigationController = [[UINavigationController alloc] initWithRootViewController:stmvc];
                    setupNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                    setupNavigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[self presentModalViewController:setupNavigationController animated:YES];
                        [self presentViewController:setupNavigationController animated:YES completion:nil];
                    });
                    //[self presentModalViewController:setupNavigationController animated:YES];
                }
                else if (checkupPosition == -1) {
                    positionKOAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETUP_POSITION_WRONG", nil) message:NSLocalizedString(@"SETUP_POSITION_ERRORS", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [positionKOAlertView show];
                }
                else if (checkupPosition == -2) {
                    positionKOAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETUP_POSITION_WRONG", nil) message:NSLocalizedString(@"SETUP_POSITION_KING_CHECK", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [positionKOAlertView show];
                }
                
                return;
            }
        default:
            break;
    }
}

- (void) manageGameByEmail {
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@""];
        
        //NSArray *toRecipients = [NSArray arrayWithObjects:NSLocalizedString(@"EMAIL", nil), nil];
        [mailer setToRecipients:[[SettingManager sharedSettingManager] getRecipients]];
        
        //UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
        //NSData *imageData = UIImagePNGRepresentation(myImage);
        //[mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"mobiletutsImage"];
  
        
        //[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        //[[self.view superview].superview.superview.layer renderInContext:UIGraphicsGetCurrentContext()];
        /*
        UIGraphicsBeginImageContext([UIScreen mainScreen].bounds.size);
        [boardView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(image);
        [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"game"];
        */
         //[imageData writeToFile:@"image1.jpeg" atomically:YES];
        
        NSString *emailBody = @"";
        if (_pgnGame) {
            emailBody = [_pgnGame getGameForMail];
            //emailBody = [_gameWebView getMosseWebPerEmail];
        }
        [mailer setMessageBody:emailBody isHTML:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self presentModalViewController:mailer animated:YES];
            [self presentViewController:mailer animated:YES completion:nil];
        });
        //[self presentModalViewController:mailer animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"NO_EMAIL_SETUP", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

- (void) showGameDetail {
    GameDetailTableViewController *gdtvc = [[GameDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [gdtvc setDelegate:self];
    [gdtvc setPgnGame:_pgnGame];
    [gdtvc setDatabaseName:_pgnFileDoc.pgnFileInfo.fileName];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:gdtvc];
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self presentModalViewController:navController animated:YES];
        [self presentViewController:navController animated:YES completion:nil];
    });
    //[self presentModalViewController:navController animated:YES];
}

- (void) showGameInfo {
    
    GameInfoTableViewController *gitvc = [[GameInfoTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [_pgnGame replaceOnlyTagAndTagValue:@"Result" :[resultMove fullMove]];
    gitvc.delegate = self;
    [gitvc setPgnFileDoc:_pgnFileDoc];
    [gitvc setPgnGame:_pgnGame];
    [gitvc setModificabile:YES];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:gitvc];
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    //navController.modalPresentationStyle = UIModalPresentationFormSheet;
    //navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self presentModalViewController:navController animated:YES];
        [self presentViewController:navController animated:YES completion:nil];
    });
    //[self presentModalViewController:navController animated:YES];
}

- (void) showGameInfoNoModify {
    GameInfoTableViewController *gitvc = [[GameInfoTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [_pgnGame replaceOnlyTagAndTagValue:@"Result" :[resultMove fullMove]];
    gitvc.delegate = self;
    [gitvc setPgnGame:_pgnGame];
    [gitvc setModificabile:NO];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:gitvc];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self presentModalViewController:navController animated:YES];
        [self presentViewController:navController animated:YES completion:nil];
    });
}

- (PieceButton *) creaPezzoPerPromozione:(NSString *)pezzo {
    PieceButton *pezzoPromosso = nil;
    
    if ([pezzo hasSuffix:@"q"]) {
        pezzoPromosso = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pezzo];
    }
    else if ([pezzo hasSuffix:@"n"]) {
        pezzoPromosso = [[[KnightButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pezzo];
    }
    else if ([pezzo hasSuffix:@"b"]) {
        pezzoPromosso = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pezzo];
    }
    else if ([pezzo hasSuffix:@"r"]) {
        pezzoPromosso = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pezzo];
    }
    return pezzoPromosso;
}


- (PieceButton *) rimettiInGiocoPezzoCatturatoInPromozione:(PGNMove *)move {
    PieceButton *pezzoMangiato = nil;
    
    float fx;
    float fy;
    
    unsigned int square = move.toSquare;
    
    fx = (float) ( square % 8 ) * dimSquare;
    fy = (dimSquare * 7) -floor( square / 8 ) * dimSquare;
    
    CGRect toSquareRect = CGRectMake(fx, fy, dimSquare, dimSquare);
    
    
    
    if ([move.captured hasSuffix:@"q"]) {
        //pezzoMangiato = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
        pezzoMangiato = [[[QueenButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
    }
    else if ([move.captured hasSuffix:@"n"]) {
        pezzoMangiato = [[[KnightButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
    }
    else if ([move.captured hasSuffix:@"b"]) {
        pezzoMangiato = [[[BishopButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
    }
    else if ([move.captured hasSuffix:@"r"]) {
        pezzoMangiato = [[[RookButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
    }
    pezzoMangiato.delegate = self;
    [pezzoMangiato setSquareValue:move.toSquare];
    if (flipped) {
        [pezzoMangiato flip];
    }
    return pezzoMangiato;
}

- (PieceButton *) rimettiInGiocoPezzoCatturato:(PGNMove *)move {
    
    PieceButton *pezzoMangiato = nil;
    
    float fx;
    float fy;
    
    unsigned int square = move.toSquare;
    
    fx = (float) ( square % 8 ) * dimSquare;
    fy = (dimSquare * 7) -floor( square / 8 ) * dimSquare;
    
    //NSLog(@"FX = %f   FY = %f", fx, fy);
    
    CGRect toSquareRect = CGRectMake(fx, fy, dimSquare, dimSquare);
    
    
    if (move.promoted) {
        if ([move.pezzoPromosso hasSuffix:@"q"]) {
            //pezzoMangiato = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:move.pezzoPromosso];
            
            pezzoMangiato = [[[QueenButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.pezzoPromosso];
            //pezzoMangiato = [[[QueenButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbolAndFlipped:pieceType:move.pezzoPromosso:flipped];
        }
        else if ([move.pezzoPromosso hasSuffix:@"n"]) {
            //pezzoMangiato = [[[KnightButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:move.pezzoPromosso];
            pezzoMangiato = [[[KnightButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.pezzoPromosso];
            //pezzoMangiato = [[[KnightButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbolAndFlipped:pieceType:move.pezzoPromosso:flipped];
        }
        else if ([move.pezzoPromosso hasSuffix:@"b"]) {
            //pezzoMangiato = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:move.pezzoPromosso];
            pezzoMangiato = [[[BishopButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.pezzoPromosso];
            //pezzoMangiato = [[[BishopButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbolAndFlipped:pieceType:move.pezzoPromosso:flipped];
        }
        else if ([move.pezzoPromosso hasSuffix:@"r"]) {
            //pezzoMangiato = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:move.pezzoPromosso];
            pezzoMangiato = [[[RookButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.pezzoPromosso];
            //pezzoMangiato = [[[RookButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbolAndFlipped:pieceType:move.pezzoPromosso:flipped];
        }
        pezzoMangiato.delegate = self;
        
        
        
        [UIView animateWithDuration:5.0 animations:^{
            [pezzoMangiato setSquareValue:[move toSquare]];
        }];
        
        
        
        
        //[pezzoMangiato setSquareValue:[move toSquare]];
        if (flipped) {
            [pezzoMangiato flip];
        }
        return pezzoMangiato;
    }
    
    if (move.enPassantCapture) {
        if ([move.color isEqualToString:@"w"]) {
            //pezzoMangiato = [[[PawnButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:BLACK_PAWN];
            pezzoMangiato = [[[PawnButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:BLACK_PAWN];
        }
        else {
            //pezzoMangiato = [[[PawnButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:WHITE_PAWN];
            pezzoMangiato = [[[PawnButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:WHITE_PAWN];
        }
        pezzoMangiato.delegate = self;
        [pezzoMangiato setSquareValue:move.enPassantPieceSquare];
        if (flipped) {
            [pezzoMangiato flip];
        }
        return pezzoMangiato;
    }
    
    
    if ([move.captured hasSuffix:@"q"]) {
        //pezzoMangiato = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
        pezzoMangiato = [[[QueenButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
        //pezzoMangiato = [[[QueenButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbolAndFlipped:pieceType:move.pezzoPromosso:flipped];
    }
    else if ([move.captured hasSuffix:@"n"]) {
        //pezzoMangiato = [[[KnightButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
        pezzoMangiato = [[[KnightButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
        //pezzoMangiato = [[[KnightButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbolAndFlipped:pieceType:move.pezzoPromosso:flipped];
    }
    else if ([move.captured hasSuffix:@"b"]) {
        //pezzoMangiato = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
        pezzoMangiato = [[[BishopButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
        //pezzoMangiato = [[[BishopButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbolAndFlipped:pieceType:move.pezzoPromosso:flipped];
    }
    else if ([move.captured hasSuffix:@"r"]) {
        //pezzoMangiato = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
        pezzoMangiato = [[[RookButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
        //pezzoMangiato = [[[RookButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbolAndFlipped:pieceType:move.pezzoPromosso:flipped];
    }
    else if ([move.captured hasSuffix:@"p"]) {
        //pezzoMangiato = [[[PawnButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
        pezzoMangiato = [[[PawnButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbol:pieceType:move.captured];
        //pezzoMangiato = [[[PawnButton alloc] initWithFrame:toSquareRect]initWithPieceTypeAndPieceSymbolAndFlipped:pieceType:move.captured:flipped];
    }
    pezzoMangiato.delegate = self;
    
    
    [pezzoMangiato setSquareValue:move.toSquare];
    
    if (flipped) {
        [pezzoMangiato flip];
    }
    
    return pezzoMangiato;
}



- (void) saveGameDetail:(NSDictionary *)tagValueDictionary {
    NSLog(@"Salvo i dettagli da BoardViewController");
    //for (NSString *tag in [tagValueDictionary allKeys]) {
    //    NSString *tagValue = [tagValueDictionary objectForKey:tag];
    //    NSLog(@"Tag = %@   Valore = %@", tag, tagValue);
    //    [_pgnGame setTag:tag andTagValue:tagValue];
    //}
    //NSString *risultato = [tagValueDictionary objectForKey:@"Result"];
    NSString *risultato = [_pgnGame getTagValueByTagName:@"Result"];
    
    
    //NSString *completeGame = [pgnGame getCompleteGame];
    
    
    //mossaEseguita = [[PGNMove alloc] initWithFullMove:risultato];
    //[mossaEseguita setEvidenzia:NO];
    
    resultMove = [[PGNMove alloc] initWithFullMove:risultato];
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[pgnParser parseMoveForward:mossaEseguita];
        [self aggiornaWebView];
    //});
    
    NSString *game = [pgnRootMove getGameWithNagsDopoAlberoAnticipato2];
    //NSLog(@"%@", game);
    [_pgnGame setMoves:game];
    //NSString *completeGame = [_pgnGame getCompleteGame];
    //NSLog(@"Complete Game = %@", completeGame);
    
    //self.navigationItem.title = [[[pgnGame getTagValueByTagName:@"White"] stringByAppendingString:@" - "] stringByAppendingString:[pgnGame getTagValueByTagName:@"Black"]];
    [self setupNavigationTitle];
    //Le seguenti istruzioni completano il salvataggio su file e devono essere effettuate dopo
    //[_pgnFileDoc.pgnFileInfo saveGame:completeGame];
    //[_delegate updateFileInfo];
    
    
    //NSLog(@"%@", [_pgnGame getGameForFile]);
    //NSMutableArray *allGames = [_pgnFileDoc.pgnFileInfo getAllGamesAndTags];
    //[allGames addObject:[_pgnGame getGameForFile]];
    //[_pgnFileDoc.pgnFileInfo saveAllGamesAndTags:allGames];
}


- (void) aggiornaTitoli {
    //NSLog(@"Eseguo aggiorna Titoli in BoardViewController");
    [self setupTitoli];
}

- (void) saveGameResult:(NSString *)risultato {
    NSString *risu = [_pgnGame getTagValueByTagName:@"Result"];
    //NSLog(@"Nuovo Risultato da salvare = %@", risu);
    resultMove = [[PGNMove alloc] initWithFullMove:risu];
    [self aggiornaWebView];
    NSString *game = [pgnRootMove getGameWithNagsDopoAlberoAnticipato2];
    [_pgnGame setMoves:game];
    [self setupNavigationTitle];
    //[_pgnGame setModified:NO];
}

- (void) salvaModificheInDatabase {
    
    //[self aggiornaWebView];
    
    [pgnRootMove addResultMove:resultMove];
    [pgnRootMove resetWebArray];
    [pgnRootMove visitaAlberoAnticipato2];
    [_pgnGame replaceOnlyTagAndTagValue:@"Result" :[resultMove fullMove]];
    
    //NSString *gameDopAlbAnt2 = [pgnRootMove getGameWithNagsDopoAlberoAnticipato2];
    
    //NSLog(@"STO SALVANDO %@", gameDopAlbAnt2);
    [_pgnGame setMoves:[pgnRootMove getGameWithNagsDopoAlberoAnticipato2]];
    //[_pgnGame setMoves:gameDopAlbAnt2];
    [pgnRootMove removeResultMove];
    
    
    //NSLog(@"STAMPO LE MOSSE:");
    //[_pgnGame stampaMosse];
    
    NSMutableArray *allGamesAndAllTags = [_pgnFileDoc.pgnFileInfo getAllGamesAndTags];
    
    //NSLog(@"Ho preso allGemasAnd All Tags");
    if ([_pgnGame indexInAllGamesAllTags] == -1) {
        //NSLog(@"Indice = -1");
        [allGamesAndAllTags addObject:[_pgnGame getGameForAllGamesAndAllTags]];
        [_pgnGame setIndexInAllGamesAllTags:[allGamesAndAllTags indexOfObject:[_pgnGame getGameForAllGamesAndAllTags]]];
    }
    else {
        //NSLog(@"Indice diverso da -1");
        [[_pgnFileDoc.pgnFileInfo getAllGamesAndTags] replaceObjectAtIndex:[_pgnGame indexInAllGamesAllTags] withObject:[_pgnGame getGameForAllGamesAndAllTags]];
    }
    //NSLog(@"Adesso salvo tutte le partite");
    [_pgnFileDoc.pgnFileInfo salvaTutteLePartite];
}

- (void) cancelButtonPressed {
    [annotationMovePopoverController dismissPopoverAnimated:YES];
    annotationMovePopoverController = nil;
    amtvc = nil;
}

- (void) saveButtonPressed {
    [annotationMovePopoverController dismissPopoverAnimated:YES];
    annotationMovePopoverController = nil;
    amtvc = nil;
    [_gameWebView aggiornaWebView];
}

- (void) updateWebView {
    //[_gameWebView aggiornaWebView];
    [self aggiornaWebView];
    
    
    //NSLog(@"updateWebView:   %@", [pgnRootMove getGameWithNagsDopoAlberoAnticipato2]);
    [_pgnGame setMoves:[pgnRootMove getGameWithNagsDopoAlberoAnticipato2]];
}

- (void) selection:(NSString *)pezzo {
    //NSLog(@"Pezzo selezionato %@", pezzo);
    selectedPieceForSetupPosition = pezzo;
}


- (void) selection:(SetupPositionView *)setupView :(NSString *)pezzo {
    //NSLog(@"Pezzo selezionato %@", pezzo);
    selectedPieceForSetupPosition = pezzo;
    //[setupView removeFromSuperview];
    //PieceButton *pb = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pezzo];
    //pb.delegate = self;
    //[pb setSquareValue:0];
    //[boardView addSubview:pb];
}

- (PieceButton *) setupPiece:(NSString *)piece {
    PieceButton *pb = nil;
    if (![piece hasSuffix:@"m"]) {
        if ([piece hasSuffix:@"r"]) {
            pb = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:selectedPieceForSetupPosition];
        }
        else {
            if ([piece hasSuffix:@"k"]) {
                pb = [[[KingButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:selectedPieceForSetupPosition];
            }
            else {
                if ([piece hasSuffix:@"q"]) {
                    pb = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:selectedPieceForSetupPosition];
                }
                else {
                    if ([piece hasSuffix:@"n"]) {
                        pb = [[[KnightButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:selectedPieceForSetupPosition];
                    }
                    else {
                        if ([piece hasSuffix:@"b"]) {
                            pb = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:selectedPieceForSetupPosition];
                        }
                        else {
                            if ([piece hasSuffix:@"p"]) {
                                pb = [[[PawnButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:selectedPieceForSetupPosition];
                            }
                        }
                    }
                }
            }
        }
    }
    return pb;
}


- (void) aggiornaColore {
    [self evidenziaAChiToccaMuovere];
}


- (void) savePositionSetup2 {
    _setupPosition = NO;
    
    BOOL toccaMuovereAlBianco = [boardModel whiteHasToMove];
    
    startFenPosition = [boardModel calcFenNotationWithNumberFirstMove];
    //NSLog(@"SAVE POSITION SETUP 2 - FEN: %@", startFenPosition);
    
    /*
    NSString *address = @"http://www.k4it.de/egtb/fetch.php?obid=et30.8461838087532669&reqid=req0.5&hook=null&action=egtb&fen=8/3k4/8/8/8/8/8/3K4%20egtb&fen=";
    
    NSString *fenfinale = [startFenPosition stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *addressFinale = [address stringByAppendingString:fenfinale];
    
    NSURL *url = [NSURL URLWithString:addressFinale];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if ([responseCode statusCode] != 200) {
        NSLog(@" ERROR = %ld", (long)[responseCode statusCode]);
        NSLog(@"%@", error.description);
    }
    else {
        NSString *risu = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", risu);
    }*/
    
    
    
    _pgnGame = [[PGNGame alloc] initWithFen:startFenPosition];
    [_pgnGame setEditMode:YES];
    [boardModel setStartFromFen:YES];
    [boardModel setFenNotation:[_pgnGame getTagValueByTagName:@"FEN"]];
    
    [self trovaECOConFen:startFenPosition];
    [self trovaBookConFen:startFenPosition];
    
    
    if (!toccaMuovereAlBianco) {
        [_pgnGame setMoves:@"1. XXX *"];
        _gameToView = [[NSMutableString alloc] initWithString:[_pgnGame moves]];
        [self parseGame];
        [boardModel setWhiteHasToMove:toccaMuovereAlBianco];
        [self evidenziaAChiToccaMuovere];
        [self aggiornaWebView];
        prossimaMossa = [[pgnRootMove getNextMoves] objectAtIndex:0];
        [prossimaMossa setFen:startFenPosition];
        
        //NSLog(@"FEN POSITION = %@", [prossimaMossa fenForBookMoves]);
    }
    else {
        //[_pgnGame setMoves:@""];
        _gameToView = [[NSMutableString alloc] initWithString:[_pgnGame moves]];
        //NSLog(@"POSITION SETUP GAME = %@", _gameToView);
        [self parseGame];
        resultMove = [[PGNMove alloc] initWithFullMove:@"*"];
        [self aggiornaWebView];
        [prossimaMossa setFen:startFenPosition];
        //pgnParser = [[PGNParser alloc] init];
        //pgnRootMove = [[PGNMove alloc] initWithFullMove:nil];
        //prossimaMossa = pgnRootMove;
        //stopNextMove = YES;
        //stopPrevMove = YES;
        //resultMove = [[PGNMove alloc] initWithFullMove:@"*"];
        //[pgnRootMove setFen:[boardModel fenNotation]];
        //_gameToView = [[NSMutableString alloc] initWithString:[_pgnGame moves]];
        //[self aggiornaWebView];
        //NSLog(@"FEN POSITION = %@", [resultMove fenForBookMoves]);
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    if (IsChessStudioLight) {
        startFenPosition = nil;
    }
    
    [UIView animateWithDuration:1.1 delay:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        if (IS_PAD) {
            if (IS_PORTRAIT) {
                setupPositionView.alpha = 0.0;
                //setupPositionView.transform = CGAffineTransformMakeTranslation(setupPositionView.frame.origin.x, 480.0f + (setupPositionView.frame.size.height/2));
            }
            else {
                setupPositionView.alpha = 0.0;
                //setupPositionView.center = CGPointMake(setupPositionView.center.x + 400, setupPositionView.center.y);
            }
        }
        else if (IS_IPHONE_6P) {
            if (IS_PORTRAIT) {
                //setupPositionView.center = CGPointMake(setupPositionView.center.x, setupPositionView.center.y + 184);
                setupPositionView.alpha = 0.0;
            }
            else {
                //setupPositionView.center = CGPointMake(setupPositionView.center.x + 400, setupPositionView.center.y);
                setupPositionView.alpha = 0.0;
            }
        }
        else {
            setupPositionView.alpha = 0.0;
            //setupPositionView.center = CGPointMake(setupPositionView.center.x, setupPositionView.center.y + 184);
            //setupPositionView.transform = CGAffineTransformMakeTranslation(setupPositionView.frame.origin.x, 240.0f + (setupPositionView.frame.size.height/2));
        }
    } completion:^(BOOL finished) {
        [setupPositionView removeFromSuperview];
        setupPositionView = nil;
        //[self setupGameWebViewAndEngineView];
        self.navigationController.toolbarHidden = NO;
        [self gestioneInterfacciaGrafica];
    }];
}


- (void) savePositionSetup {
    
    [self savePositionSetup2];
    return;

    BOOL toccaMuovereAlBianco = [boardModel whiteHasToMove];
    
    startFenPosition = [boardModel fenNotation];
    //NSLog(@"FEN POSITION SETUP = %@", startFenPosition);
    _pgnGame = [[PGNGame alloc] initWithFen:startFenPosition];
    [_pgnGame setEditMode:YES];
    [boardModel setStartFromFen:YES];
    [boardModel setFenNotation:[_pgnGame getTagValueByTagName:@"FEN"]];
    
    [self trovaECOConFen:startFenPosition];
    [self trovaBookConFen:startFenPosition];
    
    if (!toccaMuovereAlBianco) {
        [_pgnGame setMoves:@"1. XXX *"];
        _gameToView = [[NSMutableString alloc] initWithString:[_pgnGame moves]];
        [self parseGame];
        [boardModel setWhiteHasToMove:toccaMuovereAlBianco];
        [self evidenziaAChiToccaMuovere];
        [self aggiornaWebView];
        prossimaMossa = [[pgnRootMove getNextMoves] objectAtIndex:0];
        [prossimaMossa setFen:startFenPosition];
        
        //NSLog(@"FEN POSITION = %@", [prossimaMossa fenForBookMoves]);
    }
    else {
        //[_pgnGame setMoves:@""];
        _gameToView = [[NSMutableString alloc] initWithString:[_pgnGame moves]];
        //NSLog(@"POSITION SETUP GAME = %@", _gameToView);
        [self parseGame];
        resultMove = [[PGNMove alloc] initWithFullMove:@"*"];
        [self aggiornaWebView];
        [prossimaMossa setFen:startFenPosition];
        //pgnParser = [[PGNParser alloc] init];
        //pgnRootMove = [[PGNMove alloc] initWithFullMove:nil];
        //prossimaMossa = pgnRootMove;
        //stopNextMove = YES;
        //stopPrevMove = YES;
        //resultMove = [[PGNMove alloc] initWithFullMove:@"*"];
        //[pgnRootMove setFen:[boardModel fenNotation]];
        //_gameToView = [[NSMutableString alloc] initWithString:[_pgnGame moves]];
        //[self aggiornaWebView];
        //NSLog(@"FEN POSITION = %@", [resultMove fenForBookMoves]);
    }
    
    
    

    _setupPosition = NO;
    
    if (IsChessStudioLight) {
        startFenPosition = nil;
    }

    [UIView animateWithDuration:1.1 delay:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        if (IS_PAD) {
            if (IS_PORTRAIT) {
                setupPositionView.alpha = 0.0;
                //setupPositionView.transform = CGAffineTransformMakeTranslation(setupPositionView.frame.origin.x, 480.0f + (setupPositionView.frame.size.height/2));
            }
            else {
                setupPositionView.alpha = 0.0;
                //setupPositionView.center = CGPointMake(setupPositionView.center.x + 400, setupPositionView.center.y);
            }
        }
        else if (IS_IPHONE_6P) {
            if (IS_PORTRAIT) {
                //setupPositionView.center = CGPointMake(setupPositionView.center.x, setupPositionView.center.y + 184);
                setupPositionView.alpha = 0.0;
            }
            else {
                //setupPositionView.center = CGPointMake(setupPositionView.center.x + 400, setupPositionView.center.y);
                setupPositionView.alpha = 0.0;
            }
        }
        else {
            setupPositionView.alpha = 0.0;
            //setupPositionView.center = CGPointMake(setupPositionView.center.x, setupPositionView.center.y + 184);
            //setupPositionView.transform = CGAffineTransformMakeTranslation(setupPositionView.frame.origin.x, 240.0f + (setupPositionView.frame.size.height/2));
        }
    } completion:^(BOOL finished) {
        [setupPositionView removeFromSuperview];
        setupPositionView = nil;
        //[self setupGameWebViewAndEngineView];
        self.navigationController.toolbarHidden = NO;
        [self gestioneInterfacciaGrafica];
    }];
}

- (void) aggiornaCommento {
    [self aggiornaWebView];
    [_pgnGame setMoves:[pgnRootMove getGameWithNagsDopoAlberoAnticipato2]];
    //NSLog(@"Aggiorna Commento = %@", [pgnRootMove getGameWithNagsDopoAlberoAnticipato2]);
}


- (void) aggiornaOrientamento {
    if (IS_PORTRAIT) {
        if (IS_PAD) {
            [self gestisciPadCheRuotaToPortrait];
        }
        else {
            [self gestisciPhoneCheRuotaToPortrait];
        }
    }
    else {
        if (IS_PAD) {
            [self gestisciPadCheRuotaToLandscape];
        }
        else {
            [self gestisciPhoneCheRuotaToLandscape];
        }
    }
    
    [self setupInitialPosition];
    [self initBoardViewCoordinates];
}


- (void) aggiornaCommentoFromTextPopover {
    [self aggiornaWebView];
    [_pgnGame setMoves:[pgnRootMove getGameWithNagsDopoAlberoAnticipato2]];
}


- (void) inviaPV:(NSString *)pv {
    if ([[Options sharedOptions] showAnalysis]) {
        if ([[Options sharedOptions] figurineNotation]) {
            unichar c;
            NSString *s;
            NSString *pc[6] = { @"K", @"Q", @"R", @"B", @"N" };
            int i;
            for (i = 0, c = 0x2654; i < 5; i++, c++) {
                s = [NSString stringWithCharacters: &c length: 1];
                pv = [pv stringByReplacingOccurrencesOfString: pc[i] withString: s];
            }
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [analysisView setText: [NSString stringWithFormat: @" %@", pv]];
        }
        else {
            [analysisView setText: pv];
        }
    }
    else {
        [analysisView setText: @""];
    }
}

- (void) inviaSearchStarts:(NSString *)searchStats {
    if ([[Options sharedOptions] showAnalysis]) {
        if ([[Options sharedOptions] figurineNotation]) {
            unichar c;
            NSString *s;
            NSString *pc[6] = { @"K", @"Q", @"R", @"B", @"N" };
            int i;
            for (i = 0, c = 0x2654; i < 5; i++, c++) {
                s = [NSString stringWithCharacters: &c length: 1];
                searchStats =
                [searchStats stringByReplacingOccurrencesOfString: pc[i]
                                                       withString: s
                                                          options: 0
                                                            range: NSMakeRange(0, 20)];
            }
        }
        [searchStatsView setText: searchStats];
    }
    else
        [searchStatsView setText: @""];
}

- (void) ilMotoreHaMosso:(NSArray *)mosse {
    //NSLog(@"Eseguo il metodo ilMotoreHaMosso");
    //[self performSelectorOnMainThread: @selector(engineMadeMove:) withObject:mosse waitUntilDone: NO];
}

- (void) engineMadeMove:(NSArray *)mosse {
    //NSLog(@"Eseguo engineMadeMove");
    //for (int i=0; i<mosse.count; i++) {
    //    NSObject *obj = [mosse objectAtIndex:i];
    //    NSLog(@"MOSSA: %@", obj);
    //}
}


-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self.view addSubview:banner];
    [self.view layoutIfNeeded];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [banner removeFromSuperview];
    [self.view layoutIfNeeded];
}


- (void) doneButtonPressed {
    if (controllerPopoverController.isPopoverVisible) {
        [controllerPopoverController dismissPopoverAnimated:YES];
        controllerPopoverController = nil;
        return;
    }
}

- (NSInteger) loadNextGameFromDatabase {
    [self loadNextGame];
    if (_pgnGame) {
        return [_pgnGame indexInAllGamesAllTags];
    }
    return -1;
}

- (NSInteger) loadPreviousGameFromDatabase {
    [self loadPreviousGame];
    if (_pgnGame) {
        return[_pgnGame indexInAllGamesAllTags];
    }
    return-1;
}

- (void) managePawnStructure {
    [boardView managePawnStructure];
}

- (void) startForwardAnimation {
    
    if (controllerPopoverController.isPopoverVisible) {
        [controllerPopoverController dismissPopoverAnimated:YES];
        controllerPopoverController = nil;
    }
    
    if (IS_PAD) {
        [self createGameReplayToolbar];
        [self replayGameForward:nil finished:NO context:0];
    }
    else if (IS_IPHONE_6P && !IS_PORTRAIT) {
        [self createGameReplayToolbar];
        [self replayGameForward:nil finished:NO context:0];
    }
    else {
        [self createGameReplayToolbar];
    }
}

- (void) startBackAnimation{
    if (controllerPopoverController.isPopoverVisible) {
        [controllerPopoverController dismissPopoverAnimated:YES];
        controllerPopoverController = nil;
    }
    
    if (IS_PAD) {
        [self createGameReplayToolbar];
        [self replayGameBack:nil finished:NO context:0];
    }
    else if (IS_IPHONE_6P && !IS_PORTRAIT) {
        [self createGameReplayToolbar];
        [self replayGameBack:nil finished:NO context:0];
    }
    else {
        [self createGameReplayToolbar];
    }
}

- (void) replayGameForward:(NSString *)animationId finished:(BOOL)finished context:(void *)context {
    
    if ([gameSetting stopped]) {
        return;
    }
    
    if (stopNextMove || ![gameSetting forwardAnimated]) {
        [gameSetting setForwardAnimated:NO];
        stopPrevMove = NO;
        [self removeGameReplayToolbar];
        return;
    }
    if (prossimaMossa) {
        
        //NSLog(@"PROSSIMA MOSSA = %@             %@", prossimaMossa.fen, prossimaMossa.fullMove);
        NSArray *varianti = [prossimaMossa getNextMoves];
        if (varianti) {
            prossimaMossa = [[prossimaMossa getNextMoves] objectAtIndex:0];
            [pgnParser parseMoveForward:prossimaMossa];
            if ([prossimaMossa endGameMarked]) {
                stopNextMove = YES;
                prossimaMossa = [prossimaMossa getPrevMove];
                [gameSetting setForwardAnimated:NO];
                [self removeGameReplayToolbar];
                stopPrevMove = NO;
                return;
            }
        }
        else {
            stopNextMove = YES;
            [gameSetting setForwardAnimated:NO];
            [self removeGameReplayToolbar];
            stopPrevMove = NO;
            return;
        }
    }
    [prossimaMossa setEvidenzia:YES];
        //[self showNextMove:prossimaMossa];
        
    if (prossimaMossa.promoted) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations: nil context: context];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector:@selector(replayGameForward:finished:context:)];
        [UIView setAnimationCurve: UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:[gameSetting forwardAnimationDuration]];
        
        
        PieceButton *promotedPieceButton = [self rimettiInGiocoPezzoCatturato:prossimaMossa];
        PieceButton *capturedDurinPromotionPieceButton = nil;
        if (prossimaMossa.capture) {
            capturedDurinPromotionPieceButton = [self rimettiInGiocoPezzoCatturato:prossimaMossa];
        }
        
        [boardView muoviPezzoAvantiEPromuovi:prossimaMossa :promotedPieceButton];
        [boardModel mossaAvantiConPromozione:prossimaMossa];
    }
    else if (prossimaMossa.enPassantCapture) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations: nil context: context];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector:@selector(replayGameForward:finished:context:)];
        [UIView setAnimationCurve: UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:[gameSetting forwardAnimationDuration]];
        
        [boardView muoviPezzoAvanti:prossimaMossa];
        [boardModel mossaAvantiEnPassant:prossimaMossa.fromSquare :prossimaMossa.toSquare :prossimaMossa.enPassantPieceSquare];
    }
    else {
        //[boardView muoviPezzoAvanti:prossimaMossa];
            
        PieceButton *pezzoDaMuovere = [boardView findPieceBySquareTag:prossimaMossa.fromSquare];
        PieceButton *pezzoDaCatturare = nil;
        if (prossimaMossa.capture) {
            pezzoDaCatturare = [boardView findPieceBySquareTag:prossimaMossa.toSquare];
        }
            
            
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations: nil context: context];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector:@selector(replayGameForward:finished:context:)];
        [UIView setAnimationCurve: UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:[gameSetting forwardAnimationDuration]];
        [pezzoDaMuovere setSquareValue:prossimaMossa.toSquare];
                
        if (pezzoDaCatturare) {
            if (flipped) {
                [pezzoDaCatturare flip];
            }
            [pezzoDaCatturare removeFromSuperview];
        }
                
        if ([pezzoDaMuovere.titleLabel.text hasSuffix:@"k"] && (prossimaMossa.fromSquare==4) && (prossimaMossa.toSquare==6)) {
            PieceButton *rook = [boardView findPieceBySquareTag:7];
            if (rook) {
                [rook setSquareValue:5];
                //return;
            }
        }
        if ([pezzoDaMuovere.titleLabel.text hasSuffix:@"k"] && (prossimaMossa.fromSquare==4) && (prossimaMossa.toSquare==2)) {
            PieceButton *rook = [boardView findPieceBySquareTag:0];
            if (rook) {
                [rook setSquareValue:3];
                //return;
            }
        }
        if ([pezzoDaMuovere.titleLabel.text hasSuffix:@"k"] && (prossimaMossa.fromSquare==60) && (prossimaMossa.toSquare==62)) {
            PieceButton *rook = [boardView findPieceBySquareTag:63];
            if (rook) {
                [rook setSquareValue:61];
                //return;
            }
        }
        if ([pezzoDaMuovere.titleLabel.text hasSuffix:@"k"] && (prossimaMossa.fromSquare==60) && (prossimaMossa.toSquare==58)) {
            PieceButton *rook = [boardView findPieceBySquareTag:56];
            if (rook) {
                [rook setSquareValue:59];
            }
        }
        //} completion:nil];
            
        [boardModel mossaAvanti:prossimaMossa.fromSquare :prossimaMossa.toSquare];
    }
    [self evidenziaAChiToccaMuovere];
        
    [_gameWebView aggiornaWebViewAvanti:prossimaMossa];
        
    //[boardModel printPosition];
    [UIView commitAnimations];
}

- (void) replayGameBack:(NSString *)animationId finished:(BOOL)finished context:(void *)context {
    
    if ([gameSetting stopped]) {
        return;
    }
    
    if (stopPrevMove || ![gameSetting backAnimated]) {
        [gameSetting setBackAnimated:NO];
        stopNextMove = NO;
        //NSLog(@"IL REPLAY FINISCE IN 1");
        [self removeGameReplayToolbar];
        return;
    }
    
    if ([prossimaMossa isFirstMoveAfterRootWithDots]) {
        [gameSetting setBackAnimated:NO];
        stopPrevMove = YES;
        stopNextMove = NO;
        [self removeGameReplayToolbar];
        return;
    }
    
    if ([prossimaMossa isFirstMoveAfterRoot]) {
        [gameSetting setBackAnimated:NO];
        //stopPrevMove = YES;
        [self indietroButtonPressed:nil];
        //NSLog(@"IL REPLAY FINISCE IN 2");
        [self removeGameReplayToolbar];
        return;
    }
    
    context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations: nil context: context];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector:@selector(replayGameBack:finished:context:)];
    [UIView setAnimationCurve: UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:[gameSetting backAnimationDuration]];
    
    
    [self indietroButtonPressed:nil];
    
    [self evidenziaAChiToccaMuovere];
    
    [_gameWebView aggiornaWebViewAvanti:prossimaMossa];
    
    [UIView commitAnimations];
    
}



- (void) createGameReplayToolbar {
    //gameReplayToolbar = [[UIToolbar alloc] init];
    
    //if (IS_PAD) {
        //if (IS_PORTRAIT) {
            //gameReplayToolbar.frame = CGRectMake(0, 960-44, self.view.frame.size.width, 44);
        //}
        //else {
            //gameReplayToolbar.frame = CGRectMake(0, 704-44, self.view.frame.size.width, 44);
        //}
    //}
    //else if (IS_IPHONE_5) {
        //if (IS_PORTRAIT) {
            //gameReplayToolbar.frame = CGRectMake(0, 504-44, self.view.frame.size.width, 44);
        //}
        //else {
            //gameReplayToolbar.frame = CGRectMake(0, 276-52, self.view.frame.size.width, 52);
        //}
    //}
    //else if (IS_PHONE) {
        //if (IS_PORTRAIT) {
            //gameReplayToolbar.frame = CGRectMake(0, 416-44, self.view.frame.size.width, 44);
        //}
        //else {
            //gameReplayToolbar.frame = CGRectMake(0, 276-52, self.view.frame.size.width, 52);
        //}
    //}
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopAnimation)];
    [items addObject:stop];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flex];
    UIBarButtonItem *primo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(decelera)];
    [items addObject:primo];
    flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flex];
    UIBarButtonItem *pause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pauseAnimation)];
    [items addObject:pause];
    flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flex];
    UIBarButtonItem *secondo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(accelera)];
    [items addObject:secondo];
    flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flex];
    UIBarButtonItem *terzo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startAnimation)];
    [items addObject:terzo];
    
    //[gameReplayToolbar setItems:items animated:NO];
    //[self.view addSubview:gameReplayToolbar];
    
    
    //[self setToolbarItems:items];
    
    
    [self setToolbarItems:items];
    
}

- (void) removeGameReplayToolbar {
    //if (gameReplayToolbar) {
        //[gameReplayToolbar removeFromSuperview];
        //gameReplayToolbar = nil;
    //}
    
    [self setToolbarItems:defaultToolbarItems];
}

- (void) stopAnimation {
    [gameSetting resetAnimation];
    [self removeGameReplayToolbar];
}

- (void) pauseAnimation {
    [gameSetting setStopped:YES];
}

- (void) startAnimation {
    [gameSetting setStopped:NO];
    if ([gameSetting backAnimated]) {
        [self replayGameBack:nil finished:NO context:0];
    }
    else {
        [self replayGameForward:nil finished:NO context:0];
    }
}

- (void) accelera {
    [gameSetting accelera];
}

- (void) decelera {
    [gameSetting decelera];
}

//- (void) gestisciRotazioneReplayToolbar {
    //if (gameReplayToolbar) {
        //if (IS_PAD) {
            //if (IS_LANDSCAPE) {
                //gameReplayToolbar.frame = CGRectMake(0, 704-44, self.view.frame.size.width, 44);
            //}
            //else {
                //gameReplayToolbar.frame = CGRectMake(0, 960-44, self.view.frame.size.width, 44);
            //}
        //}
        //else if (IS_IPHONE_5) {
            //if (IS_LANDSCAPE) {
                //gameReplayToolbar.frame = CGRectMake(0, 276-52, self.view.frame.size.width, 52);
            //}
            //else {
                //gameReplayToolbar.frame = CGRectMake(0, 504-44, self.view.frame.size.width, 44);
            //}
        //}
        //else if (IS_PHONE) {
            //if (IS_LANDSCAPE) {
                //gameReplayToolbar.frame = CGRectMake(0, 276-52, self.view.frame.size.width, 52);
            //}
            //else {
                //gameReplayToolbar.frame = CGRectMake(0, 416-44, self.view.frame.size.width, 44);
            //}
        //}
    //}
//}




- (void) eliminaVariante {
    NSInteger numeroVarianti = 0;
    PGNMove *mossaPartenza = prossimaMossa;
    do {
        prossimaMossa = [prossimaMossa getPrevMove];
        //NSLog(@"MOSSA = %@", prossimaMossa.getCompleteMove);
        //mossaPartenza = prossimaMossa;
        if (prossimaMossa.getNextMoves) {
            //NSLog(@"Numero varianti = %d", [[prossimaMossa getNextMoves] count]);
            numeroVarianti = [[prossimaMossa getNextMoves] count];
            if (numeroVarianti == 1) {
                mossaPartenza = prossimaMossa;
            }
        }
    } while (numeroVarianti == 1);
    
    //NSLog(@"MOSSA = %@", prossimaMossa.getCompleteMove);
    //NSLog(@"NUMERO VARIANTI = %d", [[prossimaMossa getNextMoves] count]);
    //NSLog(@"MOSSA PARTENZA = %@", mossaPartenza);
    NSUInteger linea = [[prossimaMossa getNextMoves] indexOfObject:mossaPartenza];
    //NSLog(@"LINEA DA ELIMINARE = %d", linea);
    
    //for (int i=0; i<[[prossimaMossa getNextMoves] count]; i++) {
        //PGNMove *m = [[prossimaMossa getNextMoves] objectAtIndex:i];
        //NSLog(@"%@\n", m);
    //}
    
    [prossimaMossa deleteVariation:linea];
    
    
    [self aggiornaWebView];
    
    [boardModel setFenNotation:[prossimaMossa fen]];
    [pgnParser setFenPosition:[prossimaMossa fen]];
    [self clearBoardView];
    [self setupInitialPosition];
    [prossimaMossa setEvidenzia:YES];
    [self sendMoveToEngine:prossimaMossa];
    [_gameWebView aggiornaWebViewAvanti:prossimaMossa];
    if ([prossimaMossa getNextMoves]) {
        stopNextMove = NO;
    }
    else {
        stopNextMove = YES;
    }
    if (prossimaMossa.plyCount == 0) {
        stopPrevMove = YES;
    }
    else {
        stopPrevMove = NO;
    }
    [self evidenziaAChiToccaMuovere];
}

- (void) verificaPromoteVariante {
    NSInteger numeroVarianti = 0;
    NSInteger livelloVariante = [prossimaMossa livelloVariante];
    tempProssimaMossa = prossimaMossa;
    do {
        prossimaMossa = [prossimaMossa getPrevMove];
        //NSLog(@"MOSSA = %@", prossimaMossa.getCompleteMove);
        //mossaPartenza = prossimaMossa;
        if (prossimaMossa.getNextMoves) {
            //NSLog(@"Numero varianti = %d", [[prossimaMossa getNextMoves] count]);
            numeroVarianti = [[prossimaMossa getNextMoves] count];
            if (numeroVarianti == 1) {
                tempProssimaMossa = prossimaMossa;
            }
        }
    } while (numeroVarianti == 1);
    
    //NSLog(@"MOSSA = %@", prossimaMossa.getCompleteMove);
    //NSLog(@"NUMERO VARIANTI = %d", [[prossimaMossa getNextMoves] count]);
    //NSLog(@"LIVELLO VARIANTE = %d", livelloVariante);
    //NSLog(@"MOSSA PARTENZA = %@", tempProssimaMossa);
    lineaDaPromuovere = [[prossimaMossa getNextMoves] indexOfObject:tempProssimaMossa];
    //NSLog(@"LINEA DA PROMOVERE = %d", lineaDaPromuovere);
    
    //for (int i=0; i<[[prossimaMossa getNextMoves] count]; i++) {
        //PGNMove *m = [[prossimaMossa getNextMoves] objectAtIndex:i];
        //NSLog(@"%@\n", m);
    //}
    
    if (livelloVariante == 1) {
        if (lineaDaPromuovere > 1) {
            UIAlertView *promoteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PROMOTE_VARIATION", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:nil, nil];
            [promoteAlertView addButtonWithTitle:NSLocalizedString(@"PROMOTE_TO_MAIN_LINE", nil)];
            [promoteAlertView addButtonWithTitle:NSLocalizedString(@"PROMOTE_AS_FIRST", nil)];
            [promoteAlertView addButtonWithTitle:NSLocalizedString(@"PROMOTE_POSITION", nil)];
            promoteAlertView.tag = 40;
            [promoteAlertView show];
            //NSLog(@"TAG = %d", 40);
        }
        else if (lineaDaPromuovere == 1) {
            UIAlertView *promoteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PROMOTE_VARIATION", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:nil, nil];
            [promoteAlertView addButtonWithTitle:NSLocalizedString(@"TO_MAIN_LINE", nil)];
            promoteAlertView.tag = 50;
            [promoteAlertView show];
            //NSLog(@"TAG = %d", 50);
        }
    }
    else if (livelloVariante > 1) {
         UIAlertView *promoteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PROMOTE_VARIATION", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:nil, nil];
         //[promoteAlertView addButtonWithTitle:NSLocalizedString(@"PROMOTE_TO_MAIN_LINE", nil)];
         [promoteAlertView addButtonWithTitle:NSLocalizedString(@"PROMOTE_UP", nil)];
         promoteAlertView.tag = 60;
         [promoteAlertView show];
         //NSLog(@"TAG = %d", 60);
     }
    
    
    return;
    
    //prossimaMossa = tempProssimaMossa;
    
    //return;
    
    //[prossimaMossa promoteVariation:linea];
    
    [self aggiornaWebView];
    
    [boardModel setFenNotation:[prossimaMossa fen]];
    [pgnParser setFenPosition:[prossimaMossa fen]];
    [self clearBoardView];
    [self setupInitialPosition];
    [prossimaMossa setEvidenzia:YES];
    [self sendMoveToEngine:prossimaMossa];
    [_gameWebView aggiornaWebViewAvanti:prossimaMossa];
    if ([prossimaMossa getNextMoves]) {
        stopNextMove = NO;
    }
    else {
        stopNextMove = YES;
    }
    if (prossimaMossa.plyCount == 0) {
        stopPrevMove = YES;
    }
    else {
        stopPrevMove = NO;
    }
    [self evidenziaAChiToccaMuovere];
}

- (void) promoteVariation {
    //NSLog(@"LINEA DA PROMUOVERE = %d", lineaDaPromuovere);
    //NSLog(@"MOSSA DA PROMUOVERE = %@", tempProssimaMossa.getCompleteMove);
    
    prossimaMossa = tempProssimaMossa;
    
    [self aggiornaWebView];
    
    [boardModel setFenNotation:[prossimaMossa fen]];
    [pgnParser setFenPosition:[prossimaMossa fen]];
    [self clearBoardView];
    [self setupInitialPosition];
    [prossimaMossa setEvidenzia:YES];
    [self sendMoveToEngine:prossimaMossa];
    [_gameWebView aggiornaWebViewAvanti:prossimaMossa];
    if ([prossimaMossa getNextMoves]) {
        stopNextMove = NO;
    }
    else {
        stopNextMove = YES;
    }
    if (prossimaMossa.plyCount == 0) {
        stopPrevMove = YES;
    }
    else {
        stopPrevMove = NO;
    }
    [self evidenziaAChiToccaMuovere];
    
    
    tempProssimaMossa = nil;
    lineaDaPromuovere = -1;
}

- (void) promoteToMainLine {
    [prossimaMossa promoteVariationToMainLine:lineaDaPromuovere];
    
    [self aggiornaWebView];
    [boardModel setFenNotation:[prossimaMossa fen]];
    [pgnParser setFenPosition:[prossimaMossa fen]];
    [self clearBoardView];
    [self setupInitialPosition];
    [prossimaMossa setEvidenzia:YES];
    [self sendMoveToEngine:prossimaMossa];
    [_gameWebView aggiornaWebViewAvanti:prossimaMossa];
    if ([prossimaMossa getNextMoves]) {
        stopNextMove = NO;
    }
    else {
        stopNextMove = YES;
    }
    if (prossimaMossa.plyCount == 0) {
        stopPrevMove = YES;
    }
    else {
        stopPrevMove = NO;
    }
    [self evidenziaAChiToccaMuovere];
    tempProssimaMossa = nil;
    lineaDaPromuovere = -1;
}

- (void) promoteUp {
    [prossimaMossa promoteVariationUp:lineaDaPromuovere];
    
    [self aggiornaWebView];
    [boardModel setFenNotation:[prossimaMossa fen]];
    [pgnParser setFenPosition:[prossimaMossa fen]];
    [self clearBoardView];
    [self setupInitialPosition];
    [prossimaMossa setEvidenzia:YES];
    [self sendMoveToEngine:prossimaMossa];
    [_gameWebView aggiornaWebViewAvanti:prossimaMossa];
    if ([prossimaMossa getNextMoves]) {
        stopNextMove = NO;
    }
    else {
        stopNextMove = YES;
    }
    if (prossimaMossa.plyCount == 0) {
        stopPrevMove = YES;
    }
    else {
        stopPrevMove = NO;
    }
    [self evidenziaAChiToccaMuovere];
    tempProssimaMossa = nil;
    lineaDaPromuovere = -1;
}

- (void) promoteAsFirst {
    [prossimaMossa promoteAsFirstVariation:lineaDaPromuovere];
    
    [self aggiornaWebView];
    [boardModel setFenNotation:[prossimaMossa fen]];
    [pgnParser setFenPosition:[prossimaMossa fen]];
    [self clearBoardView];
    [self setupInitialPosition];
    [prossimaMossa setEvidenzia:YES];
    [self sendMoveToEngine:prossimaMossa];
    [_gameWebView aggiornaWebViewAvanti:prossimaMossa];
    if ([prossimaMossa getNextMoves]) {
        stopNextMove = NO;
    }
    else {
        stopNextMove = YES;
    }
    if (prossimaMossa.plyCount == 0) {
        stopPrevMove = YES;
    }
    else {
        stopPrevMove = NO;
    }
    [self evidenziaAChiToccaMuovere];
    tempProssimaMossa = nil;
    lineaDaPromuovere = -1;
}

- (void) promoteVariationSuperior {
    [prossimaMossa promoteVariationUp:lineaDaPromuovere];
    
    //NSLog(@"LINEA DA PROMUOVERE = %d", lineaDaPromuovere);
    //NSLog(@"MOSSA DA PROMUOVERE = %@", tempProssimaMossa.getCompleteMove);
    
    //prossimaMossa = tempProssimaMossa;
    [self aggiornaWebView];
    [boardModel setFenNotation:[prossimaMossa fen]];
    [pgnParser setFenPosition:[prossimaMossa fen]];
    [self clearBoardView];
    [self setupInitialPosition];
    [prossimaMossa setEvidenzia:YES];
    [self sendMoveToEngine:prossimaMossa];
    [_gameWebView aggiornaWebViewAvanti:prossimaMossa];
    if ([prossimaMossa getNextMoves]) {
        stopNextMove = NO;
    }
    else {
        stopNextMove = YES;
    }
    if (prossimaMossa.plyCount == 0) {
        stopPrevMove = YES;
    }
    else {
        stopPrevMove = NO;
    }
    [self evidenziaAChiToccaMuovere];
    tempProssimaMossa = nil;
    lineaDaPromuovere = -1;
}


- (BOOL) plycountMaggioreZero {
    return [boardModel getPlyCount] > 0;
}

- (BOOL) esisteTestoIniziale {
    return [pgnRootMove existInitialText];
}

- (BOOL) suffissoUltimaMossaXXX {
    NSString *ultima = [prossimaMossa getMossaPerVarianti];
    return [ultima hasSuffix:@"XXX"];
}

- (NSString *) getUltimaMossa {
    if (![prossimaMossa fullMove]) {
        return @"XXX";
    }
    return [prossimaMossa getMossaPerVarianti];
}

- (BOOL) isUltimaMossaInserita {
    if (stopNextMove) {
        return YES;
    }
    else if ([[prossimaMossa getNextMoves] count] == 0) {
        return YES;
    }
    return NO;
}

- (BOOL) isInVariante {
    return [prossimaMossa inVariante];
}

- (NSString *) getTitleGame {
    if (!self.navigationItem.titleView) {
        return self.navigationItem.title;
    }
    else {
        return [_pgnGame getTitleWhiteAndBlack];
    }
}

- (BOOL) isRevealed {
    UIViewController *sourceViewController = self.parentViewController.parentViewController;
    return [sourceViewController isKindOfClass:[SWRevealViewController class]];
}

- (PGNMove *) getMossaDaAnnotare {
    return prossimaMossa;
}

- (void) exitGame {
    [self managePopoverInPad];
    [self stopEngineController];
    if ([_pgnGame isModified]) {
        UIAlertView *saveGameAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_SAVE_GAME", nil) message:NSLocalizedString(@"SAVE_GAME_ALERT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"YES", nil) otherButtonTitles:NSLocalizedString(@"NO", nil), nil];
        saveGameAlertView.tag = -100;
        [saveGameAlertView show];
        return;
    }
    
    if ([_pgnGame isEditMode]) {
        [_pgnGame setEditMode:NO];
    }
}

- (void) undoMove {
    //prossimaMossa = [prossimaMossa getPrevMove];
    NSLog(@"Devo annullare l'ultima mossa eseguita");
    //[self indietroButtonPressed:nil];
    //[self indietroButtonPressed:nil];
    //[self gestisciUndoLastMove];
    //[prossimaMossa undoLastMove];
    //[_gameWebView aggiornaWebViewIndietro:prossimaMossa];
}

- (void) saveGame {
    [self managePopoverInPad];
    if (!_pgnFileDoc) {
        NSArray *gameArrayToSave = [NSArray arrayWithObject:[_pgnGame getGameForAllGamesAndAllTags]];
        DatabaseForCopyTableViewController *dfctvc = [[DatabaseForCopyTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [dfctvc setGamesToCopyArray:gameArrayToSave];
        [dfctvc setPartitaDaSalvare:YES];
        dfctvc.delegate = self;
        UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:dfctvc];
        if (IS_PAD) {
            boardNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        else {
            boardNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        [self presentViewController:boardNavigationController animated:YES completion:nil];
    }
    else {
        NSLog(@"Posso salvare perchè PgnFileDoc esiste");
    }
}

- (void) newGame {
    [self managePopoverInPad];
    UIAlertView *newGameAlertView = [[UIAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:@"Ok", nil];
    [newGameAlertView setTitle:NSLocalizedString(@"NEW_GAME_TITLE", nil)];
    [newGameAlertView setMessage:NSLocalizedString(@"NEW_GAME_MESSAGE", nil)];
    [newGameAlertView setTag:8];
    [newGameAlertView show];
}

- (void) sendGameByEmail {
    [self managePopoverInPad];
    [self manageGameByEmail];
}

- (void) editInitialText {
    [self managePopoverInPad];
    TextCommentViewController *tcvc = [[TextCommentViewController alloc] init];
    tcvc.delegate = self;
    [tcvc setBoardModel:boardModel];
    if ([pgnRootMove movesHasBeenInserted]) {
        PGNMove *firstMoveAfterRoot = [pgnRootMove getFirstMoveAfterRoot];
        [tcvc setPgnMove:firstMoveAfterRoot];
        [tcvc setTextBefore:YES];
    }
    else {
        [tcvc setPgnMove:pgnRootMove];
        [tcvc setTextBefore:NO];
    }
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tcvc];
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:navController animated:YES completion:nil];
    });
    return;
}

- (void) addInitialText {
    [self managePopoverInPad];
    TextCommentViewController *tcvc = [[TextCommentViewController alloc] init];
    tcvc.delegate = self;
    [tcvc setBoardModel:boardModel];
    if ([pgnRootMove movesHasBeenInserted]) {
        PGNMove *firstMoveAfterRoot = [pgnRootMove getFirstMoveAfterRoot];
        [tcvc setPgnMove:firstMoveAfterRoot];
        [tcvc setTextBefore:YES];
    }
    else {
        [tcvc setPgnMove:pgnRootMove];
        [tcvc setTextBefore:NO];
    }
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tcvc];
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:navController animated:YES completion:nil];
    });
}

- (void) addAnnotationToMove {
    [self managePopoverInPad];
    amtvc = [[AnnotationMoveTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    amtvc.delegate = self;
    [amtvc setMossaDaAnnotare:prossimaMossa];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:amtvc];
    if (IS_PAD) {
        annotationMovePopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
        dispatch_async(dispatch_get_main_queue(), ^{
            [annotationMovePopoverController presentPopoverFromBarButtonItem:[self.navigationItem.rightBarButtonItems objectAtIndex:0] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        });
    }
    else {
        [self.navigationController pushViewController:amtvc animated:YES];
    }
}

- (void) addTextAfterMove {
    [self managePopoverInPad];
    TextCommentViewController *tcvc = [[TextCommentViewController alloc] init];
    tcvc.delegate = self;
    [tcvc setBoardModel:boardModel];
    [tcvc setPgnMove:prossimaMossa];
    [tcvc setTextBefore:NO];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tcvc];
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:navController animated:YES completion:nil];
    });
}

- (void) editGameData {
    [self managePopoverInPad];
    if ([_pgnGame userCanEditGameData]) {
        [self showGameInfo];
    }
    else {
        UIAlertView *noMovesAlertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ALERT_NO_MOVES_MESSAGE", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noMovesAlertView show];
    }
}

- (void) updateWebViewAfterMoveAnnotation {
    [self updateWebView];
}

- (void) insertVariant {
    [self managePopoverInPad];
    [self indietroButtonPressed:nil];
}

- (void) insertVariantInsteadOf {
    [self managePopoverInPad];
    [self indietroButtonPressed:nil];
}

- (void) deleteVariation {
    [self managePopoverInPad];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DELETE_VARIATION", nil) message:NSLocalizedString(@"CONFIRM_DELETE_VARIATION", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ACTIONSHEET_CANCEL", nil) otherButtonTitles:NSLocalizedString(@"DELETE_VARIATION", nil), nil];
    av.tag = 30;
    [av show];
}

- (void) promuoviVariation {
    [self managePopoverInPad];
    [self verificaPromoteVariante];
}

- (void) managePopoverInPad {
    if (!boardViewMenuPopoverController) {
        return;
    }
    if ([boardViewMenuPopoverController isPopoverVisible]) {
        [boardViewMenuPopoverController dismissPopoverAnimated:YES];
        boardViewMenuPopoverController = nil;
    }
    
    
}

- (void) flipBoard {
    [self managePopoverInPad];
    [self flipButtonPressed:nil];
}

- (void) displaySetting {
    [self managePopoverInPad];
    UIStoryboard *sb = [UtilToView getStoryBoard];
    SettingsTableViewController *stvc = [sb instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
    stvc.delegate = self;
    UINavigationController *boardNavigationController = [[UINavigationController alloc] initWithRootViewController:stvc];
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

- (void) clearPosition {
    UIAlertView *newGameAlertView = [[UIAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    [newGameAlertView setTitle:NSLocalizedString(@"NEW_POSITION_TITLE", nil)];
    [newGameAlertView setMessage:NSLocalizedString(@"NEW_POSITION_MESSAGE", nil)];
    [newGameAlertView setTag:9];
    [newGameAlertView show];
}

- (void) savePosition {
    [self managePopoverInPad];
    SideToMoveViewController *stmvc;
    UINavigationController *setupNavigationController;
    UIAlertView *positionKOAlertView;
    NSInteger checkupPosition = [boardModel checkSetupPosition];
    
    if (checkupPosition>=0 && checkupPosition<=5) {
        [self evidenziaAChiToccaMuovere];
        stmvc = [[SideToMoveViewController alloc] initWithSquaresAndPieceType:squares :pieceType];
        stmvc.delegate = self;
        [stmvc setBoardModel:boardModel];
        setupNavigationController = [[UINavigationController alloc] initWithRootViewController:stmvc];
        setupNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        setupNavigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self presentModalViewController:setupNavigationController animated:YES];
            [self presentViewController:setupNavigationController animated:YES completion:nil];
        });
        //[self presentModalViewController:setupNavigationController animated:YES];
    }
    else if (checkupPosition == -1) {
        positionKOAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETUP_POSITION_WRONG", nil) message:NSLocalizedString(@"SETUP_POSITION_ERRORS", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [positionKOAlertView show];
    }
    else if (checkupPosition == -2) {
        positionKOAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETUP_POSITION_WRONG", nil) message:NSLocalizedString(@"SETUP_POSITION_KING_CHECK", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [positionKOAlertView show];
    }
}


- (void) partitaSalvataInDatabaseInModalitaReveal {
    [_pgnGame setModified:NO];
}



- (void) loadNextGame {
    if (_delegate && [_delegate respondsToSelector:@selector(getNextGame)]) {
        _pgnGame = [_delegate getNextGame];
        if (_pgnGame) {
            [self setupNewLoadedGame];
            return;
        }
        else {
            [self setupNoGame:@"N"];
        }
    }
}

- (void) loadPreviousGame {
    if (_delegate && [_delegate respondsToSelector:@selector(getPreviousGame)]) {
        _pgnGame = [_delegate getPreviousGame];
        if (_pgnGame) {
            [self setupNewLoadedGame];
            return;
        }
        else {
            [self setupNoGame:@"P"];
        }
    }
}

- (void) setupNewLoadedGame {
    flipped = NO;
    [self removeNavigationTitleGestureRecognizer];
    if ([_pgnGame isPosition]) {
        [self setPgnGame:_pgnGame];
        //[boardModel setupInitialPosition];
        //[self replaceBoard];
        [self presentBoardView];
        [self presentGameWebView];
        [self evidenziaAChiToccaMuovere];
        [self sendMoveToEngine:pgnRootMove];
        if (bookManager) {
            [bookManager interrogaBook:[pgnRootMove fen]];
        }
        [_gameWebView setOpening:nil];
        [self aggiornaWebView];
        [self setupNavigationTitle];
    }
    else {
        [self setPgnGame:_pgnGame];
        [boardModel setupInitialPosition];
        //[self replaceBoard];
        [self presentBoardView];
        [self presentGameWebView];
        [self evidenziaAChiToccaMuovere];
        [self sendMoveToEngine:pgnRootMove];
        if (bookManager) {
            [bookManager interrogaBook:[pgnRootMove fen]];
        }
        [_gameWebView setOpening:nil];
        [self aggiornaWebView];
        [self setupNavigationTitle];
    }
    
    if (![_pgnGame isEditMode]) {
        [boardView addLeftAndRightSwipeGestureRecognizer];
    }
    
}

- (void) setupNoGame:(NSString *)direction {
    NSString *title = nil;
    if ([direction isEqualToString:@"N"]) {
        title = NSLocalizedString(@"NO_NEXT_GAME", nil);
    }
    else {
        title = NSLocalizedString(@"NO_PREVIOUS_GAME", nil);
    }
    
    UIAlertView *noGameAlertView = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"NO_MORE_GAMES", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [noGameAlertView show];
}


- (void) confrontaConFen {
    NSString *fenDopoE4 = @"rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1";
    fenDopoE4 = @"r1b1k2r/1pqnbppp/p2ppn2/6B1/3NPP2/2N2Q2/PPP3PP/2KR1B1R w kq - 5 10";
    
    //fenDopoE4 = @"r1b1k2r/1pqnbppp/p2ppn2/6B1/3NPP2/2N2Q2/PPP3PP/2KR1B1R w kq - 0 10";
    
    
    //NSLog(@"Partite trovate = %d", partiteTrovate.count);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_tableViewData) {
        return [_tableViewData count];
    }
    return 20;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [cell setBackgroundColor:[UIColor colorWithRed:0.000 green:0.557 blue:0.165 alpha:0.4]];
    
     //if ((indexPath.row % 2) == 0) {
         //UIColor *oddRowColor = [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0];
         //[cell setBackgroundColor: oddRowColor];
     //}
     //else {
         //[cell setBackgroundColor:[UIColor clearColor]];
     //}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"Nalimov Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (IS_PAD) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    else {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.textLabel.textColor = [UIColor yellowColor];
    NSString *testo = [_tableViewData objectAtIndex:indexPath.row];
    NSArray *testoArray = [testo componentsSeparatedByString:@":"];
    cell.textLabel.text = [testoArray objectAtIndex:0];
    
    NSArray *detailArray = [[testoArray objectAtIndex:1] componentsSeparatedByString:@" "];
    
    cell.detailTextLabel.text = [testoArray objectAtIndex:1];
    
    if (detailArray.count == 4) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString([detailArray objectAtIndex:1], nil), NSLocalizedString([detailArray objectAtIndex:2], nil), [detailArray objectAtIndex:3]];
    }
    else if (detailArray.count == 2) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString([detailArray objectAtIndex:1], nil)];
    }
    else {
        cell.detailTextLabel.text = @"";
    }
    
    
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSelector: @selector(deselect:) withObject: tableView afterDelay: 0.1];
    
    //[_tableView setUserInteractionEnabled:NO];
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *mossa = cell.textLabel.text;
    //NSString *risu = cell.detailTextLabel.text;
    
    if (!mossa) {
        return;
    }
    
    //NSLog(@"Mossa:%@ - %@", mossa, risu);
    
    
    //PGNMove *pgnMove = [[PGNMove alloc] initWithFullMove:mossa];
    //NSLog(@"PGNMOVE = %@", pgnMove.fullMove);
    
    //if ([pgnMove promoted]) {
    //    NSLog(@"MOSSA PROMOZIONE");
    //    NSLog(@"PEZZO PROMOSSO %@", pgnMove.pezzoPromosso);
    //    NSLog(@"PROMOTION %@", pgnMove.promotion);
    //}
    
    //NSLog(@"CASA PARTENZA = %d    CASA ARRIVO = %d", pgnMove.fromSquare, pgnMove.toSquare);
    
    
    //selectedMove = YES;
    
    
    NSString *mossaPgn = nil;
    NSArray *mossaArray = [mossa componentsSeparatedByString:@"-"];
    
    NSString *casaP = [mossaArray objectAtIndex:0];
    NSString *casaA = [mossaArray objectAtIndex:1];
    
    if ([mossa hasPrefix:@"K"]) {
        mossaPgn = [NSString stringWithFormat:@"K%@", [mossaArray objectAtIndex:1]];
        casaP = [casaP substringFromIndex:1];
    }
    else if ([mossa hasPrefix:@"Q"]) {
        mossaPgn = [NSString stringWithFormat:@"Q%@", [mossaArray objectAtIndex:1]];
        casaP = [casaP substringFromIndex:1];
    }
    else if ([mossa hasPrefix:@"R"]) {
        mossaPgn = [NSString stringWithFormat:@"R%@", [mossaArray objectAtIndex:1]];
        casaP = [casaP substringFromIndex:1];
    }
    else if ([mossa hasPrefix:@"B"]) {
        mossaPgn = [NSString stringWithFormat:@"B%@", [mossaArray objectAtIndex:1]];
        casaP = [casaP substringFromIndex:1];
    }
    else if ([mossa hasPrefix:@"N"]) {
        mossaPgn = [NSString stringWithFormat:@"N%@", [mossaArray objectAtIndex:1]];
        casaP = [casaP substringFromIndex:1];
    }
    else {
        mossaPgn = [mossaArray objectAtIndex:1];
    }
    
    
    BOOL promozione = NO;
    NSString *pezzoPromosso = nil;
    if ([casaA rangeOfString:@"="].location != NSNotFound) {
        selectedMove = YES;
        NSArray *maArray = [casaA componentsSeparatedByString:@"="];
        casaA = [maArray objectAtIndex:0];
        promozione = YES;
        pezzoPromosso = [maArray objectAtIndex:1];
    }
    
    //NSLog(@"%@-%@", casaP, casaA);
    
    //[boardModel printPosition];
    
    casaPartenza = [boardModel getSquareTagFromAlgebricValue:casaP];
    //NSLog(@"CASA PARTENZA = %d", casaPartenza);
    PieceButton *pb = [boardView findPieceBySquareTag:casaPartenza];
    //NSLog(@"Ho trovato il pezzo");
    //if (pb) {
    //    NSLog(@"%@", pb.getSimbolo);
    //}
    //else {
    //    NSLog(@"Non trovo PB");
    //}
    [pb generaMossePseudoLegali];
    
    //NSLog(@"Ho generato le mosse pseudocasuali");
    //NSLog(@"PEZZO DA PROMUOVERE = %@", pezzoPromosso);
    
    //NSLog(@"%@", [pb generaMosse]);
    
    int controllo = [self checkCasaArrivo:[boardModel getSquareTagFromAlgebricValue:casaA]];
    //NSLog(@"RISU CONTROLLO:%d", controllo);
    if (controllo >= 0) {
        [pb setSquareValue:casaArrivo];
        if (promozione) {
            pedoneAppenaPromosso = [boardView findPieceBySquareTag:casaArrivo];
            [pedoneAppenaPromosso removeFromSuperview];
            PieceButton *pb;
            if ([pezzoPromosso isEqualToString:@"Q"]) {
                if ([boardModel whiteHasToMove]) {
                    pezzoPromosso = @"wq";
                }
                else {
                    pezzoPromosso = @"bq";
                }
                pb = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pezzoPromosso];
            }
            else if ([pezzoPromosso isEqualToString:@"R"]) {
                if ([boardModel whiteHasToMove]) {
                    pezzoPromosso = @"wr";
                }
                else {
                    pezzoPromosso = @"br";
                }
                pb = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pezzoPromosso];
            }
            else if ([pezzoPromosso isEqualToString:@"B"]) {
                if ([boardModel whiteHasToMove]) {
                    pezzoPromosso = @"wb";
                }
                else {
                    pezzoPromosso = @"bb";
                }
                pb = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pezzoPromosso];
            }
            else if ([pezzoPromosso isEqualToString:@"B"]) {
                if ([boardModel whiteHasToMove]) {
                    pezzoPromosso = @"wn";
                }
                else {
                    pezzoPromosso = @"bn";
                }
                pb = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pezzoPromosso];
            }
            [pb setDelegate:self];
            
            if (flipped) {
                [pb flip];
            }
            [pb setSquareValue:casaArrivo];
            [boardView addSubview:pb];
            [self gestisciMossaCompletaConPromozione:pezzoPromosso];
            selectedMove = NO;
            //[boardModel printPosition];
            
            [boardView clearHilightedAndControlledSquares];
            [boardView clearCanditatesPieces];
            [boardView clearArrivalSquare:candidateSquareTo];
            candidateSquareTo = -1;
            
            //[self performSelectorOnMainThread:@selector(getNalimovResult) withObject:nil waitUntilDone:YES];
        }
        else {
            [self gestisciMossaCompleta];
            //[boardModel printPosition];
            
            [boardView clearHilightedAndControlledSquares];
            [boardView clearCanditatesPieces];
            [boardView clearArrivalSquare:candidateSquareTo];
            candidateSquareTo = -1;
            
            
            //[self performSelectorOnMainThread:@selector(getNalimovResult) withObject:nil waitUntilDone:YES];
        }
        
    }
    
    
    //mossaEseguita = [[PGNMove alloc] initWithFullMove:mossaPgn];
    //NSLog(@"%@", mossaEseguita.fullMove);
    //[self gestisciMossaCompleta];
}

- (void)deselect:(UITableView *)tableView {
    [tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow] animated: YES];
}

- (void) clearNalimovTableView {
    if (_tableViewData) {
        [_tableViewData removeAllObjects];
        [_tableView reloadData];
    }
}

#pragma mark - Implementazione metodi optionali RNGridMenu

- (void) showPromotionMenu:(NSString *)pawn :(BOOL)capture {
    NSInteger numberOfOptions = 4;
    NSString *color = [pawn substringToIndex:1];
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:[[[settingManager getPieceTypeToLoad] stringByAppendingString:color] stringByAppendingString:@"q"]] title:NSLocalizedString(@"QUEEN", nil)],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:[[[settingManager getPieceTypeToLoad] stringByAppendingString:color] stringByAppendingString:@"r"]] title:NSLocalizedString(@"ROOK", nil)],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:[[[settingManager getPieceTypeToLoad] stringByAppendingString:color] stringByAppendingString:@"b"]] title:NSLocalizedString(@"BISHOP", nil)],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:[[[settingManager getPieceTypeToLoad] stringByAppendingString:color] stringByAppendingString:@"n"]] title:NSLocalizedString(@"KNIGHT", nil)],
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    //    av.bounces = NO;
    
    if (IS_PAD) {
        [av setItemSize:CGSizeMake(150, 150)];
    }
    
    [av setBlurLevel:0.0];
    
    if ([color hasPrefix:@"w"]) {
        [av setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0]];
    }
    else {
        [av setBackgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:1.0]];
        [av setItemTextColor:[UIColor blackColor]];
    }
    
    if (capture) {
        av.view.tag = 20;
    }
    else {
        av.view.tag = 10;
    }
    
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
    
}

- (void) gridMenuWillDismiss:(RNGridMenu *)gridMenu {
    pedoneAppenaPromosso = [boardView findPieceBySquareTag:casaArrivo];
    [pedoneAppenaPromosso removeFromSuperview];
    [pedoneAppenaPromosso setSquareValue:casaPartenza];
    [boardView addSubview:pedoneAppenaPromosso];
    if (gridMenu.view.tag == 20) {
        [boardView manageCaptureBack];
    }
    pedoneAppenaPromosso = nil;
}

- (void) gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    NSString *pz = nil;
    
    if (itemIndex == 0) {
        if ([boardModel whiteHasToMove]) {
            pz = @"wq";
        }
        else {
            pz = @"bq";
        }
    }
    else if (itemIndex == 1) {
        if ([boardModel whiteHasToMove]) {
            pz = @"wr";
        }
        else {
            pz = @"br";
        }
    }
    else if (itemIndex == 2) {
        if ([boardModel whiteHasToMove]) {
            pz = @"wb";
        }
        else {
            pz = @"bb";
        }
        
    }
    else if (itemIndex == 3) {
        if ([boardModel whiteHasToMove]) {
            pz = @"wn";
        }
        else {
            pz = @"bn";
        }
    }
    
    pedoneAppenaPromosso = [boardView findPieceBySquareTag:casaArrivo];
    [pedoneAppenaPromosso removeFromSuperview];
    PieceButton *pb;
    switch (itemIndex) {
        case 0:
            pb = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pz];
            break;
        case 1:
            pb = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pz];
            break;
        case 2:
            pb = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pz];
            break;
        case 3:
            pb = [[[KnightButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:pz];
            break;
    }
    [pb setDelegate:self];
    
    if (flipped) {
        [pb flip];
    }
    
    
    [pb setSquareValue:casaArrivo];
    [boardView addSubview:pb];
    [self gestisciMossaCompletaConPromozione:pz];
}


@end
