//
//  ControlNalimovView.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 16/07/15.
//  Copyright (c) 2015 Giordano Vicoli. All rights reserved.
//

#import "ControlNalimovView.h"
#import "BoardView.h"


@interface ControlNalimovView() {
    SettingManager *settingManager;
    
    
    CGFloat _dimSquare;
    
    
    CGRect viewFrame;
    UIView *squaresView;
    
    //CGFloat spessoreBordo;
    //CGColorRef coloreBordo;
    
    UIImageView *backupColorImageView;
    UIImageView *backupSelectionImageView;
    UIImageView *backupDragImageView;
}

@end

@implementation ControlNalimovView





-(id) initForNalimov {
    self = [super init];
    if (self) {
        settingManager = [SettingManager sharedSettingManager];
        _dimSquare = [settingManager getSquareSizeNalimov];
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
        viewFrame = CGRectMake(40.0 + _dimSquare*6, _dimSquare*8 + 40 + 30, _dimSquare*2, _dimSquare*2);
    }
    else if (IS_IPHONE_6P) {
        viewFrame = CGRectMake(40.0 + _dimSquare*6, _dimSquare*8 + 40 + 30, _dimSquare*2, _dimSquare*2);
    }
    else if (IS_IPHONE_6) {
        viewFrame = CGRectMake(40.0 + _dimSquare*6 + 20, _dimSquare*8 + 40 + 30, _dimSquare*2, _dimSquare*2);
    }
    else if (IS_IPHONE_5) {
        viewFrame = CGRectMake(40.0 + _dimSquare*6 + 20, _dimSquare*8 + 40 + 30, _dimSquare*2, _dimSquare*2);
    }
    else if (IS_IPHONE_4_OR_LESS) {
        viewFrame = CGRectMake(40.0 + _dimSquare*6 + 20, _dimSquare*8 + 40 + 30, _dimSquare*2, _dimSquare*2);
    }
    
    [self setFrame:viewFrame];
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGRect pRect = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
    squaresView = [[UIView alloc] initWithFrame:pRect];
    [squaresView setBackgroundColor:[UIColor yellowColor]];
    
    
    for (int i=0; i<4; i++) {
        float fx = (float) ( i % 2 ) * _dimSquare;
        float fy = 2 * _dimSquare - (i/2 +1)*_dimSquare;
        
        
        UIImage *darkSquareImage = [settingManager getDarkSquare];
        UIImage *lightSquareImage = [settingManager getLightSquare];
        
        UIImageView *squareImageView;
        
        
        if((int)floor(i/2)%2) {
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
        
        [squareImageView setFrame:CGRectMake(fx, fy, _dimSquare, _dimSquare)];
        squareImageView.userInteractionEnabled = YES;
        
        
        UIImageView *piv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _dimSquare, _dimSquare)];
        piv.tag = 100 + i;
        
        switch (i) {
            case 0:
                [piv setImage:[UIImage imageNamed:@"Mano"]];
                piv.alpha = 0.3;
                break;
            case 1:
                [piv setImage:[UIImage imageNamed:@"White"]];
                [piv setAccessibilityIdentifier:@"White"];
                break;
            case 2:
                [piv setImage:[UIImage imageNamed:@"ManoDrag"]];
                break;
            case 3:
                //[piv setImage:[UIImage imageNamed:@"ClearBoard"]];
                [piv setImage:[self setupClearBoard]];
                break;
            default:
                break;
        }
        
        [squareImageView addSubview:piv];
        [squareImageView setUserInteractionEnabled:NO];
        
        [squaresView addSubview:squareImageView];
        
    }
    
     [self addSubview:squaresView];
    
    /*
    if (IS_PAD) {
        spessoreBordo = 2.0;
        coloreBordo = [UIColor greenColor].CGColor;
    }
    else if (IS_IPHONE_6P) {
        spessoreBordo = 1.5;
        coloreBordo = [UIColor greenColor].CGColor;
    }
    else if (IS_IPHONE_6) {
        spessoreBordo = 1.5;
        coloreBordo = [UIColor greenColor].CGColor;
    }
    else if (IS_IPHONE_5) {
        spessoreBordo = 1.0;
        coloreBordo = [UIColor greenColor].CGColor;
    }
    else if (IS_IPHONE_4_OR_LESS) {
        spessoreBordo = 1.0;
        coloreBordo = [UIColor greenColor].CGColor;
    }
    */
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
            //if (piv.layer.borderWidth == spessoreBordo) {
                //piv.layer.borderWidth = 0.0;
            //}
            //if (piv.alpha <= 0.5) {
            //    piv.alpha = 1.0;
            //}
            if (CGRectContainsPoint(sv.frame, location)) {
                if (piv.tag == 100) {
                    //piv.layer.borderColor = coloreBordo;
                    //piv.layer.borderWidth = spessoreBordo;
                    piv.alpha = 0.3;
                    [self setAlphaWithTag:1.0 :102];
                    [_delegate setupSelection];
                }
                else if (piv.tag == 101) {
                    if ([self switchColorNotAllowed]) {
                        return;
                    }
                    if ([piv.accessibilityIdentifier isEqualToString:@"White"]) {
                        piv.image = nil;
                        [piv setImage:[UIImage imageNamed:@"Black"]];
                        [piv setAccessibilityIdentifier:@"Black"];
                        [_delegate switchColor:[UIColor blackColor]];
                    }
                    else if ([piv.accessibilityIdentifier isEqualToString:@"Black"]) {
                        piv.image = nil;
                        [piv setImage:[UIImage imageNamed:@"White"]];
                        [piv setAccessibilityIdentifier:@"White"];
                        [_delegate switchColor:[UIColor whiteColor]];
                    }
                }
                else if (piv.tag == 102) {
                    //piv.layer.borderColor = coloreBordo;
                    //piv.layer.borderWidth = spessoreBordo;
                    
                    if (![_delegate isNalimovEnabled]) {//Cambiare i titoli ed il messaggio di questo alert view
                        UIAlertView *noNalimovAlertView = [[UIAlertView alloc] initWithTitle:@"Nalimov Tablebase" message:NSLocalizedString(@"NALIMOV_NOT_ALLOWED", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [noNalimovAlertView show];
                        return;
                    }
                    
                    piv.alpha = 0.3;
                    [self setAlphaWithTag:1.0 :100];
                    [_delegate moveSelection];
                }
                else if (piv.tag == 103) {
                    [self setAlphaWithTag:0.3 :100];
                    [self setAlphaWithTag:1.0 :102];
                    [_delegate clearPosition];
                }
            }
        }
    }
}

- (void) setColor:(NSString *)colorToSet {
    UIView *v = [squaresView viewWithTag:101];
    UIImageView *colorImageView = (UIImageView *)v;
    colorImageView.image = nil;
    [colorImageView setImage:[UIImage imageNamed:colorToSet]];
    [colorImageView setAccessibilityIdentifier:colorToSet];
}

- (void) setAlphaWithTag:(CGFloat)alpha :(int)tag {
    UIView *v = [squaresView viewWithTag:tag];
    if ([v isKindOfClass:[UIImageView class]]) {
        UIImageView *iv = (UIImageView *)v;
        iv.alpha =alpha;
    }
}

- (BOOL) switchColorNotAllowed {
    UIView *v = [squaresView viewWithTag:100];
    UIImageView *iv = (UIImageView *)v;
    if (iv.alpha<1.0) {
        return NO;
    }
    else {
        return YES;
    }
}

- (UIImage *) setupClearBoard {
    BoardView *bv = [[BoardView alloc] initWithSquareSize:8];
    CGRect rect = [bv bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [bv.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void) modificaTipoSquare:(NSString *)squareType {
    [self backup];
    [squaresView removeFromSuperview];
    [self setup];
    [self restore];
}

- (void) backup {
    UIView *v = [squaresView viewWithTag:101];
    backupColorImageView = (UIImageView *)v;
    
    UIView *v1 = [squaresView viewWithTag:100];
    backupSelectionImageView = (UIImageView *)v1;
    
    UIView *v2 = [squaresView viewWithTag:102];
    backupDragImageView = (UIImageView *)v2;
}

- (void) restore {
    UIView *v = [squaresView viewWithTag:101];
    UIImageView *colorImageView = (UIImageView *)v;
    [colorImageView setImage:[backupColorImageView image]];
    [colorImageView setAccessibilityIdentifier:[backupColorImageView accessibilityIdentifier]];
    
    UIView *v1 = [squaresView viewWithTag:100];
    UIImageView *selectionImageView = (UIImageView *)v1;
    selectionImageView.alpha = backupSelectionImageView.alpha;
    
    UIView *v2 = [squaresView viewWithTag:102];
    UIImageView *dragImageView = (UIImageView *)v2;
    dragImageView.alpha = backupDragImageView.alpha;
    
    backupColorImageView = nil;
    backupSelectionImageView = nil;
    backupDragImageView = nil;
}

@end
