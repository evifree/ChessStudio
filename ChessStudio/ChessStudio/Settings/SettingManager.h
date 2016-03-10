//
//  SettingManager.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 05/02/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Options.h"
#import "Reachability.h"

@interface SettingManager : NSObject


+ (id) sharedSettingManager;


@property (nonatomic, strong) NSString *pieceType;
@property (nonatomic, strong) NSString *squares;
@property (nonatomic, strong) NSString *coordinate;
@property (nonatomic, strong) NSString *notation;
@property (nonatomic, assign) enum BoardSize boardSize;
@property (nonatomic, strong) NSString *vistaMotore;
@property (nonatomic, assign) BOOL engineFigurineNotation;
@property (nonatomic, readonly) BOOL isFigurineNotation;
@property (nonatomic, readonly) BOOL isLetterNotation;
@property (nonatomic, readonly) BOOL isEngineViewOpen;
@property (nonatomic, readonly) BOOL isEngineViewClosed;
@property (nonatomic, assign) BOOL showBookMoves;
@property (nonatomic, assign) BOOL showEco;
@property (nonatomic, assign) BOOL boardWithEdge;
@property (nonatomic, assign) BOOL dragAndDrop;
@property (nonatomic, assign) BOOL tapPieceToMove;
@property (nonatomic, assign) BOOL tapDestination;
@property (nonatomic, assign) BOOL showLegalMoves;
@property (nonatomic, strong) NSString *colorHighLight;
@property (nonatomic) CGFloat circleCornerRadius;
@property (nonatomic) CGRect  circleRect;
@property (nonatomic) CGFloat borderSelected;
@property (nonatomic, strong) NSString *colorTapDestination;
@property (nonatomic, assign) BOOL iCloudOn;
@property (nonatomic, assign) BOOL ecoBoardPreviewHintDisplayed;


- (NSString *) boardSizeAsString;
- (NSString *) pieceTypeAsString;
- (NSString *) squaresAsString;
- (NSString *) squaresAsString:(NSString *)square;
- (NSString *) coordinatesAsString;

- (UIImage *) getDarkSquare;
- (UIImage *) getLightSquare;
- (NSString *) getPieceTypeToLoad;

- (CGFloat) getSquareSize;
- (CGFloat) getSquareSize:(UIDeviceOrientation)deviceOrientation;
- (CGFloat) getSquareSizeLandscape;
- (CGFloat) getSquareSizePortrait;
- (CGFloat) getFixedSquareSize:(UIDeviceOrientation)deviceOrientation;
- (CGFloat) getSquareSizeForPositionSetup;
- (CGRect) getWebViewFrame;

- (UIFont *) getFontForCoordinates;
- (CGRect) getFrameForCoordinates;

- (UIFont *) getFontForNalimovCoordinates;
- (CGRect) getFrameForNalimovCoordinates:(CGFloat)dimSquare;

- (void) addEmailRecipients:(NSDictionary *)emailRecipients;
- (NSString *)getListaEmailRecipients;
- (NSArray *)getRecipients;


- (UIColor *) getSelectedColorHighLight;
- (UIColor *) getselectedColorTapDestination;



- (CGRect) getViewRectForBoard:(UIDeviceOrientation)deviceOrientation;
- (CGRect) getViewRectForWebMoves:(UIDeviceOrientation)deviceOrientation;
- (CGRect) getViewRectForEngine:(UIDeviceOrientation)deviceOrientation;


- (CGFloat) getSquareSizeNalimov;
- (CGFloat) getSquareSizeNalimovLandscape;
- (CGFloat) getSquareSizeNalimovPortrait;
- (CGRect) getNalimovWebViewFrame;
- (CGPoint) getNalimovBoardViewCenter:(CGFloat)dimSquare :(UIDeviceOrientation)deviceOrientation;
- (CGRect) getNalimovTableViewFrame:(CGFloat)dimSquare :(UIDeviceOrientation)deviceOrientation;
- (CGRect) getNalimovSelectionViewFrame:(CGFloat)dimSquare :(UIDeviceOrientation)deviceOrientation;
- (CGRect) getNalimovControlViewFrame:(CGFloat)dimSquare :(UIDeviceOrientation)deviceOrientation;
- (CGRect) getNalimovFenLabelFrame:(CGFloat)dimSquare :(UIDeviceOrientation)deviceOrientation;

@end
