//
//  PlayStrengthViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/12/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayStrengthDelegate <NSObject>

- (void) aggiornaPlayStrengthInTable;

@end

@interface PlayStrengthViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign) id<PlayStrengthDelegate> delegate;

@end
