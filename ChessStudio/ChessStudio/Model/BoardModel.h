//
//  BoardModel.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGNMove.h"
#import "PGNSquare.h"


extern NSString *const WHITE_KING;
extern NSString *const WHITE_QUEEN;
extern NSString *const WHITE_BISHOP;
extern NSString *const WHITE_KNIGHT;
extern NSString *const WHITE_ROOK;
extern NSString *const WHITE_PAWN;

extern NSString *const BLACK_KING;
extern NSString *const BLACK_QUEEN;
extern NSString *const BLACK_BISHOP;
extern NSString *const BLACK_KNIGHT;
extern NSString *const BLACK_ROOK;
extern NSString *const BLACK_PAWN;

extern NSString *const EMPTY;

@interface BoardModel : NSObject


@property (nonatomic, retain) NSMutableArray *pieces;
@property (nonatomic, strong) NSMutableArray *numericSquares;
@property (nonatomic, strong) NSMutableArray *algebricSquares;
@property (nonatomic, strong) NSMutableArray *mosse;
@property (nonatomic, strong) NSMutableString *listaMosse;
@property (nonatomic) BOOL whiteHasToMove;
@property (nonatomic, strong) NSString *fenNotation;
@property (nonatomic) BOOL canCaptureEnPassant;
@property (nonatomic) unsigned int casaEnPassant;
@property (nonatomic) BOOL startFromFen;


-(void) clearBoard;
-(void) setupInitialPosition;
-(void) printPosition;
-(NSString *)findContenutoBySquareNumber:(int)sn;
-(BOOL) sonoPezziDelloStessoColore:(int)squareFrom :(int)squareTo;
-(BOOL) colorePezzoOk:(int)squareFrom;
-(void) printSquares;
-(void) stampaMossa:(int)casaPartenza :(int)casaArrivo;
-(NSString *)getPreviousMove;
-(NSString *)getNextMove;
//-(Mossa *)mossaPrecedente;
//-(Mossa *)mossaSuccessiva;
-(int)getNumeroSemiMossa;
//-(void)calcolaMossePseudoLegali;
-(NSString *)trovaContenutoConNumeroCasa:(int)numeroCasa;
-(int)convertTagValueToSquareValue:(int)squareNumber;
-(BOOL)esisteCasa:(int)squareValue;
//-(NSMutableArray *)checkedSquare:(int)square :(NSString *)fromColor :(int)casaInclusa;
-(int)getKingSquareTag:(NSString *)king;

-(BOOL)reSottoScacco:(int)casaPartenza :(int)casaArrivo;
-(BOOL)casaSottoAttacco:(int)casa :(NSString *)fromColor;

-(BOOL)biancoPuoArroccareCorto;
-(BOOL)biancoPuoArroccareLungo;
-(BOOL)neroPuoArroccareCorto;
-(BOOL)neroPuoArroccareLungo;

-(PGNMove *)muoviPezzo:(int)casaPartenza :(int)casaArrivo;
-(PGNMove *)promuoviPezzo:(int)casaPartenza :(int)casaArrivo :(NSString *)pezzoPromosso;
-(PGNMove *)completaMossaEnPassant:(int)casaPartenza :(int)casaArrivo;
-(void)mossaIndietroConPromozione:(PGNMove *)pgnMove;
-(void)mossaAvantiConPromozione:(PGNMove *)pgnMove;

-(int)getSquareTagFromAlgebricValue:(NSString *)algebricValue;
-(void)mossaAvanti:(int)casaPartenza :(int)casaArrivo;
-(void)mossaIndietro:(int)casaPartenza :(int)casaArrivo :(NSString *)pezzoMangiato;
//-(void)mossaAvantiConPromozione:(int)casaPartenza :(int)casaArrivo :(NSString *)pezzoPromosso;
//-(void)mossaIndietroConPromozione:(int)casaPartenza :(int)casaArrivo :(NSString *)pedonePromosso;
-(void)mossaAvantiEnPassant:(int)casaPartenza :(int)casaArrivo :(int)casaEnPassant;
-(void)mossaIndietroEnPassant:(int)casaPartenza :(int)casaArrivo :(int)casaEnPassant;
-(NSString *)getAlgebricValueFromSquareTag:(int)squareTag;
-(short) getTagValueFromSquareValue:(short)squareValue;

-(NSString *)getColorLastMove;

-(NSString *)getPieceAtSquareTag:(int)squareTag;

-(void) stampaMosse;

-(void) sovrascriviMossa:(int)casaPartenza :(int)casaArrivo;

-(BOOL) laCasaSiTrovaNeiConfiniDellaScacchiera:(NSString *)casa;

-(NSUInteger) getPlyCount;
-(NSString *) findPezzoMangiatoByPlyCount:(NSUInteger)plyCount;


-(void)stampaStackfFen;

- (BOOL) reMatto;
- (BOOL) kingCheckedMate;


- (void) muoviAvanti:(PGNMove *)pgnMove;
- (void) muoviIndietro:(PGNMove *)pgnMove;
- (void) replaceContentOfSquare:(short)squareTo :(short) squareFrom;
- (void) emptySquare:(short) square;
- (void) replacePiece:(short) squareTo :(short) piece;
- (short) getPieceAtSquare:(short)square;
- (BOOL) squareIsEmpty:(short)square;
- (BOOL) squareContainsPiece:(short) square :(short) piece;
- (NSNumber *) getPieceNumberAtSquare:(short)square;
- (short) getPieceAtSquare:(short)column :(short)row;
- (void) switchColor;

//- (NSInteger) searchCasaEnPassantInFen:(NSString *)fen;
//- (void) setColorCanCaptureEnPassant:(NSString *)colorCancaptureEp;
- (void) ripristinaCasaEnPassant:(NSString *)fen :(NSString *)pezzo :(short)casaPartenza :(short)casaArrivo;

- (void) setPiece:(short)squareTo :(NSString *)piece;
- (NSInteger) checkSetupPosition;
- (BOOL) almenoUnArroccoPossibile;
- (BOOL) biancoPuoArroccareCortoInPosizione;
- (BOOL) biancoPuoArroccareLungoInPosizione;
- (BOOL) neroPuoArroccareCortoInPosizione;
- (BOOL) neroPuoArroccareLungoInPosizione;
- (void) setBiancoPuoArroccareCorto:(BOOL)si;
- (void) setBiancoPuoArroccareLungo:(BOOL)si;
- (void) setNeroPuoArroccareCorto:(BOOL)si;
- (void) setNeroPuoArroccareLungo:(BOOL)si;
- (BOOL) esisteAlmenoUnaPresaEnPassant;
- (NSArray *) trovaCaseEnPassant;
- (void) setPresaEnPassantPossibile:(BOOL)presaPossibile :(NSUInteger)casaEnPassant;
- (NSString *) getSelectedSquareEnPassant;
- (NSUInteger) getSelectedEnPassantSquare;
- (NSArray *) getArrocchiPermessiInPosizione;
- (void) resetEnPassantInPosition;

- (NSString *) calcFenNotationWithNumberFirstMove;
- (void) setNumberFirstMoveInSetupPosition:(NSUInteger)numberFirstMove;

- (NSMutableArray *) getListaPezziCheControllano:(int) square :(NSString *)fromColor :(int)casaInclusa;

- (NSString *) fenNotationNalimov;
- (NSString *) getPieceSymbolAtSquareTag:(int)squareTag;
- (void) setupForNalimov;
- (int) getNumberPiecesInBoard;
- (int) getNumberWhitePiecesInBoard;
- (int) getNumberBlackPiecesInBoard;

- (BOOL) isPositionForNalimovTablebase;
- (int) getNumberOf:(NSString *)piece ofColor:(NSString *)color;

@end
