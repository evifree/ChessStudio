//
//  BoardView.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "BoardView.h"
#import <QuartzCore/QuartzCore.h>
#import "UtilToView.h"
#import "SettingManager.h"
#import "GameSetting.h"

@interface BoardView() {
    
    UIView *squaresView;
    UIView *piecesView;
    
    CGFloat dimSquare;
    NSString *tipoSquare;
    NSString *pieceType;
    
    
    //BoardModel *boardModel;
    
    
    int casaPartenza;
    int casaArrivo;
    PieceButton *pezzoMosso;
    
    BOOL flipped;
    
    NSMutableArray *stackCapturedPiece;
    
    NSArray *_caseEnPassant;
    NSUInteger _selectedCasaEnPassant;
    
    SettingManager *settingManager;
    
    GameSetting *gameSetting;
    
    
    
    NSTimeInterval timeStampAtTouchesBegan;
    NSTimeInterval timeStampAtTouchesEnded;
    UIImageView *ivTapped;
    
    
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
    
}

@property (nonatomic) NSInteger squareNumber;
@property (nonatomic, strong) NSArray *controlledSquareToHilight;
@property (nonatomic, strong) NSArray *canditatesPieces;

@end

@implementation BoardView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (id)initWithSquareSize:(CGFloat)squareSize {
    self = [super init];
    if (self) {
        
        leftSwipeGestureRecognizer = nil;
        rightSwipeGestureRecognizer = nil;
        
        settingManager = [SettingManager sharedSettingManager];
        dimSquare = squareSize;
        
        //NSLog(@"DIM SQUARE FROM SETTING MANAGER = %f", dimSquare);
        
        tipoSquare = [settingManager squares];
        flipped = NO;
        stackCapturedPiece = [[NSMutableArray alloc] init];
        
        CGRect boardFrame = CGRectMake(0, 0, dimSquare*8, dimSquare*8);
        [self setBackgroundColor:[UIColor clearColor]];
        [self setFrame:boardFrame];
        squaresView = [[UIView alloc] initWithFrame:boardFrame];
        squaresView.backgroundColor = [UIColor blackColor];
        [self addSubview:squaresView];
        piecesView = [[UIView alloc] initWithFrame:boardFrame];
        [self addSubview:piecesView];
        
        UIImage *darkSquareImage = [settingManager getDarkSquare];
        UIImage *lightSquareImage = [settingManager getLightSquare];
        
        UIImageView *squareImageView;
        for (int i=0; i<64; i++) {
            
            float fx = (float) ( i % 8 ) * dimSquare;
            float fy = 8 * dimSquare - (i/8 +1)*dimSquare;
            
            if((int)floor(i/8)%2) {
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
            
            [squareImageView setFrame:CGRectMake(fx, fy, dimSquare, dimSquare)];
            [squareImageView setTag:i];
            squareImageView.userInteractionEnabled = YES;
            [self addSubview:squareImageView];
        }
        
        _squareNumber = -1;
        //[self addLeftAndRightSwipe];
    }
    return self;
}

- (id) initWithSquareSizeAndBoardModel:(CGFloat)squareSize :(BoardModel *)boardModel {
    self = [self initWithSquareSize:squareSize];
    if (self) {
        pieceType = [settingManager getPieceTypeToLoad];
        PieceButton *pb;
        for (int i=0; i<64; i++) {
            NSString *square = [boardModel findContenutoBySquareNumber:i];
            if (![square hasSuffix:@"m"]) {
                if ([square hasSuffix:@"r"]) {
                    pb = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:square];
                }
                else {
                    if ([square hasSuffix:@"k"]) {
                        pb = [[[KingButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:square];
                    }
                    else {
                        if ([square hasSuffix:@"q"]) {
                            pb = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:square];
                        }
                        else {
                            if ([square hasSuffix:@"n"]) {
                                pb = [[[KnightButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:square];
                            }
                            else {
                                if ([square hasSuffix:@"b"]) {
                                    pb = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:square];
                                }
                                else {
                                    if ([square hasSuffix:@"p"]) {
                                        pb = [[[PawnButton alloc] initWithFrame:CGRectMake(0, 0, dimSquare, dimSquare)]initWithPieceTypeAndPieceSymbol:pieceType:square];
                                    }
                                }
                            }
                        }
                    }
                }
                //[pb setSquareNumber:[[boardModel.numericSquares objectAtIndex:i] intValue]];
                [pb setCasaIniziale:i];
                //[pb setDelegate:self];
                [pb setSquareValue:i];
                if (flipped) {
                    [pb flip];
                }
                [self addSubview:pb];
            }
            else {
                PieceButton *pb = [self findPieceBySquareTag:i];
                if (pb) {
                    [pb removeFromSuperview];
                }
            }
        }
        _squareNumber = -1;
        
        //[self addLeftAndRightSwipe];
    }
    return self;
}


- (id) initWithSquareSizeAndSquareType:(CGFloat)squareSize :(NSString *)squareType {
    self = [super init];
    if (self) {
        
        leftSwipeGestureRecognizer = nil;
        rightSwipeGestureRecognizer = nil;
        
        settingManager = [SettingManager sharedSettingManager];
        
        _squareNumber = -1;
        
        dimSquare = squareSize;
        tipoSquare = squareType;
        flipped = NO;
        
        
        stackCapturedPiece = [[NSMutableArray alloc] init];
        
        /*
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
         dimSquare = 96;
         
         }
         else {
         dimSquare = 40;
         
         }
         */
        
        CGRect boardFrame = CGRectMake(0, 0, dimSquare*8, dimSquare*8);
        [self setBackgroundColor:[UIColor clearColor]];
        [self setFrame:boardFrame];
        squaresView = [[UIView alloc] initWithFrame:boardFrame];
        squaresView.backgroundColor = [UIColor blackColor];
        [self addSubview:squaresView];
        piecesView = [[UIView alloc] initWithFrame:boardFrame];
        [self addSubview:piecesView];
        
        
        UIImage *darkSquareImage = [settingManager getDarkSquare];
        UIImage *lightSquareImage = [settingManager getLightSquare];
        
        
        
        UIImageView *squareImageView;
        
        
        for (int i=0; i<64; i++) {
            
            float fx = (float) ( i % 8 ) * dimSquare;
            //float fy = floor( i / 8 ) * dimSquare;
            float fy = 8 * dimSquare - (i/8 +1)*dimSquare;
            
            //if (fx == 0) {
                //riga++;
                //colonna = 1;
            //}
            //else {
                //colonna++;
            //}
            
            //NSLog(@"i=%d    -   Fx = %f   -   Fy = %f", i, fx, fy);
            
            if((int)floor(i/8)%2) {
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
            
            //casa = colonna*10 + riga;
            
            [squareImageView setFrame:CGRectMake(fx, fy, dimSquare, dimSquare)];
            //[squareImageView setCenter:CGPointMake(fx,fy)];
            [squareImageView setTag:i];
            //[squareImageView setSquareNumber:casa];
            //[squareImageView setRow:riga];
            //[squareImageView setColumn:colonna];
            //[squareImageView setLetter:96 + colonna];
            //[squareImageView setLabel];
            squareImageView.userInteractionEnabled = YES;
            [self addSubview:squareImageView];
        }
        
        //[self addLeftAndRightSwipe];
    }
    return self;
}

- (id) initWithSettingManager {
    self = [super init];
    if (self) {
        
        leftSwipeGestureRecognizer = nil;
        rightSwipeGestureRecognizer = nil;
        
        _squareNumber = -1;
        
        settingManager = [SettingManager sharedSettingManager];
        dimSquare = [settingManager getSquareSize];
        
        //NSLog(@"DIM SQUARE FROM SETTING MANAGER = %f", dimSquare);
        
        tipoSquare = [settingManager squares];
        flipped = NO;
        stackCapturedPiece = [[NSMutableArray alloc] init];
        
        CGRect boardFrame = CGRectMake(0, 0, dimSquare*8, dimSquare*8);
        [self setBackgroundColor:[UIColor clearColor]];
        [self setFrame:boardFrame];
        squaresView = [[UIView alloc] initWithFrame:boardFrame];
        squaresView.backgroundColor = [UIColor blackColor];
        [self addSubview:squaresView];
        piecesView = [[UIView alloc] initWithFrame:boardFrame];
        [self addSubview:piecesView];
        
        UIImage *darkSquareImage = [settingManager getDarkSquare];
        UIImage *lightSquareImage = [settingManager getLightSquare];
        
        UIImageView *squareImageView;
        for (int i=0; i<64; i++) {
            
            float fx = (float) ( i % 8 ) * dimSquare;
            float fy = 8 * dimSquare - (i/8 +1)*dimSquare;
            
            if((int)floor(i/8)%2) {
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
            
            [squareImageView setFrame:CGRectMake(fx, fy, dimSquare, dimSquare)];
            [squareImageView setTag:i];
            squareImageView.userInteractionEnabled = YES;
            [self addSubview:squareImageView];
        }
        //self.layer.borderWidth = 14.0;
        //self.layer.borderColor = [UIColor clearColor].CGColor;
        //[self.layer setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"WhiteSquare96.png"]] CGColor]];
        //UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 10, 10)];
        //[l setBackgroundColor:[UIColor clearColor]];
        //l.textColor = [UIColor blackColor];
        //l.text = @"A";
        //[self addSubview:l];
        //[self.layer addSublayer:l.layer];
        
        gameSetting = [GameSetting sharedGameSetting];
        
        
        //[self addLeftAndRightSwipe];
    }
    return self;
}

- (void) addLeftAndRightSwipeGestureRecognizer {
    rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightSwipeGestureRecognizer];
    
    leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandle)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftSwipeGestureRecognizer];
}

- (void) removeLeftAndRightSwipeGestureRecognizer {
    [self removeGestureRecognizer:rightSwipeGestureRecognizer];
    [self removeGestureRecognizer:leftSwipeGestureRecognizer];
    leftSwipeGestureRecognizer = nil;
    rightSwipeGestureRecognizer = nil;
}

- (BOOL) isLeftAndRightSwipeEnabled {
    if (rightSwipeGestureRecognizer && leftSwipeGestureRecognizer) {
        return YES;
    }
    return NO;
}

- (void) rightSwipeHandle {
    [_delegate manageLeftSwipeOnBoardView];
    //[_delegate manageRightSwipeOnBoardView];
}

- (void) leftSwipeHandle {
    [_delegate manageRightSwipeOnBoardView];
    //[_delegate manageLeftSwipeOnBoardView];
}

- (void) stampaDati:(CGFloat)squareSize {
    
    dimSquare = squareSize;
    

    
    NSLog(@"SELF FRAME:  X=%f     Y=%f     W=%f    H=%f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    //NSLog(@"BOARDFRAME FRAME:  X=%f     Y=%f     W=%f    H=%f", boardFrame.origin.x, boardFrame.origin.y, boardFrame.size.width, boardFrame.size.height);
    NSLog(@"SQUARESVIEW FRAME:  X=%f     Y=%f     W=%f    H=%f", squaresView.frame.origin.x, squaresView.frame.origin.y, squaresView.frame.size.width, squaresView.frame.size.height);
    NSLog(@"PIECESVIEW FRAME:  X=%f     Y=%f     W=%f    H=%f", piecesView.frame.origin.x, piecesView.frame.origin.y, piecesView.frame.size.width, piecesView.frame.size.height);
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.75, 0.75);
    [squaresView setTransform:scaleTransform];
    [piecesView setTransform:scaleTransform];
    
    NSLog(@"SELF FRAME:  X=%f     Y=%f     W=%f    H=%f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    //NSLog(@"BOARDFRAME FRAME:  X=%f     Y=%f     W=%f    H=%f", boardFrame.origin.x, boardFrame.origin.y, boardFrame.size.width, boardFrame.size.height);
    NSLog(@"SQUARESVIEW FRAME:  X=%f     Y=%f     W=%f    H=%f", squaresView.frame.origin.x, squaresView.frame.origin.y, squaresView.frame.size.width, squaresView.frame.size.height);
    NSLog(@"PIECESVIEW FRAME:  X=%f     Y=%f     W=%f    H=%f", piecesView.frame.origin.x, piecesView.frame.origin.y, piecesView.frame.size.width, piecesView.frame.size.height);
    
    //return;
    
    for (int i=0; i<64; i++) {
        UIImageView *siv = [self findSquareByTag:i];
        if (siv) {
            NSLog(@"SQUAREIMAGEVIEW FRAME PRIMA:  X=%f     Y=%f     W=%f    H=%f", siv.frame.origin.x, siv.frame.origin.y, siv.frame.size.width, siv.frame.size.height);
            //[siv setTransform:scaleTransform];
            //NSLog(@"SQUAREIMAGEVIEW FRAME DOPO:  X=%f     Y=%f     W=%f    H=%f", siv.frame.origin.x, siv.frame.origin.y, siv.frame.size.width, siv.frame.size.height);
        }
    }
    
    return;
    
    for (int i=0; i<64; i++) {
        //float fx = (float) ( i % 8 ) * dimSquare;
        //float fy = 8 * dimSquare - (i/8 +1)*dimSquare;
        UIImageView *siv = [self findSquareByTag:i];
        PieceButton *pb = [self findPieceBySquareTag:i];
        if (pb) {
            //[pb setFrame:CGRectMake(fx, fy, dimSquare, dimSquare)];
        }
        NSLog(@"SQUAREIMAGEVIEW FRAME PRIMA:  X=%f     Y=%f     W=%f    H=%f", siv.frame.origin.x, siv.frame.origin.y, siv.frame.size.width, siv.frame.size.height);
        //[siv setFrame:CGRectMake(fx, fy, dimSquare, dimSquare)];
        NSLog(@"SQUAREIMAGEVIEW FRAME DOPO:  X=%f     Y=%f     W=%f    H=%f", siv.frame.origin.x, siv.frame.origin.y, siv.frame.size.width, siv.frame.size.height);
    }
    
    [piecesView setFrame:self.frame];
    [squaresView setFrame:self.frame];
    
    for (int i=0; i<64; i++) {
        UIImageView *siv = [self findSquareByTag:i];
        if (siv) {
            //NSLog(@"SQUAREIMAGEVIEW FRAME:  X=%f     Y=%f     W=%f    H=%f", siv.frame.origin.x, siv.frame.origin.y, siv.frame.size.width, siv.frame.size.height);
        }
    }

}

- (void) resetBoard:(CGFloat)squareSize :(NSString *)squareType {
    
    for (int i=0; i<64; i++) {
        PieceButton *pb = [self findPieceBySquareTag:i];
        if (pb) {
            [pb removeFromSuperview];
        }
        UIImageView *siv = [self findSquareByTag:i];
        if (siv) {
            [siv removeFromSuperview];
        }
    }
    
    [piecesView removeFromSuperview];
    [squaresView removeFromSuperview];
    
    dimSquare = squareSize;
    tipoSquare = squareType;
    
    CGRect boardFrame;
    
    //boardFrame = CGRectMake(0.0, 0.0, dimSquare*8, dimSquare*8);
    
    if (dimSquare == 96.0) {
        boardFrame = CGRectMake(0.0, 0.0, dimSquare*8, dimSquare*8);
        [self setFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    }
    else if (dimSquare == 72.0) {
        boardFrame = CGRectMake(96.0, 0.0, dimSquare*8, dimSquare*8);
        [self setFrame:CGRectMake(96.0, 0.0, 0.0, 0.0)];
    }
    else if (dimSquare == 48.0) {
        boardFrame = CGRectMake(192.0, 0.0, dimSquare*8, dimSquare*8);
        [self setFrame:CGRectMake(192.0, 0.0, 0.0, 0.0)];
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
    //[self setFrame:boardFrame];
    squaresView = [[UIView alloc] initWithFrame:boardFrame];
    squaresView.backgroundColor = [UIColor clearColor];
    [self addSubview:squaresView];
    piecesView = [[UIView alloc] initWithFrame:boardFrame];
    [piecesView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:piecesView];
    
    NSLog(@"SELF FRAME:  X=%f     Y=%f     W=%f    H=%f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    NSLog(@"BOARDFRAME FRAME:  X=%f     Y=%f     W=%f    H=%f", boardFrame.origin.x, boardFrame.origin.y, boardFrame.size.width, boardFrame.size.height);
    NSLog(@"SQUARESVIEW FRAME:  X=%f     Y=%f     W=%f    H=%f", squaresView.frame.origin.x, squaresView.frame.origin.y, squaresView.frame.size.width, squaresView.frame.size.height);
    NSLog(@"PIECESVIEW FRAME:  X=%f     Y=%f     W=%f    H=%f", piecesView.frame.origin.x, piecesView.frame.origin.y, piecesView.frame.size.width, piecesView.frame.size.height);
    
    UIImage *darkSquareImage;
    UIImage *lightSquareImage;
    
    
    if ([tipoSquare hasPrefix:@"square1"]) {
        darkSquareImage = [UIImage imageNamed:@"BlackSquare96.png"];
        lightSquareImage = [UIImage imageNamed:@"WhiteSquare96.png"];
    }
    else if ([tipoSquare hasPrefix:@"square2"]) {
        darkSquareImage = [UIImage imageNamed:@"BlackMarmo.png"];
        lightSquareImage = [UIImage imageNamed:@"WhiteMarmo.png"];
    }
    else if ([tipoSquare hasPrefix:@"square3"]) {
        darkSquareImage = [UIImage imageNamed:@"BlackWood2.png"];
        lightSquareImage = [UIImage imageNamed:@"WhiteWood2.png"];
    }
    else if ([tipoSquare hasPrefix:@"square4"]) {
        darkSquareImage = [UIImage imageNamed:@"BlackTexture.png"];
        lightSquareImage = [UIImage imageNamed:@"WhiteTexture.png"];
    }
    else if ([tipoSquare hasPrefix:@"square5"]) {
        darkSquareImage = [UIImage imageNamed:@"BlackWood3.png"];
        lightSquareImage = [UIImage imageNamed:@"WhiteWood3.png"];
    }
    
    UIImageView *squareImageView;
    
    for (int i=0; i<64; i++) {
        
        float fx = (float) ( i % 8 ) * dimSquare;
        //float fy = floor( i / 8 ) * dimSquare;
        float fy = 8 * dimSquare - (i/8 +1)*dimSquare;
        
        //if (fx == 0) {
        //riga++;
        //colonna = 1;
        //}
        //else {
        //colonna++;
        //}
        
        //NSLog(@"i=%d    -   Fx = %f   -   Fy = %f", i, fx, fy);
        
        if((int)floor(i/8)%2) {
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
        
        //casa = colonna*10 + riga;
        
        [squareImageView setFrame:CGRectMake(fx, fy, dimSquare, dimSquare)];
        //[squareImageView setCenter:CGPointMake(fx,fy)];
        [squareImageView setTag:i];
        //[squareImageView setSquareNumber:casa];
        //[squareImageView setRow:riga];
        //[squareImageView setColumn:colonna];
        //[squareImageView setLetter:96 + colonna];
        //[squareImageView setLabel];
        squareImageView.userInteractionEnabled = YES;
        [self addSubview:squareImageView];
    }
}

- (void) setTipoSquare:(NSString *)typeSquare {
    UIImage *darkSquareImage = [settingManager getDarkSquare];
    UIImage *lightSquareImage = [settingManager getLightSquare];
    
    /*
    if ([typeSquare isEqualToString:@"Wood"]) {
        darkSquareImage = [UIImage imageNamed:@"BlackSquare96.png"];
        lightSquareImage = [UIImage imageNamed:@"WhiteSquare96.png"];
    }
    else if ([typeSquare isEqualToString:@"Marble"]) {
        darkSquareImage = [UIImage imageNamed:@"BlackMarmo.png"];
        lightSquareImage = [UIImage imageNamed:@"WhiteMarmo.png"];
    }
    else if ([typeSquare isEqualToString:@"Wood 2"]) {
        darkSquareImage = [UIImage imageNamed:@"BlackWood2.png"];
        lightSquareImage = [UIImage imageNamed:@"WhiteWood2.png"];
    }
    else if ([typeSquare isEqualToString:@"Texture"]) {
        darkSquareImage = [UIImage imageNamed:@"BlackTexture.png"];
        lightSquareImage = [UIImage imageNamed:@"WhiteTexture.png"];
    }
    else if ([typeSquare isEqualToString:@"Wood 3"]) {
        darkSquareImage = [UIImage imageNamed:@"BlackWood3.png"];
        lightSquareImage = [UIImage imageNamed:@"WhiteWood3.png"];
    }
    else if ([typeSquare isEqualToString:@"DarkLight"]) {
        darkSquareImage = [UIImage imageNamed:@"DarkNewspaper96"];
        lightSquareImage = [UIImage imageNamed:@"LightNewspaper96"];
    }
    */
    
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *squareImageView = (UIImageView *)v;
            NSInteger i = squareImageView.tag;
            if((int)floor(i/8)%2) {
                if( i%2 ) {
                    squareImageView.image = darkSquareImage;
                }
                else {
                    squareImageView.image = lightSquareImage;
                }
            }
            else {
                if( i%2 ) {
                    squareImageView.image = lightSquareImage;
                }
                else {
                    squareImageView.image = darkSquareImage;
                }
            }
        }
    }
}



- (void) setupPosition {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"Touches began da BoardView");
    
    //NSLog(@"Numero view in BoardView: %d", self.subviews.count);
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    //NSLog(@"BOARDVIEW:Tap Location:  %f   %f", location.x, location.y);
    int sqx = location.x/dimSquare;
    int sqy = location.y/dimSquare;
    float fx = sqx*dimSquare;
    float fy = sqy*dimSquare;
    //NSLog(@"Casa: %d  %d", sqx, sqy);
    //NSLog(@"punto %f, %f", fx, fy);
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            if (CGRectContainsPoint(iv.frame, CGPointMake(fx, fy))) {
                //NSLog(@"Casa Trovata con tag = %d", iv.tag);
                
                
                //Inizio istruzioni per gestire setup posizioni en passant
                NSArray *sub = [iv subviews];
                if (sub.count > 0 && _caseEnPassant) {
                    NSNumber *numberEnPassant = [NSNumber numberWithInteger:iv.tag];
                    
                    if ([_caseEnPassant containsObject:numberEnPassant]) {
                        if (iv.layer.borderWidth == 3.0) {
                            iv.layer.borderColor = [UIColor clearColor].CGColor;
                            iv.layer.borderWidth = 0.0;
                            _selectedCasaEnPassant = 0;
                        }
                        else {
                            iv.layer.borderColor = [UIColor redColor].CGColor;
                            iv.layer.borderWidth = 3.0;
                            _selectedCasaEnPassant = iv.tag;
                        }
                        for (NSNumber *altraCasaEnPassant in _caseEnPassant) {
                            if ([altraCasaEnPassant integerValue] != iv.tag) {
                                UIImageView *altraCasaEnPassantView = [self findSquareByTag:[altraCasaEnPassant integerValue]];
                                if (altraCasaEnPassantView) {
                                    altraCasaEnPassantView.layer.borderColor = [UIColor clearColor].CGColor;
                                    altraCasaEnPassantView.layer.borderWidth = 0.0;
                                }

                            }
                        }
                    }
                    return;
                }
                //Fine istruzioni per gestire setup posizioni en passant
                
                //NSLog(@"Tap on BoardView");
                UITouch *touchBegan = [touches anyObject];
                timeStampAtTouchesBegan = [touchBegan timestamp];
                ivTapped = iv;
                //[_delegate checkSquare:iv.tag];
                break;
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //NSLog(@"Touches Moved");
    
    UITouch *touch = [[event touchesForView:self] anyObject];
    
    CGPoint previousLocation = [touch previousLocationInView:self];
	CGPoint location = [touch locationInView:self];
	CGFloat delta_x = location.x - previousLocation.x;
	CGFloat delta_y = location.y - previousLocation.y;
    
    if (!flipped) {
        self.center = CGPointMake(self.center.x + delta_x, self.center.y + delta_y);
    }
    else {
        self.center = CGPointMake(self.center.x - delta_x, self.center.y - delta_y);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"Touches Ended BoardView");
    UITouch *touchEnded = [touches anyObject];
    timeStampAtTouchesEnded = [touchEnded timestamp];
    
    if ((timeStampAtTouchesEnded - timeStampAtTouchesBegan) < 0.2) {
        [_delegate checkSquare:(int)ivTapped.tag];
    }
}


/*
- (void) setupPosition:(BoardModel *)board {
    boardModel = board;
    PieceButton *pb;
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            NSString *pezzo = [board.pieces objectAtIndex:iv.tag];
            NSLog(@"Pezzo: %@     Tag: %d", pezzo, iv.tag);
            
            //pb = [[[PieceButton alloc] initWithFrame:CGRectMake(0, 0, iv.frame.size.width, iv.frame.size.height)]initWithPieceTypeAndPieceSymbol:@"zur96":pezzo];
            //[pb setSquareValue:iv.tag];
            //[self addSubview:pb];
            
            if (![pezzo hasSuffix:@"m"]) {
                if ([pezzo hasSuffix:@"r"]) {
                    pb = [[[RookButton alloc] initWithFrame:CGRectMake(0, 0, iv.frame.size.width, iv.frame.size.height)]initWithPieceTypeAndPieceSymbol:@"zur96":pezzo];
                }
                else {
                    if ([pezzo hasSuffix:@"k"]) {
                        pb = [[[KingButton alloc] initWithFrame:CGRectMake(0, 0, iv.frame.size.width, iv.frame.size.height)]initWithPieceTypeAndPieceSymbol:@"zur96":pezzo];
                    }
                    else {
                        if ([pezzo hasSuffix:@"q"]) {
                            pb = [[[QueenButton alloc] initWithFrame:CGRectMake(0, 0, iv.frame.size.width, iv.frame.size.height)]initWithPieceTypeAndPieceSymbol:@"zur96":pezzo];
                        }
                        else {
                            if ([pezzo hasSuffix:@"n"]) {
                                pb = [[[KnightButton alloc] initWithFrame:CGRectMake(0, 0, iv.frame.size.width, iv.frame.size.height)]initWithPieceTypeAndPieceSymbol:@"zur96":pezzo];
                            }
                            else {
                                if ([pezzo hasSuffix:@"b"]) {
                                    pb = [[[BishopButton alloc] initWithFrame:CGRectMake(0, 0, iv.frame.size.width, iv.frame.size.height)]initWithPieceTypeAndPieceSymbol:@"zur96":pezzo];
                                }
                                else {
                                    if ([pezzo hasSuffix:@"p"]) {
                                        pb = [[[PawnButton alloc] initWithFrame:CGRectMake(0, 0, iv.frame.size.width, iv.frame.size.height)]initWithPieceTypeAndPieceSymbol:@"zur96":pezzo];
                                    }
                                }
                            }
                        }
                    }
                }
                [pb setSquareValue:iv.tag];
                [self addSubview:pb];
            }
        }
    }
}
*/

- (void) modifyPieces:(NSString *)typePieces {
    typePieces = [settingManager getPieceTypeToLoad];
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[PieceButton class]]) {
            PieceButton *pb = (PieceButton *)v;
            [pb modifyPieceImage:typePieces];
        }
    }
}


- (void) setCoordinates {
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            UILabel *label;
            if (IS_PAD) {
                //NSLog(@"ALTEZZA DIMSQUARE = %f", dimSquare);
                //NSLog(@"ALTEZZA IMMAGINE = %f", iv.frame.size.height);
                //label = [[UILabel alloc] initWithFrame:CGRectMake(0, dimSquare - 11, 20, 10)];
                //label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
                label = [[UILabel alloc] initWithFrame:[settingManager getFrameForCoordinates]];
                label.font = [settingManager getFontForCoordinates];
            }
            else {
                //label = [[UILabel alloc] initWithFrame:CGRectMake(0, dimSquare - 11, 13, 11)];
                //label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(8.0)];
                label = [[UILabel alloc] initWithFrame:[settingManager getFrameForCoordinates]];
                label.font = [settingManager getFontForCoordinates];
            }
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor clearColor];
            label.text = [NSString stringWithFormat:@"%ld", (long)iv.tag];
            [iv addSubview:label];
        }
    }
}


- (void) setCoordinates:(NSArray *)coordArray {
    
    if (!coordArray) { // rimuovi l'eventuale label esistente
        for (UIView *v in self.subviews) {
            if ([v isKindOfClass:[UIImageView class]]) {
                UIImageView *iv = (UIImageView *)v;
                for (UIView *vv in iv.subviews) {
                    if ([vv isKindOfClass:[UILabel class]]) {
                        UILabel *label = (UILabel *)vv;
                        [label removeFromSuperview];
                    }
                }
            }
        }
        return;
    }
    
    
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            UILabel *label;
            if (IS_PAD) {
                //NSLog(@"ALTEZZA DIMSQUARE = %f", dimSquare);
                //NSLog(@"ALTEZZA IMMAGINE = %f", iv.frame.size.height);
                //label = [[UILabel alloc] initWithFrame:CGRectMake(0, dimSquare - 11, 20, 10)];
                //label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
                label = [[UILabel alloc] initWithFrame:[settingManager getFrameForCoordinates]];
                label.font = [settingManager getFontForCoordinates];
            }
            else {
                //label = [[UILabel alloc] initWithFrame:CGRectMake(0, dimSquare - 11, 13, 11)];
                //label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(8.0)];
                label = [[UILabel alloc] initWithFrame:[settingManager getFrameForCoordinates]];
                label.font = [settingManager getFontForCoordinates];
            }
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor clearColor];
            
            NSObject *obj = [coordArray objectAtIndex:iv.tag];
            if ([obj isKindOfClass:[NSNumber class]]) {
                NSNumber *valore = (NSNumber *)obj;
                label.text = [NSString stringWithFormat:@"%d", valore.intValue];
            }
            else {
                label.text = (NSString *)obj;
            }
            [iv addSubview:label];
        }
    }
}

- (void) setNalimovCoordinates {
    CGRect frame = [settingManager getFrameForNalimovCoordinates:dimSquare];
    UIFont *font = [settingManager getFontForNalimovCoordinates];
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            UILabel *label;
            //if (IS_PAD) {
            //label = [[UILabel alloc] initWithFrame:[settingManager getFrameForCoordinates]];
            //label.font = [settingManager getFontForCoordinates];
            //}
            //else {
            //label = [[UILabel alloc] initWithFrame:[settingManager getFrameForCoordinates]];
            //label.font = [settingManager getFontForCoordinates];
            //}
            label = [[UILabel alloc] initWithFrame:frame];
            label.font = font;
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor clearColor];
            label.text = [NSString stringWithFormat:@"%ld", (long)iv.tag];
            [iv addSubview:label];
        }
    }
}

- (void) setNalimovCoordinates:(NSArray *)coordArray {
    
    if (!coordArray) { // rimuovi l'eventuale label esistente
        for (UIView *v in self.subviews) {
            if ([v isKindOfClass:[UIImageView class]]) {
                UIImageView *iv = (UIImageView *)v;
                for (UIView *vv in iv.subviews) {
                    if ([vv isKindOfClass:[UILabel class]]) {
                        UILabel *label = (UILabel *)vv;
                        [label removeFromSuperview];
                    }
                }
            }
        }
        return;
    }
    
    CGRect frame = [settingManager getFrameForNalimovCoordinates:dimSquare];
    UIFont *font = [settingManager getFontForNalimovCoordinates];
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            UILabel *label;
            //if (IS_PAD) {
            //    label = [[UILabel alloc] initWithFrame:[settingManager getFrameForNalimovCoordinates]];
            //    label.font = [settingManager getFontForNalimovCoordinates];
            //}
            //else {
            //    label = [[UILabel alloc] initWithFrame:[settingManager getFrameForNalimovCoordinates]];
            //    label.font = [settingManager getFontForNalimovCoordinates];
            //}
            label = [[UILabel alloc] initWithFrame:frame];
            label.font = font;
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor clearColor];
            
            NSObject *obj = [coordArray objectAtIndex:iv.tag];
            if ([obj isKindOfClass:[NSNumber class]]) {
                NSNumber *valore = (NSNumber *)obj;
                label.text = [NSString stringWithFormat:@"%d", valore.intValue];
            }
            else {
                label.text = (NSString *)obj;
            }
            [iv addSubview:label];
        }
    }
}

- (PieceButton *) findPieceBySquareTag:(int) squareTag {
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[PieceButton class]]) {
            PieceButton *pb = (PieceButton *)v;
            if ((pb.tag == squareTag)) {
                return pb;
            }
        }
    }
    return nil;
}

- (PieceButton *) findHiddenPieceBySquareTag:(int) squareTag {
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[PieceButton class]]) {
            PieceButton *pb = (PieceButton *)v;
            if ((pb.tag == squareTag) && [pb isHidden]) {
                return pb;
            }
        }
    }
    return nil;
}

- (NSMutableArray *) findPiecesByName:(NSString *)name {
    NSMutableArray *risu = [[NSMutableArray alloc] init];
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[PieceButton class]]) {
            PieceButton *pb = (PieceButton *)v;
            if ([pb.titleLabel.text isEqualToString:name]) {
                [pb generaMossePseudoLegali];
                [risu addObject:pb];
            }
        }
    }
    return risu;
}

- (void) muoviPezzo:(int)cp :(int)ca {
    PieceButton *pb = [self findPieceBySquareTag:cp];
    [UIView animateWithDuration:0.5 animations:^{
        [pb setSquareValue:ca];
    }];
}

- (void) muoviPezzoIndietro:(int)cp :(int)ca :(PieceButton *)pm {
    PieceButton *pb = [self findPieceBySquareTag:cp];
    
    //[[pb movimenti] removeLastObject];
    
    NSLog(@"devo muovere il pezzo indietro %@ da %d a %d", pb.titleLabel.text, cp, ca);
    
    /*
    if (pm) {
        [pm setSquareValue:cp];
    }*/
    
    
    [UIView animateWithDuration:0.1 animations:^{
        [pb setSquareValue:ca];
        if (pm) {
            //[pm setSquareValue:cp];
            [self addSubview:pm];
        }
        
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==6) && (ca==4)) {
            PieceButton *rook = [self findPieceBySquareTag:5];
            if (rook) {
                [rook setSquareValue:7];
                return;
            }
        }
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==2) && (ca==4)) {
            PieceButton *rook = [self findPieceBySquareTag:3];
            if (rook) {
                [rook setSquareValue:0];
                return;
            }
        }
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==62) && (ca==60)) {
            PieceButton *rook = [self findPieceBySquareTag:61];
            if (rook) {
                [rook setSquareValue:63];
                return;
            }
        }
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==58) && (ca==60)) {
            PieceButton *rook = [self findPieceBySquareTag:59];
            if (rook) {
                [rook setSquareValue:56];
            }
        }
        
        
    } completion:^(BOOL finished) {
        //if (pm) {
        //    [self addSubview:pm];
        //    [pm setSquareValue:cp];
        //}
        /*
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==6) && (ca==4)) {
            PieceButton *rook = [self findPieceBySquareTag:5];
            if (rook) {
                [rook setSquareValue:7];
                return;
            }
        }
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==2) && (ca==4)) {
            PieceButton *rook = [self findPieceBySquareTag:3];
            if (rook) {
                [rook setSquareValue:0];
                return;
            }
        }
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==62) && (ca==60)) {
            PieceButton *rook = [self findPieceBySquareTag:61];
            if (rook) {
                [rook setSquareValue:63];
                return;
            }
        }
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==58) && (ca==60)) {
            PieceButton *rook = [self findPieceBySquareTag:59];
            if (rook) {
                [rook setSquareValue:56];
            }
        }
        */
    }];
    //usleep(6);
}

- (void) muoviPezzoAvanti:(PGNMove *)move {
    
    PieceButton *pezzoDaMuovere = [self findPieceBySquareTag:move.fromSquare];
    PieceButton *pezzoDaCatturare = nil;
    
    if (move.enPassantCapture) {
        pezzoDaMuovere = [self findPieceBySquareTag:move.fromSquare];
        pezzoDaCatturare = [self findPieceBySquareTag:move.enPassantPieceSquare];
        if (pezzoDaCatturare) {
            if (flipped) {
                [pezzoDaCatturare flip];
            }
            [pezzoDaCatturare removeFromSuperview];
        }
        [UIView animateWithDuration:0.1 animations:^{
            [pezzoDaMuovere setSquareValue:move.toSquare];
        }];
        return;
    }
    
    
    
    if (move.capture) {
        pezzoDaCatturare = [self findPieceBySquareTag:move.toSquare];
    }
    
    //[[pezzoDaMuovere movimenti] addObject:[NSNumber numberWithInt:move.toSquare]];
    
    
    [UIView animateWithDuration:0.1 animations:^{
    //[UIView animateWithDuration:0.1 delay:0.0 options:(UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse) animations:^{
        [pezzoDaMuovere setSquareValue:move.toSquare];
        
        if (pezzoDaCatturare) {
            if (flipped) {
                [pezzoDaCatturare flip];
            }
            [pezzoDaCatturare removeFromSuperview];
        }
        
        if ([pezzoDaMuovere.titleLabel.text hasSuffix:@"k"] && (move.fromSquare==4) && (move.toSquare==6)) {
            PieceButton *rook = [self findPieceBySquareTag:7];
            if (rook) {
                [rook setSquareValue:5];
                return;
            }
        }
        if ([pezzoDaMuovere.titleLabel.text hasSuffix:@"k"] && (move.fromSquare==4) && (move.toSquare==2)) {
            PieceButton *rook = [self findPieceBySquareTag:0];
            if (rook) {
                [rook setSquareValue:3];
                return;
            }
        }
        if ([pezzoDaMuovere.titleLabel.text hasSuffix:@"k"] && (move.fromSquare==60) && (move.toSquare==62)) {
            PieceButton *rook = [self findPieceBySquareTag:63];
            if (rook) {
                [rook setSquareValue:61];
                return;
            }
        }
        if ([pezzoDaMuovere.titleLabel.text hasSuffix:@"k"] && (move.fromSquare==60) && (move.toSquare==58)) {
            PieceButton *rook = [self findPieceBySquareTag:56];
            if (rook) {
                [rook setSquareValue:59];
            }
        }
    }completion:nil];
}

- (void) muoviPezzoAvantiEPromuovi:(PGNMove *)move :(PieceButton *)pezzoPromosso {
    PieceButton *pezzoDaMuovere = [self findPieceBySquareTag:move.fromSquare];
    PieceButton *pezzoDaCatturare = nil;
    if (move.capture) {
        pezzoDaCatturare = [self findPieceBySquareTag:move.toSquare];
    }
    
    //[[pezzoDaMuovere movimenti] addObject:[NSNumber numberWithInt:move.toSquare]];
    
    [UIView animateWithDuration:0.1 animations:^{
        
        if (pezzoDaCatturare) {
            if (flipped) {
                [pezzoDaCatturare flip];
            }
            [pezzoDaCatturare removeFromSuperview];
        }
        [pezzoDaMuovere removeFromSuperview];
        
        [pezzoPromosso setSquareValue:move.toSquare];
        [self addSubview:pezzoPromosso];
    }];
}

- (void) muoviPezzoIndietro:(PGNMove *)move :(PieceButton *)pezzoCatturatoDaRimettereInGioco {
    
    PieceButton *pezzoDaMuovere = [self findPieceBySquareTag:move.toSquare];
    //[[pezzoDaMuovere movimenti] removeLastObject];
    
    [UIView animateWithDuration:0.1 animations:^{
        if (pezzoCatturatoDaRimettereInGioco) {
            [self addSubview:pezzoCatturatoDaRimettereInGioco];
        }
        
        [pezzoDaMuovere setSquareValue:move.fromSquare];
        
        if ([pezzoDaMuovere.titleLabel.text hasSuffix:@"k"] && (move.toSquare==6) && (move.fromSquare==4)) {
            PieceButton *rook = [self findPieceBySquareTag:5];
            if (rook) {
                [rook setSquareValue:7];
                return;
            }
        }
        if ([pezzoDaMuovere.titleLabel.text hasSuffix:@"k"] && (move.toSquare==2) && (move.fromSquare==4)) {
            PieceButton *rook = [self findPieceBySquareTag:3];
            if (rook) {
                [rook setSquareValue:0];
                return;
            }
        }
        if ([pezzoDaMuovere.titleLabel.text hasSuffix:@"k"] && (move.toSquare==62) && (move.fromSquare==60)) {
            PieceButton *rook = [self findPieceBySquareTag:61];
            if (rook) {
                [rook setSquareValue:63];
                return;
            }
        }
        if ([pezzoDaMuovere.titleLabel.text hasSuffix:@"k"] && (move.toSquare==58) && (move.fromSquare==60)) {
            PieceButton *rook = [self findPieceBySquareTag:59];
            if (rook) {
                [rook setSquareValue:56];
            }
        }
    }];
}

- (void) muoviPezzoIndietroPromosso:(PGNMove *)move :(PieceButton *)pedonePromosso :(PieceButton *)pezzoCatturato {
    PieceButton *pezzoCreatoInPromozione = [self findPieceBySquareTag:move.toSquare];
    
    NSLog(@"Pezzo Creato in Promozione = %@", pezzoCreatoInPromozione.titleLabel.text);
    
    [pezzoCreatoInPromozione removeFromSuperview];
    [pedonePromosso setSquareValue:move.fromSquare];
    if (pezzoCatturato) {
        [pezzoCatturato setSquareValue:move.toSquare];
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        [self addSubview:pedonePromosso];
        if (pezzoCatturato) {
            [self addSubview:pezzoCatturato];
        }
    } completion:^(BOOL finished) {
    }];
}



- (void) muoviPezzoAvanti:(int)cp :(int)ca :(PieceButton *)pm {
    PieceButton *pb = [self findPieceBySquareTag:cp];
    
    //[[pb movimenti] addObject:[NSNumber numberWithInt:ca]];
    
    [UIView animateWithDuration:0.1 animations:^{
        [pb setSquareValue:ca];
        if (pm) {
            [pm removeFromSuperview];
        }
        
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==4) && (ca==6)) {
            PieceButton *rook = [self findPieceBySquareTag:7];
            if (rook) {
                [rook setSquareValue:5];
                return;
            }
        }
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==4) && (ca==2)) {
            PieceButton *rook = [self findPieceBySquareTag:0];
            if (rook) {
                [rook setSquareValue:3];
                return;
            }
        }
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==60) && (ca==62)) {
            PieceButton *rook = [self findPieceBySquareTag:63];
            if (rook) {
                [rook setSquareValue:61];
                return;
            }
        }
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==60) && (ca==58)) {
            PieceButton *rook = [self findPieceBySquareTag:56];
            if (rook) {
                [rook setSquareValue:59];
            }
        }
        
        
    } completion:^(BOOL finished) {
        
        //if (pm) {
        //    [pm removeFromSuperview];
        //}
        /*
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==4) && (ca==6)) {
            PieceButton *rook = [self findPieceBySquareTag:7];
            if (rook) {
                [rook setSquareValue:5];
                return;
            }
        }
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==4) && (ca==2)) {
            PieceButton *rook = [self findPieceBySquareTag:0];
            if (rook) {
                [rook setSquareValue:3];
                return;
            }
        }
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==60) && (ca==62)) {
            PieceButton *rook = [self findPieceBySquareTag:63];
            if (rook) {
                [rook setSquareValue:61];
                return;
            }
        }
        if ([pb.titleLabel.text hasSuffix:@"k"] && (cp==60) && (ca==58)) {
            PieceButton *rook = [self findPieceBySquareTag:56];
            if (rook) {
                [rook setSquareValue:59];
            }
        }
        */
    }];
}

- (void) promuoviPedoneAvanti:(int)cp :(int)ca :(PieceButton *)pp {
    PieceButton *pb = [self findPieceBySquareTag:cp];
    [UIView animateWithDuration:0.1 animations:^{
        [pb setSquareValue:ca];
        [pb removeFromSuperview];
        [self addSubview:pp];
        [pp setSquareValue:ca];
    } completion:^(BOOL finished) {
        //[pb removeFromSuperview];
        //[self addSubview:pp];
        //[pp setSquareValue:ca];
    }];
}

- (void) promuoviPedoneIndietro:(int)cp :(int)ca :(PieceButton *)pp {
    PieceButton *pb = [self findPieceBySquareTag:cp];
    [UIView animateWithDuration:0.1 animations:^{
        [self addSubview:pp];
        [pb removeFromSuperview];
        [pp setSquareValue:ca];
    } completion:^(BOOL finished) {
        //[pb removeFromSuperview];
        //[pp setSquareValue:ca];
    }];
}

- (void) mossaAvantiPromozioneECattura:(int)cp :(int)ca :(PieceButton *)pezzoPromosso :(PieceButton *)pezzoCatturatoInPromozione {
    PieceButton *pedonePromosso = [self findPieceBySquareTag:cp];
    [pedonePromosso removeFromSuperview];
    if (pezzoCatturatoInPromozione) {
        [pezzoCatturatoInPromozione removeFromSuperview];
    }
    [pezzoPromosso setSquareValue:ca];
    [UIView animateWithDuration:0.1 animations:^{
        [self addSubview:pezzoPromosso];
    } completion:^(BOOL finished) {
    }];
}

- (void) mossaIndietroPromozioneECattura:(int)cp :(int)ca :(PieceButton *)pedonePromosso :(PieceButton *)pezzoCatturatoInPromozione {
    PieceButton *pb = [self findPieceBySquareTag:cp];
    [pb removeFromSuperview];
    [pedonePromosso setSquareValue:ca];
    if (pezzoCatturatoInPromozione) {
        [pezzoCatturatoInPromozione setSquareValue:cp];
    }
    [UIView animateWithDuration:0.1 animations:^{
        [self addSubview:pedonePromosso];
        if (pezzoCatturatoInPromozione) {
            [self addSubview:pezzoCatturatoInPromozione];
        }
    } completion:^(BOOL finished) {
        //[pb removeFromSuperview];
        //[pp setSquareValue:ca];
    }];
}

- (void) mossaAvantiEnPassant:(int)cp :(int)ca :(int)casaEnPassant {
    PieceButton *pb = [self findPieceBySquareTag:cp];
    PieceButton *pedoneEnPassant = [self findPieceBySquareTag:casaEnPassant];
    [UIView animateWithDuration:0.1 animations:^{
        [pb setSquareValue:ca];
        [pedoneEnPassant removeFromSuperview];
    } completion:^(BOOL finished) {
        //[pedoneEnPassant removeFromSuperview];
    }];
}

- (void) mossaIndietroEnPassant:(int)cp :(int)ca :(PieceButton *)pedoneEnPassant {
    PieceButton *pb = [self findPieceBySquareTag:cp];
    [UIView animateWithDuration:0.1 animations:^{
        [pb setSquareValue:ca];
        //[self addSubview:pedoneEnPassant];
    } completion:^(BOOL finished) {
        //[self addSubview:pedoneEnPassant];
    }];
}

- (void)flipPosition {
    
    flipped = !flipped;
    
    [UIView animateWithDuration:0.1 animations:^{
        if (flipped) {
            self.transform = CGAffineTransformRotate(self.transform, M_PI);
        }
        else {
            self.transform = CGAffineTransformRotate(self.transform, M_PI);
        }
    } completion:^(BOOL finished){
        for (UIView *v in self.subviews) {
            if ([v isKindOfClass:[UIImageView class]]) {
                UIImageView *iv = (UIImageView *)v;
                [UIView animateWithDuration:0 animations:^{
                    iv.transform = CGAffineTransformRotate(iv.transform, M_PI);
                }];
            }
        }
        for (UIView *v in self.subviews) {
            if ([v isKindOfClass:[PieceButton class]]) {
                PieceButton *pb = (PieceButton *)v;
                [pb flip];
            }
        }
    }];
    /*
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            [UIView animateWithDuration:0 animations:^{
                iv.transform = CGAffineTransformRotate(iv.transform, M_PI);
            }];
        }
    }
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[PieceButton class]]) {
            PieceButton *pb = (PieceButton *)v;
            [pb flip];
        }
    }*/
}


- (void) manageCapture:(NSUInteger)tagCapturedPiece {
    //NSLog(@"Sto eseguendo manageCapture");
    PieceButton *pieceToRemove = [self findPieceBySquareTag:(int)tagCapturedPiece];
    if (pieceToRemove) {
        if (flipped) {
            [pieceToRemove flip];
        }
        [pieceToRemove removeFromSuperview];
        [stackCapturedPiece addObject:pieceToRemove];
    }
    //NSLog(@"Ho eseguito manage capture: Pezzo da catturare = %@  pezzo che cattura non lo so", pieceToRemove.titleLabel.text);
}

- (void) manageCaptureBack {
    PieceButton *pieceCaptured = [stackCapturedPiece lastObject];
    if (pieceCaptured) {
        if (flipped) {
            [pieceCaptured flip];
        }
        [self addSubview:pieceCaptured];
        [stackCapturedPiece removeLastObject];
    }
}

 
- (void) gestisciCatturaAvanti:(PGNMove *)move {
    if (move.capture) {
        PieceButton *pieceToRemove = [self findPieceBySquareTag:move.toSquare];
        if (pieceToRemove) {
            if (flipped) {
                [pieceToRemove flip];
            }
            [pieceToRemove removeFromSuperview];
            pieceToRemove = nil;
        }
    }
}

- (void) gestisciCatturaIndietro:(PGNMove *)move :(PieceButton *)pezzoCatturato {
    [pezzoCatturato setSquareValue:[move toSquare]];
    [self addSubview:pezzoCatturato];
}


- (PieceButton *) getLastCapturedPiece {
    if (stackCapturedPiece.count > 0) {
        return [stackCapturedPiece lastObject];
    }
    return nil;
}

/*
- (void) stampaPezziCatturati {
    NSLog(@"Pezzi NERI Catturati dal Bianco");
    for (PieceButton *pb in stackCapturedPiece) {
        if ([pb.titleLabel.text hasPrefix:@"b"]) {
            NSLog(@"%@", pb.titleLabel.text);
        }
    }
    NSLog(@"Pezzi BIANCHI Catturati dal Nero");
    for (PieceButton *pb in stackCapturedPiece) {
        if ([pb.titleLabel.text hasPrefix:@"w"]) {
            NSLog(@"%@", pb.titleLabel.text);
        }
    }
}
*/
 
- (void) manageCastle:(NSUInteger)kingTag :(NSUInteger)rookTag {
    PieceButton *rookButton = [self findPieceBySquareTag:(int)rookTag];
    if ((rookTag - kingTag) == 3) { //Arrocco Corto
        [rookButton setSquareValue:(int)(kingTag + 1)];
        return;
    }
    if ((rookTag - kingTag) == -4) {
        [rookButton setSquareValue:(int)(kingTag - 1)];
    }
}

- (void) segnaCaseEnPassant:(NSArray *)caseEnPassant {
    _caseEnPassant = caseEnPassant;
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            NSNumber *tagNumber = [NSNumber numberWithInteger:iv.tag];
            if ([_caseEnPassant containsObject:tagNumber]) {
                UIView *circleView;
                if (IS_PAD) {
                    circleView = [[UIView alloc] initWithFrame:CGRectMake(20,20,20,20)];
                    circleView.layer.cornerRadius = 10;
                }
                else if (IS_IPHONE_4_OR_LESS) {
                    if (IS_PORTRAIT) {
                        circleView = [[UIView alloc] initWithFrame:CGRectMake(15,15,10,10)];
                        circleView.layer.cornerRadius = 5;
                    }
                    else {
                        circleView = [[UIView alloc] initWithFrame:CGRectMake(10,10,8,8)];
                        circleView.layer.cornerRadius = 5;
                    }
                }
                else if (IS_IPHONE_5) {
                    if (IS_PORTRAIT) {
                        circleView = [[UIView alloc] initWithFrame:CGRectMake(15,15,10,10)];
                        circleView.layer.cornerRadius = 5;
                    }
                    else {
                        circleView = [[UIView alloc] initWithFrame:CGRectMake(10,10,8,8)];
                        circleView.layer.cornerRadius = 5;
                    }
                }
                else if (IS_IPHONE_6) {
                    if (IS_PORTRAIT) {
                        circleView = [[UIView alloc] initWithFrame:CGRectMake(18,18,10,10)];
                        circleView.layer.cornerRadius = 5;
                    }
                    else {
                        circleView = [[UIView alloc] initWithFrame:CGRectMake(14,14,8,8)];
                        circleView.layer.cornerRadius = 5;
                    }
                }
                else if (IS_IPHONE_6P) {
                    if (IS_PORTRAIT) {
                        circleView = [[UIView alloc] initWithFrame:CGRectMake(13,13,9,9)];
                        circleView.layer.cornerRadius = 5;
                    }
                    else {
                        circleView = [[UIView alloc] initWithFrame:CGRectMake(13,13,9,9)];
                        circleView.layer.cornerRadius = 5;
                    }
                }
                circleView.alpha = 1.0;
                circleView.backgroundColor = [UIColor redColor];
                [iv addSubview:circleView];
                
                if (iv.tag == _selectedCasaEnPassant) {
                    iv.layer.borderColor = [UIColor redColor].CGColor;
                    iv.layer.borderWidth = 3.0;
                }
            }
        }
    }
}


- (void) clearCaseEnPassant:(NSArray *)caseEnPassant {
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            NSNumber *tagNumber = [NSNumber numberWithInteger:iv.tag];
            if ([caseEnPassant containsObject:tagNumber]) {
                UIView *circleView = [[iv subviews] objectAtIndex:0];
                [circleView removeFromSuperview];
                iv.layer.borderColor = [UIColor clearColor].CGColor;
                iv.layer.borderWidth = 0.0;
            }
            
        }
    }
}

- (NSUInteger) getSelectedCasaEnPassant {
    return _selectedCasaEnPassant;
}


- (void) setSelectedCasaEnPassant:(NSUInteger)selectedCasaEnPassant {
    _selectedCasaEnPassant = selectedCasaEnPassant;
    if (_selectedCasaEnPassant == 0) {
        return;
    }
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            if (iv.tag == _selectedCasaEnPassant) {
                iv.layer.borderColor = [UIColor redColor].CGColor;
                iv.layer.borderWidth = 3.0;
                break;
            }
        }
    }
}


- (UIImageView *) findSquareByTag:(NSUInteger)tagSquare {
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            if (iv.tag == tagSquare) {
                return iv;
            }
        }
    }
    return nil;
}

- (void) resetEnPassantInPosition {
    _selectedCasaEnPassant = 0;
}

- (BOOL) tapInCentro:(CGPoint)point :(CGFloat) numeroCase {
    if (point.x>=dimSquare*numeroCase && point.y>=dimSquare*numeroCase && point.x <= dimSquare*numeroCase+dimSquare*(8 - 2*numeroCase) && point.y <= dimSquare*numeroCase + dimSquare*(8 - 2*numeroCase)) {
        return YES;
    }
    return NO;
}


- (void) managePawnStructure {
    GameSetting *gs = [GameSetting sharedGameSetting];
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[PieceButton class]]) {
            PieceButton *pb = (PieceButton *)v;
            if (![pb.titleLabel.text hasSuffix:@"p"]) {
                [pb setHidden:[gs pawnStructure]];
            }
        }
    }
}

- (BOOL) isHilighted:(NSInteger)squareNumber {
    if (squareNumber == _squareNumber) {
        return YES;
    }
    return NO;
}

- (void) clearStartSquare:(NSInteger)squareNumber {
    UIImageView *iv = [self findSquareByTag:squareNumber];
    iv.layer.borderColor = [UIColor clearColor].CGColor;
    iv.layer.borderWidth = 0.0;
    _squareNumber = -1;
}


- (void) hiLightStartSquare:(NSInteger)squareNumber {
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            if (iv.tag == _squareNumber) {
                iv.layer.borderColor = [UIColor clearColor].CGColor;
                iv.layer.borderWidth = 0.0;
            }
            if (iv.tag == squareNumber) {
                iv.layer.borderColor = [settingManager getSelectedColorHighLight].CGColor;
                iv.layer.borderWidth = [settingManager borderSelected];
            }
        }
    }
    _squareNumber = squareNumber;
}

- (void) hiLightControlledSquare:(NSInteger)squareToHilight {
    UIImageView *iv = [self findSquareByTag:squareToHilight];
    UIView *circleView = [[UIView alloc] initWithFrame:[settingManager circleRect]];
    circleView.layer.cornerRadius = [settingManager circleCornerRadius];
    circleView.alpha = 1.0;
    circleView.backgroundColor = [settingManager getSelectedColorHighLight];
    circleView.center = CGPointMake(iv.frame.size.width/2, iv.frame.size.width/2);
    PieceButton *pb = [self findPieceBySquareTag:(int)squareToHilight];
    if (!pb) {
        [iv addSubview:circleView];
    }
    else {
        [pb addSubview:circleView];
    }
    
    return;
    
    
    
    
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            if (iv.tag == squareToHilight) {
                UIView *circleView = [[UIView alloc] initWithFrame:[settingManager circleRect]];
                circleView.layer.cornerRadius = [settingManager circleCornerRadius];
                circleView.alpha = 1.0;
                circleView.backgroundColor = [UIColor orangeColor];
                circleView.center = CGPointMake(iv.frame.size.width/2, iv.frame.size.width/2);
                [iv addSubview:circleView];
            }
        }
    }
}

- (void) clearControlledSquare:(NSInteger)squareToClear {
    PieceButton *pb = [self findPieceBySquareTag:(int)squareToClear];
    if (pb) {
        for (UIView *sv in [pb subviews]) {
            if (sv.layer.cornerRadius == [settingManager circleCornerRadius]) {
                [sv removeFromSuperview];
            }
        }
    }
    //else {
        UIImageView *iv = [self findSquareByTag:squareToClear];
        if (iv.tag == squareToClear) {
            for (UIView *sv in [iv subviews]) {
                if (sv.layer.cornerRadius == [settingManager circleCornerRadius]) {
                    [sv removeFromSuperview];
                }
            }
        }
    //}
    
    return;
    
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            if (iv.tag == squareToClear) {
                for (UIView *sv in [iv subviews]) {
                    if (sv.layer.cornerRadius == 10) {
                        [sv removeFromSuperview];
                    }
                }
            }
        }
    }
}

- (void) clearHilightControlledSquares {
    for (NSNumber *number in _controlledSquareToHilight) {
        NSInteger squareToClear = [number integerValue];
        [self clearControlledSquare:squareToClear];
    }
}

- (void) hiLightControlledSquares:(NSArray *)squaresToHilight {
    [self clearHilightControlledSquares];
    _controlledSquareToHilight = [NSArray arrayWithArray:squaresToHilight];
    for (NSNumber *number in _controlledSquareToHilight) {
        NSInteger squareToHilight = [number integerValue];
        [self hiLightControlledSquare:squareToHilight];
    }
}

- (void) clearControlledSquares:(NSArray *)squaresToClear {
    for (NSNumber *number in squaresToClear) {
        NSInteger squareToClear = [number integerValue];
        [self clearControlledSquare:squareToClear];
    }
}

- (void) clearHilightedAndControlledSquares {
    [self clearStartSquare:_squareNumber];
    [self clearHilightControlledSquares];
}

- (PieceButton *) findPieceButtonTapped {
    return [self findPieceBySquareTag:(int)_squareNumber];
}

- (void) hilightCandidatesPiece:(int)squareNumber {
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)v;
            if (iv.tag == _squareNumber) {
                iv.layer.borderColor = [UIColor clearColor].CGColor;
                iv.layer.borderWidth = 0.0;
            }
            if (iv.tag == squareNumber) {
                iv.layer.borderColor = [settingManager getselectedColorTapDestination].CGColor;
                iv.layer.borderWidth = [settingManager borderSelected];
            }
        }
    }
}

- (void) hilightCandidatesPieces:(NSArray *)squareNumbers {
    [self clearCanditatesPieces];
    for (NSNumber *n in squareNumbers) {
        int square = [n intValue];
        UIImageView *iv = [self findSquareByTag:square];
        iv.layer.borderColor = [settingManager getselectedColorTapDestination].CGColor;
        iv.layer.borderWidth = [settingManager borderSelected];
    }
    _canditatesPieces = [NSArray arrayWithArray:squareNumbers];
}

- (void) clearCanditatesPieces {
    for (NSNumber *n in _canditatesPieces) {
        UIImageView *iv = [self findSquareByTag:[n integerValue]];
        iv.layer.borderColor = [UIColor clearColor].CGColor;
        iv.layer.borderWidth = 0.0;
    }
    _canditatesPieces = nil;
}

- (BOOL)candidatesPiecesAreHilighted {
    if (_canditatesPieces) {
        if (_canditatesPieces.count > 0) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) selectedPieceIsCandidatePiece:(int)squareTag {
    //NSLog(@"BoardView Square = %d", squareTag);
    //NSLog(@"BoardView Candidates = %@", _canditatesPieces);
    NSNumber *squareNumber = [NSNumber numberWithInt:squareTag];
    if (_canditatesPieces) {
        if ([_canditatesPieces containsObject:squareNumber]) {
            return YES;
        }
    }
    return NO;
}

- (void) hilightArrivalSquare:(int)arrivalSquare {
    UIImageView *iv = [self findSquareByTag:arrivalSquare];
    UIView *circleView = [[UIView alloc] initWithFrame:[settingManager circleRect]];
    circleView.layer.cornerRadius = [settingManager circleCornerRadius];
    circleView.alpha = 1.0;
    circleView.backgroundColor = [settingManager getselectedColorTapDestination];
    circleView.center = CGPointMake(iv.frame.size.width/2, iv.frame.size.width/2);
    PieceButton *pb = [self findPieceBySquareTag:arrivalSquare];
    if (!pb) {
        [iv addSubview:circleView];
    }
    else {
        [pb addSubview:circleView];
    }
    
    //[self hiLightControlledSquare:arrivalSquare];
}

- (void) clearArrivalSquare:(int)arrivalSquare {
    [self clearControlledSquare:arrivalSquare];
}


@end
