//
//  SelectionPieceView.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 07/07/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "SelectionPieceView.h"

@interface SelectionPieceView() {
    
    SettingManager *settingManager;
    
    CGFloat _dimSquare;
    NSString *tipoSquare;
    NSString *tipoPezzi;
    
    UIView *squaresView;
    UIView *piecesView;
    
    CGRect viewFrame;
    
    CGFloat spessoreBordo;
    CGColorRef coloreBordo;
}

@end

@implementation SelectionPieceView



-(id) initForNalimov {
    self = [super init];
    if (self) {
        settingManager = [SettingManager sharedSettingManager];
        _dimSquare = [settingManager getSquareSizeNalimovLandscape];
        [self setup];
    }
    return self;
}

- (id) initWithSquareSize:(CGFloat)dimSquare {
    self = [super init];
    if (self) {
        settingManager = [SettingManager sharedSettingManager];
        _dimSquare = dimSquare;
        [self setup];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) setup {
    if (IS_PAD) {
        viewFrame = CGRectMake(_dimSquare, _dimSquare*9 + 10, _dimSquare*6, _dimSquare*2);
    }
    else if (IS_IPHONE_5) {
        viewFrame = CGRectMake(30.0, _dimSquare*8 + 40 + 30, _dimSquare*6, _dimSquare*2);
    }
    else if (IS_IPHONE_4_OR_LESS) {
        viewFrame = CGRectMake(30.0, _dimSquare*8 + 40 + 30, _dimSquare*6, _dimSquare*2);
    }
    else {
        viewFrame = CGRectMake(40.0, _dimSquare*8 + 40 + 30, _dimSquare*6, _dimSquare*2);
    }
    
    [self setFrame:viewFrame];
    [self setBackgroundColor:[UIColor clearColor]];
    CGRect pRect = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
    squaresView = [[UIView alloc] initWithFrame:pRect];
    [squaresView setBackgroundColor:[UIColor yellowColor]];
    
    tipoSquare = [settingManager squares];
    tipoPezzi = [settingManager getPieceTypeToLoad];
    
    piecesView = [[UIView alloc] initWithFrame:pRect];
    
    UIImage *darkSquareImage = [settingManager getDarkSquare];
    UIImage *lightSquareImage = [settingManager getLightSquare];
    
    UIImageView *squareImageView;
    
    for (int i=0; i<12; i++) {
        float fx = (float) ( i % 6 ) * _dimSquare;
        float fy = 2 * _dimSquare - (i/6 +1)*_dimSquare;
        
        NSString *pezzo = [UtilToView getPieceSetupPositionByNumber:i];
        
        pezzo = [tipoPezzi stringByAppendingString:pezzo];
        
        if((int)floor(i/6)%2) {
            if( i%2 ) {
                squareImageView = [[UIImageView alloc] initWithImage:darkSquareImage];
            }
            else {
                squareImageView = [[UIImageView alloc] initWithImage:lightSquareImage];
            }
        }
        else {
            if( i%2 ) {
                squareImageView = [[UIImageView alloc] initWithImage:lightSquareImage];
            }
            else {
                squareImageView = [[UIImageView alloc] initWithImage:darkSquareImage];
            }
        }
        
        //NSLog(@"%f    %f", fx, fy);
        [squareImageView setFrame:CGRectMake(fx, fy, _dimSquare, _dimSquare)];
        squareImageView.userInteractionEnabled = YES;
        
        UIImageView *piv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _dimSquare, _dimSquare)];
        piv.tag = i;
        [piv setImage:[UIImage imageNamed:pezzo]];
        [squareImageView addSubview:piv];
        [squareImageView setUserInteractionEnabled:NO];
        
        [squaresView addSubview:squareImageView];
    }
    
    if (IS_PAD) {
        spessoreBordo = 2.0;
        coloreBordo = [UIColor redColor].CGColor;
    }
    else if (IS_IPHONE_6P) {
        spessoreBordo = 1.5;
        coloreBordo = [UIColor redColor].CGColor;
    }
    else if (IS_IPHONE_6) {
        spessoreBordo = 1.5;
        coloreBordo = [UIColor redColor].CGColor;
    }
    else if (IS_IPHONE_5) {
        spessoreBordo = 1.0;
        coloreBordo = [UIColor redColor].CGColor;
    }
    else if (IS_IPHONE_4_OR_LESS) {
        spessoreBordo = 1.0;
        coloreBordo = [UIColor redColor].CGColor;
    }
    [self addSubview:squaresView];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //[_delegate selection:self];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    //NSLog(@"%f     %f", location.x, location.y);
    NSArray *subViews = [squaresView subviews];
    for (UIView *sv in subViews) {
        if ([sv isKindOfClass:[UIImageView class]]) {
            UIView *v = [[sv subviews] objectAtIndex:0];
            UIImageView *piv = (UIImageView *)v;
            if (piv.layer.borderWidth == spessoreBordo) {
                piv.layer.borderWidth = 0.0;
            }
            if (CGRectContainsPoint(sv.frame, location)) {
                //NSLog(@"Tag %d", piv.tag);
                piv.layer.borderColor = coloreBordo;
                piv.layer.borderWidth = spessoreBordo;
                [_delegate selection:[UtilToView getPieceSetupPositionByNumber:piv.tag]];
            }
        }
    }
}

- (void) modificaTipoPezzi:(NSString *)pieceType {
    tipoPezzi = [settingManager getPieceTypeToLoad];
    [self setup];
}

- (void) modificaTipoSquare:(NSString *)squareType {
    tipoSquare = [settingManager squares];
    [self setup];
}

@end
