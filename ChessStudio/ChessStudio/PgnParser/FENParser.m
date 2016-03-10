//
//  FENParser.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 09/09/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "FENParser.h"

@interface FENParser() {
    NSString *_fen;
    NSString *_colorToMove;
    BOOL _whiteHasToMove;
    
    BOOL arroccoCortoBianco;
    BOOL arroccoCortoNero;
    BOOL arroccoLungoBianco;
    BOOL arroccoLungoNero;
    
    BOOL possibilePresaEnPassant;
    NSString *casaEnPassant;
    
    NSUInteger numeroSemimosseDaUltimaMossaPedoneOPresa;
    NSUInteger numeroSemiMossa;
    NSString *numeroMossa;
    NSUInteger startPlycount;
}

@end

@implementation FENParser

- (id) initWithFen:(NSString *)fen {
    self = [super init];
    if (self) {
        _fen = fen;
        [self parseFen];
    }
    return self;
}

- (NSString *) getFen {
    //NSLog(@"FEN: %@", _fen);
    return _fen;
}

//- (void) parseFen3 {
//    NSMutableCharacterSet *quadre = [[NSMutableCharacterSet alloc] init];
//    [quadre addCharactersInString:@"[]"];
//    NSMutableCharacterSet *doppiApici = [[NSMutableCharacterSet alloc] init];
//    [doppiApici addCharactersInString:@"\""];
//    
//    
//    NSArray *fenArray = [_fen componentsSeparatedByString:@" "];
//    if (fenArray.count < 6) {
//        
//    }
//}

- (void) parseFen2 {
    //NSLog(@"********   Inizio Parse Fen2 in FenParser *********");
    
    NSMutableArray *fenPosition = (NSMutableArray *)[_fen componentsSeparatedByString:@"/"];
    NSString *stringControl = [fenPosition objectAtIndex:fenPosition.count - 1];
    NSMutableArray *fenControl = (NSMutableArray *)[stringControl componentsSeparatedByString:@" "];
    
    [fenPosition replaceObjectAtIndex:fenPosition.count - 1 withObject:[fenControl objectAtIndex:0]];
    [fenControl removeObjectAtIndex:0];
    
    _colorToMove = [fenControl objectAtIndex:0];
    if ([_colorToMove isEqualToString:@"w"]) {
        _whiteHasToMove = YES;
    }
    else {
        _whiteHasToMove = NO;
    }
    
    NSString *arroccoControl = [fenControl objectAtIndex:1];
    const char *arroccoControlChar = [arroccoControl UTF8String];
    for (int i=0; i<arroccoControl.length; i++) {
        NSString *ch = [NSString stringWithFormat:@"%c", arroccoControlChar[i]];
        if ([ch isEqualToString:@"-"]) {
            arroccoCortoBianco = NO;
            arroccoCortoNero = NO;
            arroccoLungoBianco = NO;
            arroccoLungoNero = NO;
            //NSLog(@"Non sono permessi arrocchi da ambo le parti");
        }
        else if ([ch isEqualToString:@"K"] || [ch isEqualToString:@"H"]) {
            arroccoCortoBianco = YES;
            //NSLog(@"Il Bianco può arroccare corto");
        }
        else if ([ch isEqualToString:@"Q"] || [ch isEqualToString:@"A"]) {
            arroccoLungoBianco = YES;
            //NSLog(@"Il Bianco può arroccare lungo");
        }
        else if ([ch isEqualToString:@"k"] || [ch isEqualToString:@"h"]) {
            arroccoCortoNero = YES;
            //NSLog(@"Il Nero può arroccare corto");
        }
        else if ([ch isEqualToString:@"q"] || [ch isEqualToString:@"a"]) {
            arroccoLungoNero = YES;
            //NSLog(@"Il Nero può arroccare lungo");
        }
    }
    
    casaEnPassant = [fenControl objectAtIndex:2];
    if ([casaEnPassant isEqualToString:@"-"]) {
        possibilePresaEnPassant = NO;
        //NSLog(@"Non ci sono prese en passant");
    }
    else {
        possibilePresaEnPassant = YES;
        //NSLog(@"Presa en passant possibile nella casa %@", casaEnPassant);
    }
    
    //Gestione mosse senza mosse di Pedone e senza catture
    NSString *ns = [fenControl objectAtIndex:3];
    numeroSemimosseDaUltimaMossaPedoneOPresa = [ns integerValue];
    //NSLog(@"Numero semimosse senza movimenti di Pedone o catture = %d", numeroSemimosseDaUltimaMossaPedoneOPresa);
    
    NSString *numeroPrimaMossa = [fenControl objectAtIndex:4];
    //NSLog(@"Numero prima Mossa = %@", numeroPrimaMossa);
    numeroMossa = numeroPrimaMossa;
    NSUInteger numPrimaMossa = [numeroPrimaMossa integerValue];
    if (_whiteHasToMove) {
        startPlycount = (numPrimaMossa * 2) - 1;
    }
    else {
        startPlycount = (numPrimaMossa * 2) - 1;
    }
    numeroSemiMossa = startPlycount;
    
    
    //NSLog(@"*******  Fine Parse Fen2 in FenParser ********");
}


- (void) parseFen {

    [self parseFen2];
    return;
    //NSLog(@"********   Inizio Parse Fen in FenParser *********");
    
    //NSLog(@"FEN = %@", _fen);
    
    NSMutableArray *fenPosition = (NSMutableArray *)[_fen componentsSeparatedByString:@"/"];
    NSString *stringControl = [fenPosition objectAtIndex:fenPosition.count - 1];
    NSMutableArray *fenControl = (NSMutableArray *)[stringControl componentsSeparatedByString:@" "];
    
    [fenPosition replaceObjectAtIndex:fenPosition.count - 1 withObject:[fenControl objectAtIndex:0]];
    [fenControl removeObjectAtIndex:0];
    
    //NSCharacterSet *upperCaseSet = [NSCharacterSet uppercaseLetterCharacterSet];
    
    //for (NSString *riga in fenPosition) {
    //    NSLog(@"%@", riga);
    //}
    
    //for (NSString *riga in fenControl) {
    //    NSLog(@"%@", riga);
    //}
    
    _colorToMove = [fenControl objectAtIndex:0];
    if ([_colorToMove isEqualToString:@"w"]) {
        _whiteHasToMove = YES;
    }
    else {
        _whiteHasToMove = NO;
    }
    
    
    //Controllo degli Arrocchi
    NSString *arroccoControl = [fenControl objectAtIndex:1];
    //NSLog(@"ARROCCO CONTROL = %@", arroccoControl);
    const char *arroccoControlChar = [arroccoControl UTF8String];
    for (int i=0; i<arroccoControl.length; i++) {
        NSString *ch = [NSString stringWithFormat:@"%c", arroccoControlChar[i]];
        if ([ch isEqualToString:@"-"]) {
            arroccoCortoBianco = NO;
            arroccoCortoNero = NO;
            arroccoLungoBianco = NO;
            arroccoLungoNero = NO;
            //NSLog(@"Non sono permessi arrocchi da ambo le parti");
        }
        else if ([ch isEqualToString:@"K"] || [ch isEqualToString:@"H"]) {
            arroccoCortoBianco = YES;
            //NSLog(@"Il Bianco può arroccare corto");
        }
        else if ([ch isEqualToString:@"Q"] || [ch isEqualToString:@"A"]) {
            arroccoLungoBianco = YES;
            //NSLog(@"Il Bianco può arroccare lungo");
        }
        else if ([ch isEqualToString:@"k"] || [ch isEqualToString:@"h"]) {
            arroccoCortoNero = YES;
            //NSLog(@"Il Nero può arroccare corto");
        }
        else if ([ch isEqualToString:@"q"] || [ch isEqualToString:@"a"]) {
            arroccoLungoNero = YES;
            //NSLog(@"Il Nero può arroccare lungo");
        }
    }
    
    
    //Controllo Mosse En Passant
    casaEnPassant = [fenControl objectAtIndex:2];
    
    if ([casaEnPassant isEqualToString:@"-"]) {
        possibilePresaEnPassant = NO;
        //NSLog(@"Non ci sono prese en passant");
    }
    else {
        possibilePresaEnPassant = YES;
        //NSLog(@"Presa en passant possibile nella casa %@", casaEnPassant);
    }
    
    
    //Gestione mosse senza mosse di Pedone e senza catture
    NSString *ns = [fenControl objectAtIndex:3];
    numeroSemimosseDaUltimaMossaPedoneOPresa = [ns integerValue];
    //NSLog(@"Numero semimosse senza movimenti di Pedone o catture = %lu", (unsigned long)numeroSemimosseDaUltimaMossaPedoneOPresa);
    
    //Gestione numero mosse
    //NSString *nmString = [fenControl objectAtIndex:4];
    //numeroMossa = nmString;
    //NSInteger nm = [nmString integerValue];
    numeroMossa = @"1";
    NSUInteger nm = 1;//Il numero semimosse viene posto = 1 perchè supponiamo che in un posizione si parta sempre dalla mossa n.1. Si vedrà in seguito se gestire una numerazione diversa.
    
    if (nm == 1) {
        if (_whiteHasToMove) {
            numeroSemiMossa = 0;
        }
        else {
            numeroSemiMossa = 1;
        }
    }
    else {
        nm--;
        if (_whiteHasToMove) {
            numeroSemiMossa = nm*2;
        }
        else {
            numeroSemiMossa = nm*2 + 1;
        }
    }
    
    //NSLog(@"NUMERO SEMIMOSSE CALCOLATO IN FEN PARSER = %d con mossa al %@", numeroSemiMossa, _colorToMove);
    
    //NSLog(@"*******  Fine Parse Fen in FenParser ********");
}


- (NSString *) getColorToMove {
    return _colorToMove;
}

- (BOOL) whiteHasToMove {
    return _whiteHasToMove;
}

- (BOOL) biancoPuoArroccareCorto {
    return arroccoCortoBianco;
}

- (BOOL) biancoPuoArroccareLungo {
    return arroccoLungoBianco;
}

- (BOOL) neroPuoArroccareCorto {
    return arroccoCortoNero;
}

- (BOOL) neroPuoArroccareLungo {
    return arroccoLungoNero;
}

- (BOOL) presaEnPassantPossibile {
    return possibilePresaEnPassant;
}

- (NSString *) getCasaEnPassant {
    return casaEnPassant;
}

- (NSUInteger) getNumeroSemimosseDaUltimaoPedoneMossoOPresa {
    return numeroSemimosseDaUltimaMossaPedoneOPresa;
}

- (NSUInteger) getNumeroSemiMossa {
    return numeroSemiMossa;
}

- (NSString *) getNumeroMossa {
    return numeroMossa;
}

- (NSString *) getNumeroMossaToDisplay {
    if (_whiteHasToMove) {
        return [numeroMossa stringByAppendingString:@". "];
    }
    else {
        return [numeroMossa stringByAppendingString:@". XXX "];
    }
}

- (NSString *) getPrimaMossaConUnPunto {
    return [numeroMossa stringByAppendingString:@"."];
}

- (NSString *) getPrimaMossaConTrePunti {
    return [numeroMossa stringByAppendingString:@"..."];
}

@end
