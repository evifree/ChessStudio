//
//  PlayStyleOptionTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/12/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PlayStyleOptionDelegate <NSObject>

- (void) aggiornaPlayStyleInTable;

@end

@interface PlayStyleOptionTableViewController : UITableViewController

@property (nonatomic, assign) id<PlayStyleOptionDelegate> delegate;

@end
