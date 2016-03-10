//
//  PieceButton.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "PieceButton.h"

@interface PieceButton() {

    unsigned int square;
    float dimSquare;
    float dimSquareHalf;
    
    
    PieceButton *startPieceButton;
    
    BOOL flipped;
    
    NSTimeInterval timeStampAtTouchesBegan;
    NSTimeInterval timeStampAtTouchesEnded;
    
}


@end

@implementation PieceButton

@synthesize delegate = _delegate;
@synthesize pseudoLegalMoves = _pseudoLegalMoves;
//@synthesize squareNumber = _squareNumber;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        dimSquare = frame.size.width;
        dimSquareHalf = dimSquare/2;
    }
    return self;
}

- (id) initWithPieceTypeAndPieceSymbol:(NSString *)pieceType :(NSString *)pieceSymbol {
    NSString *path = [[pieceType stringByAppendingString:pieceSymbol] stringByAppendingString:@".png"];
    UIImage *image = [UIImage imageNamed:path];
    [self setBackgroundImage:image forState:UIControlStateNormal];
    self.adjustsImageWhenHighlighted = NO;
    [self setOpaque:YES];
    flipped = NO;
    self.titleLabel.text = pieceSymbol;
    _pseudoLegalMoves = [[NSMutableSet alloc] init];
    
    //_movimenti = [[NSMutableArray alloc] init];
    _simboloColorePezzo = pieceSymbol;
    _colore = [_simboloColorePezzo substringToIndex:1];
    _simboloPezzo = [_simboloColorePezzo substringFromIndex:1];
    
    return self;
}

- (id) initWithPieceTypeAndPieceSymbolAndFlipped:(NSString *)pieceType :(NSString *)pieceSymbol :(BOOL)flip {
    NSString *path = [[pieceType stringByAppendingString:pieceSymbol] stringByAppendingString:@".png"];
    UIImage *image = [UIImage imageNamed:path];
    [self setBackgroundImage:image forState:UIControlStateNormal];
    self.adjustsImageWhenHighlighted = NO;
    [self setOpaque:YES];
    flipped = flip;
    self.titleLabel.text = pieceSymbol;
    _pseudoLegalMoves = [[NSMutableSet alloc] init];
    
    //_movimenti = [[NSMutableArray alloc] init];
    _simboloColorePezzo = pieceSymbol;
    _colore = [_simboloColorePezzo substringToIndex:1];
    _simboloPezzo = [_simboloColorePezzo substringFromIndex:1];
    
    if (flipped) {
        [self flip];
    }
    
    return self;
}

- (void) modifyPieceImage:(NSString *)pieceType {
    NSString *path = [[pieceType stringByAppendingString:_simboloColorePezzo] stringByAppendingString:@".png"];
    UIImage *image = [UIImage imageNamed:path];
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSString *) getSimbolo {
    return nil;
}

- (void)flip {
    flipped = !flipped;
    
    [UIView animateWithDuration:0 animations:^{
        self.transform = CGAffineTransformRotate(self.transform, M_PI);
    }];
}

- (void)setSquareValue:(unsigned int)squareValue {
    
    float fx;
    float fy;
    
    square = squareValue;
    
    fx = (float) ( square % 8 ) * dimSquare;
    fy = (dimSquare * 7) -floor( square / 8 ) * dimSquare;
    
    
	[self setCenter:CGPointMake(fx + dimSquareHalf,fy + dimSquareHalf)];
    self.tag = squareValue;
    
    //NSLog(@"setSquareValue: fx:%f  ----   fy:%f --- tag:%d", fx, fy, squareValue);
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"Bottone con tag %ld toccato e pezzo %@", (long)self.tag, self.titleLabel.text);
    //NSLog(@"Descrizione: %@", self.description);
    //[self.superview touchesBegan:touches withEvent:event];
    
    
    if (!_delegate) {
        return;
    }
    
    
    if ([_delegate isSetupPosition]) {
        [_delegate checkSetupPosition:self.tag];
        return;
    }
    
    
    UITouch *touchBegan = [touches anyObject];
    timeStampAtTouchesBegan = [touchBegan timestamp];
    
    
    UIView *v = [self superview];
    [v bringSubviewToFront:self];
    
    [self generaMossePseudoLegali];
    
    
    //[self stampaMossePseudoLegali];
    
    
    [_delegate setCasaPartenza:(int)self.tag];
    
    
    return;
    
    
    NSArray *subView = [v subviews];
    for (UIView *sv in subView) {
        if ([sv isKindOfClass:[PieceButton class]]) {
            startPieceButton = (PieceButton *)sv;
            if (startPieceButton.tag == self.tag) {
                NSLog(@"pezzo start %@", startPieceButton.description);
                [_delegate setCasaPartenza:startPieceButton.tag];
                return;
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //NSLog(@"Touches Moved");
    
    if ([_delegate isSetupPosition]) {
        return;
    }
    
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
    
    //NSLog(@"Touches Ended");
    
    if ([_delegate isSetupPosition]) {
        return;
    }
    
    
    UITouch *touchEnded = [touches anyObject];
    timeStampAtTouchesEnded = [touchEnded timestamp];
    
    if ((timeStampAtTouchesEnded - timeStampAtTouchesBegan) < 0.1) {
        //NSLog(@"Devo gestire un tocco breve");
        
        //if (![_delegate checkTapPieceToMove]) {
            //return;
        //}
        
        
        [_delegate gestisciToccoBreve:self];
        [self setSquareValue:(int)self.tag];
        return;
    }
    else {
        //NSLog(@"Non devo gestire un tocco breve");
        [_delegate gestisciDragAndDrop:self];
        if (![_delegate checkDragAndDrop]) {
            [self setSquareValue:(int)self.tag];
            return;
        }
    }
    
    
    UIView *bv = [self superview];
    NSArray *subView = [bv subviews];
    for (UIView *sv in subView) {
        if ([sv isKindOfClass:[UIImageView class]]) {
            if (CGRectContainsPoint(sv.frame, self.center)) {
                
                if (!_delegate) {
                    [self setSquareValue:(int)self.tag];
                    return;
                }
    
                if ([_delegate reSottoScacco:(int)sv.tag]) {
                    [self setSquareValue:(int)self.tag];
                    return;
                }
                
                int controlloCasaArrivo = [_delegate checkCasaArrivo:(int)sv.tag];
                //NSLog(@"Controllo casa arrivo = %d", controlloCasaArrivo);
                if (controlloCasaArrivo == -1) {
                    [self setSquareValue:(int)self.tag];
                    return;
                }
                
                if (controlloCasaArrivo == -2) {
                    //NSLog(@"Devo gestire la promozione del pedone");
                    [self setSquareValue:(int)sv.tag];
                    return;
                }
                //[_movimenti addObject:[NSNumber numberWithInt:sv.tag]];
                [self setSquareValue:(int)sv.tag];
                //[_delegate stampaMossaCompleta];
                [_delegate gestisciMossaCompleta];
                return;
            }
        }
    }
    [self setSquareValue:(int)self.tag];
}

- (void) generaMossePseudoLegali {
    NSLog(@"Calcola Mosse da Piece Button");
}

- (void) stampaMossePseudoLegali {
    NSLog(@"Stampo mosse pseudolegali");
}

- (NSMutableSet *) generaMosse {
    return nil;
}

@end
