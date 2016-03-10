//
//  TextCommentPopoverViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 03/03/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGNMove.h"

@protocol TextCommentPopoverViewControllerDelegate <NSObject>

- (void) aggiornaCommentoFromTextPopover;
//- (void) aggiornaOrientamentoFromTextPopover;

@end

@interface TextCommentPopoverViewController : UIViewController

@property (nonatomic, assign) id<TextCommentPopoverViewControllerDelegate> delegate;

@property (nonatomic, strong) PGNMove *pgnMove;
@property (nonatomic) BOOL textBefore;

@end
