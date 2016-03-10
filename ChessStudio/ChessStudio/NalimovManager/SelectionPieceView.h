//
//  SelectionPieceView.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 07/07/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingManager.h"
#import "UtilToView.h"


@protocol SelectionPieceViewDelegate <NSObject>

- (void) selection:(NSString *)pezzo;

@end

@interface SelectionPieceView : UIView

@property (nonatomic, assign) id<SelectionPieceViewDelegate> delegate;

- (id) initForNalimov;
- (id) initWithSquareSize:(CGFloat)dimSquare;

- (void) modificaTipoPezzi:(NSString *)pieceType;
- (void) modificaTipoSquare:(NSString *)squareType;

@end
