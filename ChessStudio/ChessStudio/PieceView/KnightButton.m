//
//  KnightButton.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "KnightButton.h"

@implementation KnightButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
    return @"N";
}

- (void) generaMossePseudoLegali {
    //NSLog(@"Calcola Mosse da Knight Button  %@  in %d", self.titleLabel.text, self.tag);
    [self.pseudoLegalMoves removeAllObjects];
    unsigned int nuovaCasa = 0;
    BOOL continua;
    for (int direction = 1; direction<=8; direction++) {
        nuovaCasa = (int)self.tag;
        switch (direction) {
            case 1:
                nuovaCasa = nuovaCasa + 10;
                if ([self.delegate checkConfiniScacchieraPerCavallo:nuovaCasa - 10 :nuovaCasa] == 0) {
                    continua = [self.delegate checkTheSquare:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    if (continua == 0 || continua == 1) {
                        //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    }
                }
                break;
            case 2:
                nuovaCasa = nuovaCasa - 10;
                if ([self.delegate checkConfiniScacchieraPerCavallo:nuovaCasa + 10 :nuovaCasa] == 0) {
                    continua = [self.delegate checkTheSquare:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    if (continua == 0 || continua == 1) {
                        //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    }
                }
                break;
            case 3:
                nuovaCasa = nuovaCasa + 6;
                if ([self.delegate checkConfiniScacchieraPerCavallo:nuovaCasa - 6 :nuovaCasa] == 0) {
                    continua = [self.delegate checkTheSquare:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    if (continua == 0 || continua == 1) {
                        //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    }
                }
                break;
            case 4:
                nuovaCasa = nuovaCasa - 6;
                if ([self.delegate checkConfiniScacchieraPerCavallo:nuovaCasa + 6 :nuovaCasa] == 0) {
                    continua = [self.delegate checkTheSquare:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    if (continua == 0 || continua == 1) {
                        //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    }
                }
                break;
            case 5:
                nuovaCasa = nuovaCasa + 17;
                if ([self.delegate checkConfiniScacchieraPerCavallo:nuovaCasa - 17 :nuovaCasa] == 0) {
                    continua = [self.delegate checkTheSquare:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    if (continua == 0 || continua == 1) {
                        //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    }
                }
                break;
            case 6:
                nuovaCasa = nuovaCasa - 17;
                if ([self.delegate checkConfiniScacchieraPerCavallo:nuovaCasa + 17 :nuovaCasa] == 0) {
                    continua = [self.delegate checkTheSquare:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    if (continua == 0 || continua == 1) {
                        //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    }
                }
                break;
            case 7:
                nuovaCasa = nuovaCasa + 15;
                if ([self.delegate checkConfiniScacchieraPerCavallo:nuovaCasa - 15 :nuovaCasa] == 0) {
                    continua = [self.delegate checkTheSquare:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    if (continua == 0 || continua == 1) {
                        //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    }
                }
                break;
            case 8:
                nuovaCasa = nuovaCasa - 15;
                if ([self.delegate checkConfiniScacchieraPerCavallo:nuovaCasa + 15 :nuovaCasa] == 0) {
                    continua = [self.delegate checkTheSquare:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    if (continua == 0 || continua == 1) {
                        //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    }
                }
                break;
            default:
                break;
        }
    }
}

- (NSMutableSet *) generaMosse {
    [self generaMossePseudoLegali];
    return self.pseudoLegalMoves;
}

@end
