//
//  TextCommentViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 10/10/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardModel.h"
#import "BoardView.h"
#import "PGNMove.h"

@protocol TextCommentViewControllerDelegate <NSObject>

- (void) aggiornaCommento;
- (void) aggiornaOrientamento;

@end

@interface TextCommentViewController : UIViewController

@property (nonatomic, assign) id<TextCommentViewControllerDelegate> delegate;

@property (nonatomic, strong) BoardModel *boardModel;
@property (nonatomic, strong) PGNMove *pgnMove;
@property (nonatomic) BOOL textBefore;

@end
