//
//  EcoTagViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 19/07/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EcoTagViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSString *previousEco;
@property (nonatomic, strong) NSString *selectedEco;

@end
