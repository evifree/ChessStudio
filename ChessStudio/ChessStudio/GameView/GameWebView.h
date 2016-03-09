//
//  GameWebView.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 27/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PGNGame.h"
#import "PGNMove.h"
#import "PGNUtil.h"

@interface GameWebView : UIWebView


//@property (nonatomic, strong) NSArray *movesArray;
@property (nonatomic, strong) NSArray *gameToViewArray;
@property (nonatomic, strong) NSString *opening;
@property (nonatomic, strong) NSString *bookMoves;
@property (nonatomic, strong) NSArray *bookMovesArray;

@property (nonatomic, assign) CGPoint lastTouchPosition;


//@property (nonatomic, strong) PGNGame *pgnGame;

//- (void) indietroButtonPressed;
//- (void) avantiButtonPressed;

//- (void) avantiButtonPressed:(NSString *)mossa;
//- (void) indietroButtonPressed:(NSString *)mossa;
//- (void) insertNewMoves:(NSString *)mosse;

- (void) resetGame;


//- (void) mossaAvanti;
//- (void) mossaIndietro;

//- (void) addLastMove:(PGNGame *)pgnGame;


//- (void) setParsedGame:(NSString *)parsedGame;

- (void) refresh;


//- (void) addMove: (PGNMove *) mossaEseguita;



//- (void) setGameArray:(NSArray *)gameArray :(PGNMove *)mossaEseguita;
//- (void) setWebGameArray:(NSArray *)webGameArray;
//- (void) evidenziaPosizione:(NSString *)posizione;
- (void) setPgnMovesArray:(NSArray *)pgnMovesArray;
- (void) setRootMove:(PGNMove *)rootMove;
- (void) aggiornaWebView;
- (void) aggiornaWebViewAvanti:(PGNMove *)nextMove;
- (void) aggiornaWebViewIndietro:(PGNMove *)prevMove;
//- (void) aggiornaWebViewDopoSelezione:(NSString *)numeroMossaInWebGameArray;
- (short) getNumeroMossaEvidenziata;

- (PGNMove *) getMoveByNumber:(short)number;
- (NSUInteger) getNumberByMove:(PGNMove *)move;
- (void) stampaPgnMovesArray;


//- (void) setMoveNotation:(NSUInteger)movNotation;
//- (void) setNotation:(NSString *)notation;

- (NSString *) getMosseWebPerEmail;


@end
