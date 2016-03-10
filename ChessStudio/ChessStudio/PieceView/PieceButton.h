//
//  PieceButton.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 14/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieceButton;


@protocol PieceButtonDelegate <NSObject>

- (void) setCasaPartenza:(int)fromSquareTag;
- (void) setCasaArrivo:(int)toSquareTag;
- (int)  checkCasaArrivo:(int)toSquareTag;
//- (void) stampaMossaCompleta;
- (void) gestisciMossaCompleta;
- (int) checkTheSquare:(int)squareNumber :(NSString *)pieceToMove :(int)squareValue;
- (int) checkTheSquareForPawn:(int)squareNumber :(NSString *)pieceToMove :(int)squareValue;
- (int) checkTheSquareForKing:(int)squareNumber :(NSString *)pieceToMove :(int)squareValue;
- (BOOL) reSottoScacco:(int)toSquareTag;

//- (int) checkConfiniScacchieraPerAlfiere:(int)squareNumber;
- (int) checkConfiniScacchieraPerPedone:(int)casaOrigine :(int)casaDestinazione;
- (int) checkConfiniScacchieraPerAlfiere:(int)casaOrigine :(int)casaDestinazione;
- (int) checkConfiniScacchieraPerTorre:(int)casaOrigine :(int)casaDestinazione;
- (int) checkConfiniScacchieraPerCavallo:(int)casaOrigine :(int)casaDestinazione;
- (int) checkConfiniScacchieraPerDonnaRe:(int)casaOrigine :(int)casaDestinazione;

- (void) gestisciToccoBreve:(PieceButton *)pieceButton;
- (void) gestisciDragAndDrop:(PieceButton *)pieceButton;
- (BOOL) checkDragAndDrop;
//- (BOOL) checkTapPieceToMove;

- (BOOL) isSetupPosition;
- (void) checkSetupPosition:(NSUInteger)squareTag;

@end


@interface PieceButton : UIButton


@property (nonatomic, assign) id<PieceButtonDelegate> delegate;
@property (nonatomic, strong) NSMutableSet *pseudoLegalMoves;
//@property (nonatomic) unsigned int squareNumber;
@property (nonatomic) NSUInteger casaIniziale;

//@property (nonatomic, strong) NSMutableArray *movimenti;
@property (nonatomic, strong) NSString *colore;
@property (nonatomic, strong) NSString *simboloColorePezzo;
@property (nonatomic, strong) NSString *simboloPezzo;

- (id) initWithPieceTypeAndPieceSymbol:(NSString *)pieceType :(NSString *)pieceSymbol;
- (id) initWithPieceTypeAndPieceSymbolAndFlipped:(NSString *)pieceType :(NSString *)pieceSymbol :(BOOL)flip;
- (void)setSquareValue:(unsigned int)squareValue;
- (void) flip;


- (void) generaMossePseudoLegali;
- (NSString *)getSimbolo;

- (NSMutableSet *) generaMosse;

- (void) modifyPieceImage:(NSString *)pieceType;

- (void) stampaMossePseudoLegali;

@end
