//
//  SettingManager.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 05/02/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "SettingManager.h"
#import "Options.h"
#import "UtilToView.h"

@interface SettingManager() {

    NSUserDefaults *defaults;
    
    NSArray *listEmailRecipient;
    
    Reachability *internetReachability;
    NetworkStatus networkStatus;
}

@end

@implementation SettingManager


#define KEY_DISPLAY_ECO_BOARD_PREVIEW_INT @"displayEcoBoardPreviewHint"

- (id) init {
    self = [super init];
    if (self) {
        //NSLog(@"Sto inizializzando Setting Manager");
        [self loadStandardDefaults];
        [self setupReachability];
    }
    return self;
}


+ (id) sharedSettingManager {
    static SettingManager *settingManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settingManager = [[self alloc] init];
    });
    return settingManager;
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
}

- (void) loadStandardDefaults {
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    _pieceType = [defaults stringForKey:@"pieces"];
    
    if (_pieceType) {
        if (![[UtilToView getTipoPezziArray] containsObject:_pieceType]) {
            _pieceType = @"Zurich";
            [defaults setObject:_pieceType forKey:@"pieces"];
            [defaults synchronize];
        }
    }
    
    if (!_pieceType) {
        _pieceType = @"Zurich";
        [defaults setObject:_pieceType forKey:@"pieces"];
        [defaults synchronize];
    }
    
    _coordinate = [defaults stringForKey:@"coordinate"];
    
    if (_coordinate) {
        if (![[UtilToView getTipoCoordinate] containsObject:_coordinate]) {
            _coordinate = NSLocalizedString(@"NO_COORDINATES", nil);
            [defaults setObject:_coordinate forKey:@"coordinate"];
            [defaults synchronize];
        }
    }
    
    if (!_coordinate) {
        _coordinate = NSLocalizedString(@"NO_COORDINATES", nil);
        [defaults setObject:_coordinate forKey:@"coordinate"];
        [defaults synchronize];
    }
    
    _squares = [defaults stringForKey:@"squares"];
    
    if (_squares) {
        if (![[UtilToView getTipoSquares] containsObject:_squares]) {
            _squares = @"square5";
            [defaults setObject:_squares forKey:@"squares"];
            [defaults synchronize];
        }
    }
    
    if (!_squares) {
        _squares = @"square5";
        [defaults setObject:_squares forKey:@"squares"];
        [defaults synchronize];
    }
    
    _notation = [defaults stringForKey:@"notation"];
    
    if (_notation) {
        if (![[UtilToView getTipoNotation] containsObject:_notation]) {
            _notation = NSLocalizedString(@"LETTER", nil);
            [defaults setObject:_notation forKey:@"notation"];
            [defaults synchronize];
        }
    }
    
    if (!_notation) {
        _notation = NSLocalizedString(@"LETTER", nil);
        [defaults setObject:_notation forKey:@"notation"];
        [defaults synchronize];
    }
    
    
    _vistaMotore = [defaults stringForKey:@"engine"];
    if (_vistaMotore) {
        if (![[UtilToView getVistaMotore] containsObject:_vistaMotore]) {
            _vistaMotore = NSLocalizedString(@"ENGINE_VIEW_OPEN", nil);
            [defaults setObject:_vistaMotore forKey:@"engine"];
            [defaults synchronize];
        }
    }
    
    if (!_vistaMotore) {
        _vistaMotore = NSLocalizedString(@"ENGINE_VIEW_OPEN", nil);
        [defaults setObject:_vistaMotore forKey:@"engine"];
        [defaults synchronize];
    }
    
    NSObject *boardSizeObj = [defaults objectForKey:@"boardSize"];
    if (boardSizeObj) {
        _boardSize = (int)[defaults integerForKey:@"boardSize"];
    }
    else {
        _boardSize = BIG;
        [defaults setInteger:_boardSize forKey:@"boardSize"];
        [defaults synchronize];
    }
    
    NSObject *engineFigObj = [defaults objectForKey:@"engineNotation"];
    if (engineFigObj) {
        _engineFigurineNotation = [defaults boolForKey:@"engineNotation"];
    }
    else {
        _engineFigurineNotation = NO;
        [defaults setBool:_engineFigurineNotation forKey:@"engineNotation"];
        [defaults synchronize];
    }
    
    
    if (IsChessStudioLight) {
        _showBookMoves = NO;
        [defaults setBool:_showBookMoves forKey:@"ShowBookMoves"];
        [defaults synchronize];
        
        _showEco = NO;
        [defaults setBool:_showEco forKey:@"ShowEco"];
        [defaults synchronize];
    }
    else {
    
        NSObject *obj = [defaults objectForKey:@"ShowBookMoves"];
        if (obj) {
            _showBookMoves = [defaults boolForKey:@"ShowBookMoves"];
        }
        else {
            _showBookMoves = YES;
            [defaults setBool:_showBookMoves forKey:@"ShowBookMoves"];
            [defaults synchronize];
        }
    
        obj = [defaults objectForKey:@"ShowEco"];
        if (obj) {
            _showEco = [defaults boolForKey:@"ShowEco"];
        }
        else {
            _showEco = YES;
            [defaults setBool:_showEco forKey:@"ShowEco"];
            [defaults synchronize];
        }
    }
    
    
    NSObject *dragAndDrop = [defaults objectForKey:@"DragAndDropMove"];
    if (dragAndDrop) {
        _dragAndDrop = [defaults boolForKey:@"DragAndDropMove"];
    }
    else {
        _dragAndDrop = YES;
        [defaults setBool:_dragAndDrop forKey:@"DragAndDropMove"];
        [defaults synchronize];
    }
    
    NSObject *tapPezzoDaMuovere = [defaults objectForKey:@"TapOnPieceToMove"];
    if (tapPezzoDaMuovere) {
        _tapPieceToMove = [defaults boolForKey:@"TapOnPieceToMove"];
    }
    else {
        _tapPieceToMove = YES;
        [defaults setBool:_tapPieceToMove forKey:@"TapOnPieceToMove"];
        [defaults synchronize];
    }
    
    NSObject *legalMoves = [defaults objectForKey:@"ShowLegalMoves"];
    if (legalMoves) {
        _showLegalMoves = [defaults boolForKey:@"ShowLegalMoves"];
    }
    else {
        _showLegalMoves = YES;
        [defaults setBool:_showLegalMoves forKey:@"ShowLegalMoves"];
        [defaults synchronize];
    }
    
    
    NSObject *tapCasaArrivo = [defaults objectForKey:@"TapDestinationMove"];
    if (tapCasaArrivo) {
        _tapDestination = [defaults boolForKey:@"TapDestinationMove"];
    }
    else {
        _tapDestination = YES;
        [defaults setBool:_tapDestination forKey:@"TapDestinationMove"];
        [defaults synchronize];
    }
    
    NSObject *colorLight = [defaults objectForKey:@"ColorHighLight"];
    if (colorLight) {
        _colorHighLight = [defaults stringForKey:@"ColorHighLight"];
    }
    else {
        _colorHighLight = NSLocalizedString(@"ORANGE", nil);
        [defaults setObject:_colorHighLight forKey:@"ColorHighLight"];
        [defaults synchronize];
    }
    
    NSObject *colorTapArrival = [defaults objectForKey:@"ColorTapDestination"];
    if (colorTapArrival) {
        _colorTapDestination = [defaults stringForKey:@"ColorTapDestination"];
    }
    else {
        _colorTapDestination = NSLocalizedString(@"YELLOW", nil);
        [defaults setObject:_colorTapDestination forKey:@"ColorTapDestination"];
        [defaults synchronize];
    }
    
    NSObject *cloudOn = [defaults objectForKey:@"iCloudOn"];
    if (cloudOn) {
        _iCloudOn = [defaults boolForKey:@"iCloudOn"];
    }
    else {
        _iCloudOn = NO;
        [defaults setBool:_iCloudOn forKey:@"iCloudOn"];
        [defaults synchronize];
    }
    
    
    NSObject *ecoBoardPreviewHint = [defaults objectForKey:KEY_DISPLAY_ECO_BOARD_PREVIEW_INT];
    if (!ecoBoardPreviewHint) {
        [defaults setBool:NO forKey:KEY_DISPLAY_ECO_BOARD_PREVIEW_INT];
        [defaults synchronize];
    }
    else {
        _ecoBoardPreviewHintDisplayed = [defaults boolForKey:KEY_DISPLAY_ECO_BOARD_PREVIEW_INT];
    }
    
    [self loadEmailRecipients];
}


#pragma mark - Inizio Metodi gestione Email recipients

- (void) loadEmailRecipients {
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:@"EmailRecipients.json"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists) {
        NSError *error = nil;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:kNilOptions error:&error];
        [self addEmailRecipients:data];
    }
    else {
        listEmailRecipient = [NSArray arrayWithObjects:@"chess.studio.app@gmail.com", nil];
    }
}

- (void) addEmailRecipients:(NSDictionary *)emailRecipients {
    NSMutableArray *listRecipient = [[NSMutableArray alloc] init];
    for (NSString *key in [emailRecipients allKeys]) {
        if ([[emailRecipients objectForKey:key] isEqualToString:@"1"]) {
            [listRecipient addObject:key];
        }
    }
    listEmailRecipient = [listRecipient sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSString *) getListaEmailRecipients {
    NSMutableString *lista = [[NSMutableString alloc] init];
    for (NSString *s in listEmailRecipient) {
        if (lista.length == 0) {
            [lista appendString:s];
        }
        else {
            [lista appendString:@", "];
            [lista appendString:s];
        }
    }
    return lista;
}

- (NSArray *) getRecipients {
    return listEmailRecipient;
}

#pragma mark - Fine Metodi gestione Email recipients


- (void) setPieceType:(NSString *)pieceType {
    _pieceType = pieceType;
    [[NSUserDefaults standardUserDefaults] setObject:_pieceType forKey:@"pieces"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setSquares:(NSString *)squares {
    _squares = squares;
    [[NSUserDefaults standardUserDefaults] setObject:_squares forKey:@"squares"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setCoordinate:(NSString *)coordinate {
    _coordinate = coordinate;
    [[NSUserDefaults standardUserDefaults] setObject:_coordinate forKey:@"coordinate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setNotation:(NSString *)notation {
    _notation = notation;
    [[NSUserDefaults standardUserDefaults] setObject:_notation forKey:@"notation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setBoardSize:(enum BoardSize)boardSize {
    _boardSize = boardSize;
    [[NSUserDefaults standardUserDefaults] setInteger:_boardSize forKey:@"boardSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setVistaMotore:(NSString *)vistaMotore {
    _vistaMotore = vistaMotore;
    [[NSUserDefaults standardUserDefaults] setObject:_vistaMotore forKey:@"engine"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setEngineFigurineNotation:(BOOL)engineFigurineNotation {
    _engineFigurineNotation = engineFigurineNotation;
    [[NSUserDefaults standardUserDefaults] setBool:_engineFigurineNotation forKey:@"engineNotation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setShowBookMoves:(BOOL)showBookMoves {
    _showBookMoves = showBookMoves;
    [[NSUserDefaults standardUserDefaults] setBool:_showBookMoves forKey:@"ShowBookMoves"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setShowEco:(BOOL)showEco {
    _showEco = showEco;
    [[NSUserDefaults standardUserDefaults] setBool:_showEco forKey:@"ShowEco"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setDragAndDrop:(BOOL)dragAndDrop {
    _dragAndDrop = dragAndDrop;
    [[NSUserDefaults standardUserDefaults] setBool:_dragAndDrop forKey:@"DragAndDropMove"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setTapPieceToMove:(BOOL)tapPieceToMove {
    _tapPieceToMove = tapPieceToMove;
    [[NSUserDefaults standardUserDefaults] setBool:_tapPieceToMove forKey:@"TapOnPieceToMove"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setShowLegalMoves:(BOOL)showLegalMoves {
    _showLegalMoves = showLegalMoves;
    [[NSUserDefaults standardUserDefaults] setBool:_showLegalMoves forKey:@"ShowLegalMoves"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setTapDestination:(BOOL)tapDestination {
    _tapDestination = tapDestination;
    [[NSUserDefaults standardUserDefaults] setBool:_tapDestination forKey:@"TapDestinationMove"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setColorHighLight:(NSString *)colorHighLight {
    _colorHighLight = colorHighLight;
    [defaults setObject:_colorHighLight forKey:@"ColorHighLight"];
    [defaults synchronize];
}

- (void) setColorTapDestination:(NSString *)colorTapDestination {
    _colorTapDestination = colorTapDestination;
    [defaults setObject:_colorTapDestination forKey:@"ColorTapDestination"];
    [defaults synchronize];
}

- (void) setICloudOn:(BOOL)iCloudOn {
    _iCloudOn = iCloudOn;
    [defaults setBool:_iCloudOn forKey:@"iCloudOn"];
    [defaults synchronize];
}

- (void) setEcoBoardPreviewHintDisplayed:(BOOL)ecoBoardPreviewHintDisplayed {
    _ecoBoardPreviewHintDisplayed = ecoBoardPreviewHintDisplayed;
    [defaults setBool:_ecoBoardPreviewHintDisplayed forKey:KEY_DISPLAY_ECO_BOARD_PREVIEW_INT];
    [defaults synchronize];
}

- (BOOL) isFigurineNotation {
    return [_notation isEqualToString:NSLocalizedString(@"FIGURINE", nil)];
}

- (BOOL) isLetterNotation {
    return [_notation isEqualToString:NSLocalizedString(@"LETTER", nil)];
}

- (BOOL) isEngineViewOpen {
    return [_vistaMotore isEqualToString:NSLocalizedString(@"ENGINE_VIEW_OPEN", nil)];
}

- (BOOL) isEngineViewClosed {
    return [_vistaMotore isEqualToString:NSLocalizedString(@"ENGINE_VIEW_CLOSED", nil)];
}

- (BOOL) boardWithEdge {
    return [_coordinate isEqualToString:NSLocalizedString(@"EDGE", nil)];
}

- (NSString *) boardSizeAsString {
    if (_boardSize == BIG) {
        return NSLocalizedString(@"BIG", nil);
    }
    else if (_boardSize == MEDIUM) {
        return NSLocalizedString(@"MEDIUM", nil);
    }
    else if (_boardSize == SMALL) {
        return NSLocalizedString(@"SMALL", nil);
    }
    return nil;
}

- (NSString *) pieceTypeAsString {
    return _pieceType;
}

- (NSString *) squaresAsString {
    if ([_squares isEqualToString:@"square1"]) {
        return @"Wood";
    }
    else if ([_squares isEqualToString:@"square2"]) {
        return @"Marble";
    }
    else if ([_squares isEqualToString:@"square3"]) {
        return @"Wood 2";
    }
    else if ([_squares isEqualToString:@"square4"]) {
        return @"Texture";
    }
    else if ([_squares isEqualToString:@"square5"]) {
        return @"Wood 3";
    }
    else if ([_squares isEqualToString:@"square6"]) {
        return @"DarkLight";
    }
    else if ([_squares isEqualToString:@"square7"]) {
        return @"GrayLight";
    }
    else if ([_squares isEqualToString:@"square8"]) {
        return @"BlueLight";
    }
    else if ([_squares isEqualToString:@"square9"]) {
        return @"BrownLight";
    }
    else if ([_squares isEqualToString:@"square10"]) {
        return @"GreenLight";
    }
    return nil;
}

- (NSString *) squaresAsString:(NSString *)square {
    if ([square isEqualToString:@"square1"]) {
        return @"Wood";
    }
    else if ([square isEqualToString:@"square2"]) {
        return @"Marble";
    }
    else if ([square isEqualToString:@"square3"]) {
        return @"Wood 2";
    }
    else if ([square isEqualToString:@"square4"]) {
        return @"Texture";
    }
    else if ([square isEqualToString:@"square5"]) {
        return @"Wood 3";
    }
    else if ([square isEqualToString:@"square6"]) {
        return @"DarkLight";
    }
    else if ([square isEqualToString:@"square7"]) {
        return @"GrayLight";
    }
    else if ([square isEqualToString:@"square8"]) {
        return @"BlueLight";
    }
    else if ([square isEqualToString:@"square9"]) {
        return @"BrownLight";
    }
    else if ([square isEqualToString:@"square10"]) {
        return @"GreenLight";
    }
    return nil;
}

- (NSString *) coordinatesAsString {
    return nil;
}

- (UIImage *) getDarkSquare {
    if ([_squares isEqualToString:@"square1"]) {
        return [UIImage imageNamed:@"BlackSquare96.png"];
    }
    else if ([_squares isEqualToString:@"square2"]) {
        return [UIImage imageNamed:@"BlackMarmo.png"];
    }
    else if ([_squares isEqualToString:@"square3"]) {
        return [UIImage imageNamed:@"BlackWood2.png"];
    }
    else if ([_squares isEqualToString:@"square4"]) {
        return [UIImage imageNamed:@"BlackTexture.png"];
    }
    else if ([_squares isEqualToString:@"square5"]) {
        return [UIImage imageNamed:@"BlackWood3.png"];
    }
    else if ([_squares isEqualToString:@"square6"]) {
        return [UIImage imageNamed:@"DarkNewspaper96"];
    }
    else if ([_squares isEqualToString:@"square7"]) {
        return [UIImage imageNamed:@"BlackGrayLight"];
    }
    else if ([_squares isEqualToString:@"square8"]) {
        return [UIImage imageNamed:@"BlackBlueLight"];
    }
    else if ([_squares isEqualToString:@"square9"]) {
        return [UIImage imageNamed:@"BlackBrownLight"];
    }
    else if ([_squares isEqualToString:@"square10"]) {
        return [UIImage imageNamed:@"BlackGreenLight"];
    }
    return nil;
}

- (UIImage *) getLightSquare {
    if ([_squares isEqualToString:@"square1"]) {
        return [UIImage imageNamed:@"WhiteSquare96.png"];
    }
    else if ([_squares isEqualToString:@"square2"]) {
        return [UIImage imageNamed:@"WhiteMarmo.png"];
    }
    else if ([_squares isEqualToString:@"square3"]) {
        return [UIImage imageNamed:@"WhiteWood2.png"];
    }
    else if ([_squares isEqualToString:@"square4"]) {
        return [UIImage imageNamed:@"WhiteTexture.png"];
    }
    else if ([_squares isEqualToString:@"square5"]) {
        return [UIImage imageNamed:@"WhiteWood3.png"];
    }
    else if ([_squares isEqualToString:@"square6"]) {
        return [UIImage imageNamed:@"LightNewspaper96"];
    }
    else if ([_squares isEqualToString:@"square7"]) {
        return [UIImage imageNamed:@"WhiteGrayLight"];
    }
    else if ([_squares isEqualToString:@"square8"]) {
        return [UIImage imageNamed:@"WhiteBlueLight"];
    }
    else if ([_squares isEqualToString:@"square9"]) {
        return [UIImage imageNamed:@"WhiteBrownLight"];
    }
    else if ([_squares isEqualToString:@"square10"]) {
        return [UIImage imageNamed:@"WhiteGreenLight"];
    }
    return nil;
}

- (NSString *) getPieceTypeToLoad {
    if ([_pieceType isEqualToString:@"Zurich"]) {
        return @"zur96";
    }
    else if ([_pieceType isEqualToString:@"Linares"]) {
        return @"lin96";
    }
    else if ([_pieceType isEqualToString:@"Hastings"]) {
        return @"has96";
    }
    else if ([_pieceType isEqualToString:@"Condal"]) {
        return @"condal96";
    }
    else if ([_pieceType isEqualToString:@"Adventurer"]) {
        return @"adventurer96";
    }
    return nil;
}


- (CGFloat) getEdgeSize {
    if (IS_PAD_PRO) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 6.0;
            }
            else if (_boardSize == MEDIUM) {
                return 5.0;
            }
            else if (_boardSize == SMALL) {
                return 4.0;
            }
        }
        else if (IS_LANDSCAPE) {
            if (_boardSize == BIG) {
                return 6.0;
            }
            else if (_boardSize == MEDIUM) {
                return 5.0;
            }
            else if (_boardSize == SMALL) {
                return 4.0;
            }
        }
    }
    else if (IS_PAD) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 5.0;
            }
            else if (_boardSize == MEDIUM) {
                return 3.0;
            }
            else if (_boardSize == SMALL) {
                return 2.0;
            }
        }
        else if (IS_LANDSCAPE) {
            if (_boardSize == BIG) {
                return 4.0;
            }
            else if (_boardSize == MEDIUM) {
                return 3.0;
            }
            else if (_boardSize == SMALL) {
                return 2.0;
            }
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 2.0;
            }
            else if (_boardSize == MEDIUM) {
                return 1.5;
            }
            else if (_boardSize == SMALL) {
                return 1.0;
            }
        }
        else if (IS_LANDSCAPE) {
            return 1.5;
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 2.0;
            }
            else if (_boardSize == MEDIUM) {
                return 1.5;
            }
            else if (_boardSize == SMALL) {
                return 1.0;
            }
        }
        else if (IS_LANDSCAPE) {
            return 1.5;
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 2.0;
            }
            else if (_boardSize == MEDIUM) {
                return 1.5;
            }
            else if (_boardSize == SMALL) {
                return 1.0;
            }
        }
        else if (IS_LANDSCAPE) {
            return 1.5;
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 2.0;
            }
            else if (_boardSize == MEDIUM) {
                return 1.5;
            }
            else if (_boardSize == SMALL) {
                return 1.0;
            }
        }
        else if (IS_LANDSCAPE) {
            return 1.5;
        }
    }
    return 0.0;
}


- (CGFloat) getEdgeSize:(UIDeviceOrientation)deviceOrientation {
    if (IS_PAD_PRO) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            if (_boardSize == BIG) {
                return 6.0;
            }
            else if (_boardSize == MEDIUM) {
                return 5.0;
            }
            else if (_boardSize == SMALL) {
                return 4.0;
            }
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            if (_boardSize == BIG) {
                return 6.0;
            }
            else if (_boardSize == MEDIUM) {
                return 5.0;
            }
            else if (_boardSize == SMALL) {
                return 4.0;
            }
        }
    }
    else if (IS_PAD) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            if (_boardSize == BIG) {
                return 5.0;
            }
            else if (_boardSize == MEDIUM) {
                return 3.0;
            }
            else if (_boardSize == SMALL) {
                return 2.0;
            }
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            if (_boardSize == BIG) {
                return 4.0;
            }
            else if (_boardSize == MEDIUM) {
                return 3.0;
            }
            else if (_boardSize == SMALL) {
                return 2.0;
            }
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            if (_boardSize == BIG) {
                return 2.0;
            }
            else if (_boardSize == MEDIUM) {
                return 1.5;
            }
            else if (_boardSize == SMALL) {
                return 1.0;
            }
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            return 1.5;
        }
    }
    else if (IS_IPHONE_5) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            if (_boardSize == BIG) {
                return 2.0;
            }
            else if (_boardSize == MEDIUM) {
                return 1.5;
            }
            else if (_boardSize == SMALL) {
                return 1.0;
            }
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            return 1.5;
        }
    }
    else if (IS_IPHONE_6) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            if (_boardSize == BIG) {
                return 2.0;
            }
            else if (_boardSize == MEDIUM) {
                return 1.5;
            }
            else if (_boardSize == SMALL) {
                return 1.0;
            }
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            return 1.5;
        }
    }
    else if (IS_IPHONE_6P) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            if (_boardSize == BIG) {
                return 2.0;
            }
            else if (_boardSize == MEDIUM) {
                return 1.5;
            }
            else if (_boardSize == SMALL) {
                return 1.0;
            }
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            return 1.5;
        }
    }

    return 0.0;
}

- (CGFloat) getSquareSize {
    if (IS_PAD_PRO) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 128.0 - [self getEdgeSize];
                    }
                    return 128.0;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 104.0 - [self getEdgeSize];
                    }
                    return 104.0;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 80.0 - [self getEdgeSize];
                    }
                    return 80.0;
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 114.5 - [self getEdgeSize];
                    }
                    return 114.5;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 94.5 - [self getEdgeSize];
                    }
                    return 94.5;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 74.5 - [self getEdgeSize];
                    }
                    return 74.5;
                default:
                    break;
            }
        }
    }
    else if (IS_PAD) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        //return 92.5;
                        return 96.0 - [self getEdgeSize];
                    }
                    return 96.0;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        //return 68.5;
                        return 72.0 - [self getEdgeSize];
                    }
                    return 72.0;
                case SMALL:
                    if ([self boardWithEdge]) {
                        //return 44.5;
                        return 48.0 - [self getEdgeSize];
                    }
                    return 48.0;
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 82.5 - [self getEdgeSize];
                    }
                    return 82.5;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 61.875 - [self getEdgeSize];
                    }
                    return 61.875;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 41.25 - [self getEdgeSize];
                    }
                    return 41.25;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 40.0 - [self getEdgeSize];
                    }
                    return 40.0;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 30 - [self getEdgeSize];
                    }
                    return 30.0;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 20.0 - [self getEdgeSize];
                    }
                    return 20.0;
                default:
                    break;
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
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return tempSize - [self getEdgeSize];
                    }
                    return tempSize;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return tempSize - [self getEdgeSize];
                    }
                    return tempSize;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return tempSize - [self getEdgeSize];
                    }
                    return tempSize;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 40.0 - [self getEdgeSize];
                    }
                    return 40.0;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 30 - [self getEdgeSize];
                    }
                    return 30.0;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 20.0 - [self getEdgeSize];
                    }
                    return 20.0;
                default:
                    break;
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
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return tempSize - [self getEdgeSize];
                    }
                    return tempSize;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return tempSize - [self getEdgeSize];
                    }
                    return tempSize;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return tempSize - [self getEdgeSize];
                    }
                    return tempSize;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 46.875 - [self getEdgeSize];
                    }
                    return 46.875;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 36.875 - [self getEdgeSize];
                    }
                    return 36.875;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 26.875 - [self getEdgeSize];
                    }
                    return 26.875;
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 38.875 - [self getEdgeSize];
                    }
                    return 38.875;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 38.875 - [self getEdgeSize];
                    }
                    return 38.875;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 38.875 - [self getEdgeSize];
                    }
                    return 38.875;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 51.75 - [self getEdgeSize];
                    }
                    return 51.75;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 41.75 - [self getEdgeSize];
                    }
                    return 41.75;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 31.75 - [self getEdgeSize];
                    }
                    return 31.75;
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 40.75 - [self getEdgeSize];
                    }
                    return 40.75;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 40.75 - [self getEdgeSize];
                    }
                    return 40.75;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 40.75 - [self getEdgeSize];
                    }
                    return 40.75;
                default:
                    break;
            }
        }
    }
    return 0.0;
}

#pragma mark - Metodi per la restituzione di punti o frame per le Nalimov TableBase

- (CGFloat) getSquareSizeNalimov {
    if (IS_PAD_PRO) {
        if (IS_PORTRAIT) {
            return 80.0;
        }
        else {
            return 80.0;
        }
    }
    else if (IS_PAD) {
        if (IS_PORTRAIT) {
            return 65.0;
        }
        else {
            return 65.0;
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            return 38.0;
        }
        else {
            return 40.75;
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            return 36.875;
        }
        else {
            return 30.0;
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            return 30;
        }
        else {
            return 20;
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            return 30.0;
        }
        else {
            return 20.0;
        }
    }
    return 0.0;
}

- (CGFloat) getSquareSizeNalimovLandscape {
    if (IS_PAD_PRO) {
        return 80.0;
    }
    else if (IS_PAD) {
        return 65.0;
    }
    else if (IS_IPHONE_6P) {
        return 40.75;
    }
    else if (IS_IPHONE_6) {
        return 38.875;
    }
    else if (IS_IPHONE_5) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            return 32.0;
        }
        else {
            return 29.5;
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            return 32.0;
        }
        else {
            return 29.5;
        }
    }
    return 0.0;
}

- (CGFloat) getSquareSizeNalimovPortrait {
    if (IS_PAD_PRO) {
        return 80;
    }
    else if (IS_PAD) {
        return 65.0;
    }
    else if (IS_IPHONE_6P) {
        return 38.0;
    }
    else if (IS_IPHONE_6) {
        return 36.875;
    }
    else if (IS_IPHONE_5) {
        return 30.0;
    }
    else if (IS_IPHONE_4_OR_LESS) {
        return 30.0;
    }
    return 0.0;
}

- (CGPoint) getNalimovBoardViewCenter:(CGFloat)dimSquare :(UIDeviceOrientation)deviceOrientation {
    if (IS_PAD) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
        else {
            return CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
    }
    else if (IS_IPHONE_6P) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
        else {
            return CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
    }
    else if (IS_IPHONE_6) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
        else {
            return CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
    }
    else if (IS_IPHONE_5) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
        else {
            return CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
        else {
            return CGPointMake(dimSquare*8/2 + 0.0, dimSquare*8/2 + 0.0);
        }
    }
    return CGPointZero;
}

- (CGRect) getNalimovTableViewFrame:(CGFloat)dimSquare :(UIDeviceOrientation)deviceOrientation {
    if (IS_PAD) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*8+40, 0, 200, dimSquare*8);
        }
        else {
            return CGRectMake(dimSquare*8 + dimSquare*2 + 20, dimSquare*2+10, 150, dimSquare*8 - dimSquare*2 - 80);
        }
    }
    else if (IS_IPHONE_6P) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*8+5+5, 0.0, 95, dimSquare*8);
        }
        else {
            return CGRectMake(dimSquare*8 + dimSquare*6 + 20, 0, 90, dimSquare*4 + 5);
        }
    }
    else if (IS_IPHONE_6) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*8+5, 0, 70, dimSquare*8);
        }
        else {
            return CGRectMake(dimSquare*8 + dimSquare*6 + 20, 0, 90, dimSquare*4 + 5);
        }
    }
    else if (IS_IPHONE_5) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*8+0+5, 0, 70, dimSquare*8);
        }
        else {
            return CGRectMake(dimSquare*8 + dimSquare*6 + 20, 0, 90, dimSquare*4 + 10);
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*8+0+5, 0, 70, dimSquare*8);
        }
        else {
            return CGRectMake(dimSquare*8 + dimSquare*2 + 20, dimSquare*2 + 2, 100, dimSquare*8 - dimSquare*2 - 80);
        }
    }
    return CGRectZero;
}

- (CGRect) getNalimovSelectionViewFrame:(CGFloat)dimSquare :(UIDeviceOrientation)deviceOrientation {
    if (IS_PAD) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare, dimSquare*8 + 10, dimSquare*6, dimSquare*2);
        }
        else {
            return CGRectMake(dimSquare*8 + 10, 0, dimSquare*6, dimSquare*2);
        }
    }
    else if (IS_IPHONE_6P) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*4 - dimSquare*3, dimSquare*8 + 5, dimSquare*6, dimSquare*2);
        }
        else {
            return CGRectMake(dimSquare*8 + 10, 0, dimSquare*6, dimSquare*2);
        }
    }
    else if (IS_IPHONE_6) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*4 - dimSquare*3, dimSquare*8 + 5, dimSquare*6, dimSquare*2);
        }
        else {
            return CGRectMake(dimSquare*8 + 10, 0, dimSquare*6, dimSquare*2);
        }
    }
    else if (IS_IPHONE_5) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*4 - dimSquare*3, dimSquare*8 + 5, dimSquare*6, dimSquare*2);
        }
        else {
            return CGRectMake(dimSquare*8 + 10, 0, dimSquare*6, dimSquare*2);
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*4 - dimSquare*3, dimSquare*8 + 5, dimSquare*6, dimSquare*2);
        }
        else {
            return CGRectMake(dimSquare*8 + 10, 0, dimSquare*6, dimSquare*2);
        }
    }
    return CGRectZero;
}

- (CGRect) getNalimovControlViewFrame:(CGFloat)dimSquare :(UIDeviceOrientation)deviceOrientation {
    if (IS_PAD) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*8 + 40 + 40, dimSquare*8 + 10, dimSquare*2, dimSquare*2);
        }
        else {
            return CGRectMake(dimSquare*8 + 10, dimSquare*2 + 10, dimSquare*2, dimSquare*2);
        }
    }
    else if (IS_IPHONE_6P) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*8 + 20, dimSquare*8 + 5, dimSquare*2, dimSquare*2);
        }
        else {
            return CGRectMake(dimSquare*8 + 10, dimSquare*2 + 2, dimSquare*2, dimSquare*2);
        }
    }
    else if (IS_IPHONE_6) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*8 + 3, dimSquare*8 + 5, dimSquare*2, dimSquare*2);
        }
        else {
            return CGRectMake(dimSquare*8 + 10, dimSquare*2 + 2, dimSquare*2, dimSquare*2);
        }
    }
    else if (IS_IPHONE_5) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*8 + 10, dimSquare*8 + 5, dimSquare*2, dimSquare*2);
        }
        else {
            return CGRectMake(dimSquare*8 + 10, dimSquare*2 + 2, dimSquare*2, dimSquare*2);
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare*8 + 10, dimSquare*8 + 5, dimSquare*2, dimSquare*2);
        }
        else {
            return CGRectMake(dimSquare*8 + 10, dimSquare*2 + 2, dimSquare*2, dimSquare*2);
        }
    }
    return CGRectZero;
}

- (CGRect) getNalimovFenLabelFrame:(CGFloat)dimSquare :(UIDeviceOrientation)deviceOrientation {
    if (IS_PAD) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 25);
        }
        else {
            return CGRectMake(dimSquare*8 + 10, dimSquare*8 - 26, 1024-dimSquare*8-20, 25);
        }
    }
    else if (IS_IPHONE_6P) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 20);
        }
        else {
            return CGRectMake(dimSquare*8 + 17, dimSquare*4 + 15, 736-dimSquare*8 - 23, 15);
        }
    }
    else if (IS_IPHONE_6) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 20);
        }
        else {
            return CGRectMake(dimSquare*8 + 15, dimSquare*4 + 15, 667-dimSquare*8 - 20, 15);
        }
    }
    else if (IS_IPHONE_5) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectMake(dimSquare, dimSquare*8+dimSquare*2+20, dimSquare*8, 20);
        }
        else {
            return CGRectMake(dimSquare*8 + 10, dimSquare*4 + 20, 568-dimSquare*8 - 20, 15);
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            return CGRectZero;
        }
        else {
            return CGRectMake(dimSquare*8, dimSquare*8-73, 480-dimSquare*8, 15);
        }
    }
    return CGRectZero;
}


- (CGFloat) getSquareSize:(UIDeviceOrientation)deviceOrientation {
    if (IS_PAD_PRO) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        //return 92.5;
                        return 128.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 128.0;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        //return 68.5;
                        return 104.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 104.0;
                case SMALL:
                    if ([self boardWithEdge]) {
                        //return 44.5;
                        return 80.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 80.0;
                default:
                    break;
            }
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 114.5 - [self getEdgeSize:deviceOrientation];
                    }
                    return 114.5;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 94.5 - [self getEdgeSize:deviceOrientation];
                    }
                    return 94.5;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 74.5 - [self getEdgeSize:deviceOrientation];
                    }
                    return 74.5;
                default:
                    break;
            }
        }
    }
    else if (IS_PAD) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        //return 92.5;
                        return 96.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 96.0;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        //return 68.5;
                        return 72.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 72.0;
                case SMALL:
                    if ([self boardWithEdge]) {
                        //return 44.5;
                        return 48.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 48.0;
                default:
                    break;
            }
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 82.5 - [self getEdgeSize:deviceOrientation];
                    }
                    return 82.5;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 61.875 - [self getEdgeSize:deviceOrientation];
                    }
                    return 61.875;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 41.25 - [self getEdgeSize:deviceOrientation];
                    }
                    return 41.25;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 40.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 40.0;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 30 - [self getEdgeSize:deviceOrientation];
                    }
                    return 30.0;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 20.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 20.0;
                default:
                    break;
            }
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 28.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 28.0;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 28.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 28.0;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 28.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 28.0;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 40.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 40.0;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 30 - [self getEdgeSize:deviceOrientation];
                    }
                    return 30.0;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 20.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 20.0;
                default:
                    break;
            }
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 28.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 28.0;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 28.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 28.0;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 28.0 - [self getEdgeSize:deviceOrientation];
                    }
                    return 28.0;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 46.875 - [self getEdgeSize];
                    }
                    return 46.875;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 36.875 - [self getEdgeSize];
                    }
                    return 36.875;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 26.875 - [self getEdgeSize];
                    }
                    return 26.875;
                default:
                    break;
            }
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 38.875 - [self getEdgeSize];
                    }
                    return 38.875;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 38.875 - [self getEdgeSize];
                    }
                    return 38.875;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 38.875 - [self getEdgeSize];
                    }
                    return 38.875;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_6P) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 51.75 - [self getEdgeSize];
                    }
                    return 51.75;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 41.75 - [self getEdgeSize];
                    }
                    return 41.75;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 31.75 - [self getEdgeSize];
                    }
                    return 31.75;
                default:
                    break;
            }
        }
        else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            switch (_boardSize) {
                case BIG:
                    if ([self boardWithEdge]) {
                        return 40.75 - [self getEdgeSize];
                    }
                    return 40.75;
                case MEDIUM:
                    if ([self boardWithEdge]) {
                        return 40.75 - [self getEdgeSize];
                    }
                    return 40.75;
                case SMALL:
                    if ([self boardWithEdge]) {
                        return 40.75 - [self getEdgeSize];
                    }
                    return 40.75;
                default:
                    break;
            }
        }
    }
    return 0.0;
}

- (CGFloat) getSquareSizeLandscape {
    if (IS_PAD_PRO) {
        switch (_boardSize) {
            case BIG:
                if ([self boardWithEdge]) {
                    return 114.5 - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return 114.5;
            case MEDIUM:
                if ([self boardWithEdge]) {
                    return 94.5 - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return 94.5;
            case SMALL:
                if ([self boardWithEdge]) {
                    return 74.5 - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return 74.5;
            default:
                break;
        }
    }
    else if (IS_PAD) {
        switch (_boardSize) {
            case BIG:
                if ([self boardWithEdge]) {
                    return 82.5 - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return 82.5;
            case MEDIUM:
                if ([self boardWithEdge]) {
                    return 61.875 - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return 61.875;
            case SMALL:
                if ([self boardWithEdge]) {
                    return 41.25 - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return 41.25;
            default:
                break;
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        CGFloat tempSize = 0.0;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            tempSize = 32.0;
        }
        else {
            tempSize = 29.5;
        }
        switch (_boardSize) {
            case BIG:
                if ([self boardWithEdge]) {
                    return tempSize - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return tempSize;
            case MEDIUM:
                if ([self boardWithEdge]) {
                    return tempSize - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return tempSize;
            case SMALL:
                if ([self boardWithEdge]) {
                    return tempSize - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return tempSize;
            default:
                break;
        }
    }
    else if (IS_IPHONE_5) {
        CGFloat tempSize = 0.0;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            tempSize = 32.0;
        }
        else {
            tempSize = 29.5;
        }
        switch (_boardSize) {
            case BIG:
                if ([self boardWithEdge]) {
                    return tempSize - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return tempSize;
            case MEDIUM:
                if ([self boardWithEdge]) {
                    return tempSize - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return tempSize;
            case SMALL:
                if ([self boardWithEdge]) {
                    return tempSize - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return tempSize;
            default:
                break;
        }
    }
    else if (IS_IPHONE_6) {
        switch (_boardSize) {
            case BIG:
                if ([self boardWithEdge]) {
                    return 38.875 - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return 38.875;
            case MEDIUM:
                if ([self boardWithEdge]) {
                    return 38.875 - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return 38.875;
            case SMALL:
                if ([self boardWithEdge]) {
                    return 38.875 - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return 38.875;
            default:
                break;
        }
    }
    else if (IS_IPHONE_6P) {
        switch (_boardSize) {
            case BIG:
                if ([self boardWithEdge]) {
                    return 40.75 - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return 40.75;
            case MEDIUM:
                if ([self boardWithEdge]) {
                    return 40.75 - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return 40.75;
            case SMALL:
                if ([self boardWithEdge]) {
                    return 40.75 - [self getEdgeSize:UIDeviceOrientationLandscapeLeft];
                }
                return 40.75;
            default:
                break;
        }
    }
    return 0.0;
}

- (CGFloat) getSquareSizePortrait {
    if (IS_PAD_PRO) {
        switch (_boardSize) {
            case BIG:
                return 128.0;
            case MEDIUM:
                return 104.0;
            case SMALL:
                return 80.0;
            default:
                break;
        }
    }
    else if (IS_PAD) {
        switch (_boardSize) {
            case BIG:
                return 96.0;
            case MEDIUM:
                return 72.0;
            case SMALL:
                return 48.0;
            default:
                break;
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        switch (_boardSize) {
            case BIG:
                return 40.0;
            case MEDIUM:
                return 30.0;
            case SMALL:
                return 20.0;
            default:
                break;
        }
    }
    else if (IS_IPHONE_5) {
        switch (_boardSize) {
            case BIG:
                return 40.0;
            case MEDIUM:
                return 30.0;
            case SMALL:
                return 20.0;
            default:
                break;
        }
    }
    else if (IS_IPHONE_6) {
        switch (_boardSize) {
            case BIG:
                return 46.875;
            case MEDIUM:
                return 36.875;
            case SMALL:
                return 26.875;
            default:
                break;
        }
    }
    else if (IS_IPHONE_6P) {
        switch (_boardSize) {
            case BIG:
                return 51.75;
            case MEDIUM:
                return 41.75;
            case SMALL:
                return 31.75;
            default:
                break;
        }
    }
    return 0.0;
}

- (CGFloat) getSquareSizeForPositionSetup {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            return 80.0;
        }
        else {
            return 58.0;
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            return 40.0;
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                return 32.0;
            }
            return 29.5;
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            return 40.0;
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                return 32.0;
            }
            return 29.5;
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            return 46.875;
        }
        else {
            return 38.875;
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            return 51.75;
        }
        else {
            return 40.75;
        }
    }
    return 0.0;
}

- (CGRect) getWebViewFrame {
    
    
    return [self getWebViewFrame2];
    
    CGFloat dimSquare = [self getSquareSize];
    
    //NSLog(@"DIM SQUARE IN GET WEB VIEW FRAME = %f", dimSquare);
    
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                return CGRectMake(0.0, dimSquare*8, 768.0, (768.0 - dimSquare*8) + 110.0);
            }
            else {
                return CGRectMake(0.0, dimSquare*8, 768.0, (768.0 - dimSquare*8) + 148.0);
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                return CGRectMake(dimSquare*8, 0.0, (1024.0 - dimSquare*8), 622.0);
            }
            else {
                return CGRectMake(dimSquare*8, 0.0, (1024.0 - dimSquare*8), 660.0);
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                return CGRectMake(0.0, dimSquare*8, 320.0, (460.0 - dimSquare*8) - 38.0);
            }
            else {
                return CGRectMake(0.0, dimSquare*8, 320.0, (460.0 - dimSquare*8));
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                return CGRectMake(dimSquare*8, 0, (568 - dimSquare*8), (dimSquare*8 - 38.0));
            }
            else {
                return CGRectMake(dimSquare*8, 0, (568 - dimSquare*8), dimSquare*8);
            }
        }
    }
    else if (IS_PHONE) {
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                if (_boardSize == BIG) {
                    return CGRectMake(0.0, dimSquare*8, 320.0, (320.0 - dimSquare*8) + 52.0 - 19.0);
                }
                else {
                    return CGRectMake(0.0, dimSquare*8, 320.0, (320.0 - dimSquare*8) + 52.0 - 38.0);
                }
            }
            else {
                return CGRectMake(0.0, dimSquare*8, 320.0, (320.0 - dimSquare*8) + 52.0);
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                return CGRectMake(dimSquare*8, 0, (480 - dimSquare*8), (dimSquare*8 - 38.0));
            }
            else {
                return CGRectMake(dimSquare*8, 0, (480 - dimSquare*8), dimSquare*8);
            }
        }
    }
    
    return CGRectZero;
}

- (CGFloat) getFixedSquareSize {
    if (IS_PAD_PRO) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    return 128.0;
                case MEDIUM:
                    return 104.0;
                case SMALL:
                    return 80.0;
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    return 114.5;
                case MEDIUM:
                    return 94.5;
                case SMALL:
                    return 74.5;
                default:
                    break;
            }
        }
    }
    else if (IS_PAD) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    return 96.0;
                case MEDIUM:
                    return 72.0;
                case SMALL:
                    return 48.0;
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    return 82.5;
                case MEDIUM:
                    return 61.875;
                case SMALL:
                    return 41.25;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    return 40.0;
                case MEDIUM:
                    return 30.0;
                case SMALL:
                    return 20.0;
                default:
                    break;
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
            switch (_boardSize) {
                case BIG:
                    return tempSize;
                case MEDIUM:
                    return tempSize;
                case SMALL:
                    return tempSize;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    return 40.0;
                case MEDIUM:
                    return 30.0;
                case SMALL:
                    return 20.0;
                default:
                    break;
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
            switch (_boardSize) {
                case BIG:
                    return tempSize;
                case MEDIUM:
                    return tempSize;
                case SMALL:
                    return tempSize;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    return 46.875;
                case MEDIUM:
                    return 36.875;
                case SMALL:
                    return 26.875;
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    return 38.875;
                case MEDIUM:
                    return 38.875;
                case SMALL:
                    return 38.875;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    return 51.75;
                case MEDIUM:
                    return 41.75;
                case SMALL:
                    return 31.75;
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    return 40.75;
                case MEDIUM:
                    return 40.75;
                case SMALL:
                    return 40.75;
                default:
                    break;
            }
        }
    }
    return 0.0;
    
}

- (CGFloat) getFixedSquareSize:(UIDeviceOrientation)deviceOrientation {
    if (IS_PAD_PRO) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            switch (_boardSize) {
                case BIG:
                    return 128.0;
                case MEDIUM:
                    return 104.0;
                case SMALL:
                    return 80.0;
                default:
                    break;
            }
        }
        else if ((deviceOrientation == UIDeviceOrientationLandscapeLeft)||(deviceOrientation == UIDeviceOrientationLandscapeRight)) {
            switch (_boardSize) {
                case BIG:
                    return 114.5;
                case MEDIUM:
                    return 94.5;
                case SMALL:
                    return 74.5;
                default:
                    break;
            }
        }
    }
    else if (IS_PAD) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            switch (_boardSize) {
                case BIG:
                    return 96.0;
                case MEDIUM:
                    return 72.0;
                case SMALL:
                    return 48.0;
                default:
                    break;
            }
        }
        else if ((deviceOrientation == UIDeviceOrientationLandscapeLeft)||(deviceOrientation == UIDeviceOrientationLandscapeRight)) {
            switch (_boardSize) {
                case BIG:
                    return 82.5;
                case MEDIUM:
                    return 61.875;
                case SMALL:
                    return 41.25;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            switch (_boardSize) {
                case BIG:
                    return 40.0;
                case MEDIUM:
                    return 30.0;
                case SMALL:
                    return 20.0;
                default:
                    break;
            }
        }
        else if ((deviceOrientation == UIDeviceOrientationLandscapeLeft)||(deviceOrientation == UIDeviceOrientationLandscapeRight)) {
            CGFloat tempSize = 0.0;
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                tempSize = 32.0;
            }
            else {
                tempSize = 29.5;
            }
            switch (_boardSize) {
                case BIG:
                    return tempSize;
                case MEDIUM:
                    return tempSize;
                case SMALL:
                    return tempSize;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            switch (_boardSize) {
                case BIG:
                    return 40.0;
                case MEDIUM:
                    return 30.0;
                case SMALL:
                    return 20.0;
                default:
                    break;
            }
        }
        else if ((deviceOrientation == UIDeviceOrientationLandscapeLeft)||(deviceOrientation == UIDeviceOrientationLandscapeRight)) {
            CGFloat tempSize = 0.0;
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                tempSize = 32.0;
            }
            else {
                tempSize = 29.5;
            }
            switch (_boardSize) {
                case BIG:
                    return tempSize;
                case MEDIUM:
                    return tempSize;
                case SMALL:
                    return tempSize;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            switch (_boardSize) {
                case BIG:
                    return 46.875;
                case MEDIUM:
                    return 36.875;
                case SMALL:
                    return 26.875;
                default:
                    break;
            }
        }
        else if ((deviceOrientation == UIDeviceOrientationLandscapeLeft)||(deviceOrientation == UIDeviceOrientationLandscapeRight)) {
            switch (_boardSize) {
                case BIG:
                    return 38.875;
                case MEDIUM:
                    return 38.875;
                case SMALL:
                    return 38.875;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_6P) {
        if (deviceOrientation == UIDeviceOrientationPortrait) {
            switch (_boardSize) {
                case BIG:
                    return 51.75;
                case MEDIUM:
                    return 41.75;
                case SMALL:
                    return 31.75;
                default:
                    break;
            }
        }
        else if ((deviceOrientation == UIDeviceOrientationLandscapeLeft)||(deviceOrientation == UIDeviceOrientationLandscapeRight)) {
            switch (_boardSize) {
                case BIG:
                    return 40.75;
                case MEDIUM:
                    return 40.75;
                case SMALL:
                    return 40.75;
                default:
                    break;
            }
        }
    }
    return 0.0;
}


- (CGRect) getNalimovWebViewFrame {
    if (IS_PAD_PRO) {
        if (IS_PORTRAIT) {
            return CGRectMake(0.0, 850.0, 1024.0, 408.0);  //408 = 1366 - 850 - 20 - 88
        }
        else {
            return CGRectMake(0.0, 641, 1366, 1024 - 641 - 20 - 44 - 44);
        }
    }
    else if (IS_PAD) {
        if (IS_PORTRAIT) {
            return CGRectMake(0.0, 700.0, 768.0, 216.0);
        }
        else {
            return CGRectMake(0.0, 521, 1023, 138);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            return CGRectMake(0.0, 428.0, 414, 200);
        }
        else {
            CGFloat sq = [self getSquareSizeNalimovLandscape];
            return CGRectMake(sq*8, sq*8-122, 736-sq*8, 122);
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            return CGRectMake(0.0, 420.0, 375, 139.0);
        }
        else {
            CGFloat sq = [self getSquareSizeNalimovLandscape];
            return CGRectMake(sq*8, sq*8-120, 667-sq*8, 120);
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            return CGRectMake(0.0, 350.0, 320, 110.0);
        }
        else {
            CGFloat sq = [self getSquareSizeNalimovLandscape];
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                return CGRectMake(sq*8, sq*8-90, 568-sq*8, 90);
            }
            return CGRectMake(sq*8, sq*8-80, 568-sq*8, 80);
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            return CGRectMake(0.0, 312.0, 320, 60.0);
        }
        else {
            CGFloat sq = [self getSquareSizeNalimovLandscape];
            return CGRectMake(sq*8, sq*8-55, 480-sq*8, 55);
        }
    }
    return CGRectZero;
}

- (CGRect) getWebViewFrame2 {
    CGFloat dimSquare = [self getFixedSquareSize];
    
    //NSLog(@"DIM SQUARE IN GET WEB VIEW FRAME = %f", dimSquare);
    
    if (IS_PAD_PRO) {
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                
                return CGRectMake(0.0, dimSquare*8, 1024.0, (1366.0 - dimSquare*8) - 38.0 - 108.0);
                
                //                if (_boardSize == BIG) {
                //                    return CGRectMake(0.0, dimSquare*8, 1024.0, (1366.0 - dimSquare*8) - 38.0 - 108.0);
                //                }
                //                else if (_boardSize == MEDIUM) {
                //                    return CGRectMake(0.0, dimSquare*8, 1024.0, (1366.0 - dimSquare*8) - 38.0 - 108.0);
                //                }
                //                else if (_boardSize == SMALL) {
                //                    return CGRectMake(0.0, dimSquare*8, 1024.0, (1366.0 - dimSquare*8) - 38.0 - 108.0);
                //                }
            }
            else {
                return CGRectMake(0.0, dimSquare*8, 1024.0, (1366.0 - dimSquare*8) - 108.0);
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                return CGRectMake(dimSquare*8, 0.0, (1366.0 - dimSquare*8), 878.0);
            }
            else {
                return CGRectMake(dimSquare*8, 0.0, (1366.0 - dimSquare*8), 916.0);
            }
        }
    }
    else if (IS_PAD) {
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                if (_boardSize == BIG) {
                    return CGRectMake(0.0, dimSquare*8, 768.0, (768.0 - dimSquare*8) + 110.0);
                }
                else if (_boardSize == MEDIUM) {
                    return CGRectMake(0.0, dimSquare*8, 768.0, (768.0 - dimSquare*8) + 110.0);
                }
                else if (_boardSize == SMALL) {
                    return CGRectMake(0.0, dimSquare*8, 768.0, (768.0 - dimSquare*8) + 110.0);
                }
            }
            else {
                return CGRectMake(0.0, dimSquare*8, 768.0, (768.0 - dimSquare*8) + 148.0);
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                return CGRectMake(dimSquare*8, 0.0, (1024.0 - dimSquare*8), 622.0);
            }
            else {
                return CGRectMake(dimSquare*8, 0.0, (1024.0 - dimSquare*8), 660.0);
            }
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                if (_boardSize == BIG) {
                    return CGRectMake(0.0, dimSquare*8, 320.0, (320.0 - dimSquare*8) + 52.0 - 19.0);
                }
                else {
                    return CGRectMake(0.0, dimSquare*8, 320.0, (320.0 - dimSquare*8) + 52.0 - 38.0);
                }
            }
            else {
                return CGRectMake(0.0, dimSquare*8, 320.0, (320.0 - dimSquare*8) + 52.0);
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                return CGRectMake(dimSquare*8, 0, (480 - dimSquare*8), (dimSquare*8 - 38.0));
            }
            else {
                return CGRectMake(dimSquare*8, 0, (480 - dimSquare*8), dimSquare*8);
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                return CGRectMake(0.0, dimSquare*8, 320.0, (460.0 - dimSquare*8) - 38.0);
            }
            else {
                return CGRectMake(0.0, dimSquare*8, 320.0, (460.0 - dimSquare*8));
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                return CGRectMake(dimSquare*8, 0, (568 - dimSquare*8), (dimSquare*8 - 38.0));
            }
            else {
                return CGRectMake(dimSquare*8, 0, (568 - dimSquare*8), dimSquare*8);
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                return CGRectMake(0.0, dimSquare*8, 375.0, (559 - dimSquare*8) - 38);
            }
            else {
                return CGRectMake(0.0, dimSquare*8, 375, (559 - dimSquare*8));
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                return CGRectMake(dimSquare*8, 0, (667 - dimSquare*8), (dimSquare*8 - 38.0));
            }
            else {
                return CGRectMake(dimSquare*8, 0, (667 - dimSquare*8), dimSquare*8);
            }
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                return CGRectMake(0.0, dimSquare*8, 414.0, (628 - dimSquare*8) - 38);
            }
            else {
                return CGRectMake(0.0, dimSquare*8, 414, (628 - dimSquare*8));
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                return CGRectMake(dimSquare*8, 0, (736 - dimSquare*8), (dimSquare*8 - 38.0));
            }
            else {
                return CGRectMake(dimSquare*8, 0, (736 - dimSquare*8), dimSquare*8);
            }
        }
    }
    return CGRectZero;
}



- (UIFont *) getFontForCoordinates {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
                    break;
                case MEDIUM:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(8.0)];
                case SMALL:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(6.0)];;
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
                    break;
                case MEDIUM:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(10.0)];
                case SMALL:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(8.0)];;
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(8.0)];
                    break;
                case MEDIUM:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(6.0)];
                case SMALL:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(4.0)];
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(5.0)];
                    break;
                case MEDIUM:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(5.0)];
                case SMALL:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(5.0)];
                default:
                    break;
            }
        }
    }
    else if (IS_PHONE) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(7.0)];
                    break;
                case MEDIUM:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(5.0)];
                case SMALL:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(3.0)];
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(5.0)];
                    break;
                case MEDIUM:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(5.0)];
                case SMALL:
                    return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(5.0)];
                default:
                    break;
            }
        }
    }

    return nil;
}

- (CGRect) getFrameForCoordinates {
    CGFloat dimSquare = [self getSquareSize];
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    return CGRectMake(0, dimSquare - 11, 20, 10);
                    break;
                case MEDIUM:
                    return CGRectMake(0, dimSquare - 11, 15, 10);
                case SMALL:
                    return CGRectMake(0, dimSquare - 9, 10, 10);
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    return CGRectMake(0, dimSquare - 11, 20, 10);
                    break;
                case MEDIUM:
                    return CGRectMake(0, dimSquare - 11, 20, 10);
                case SMALL:
                    return CGRectMake(0, dimSquare - 11, 12, 10);
                default:
                    break;
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    return CGRectMake(0, dimSquare - 10, 11, 9);
                    break;
                case MEDIUM:
                    return CGRectMake(0, dimSquare - 8, 8, 10);
                case SMALL:
                    return CGRectMake(0, dimSquare - 7, 7, 9);
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    return CGRectMake(0, dimSquare - 8, 8, 10);
                    break;
                case MEDIUM:
                    return CGRectMake(0, dimSquare - 8, 8, 10);
                case SMALL:
                    return CGRectMake(0, dimSquare - 8, 8, 10);
                default:
                    break;
            }
        }
    }
    else if (IS_PHONE) {
        if (IS_PORTRAIT) {
            switch (_boardSize) {
                case BIG:
                    return CGRectMake(0, dimSquare - 10, 11, 9);
                    break;
                case MEDIUM:
                    return CGRectMake(0, dimSquare - 8, 8, 10);
                case SMALL:
                    return CGRectMake(0, dimSquare - 7, 7, 9);
                default:
                    break;
            }
        }
        else if (IS_LANDSCAPE) {
            switch (_boardSize) {
                case BIG:
                    return CGRectMake(0, dimSquare - 8, 8, 10);
                    break;
                case MEDIUM:
                    return CGRectMake(0, dimSquare - 8, 8, 10);
                case SMALL:
                    return CGRectMake(0, dimSquare - 8, 8, 10);
                default:
                    break;
            }
        }
    }
    return CGRectZero;
}

#pragma mark - Metodi per la restituzione dei frame e dei Font per Nalimov Board

- (UIFont *) getFontForNalimovCoordinates {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(10.0)];
        }
        else {
            return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(10.0)];
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(8.0)];
        }
        else {
            return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(8.0)];
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(7.0)];
        }
        else {
            return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(7.0)];
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(5.0)];
        }
        else {
            return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(5.0)];
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(5.0)];
        }
        else {
            return [UIFont fontWithName:@"Arial Rounded MT Bold" size:(5.0)];
        }
    }
    return nil;
}

- (CGRect) getFrameForNalimovCoordinates:(CGFloat)dimSquare {
    //CGFloat dimSquare = 0.0;
    if (IS_PORTRAIT) {
        //dimSquare = [self getSquareSizeNalimovPortrait];
    }
    else {
        //dimSquare = [self getSquareSizeNalimovLandscape];
    }
    //CGFloat dimSquare = [self getSquareSizeNalimov];
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            return CGRectMake(1, dimSquare - 10, 15, 10);
        }
        else {
            return CGRectMake(1, dimSquare - 10, 15, 10);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            return CGRectMake(1, dimSquare - 10, 15, 10);
        }
        else {
            return CGRectMake(1, dimSquare - 10, 15, 10);
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            return CGRectMake(1, dimSquare - 9, 15, 10);
        }
        else {
            return CGRectMake(1, dimSquare - 9, 15, 10);
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            return CGRectMake(1, dimSquare - 8, 8, 10);
        }
        else {
            return CGRectMake(1, dimSquare - 8, 8, 10);
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            return CGRectMake(1, dimSquare - 8, 8, 10);
        }
        else {
            return CGRectMake(1, dimSquare - 8, 8, 10);
        }
    }
    return CGRectZero;
}



#pragma mark - Metodi per la restituzione dei frame introdotti a partire dal 12 Gennaio 2015

- (CGRect) getViewRectForBoard:(UIDeviceOrientation)deviceOrientation {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            return CGRectMake(0, 64, 768.0, [self getSquareSize]*8);
        }
        else {
            return CGRectMake(0, 64, [self getSquareSize]*8, 660.0);
        }
    }
    
    if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            return CGRectMake(0, 64, 375, [self getSquareSize]*8);
        }
        else {
            return CGRectMake(0, 32, [self getSquareSize]*8, 311);
        }
    }
    
    if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            return CGRectMake(0, 64, 414, [self getSquareSize]*8);
        }
        else {
            return CGRectMake(0, 32, [self getSquareSize]*8, 350);
        }
    }
    
    if (IS_PHONE) {
        if (IS_PORTRAIT) {
            return CGRectMake(0, 64, 320, [self getSquareSize]*8);
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                return CGRectMake(0, 32, 256, 256);
            }
            return CGRectMake(0, 52, 236, 236);
        }
    }
    
    return CGRectZero;
}

- (CGRect) getViewRectForWebMoves:(UIDeviceOrientation)deviceOrientation {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                return CGRectMake(0.0, [self getSquareSizePortrait]*8 + 64, 768.0, 916 - [self getSquareSizePortrait]*8 - 38);
            }
            else {
                return CGRectMake(0.0, [self getSquareSizePortrait]*8 + 64, 768.0, 916 - [self getSquareSizePortrait]*8);
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                return CGRectMake([self getSquareSize]*8, 64, 1024 - [self getSquareSize], 622);
            }
            else {
                return CGRectMake([self getSquareSize]*8, 64, 1024 - [self getSquareSize], 660);
            }
        }
    }
    
    if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                return CGRectMake(0.0, [self getSquareSizePortrait]*8 + 64, 375.0, 559 - [self getSquareSizePortrait]*8 - 38);
            }
            else {
                return CGRectMake(0, [self getSquareSizePortrait]*8 + 64, 375, 559 - [self getSquareSizePortrait]*8);
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                return CGRectMake(311, 32, 667 - 311, 311 - 38);
            }
            else {
                return CGRectMake(311, 32, 667 - 311, 311);
            }
        }
    }
    
    if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                return CGRectMake(0.0, [self getSquareSizePortrait]*8 + 64, 414.0, 628 - [self getSquareSizePortrait]*8 - 38);
            }
            else {
                return CGRectMake(0, [self getSquareSizePortrait]*8 + 64, 414, 672 - [self getSquareSizePortrait]*8);
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                return CGRectMake(350, 32, 736 - 350, 350 - 38);
            }
            else {
                return CGRectMake(350, 32, 736 - 350, 350);
            }
        }
    }
    
    if (IS_IPHONE_5) {
        NSLog(@"HO TROVATO iPHONE 5");
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                return CGRectMake(0.0, [self getSquareSizePortrait]*8 + 64, 320.0, 460 - [self getSquareSizePortrait]*8 - 38);
            }
            else {
                return CGRectMake(0, [self getSquareSizePortrait]*8 + 64, 320, 460 - [self getSquareSizePortrait]*8);
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    return CGRectMake(256, 32, 568 - 256, 256 - 38);
                }
                return CGRectMake(236, 52, 568 - 236, 236 - 38);
            }
            else {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    return CGRectMake(256, 32, 568 - 256, 256);
                }
                return CGRectMake(236, 52, 568 - 236, 236);
            }
        }
    }
    
    if (IS_IPHONE_4_OR_LESS) {
        NSLog(@"HO TROVATO iPHONE");
        if (IS_PORTRAIT) {
            if ([self isEngineViewOpen]) {
                if ([self boardSize] == BIG) {
                    return CGRectMake(0.0, [self getSquareSizePortrait]*8 + 64, 320.0, 372 - [self getSquareSizePortrait]*8 - 19);
                }
                return CGRectMake(0.0, [self getSquareSizePortrait]*8 + 64, 320.0, 372 - [self getSquareSizePortrait]*8 - 38);
            }
            else {
                return CGRectMake(0, [self getSquareSizePortrait]*8 + 64, 320, 372 - [self getSquareSizePortrait]*8);
            }
        }
        else {
            if ([self isEngineViewOpen]) {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    return CGRectMake(256, 32, 480 - 256, 256 - 38);
                }
                return CGRectMake(236, 52, 480 - 236, 236 - 38);
            }
            else {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    return CGRectMake(256, 32, 480 - 256, 256);
                }
                return CGRectMake(236, 52, 480 - 236, 236);
            }
        }
    }
    return CGRectZero;
}

- (CGRect) getViewRectForEngine:(UIDeviceOrientation)deviceOrientation {
    if ([self isEngineViewClosed]) {
        return CGRectZero;
    }
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            return CGRectMake(0.0, 916 - 38 + 64, 768.0, 38.0);
        }
        else {
            return CGRectMake([self getSquareSize]*8, 686, 1024 - [self getSquareSize], 38.0);
        }
    }
    
    if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            return CGRectMake(0.0, 559 - 38 + 64, 375, 38.0);
        }
        else {
            return CGRectMake(311, 375-38-32, 667 - [self getSquareSize], 38.0);
        }
    }
    
    if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            return CGRectMake(0.0, 628 - 38 + 64, 414, 38.0);
        }
        else {
            return CGRectMake(350, 414-38-32, 628 - [self getSquareSize], 38.0);
        }
    }
    
    if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            return CGRectMake(0.0, 460 - 38 + 64, 320, 38.0);
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                return CGRectMake(256, 320 - 38 - 32, 568 - 256, 38);
            }
            return CGRectMake(236, 320-38-32, 568 - [self getSquareSize], 38.0);
        }
    }

    if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            if ([self boardSize] == BIG) {
                return CGRectMake(0.0, 372 - 19 + 64, 320.0, 19);
            }
            return CGRectMake(0.0, 372 - 38 + 64, 320, 38.0);
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                return CGRectMake(256, 320 - 38 - 32, 480 - 256, 38);
            }
            return CGRectMake(236, 320 - 38 - 32, 480 - [self getSquareSize], 38.0);
        }
    }
    
    return CGRectZero;
}


- (UIColor *) getSelectedColorHighLight {
    if ([_colorHighLight isEqualToString:NSLocalizedString(@"ORANGE", nil)]) {
        return [UIColor orangeColor];
    }
    else if ([_colorHighLight isEqualToString:NSLocalizedString(@"WHITE", nil)]) {
        return [UIColor whiteColor];
    }
    else if ([_colorHighLight isEqualToString:NSLocalizedString(@"BLACK", nil)]) {
        return [UIColor blackColor];
    }
    else if ([_colorHighLight isEqualToString:NSLocalizedString(@"YELLOW", nil)]) {
        return [UIColor yellowColor];
    }
    else if ([_colorHighLight isEqualToString:NSLocalizedString(@"RED", nil)]) {
        return [UIColor redColor];
    }
    else if ([_colorHighLight isEqualToString:NSLocalizedString(@"GREEN", nil)]) {
        return [UIColor greenColor];
    }
    else if ([_colorHighLight isEqualToString:NSLocalizedString(@"BLUE", nil)]) {
        return [UIColor blueColor];
    }
    return nil;
}

- (UIColor *) getselectedColorTapDestination {
    if ([_colorTapDestination isEqualToString:NSLocalizedString(@"ORANGE", nil)]) {
        return [UIColor orangeColor];
    }
    else if ([_colorTapDestination isEqualToString:NSLocalizedString(@"WHITE", nil)]) {
        return [UIColor whiteColor];
    }
    else if ([_colorTapDestination isEqualToString:NSLocalizedString(@"BLACK", nil)]) {
        return [UIColor blackColor];
    }
    else if ([_colorTapDestination isEqualToString:NSLocalizedString(@"YELLOW", nil)]) {
        return [UIColor yellowColor];
    }
    else if ([_colorTapDestination isEqualToString:NSLocalizedString(@"RED", nil)]) {
        return [UIColor redColor];
    }
    else if ([_colorTapDestination isEqualToString:NSLocalizedString(@"GREEN", nil)]) {
        return [UIColor greenColor];
    }
    else if ([_colorTapDestination isEqualToString:NSLocalizedString(@"BLUE", nil)]) {
        return [UIColor blueColor];
    }
    return nil;
}

- (CGFloat) circleCornerRadius {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 10.0;
            }
            else if (_boardSize == MEDIUM) {
                return 8.0;
            }
            else if (_boardSize == SMALL) {
                return 5.0;
            }
        }
        else {
            if (_boardSize == BIG) {
                return 10.0;
            }
            else if (_boardSize == MEDIUM) {
                return 8.0;
            }
            else if (_boardSize == SMALL) {
                return 5.0;
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 8.0;
            }
            else if (_boardSize == MEDIUM) {
                return 6.0;
            }
            else if (_boardSize == SMALL) {
                return 4.0;
            }
        }
        else {
            return 6.0;
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 8.0;
            }
            else if (_boardSize == MEDIUM) {
                return 6.0;
            }
            else if (_boardSize == SMALL) {
                return 4.0;
            }
        }
        else {
            return 6.0;
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 8.0;
            }
            else if (_boardSize == MEDIUM) {
                return 6.0;
            }
            else if (_boardSize == SMALL) {
                return 4.0;
            }
        }
        else {
            return 5.0;
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 6.0;
            }
            else if (_boardSize == MEDIUM) {
                return 5.0;
            }
            else if (_boardSize == SMALL) {
                return 4.0;
            }
        }
        else {
            return 5.0;
        }
    }
    
    return 8.0;
}

- (CGRect) circleRect {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return CGRectMake(20.0, 20.0, 20.0, 20.0);
            }
            else if (_boardSize == MEDIUM) {
                return CGRectMake(15.0, 15.0, 15.0, 15.0);
            }
            else if (_boardSize == SMALL) {
                return CGRectMake(10.0, 10.0, 10.0, 10.0);
            }
        }
        else {
            if (_boardSize == BIG) {
                return CGRectMake(18.0, 18.0, 18.0, 18.0);
            }
            else if (_boardSize == MEDIUM) {
                return CGRectMake(13.0, 13.0, 13.0, 13.0);
            }
            else if (_boardSize == SMALL) {
                return CGRectMake(8.0, 8.0, 8.0, 8.0);
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return CGRectMake(13.0, 13.0, 13.0, 13.0);
            }
            else if (_boardSize == MEDIUM) {
                return CGRectMake(9.0, 9.0, 9.0, 9.0);
            }
            else if (_boardSize == SMALL) {
                return CGRectMake(6.0, 6.0, 6.0, 6.0);
            }
        }
        else {
            return CGRectMake(10.0, 10.0, 10.0, 10.0);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return CGRectMake(13.0, 13.0, 13.0, 13.0);
            }
            else if (_boardSize == MEDIUM) {
                return CGRectMake(9.0, 9.0, 9.0, 9.0);
            }
            else if (_boardSize == SMALL) {
                return CGRectMake(6.0, 6.0, 6.0, 6.0);
            }
        }
        else {
            return CGRectMake(10.0, 10.0, 10.0, 10.0);
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return CGRectMake(11.0, 11.0, 11.0, 11.0);
            }
            else if (_boardSize == MEDIUM) {
                return CGRectMake(8.0, 8.0, 8.0, 8.0);
            }
            else if (_boardSize == SMALL) {
                return CGRectMake(6.0, 6.0, 6.0, 6.0);
            }
        }
        else {
            return CGRectMake(8.0, 8.0, 8.0, 8.0);
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return CGRectMake(10.0, 10.0, 10.0, 10.0);
            }
            else if (_boardSize == MEDIUM) {
                return CGRectMake(7.0, 7.0, 7.0, 7.0);
            }
            else if (_boardSize == SMALL) {
                return CGRectMake(6.0, 6.0, 6.0, 6.0);
            }
        }
        else {
            return CGRectMake(7.0, 7.0, 7.0, 7.0);
        }
    }
    
    return CGRectMake(20.0, 20.0, 20.0, 20.0);
}

- (CGFloat) borderSelected {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 3.0;
            }
            else if (_boardSize == MEDIUM) {
                return 3.0;
            }
            else if (_boardSize == SMALL) {
                return 3.0;
            }
        }
        else {
            if (_boardSize == BIG) {
                return 3.0;
            }
            else if (_boardSize == MEDIUM) {
                return 3.0;
            }
            else if (_boardSize == SMALL) {
                return 2.0;
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 3.0;
            }
            else if (_boardSize == MEDIUM) {
                return 2.0;
            }
            else if (_boardSize == SMALL) {
                return 2.0;
            }
        }
        else {
            return 2.0;
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 3.0;
            }
            else if (_boardSize == MEDIUM) {
                return 2.0;
            }
            else if (_boardSize == SMALL) {
                return 2.0;
            }
        }
        else {
            return 2.0;
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 2.0;
            }
            else if (_boardSize == MEDIUM) {
                return 1.5;
            }
            else if (_boardSize == SMALL) {
                return 1.0;
            }
        }
        else {
            return 1.5;
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            if (_boardSize == BIG) {
                return 2.0;
            }
            else if (_boardSize == MEDIUM) {
                return 1.5;
            }
            else if (_boardSize == SMALL) {
                return 1.0;
            }
        }
        else {
            return 1.5;
        }
    }
    
    return 8.0;
}


@end
