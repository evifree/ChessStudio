//
//  SetupPositionView.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 21/08/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "SetupPositionView.h"
#import "UtilToView.h"
#import <QuartzCore/QuartzCore.h>
#import "SettingManager.h"

@interface SetupPositionView() {
    CGFloat dimSquare;
    NSString *tipoSquare;
    NSString *tipoPezzi;
    
    UIView *squaresView;
    //UIView *piecesView;
    
    SettingManager *settingManager;
    
    CGFloat spessoreBordo;
    CGColorRef coloreBordo;
}

@end

@implementation SetupPositionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
- (id)initWithSquareSizeAndSquareTypeAndPieceType:(CGFloat)squareSize :(NSString *)squareType :(NSString *)pieceType {
    self = [super init];
    if (self) {
        
        if (IS_PAD) {
            spessoreBordo = 3.0;
            coloreBordo = [UIColor redColor].CGColor;
        }
        else if (IS_IPHONE_5) {
            spessoreBordo = 1.5;
            coloreBordo = [UIColor greenColor].CGColor;
        }
        else if (IS_PHONE) {
            spessoreBordo = 1.5;
            coloreBordo = [UIColor greenColor].CGColor;
        }
        
        
        settingManager = [SettingManager sharedSettingManager];
        dimSquare = [settingManager getSquareSizeForPositionSetup];
        tipoSquare = [settingManager squares];
        tipoPezzi = [settingManager getPieceTypeToLoad];
        
        
        
        [self setupPositionView];
    }
    return self;
}
*/

- (id) initWithSettingManager {
    self = [super init];
    if (self) {
        if (IS_PAD_PRO) {
            spessoreBordo = 3.0;
            coloreBordo = [UIColor redColor].CGColor;
        }
        else if (IS_PAD) {
            spessoreBordo = 3.0;
            coloreBordo = [UIColor redColor].CGColor;
        }
        else if (IS_IPHONE_4_OR_LESS) {
            spessoreBordo = 1.5;
            coloreBordo = [UIColor greenColor].CGColor;
        }
        else if (IS_IPHONE_5) {
            spessoreBordo = 1.5;
            coloreBordo = [UIColor greenColor].CGColor;
        }
        else if (IS_IPHONE_6) {
            spessoreBordo = 1.5;
            coloreBordo = [UIColor greenColor].CGColor;
        }
        else if (IS_IPHONE_6P) {
            spessoreBordo = 2.0;
            coloreBordo = [UIColor greenColor].CGColor;
        }
        
        
        settingManager = [SettingManager sharedSettingManager];
        dimSquare = [settingManager getSquareSizeForPositionSetup];
        tipoSquare = [settingManager squares];
        tipoPezzi = [settingManager getPieceTypeToLoad];
        
        [self setupPositionView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setupPositionView {
    CGRect setupFrame;
    if (IS_PAD_PRO) {
        if (IS_PORTRAIT) {
            setupFrame = CGRectMake(0, 1026, 1024, 275);
        }
        else {
            setupFrame = CGRectMake(916, 0, 450, 916);
        }
    }
    else if (IS_PAD) {
        if (IS_PORTRAIT) {
            setupFrame = CGRectMake(0, 769, 768, 192);
            //setupFrame = CGRectMake(0, 768, 768, 148);
        }
        else {
            setupFrame = CGRectMake(660, 0, 364, 660);
        }
    }
    else if (IS_IPHONE_4_OR_LESS){
        if (IS_PORTRAIT) {
            setupFrame = CGRectMake(0, 320, 320, 96);
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                setupFrame = CGRectMake(256.0, 0, 224.0, 256.0);
            }
            else {
                setupFrame = CGRectMake(236, 0, 256, 236);
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            setupFrame = CGRectMake(0, 320, 320, 140);
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                setupFrame = CGRectMake(256.0, 0, 344.0, 256.0);
            }
            else {
                setupFrame = CGRectMake(236.0, 0, 344, 236);
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            setupFrame = CGRectMake(0.0, 375, 375, 184.0);
        }
        else {
            setupFrame = CGRectMake(311.0, 0, 356.0, 311.0);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            setupFrame = CGRectMake(0.0, 414, 414, 214.0);
        }
        else {
            setupFrame = CGRectMake(326.0, 0, 410.0, 326.0);
        }
    }
    
    [self setBackgroundColor:UIColorFromRGB(0xffffa6)];
    [self setFrame:setupFrame];
    
    CGRect squaresViewFrame;
    
    if (IS_PAD_PRO) {
        if (IS_PORTRAIT) {
            squaresViewFrame = CGRectMake(272, 57.5, 480, 160);
        }
        else {
            squaresViewFrame = CGRectMake(51, 9, 348, 116);
        }
    }
    else if (IS_PAD) {
        if (IS_PORTRAIT) {
            squaresViewFrame = CGRectMake(144, 16, 480, 160);
        }
        else {
            squaresViewFrame = CGRectMake(9, 9, 348, 116);
        }
    }
    else if (IS_IPHONE_4_OR_LESS) {
        if (IS_PORTRAIT) {
            squaresViewFrame = CGRectMake(40, 8, 240, 80);
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                squaresViewFrame = CGRectMake(16, 9, 180, 60);
            }
            else {
                squaresViewFrame = CGRectMake(38, 9, 180, 60);
            }
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            squaresViewFrame = CGRectMake(40, 8, 240, 80);
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                squaresViewFrame = CGRectMake(65, 9, 180, 60);
            }
            else {
                squaresViewFrame = CGRectMake(82, 9, 180, 60);
            }
        }
    }
    else if (IS_IPHONE_6) {
        if (IS_PORTRAIT) {
            //squaresViewFrame = CGRectMake(45, 30, 240, 80);
            squaresViewFrame = CGRectMake(45, 30, 281.25, 93.75);
        }
        else {
            //squaresViewFrame = CGRectMake(60, 20, 180, 60);
            squaresViewFrame = CGRectMake(60, 20, 233.25, 77.75);
        }
    }
    else if (IS_IPHONE_6P) {
        if (IS_PORTRAIT) {
            squaresViewFrame = CGRectMake(53, 30, dimSquare*6, dimSquare*2);
        }
        else {
            squaresViewFrame = CGRectMake(80, 20, dimSquare*6, dimSquare*2);
        }
    }

    squaresView = [[UIView alloc] initWithFrame:squaresViewFrame];
    //squaresView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    squaresView.backgroundColor = UIColorFromRGB(0xffffa6);
    [self addSubview:squaresView];
    //piecesView = [[UIView alloc] initWithFrame:squaresViewFrame];
    
    UIImage *darkSquareImage = [settingManager getDarkSquare];
    UIImage *lightSquareImage = [settingManager getLightSquare];
    
    UIImageView *squareImageView;
    
    for (int i=0; i<12; i++) {
        float fx = (float) ( i % 6 ) * dimSquare;
        float fy = 2 * dimSquare - (i/6 +1)*dimSquare;
        
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
        [squareImageView setFrame:CGRectMake(fx, fy, dimSquare, dimSquare)];
        squareImageView.userInteractionEnabled = YES;
        
        UIImageView *piv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)];
        piv.tag = i;
        [piv setImage:[UIImage imageNamed:pezzo]];
        [squareImageView addSubview:piv];
        [squareImageView setUserInteractionEnabled:NO];
        
        [squaresView addSubview:squareImageView];
    }
}

- (void) modificaTipoPezzi:(NSString *)pieceType {
    tipoPezzi = [settingManager getPieceTypeToLoad];
    [self setupPositionView];
}

- (void) modificaTipoSquare:(NSString *)squareType {
    tipoSquare = [settingManager squares];
    [self setupPositionView];
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
                [_delegate selection:self :[UtilToView getPieceSetupPositionByNumber:piv.tag]];
            }
        }
        
    }
}

@end
