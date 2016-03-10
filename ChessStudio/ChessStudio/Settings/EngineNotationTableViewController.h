//
//  EngineNotationTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/12/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EngineNotationDelegate <NSObject>

- (void) aggiornaEngineNotationInTable;

@end

@interface EngineNotationTableViewController : UITableViewController

@property (nonatomic, assign) id<EngineNotationDelegate> delegate;

@end
