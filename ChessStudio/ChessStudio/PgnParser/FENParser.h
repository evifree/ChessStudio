//
//  FENParser.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 09/09/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FENParser : NSObject

- (id) initWithFen:(NSString *)fen;

- (NSString *) getFen;

- (NSString *) getColorToMove;
- (BOOL) whiteHasToMove;

- (BOOL) biancoPuoArroccareCorto;
- (BOOL) biancoPuoArroccareLungo;
- (BOOL) neroPuoArroccareCorto;
- (BOOL) neroPuoArroccareLungo;
- (BOOL) presaEnPassantPossibile;
- (NSString *) getCasaEnPassant;

- (NSUInteger) getNumeroSemimosseDaUltimaoPedoneMossoOPresa;
- (NSUInteger) getNumeroSemiMossa;
- (NSString *) getNumeroMossa;
- (NSString *) getNumeroMossaToDisplay;

- (NSString *) getPrimaMossaConUnPunto;
- (NSString *) getPrimaMossaConTrePunti;

@end
