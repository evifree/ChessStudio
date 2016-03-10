//
//  PawnButton.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "PawnButton.h"

@implementation PawnButton

@synthesize pseudoAttackSquares = _pseudoAttackSquares;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _pseudoAttackSquares = [[NSMutableSet alloc] init];
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

- (NSString *) getSimbolo {
    return @"";
}

- (void) generaMossePseudoLegali {
    //NSLog(@"Calcola Mosse da Pawn Button  %@  in  %d", self.titleLabel.text, self.tag);
    [self.pseudoLegalMoves removeAllObjects];
    [_pseudoAttackSquares removeAllObjects];
    unsigned int nuovaCasa = 0;
    int continua;
    int inBoard;
    nuovaCasa = (int)self.tag;
    if ([self.titleLabel.text hasPrefix:@"w"]) {
        nuovaCasa = nuovaCasa + 8;
        continua = [self.delegate checkTheSquareForPawn:nuovaCasa :self.titleLabel.text :(int)self.tag];
        inBoard = [self.delegate checkConfiniScacchieraPerPedone:nuovaCasa - 8 :nuovaCasa];
        if (continua == 0 && inBoard == 0) {
            //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
            [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
            if (self.tag >= 8   &&  self.tag <= 15) {
                nuovaCasa = nuovaCasa + 8;
                continua = [self.delegate checkTheSquareForPawn:nuovaCasa :self.titleLabel.text :(int)self.tag];
                inBoard = [self.delegate checkConfiniScacchieraPerPedone:nuovaCasa - 8 :nuovaCasa];
                if (continua == 0 && inBoard == 0) {
                    //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                    [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                }
            }
        }
        //////////////
        
        nuovaCasa = (int)self.tag + 9;
        continua = [self.delegate checkTheSquareForPawn:nuovaCasa :self.titleLabel.text :(int)self.tag];
        inBoard = [self.delegate checkConfiniScacchieraPerPedone:nuovaCasa - 9 :nuovaCasa];
        if (continua == 0 && inBoard == 0) {
            //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
            [_pseudoAttackSquares addObject:[NSNumber numberWithInt:nuovaCasa]];
            [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
        }
        nuovaCasa = (int)self.tag + 7;
        continua = [self.delegate checkTheSquareForPawn:nuovaCasa :self.titleLabel.text :(int)self.tag];
        inBoard = [self.delegate checkConfiniScacchieraPerPedone:nuovaCasa - 7 :nuovaCasa];
        if (continua == 0 && inBoard == 0) {
            //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
            [_pseudoAttackSquares addObject:[NSNumber numberWithInt:nuovaCasa]];
            [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
        }
        return;
    }
    if ([self.titleLabel.text hasPrefix:@"b"]) {
        nuovaCasa = nuovaCasa - 8;
        continua = [self.delegate checkTheSquareForPawn:nuovaCasa :self.titleLabel.text :(int)self.tag];
        inBoard = [self.delegate checkConfiniScacchieraPerPedone:nuovaCasa + 8 :nuovaCasa];
        if (continua == 0 && inBoard == 0) {
            //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
            [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
            if (self.tag >= 48 && self.tag <= 55) {
                nuovaCasa = nuovaCasa - 8;
                continua = [self.delegate checkTheSquareForPawn:nuovaCasa :self.titleLabel.text :(int)self.tag];
                inBoard = [self.delegate checkConfiniScacchieraPerPedone:nuovaCasa + 8 :nuovaCasa];
                if (continua == 0 && inBoard == 0) {
                    //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                    [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                }
            }
        }
        ///////////////
        nuovaCasa = (int)self.tag - 9;
        continua = [self.delegate checkTheSquareForPawn:nuovaCasa :self.titleLabel.text :(int)self.tag];
        inBoard = [self.delegate checkConfiniScacchieraPerPedone:nuovaCasa + 9 :nuovaCasa];
        if (continua == 0 && inBoard == 0) {
            //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
            [_pseudoAttackSquares addObject:[NSNumber numberWithInt:nuovaCasa]];
            [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
        }
        nuovaCasa = (int)self.tag - 7;
        continua = [self.delegate checkTheSquareForPawn:nuovaCasa :self.titleLabel.text :(int)self.tag];
        inBoard = [self.delegate checkConfiniScacchieraPerPedone:nuovaCasa + 7 :nuovaCasa];
        if (continua == 0 && inBoard == 0) {
            //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
            [_pseudoAttackSquares addObject:[NSNumber numberWithInt:nuovaCasa]];
            [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
        }
    }
}

- (NSMutableSet *) generaMosse {
    [self generaMossePseudoLegali];
    return self.pseudoLegalMoves;
}

- (void) stampaMossePseudoLegali {
    for (NSNumber *n in [_pseudoAttackSquares allObjects]) {
        int nc = [n intValue];
        NSLog(@"CASA POSSIBILE = %d", nc);
    }
}


@end
