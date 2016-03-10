//
//  ControlNalimovView.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 16/07/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingManager.h"


@protocol ControlNalimovViewDelegate <NSObject>

- (void) clearPosition;
- (void) switchColor:(UIColor *)color;
- (void) moveSelection;
- (void) setupSelection;
- (BOOL) isNalimovEnabled;

@end


@interface ControlNalimovView : UIView

@property (nonatomic, assign) id<ControlNalimovViewDelegate> delegate;


- (id) initForNalimov;
- (id) initWithSquareSize:(CGFloat)dimSquare;

- (void) setColor:(NSString *)colorToSet;
- (void) modificaTipoSquare:(NSString *)squareType;

@end
