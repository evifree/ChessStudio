//
//  KingButton.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "KingButton.h"

@implementation KingButton

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
    return @"K";
}

- (void) generaMossePseudoLegali {
    //NSLog(@"Calcola Mosse da King Button  %@  in %d", self.titleLabel.text, self.tag);
    [self.pseudoLegalMoves removeAllObjects];
    unsigned int nuovaCasa = 0;
    BOOL continua;
    int inBoard;
    for (int direction = 1; direction<=8; direction++) {
        nuovaCasa = (int)self.tag;
        switch (direction) {
            case 1:
                nuovaCasa = nuovaCasa + 8;
                continua = [self.delegate checkTheSquareForKing:nuovaCasa :self.titleLabel.text :(int)self.tag];
                inBoard = [self.delegate checkConfiniScacchieraPerDonnaRe:nuovaCasa - 8 :nuovaCasa];
                if ((continua  == 0 || continua == 1) && inBoard == 0) {
                    //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                    [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    }
                break;
            case 2:
                nuovaCasa = nuovaCasa - 8;
                continua = [self.delegate checkTheSquareForKing:nuovaCasa :self.titleLabel.text :(int)self.tag];
                inBoard = [self.delegate checkConfiniScacchieraPerDonnaRe:nuovaCasa + 8 :nuovaCasa];
                if ((continua  == 0 || continua == 1) && inBoard == 0) {
                    //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                    [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                }
                break;
            case 3:
                nuovaCasa = nuovaCasa + 1;
                continua = [self.delegate checkTheSquareForKing:nuovaCasa :self.titleLabel.text :(int)self.tag];
                inBoard = [self.delegate checkConfiniScacchieraPerDonnaRe:nuovaCasa - 1 :nuovaCasa];
                if ((continua  == 0 || continua == 1) && inBoard == 0) {
                    //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                    [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    //Gestione Arrocco corto
                    if ([self.titleLabel.text hasPrefix:@"w"] && (self.tag != 4)) {
                        break;
                    }
                    if ([self.titleLabel.text hasPrefix:@"b"] && (self.tag != 60)) {
                        break;
                    }
                    
                    nuovaCasa = nuovaCasa + 1;
                    continua = [self.delegate checkTheSquareForKing:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    if (continua == 0 || continua == 1) {
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    }
                }
                break;
            case 4:
                nuovaCasa = nuovaCasa - 1;
                continua = [self.delegate checkTheSquareForKing:nuovaCasa :self.titleLabel.text :(int)self.tag];
                inBoard = [self.delegate checkConfiniScacchieraPerDonnaRe:nuovaCasa + 1 :nuovaCasa];
                if ((continua  == 0 || continua == 1) && inBoard == 0) {
                    //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                    [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    //Gestione Arrocco Lungo
                    
                    if ([self.titleLabel.text hasPrefix:@"w"] && (self.tag != 4)) {
                        break;
                    }
                    if ([self.titleLabel.text hasPrefix:@"b"] && (self.tag != 60)) {
                        break;
                    }
                    
                    
                    nuovaCasa = nuovaCasa - 1;
                    continua = [self.delegate checkTheSquareForKing:nuovaCasa :self.titleLabel.text :(int)self.tag];
                    if (continua == 0 || continua == 1) {
                        [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                    }
                }
                break;
            case 5:
                nuovaCasa = nuovaCasa + 7;
                continua = [self.delegate checkTheSquareForKing:nuovaCasa :self.titleLabel.text :(int)self.tag];
                inBoard = [self.delegate checkConfiniScacchieraPerDonnaRe:nuovaCasa - 7 :nuovaCasa];
                if ((continua  == 0 || continua == 1) && inBoard == 0) {
                    //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                    [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                }
                break;
            case 6:
                nuovaCasa = nuovaCasa - 7;
                continua = [self.delegate checkTheSquareForKing:nuovaCasa :self.titleLabel.text :(int)self.tag];
                inBoard = [self.delegate checkConfiniScacchieraPerDonnaRe:nuovaCasa + 7 :nuovaCasa];
                if ((continua  == 0 || continua == 1) && inBoard == 0) {
                    //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                    [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                }
                break;
            case 7:
                nuovaCasa = nuovaCasa + 9;
                continua = [self.delegate checkTheSquareForKing:nuovaCasa :self.titleLabel.text :(int)self.tag];
                inBoard = [self.delegate checkConfiniScacchieraPerDonnaRe:nuovaCasa - 9 :nuovaCasa];
                if ((continua  == 0 || continua == 1) && inBoard == 0) {
                    //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                    [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
                }
                break;
            case 8:
                nuovaCasa = nuovaCasa - 9;
                continua = [self.delegate checkTheSquareForKing:nuovaCasa :self.titleLabel.text :(int)self.tag];
                inBoard = [self.delegate checkConfiniScacchieraPerDonnaRe:nuovaCasa + 9 :nuovaCasa];
                if ((continua  == 0 || continua == 1) && inBoard == 0) {
                    //NSLog(@"Pezzo. %@ %d", self.titleLabel.text, nuovaCasa);
                    [self.pseudoLegalMoves addObject:[NSNumber numberWithInt:nuovaCasa]];
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
