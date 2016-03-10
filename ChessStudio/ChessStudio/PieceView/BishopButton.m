//
//  BishopButton.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "BishopButton.h"

@implementation BishopButton

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
    return @"B";
}

- (void) generaMossePseudoLegali {
    //NSLog(@"Calcola Mosse da Bishop Button %@  in %d", self.titleLabel.text, self.tag);
    [self.pseudoLegalMoves removeAllObjects];
    int nuovaCasa = 0;
    int continua;
    int inBoard;
    for (int direction = 1; direction<=4; direction++) {
        nuovaCasa = (int)self.tag;
        switch (direction) {
            case 1:
                do {
                    nuovaCasa = nuovaCasa + 7;
                    continua = [self.delegate checkTheSquare:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    inBoard = [self.delegate checkConfiniScacchieraPerAlfiere:nuovaCasa - 7 :nuovaCasa];
                    if ((continua  == 0 || continua == 1) && inBoard == 0) {
                        //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                        //continua = [self.delegate checkConfiniScacchieraPerAlfiere:nuovaCasa];
                        //continua = [self.delegate checkConfiniScacchieraPerAlfiere:nuovaCasa - 7 :nuovaCasa];
                    }
                } while ((continua == 0) && (inBoard == 0));
                break;
            case 2:
                do {
                    nuovaCasa = nuovaCasa - 7;
                    continua = [self.delegate checkTheSquare:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    inBoard = [self.delegate checkConfiniScacchieraPerAlfiere:nuovaCasa + 7 :nuovaCasa];
                    if ((continua  == 0 || continua == 1) && inBoard == 0) {
                        //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                        //continua = [self.delegate checkConfiniScacchieraPerAlfiere:nuovaCasa];
                        //continua = [self.delegate checkConfiniScacchieraPerAlfiere:nuovaCasa + 7 :nuovaCasa];
                    }
                } while ((continua == 0) && (inBoard == 0));
                break;
            case 3:
                do {
                    nuovaCasa = nuovaCasa + 9;
                    continua = [self.delegate checkTheSquare:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    inBoard = [self.delegate checkConfiniScacchieraPerAlfiere:nuovaCasa - 9 :nuovaCasa];
                    if ((continua  == 0 || continua == 1) && inBoard == 0) {
                        //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                        //continua = [self.delegate checkConfiniScacchieraPerAlfiere:nuovaCasa];
                        //continua = [self.delegate checkConfiniScacchieraPerAlfiere:nuovaCasa - 9 :nuovaCasa];
                    }
                } while ((continua == 0) && (inBoard == 0));
                break;
            case 4:
                do {
                    nuovaCasa = nuovaCasa - 9;
                    continua = [self.delegate checkTheSquare:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    inBoard = [self.delegate checkConfiniScacchieraPerAlfiere:nuovaCasa + 9 :nuovaCasa];
                    if ((continua  == 0 || continua == 1) && inBoard == 0) {
                        //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                        //continua = [self.delegate checkConfiniScacchieraPerAlfiere:nuovaCasa];
                        //continua = [self.delegate checkConfiniScacchieraPerAlfiere:nuovaCasa + 9 :nuovaCasa];
                    }
                } while ((continua == 0) && (inBoard == 0));
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
