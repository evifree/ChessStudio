//
//  UtilToView.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 22/04/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilToView : NSObject


+ (CGSize) getSizeOfMBProgress;
+ (UIStoryboard *) getStoryBoard;

+ (NSString *)machine;
+ (NSString *)deviceModelName;


+ (NSArray *) getTipoPezziArray;
+ (NSArray *) getTipoCoordinate;
+ (NSArray *) getTipoSquares;
+ (NSArray *) getTipoNotation;
+ (NSArray *) getVistaMotore;
+ (NSArray *) getTipoBoardSize;
+ (NSArray *) getSevenTagRoster;
+ (NSString *) getTagRosterByIndex:(NSUInteger)index;
+ (NSString *) getTagRosterDefaultValueByIndex:(NSUInteger)index;
+ (NSArray *) getResultsArray;
+ (NSArray *) getAdditionalTagArray;
+ (NSArray *) getAdditionalTagSection;
+ (NSDictionary *) getAdditionalTagSectionValues;
+ (NSDictionary *) getSupplementalTagSectionValues;
+ (NSArray *) getTitleArray;
+ (NSArray *) getSupplementalTagValues;

+ (NSArray *) getEcoLetterArray;
+ (NSArray *) getEcoNumberArray;

+ (NSArray *) getMoveAnnotationText;
+ (NSArray *) getMoveAnnotationImage;
+ (NSArray *) getPositionAnnotationText;
+ (NSArray *) getPositionAnnotationImage;
+ (NSArray *) getPrefixAnnotationText;
+ (NSArray *) getPrefixAnnotationImage;
+ (UIColor *) getEcoColor:(NSString *)ecoCode;

+ (CGRect) getRectByDevice;

+ (NSString *) getPieceSetupPositionByNumber:(NSInteger)squareNumber;

+ (NSString *) getPieceType;
+ (NSString *) getSquareType;
+ (UIImage *) getDarkImageForSquare:(NSString *)squareType;
+ (UIImage *) getLightImageForSquare:(NSString *)squareType;


+ (CGRect) getPadPortraitEngineViewFrame;
+ (CGRect) getPadPortraitMovesFrameWithEngine;
+ (CGRect) getPadPortraitMovesFrameWithoutEngine;
+ (CGRect) getPadPortraitEngineFrame;
+ (CGRect) getPadPortraitStatsEngineFrame;

+ (CGRect) getPhone5PortraitEngineViewFrame;

+ (NSArray *) getEngines;

+ (NSArray *) getOrderedSevenTags;
+ (NSArray *) getOrderedSuppTags;
+ (NSArray *) getPositionTags;

@end
