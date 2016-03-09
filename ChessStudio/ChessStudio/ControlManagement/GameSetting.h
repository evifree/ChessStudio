//
//  GameSetting.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 18/05/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameSetting : NSObject


@property (nonatomic, assign) BOOL pawnStructure;
@property (nonatomic, assign) BOOL forwardAnimated;
@property (nonatomic, assign) BOOL backAnimated;
@property (nonatomic, assign) CGFloat forwardAnimationDuration;
@property (nonatomic, assign) CGFloat backAnimationDuration;
@property (nonatomic, assign) BOOL stopped;

+ (id) sharedGameSetting;
- (void) reset;
- (void) resetAnimation;

- (void) decelera;
- (void) accelera;

@end
