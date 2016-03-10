//
//  PGNMove.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 11/12/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGNMove : NSObject

@property (nonatomic, strong) NSString *move;
@property (nonatomic, strong) NSString *fullMove;
@property (nonatomic) int fromSquare;
@property (nonatomic) int toSquare;
@property (nonatomic, strong) NSString *piece;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic) BOOL check;
@property (nonatomic) BOOL checkMate;
@property (nonatomic) BOOL capture;
@property (nonatomic) BOOL promoted;
@property (nonatomic, strong) NSString *promotion;
@property (nonatomic) BOOL endGameMarked;
@property (nonatomic, strong) NSString *endGameMark;
@property (nonatomic) BOOL kingSideCastle;
@property (nonatomic) BOOL queenSideCastle;
@property (nonatomic) BOOL enPassant;
@property (nonatomic) BOOL enPassantCapture;
@property (nonatomic) int enPassantPieceSquare;
@property (nonatomic, strong) NSString *nag;
@property (nonatomic) int plyCount;
@property (nonatomic, strong) NSString *captured;
@property (nonatomic) BOOL evidenzia;

@property (nonatomic) BOOL inVariante;
@property (nonatomic) int livelloVariante;

@property (nonatomic, strong) NSString *fen;

@property (nonatomic, strong) NSString *textBefore;
@property (nonatomic, strong) NSString *textAfter;


@property (nonatomic) BOOL trovatoFenUguale;


@property (nonatomic) BOOL insertWebDiagram;

- (id) initWithFullMove:(NSString *)fullMove;

- (BOOL) isCastle;

- (NSString *) pezzoPromosso;

- (NSString *)log;

- (NSString *) getWebMove;

- (NSString *) fenForBookMoves;

- (void) addNextMove:(PGNMove *)nextMove;
- (void) addPrevMove:(PGNMove *)prevMove;
- (void) overwriteNextMoves:(PGNMove *)nextMove;
- (void) promoteNextMoveToMainLine:(PGNMove *)nextMove;
- (NSArray *) getNextMoves;
- (PGNMove *) getPrevMove;
- (void) undoLastMove;



- (BOOL) daQuestaMossaEsisteDiramazione;

- (NSString *) getMossaDaStampare;
- (NSString *) getMossaDaStampareDopoAperturaParentesi;
- (NSString *) getPrimaMossaNeroDaStampare;

- (NSString *) getCompleteMove;
- (NSString *) getMossaPerVarianti;

- (BOOL) isValid;
- (BOOL) pedoneMossoDiDuePassi;
- (BOOL) mossaDiPedoneOCattura;


//////////////////////////////////////////
- (void) visitaAlberoToGetTextAfterGraffe;
- (void) visitaAlberoToGetTextBeforeGraffe;
- (void) visitaAlberoToGetFen;
- (void) visitaAlberoToGetMainLine;
- (void) visitaAlberoAnticipato;
- (void) visitaAlberoDifferito;
- (void) visitaAlberoAnticipato2;

- (void) visitaAlberoToCompareFen:(NSString *)inputFen;

- (NSString *) getGameDopoAlberoAnticipato2;
- (NSString *) getGameWithNagsDopoAlberoAnticipato2;
- (NSArray *) getGameArrayDopoAlberoAnticipato2;
- (void) resetWebArray;
- (void) resetGameWithNags;
- (void) resetEngineMoves;
- (NSString *) getMossaPerWebView;
- (NSString *) getMossaPerWebView2;
- (NSUInteger) getNumeroMossa;
- (NSString *) getMossaTest;
- (NSString *) getMossaCompletaConParentesi;
//////////////////////////////////////////

- (void) visitaAlberoIndietro;
- (int) visitaAlberoIndietroPerMotore;
- (NSString *) getMosseDopoVisitaAlberoIndietroPerMotore;
- (NSUInteger) getNumeroMosse:(NSString *)pezzo;

- (BOOL) isEqualToMove:(PGNMove *)pgnMove;

- (void) setMoveAnnotation:(NSString *)moveAnnotation;
- (void) removeMoveAnnotation:(NSString *)moveAnnotation;
- (void) setPositionAnnotation:(NSString *)positionAnnotation;
- (NSString *)getMoveAnnotationAtIndex:(NSUInteger)index;
- (void) removeNag:(NSString *)nag;
- (BOOL) containsNag:(NSString *)nag;

- (PGNMove *) getLastMove;
- (void) removeResultMove;
- (void) addResultMove:(PGNMove *)resultMove;

- (BOOL) isRootMove;
- (BOOL) isFirstMoveAfterRoot;
- (BOOL) isFirstMoveAfterRootWithDots;
- (BOOL) isResultMove;
- (BOOL) movesHasBeenInserted;
- (BOOL) existInitialText;
- (PGNMove *) getFirstMoveAfterRoot;

- (NSString *) textBeforeWithGraffe;
- (NSString *) textAfterWithGraffe;

// Metodi per la gestione delle varianti (eliminazione, promozione)
- (void) deleteVariation:(NSInteger)livelloVariante;
- (void) promoteVariationToMainLine:(NSInteger)livelloVarianteDaPromuovere;
- (void) promoteVariationUp:(NSInteger)livelloVarianteDaPromuovere;
- (void) promoteAsFirstVariation:(NSInteger)livelloVarianteDaPromuovere;

- (NSString *) getMoveToDisplayOnWebView;
- (NSString *) textAfterForGameMovesWebView;

@property (nonatomic, getter=isExtendedMove) BOOL extendedMove;
- (void) convertExtendedMoveToFullMove:(NSString *)prefix;


@end
