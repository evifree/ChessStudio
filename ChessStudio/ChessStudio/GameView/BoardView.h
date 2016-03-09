//
//  BoardView.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardModel.h"
#import "PieceButton.h"
#import "RookButton.h"
#import "KingButton.h"
#import "QueenButton.h"
#import "KnightButton.h"
#import "BishopButton.h"
#import "PawnButton.h"
#import "PGNMove.h"
#import "GameSetting.h"


@protocol BoardViewDelegate <NSObject>

//- (void) setCasaPartenza:(int)cp;
//- (void) setCasaArrivo:(int)ca;
//- (int) checkCasaArrivo:(int)ca;

- (void) checkSquare:(int) squareTag;
- (void) manageRightSwipeOnBoardView;
- (void) manageLeftSwipeOnBoardView;

@end

@interface BoardView : UIView


@property (nonatomic, assign) id<BoardViewDelegate> delegate;

-(id)initWithSquareSize:(CGFloat)squareSize;
-(id)initWithSquareSizeAndBoardModel:(CGFloat)squareSize :(BoardModel *)boardModel;
-(id)initWithSquareSizeAndSquareType:(CGFloat)squareSize :(NSString *)squareType;
-(id)initWithSettingManager;

//-(void)setupPosition:(BoardModel *)board;
-(void)setCoordinates;
-(void)setCoordinates:(NSArray *)coordArray;
-(void)setNalimovCoordinates;
-(void)setNalimovCoordinates:(NSArray *)coordArray;
-(void)setTipoSquare:(NSString *)typeSquare;
-(PieceButton *) findPieceBySquareTag:(int) squareTag;
-(void)flipPosition;
-(void)muoviPezzo:(int)cp :(int)ca;
-(void)muoviPezzoIndietro:(int)cp :(int)ca :(PieceButton *)pm;
-(void)muoviPezzoAvanti:(int)cp :(int)ca :(PieceButton *)pm;
-(void)promuoviPedoneAvanti:(int)cp :(int)ca :(PieceButton *)pp;
-(void)promuoviPedoneIndietro:(int)cp :(int)ca :(PieceButton *)pp;
-(void)mossaAvantiEnPassant:(int)cp :(int)ca :(int)casaEnPassant;
-(void)mossaIndietroEnPassant:(int)cp :(int)ca :(PieceButton *)pedoneEnPassant;
-(void)mossaIndietroPromozioneECattura:(int)cp :(int)ca :(PieceButton *)pedonePromosso :(PieceButton *)pezzoCatturatoInPromozione;
-(void)mossaAvantiPromozioneECattura:(int)cp :(int)ca :(PieceButton *)pezzoPromosso :(PieceButton *)pezzoCatturatoInPromozione;
-(NSMutableArray *)findPiecesByName:(NSString *)name;

-(void)modifyPieces:(NSString *)typePieces;


-(void)manageCapture:(NSUInteger)tagCapturedPiece;
-(void)manageCaptureBack;
//-(void)gestisciCatturaAvanti:(PGNMove *)move;
//-(void)gestisciCatturaIndietro:(PGNMove *)move :(PieceButton *)pezzoCatturato;
-(PieceButton *)getLastCapturedPiece;
//-(void)stampaPezziCatturati;
-(void)manageCastle:(NSUInteger)kingTag :(NSUInteger)rookTag;

- (void) muoviPezzoAvanti:(PGNMove *)move;
- (void) muoviPezzoAvantiEPromuovi:(PGNMove *)move :(PieceButton *)pezzoPromosso;
- (void) muoviPezzoIndietro:(PGNMove *)move :(PieceButton *)pezzoCatturatoDaRimettereInGioco;
- (void) muoviPezzoIndietroPromosso:(PGNMove *)move :(PieceButton *)pedonePromosso :(PieceButton *)pezzoCatturato;

//Metodi per gestire il setup della posizione
- (void) segnaCaseEnPassant:(NSArray *)caseEnPassant;
- (void) clearCaseEnPassant:(NSArray *)caseEnPassant;
- (NSUInteger) getSelectedCasaEnPassant;
- (void) setSelectedCasaEnPassant:(NSUInteger)selectedCasaEnPassant;
- (UIImageView *) findSquareByTag:(NSUInteger)tagSquare;
- (void) resetEnPassantInPosition;

- (void) resetBoard:(CGFloat)squareSize :(NSString *)squareType;

- (void) stampaDati:(CGFloat)squareSize;

- (BOOL) tapInCentro:(CGPoint)point :(CGFloat)numeroCase;

- (void) managePawnStructure;

- (BOOL) isHilighted:(NSInteger)squareNumber;
- (void) hiLightStartSquare:(NSInteger)squareNumber;
- (void) clearStartSquare:(NSInteger)squareNumber;
- (void) hiLightControlledSquare:(NSInteger)squareToHilight;
- (void) hiLightControlledSquares:(NSArray *)squaresToHilight;
- (void) clearControlledSquares:(NSArray *)squaresToClear;
- (void) clearHilightedAndControlledSquares;
- (PieceButton *) findPieceButtonTapped;
- (void) hilightCandidatesPiece:(int)squareNumber;
- (void) hilightCandidatesPieces:(NSArray *)squareNumbers;
- (void) clearCanditatesPieces;
- (BOOL) candidatesPiecesAreHilighted;
- (BOOL) selectedPieceIsCandidatePiece:(int)squareTag;
- (void) hilightArrivalSquare:(int)arrivalSquare;
- (void) clearArrivalSquare:(int)arrivalSquare;


- (void) addLeftAndRightSwipeGestureRecognizer;
- (void) removeLeftAndRightSwipeGestureRecognizer;
- (BOOL) isLeftAndRightSwipeEnabled;

@end
