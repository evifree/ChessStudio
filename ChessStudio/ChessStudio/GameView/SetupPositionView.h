//
//  SetupPositionView.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 21/08/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SetupPositionView;

@protocol SetupPositionViewDelegate <NSObject>

- (void) selection:(SetupPositionView *)setupPositionView :(NSString *)pezzo;

@end


@interface SetupPositionView : UIView

@property (nonatomic, assign) id<SetupPositionViewDelegate> delegate;


//-(id)initWithSquareSizeAndSquareTypeAndPieceType:(CGFloat)squareSize :(NSString *)squareType :(NSString *)pieceType;
-(id)initWithSettingManager;

-(void)modificaTipoPezzi:(NSString *)pieceType;
-(void)modificaTipoSquare:(NSString *)squareType;

@end
