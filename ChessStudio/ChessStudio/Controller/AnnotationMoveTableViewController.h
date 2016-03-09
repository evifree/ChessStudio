//
//  AnnotationMoveTableViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 31/05/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGNMove.h"

@protocol AnnotationMoveTableViewControllerDelegate <NSObject>

- (void) cancelButtonPressed;
- (void) saveButtonPressed;
- (void) updateWebView;

@end

@interface AnnotationMoveTableViewController : UITableViewController


@property (nonatomic, assign) id<AnnotationMoveTableViewControllerDelegate> delegate;

@property (nonatomic, strong) PGNMove *mossaDaAnnotare;

@end
