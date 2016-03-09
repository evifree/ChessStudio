//
//  GameSetting.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 18/05/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "GameSetting.h"

@implementation GameSetting

- (id) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


+ (id) sharedGameSetting {
    static GameSetting *gameSetting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gameSetting = [[self alloc] init];
    });
    return gameSetting;
}

- (void) reset {
    _pawnStructure = NO;
    _forwardAnimated = NO;
    _backAnimated = NO;
    _forwardAnimationDuration = 0.5;
    _backAnimationDuration = 0.5;
    _stopped = NO;
}

- (void) resetAnimation {
    _forwardAnimated = NO;
    _backAnimated = NO;
    _forwardAnimationDuration = 0.5;
    _backAnimationDuration = 0.5;
    _stopped = NO;
}

- (void) accelera {
    if (_forwardAnimated) {
        if (_forwardAnimationDuration <= 0.3) {
            return;
        }
        _forwardAnimationDuration -= 0.1;
    }
    if (_backAnimated) {
        if (_backAnimationDuration <= 0.3) {
            return;
        }
        _backAnimationDuration -= 0.1;
    }
}

- (void) decelera {
    if (_forwardAnimated) {
        _forwardAnimationDuration += 0.1;
    }
    else if (_backAnimated) {
        _backAnimationDuration += 0.1;
    }
}

@end
