//
//  PGNMoveAnnotation.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 23/10/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PGNMoveAnnotation.h"

@interface PGNMoveAnnotation() {
    
    NSCharacterSet *digitSet;

    NSString *giudizioMossa;   //una delle 7 notazioni 0-6
    
    NSString *unicaMossa;
    NSString *novitaTeorica;
    
    NSMutableArray *listOfNag;
}

@end

@implementation PGNMoveAnnotation

- (id) init {
    self = [super init];
    if (self) {
        digitSet = [NSCharacterSet decimalDigitCharacterSet];
        [self initMoveAnnotation];
    }
    return self;
}


- (void) initMoveAnnotation {
    giudizioMossa = @"$0";
    unicaMossa = nil;
    novitaTeorica = nil;
    listOfNag = [[NSMutableArray alloc] init];
    [listOfNag addObject:giudizioMossa];
}


- (void) addNag:(NSString *)nag {
    [listOfNag addObject:nag];
}


- (BOOL) nagIsCorrect:(NSString *)nag {
    //Controllo che nag esiste
    if (!nag) {
        NSLog(@"NAG non esiste");
        return NO;
    }
    
    //controllo che nag inizi con $
    if (![nag hasPrefix:@"$"]) {
        NSLog(@"NAG non inizia con $");
        return NO;
    }
    
    //controllo che la parte di nag dopo il $ sia un numero
    NSString *stringNumberAfter$ = [nag substringFromIndex:1];
    NSCharacterSet *nagStringSet = [NSCharacterSet characterSetWithCharactersInString:stringNumberAfter$];
    
    if (![digitSet isSupersetOfSet:nagStringSet]) {
        NSLog(@"NAG non contiene sono numeri dopo $");
        return NO;
    }
    
    //Trasformo la string in numero e controllo che non sia maggiore di 255
    NSInteger nagNumber = nagNumber = [stringNumberAfter$ integerValue];
    if (nagNumber > 255) {
        NSLog(@"Numero NAG maggiore di 255");
        return NO;
    }
    
    return YES;
}

- (void) setNag:(NSString *)nag {
    
    if (![self nagIsCorrect:nag]) {
        NSLog(@"NAG NON È CORRETTO");
        return;
    }

    NSString *stringNumberAfter$ = [nag substringFromIndex:1];
    NSInteger nagNumber = nagNumber = [stringNumberAfter$ integerValue];
    
    switch (nagNumber) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
            [listOfNag replaceObjectAtIndex:[listOfNag indexOfObject:giudizioMossa] withObject:nag];
            giudizioMossa = nag;
            break;
        case 7:
            unicaMossa = nag;
            if (![listOfNag containsObject:nag]) {
                [listOfNag addObject:nag];
            }
            break;
        case 146:
            novitaTeorica = nag;
            if (![listOfNag containsObject:nag]) {
                [listOfNag addObject:nag];
            }
            break;
        default:
            if (![listOfNag containsObject:nag]) {
                [listOfNag addObject:nag];
            }
            break;
    }
}

- (void) removeNag:(NSString *)nag {
    if (![self nagIsCorrect:nag]) {
        NSLog(@"NAG NON È CORRETTO");
        return;
    }
    
    NSString *stringNumberAfter$ = [nag substringFromIndex:1];
    NSInteger nagNumber = nagNumber = [stringNumberAfter$ integerValue];
    
    switch (nagNumber) {
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
            [listOfNag replaceObjectAtIndex:[listOfNag indexOfObject:giudizioMossa] withObject:@"$0"];
            giudizioMossa = @"$0";
            break;
        case 7:
            unicaMossa = nil;
            if ([listOfNag containsObject:nag]) {
                [listOfNag removeObject:nag];
            }
            break;
        case 146:
            novitaTeorica = nil;
            if ([listOfNag containsObject:nag]) {
                [listOfNag removeObject:nag];
            }
            break;
        default:
            if ([listOfNag containsObject:nag]) {
                [listOfNag removeObject:nag];
            }
            break;
    }
}

- (BOOL) containsNag:(NSString *)nag {
    
    if (![self nagIsCorrect:nag]) {
        NSLog(@"NAG NON È CORRETTO");
        return NO;
    }
    
    return [listOfNag containsObject:nag];
}



#pragma mark - Inizio sezione dedicata alla restituzione della mossa con le annotazioni

- (NSString *) getMoveAnnotation {
    
    NSMutableSet *annotationSet = [[NSMutableSet alloc] init];
    [annotationSet addObject:giudizioMossa];
    
    NSMutableString *ma = [[NSMutableString alloc] init];
    
    if (![giudizioMossa isEqualToString:@"$0"]) {
        [ma appendString:@" "];
        [ma appendString:giudizioMossa];
    }
    
    if (unicaMossa) {
        [ma appendString:@" "];
        [ma appendString:unicaMossa];
        [annotationSet addObject:unicaMossa];
    }
    
    if (novitaTeorica) {
        [ma appendString:@" "];
        [ma appendString:novitaTeorica];
        [annotationSet addObject:novitaTeorica];
    }
    
    for (int i=0; i<listOfNag.count; i++) {
        NSString *nag = [listOfNag objectAtIndex:i];
        if (![annotationSet containsObject:nag]) {
            [ma appendString:@" "];
            [ma appendString:nag];
        }
    }
    //NSLog(@"PgnMoveAnnotation getMoveAnnotation: %@", ma);
    return ma;
}

- (NSString *) getWebMoveAnnotation {
    
    NSMutableSet *annotationSet = [[NSMutableSet alloc] init];
    [annotationSet addObject:giudizioMossa];
    
    NSMutableString *ma = [[NSMutableString alloc] init];
    
    if (![giudizioMossa isEqualToString:@"$0"]) {
        [ma appendString:@" "];
        [ma appendString:[PGNUtil nagToSymbol:giudizioMossa]];
    }
    
    if (unicaMossa) {
        [ma appendString:@" "];
        [ma appendString:[PGNUtil nagToSymbol:unicaMossa]];
        [annotationSet addObject:unicaMossa];
    }
    
    if (novitaTeorica) {
        [ma appendString:@" "];
        [ma appendString:[PGNUtil nagToSymbol:novitaTeorica]];
        [annotationSet addObject:novitaTeorica];
    }
    
    for (int i=0; i<listOfNag.count; i++) {
        NSString *nag = [listOfNag objectAtIndex:i];
        if (![annotationSet containsObject:nag]) {
            [ma appendString:@" "];
            [ma appendString:[PGNUtil nagToSymbol:nag]];
        }
    }
    //NSLog(@"PgnMoveAnnotation getMoveAnnotation: %@", ma);
    return ma;
}

- (NSString *) getWebMoveAnnotationForGameMovesWebView {
    
    NSMutableSet *annotationSet = [[NSMutableSet alloc] init];
    [annotationSet addObject:giudizioMossa];
    
    NSMutableString *ma = [[NSMutableString alloc] init];
    
    if (![giudizioMossa isEqualToString:@"$0"]) {
        [ma appendString:@""];
        [ma appendString:[PGNUtil nagToSymbolForGameMovesWebView:giudizioMossa]];
    }
    
    if (unicaMossa) {
        [ma appendString:@""];
        [ma appendString:[PGNUtil nagToSymbolForGameMovesWebView:unicaMossa]];
        [annotationSet addObject:unicaMossa];
    }
    
    if (novitaTeorica) {
        [ma appendString:@""];
        [ma appendString:[PGNUtil nagToSymbolForGameMovesWebView:novitaTeorica]];
        [annotationSet addObject:novitaTeorica];
    }
    
    for (int i=0; i<listOfNag.count; i++) {
        NSString *nag = [listOfNag objectAtIndex:i];
        if (![annotationSet containsObject:nag]) {
            [ma appendString:@""];
            [ma appendString:[PGNUtil nagToSymbolForGameMovesWebView:nag]];
        }
    }
    //NSLog(@"PgnMoveAnnotation getMoveAnnotation: %@", ma);
    return ma;
}


#pragma mark - Metodi per il test

- (void) stampaNag {
    NSMutableString *ma =  [[NSMutableString alloc] init];
    if (listOfNag.count > 0) {
        for (int i=0; i<listOfNag.count; i++) {
            NSString *nag = [listOfNag objectAtIndex:i];
            [ma appendString:nag];
            if (i < listOfNag.count - 1) {
                [ma appendString:@" "];
            }
        }
        NSLog(@"stampa nag PgnMoveAnnotation: %@", ma);
    }
}

@end
