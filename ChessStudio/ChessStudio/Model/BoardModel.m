//
//  BoardModel.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 13/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "BoardModel.h"

// Define your ids for the white pieces
NSString *const WHITE_KING =   @"wk";
NSString *const WHITE_QUEEN =  @"wq";
NSString *const WHITE_BISHOP = @"wb";
NSString *const WHITE_KNIGHT = @"wn";
NSString *const WHITE_ROOK =   @"wr";
NSString *const WHITE_PAWN =   @"wp";
// Define your ids for the black pieces
NSString *const BLACK_KING =   @"bk";
NSString *const BLACK_QUEEN =  @"bq";
NSString *const BLACK_BISHOP = @"bb";
NSString *const BLACK_KNIGHT = @"bn";
NSString *const BLACK_ROOK =   @"br";
NSString *const BLACK_PAWN =   @"bp";
// Define your id for the an empty space
NSString *const EMPTY =   @"em";

@interface BoardModel() {
    
    
    NSUInteger numeroSemiMossa;
    NSMutableArray *stackSemiMosse;

    
    NSMutableDictionary *pezziMangiati;
    
    
    
    BOOL reBiancoMosso;
    BOOL reNeroMosso;
    BOOL torreBiancaAlaReMossa;
    BOOL torreBiancaAlaDonnaMossa;
    BOOL torreNeraAlaReMossa;
    BOOL torreNeraAlaDonnaMossa;
    
    //NSMutableArray *pezziCheControllano;
    
    NSMutableArray *listaMosseArray;
    
    
    NSSet *setCaseScacchieraNotazioneCorr;
    
    
    NSUInteger numeroSemimosseDaUltimaMossaPedoneOPresa;
    BOOL fenEnPassant;
    NSString *fenEnPassantSquare;
    
    
    //NSMutableArray *stackFen;
    
    
    NSString *colorCanCaptureEnpassant;
    
    
    
    NSMutableArray *kingSearchPath;
    NSMutableArray *cavalloPath;
    NSMutableArray *alfierePath;
    NSMutableArray *torrePath;
    NSMutableArray *donnaPath;
    NSMutableArray *pedoneBiancoPath;
    NSMutableArray *pedoneNeroPath;
    
    NSUInteger numberFirstMoveInSetupPosition;
}

@end


@implementation BoardModel

@synthesize pieces = _pieces;
@synthesize numericSquares = _squares;
@synthesize algebricSquares = _algebricSquares;
@synthesize mosse = _mosse;
@synthesize whiteHasToMove = _whiteHasToMove;
@synthesize fenNotation = _fenNotation;
@synthesize canCaptureEnPassant = _canCaptureEnPassant;
@synthesize casaEnPassant = _casaEnPassant;


-(id) init {
	// This we hold which pieces should be on what square
	_pieces = [[NSMutableArray alloc] initWithCapacity:64];
    _squares = [[NSMutableArray alloc] initWithCapacity:64];
    _algebricSquares = [[NSMutableArray alloc] initWithCapacity:64];
    _mosse = [[NSMutableArray alloc] init];
    pezziMangiati = [[NSMutableDictionary alloc] init];
    numeroSemiMossa = 0;
    _listaMosse = [[NSMutableString alloc] init];
    _whiteHasToMove = YES;
    [self clearBoard];
    
    
    reBiancoMosso = NO;
    reNeroMosso = NO;
    torreBiancaAlaReMossa = NO;
    torreBiancaAlaDonnaMossa = NO;
    torreNeraAlaReMossa = NO;
    torreNeraAlaDonnaMossa = NO;
    
    _canCaptureEnPassant = NO;
    _casaEnPassant = 0;
    colorCanCaptureEnpassant = nil;
    
    
    stackSemiMosse = [[NSMutableArray alloc] init];
    listaMosseArray = [[NSMutableArray alloc] init];
    
    
    setCaseScacchieraNotazioneCorr = [[NSSet alloc] initWithObjects:@"11", @"21", @"31", @"41", @"51", @"61", @"71", @"81", @"12", @"22", @"32", @"42", @"52", @"62", @"72", @"82", @"13", @"23", @"33", @"43", @"53", @"63", @"73", @"83", @"14", @"24", @"34", @"44", @"54", @"64", @"74", @"84", @"15", @"25", @"35", @"45", @"55", @"65", @"75", @"85", @"16", @"26", @"36", @"46", @"56", @"66", @"76", @"86", @"17", @"27", @"37", @"47", @"57", @"67", @"77", @"87", @"18", @"28", @"38", @"48", @"58", @"68", @"78", @"88", nil];
    
    numeroSemimosseDaUltimaMossaPedoneOPresa = 0;
    fenEnPassant = NO;
    
    
    //stackFen = [[NSMutableArray alloc] init];
    
    [self initSearchPath];
    
    _startFromFen = NO;
    
	return self;
}

- (void) initSearchPath {
    PGNSquare *sq = nil;
    kingSearchPath = [[NSMutableArray alloc] init];
    sq = [[PGNSquare alloc] initWithColumnAndRow:1 :1];
    [kingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:1 :-1];
    [kingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:-1 :-1];
    [kingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:-1 :1];
    [kingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:0 :1];
    [kingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:1 :0];
    [kingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:0 :-1];
    [kingSearchPath addObject:sq];
    sq = [[PGNSquare alloc] initWithColumnAndRow:-1 :0];
    [kingSearchPath addObject:sq];
    
    
    cavalloPath = [[NSMutableArray alloc] init];
    [cavalloPath addObject:[NSNumber numberWithShort:8]];
    [cavalloPath addObject:[NSNumber numberWithShort:-8]];
    [cavalloPath addObject:[NSNumber numberWithShort:12]];
    [cavalloPath addObject:[NSNumber numberWithShort:-12]];
    [cavalloPath addObject:[NSNumber numberWithShort:21]];
    [cavalloPath addObject:[NSNumber numberWithShort:-21]];
    [cavalloPath addObject:[NSNumber numberWithShort:19]];
    [cavalloPath addObject:[NSNumber numberWithShort:-19]];
    
    alfierePath = [[NSMutableArray alloc] init];
    [alfierePath addObject:[NSNumber numberWithShort:11]];
    [alfierePath addObject:[NSNumber numberWithShort:-11]];
    [alfierePath addObject:[NSNumber numberWithShort:9]];
    [alfierePath addObject:[NSNumber numberWithShort:-9]];
    
    torrePath = [[NSMutableArray alloc] init];
    [torrePath addObject:[NSNumber numberWithShort:10]];
    [torrePath addObject:[NSNumber numberWithShort:-10]];
    [torrePath addObject:[NSNumber numberWithShort:1]];
    [torrePath addObject:[NSNumber numberWithShort:-1]];
    
    donnaPath = [[NSMutableArray alloc] init];
    [donnaPath addObject:[NSNumber numberWithShort:11]];
    [donnaPath addObject:[NSNumber numberWithShort:-11]];
    [donnaPath addObject:[NSNumber numberWithShort:9]];
    [donnaPath addObject:[NSNumber numberWithShort:-9]];
    [donnaPath addObject:[NSNumber numberWithShort:10]];
    [donnaPath addObject:[NSNumber numberWithShort:-10]];
    [donnaPath addObject:[NSNumber numberWithShort:1]];
    [donnaPath addObject:[NSNumber numberWithShort:-1]];
    
    pedoneBiancoPath = [[NSMutableArray alloc] init];
    [pedoneBiancoPath addObject:[NSNumber numberWithShort:1]];
    
    
    pedoneNeroPath = [[NSMutableArray alloc] init];
    [pedoneNeroPath addObject:[NSNumber numberWithShort:-1]];
    
}

- (void) clearBoard {
    [_pieces removeAllObjects];
    int colonna = 1;
    int riga = 1;
    for (int i=0; i < 64; i++) {
		[_pieces insertObject:EMPTY atIndex:i];
        int casa = colonna*10 + riga;
        [_squares insertObject:[NSNumber numberWithInt:casa] atIndex:i];
        char letter = 96 + colonna;
        NSString *casaAlgebrica = [[NSString stringWithFormat:@"%c", letter] stringByAppendingString:[NSString stringWithFormat:@"%d", riga]];
        [_algebricSquares insertObject:casaAlgebrica atIndex:i];
        colonna++;
        if (colonna>8) {
            colonna = 1;
            riga++;
        }
	}
}


- (void) setupInitialPosition {
    [self clearBoard];
    // Setup the white power pieces
	[_pieces replaceObjectAtIndex:0 withObject:WHITE_ROOK];
	[_pieces replaceObjectAtIndex:1 withObject:WHITE_KNIGHT];
	[_pieces replaceObjectAtIndex:2 withObject:WHITE_BISHOP];
	[_pieces replaceObjectAtIndex:3 withObject:WHITE_QUEEN];
	[_pieces replaceObjectAtIndex:4 withObject:WHITE_KING];
	[_pieces replaceObjectAtIndex:5 withObject:WHITE_BISHOP];
	[_pieces replaceObjectAtIndex:6 withObject:WHITE_KNIGHT];
	[_pieces replaceObjectAtIndex:7 withObject:WHITE_ROOK];
	// Setup the white pawns
	for (int i=8; i < 16; i++) {
		[_pieces replaceObjectAtIndex:i withObject:WHITE_PAWN];
	}
	// Setup the bacl pawns
	for (int i=48; i < 56; i++) {
		[_pieces replaceObjectAtIndex:i withObject:BLACK_PAWN];
	}
	// Setup the black power pieces
	[_pieces replaceObjectAtIndex:56 withObject:BLACK_ROOK];
	[_pieces replaceObjectAtIndex:57 withObject:BLACK_KNIGHT];
	[_pieces replaceObjectAtIndex:58 withObject:BLACK_BISHOP];
	[_pieces replaceObjectAtIndex:59 withObject:BLACK_QUEEN];
	[_pieces replaceObjectAtIndex:60 withObject:BLACK_KING];
	[_pieces replaceObjectAtIndex:61 withObject:BLACK_BISHOP];
	[_pieces replaceObjectAtIndex:62 withObject:BLACK_KNIGHT];
	[_pieces replaceObjectAtIndex:63 withObject:BLACK_ROOK];
    
    _whiteHasToMove = YES;
    [_listaMosse setString:@""];
    [listaMosseArray removeAllObjects];
    numeroSemiMossa = 0;
    [stackSemiMosse removeAllObjects];
    [_mosse removeAllObjects];
    [pezziMangiati removeAllObjects];
    
    reBiancoMosso = NO;
    reNeroMosso = NO;
    torreBiancaAlaReMossa = NO;
    torreBiancaAlaDonnaMossa = NO;
    torreNeraAlaReMossa = NO;
    torreNeraAlaDonnaMossa = NO;
    
    _canCaptureEnPassant = NO;
    _casaEnPassant = 0;
    
    numeroSemimosseDaUltimaMossaPedoneOPresa = 0;
    fenEnPassant = NO;
    
    
    //[stackFen removeAllObjects];
}


- (int) getSquareTagFromAlgebricValue:(NSString *)algebricValue {
    for (int i=0; i<64; i++) {
        if ([[_algebricSquares objectAtIndex:i] isEqualToString:algebricValue]) {
            return i;
        }
    }
    return -1;
}

- (NSString *) getAlgebricValueFromSquareTag:(int)squareTag {
    return [_algebricSquares objectAtIndex:squareTag];
}

// A valuable tool for dumping what's in memory
// Example NSLog:
// --------- BOARD -----------
// | br bn bb bq bk bb bn br |
// | bp bp bp bp bp bp bp bp |
// | em em em em em em em em |
// | em em em em em em em em |
// | em em em em em em em em |
// | em em em em em em em em |
// | wp wp wp wp wp wp wp wp |
// | wr wn wb wq wk wb wn wr |
// ---------------------------


- (void) printPosition {
	NSLog(@"--------- BOARD -----------");
	NSString * line;
	// Start at the top of the row first
	for( int i=7; i>=0; i--) {
		line = @"";
		// Simply move from left to right in that row
		for( int j=0; j<8; j++) {
			// Create a space between for readability
			line = [line stringByAppendingString:[NSString stringWithFormat:@" %@",[_pieces objectAtIndex:i*8+j]]];
		}
		NSLog(@"|%@ |",line);
	}
	NSLog(@"---------------------------");
}


- (void) printSquares {
    NSLog(@"--------- BOARD -----------");
    NSString *line;
    // Start at the top of the row first
	for( int i=7; i>=0; i--) {
		line = @"";
		// Simply move from left to right in that row
		for( int j=0; j<8; j++) {
			// Create a space between for readability
			line = [line stringByAppendingString:[NSString stringWithFormat:@" %@",[_squares objectAtIndex:i*8+j]]];
		}
		NSLog(@"|%@ |",line);
	}
	NSLog(@"---------------------------");
}

- (void) stampaMosse {
    NSMutableString *mse = [[NSMutableString alloc] init];
    for (int i=0; i<_mosse.count; i++) {
        NSString *ms = [_mosse objectAtIndex:i];
        if (mse.length > 0) {
            [mse appendString:@" "];
        }
        [mse appendString:ms];
    }
    //NSLog(@"Numero Semimosse = %d            %@", numeroSemiMossa, mse);
}

- (NSString *)findContenutoBySquareNumber:(int)sn {
    return [_pieces objectAtIndex:sn];
}

- (NSString *)trovaContenutoConNumeroCasa:(int)numeroCasa {
    for (int k=0; k<_squares.count; k++) {
        NSNumber *number = [_squares objectAtIndex:k];
        if (number.intValue == numeroCasa) {
            return [_pieces objectAtIndex:k];
        }
    }
    return nil;
}

- (int) convertTagValueToSquareValue:(int)squareNumber {
    return [[_squares objectAtIndex:squareNumber] intValue];
}

- (short) getTagValueFromSquareValue:(short)squareValue {
    for (int i=0; i<_squares.count; i++) {
        if (squareValue == [[_squares objectAtIndex:i] intValue]) {
            return i;
        }
    }
    return -1;
}


- (void) setNumberFirstMoveInSetupPosition:(NSUInteger)numberFirstMove {
    numberFirstMoveInSetupPosition = numberFirstMove;
}

- (NSString *) calcFenNotationWithNumberFirstMove {
    NSMutableString *rigaFenFinale = [[NSMutableString alloc] initWithFormat:@"%@", @""];
    NSString *rigaFen;
    for (int r=7; r>=0; r--) {
        rigaFen = @"";
        int nc = 0;
        for (int c=0; c<8; c++) {
            //int sn = c*10 + r;
            NSString *sv = [_pieces objectAtIndex:r*8 + c];
            if ([sv isEqualToString:EMPTY]) {
                nc++;
            }
            else {
                if (nc > 0) {
                    NSString *ncc = [NSString stringWithFormat:@"%d", nc];
                    rigaFen = [rigaFen stringByAppendingString:ncc];
                }
                NSString *svv = [sv substringFromIndex:1];
                if ([sv hasPrefix:@"w"]) {
                    svv = [svv capitalizedString];
                }
                rigaFen = [rigaFen stringByAppendingString:svv];
                nc = 0;
            }
        }
        if (nc > 0) {
            NSString *ncc = [NSString stringWithFormat:@"%d", nc];
            rigaFen = [rigaFen stringByAppendingString:ncc];
        }
        if ([rigaFenFinale isEqualToString:@""]) {
            [rigaFenFinale appendString:rigaFen];
        }
        else {
            [rigaFenFinale appendString:@"/"];
            [rigaFenFinale appendString:rigaFen];
        }
    }
    
    if (_whiteHasToMove) {
        [rigaFenFinale appendString:@" w"];
    }
    else {
        [rigaFenFinale appendString:@" b"];
    }
    
    
    //Gestione Arrocchi in FEN
    NSMutableString *arrocchi = [[NSMutableString alloc] init];
    if ([self biancoPuoArroccareCortoPerFen]) {
        [arrocchi appendString:@"K"];
    }
    if ([self biancoPuoArroccareLungoPerFen]) {
        [arrocchi appendString:@"Q"];
    }
    if ([self neroPuoArroccareCortoPerFen]) {
        [arrocchi appendString:@"k"];
    }
    if ([self neroPuoArroccareLungoPerFen]) {
        [arrocchi appendString:@"q"];
    }
    if (arrocchi.length == 0) {
        [arrocchi appendString:@"-"];
    }
    [rigaFenFinale appendFormat:@" %@", arrocchi];
    
    //Gestione EnPassant in FEN
    if (fenEnPassant) {
        [rigaFenFinale appendFormat:@" %@ ", fenEnPassantSquare];
    }
    else {
        [rigaFenFinale appendString:@" - "];
    }
    
    //Gestione numeroSemimosse da Ultima mossa di Pedone o presa
    [rigaFenFinale appendFormat:@"%ld ", (long)numeroSemimosseDaUltimaMossaPedoneOPresa];
    
    [rigaFenFinale appendFormat:@"%ld", (long)numberFirstMoveInSetupPosition];
    
    _fenNotation = rigaFenFinale;
    
    return _fenNotation;
}

//Genera la FEN relativa all'attuale posizione
- (NSString *) fenNotation {
    
    //NSLog(@"@@@@@@@@@@@@@@@@@@@@@@@@@@@    ESEGUO GET FEN NOTATION IN BOARD MODEL");
    
    //NSLog(@"^^^^^^^^^^^^^^^^^^^ INIZIO DATI RELATIVI A METODO CHIAMANTE");
    //NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    //NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    //NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    //[array removeObject:@""];
    //NSLog(@"Stack = %@", [array objectAtIndex:0]);
    //NSLog(@"Framework = %@", [array objectAtIndex:1]);
    //NSLog(@"Memory address = %@", [array objectAtIndex:2]);
    //NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    //NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    //NSLog(@"Line caller = %@", [array objectAtIndex:5]);
    //NSLog(@"^^^^^^^^^^^^^^^^^^^ FINE DATI RELATIVI A METODO CHIAMANTE");
    
    
    NSMutableString *rigaFenFinale = [[NSMutableString alloc] initWithFormat:@"%@", @""];
    NSString *rigaFen;
    for (int r=7; r>=0; r--) {
        rigaFen = @"";
        int nc = 0;
        for (int c=0; c<8; c++) {
            //int sn = c*10 + r;
            NSString *sv = [_pieces objectAtIndex:r*8 + c];
            if ([sv isEqualToString:EMPTY]) {
                nc++;
            }
            else {
                if (nc > 0) {
                    NSString *ncc = [NSString stringWithFormat:@"%d", nc];
                    rigaFen = [rigaFen stringByAppendingString:ncc];
                }
                NSString *svv = [sv substringFromIndex:1];
                if ([sv hasPrefix:@"w"]) {
                    svv = [svv capitalizedString];
                }
                rigaFen = [rigaFen stringByAppendingString:svv];
                nc = 0;
            }
        }
        if (nc > 0) {
            NSString *ncc = [NSString stringWithFormat:@"%d", nc];
            rigaFen = [rigaFen stringByAppendingString:ncc];
        }
        if ([rigaFenFinale isEqualToString:@""]) {
            [rigaFenFinale appendString:rigaFen];
        }
        else {
            [rigaFenFinale appendString:@"/"];
            [rigaFenFinale appendString:rigaFen];
        }
    }
    
    if (_whiteHasToMove) {
        [rigaFenFinale appendString:@" w"];
    }
    else {
        [rigaFenFinale appendString:@" b"];
    }
    
    
    //Gestione Arrocchi in FEN
    NSMutableString *arrocchi = [[NSMutableString alloc] init];
    if ([self biancoPuoArroccareCortoPerFen]) {
        [arrocchi appendString:@"K"];
    }
    if ([self biancoPuoArroccareLungoPerFen]) {
        [arrocchi appendString:@"Q"];
    }
    if ([self neroPuoArroccareCortoPerFen]) {
        [arrocchi appendString:@"k"];
    }
    if ([self neroPuoArroccareLungoPerFen]) {
        [arrocchi appendString:@"q"];
    }
    if (arrocchi.length == 0) {
        [arrocchi appendString:@"-"];
    }
    [rigaFenFinale appendFormat:@" %@", arrocchi];
    
    //Gestione EnPassant in FEN
    if (fenEnPassant) {
        [rigaFenFinale appendFormat:@" %@ ", fenEnPassantSquare];
    }
    else {
        [rigaFenFinale appendString:@" - "];
    }
    
    //Gestione numeroSemimosse da Ultima mossa di Pedone o presa
    [rigaFenFinale appendFormat:@"%ld ", (long)numeroSemimosseDaUltimaMossaPedoneOPresa];
    
    //Gestione numero mosse in FEN
    //NSLog(@"Gestione numero mosse durante creazione FEN");
    //NSLog(@"Valore della semimossa = %d", numeroSemiMossa);
    NSUInteger nm = numeroSemiMossa/2 + 1;
    //CGFloat nmFloat = numeroSemiMossa/2 +1;
    //NSLog(@"Valore semimossa = %d", numeroSemiMossa);
    //NSLog(@"Calcolo nel numero mossa in FEN In BoardModel Float = %f", nmFloat);
    //NSLog(@"Calcolo del numero mossa in FEN In BoardModel Integer = %d", nm);
    [rigaFenFinale appendFormat:@"%ld", (long)nm];
    
    _fenNotation = rigaFenFinale;
    
    
    //NSLog(@"FEN = %@", _fenNotation);
    
    return _fenNotation;
}


//Interpreta la FEN e stabilisce la nuova posizione 
- (void) setFenNotation:(NSString *)fenNotation {
    
    //NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&    ESEGUO SET FEN NOTATION IN BOARD MODEL");
    
    //NSLog(@"^^^^^^^^^^^^^^^^^^^ INIZIO DATI RELATIVI A METODO CHIAMANTE");
    //NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    //NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    //NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    //[array removeObject:@""];
    //NSLog(@"Stack = %@", [array objectAtIndex:0]);
    //NSLog(@"Framework = %@", [array objectAtIndex:1]);
    //NSLog(@"Memory address = %@", [array objectAtIndex:2]);
    //NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    //NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    //NSLog(@"Line caller = %@", [array objectAtIndex:5]);
    //NSLog(@"^^^^^^^^^^^^^^^^^^^ FINE DATI RELATIVI A METODO CHIAMANTE");
    
    
    _fenNotation = fenNotation;
    
    NSMutableArray *fenPosition = (NSMutableArray *)[fenNotation componentsSeparatedByString:@"/"];

    
    NSString *stringControl = [fenPosition objectAtIndex:fenPosition.count - 1];
    NSMutableArray *fenControl = (NSMutableArray *)[stringControl componentsSeparatedByString:@" "];
    
    [fenPosition replaceObjectAtIndex:fenPosition.count - 1 withObject:[fenControl objectAtIndex:0]];
    [fenControl removeObjectAtIndex:0];
    
    //for (NSString *riga in fenPosition) {
    //    NSLog(@"%@", riga);
    //}
    
    //NSLog(@"------------------------------------");
    
    //for (NSString *riga in fenControl) {
    //    NSLog(@"%@", riga);
    //}
    
    [self clearBoard];
    
    NSCharacterSet *upperCaseSet = [NSCharacterSet uppercaseLetterCharacterSet];
    
    for (int r=7; r>=0; r--) {
        NSString *rigaFen = [fenPosition objectAtIndex:7-r];
        //NSLog(@"Analizzo riga:%@", rigaFen);
        NSMutableArray *rigaFenSub = [[NSMutableArray alloc] init];
        for (int k=0; k<rigaFen.length; k++) {
            NSRange range = {k, 1};
            NSString *ks = [rigaFen substringWithRange:range];
            //NSLog(@"carattere da riga fen: %@", ks);
            NSScanner *scanner = [NSScanner scannerWithString:ks];
            if ([scanner scanInt:NULL]) {
                //NSLog(@"La stringa è un numero");
                int n = [ks intValue];
                for (int x=0; x<n; x++) {
                    [rigaFenSub addObject:EMPTY];
                }
            }
            else {
                //NSLog(@"La stringa non è un numero");
                NSRange  uppercaseRange = [ks rangeOfCharacterFromSet:upperCaseSet];
                if (uppercaseRange.location == NSNotFound) {
                    NSString *sss = @"b";
                    sss = [sss stringByAppendingString:ks];
                    [rigaFenSub addObject:sss];
                }
                else {
                    NSString *sss = @"w";
                    ks = [ks lowercaseString];
                    sss = [sss stringByAppendingString:ks];
                    [rigaFenSub addObject:sss];
                }
            }
        }
        //for (NSString *nss in rigaFenSub) {
        //    NSLog(@"-----> %@", nss);
        //}
        for (int c=0; c<8; c++) {
            int sn = r*8 + c;
            NSString *sv = [rigaFenSub objectAtIndex:c];
            //NSLog(@"Casa: %d : %@", sn, sv);
            [_pieces replaceObjectAtIndex:sn withObject:sv];
        }
    }
    
    
    
    //for (NSString *riga in fenControl) {
    //    NSLog(@"%@", riga);
    //}
    
    NSString *colorControl = [fenControl objectAtIndex:0];
    if ([colorControl isEqualToString:@"w"]) {
        _whiteHasToMove = YES;
        //NSLog(@"Deve Muovere il Bianco");
    }
    else {
        //NSLog(@"Deve muovere il Nero");
        _whiteHasToMove = NO;
    }
    
    
    //Controllo degli Arrocchi
    NSString *arroccoControl = [fenControl objectAtIndex:1];
    //NSLog(@"ARROCCO CONTROL = %@", arroccoControl);
    const char *arroccoControlChar = [arroccoControl UTF8String];
    for (int i=0; i<arroccoControl.length; i++) {
        NSString *ch = [NSString stringWithFormat:@"%c", arroccoControlChar[i]];
        if ([ch isEqualToString:@"-"]) {
            reBiancoMosso = YES;
            reNeroMosso = YES;
            //torreBiancaAlaReMossa = YES;
            //torreBiancaAlaDonnaMossa = YES;
            //torreNeraAlaReMossa = YES;
            //torreNeraAlaDonnaMossa = YES;
            //NSLog(@"Non sono permessi arrocchi da ambo le parti");
        }
        else if ([ch isEqualToString:@"K"]) {
            reBiancoMosso = NO;
            torreBiancaAlaReMossa = NO;
            //NSLog(@"Il Bianco può arroccare corto");
        }
        else if ([ch isEqualToString:@"Q"]) {
            reBiancoMosso = NO;
            torreBiancaAlaDonnaMossa = NO;
            //NSLog(@"Il Bianco può arroccare lungo");
        }
        else if ([ch isEqualToString:@"k"]) {
            reNeroMosso = NO;
            torreNeraAlaReMossa = NO;
            //NSLog(@"Il Nero può arroccare corto");
        }
        else if ([ch isEqualToString:@"q"]) {
            reNeroMosso = NO;
            torreNeraAlaDonnaMossa = NO;
            //NSLog(@"Il Nero può arroccare lungo");
        }
    }
    
    //Controllo Mosse En Passant
    NSString *enPassantControl = [fenControl objectAtIndex:2];
    if ([enPassantControl isEqualToString:@"-"]) {
        _canCaptureEnPassant = NO;
    }
    else {
        int tagEnPassant = [self getSquareTagFromAlgebricValue:enPassantControl];
        //NSLog(@"Devo gestire la possibile cattura enpassant in %@ oppure tag = %d", enPassantControl, tagEnPassant);
        if (_whiteHasToMove) {
            //NSUInteger cp = tagEnPassant + 8;
            int ca = tagEnPassant - 8;
            int ca1 = ca + 1;
            int ca2 = ca - 1;
            //NSLog(@"Ultima mossa pedone Nero %@-%@", [self getAlgebricValueFromSquareTag:cp], [self getAlgebricValueFromSquareTag:ca]);
            if ([_squares containsObject:[NSNumber numberWithInt:ca1]]) {
                if ([[_pieces objectAtIndex:ca1] isEqualToString:@"wp"]) {
                    _canCaptureEnPassant = YES;
                }
            }
            if ([_squares containsObject:[NSNumber numberWithInt:ca2]]) {
                if ([[_pieces objectAtIndex:ca2] isEqualToString:@"wp"]) {
                    _canCaptureEnPassant = YES;
                }
            }
            if (_canCaptureEnPassant) {
                _casaEnPassant = ca + 8;
                //NSLog(@"E' possibile una cattura En passant alla prossima mossa del Bianco nella casa %d", _casaEnPassant);
            }
            else {
                //NSLog(@"Nessuna presa enpassant possibile da parte del Bianco");
            }
        }
        else {
            //NSUInteger cp = tagEnPassant - 8;
            int ca = tagEnPassant + 8;
            //NSLog(@"Ultima mossa pedone Bianco %@-%@", [self getAlgebricValueFromSquareTag:cp], [self getAlgebricValueFromSquareTag:ca]);
            int ca1 = ca + 1;
            int ca2 = ca - 1;
            if ([_squares containsObject:[NSNumber numberWithInt:ca1]]) {
                if ([[_pieces objectAtIndex:ca1] isEqualToString:@"bp"]) {
                    _canCaptureEnPassant = YES;
                }
            }
            if ([_squares containsObject:[NSNumber numberWithInt:ca2]]) {
                if ([[_pieces objectAtIndex:ca2] isEqualToString:@"bp"]) {
                    _canCaptureEnPassant = YES;
                }
            }
            if (_canCaptureEnPassant) {
                _casaEnPassant = ca - 8;
                //NSLog(@"E' possibile una cattura En passant alla prossima mossa del Nero nella casa %d", _casaEnPassant);
            }
            else {
                //NSLog(@"Nessuna presa enpassant possibile da parte del Nero");
            }
        }
    }
    
    
    //Gestione mosse senza mosse di Pedone e senza catture
    NSString *ns = [fenControl objectAtIndex:3];
    numeroSemimosseDaUltimaMossaPedoneOPresa = [ns integerValue];
    //NSLog(@"Numero semimosse senza movimenti di Pedone o catture = %d", numeroSemimosseDaUltimaMossaPedoneOPresa);
    
    //Gestione numero mosse
    NSString *nmString = [fenControl objectAtIndex:4];
    NSInteger nm = [nmString integerValue];
    
    
        if (nm == 1) {
            
            if (_startFromFen) {
                if (_whiteHasToMove) {
                    numeroSemiMossa = 0;
                }
                else {
                    numeroSemiMossa = 1;
                }
            }
            
            else {
                if (_whiteHasToMove) {
                    numeroSemiMossa = 0;
                }
                else {
                    numeroSemiMossa = 1;
                }
            }
            /*
            if (_startFromFen) {
                if (_whiteHasToMove) {
                    numeroSemiMossa = 0;
                }
                else {
                    numeroSemiMossa = 0;
                }
            }
            else {
                numeroSemiMossa = 0;
            }*/
            
            /*
            if (_whiteHasToMove) {
                numeroSemiMossa = 0;
            }
            else {
                //NSLog(@"################FEN = %@", fenNotation);
                //numeroSemiMossa = 1;    //Questa istruzione deve essere inserita nel caso di una partita o di una posizione in cui inizi a muovere il Bianco
                //numeroSemiMossa = 0;      //Questa istruzione deve essere inserita nel caso di una posizione in cui inizi a muovere il Nero
                if (_startFromFen && !_whiteHasToMove) {
                    numeroSemiMossa = 0;
                }
                else if (_startFromFen && _whiteHasToMove) {
                    numeroSemiMossa = 1;
                }
                else if (!_startFromFen && _whiteHasToMove) {
                    numeroSemiMossa = 1;
                }
            }*/
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
    
    //NSLog(@"VALORE FEN RICEVUTO = %@", fenNotation);
    //NSLog(@"NUMERO SEMIMOSSE CALCOLATO IN BOARD MODEL = %d", numeroSemiMossa);
    //if (_whiteHasToMove) {
    //    NSLog(@"LA MOSSA E' AL BIANCO");
    //}
    //else {
    //    NSLog(@"LA MOSSA E' AL NERO");
    //}
    
    
    //[self printPosition];
}

- (NSString *) getPieceAtSquareTag:(int)squareTag {
    int sv = [self convertTagValueToSquareValue:squareTag];
    return [self trovaContenutoConNumeroCasa:sv];
}

- (void) mossaAvanti:(int)casaPartenza :(int)casaArrivo {
    //NSLog(@"BOARD MODEL Mossa: %d - %d", casaPartenza, casaArrivo);
    NSString *pezzo = [_pieces objectAtIndex:casaPartenza];
    //NSString *pezzoInCasaArrivo = [_pieces objectAtIndex:casaArrivo];
    
    
    //Controllo En Passant
    [self checkIfNextMoveCanBeEnPassant:pezzo :casaPartenza :casaArrivo];
    
    /*
    unsigned int cp = [self convertTagValueToSquareValue:casaPartenza];
    unsigned int ca = [self convertTagValueToSquareValue:casaArrivo];
    
    if ([pezzo hasSuffix:@"wp"]  && (cp%10==2) && (ca%10==4)) {
        unsigned int ca1 = ca + 10;
        unsigned int ca2 = ca - 10;
        if ([_squares containsObject:[NSNumber numberWithInt:ca1]]) {
            if ([[_pieces objectAtIndex:casaArrivo + 1] isEqualToString:@"bp"]) {
                _canCaptureEnPassant = YES;
            }
        }
        if ([_squares containsObject:[NSNumber numberWithInt:ca2]]) {
            if ([[_pieces objectAtIndex:casaArrivo - 1] isEqualToString:@"bp"]) {
                _canCaptureEnPassant = YES;
            }
        }
        if (_canCaptureEnPassant) {
            _casaEnPassant = casaArrivo - 8;
            colorCanCaptureEnpassant = @"b";
            NSLog(@"E' possibile una cattura En passant alla prossima mossa del Nero nella casa %d", _casaEnPassant);
        }
    }
    //Controllo En Passant Nero
    if ([pezzo hasSuffix:@"bp"]  && (cp%10==7) && (ca%10==5)) {
        unsigned int ca1 = ca + 10;
        unsigned int ca2 = ca - 10;
        if ([_squares containsObject:[NSNumber numberWithInt:ca1]]) {
            if ([[_pieces objectAtIndex:casaArrivo + 1] isEqualToString:@"wp"]) {
                _canCaptureEnPassant = YES;
            }
        }
        if ([_squares containsObject:[NSNumber numberWithInt:ca2]]) {
            if ([[_pieces objectAtIndex:casaArrivo - 1] isEqualToString:@"wp"]) {
                _canCaptureEnPassant = YES;
            }
        }
        if (_canCaptureEnPassant) {
            _casaEnPassant = casaArrivo + 8;
            colorCanCaptureEnpassant = @"w";
            NSLog(@"E' possibile una cattura En passant alla prossima mossa del Bianco nella casa %d", _casaEnPassant);
        }
    }
    */
    
    //Salvo informazioni FEN per Torre e/o Re per gestire l'arrocco
    //if ([pezzo hasSuffix:@"k"] || [pezzo hasSuffix:@"r"]) {
        //[stackFen addObject:[self fenNotation]];
    //}
    
    
    
    [_pieces replaceObjectAtIndex:casaPartenza withObject:EMPTY];
    [_pieces replaceObjectAtIndex:casaArrivo withObject:pezzo];
    
    if ([pezzo hasSuffix:@"wk"] && casaPartenza == 4 && casaArrivo == 6) {
        NSString *torre = [_pieces objectAtIndex:7];
        [_pieces replaceObjectAtIndex:7 withObject:EMPTY];
        [_pieces replaceObjectAtIndex:5 withObject:torre];
        torreBiancaAlaReMossa = YES;
        reBiancoMosso = YES;
    }
    if ([pezzo hasSuffix:@"wk"] && casaPartenza == 4 && casaArrivo == 2) {
        NSString *torre = [_pieces objectAtIndex:0];
        [_pieces replaceObjectAtIndex:0 withObject:EMPTY];
        [_pieces replaceObjectAtIndex:3 withObject:torre];
        torreBiancaAlaDonnaMossa = YES;
        reBiancoMosso = YES;
    }
    if ([pezzo hasSuffix:@"bk"] && casaPartenza == 60 && casaArrivo == 62) {
        NSString *torre = [_pieces objectAtIndex:63];
        [_pieces replaceObjectAtIndex:63 withObject:EMPTY];
        [_pieces replaceObjectAtIndex:61 withObject:torre];
        torreNeraAlaReMossa = YES;
        reNeroMosso = YES;
    }
    if ([pezzo hasSuffix:@"bk"] && casaPartenza == 60 && casaArrivo == 58) {
        NSString *torre = [_pieces objectAtIndex:56];
        [_pieces replaceObjectAtIndex:56 withObject:EMPTY];
        [_pieces replaceObjectAtIndex:59 withObject:torre];
        torreNeraAlaDonnaMossa = YES;
        reNeroMosso = YES;
    }
    
    if (_whiteHasToMove) {
        if ([pezzo hasSuffix:@"k"] && !reBiancoMosso) {
            reBiancoMosso = YES;
            //NSLog(@"Hai mosso per la prima volta il Re Bianco");
        }
        if ([pezzo hasSuffix:@"r"] && casaPartenza == 7 && !torreBiancaAlaReMossa) {
            torreBiancaAlaReMossa = YES;
            //NSLog(@"Hai mosso per la prima volta La Torre di Re Bianca");
        }
        if ([pezzo hasSuffix:@"r"] && casaPartenza == 0 && !torreBiancaAlaDonnaMossa) {
            torreBiancaAlaDonnaMossa = YES;
            //NSLog(@"Hai mosso per la prima volta La Torre di Donna Bianca");
        }
    }
    else {
        if ([pezzo hasSuffix:@"k"] && !reNeroMosso) {
            reNeroMosso = YES;
            //NSLog(@"Hai mosso per la prima volta il Re Nero");
        }
        if ([pezzo hasSuffix:@"r"] && casaPartenza == 63 && !torreBiancaAlaReMossa) {
            torreNeraAlaReMossa = YES;
            //NSLog(@"Hai mosso per la prima volta La Torre di Re Nera");
        }
        if ([pezzo hasSuffix:@"r"] && casaPartenza == 56 && !torreBiancaAlaDonnaMossa) {
            torreNeraAlaDonnaMossa = YES;
            //NSLog(@"Hai mosso per la prima volta La Torre di Donna Nera");
        }
    }
    
    _whiteHasToMove = !_whiteHasToMove;
    numeroSemiMossa++;
    //[self printPosition];
}

/*
- (void) mossaAvantiConPromozione:(int)casaPartenza :(int)casaArrivo :(NSString *)pezzoPromosso {
    [_pieces replaceObjectAtIndex:casaPartenza withObject:EMPTY];
    [_pieces replaceObjectAtIndex:casaArrivo withObject:pezzoPromosso];
    _whiteHasToMove = !_whiteHasToMove;
    numeroSemiMossa++;
    [self printPosition];
}

- (void) mossaIndietroConPromozione:(int)casaPartenza :(int)casaArrivo :(NSString *)pedonePromosso {
    [_pieces replaceObjectAtIndex:casaPartenza withObject:EMPTY];
    [_pieces replaceObjectAtIndex:casaArrivo withObject:pedonePromosso];
    _whiteHasToMove = !_whiteHasToMove;
    numeroSemiMossa--;
    [self printPosition];
}
*/

- (void) mossaAvantiConPromozione:(PGNMove *)pgnMove {
    [_pieces replaceObjectAtIndex:pgnMove.fromSquare withObject:EMPTY];
    [_pieces replaceObjectAtIndex:pgnMove.toSquare withObject:pgnMove.pezzoPromosso];
    _whiteHasToMove = !_whiteHasToMove;
    numeroSemiMossa++;
    //[self printPosition];
}

- (void) mossaIndietroConPromozione:(PGNMove *)pgnMove {
    NSLog(@"Eseguo MossaindietroConPromozione");
    NSString *pedonePromosso = [[pgnMove color] stringByAppendingString:@"p"];
    NSLog(@"COLORE = %@", pgnMove.color);
    //NSLog(@"CASA PARTENZA = %d    CASA ARRIVO = %d", pgnMove.fromSquare, pgnMove.toSquare);
    [_pieces replaceObjectAtIndex:pgnMove.fromSquare withObject:pedonePromosso];
    [_pieces replaceObjectAtIndex:pgnMove.toSquare withObject:EMPTY];
    if (pgnMove.capture) {
        NSLog(@"PEZZO CATTURATO = %@", pgnMove.captured);
        [_pieces replaceObjectAtIndex:pgnMove.toSquare withObject:pgnMove.captured];
    }
    _whiteHasToMove = !_whiteHasToMove;
    numeroSemiMossa--;
    //[self printPosition];
}

- (void) mossaAvantiEnPassant:(int)casaPartenza :(int)casaArrivo :(int)casaEnPassant {
    [_pieces replaceObjectAtIndex:casaPartenza withObject:EMPTY];
    if (_whiteHasToMove) {
        [_pieces replaceObjectAtIndex:casaArrivo withObject:WHITE_PAWN];
    }
    else {
        [_pieces replaceObjectAtIndex:casaArrivo withObject:BLACK_PAWN];
    }
    [_pieces replaceObjectAtIndex:casaEnPassant withObject:EMPTY];
    _whiteHasToMove = !_whiteHasToMove;
    numeroSemiMossa++;
    
    if (_canCaptureEnPassant) {
        _canCaptureEnPassant = NO;
        _casaEnPassant = 0;
        colorCanCaptureEnpassant = nil;
    }
    
    //[self printPosition];
}

- (void) mossaIndietroEnPassant:(int)casaPartenza :(int)casaArrivo :(int)casaEnPassant {
    [_pieces replaceObjectAtIndex:casaPartenza withObject:EMPTY];
    if (_whiteHasToMove) {
        [_pieces replaceObjectAtIndex:casaArrivo withObject:BLACK_PAWN];
        [_pieces replaceObjectAtIndex:casaEnPassant withObject:WHITE_PAWN];
    }
    else {
        [_pieces replaceObjectAtIndex:casaArrivo withObject:WHITE_PAWN];
        [_pieces replaceObjectAtIndex:casaEnPassant withObject:BLACK_PAWN];
    }
    
    _canCaptureEnPassant = YES;
    _casaEnPassant = casaPartenza;
    NSLog(@"Situazione enPassant ripristinata con casaEnPassant = %d", _casaEnPassant);
    
    _whiteHasToMove = !_whiteHasToMove;
    numeroSemiMossa--;
    
    if (_whiteHasToMove) {
        colorCanCaptureEnpassant = @"w";
    }
    else {
        colorCanCaptureEnpassant = @"b";
    }
    
    
    //[self printPosition];
}

- (void) mossaIndietro:(int)casaPartenza :(int)casaArrivo :(NSString *)pezzoMangiato {
    //NSLog(@"BOARD MODEL Mossa: %d - %d", casaPartenza, casaArrivo);
    //[self printPosition];
    NSString *pezzo = [_pieces objectAtIndex:casaPartenza];
    [_pieces replaceObjectAtIndex:casaPartenza withObject:pezzoMangiato];
    [_pieces replaceObjectAtIndex:casaArrivo withObject:pezzo];
    
    if ([pezzo hasSuffix:@"wk"] && casaPartenza == 6 && casaArrivo == 4) {
        NSString *torre = [_pieces objectAtIndex:5];
        [_pieces replaceObjectAtIndex:5 withObject:EMPTY];
        [_pieces replaceObjectAtIndex:7 withObject:torre];
        torreBiancaAlaReMossa = NO;
        reBiancoMosso = NO;
        //NSLog(@"Ora il bianco può di nuovo arroccare corto");
    }
    if ([pezzo hasSuffix:@"wk"] && casaPartenza == 2 && casaArrivo == 4) {
        NSString *torre = [_pieces objectAtIndex:3];
        [_pieces replaceObjectAtIndex:3 withObject:EMPTY];
        [_pieces replaceObjectAtIndex:0 withObject:torre];
        torreBiancaAlaDonnaMossa = NO;
        reBiancoMosso = NO;
        //NSLog(@"Ora il bianco può di nuovo arroccare lungo");
    }
    if ([pezzo hasSuffix:@"bk"] && casaPartenza == 62 && casaArrivo == 60) {
        NSString *torre = [_pieces objectAtIndex:61];
        [_pieces replaceObjectAtIndex:61 withObject:EMPTY];
        [_pieces replaceObjectAtIndex:63 withObject:torre];
        torreNeraAlaReMossa = NO;
        reNeroMosso = NO;
        //NSLog(@"Ora il nero può di nuovo arroccare corto");
    }
    if ([pezzo hasSuffix:@"bk"] && casaPartenza == 58 && casaArrivo == 60) {
        NSString *torre = [_pieces objectAtIndex:59];
        [_pieces replaceObjectAtIndex:59 withObject:EMPTY];
        [_pieces replaceObjectAtIndex:56 withObject:torre];
        torreNeraAlaDonnaMossa = NO;
        reNeroMosso = NO;
        //NSLog(@"Ora il nero può di nuovo arroccare lungo");
    }
    _whiteHasToMove = !_whiteHasToMove;
    numeroSemiMossa--;
    
    if (numeroSemiMossa == -1) {
        numeroSemiMossa = 0;
    }
    
    //[self printPosition];
    //NSLog(@"£££££££££££££££   NUMERO SEMIMOSSA DOPO ESSERE ANDATI INDIETRO = %d", numeroSemiMossa);
    
    if (_canCaptureEnPassant) {
        _canCaptureEnPassant = NO;
        _casaEnPassant = 0;
        colorCanCaptureEnpassant = nil;
    }
    
    //if ([pezzo hasSuffix:@"k"] || [pezzo hasSuffix:@"r"]) {
        //if (stackFen.count>0) {
        //    NSString *fen = [stackFen lastObject];
        //    [self setFenNotation:fen];
        //    [stackFen removeLastObject];
        //    NSLog(@"Qui cambio il fen con %@", fen);
        //}
    //}
    
    //[self printPosition];
}


- (void) sovrascriviMossa:(int)casaPartenza :(int)casaArrivo {
    NSRange range = NSMakeRange(numeroSemiMossa, _mosse.count - numeroSemiMossa);
    //[_mosse removeObjectAtIndex:numeroSemiMossa];
    [_mosse removeObjectsInRange:range];
    //[listaMosseArray removeObjectAtIndex:numeroSemiMossa];
    [listaMosseArray removeObjectsInRange:range];
    [self muoviPezzo:casaPartenza :casaArrivo];
}

- (NSUInteger) getPlyCount {
    return numeroSemiMossa;
}


#pragma mark - Metodi per vedere se alla prossima mossa è possibile una presa EnPassant

- (void) checkIfNextMoveCanBeEnPassant:(NSString *) pezzo :(short) casaPartenza :(short) casaArrivo {
    
    //NSString *pezzo = [_pieces objectAtIndex:casaPartenza];
    
    _canCaptureEnPassant = NO;
    _casaEnPassant = 0;
    colorCanCaptureEnpassant = nil;
    
    
    if ([pezzo hasSuffix:@"p"]) {
        unsigned int cp = [self convertTagValueToSquareValue:casaPartenza];
        unsigned int ca = [self convertTagValueToSquareValue:casaArrivo];
        
        if ([pezzo hasSuffix:@"wp"]  && (cp%10==2) && (ca%10==4)) {
            unsigned int ca1 = ca + 10;
            unsigned int ca2 = ca - 10;
            if ([_squares containsObject:[NSNumber numberWithInt:ca1]]) {
                if ([[_pieces objectAtIndex:casaArrivo + 1] isEqualToString:@"bp"]) {
                    _canCaptureEnPassant = YES;
                }
            }
            if ([_squares containsObject:[NSNumber numberWithInt:ca2]]) {
                if ([[_pieces objectAtIndex:casaArrivo - 1] isEqualToString:@"bp"]) {
                    _canCaptureEnPassant = YES;
                }
            }
            if (_canCaptureEnPassant) {
                _casaEnPassant = casaArrivo - 8;
                colorCanCaptureEnpassant = @"b";
                NSLog(@"E' possibile una cattura En passant alla prossima mossa del Nero nella casa %d", _casaEnPassant);
            }
        }
        else if ([pezzo hasSuffix:@"bp"]  && (cp%10==7) && (ca%10==5)) {
                unsigned int ca1 = ca + 10;
                unsigned int ca2 = ca - 10;
                if ([_squares containsObject:[NSNumber numberWithInt:ca1]]) {
                    if ([[_pieces objectAtIndex:casaArrivo + 1] isEqualToString:@"wp"]) {
                        _canCaptureEnPassant = YES;
                    }
                }
                if ([_squares containsObject:[NSNumber numberWithInt:ca2]]) {
                    if ([[_pieces objectAtIndex:casaArrivo - 1] isEqualToString:@"wp"]) {
                        _canCaptureEnPassant = YES;
                    }
                }
                if (_canCaptureEnPassant) {
                    _casaEnPassant = casaArrivo + 8;
                    colorCanCaptureEnpassant = @"w";
                    NSLog(@"E' possibile una cattura En passant alla prossima mossa del Bianco nella casa %d", _casaEnPassant);
                }
            }
    }
    else {
        _canCaptureEnPassant = NO;
        _casaEnPassant = 0;
        colorCanCaptureEnpassant = nil;
    }
}

- (NSInteger) searchCasaEnPassantInFen:(NSString *)fen {
    NSMutableArray *fenPosition = (NSMutableArray *)[fen componentsSeparatedByString:@"/"];
    NSString *stringControl = [fenPosition objectAtIndex:fenPosition.count - 1];
    NSMutableArray *fenControl = (NSMutableArray *)[stringControl componentsSeparatedByString:@" "];
    [fenControl removeObjectAtIndex:0];
    NSString *enPassantControl = [fenControl objectAtIndex:2];
    //NSLog(@"ENPASSANT CONTROL = %@", enPassantControl);
    if ([enPassantControl isEqualToString:@"-"]) {
        return -1;
    }
    NSUInteger tagEnPassant = [self getSquareTagFromAlgebricValue:enPassantControl];
    return tagEnPassant;
}

//- (void) setColorCanCaptureEnPassant:(NSString *)colorCancaptureEp {
//    colorCanCaptureEnpassant = colorCancaptureEp;
//}

- (void) ripristinaCasaEnPassant:(NSString *)fen :(NSString *)pezzo :(short)casaPartenza :(short)casaArrivo {
    if (![pezzo hasSuffix:@"p"]) {
        _canCaptureEnPassant = NO;
        _casaEnPassant = 0;
        colorCanCaptureEnpassant = nil;
        return;
    }
    NSInteger vecchiaCasaEnPassant = [self searchCasaEnPassantInFen:fen];
    if (vecchiaCasaEnPassant == -1) {
        _canCaptureEnPassant = NO;
        _casaEnPassant = 0;
        colorCanCaptureEnpassant = nil;
        return;
    }
    if ([pezzo hasSuffix:@"wp"] && ((casaPartenza+7 == vecchiaCasaEnPassant) || (casaPartenza+9 == vecchiaCasaEnPassant))) {
        _canCaptureEnPassant = YES;
        _casaEnPassant = (int)vecchiaCasaEnPassant;
        colorCanCaptureEnpassant = @"w";
    }
    else if ([pezzo hasSuffix:@"bp"] && ((casaPartenza-7 == vecchiaCasaEnPassant) || (casaPartenza-9 == vecchiaCasaEnPassant))) {
        _canCaptureEnPassant = YES;
        _casaEnPassant = (int)vecchiaCasaEnPassant;
        colorCanCaptureEnpassant = @"b";
    }
}

#pragma mark - Fine Metodi per vedere se alla prossima mossa è possibile una presa EnPassant


#pragma mark - Inizio Metodi utilizzati per il parsing delle partite con notazione estesa

- (void) controllaSeDevoAggiungereScacco: (PGNMove *)pgnMove {
    NSLog(@"CONTROLLO RE SOTTO SCACCO CON MOSSA: %@", pgnMove.fullMove);
    int diagnosi = [self hoDatoScaccoAlRe:pgnMove.fromSquare :pgnMove.toSquare];
//    if ([self hoDatoScaccoAlRe:pgnMove.fromSquare :pgnMove.toSquare]) {
//        if (_whiteHasToMove) {
//            NSLog(@"HO TROVATO IL RE BIANCO SOTTO SCACCO DOPO MOSSA: %@", pgnMove.fullMove);
//        }
//        else {
//            NSLog(@"HO TROVATO IL RE NERO SOTTO SCACCO DOPO MOSSA: %@", pgnMove.fullMove);
//        }
//        NSString *fullMoveCheck = [pgnMove fullMove];
//        //fullMoveCheck = [fullMoveCheck stringByAppendingString:@"+"];
//        //[self printPosition];
//        if (![self ilRePuoMuoversi]) {
//            fullMoveCheck = [fullMoveCheck stringByAppendingString:@"#"];
//            if (_whiteHasToMove) {
//                NSLog(@"IL NERO VINCE   0-1");
//            }
//            else {
//                NSLog(@"Il BIANCO VINCE   1-0");
//            }
//        }
//        else {
//            fullMoveCheck = [fullMoveCheck stringByAppendingString:@"+"];
//        }
//        [pgnMove setFullMove:fullMoveCheck];
//    }
    NSString *fullMoveCheck = [pgnMove fullMove];
    switch (diagnosi) {
        case 0:
            break;
        case 100:
            fullMoveCheck = [fullMoveCheck stringByAppendingString:@"+"];
            [pgnMove setFullMove:fullMoveCheck];
            break;
        case 200:
            fullMoveCheck = [fullMoveCheck stringByAppendingString:@"#"];
            [pgnMove setFullMove:fullMoveCheck];
            break;
        default:
            break;
    }
}

- (int) hoDatoScaccoAlRe:(int)cp :(int)ca {
    //NSLog(@"****************************   INIZIO METODO RE SOTTO SCACCO   ******************************");
    
    NSString *pezzo = [_pieces objectAtIndex:cp];
    NSString *pezzoInCasaArrivo = [_pieces objectAtIndex:ca];
    
    //[self printPosition];
    
    [_pieces replaceObjectAtIndex:cp withObject:EMPTY];
    [_pieces replaceObjectAtIndex:ca withObject:pezzo];
    
    //[self printPosition];
    
    
    //NSLog(@"&&&&&&&&&&&&&&&&&&&  INIZIO  CONTROLLO RE SOTTO SCACCO   &&&&&&&&&&&&&&&&&&&&&&&");
    
    int tagRe = 0;
    NSMutableArray *kingChecked;
    if (_whiteHasToMove) {
        NSLog(@"CONTROLLO SE IL RE BIANCO SOTTO SCACCO");
        tagRe = [self getKingSquareTag:@"wk"];
        kingChecked = [self checkedSquare:tagRe :@"w" :-1];
    }
    else {
        NSLog(@"CONTROLLO SE IL RE NERO SOTTO SCACCO");
        tagRe = [self getKingSquareTag:@"bk"];
        kingChecked = [self checkedSquare:tagRe :@"b" :-1];
    }
    
    
    int diagnosi = -1;
    
    if (kingChecked.count>0) {
        if ([self ilRePuoMuoversi]) {
            diagnosi = 100;  //Scacco senza matto
        }
        else {
            diagnosi = 200;  // Scacco Matto
        }
    }
    else diagnosi = 0;
    
    //NSLog(@"&&&&&&&&&&&&&&&&&&&  FINE  CONTROLLO RE SOTTO SCACCO   &&&&&&&&&&&&&&&&&&&&&&&");
    
    [_pieces replaceObjectAtIndex:cp withObject:pezzo];
    [_pieces replaceObjectAtIndex:ca withObject:pezzoInCasaArrivo];
    
    //[self printPosition];
    
    //NSLog(@"****************************     FINE METODO RE SOTTO SCACCO   ******************************");
    
    return diagnosi;
}

- (BOOL) ilReSottoScacco:(int)cp :(int)ca {
    
    //NSLog(@"****************************   INIZIO METODO RE SOTTO SCACCO   ******************************");
    
    NSString *pezzo = [_pieces objectAtIndex:cp];
    NSString *pezzoInCasaArrivo = [_pieces objectAtIndex:ca];
    
    //[self printPosition];
    
    [_pieces replaceObjectAtIndex:cp withObject:EMPTY];
    [_pieces replaceObjectAtIndex:ca withObject:pezzo];
    
    //[self printPosition];
    
    
    //NSLog(@"&&&&&&&&&&&&&&&&&&&  INIZIO  CONTROLLO RE SOTTO SCACCO   &&&&&&&&&&&&&&&&&&&&&&&");
    
    int tagRe = 0;
    NSMutableArray *kingChecked;
    if (_whiteHasToMove) {
        NSLog(@"CONTROLLO SE IL RE NERO SOTTO SCACCO");
        tagRe = [self getKingSquareTag:@"bk"];
        kingChecked = [self checkedSquare:tagRe :@"b" :-1];
    }
    else {
        NSLog(@"CONTROLLO SE IL RE BIANCO SOTTO SCACCO");
        tagRe = [self getKingSquareTag:@"wk"];
        kingChecked = [self checkedSquare:tagRe :@"w" :-1];
    }
    
    //NSLog(@"&&&&&&&&&&&&&&&&&&&  FINE  CONTROLLO RE SOTTO SCACCO   &&&&&&&&&&&&&&&&&&&&&&&");
    
    [_pieces replaceObjectAtIndex:cp withObject:pezzo];
    [_pieces replaceObjectAtIndex:ca withObject:pezzoInCasaArrivo];
    
    //[self printPosition];
          
    //NSLog(@"****************************     FINE METODO RE SOTTO SCACCO   ******************************");
    
    return kingChecked.count>0;
}

- (NSString *) controllaSeAltriPezziDelloStessoTipoPossonoRaggiungereUnaCasa2:(NSString *)pezzo :(int)casaPartenza :(int)casaArrivo {
    
    NSString *prefix = nil;
    
    if ([pezzo hasSuffix:@"p"] || [pezzo hasSuffix:@"k"]) {
        return prefix;
    }
    
    int svArrivo = [self convertTagValueToSquareValue:casaArrivo];
    int svPartenza = [self convertTagValueToSquareValue:casaPartenza];
    NSString *colore = [pezzo substringToIndex:1];
    
    NSMutableArray *altriPezziDelloStessoTipo = [[NSMutableArray alloc] init];
    
    //NSLog(@"PEZZO = %@   casaP=%d   casaA=%d", pezzo, svPartenza, svArrivo);
    
    if ([pezzo hasSuffix:@"r"]) { //Torre
        int numDirezioni = 4;
        for (int i=1; i<=numDirezioni; i++) {
            int delta = 0;
            switch (i) {
                case 1:
                    delta = 10;
                    break;
                case 2:
                    delta = -10;
                    break;
                case 3:
                    delta = 1;
                    break;
                case 4:
                    delta = -1;
                    break;
                default:
                    break;
            }
            BOOL continua = YES;
            int casa = svArrivo;
            while (continua) {
                casa = casa + delta;
                if (![self esisteCasa:casa]) {
                    break;
                }
                NSString *pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:casa];
                if ([pezzoInNuovaCasa isEqualToString:EMPTY]) {
                    continua = YES;
                }
                else if (![pezzoInNuovaCasa hasPrefix:colore]) {
                    break;
                }
                else if (![pezzoInNuovaCasa isEqualToString:pezzo]) {
                    break;
                }
                else if ([pezzoInNuovaCasa isEqualToString:pezzo] && casa!=casaPartenza) {
                    if (![self ilReSottoScacco:[self getTagValueFromSquareValue:casa] :casaArrivo]) {
                        [altriPezziDelloStessoTipo addObject:[NSNumber numberWithInt:casa]];
                    }
                    break;
                }
            }
        }
        NSLog(@"ççççççççççççççççççççççç TORRE   %@", altriPezziDelloStessoTipo);
    }
    
    if ([pezzo hasSuffix:@"n"]) {  //Cavallo
        int numDirezioni = 8;
        for (int i=1; i<=numDirezioni; i++) {
            int delta = 0;
            switch (i) {
                case 1:
                    delta = 12;
                    break;
                case 2:
                    delta = -12;
                    break;
                case 3:
                    delta = 21;
                    break;
                case 4:
                    delta = -21;
                    break;
                case 5:
                    delta = 19;
                    break;
                case 6:
                    delta = -19;
                    break;
                case 7:
                    delta = 8;
                    break;
                case 8:
                    delta = -8;
                    break;
                default:
                    break;
            }
            BOOL continua = YES;
            int casa = svArrivo;
            while (continua) {
                casa = casa + delta;
                if (![self esisteCasa:casa]) {
                    break;
                }
                NSString *pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:casa];
                if ([pezzoInNuovaCasa isEqualToString:EMPTY]) {
                    break;
                }
                else if (![pezzoInNuovaCasa hasPrefix:colore]) {
                    break;
                }
                else if (![pezzoInNuovaCasa isEqualToString:pezzo]) {
                    break;
                }
                else if ([pezzoInNuovaCasa isEqualToString:pezzo] && casa!=casaPartenza) {
                    if (![self ilReSottoScacco:[self getTagValueFromSquareValue:casa] :casaArrivo]) {
                        [altriPezziDelloStessoTipo addObject:[NSNumber numberWithInt:casa]];
                    }
                    break;
                }
            }
        }
        NSLog(@"ççççççççççççççççççççççç CAVALLO   %@", altriPezziDelloStessoTipo);
    }
    
    if ([pezzo hasSuffix:@"b"]) {  //Alfiere
        int numDirezioni = 4;
        for (int i=1; i<=numDirezioni; i++) {
            int delta = 0;
            switch (i) {
                case 1:
                    delta = 11;
                    break;
                case 2:
                    delta = -11;
                    break;
                case 3:
                    delta = 9;
                    break;
                case 4:
                    delta = -9;
                    break;
                default:
                    break;
            }
            BOOL continua = YES;
            int casa = svArrivo;
            while (continua) {
                casa = casa + delta;
                if (![self esisteCasa:casa]) {
                    break;
                }
                NSString *pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:casa];
                if ([pezzoInNuovaCasa isEqualToString:EMPTY]) {
                    continua = YES;
                }
                else if (![pezzoInNuovaCasa hasPrefix:colore]) {
                    break;
                }
                else if (![pezzoInNuovaCasa isEqualToString:pezzo]) {
                    break;
                }
                else if ([pezzoInNuovaCasa isEqualToString:pezzo] && casa!=casaPartenza) {
                    if (![self ilReSottoScacco:[self getTagValueFromSquareValue:casa] :casaArrivo]) {
                        [altriPezziDelloStessoTipo addObject:[NSNumber numberWithInt:casa]];
                    }
                    break;
                }
            }
        }
        NSLog(@"ççççççççççççççççççççççç ALFIERE   %@", altriPezziDelloStessoTipo);
    }
    
    if ([pezzo hasSuffix:@"q"]) {   //Donna
        int numDirezioni = 8;
        for (int i=1; i<=numDirezioni; i++) {
            int delta = 0;
            switch (i) {
                case 1:
                    delta = 10;
                    break;
                case 2:
                    delta = -10;
                    break;
                case 3:
                    delta = 1;
                    break;
                case 4:
                    delta = -1;
                    break;
                case 5:
                    delta = 11;
                    break;
                case 6:
                    delta = -11;
                    break;
                case 7:
                    delta = 9;
                    break;
                case 8:
                    delta = -9;
                    break;
                default:
                    break;
            }
            BOOL continua = YES;
            int casa = svArrivo;
            while (continua) {
                casa = casa + delta;
                if (![self esisteCasa:casa]) {
                    break;
                }
                NSString *pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:casa];
                if ([pezzoInNuovaCasa isEqualToString:EMPTY]) {
                    break;
                }
                else if (![pezzoInNuovaCasa hasPrefix:colore]) {
                    break;
                }
                else if (![pezzoInNuovaCasa isEqualToString:pezzo]) {
                    break;
                }
                else if ([pezzoInNuovaCasa isEqualToString:pezzo] && casa!=casaPartenza) {
                    if (![self ilReSottoScacco:[self getTagValueFromSquareValue:casa] :casaArrivo]) {
                        [altriPezziDelloStessoTipo addObject:[NSNumber numberWithInt:casa]];
                    }
                    break;
                }
            }
        }
        NSLog(@"ççççççççççççççççççççççç DONNA   %@", altriPezziDelloStessoTipo);
    }
    
    
    if ([altriPezziDelloStessoTipo count] <= 1) {
        return nil;
    }
    else {
        
        //controllo se i pezzi sono sulla colonna o sulla traversa
        NSMutableSet *colonne = [[NSMutableSet alloc] init];
        NSMutableSet *traverse = [[NSMutableSet alloc] init];
        for (NSNumber *n in altriPezziDelloStessoTipo) {
            NSString *ns = [n stringValue];
            //NSLog(@"CASA STRING = %@", ns);
            NSString *c = [ns substringToIndex:1];
            [colonne addObject:c];
            NSString *t = [ns substringFromIndex:1];
            [traverse addObject:t];
        }
        
        //NSLog(@"COLONNE:%@", colonne);
        //NSLog(@"TRAVERSE:%@", traverse);
        
        BOOL stessaTraversa = NO;
        BOOL stessaColonna = NO;
        
        if ([colonne count]==1 && [traverse count]>1) {
            stessaColonna = YES;
            stessaTraversa = NO;
        }
        else if ([colonne count]>1 && [traverse count]==1) {
            stessaColonna = NO;
            stessaTraversa = YES;
        }
        else {
            stessaColonna = NO;
            stessaTraversa = NO;
        }
        
        
        if ([altriPezziDelloStessoTipo containsObject:[NSNumber numberWithInt:svPartenza]]) {
            NSString *casaPartenzaAlgebrica = [self getAlgebricValueFromSquareTag:casaPartenza];
            if (stessaTraversa) {
                prefix = [casaPartenzaAlgebrica substringToIndex:1];
            }
            else if (stessaColonna) {
                prefix = [casaPartenzaAlgebrica substringFromIndex:1];
            }
            else {
                prefix = [casaPartenzaAlgebrica substringToIndex:1];
            }
            
            return prefix;
        }
    }
    
    return prefix;
}

#pragma mark - Fine Metodi utilizzati per il parsing delle partite con notazione estesa


- (NSString *) controllaSeAltriPezziDelloStessoTipoPossonoRaggiungereUnaCasa:(NSString *)pezzo :(short)casaPartenza :(short)casaArrivo {
    
    //[self controllaSeAltriPezziDelloStessoTipoPossonoRaggiungereUnaCasa2:pezzo :casaPartenza :casaArrivo];
    
    //NSLog(@"********************* Inizio Controllo Se Altri Pezzi");
    //NSLog(@"PEZZO:%@      CP:%d      CA:%d", pezzo, casaPartenza, casaArrivo);
    
    //[self printPosition];
    
    
    
    
    NSString *prefix = nil;
    
    if ([pezzo hasSuffix:@"p"] || [pezzo hasSuffix:@"k"]) {
        return prefix;
    }
    
    //Trovo gli altri pezzi dello stesso tipo e colore
    NSMutableArray *listaAltriPezziStessoColoreStessoTipo = [[NSMutableArray alloc] init];
    for (short i=0; i<64; i++) {
        NSString *pz = [_pieces objectAtIndex:i];
        if ([pz isEqualToString:pezzo] && i!=casaArrivo) {
            [listaAltriPezziStessoColoreStessoTipo addObject:[NSNumber numberWithShort:i]];
            //NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&&  %@    %d", pz, i);
        }
    }
    
    NSString *colore;
    if ([pezzo hasPrefix:@"w"]) {
        colore = @"b";
    }
    else {
        colore = @"w";
    }
    
    //NSMutableArray *listaPezzi = [self listaPezziCheControllano:casaArrivo :colore];
    
    NSString *algebricCasaPartenza = [_algebricSquares objectAtIndex:casaPartenza];
    //NSString *algebricCasaArrivo = [_algebricSquares objectAtIndex:casaArrivo];
    
    //NSLog(@"Casa Partenza %@    Casa Arrivo %@", algebricCasaPartenza, algebricCasaArrivo);
    
    //NSMutableArray *listaCaseConPezzi = [self checkedSquare2:casaArrivo :colore :-1];
    NSMutableArray *listaCaseConPezzi = [self listaCaseControllateDaiPezzi:casaPartenza :casaArrivo :colore];
    

    //NSLog(@"!!!!!!!!%@", listaCaseConPezzi);
    
    
    NSMutableArray *listaCaseAlgebricheAltriPezzi = [[NSMutableArray alloc] init];
    
    for (NSNumber *casa in listaCaseConPezzi) {
        short squareNumber = [self getTagValueFromSquareValue:casa.shortValue];
        NSString *pz = [_pieces objectAtIndex:squareNumber];
        if ([pz isEqualToString:pezzo]) {
            NSString *algebricAltroPezzo = [_algebricSquares objectAtIndex:squareNumber];
            [listaCaseAlgebricheAltriPezzi addObject:algebricAltroPezzo];
        }
    }
    
    if (listaCaseAlgebricheAltriPezzi.count == 0) {
        //NSLog(@"Non ci sono altri pezzi che possono andare in %@", algebricCasaArrivo);
        return prefix;
    }
    //NSLog(@"??????????????????  %@", listaCaseAlgebricheAltriPezzi);
    
    NSString *letteraCasaPartenza = [algebricCasaPartenza substringToIndex:1];
    BOOL stessaColonna = NO;
    for (NSString *algebricValue in listaCaseAlgebricheAltriPezzi) {
        //NSLog(@"Casa partenza %@  Casa Arrivo %@   Casa partenza Altro pezzo %@", algebricCasaPartenza, algebricCasaArrivo, algebricValue);
        NSString *letteraCasaPartenzaAltroPezzo = [algebricValue substringToIndex:1];
        if ([letteraCasaPartenza isEqualToString:letteraCasaPartenzaAltroPezzo]) {
            stessaColonna = YES;
            //NSLog(@"Due pezzi sono sulla stessa colonna");
            break;
        }
    }
    
    if (stessaColonna) {
        //NSLog(@"Ci sono almeno due pezzi che sono sulla stessa colonna");
        NSString *numeroCasaPartenza = [algebricCasaPartenza substringFromIndex:1];
        prefix = numeroCasaPartenza;
    }
    else {
        NSLog(@"Nessuno dei pezzi è sulla stessa colonna");
        prefix = letteraCasaPartenza;
    }
    
    
    if (prefix) {
        NSLog(@"Il prefisso per questa mossa è %@", prefix);
    }
    
    
    //NSLog(@"********************* FINE   Controllo Se Altri Pezzi");
    
    return prefix;
}


- (PGNMove *) muoviPezzo:(int)casaPartenza :(int)casaArrivo {
    
    if (_canCaptureEnPassant && (casaArrivo == _casaEnPassant)) {
        NSString *pezzo = [_pieces objectAtIndex:casaPartenza];
        NSString *pezzoChePuoCatturareEnPassant = [NSString stringWithFormat:@"%@p", colorCanCaptureEnpassant];
        if ([pezzo isEqualToString:pezzoChePuoCatturareEnPassant]) {
            NSLog(@"BOARDMODEL - MUOVIPEZZO: Devo gestire la presa enPassant");
            return [self completaMossaEnPassant:casaPartenza :casaArrivo];
        }
        _casaEnPassant = NO;
        _casaEnPassant = 0;
        colorCanCaptureEnpassant = nil;
    }
    
    
    
    //NSLog(@"Mossa: %d - %d", casaPartenza, casaArrivo);
    NSString *pezzo = [_pieces objectAtIndex:casaPartenza];
    NSString *pezzoInCasaArrivo = [_pieces objectAtIndex:casaArrivo];
    
    //Salvo informazioni FEN per Torre e/o Re per gestire l'arrocco
    //if ([pezzo hasSuffix:@"k"] || [pezzo hasSuffix:@"r"]) {
        //[stackFen addObject:[self fenNotation]];
    //}
    
    
    [_pieces replaceObjectAtIndex:casaPartenza withObject:EMPTY];
    [_pieces replaceObjectAtIndex:casaArrivo withObject:pezzo];
    
    
    //NSLog(@"PEZZO IN CASA DI ARRIVO = %@", pezzoInCasaArrivo);
    
    
    //Controllo En Passant
    
    [self checkIfNextMoveCanBeEnPassant:pezzo :casaPartenza :casaArrivo];
    
    
    unsigned int cp = [self convertTagValueToSquareValue:casaPartenza];
    unsigned int ca = [self convertTagValueToSquareValue:casaArrivo];
    

    //Controllo movimento Torri e Re
    if (_whiteHasToMove) {
        if ([pezzo hasSuffix:@"k"] && !reBiancoMosso) {
            reBiancoMosso = YES;
            //NSLog(@"Hai mosso per la prima volta il Re Bianco");
        }
        if ([pezzo hasSuffix:@"r"] && casaPartenza == 7 && !torreBiancaAlaReMossa) {
            torreBiancaAlaReMossa = YES;
            //NSLog(@"Hai mosso per la prima volta La Torre di Re Bianca");
        }
        if ([pezzo hasSuffix:@"r"] && casaPartenza == 0 && !torreBiancaAlaDonnaMossa) {
            torreBiancaAlaDonnaMossa = YES;
            //NSLog(@"Hai mosso per la prima volta La Torre di Donna Bianca");
        }
    }
    else {
        if ([pezzo hasSuffix:@"k"] && !reNeroMosso) {
            reNeroMosso = YES;
            //NSLog(@"Hai mosso per la prima volta il Re Nero");
        }
        if ([pezzo hasSuffix:@"r"] && casaPartenza == 63 && !torreBiancaAlaReMossa) {
            torreNeraAlaReMossa = YES;
            //NSLog(@"Hai mosso per la prima volta La Torre di Re Nera");
        }
        if ([pezzo hasSuffix:@"r"] && casaPartenza == 56 && !torreBiancaAlaDonnaMossa) {
            torreNeraAlaDonnaMossa = YES;
            //NSLog(@"Hai mosso per la prima volta La Torre di Donna Nera");
        }
    }
    
    
    
    
    //Inizio controllo se altri pezzi dello stesso tipo possono raggiumgere la stessa casa d'arrivo
    
    
    [self controllaSeAltriPezziDelloStessoTipoPossonoRaggiungereUnaCasa:pezzo :casaPartenza :casaArrivo];
    
    NSString *p = [[pezzo substringFromIndex:1] uppercaseString];
    if ([p isEqualToString:@"P"]) {
        p = @"";
    }
    
    NSString *prefix = [self controllaSeAltriPezziDelloStessoTipoPossonoRaggiungereUnaCasa:pezzo :casaPartenza :casaArrivo];
         
    
    NSString *caa = [_algebricSquares objectAtIndex:casaArrivo];
    NSString *mossa;
    
    if ([pezzoInCasaArrivo isEqualToString:EMPTY]) {
        mossa = [NSString stringWithFormat:@"%@%@", p, caa];
    }
    else {
        
        [pezziMangiati setObject:pezzoInCasaArrivo forKey:[[NSNumber alloc] initWithInt:(int)numeroSemiMossa]];
        
        NSString *cap = [_algebricSquares objectAtIndex:casaPartenza];
        NSString *pz = [[pezzo substringFromIndex:1] uppercaseString];
        if ([pz isEqualToString:@"P"]) {
            mossa = [NSString stringWithFormat:@"%@x%@", [cap substringToIndex:1], caa];
        }
        else {
            mossa = [NSString stringWithFormat:@"%@x%@", p, caa];
        }
    }
    NSString  *nms = nil;
    
    if (!(numeroSemiMossa & 1)) {
        int nm = (int)(numeroSemiMossa/2 + 1);
        nms = [NSString stringWithFormat:@"%d. ", nm];
    }
    
    if ([p isEqualToString:@"K"] && casaPartenza == 4 && casaArrivo == 6) {
        mossa = @"O-O";
        NSString *torre = [_pieces objectAtIndex:7];
        [_pieces replaceObjectAtIndex:7 withObject:EMPTY];
        [_pieces replaceObjectAtIndex:5 withObject:torre];
        
    }
    if ([p isEqualToString:@"K"] && casaPartenza == 4 && casaArrivo == 2) {
        mossa = @"O-O-O";
        NSString *torre = [_pieces objectAtIndex:0];
        [_pieces replaceObjectAtIndex:0 withObject:EMPTY];
        [_pieces replaceObjectAtIndex:3 withObject:torre];
    }
    if ([p isEqualToString:@"K"] && casaPartenza == 60 && casaArrivo == 62) {
        mossa = @"O-O";
        NSString *torre = [_pieces objectAtIndex:63];
        [_pieces replaceObjectAtIndex:63 withObject:EMPTY];
        [_pieces replaceObjectAtIndex:61 withObject:torre];
    }
    if ([p isEqualToString:@"K"] && casaPartenza == 60 && casaArrivo == 58) {
        mossa = @"O-O-O";
        NSString *torre = [_pieces objectAtIndex:56];
        [_pieces replaceObjectAtIndex:56 withObject:EMPTY];
        [_pieces replaceObjectAtIndex:59 withObject:torre];
    }
    
    
    //NSLog(@"MOSSA FINALE:%@", mossa);
    if (prefix) {
        NSString *first = [mossa substringWithRange:NSMakeRange(0, 1)];
        NSString *second = [mossa substringFromIndex:1];
        mossa = [[first stringByAppendingString:prefix] stringByAppendingString:second];
        //NSLog(@"MOSSA FINALE dopo prefix:%@", mossa);
    }
    
    NSMutableString *mossaString = [[NSMutableString alloc] init];
    if (nms) {
        [_listaMosse appendString:nms];
        [mossaString appendString:nms];
    }
    [_listaMosse appendString:mossa];
    [_listaMosse appendString:@" "];
    [mossaString appendString:mossa];
    [mossaString appendString:@" "];
    
    
    [listaMosseArray addObject:mossa];
    
    //NSLog(@"%@", _listaMosse);
    
    NSString *scp = [NSString stringWithFormat:@"%d", casaPartenza];
    NSString *sca = [NSString stringWithFormat:@"%d", casaArrivo];
    NSString *ms = [[scp stringByAppendingString:@"*"] stringByAppendingString:sca];
    [_mosse addObject:ms];
    
    //NSLog(@"%@", ms);
    //NSLog(@"Ultima Mossa = %@", mossaString);
    //NSLog(@"Mossa senza Numero = %@", mossa);
    
    numeroSemiMossa++;
    _whiteHasToMove = !_whiteHasToMove;
    
    //[self printPosition];
    
    
    //Inizio Istruzioni per poter generare correttamente FEN
    if ([pezzo hasSuffix:@"wp"]  && (cp%10==2) && (ca%10==4)) {
        fenEnPassant = YES;
        fenEnPassantSquare = [self getAlgebricValueFromSquareTag:casaPartenza + 8];
    }
    else if ([pezzo hasSuffix:@"bp"]  && (cp%10==7) && (ca%10==5)) {
        fenEnPassant = YES;
        fenEnPassantSquare = [self getAlgebricValueFromSquareTag:casaPartenza - 8];
    }
    else {
        fenEnPassant = NO;
    }
    if (![pezzo hasSuffix:@"p"] && [pezzoInCasaArrivo hasSuffix:@"em"] ) {
        numeroSemimosseDaUltimaMossaPedoneOPresa++;
    }
    else {
        numeroSemimosseDaUltimaMossaPedoneOPresa = 0;
    }
    //Fine istruzioni per FEN
    
    
    mossa = [self controllaScaccoEScaccoMatto:mossa :casaArrivo];
    
    PGNMove *pgnMove = [[PGNMove alloc] initWithFullMove:mossa];
    [pgnMove setPlyCount:(int)[self getPlyCount]];
    [pgnMove setColor:[self getColorLastMove]];
    //[pgnMove setFromSquare:casaPartenza];
    //[pgnMove setToSquare:casaArrivo];
    
    //NSLog(@"BOARDMODEL: CASA PARTENZA = %d    CASA ARRIVO = %d", pgnMove.fromSquare, pgnMove.toSquare);
    
    //Voglio controllare se con questa mossa ho dato scacco al re avversario
    
    //[self controllaScaccoEScaccoMatto:pgnMove :casaArrivo];
    
    return pgnMove;
}

- (NSString *) findPezzoMangiatoByPlyCount:(NSUInteger)plyCount {
    return [pezziMangiati objectForKey:[NSNumber numberWithUnsignedInteger:plyCount]];
}

- (NSMutableString *)listaMosse {
    //NSMutableString *lm = [[NSMutableString alloc] init];
    //for (NSString *m in listaMosseArray) {
    //    [lm appendString:m];
    //}
    NSLog(@"LISTAMOSSE      %@", _listaMosse);
    return _listaMosse;
}

- (NSString *) getColorLastMove {
    if (_whiteHasToMove) {
        return @"b";
    }
    return @"w";
}


- (PGNMove *) promuoviPezzo:(int)casaPartenza :(int)casaArrivo :(NSString *)pezzoPromosso {

    NSLog(@"Mossa PROMOZIONE: %d - %d", casaPartenza, casaArrivo);
    NSString *pezzo = [_pieces objectAtIndex:casaPartenza];
    NSString *pezzoInCasaArrivo = [_pieces objectAtIndex:casaArrivo];
    [_pieces replaceObjectAtIndex:casaPartenza withObject:EMPTY];
    [_pieces replaceObjectAtIndex:casaArrivo withObject:pezzoPromosso];
    
    
    NSLog(@"PEZZO IN CASA DI ARRIVO = %@", pezzoInCasaArrivo);
    
    NSString *p = [[pezzo substringFromIndex:1] uppercaseString];
    if ([p isEqualToString:@"P"]) {
        p = @"";
    }
    
    NSString *prefix;
    
    NSString *caa = [_algebricSquares objectAtIndex:casaArrivo];
    NSString *mossa;
    if ([pezzoInCasaArrivo isEqualToString:EMPTY]) {
        mossa = [NSString stringWithFormat:@"%@%@", p, caa];
    }
    else {
        
        [pezziMangiati setObject:pezzoInCasaArrivo forKey:[[NSNumber alloc] initWithInt:(int)numeroSemiMossa]];
        
        NSString *cap = [_algebricSquares objectAtIndex:casaPartenza];
        NSString *pz = [[pezzo substringFromIndex:1] uppercaseString];
        if ([pz isEqualToString:@"P"]) {
            mossa = [NSString stringWithFormat:@"%@x%@", [cap substringToIndex:1], caa];
        }
        else {
            mossa = [NSString stringWithFormat:@"%@x%@", p, caa];
        }
    }
    NSString  *nms = nil;
    
    if (!(numeroSemiMossa & 1)) {
        int nm = (int)(numeroSemiMossa/2 + 1);
        nms = [[NSString stringWithFormat:@"%d", nm] stringByAppendingString:@"."];
    }
    
    
    //NSLog(@"MOSSA FINALE:%@", mossa);
    if (prefix) {
        NSString *first = [mossa substringWithRange:NSMakeRange(0, 1)];
        NSString *second = [mossa substringFromIndex:1];
        mossa = [[first stringByAppendingString:prefix] stringByAppendingString:second];
        //NSLog(@"MOSSA FINALE dopo prefix:%@", mossa);
    }
    
    
    if (nms) {
        [_listaMosse appendString:nms];
    }
    
    NSString *pp = [[pezzoPromosso substringFromIndex:1] uppercaseString];
    mossa = [[mossa stringByAppendingString:@"="] stringByAppendingString:pp];
    
    [_listaMosse appendString:mossa];
    [_listaMosse appendString:@" "];
    
    //NSLog(@"%@", _listaMosse);
    
    NSString *scp = [NSString stringWithFormat:@"%d", casaPartenza];
    NSString *sca = [NSString stringWithFormat:@"%d", casaArrivo];
    NSString *ms = [[scp stringByAppendingString:@"*"] stringByAppendingString:sca];
    [_mosse addObject:ms];
    
    NSLog(@"%@", ms);
    
    numeroSemiMossa++;
    _whiteHasToMove = !_whiteHasToMove;
    
    
    mossa = [self controllaScaccoEScaccoMatto:mossa :casaArrivo];
    
    NSLog(@"MOSSA = %@", mossa);
    
    PGNMove *pgnMove = [[PGNMove alloc] initWithFullMove:mossa];
    [pgnMove setPlyCount:(int)[self getPlyCount]];
    [pgnMove setColor:[self getColorLastMove]];
    //[pgnMove setFromSquare:casaPartenza];
    //[pgnMove setToSquare:casaArrivo];
    //if (pgnMove.capture) {
    //    [pgnMove setCaptured:[self findPezzoMangiatoByPlyCount:pgnMove.plyCount - 1]];
    //}
    
    //[self printPosition];
    
    //[self controllaScaccoEScaccoMatto:pgnMove :casaArrivo];
    
    NSLog(@"BOARDMODEL: CASA PARTENZA = %d    CASA ARRIVO = %d", pgnMove.fromSquare, pgnMove.toSquare);
    
    
    numeroSemimosseDaUltimaMossaPedoneOPresa = 0;
    
    return pgnMove;
}


- (PGNMove *) completaMossaEnPassant:(int)casaPartenza :(int)casaArrivo {
    //NSLog(@"Mossa: %d - %d", casaPartenza, _casaEnPassant);
    
    NSUInteger *enPassantSquare;
    
    [_pieces replaceObjectAtIndex:casaPartenza withObject:EMPTY];
    if (_whiteHasToMove) {
        [_pieces replaceObjectAtIndex:_casaEnPassant withObject:@"wp"];
        [_pieces replaceObjectAtIndex:_casaEnPassant - 8 withObject:EMPTY];
        enPassantSquare = _casaEnPassant - 8;
    }
    else {
        [_pieces replaceObjectAtIndex:_casaEnPassant withObject:@"bp"];
        [_pieces replaceObjectAtIndex:_casaEnPassant + 8 withObject:EMPTY];
        enPassantSquare = _casaEnPassant + 8;
    }
    
    NSString *cap = [_algebricSquares objectAtIndex:casaPartenza];
    NSString *caa = [_algebricSquares objectAtIndex:_casaEnPassant];
    NSString *mossa = [NSString stringWithFormat:@"%@x%@", [cap substringToIndex:1], caa];
    
    NSLog(@"MOSSA EN PASSANT = %@", mossa);
    
    NSString  *nms = nil;
    
    if (!(numeroSemiMossa & 1)) {
        int nm = (int)(numeroSemiMossa/2 + 1);
        nms = [[NSString stringWithFormat:@"%d", nm] stringByAppendingString:@"."];
    }
    
    if (nms) {
        [_listaMosse appendString:nms];
    }
    [_listaMosse appendString:mossa];
    [_listaMosse appendString:@" "];
    
    NSString *scp = [NSString stringWithFormat:@"%d", casaPartenza];
    NSString *sca = [NSString stringWithFormat:@"%d", casaArrivo];
    NSString *ms = [[scp stringByAppendingString:@"*"] stringByAppendingString:sca];
    [_mosse addObject:ms];
    
    NSLog(@"%@", ms);
    
    _canCaptureEnPassant = NO;
    _casaEnPassant = 0;
    numeroSemiMossa++;
    _whiteHasToMove = !_whiteHasToMove;
    
    //[self printPosition];
    //NSLog(@"LISTAMOSSE = %@", _listaMosse);
    
    mossa = [self controllaScaccoEScaccoMatto:mossa :casaArrivo];
    
    PGNMove *pgnMove = [[PGNMove alloc] initWithFullMove:mossa];
    [pgnMove setPlyCount:(int)[self getPlyCount]];
    [pgnMove setColor:[self getColorLastMove]];
    //[pgnMove setFromSquare:casaPartenza];
    //[pgnMove setToSquare:casaArrivo];
    //[pgnMove setCaptured:[self findPezzoMangiatoByPlyCount:pgnMove.plyCount - 1]];
    //[pgnMove setEnPassantCapture:YES];
    //[pgnMove setEnPassant:YES];
    //[pgnMove setEnPassantPieceSquare:enPassantSquare];
    
    
    //[self controllaScaccoEScaccoMatto:pgnMove :casaArrivo];
    
    numeroSemimosseDaUltimaMossaPedoneOPresa = 0;
    
    return pgnMove;
}


- (BOOL) sonoPezziDelloStessoColore:(int)squareFrom :(int)squareTo {
    NSString *p1 = [_pieces objectAtIndex:squareFrom];
    NSString *p2 = [_pieces objectAtIndex:squareTo];
    
    //Questa controllo evita il crash che si aveva quando un pezzo andava a muoversi nella casa del re avversario
    if ([p2 hasSuffix:@"k"]) {
        return YES;
    }
    
    
    if (![p1 isEqualToString:EMPTY]  && ![p2 isEqualToString:EMPTY]) {
        NSString *p1First = [p1 substringWithRange:NSMakeRange(0, 1)];
        NSString *p2First = [p2 substringWithRange:NSMakeRange(0, 1)];
        if ([p1First isEqualToString:p2First]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) colorePezzoOk:(int)squareFrom {
    NSString *pezzoMosso = [_pieces objectAtIndex:squareFrom];
    NSString *colorePezzo = [pezzoMosso substringWithRange:NSMakeRange(0, 1)];
    if ([colorePezzo isEqualToString:@"w"] && _whiteHasToMove) {
        return YES;
    }
    else if ([colorePezzo isEqualToString:@"b"] && !_whiteHasToMove) {
        return YES;
    }
    return NO;
}

- (void) stampaMossa:(int)casaPartenza :(int)casaArrivo {
    return;
    NSString *pezzo = [_pieces objectAtIndex:casaArrivo];
    //NSNumber *cp = [_squares objectAtIndex:casaPartenza];
    //NSNumber *ca = [_squares objectAtIndex:casaArrivo];
    
    NSString *p = [[pezzo substringFromIndex:1] uppercaseString];
    
    //NSString *cap = [algebricSquares objectAtIndex:casaPartenza];
    NSString *caa = [_algebricSquares objectAtIndex:casaArrivo];
    
    if ([p isEqualToString:@"P"]) {
        p = @"";
    }
    
    
    
    //NSLog(@"%@ %d%d", pezzo, cp.intValue, ca.intValue);
    NSLog(@"%@%@", p, caa);
}

- (NSString *) getPreviousMove {
    if (numeroSemiMossa == 0) {
        return nil;
    }
    //NSLog(@"Attuale numero semimosse: %d", numeroSemiMossa);
    numeroSemiMossa--;
    
    NSString *ms = [_mosse objectAtIndex:numeroSemiMossa];
    
    if (ms) {
        //NSLog(@"Mossa corrispondente a semimossa %d : %@", numeroSemiMossa, ms);
        NSRange range = [ms rangeOfString:@"*"];
        NSString *scp = [ms substringToIndex:range.location];
        NSString *sca = [ms substringFromIndex:range.location + 1];
        NSString *pscp = [_pieces objectAtIndex:[sca intValue]];
        NSLog(@"devo eseguire la mossa: %@ %@-%@", pscp, sca, scp);
        
        [_pieces replaceObjectAtIndex:[scp intValue] withObject:pscp];
        [_pieces replaceObjectAtIndex:[sca intValue] withObject:EMPTY];
        NSString *probabilePezzoMangiato = [pezziMangiati objectForKey:[[NSNumber alloc] initWithInt:(int)numeroSemiMossa]];
        if (probabilePezzoMangiato) {
            //NSLog(@"A questo punto devo rimettere in gioco il pezzo magiato nella boardmodel");
            [_pieces replaceObjectAtIndex:[sca intValue] withObject:probabilePezzoMangiato];
        }
    }
    return [_mosse objectAtIndex:numeroSemiMossa];
}

/*
- (Mossa *) mossaPrecedente {
    if (numeroSemiMossa == 0) {
        return nil;
    }
    numeroSemiMossa--;
    _whiteHasToMove = !_whiteHasToMove;
    Mossa *prevMossa = [[Mossa alloc] init];
    NSString *pm = [_mosse objectAtIndex:numeroSemiMossa];
    if (pm) {
        NSLog(@"Mossa corrispondente a semimossa %d : %@", numeroSemiMossa, pm);
        NSRange range = [pm rangeOfString:@"*"];
        NSString *scp = [pm substringToIndex:range.location];
        NSString *sca = [pm substringFromIndex:range.location + 1];
        NSString *pscp = [_pieces objectAtIndex:[sca intValue]];
        [prevMossa setCasaPartenza:sca];
        [prevMossa setCasaArrivo:scp];
        NSLog(@"devo eseguire la mossa: %@ %@-%@", pscp, sca, scp);
        NSString *probabilePezzoMangiato = [pezziMangiati objectForKey:[[NSNumber alloc] initWithInt:numeroSemiMossa]];
        if (probabilePezzoMangiato) {
            [prevMossa setPezzoMangiato:probabilePezzoMangiato];
        }
        return prevMossa;
    }
    return nil;
}

- (Mossa *) mossaSuccessiva {
    if (numeroSemiMossa == _mosse.count) {
        return nil;
    }
    Mossa *nextMossa = [[Mossa alloc] init];
    NSString *nm = [_mosse objectAtIndex:numeroSemiMossa];
    if (nm) {
        NSLog(@"Mossa corrispondente a semimossa %d : %@", numeroSemiMossa, nm);
        NSRange range = [nm rangeOfString:@"*"];
        NSString *scp = [nm substringToIndex:range.location];
        NSString *sca = [nm substringFromIndex:range.location + 1];
        NSString *pscp = [_pieces objectAtIndex:[scp intValue]];
        [nextMossa setCasaPartenza:scp];
        [nextMossa setCasaArrivo:sca];
        NSLog(@"devo eseguire la mossa: %@ %@-%@", pscp, scp, sca);
        NSString *probabilePezzoMangiato = [pezziMangiati objectForKey:[[NSNumber alloc] initWithInt:numeroSemiMossa]];
        if (probabilePezzoMangiato) {
            [nextMossa setPezzoMangiato:probabilePezzoMangiato];
        }
        numeroSemiMossa++;
        _whiteHasToMove = !_whiteHasToMove;
        return nextMossa;
    }
    return nil;
}
*/
 
- (NSString *) getNextMove {
    if (numeroSemiMossa == _mosse.count) {
        return nil;
    }
    
    NSString *ms = [_mosse objectAtIndex:numeroSemiMossa++];
    if (ms) {
        NSRange range = [ms rangeOfString:@"*"];
        NSString *scp = [ms substringToIndex:range.location];
        NSString *sca = [ms substringFromIndex:range.location + 1];
        NSString *pezzo = [_pieces objectAtIndex:[scp intValue]];
        NSString *pezzoInCasaArrivo = [_pieces objectAtIndex:[sca intValue]];
        [_pieces replaceObjectAtIndex:[scp intValue] withObject:EMPTY];
        [_pieces replaceObjectAtIndex:[sca intValue] withObject:pezzo];
        if (![pezzoInCasaArrivo isEqualToString:EMPTY]) {
            [pezziMangiati setObject:pezzoInCasaArrivo forKey:[[NSNumber alloc] initWithInt:(int)numeroSemiMossa]];
        }
    }
    
    return ms;
}

- (int) getNumeroSemiMossa {
    return (int)numeroSemiMossa;
}

- (int) getKingSquareTag:(NSString *)king {
    for (int i=0; i<_pieces.count; i++) {
        if ([[_pieces objectAtIndex:i] isEqualToString:king]) {
            return i;
        }
    }
    return -1;
}

- (BOOL) esisteCasa:(int)squareValue {
    //NSLog(@"Esiste Casa = %d", squareValue);
    NSNumber *squareNumericValue = [NSNumber numberWithInt:squareValue];
    //[self printSquares];
    return [_squares containsObject:squareNumericValue];
}


- (NSMutableArray *) checkedSquare:(int) square :(NSString *)fromColor :(int)casaInclusa {
    
    //NSMutableArray *caseInveceDeiPezzi = [[NSMutableArray alloc] init];
    
    NSMutableArray *pezziCheControllano = [[NSMutableArray alloc] init];
    int squareNumber = [self convertTagValueToSquareValue:square];
    if (casaInclusa != -1) {
        casaInclusa = [self convertTagValueToSquareValue:casaInclusa];
    }
    unsigned int nuovaCasa = 0;
    NSString *pezzoInNuovaCasa;
    BOOL continua = YES;
    for (int direction = 1; direction<=16; direction++) {
        nuovaCasa = squareNumber;
        switch (direction) {
            case 1:
                do {
                    nuovaCasa = nuovaCasa + 1;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa: %@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY]  || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (nuovaCasa - squareNumber == 1)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"q"] || [pezzoInNuovaCasa hasSuffix:@"r"]) {
                                //NSLog(@"Ho trovato una Torre o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 2:
                do {
                    nuovaCasa = nuovaCasa - 1;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (squareNumber - nuovaCasa == 1)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"q"] || [pezzoInNuovaCasa hasSuffix:@"r"]) {
                                //NSLog(@"Ho trovato una Torre o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 3:
                do {
                    nuovaCasa = nuovaCasa + 10;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (nuovaCasa - squareNumber == 10)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"q"] || [pezzoInNuovaCasa hasSuffix:@"r"]) {
                                //NSLog(@"Ho trovato una Torre o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 4:
                do {
                    nuovaCasa = nuovaCasa - 10;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (squareNumber - nuovaCasa == 10)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"q"] || [pezzoInNuovaCasa hasSuffix:@"r"]) {
                                //NSLog(@"Ho trovato una Torre o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 5:
                do {
                    nuovaCasa = nuovaCasa + 11;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (nuovaCasa - squareNumber == 11)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"p"] && (nuovaCasa - squareNumber == 11) && [fromColor isEqualToString:@"w"]) {
                                //NSLog(@"Ho trovato un Pedone che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"b"] || [pezzoInNuovaCasa hasSuffix:@"q"]) {
                                //NSLog(@"Ho trovato un Alfiere o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 6:
                do {
                    nuovaCasa = nuovaCasa - 11;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (squareNumber - nuovaCasa == 11)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"p"] && (squareNumber - nuovaCasa == 11) && [fromColor isEqualToString:@"b"]) {
                                //NSLog(@"Ho trovato un Pedone che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"b"] || [pezzoInNuovaCasa hasSuffix:@"q"]) {
                                //NSLog(@"Ho trovato un Alfiere o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 7:
                do {
                    nuovaCasa = nuovaCasa + 9;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (nuovaCasa - squareNumber == 9)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"p"] && (nuovaCasa - squareNumber == 9) && [fromColor isEqualToString:@"b"]) {
                                //NSLog(@"Ho trovato un Pedone che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"b"] || [pezzoInNuovaCasa hasSuffix:@"q"]) {
                                //NSLog(@"Ho trovato un Alfiere o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 8:
                do {
                    nuovaCasa = nuovaCasa - 9;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (squareNumber - nuovaCasa == 9)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"p"] && (squareNumber - nuovaCasa == 9) && [fromColor isEqualToString:@"w"]) {
                                //NSLog(@"Ho trovato un Pedone che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"b"] || [pezzoInNuovaCasa hasSuffix:@"q"]) {
                                //NSLog(@"Ho trovato un Alfiere o una Donna  che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 9: {
                nuovaCasa = nuovaCasa + 12;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                        break;
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                                //NSLog(@"Ho trovato un cavallo che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                        }
                    }
                }
                break;
            case 10: {
                nuovaCasa = nuovaCasa - 12;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                }
                break;
            case 11:
                nuovaCasa = nuovaCasa + 8;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                break;
            case 12:
                nuovaCasa = nuovaCasa - 8;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                break;
            case 13:
                nuovaCasa = nuovaCasa + 21;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                break;
            case 14:
                nuovaCasa = nuovaCasa - 21;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                break;
            case 15:
                nuovaCasa = nuovaCasa + 19;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                break;
            case 16:
                nuovaCasa = nuovaCasa - 19;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                break;
        }
    }
    return pezziCheControllano;
    //return caseInveceDeiPezzi;
}


#pragma mark - Metodi per vedere se il re è sotto scacco o scacco matto


- (NSString *) controllaScaccoEScaccoMatto:(NSString *)move :(short)casaArrivo {
    NSArray *checkArray = [self hoDatoScacco];
    
    switch (checkArray.count) {
        case 0:
            //Non ci sono scacchi al Re
            //NSLog(@"Non ci sono scacchi al re");
            break;
        case 1: {
            
            BOOL scaccoDiScoperta;
            NSString *pezzoCheDaScaccoDiScoperta;
            BOOL pezzoCheDaScaccoPuoEssereCatturato;
            BOOL rePuoMuoversi;
            BOOL pezziPossonoInterporsi;
            
            
            short casa = [self getTagValueFromSquareValue:[[checkArray objectAtIndex:0] shortValue]];
            if (casaArrivo == casa) {
                //NSLog(@"Con il pezzo %@ di colore %@ nella casa %d ho dato scacco alla mossa %d", pgnMove.piece, pgnMove.color, casaArrivo, pgnMove.plyCount);
                //NSLog(@"BOARDMODEL >> Con questa mossa ho dato scacco.");
                scaccoDiScoperta = NO;
            }
            else {
                //NSLog(@"BOARDMODEL >> Con questa mossa ho dato scacco di scoperta.");
                pezzoCheDaScaccoDiScoperta = [self findContenutoBySquareNumber:casa];
                //NSLog(@"Con il pezzo %@ di colore %@ nella casa %d ho dato scacco di scoperta alla mossa %d", pezzoCheDaScaccoDiScoperta, pgnMove.color, casa, pgnMove.plyCount);
                scaccoDiScoperta = YES;
            }
            
            //[pgnMove setCheck:YES];
            //move = [move stringByAppendingString:@"+"];
            
            //Controllo se posso parare lo scacco muovendo il Re
            if ([self ilRePuoMuoversi]) {
                //NSLog(@"Per parare lo scacco il re può muoversi");
                rePuoMuoversi = YES;
            }
            else {
                //NSLog(@"Per parare lo scacco il re non può muoversi");
                rePuoMuoversi = NO;
            }
            //Controllo se posso parare lo scacco mangiando il pezzo che da scacco
            
            if (scaccoDiScoperta) {
                if ([self ilPezzoNellaCasaPuoEssereCatturato:casa]) {
                    //NSLog(@"Il pezzo %@ può essere catturato", pezzoCheDaScaccoDiScoperta);
                    pezzoCheDaScaccoPuoEssereCatturato = YES;
                }
                else {
                    //NSLog(@"Il pezzo %@ non può essere catturato", pezzoCheDaScaccoDiScoperta);
                    pezzoCheDaScaccoPuoEssereCatturato = NO;
                }
            }
            else {
                if ([self ilPezzoNellaCasaPuoEssereCatturato:casaArrivo]) {
                    //NSLog(@"Il pezzo %@%@ può essere catturato", pgnMove.color, pgnMove.piece);
                    pezzoCheDaScaccoPuoEssereCatturato = YES;
                }
                else {
                    //NSLog(@"Il pezzo %@%@ non può essere catturato", pgnMove.color, pgnMove.piece);
                    pezzoCheDaScaccoPuoEssereCatturato = NO;
                }
            }
            
            //Controllo se posso parare lo scacco interponendo un pezzo
            NSArray *listaPezziDaInterporre;
            if (scaccoDiScoperta) {
                listaPezziDaInterporre = [self trovaInterposizionePezzo:casa];
            }
            else {
                listaPezziDaInterporre = [self trovaInterposizionePezzo:casaArrivo];
            }
            pezziPossonoInterporsi = listaPezziDaInterporre.count>0;
            
            //for (NSNumber *n in listaPezziDaInterporre) {
            //NSString *pezzo = [self trovaContenutoConNumeroCasa:[n shortValue]];
            //NSLog(@"Pezzo da interporre nella casa %d = %@ che si trova nella casa %d", 0, pezzo, [self getTagValueFromSquareValue:[n shortValue]]);
            //}
            
            
            if (!pezzoCheDaScaccoPuoEssereCatturato && !rePuoMuoversi && !pezziPossonoInterporsi) {
                //NSLog(@"LO SCACCO E' MATTO");
                move = [move stringByAppendingString:@"#"];
            }
            else {
                move = [move stringByAppendingString:@"+"];
            }
            
        }
            break;
        case 2: {
            NSLog(@"Con l'ultima mossa ho dato scacco doppio e posso pararlo solamente muovendo il re");
            //Controllo se posso parare lo scacco muovendo il Re
            //[pgnMove setCheck:YES];
            move = [move stringByAppendingString:@"+"];
            if ([self ilRePuoMuoversi]) {
                //NSLog(@"Per parare lo scacco il re può muoversi");
            }
            else {
                //NSLog(@"Per parare lo scacco il re non può muoversi");
                //[pgnMove setCheckMate:YES];
                move = [move stringByAppendingString:@"#"];
            }
        }
            break;
        default:
            break;
    }
    
    return move;
}

/*
- (void) controllaScaccoEScaccoMatto:(PGNMove *)pgnMove :(short)casaArrivo {
    NSArray *checkArray = [self hoDatoScacco];
    
    switch (checkArray.count) {
        case 0:
            //Non ci sono scacchi al Re
            break;
        case 1: {
            BOOL scaccoDiScoperta;
            NSString *pezzoCheDaScaccoDiScoperta;
            BOOL pezzoCheDaScaccoPuoEssereCatturato;
            BOOL rePuoMuoversi;
            BOOL pezziPossonoInterporsi;
            
            
            short casa = [self getTagValueFromSquareValue:[[checkArray objectAtIndex:0] shortValue]];
            if (casaArrivo == casa) {
                //NSLog(@"Con il pezzo %@ di colore %@ nella casa %d ho dato scacco alla mossa %d", pgnMove.piece, pgnMove.color, casaArrivo, pgnMove.plyCount);
                //NSLog(@"BOARDMODEL >> Con questa mossa ho dato scacco.");
                scaccoDiScoperta = NO;
            }
            else {
                //NSLog(@"BOARDMODEL >> Con questa mossa ho dato scacco di scoperta.");
                pezzoCheDaScaccoDiScoperta = [self findContenutoBySquareNumber:casa];
                //NSLog(@"Con il pezzo %@ di colore %@ nella casa %d ho dato scacco di scoperta alla mossa %d", pezzoCheDaScaccoDiScoperta, pgnMove.color, casa, pgnMove.plyCount);
                scaccoDiScoperta = YES;
            }
            
            [pgnMove setCheck:YES];
            
            //Controllo se posso parare lo scacco muovendo il Re
            if ([self ilRePuoMuoversi]) {
                //NSLog(@"Per parare lo scacco il re può muoversi");
                rePuoMuoversi = YES;
            }
            else {
                //NSLog(@"Per parare lo scacco il re non può muoversi");
                rePuoMuoversi = NO;
            }
            //Controllo se posso parare lo scacco mangiando il pezzo che da scacco
            
            if (scaccoDiScoperta) {
                if ([self ilPezzoNellaCasaPuoEssereCatturato:casa]) {
                    //NSLog(@"Il pezzo %@ può essere catturato", pezzoCheDaScaccoDiScoperta);
                    pezzoCheDaScaccoPuoEssereCatturato = YES;
                }
                else {
                    //NSLog(@"Il pezzo %@ non può essere catturato", pezzoCheDaScaccoDiScoperta);
                    pezzoCheDaScaccoPuoEssereCatturato = NO;
                }
            }
            else {
                if ([self ilPezzoNellaCasaPuoEssereCatturato:casaArrivo]) {
                    //NSLog(@"Il pezzo %@%@ può essere catturato", pgnMove.color, pgnMove.piece);
                    pezzoCheDaScaccoPuoEssereCatturato = YES;
                }
                else {
                    //NSLog(@"Il pezzo %@%@ non può essere catturato", pgnMove.color, pgnMove.piece);
                    pezzoCheDaScaccoPuoEssereCatturato = NO;
                }
            }
            
            //Controllo se posso parare lo scacco interponendo un pezzo
            NSArray *listaPezziDaInterporre;
            if (scaccoDiScoperta) {
                listaPezziDaInterporre = [self trovaInterposizionePezzo:casa];
            }
            else {
                listaPezziDaInterporre = [self trovaInterposizionePezzo:casaArrivo];
            }
            pezziPossonoInterporsi = listaPezziDaInterporre.count>0;
            
            //for (NSNumber *n in listaPezziDaInterporre) {
                //NSString *pezzo = [self trovaContenutoConNumeroCasa:[n shortValue]];
                //NSLog(@"Pezzo da interporre nella casa %d = %@ che si trova nella casa %d", 0, pezzo, [self getTagValueFromSquareValue:[n shortValue]]);
            //}
            
            
            if (!pezzoCheDaScaccoPuoEssereCatturato && !rePuoMuoversi && !pezziPossonoInterporsi) {
                //NSLog(@"LO SCACCO E' MATTO");
                [pgnMove setCheckMate:YES];
            }
            
        }
            break;
        case 2: {
            //NSLog(@"Con l'ultima mossa ho dato scacco doppio e posso pararlo solamente muovendo il re");
            //Controllo se posso parare lo scacco muovendo il Re
            [pgnMove setCheck:YES];
            if ([self ilRePuoMuoversi]) {
                //NSLog(@"Per parare lo scacco il re può muoversi");
            }
            else {
                //NSLog(@"Per parare lo scacco il re non può muoversi");
                [pgnMove setCheckMate:YES];
            }
        }
            break;
        default:
            break;
    }
}
*/

- (NSArray *) hoDatoScacco {
    int tagRe = 0;
    NSMutableArray *kingChecked;
    if (_whiteHasToMove) {
        tagRe = [self getKingSquareTag:@"wk"];
        kingChecked = [self checkedSquare2:tagRe :@"w" :-1];
    }
    else {
        tagRe = [self getKingSquareTag:@"bk"];
        kingChecked = [self checkedSquare2:tagRe :@"b" :-1];
    }
    return kingChecked;
}

- (BOOL) ilRePuoMuoversi {
    NSMutableArray *caseDisponibili = [[NSMutableArray alloc] init];
    short casaRePartenza = -1;
    short casaReArrivo = -1;
    if (_whiteHasToMove) {
        casaRePartenza = [self getKingSquareTag:@"wk"];
    }
    else {
        casaRePartenza = [self getKingSquareTag:@"bk"];
    }
    short colPartenza = [self getColumnFromSquare:casaRePartenza];
    short rowPartenza = [self getRowFromSquare:casaRePartenza];
    short colArrivo = -1;
    short rowArrivo = -1;
    for (PGNSquare *square in kingSearchPath) {
        colArrivo = colPartenza + square.column;
        rowArrivo = rowPartenza + square.row;
        if (!((colArrivo<0) || (colArrivo>7) || (rowArrivo<0) || (rowArrivo>7))) {
            casaReArrivo = [self getSquareValueFromColumnAndRaw:colArrivo :rowArrivo];
            if (![self sonoPezziDelloStessoColore:casaRePartenza :casaReArrivo]) {
                if (![self reSottoScacco:casaRePartenza :casaReArrivo]) {
                    [caseDisponibili addObject:[NSNumber numberWithInt:casaReArrivo]];
                }
            }
        }
    }
    if (caseDisponibili.count > 0) {
        //NSLog(@"Il Re può muoversi nelle seguenti case:");
        //for (NSNumber *n in caseDisponibili) {
            //NSLog(@"%d", [n shortValue]);
        //}
        return YES;
    }
    return NO;
}

#pragma mark - Metodo per trovare i pezzi da interporre per parare uno scacco al Re

- (NSArray *) trovaInterposizionePezzo:(short)casaPezzoCheDaScacco {
    
    NSMutableArray *listaPezziDaInterporre = [[NSMutableArray alloc] init];
    
    NSString *pezzoCheDaScacco = [self findContenutoBySquareNumber:casaPezzoCheDaScacco];
    short casaReSottoScacco;
    short passo = 0;
    short numeroCaseDaInterporre = 0;
    if (_whiteHasToMove) {
        casaReSottoScacco = [self getKingSquareTag:@"wk"];
    }
    else {
        casaReSottoScacco = [self getKingSquareTag:@"bk"];
    }
    short differenza = casaReSottoScacco - casaPezzoCheDaScacco;
    //NSLog(@"La differenza è = %d", differenza);
    //NSLog(@"Il pezzo che da scacco è %@", pezzoCheDaScacco);
    if ([pezzoCheDaScacco hasSuffix:@"p"] || [pezzoCheDaScacco hasSuffix:@"n"]) {
        //NSLog(@"Per parare questo scacco non si possono interporre pezzi");
        return listaPezziDaInterporre;
    }
    else if ([pezzoCheDaScacco hasSuffix:@"b"]) {
        //NSLog(@"Interposizione tra Alfiere in %d e Re in %d", casaPezzoCheDaScacco, casaReSottoScacco);
        if (differenza%7 == 0) {
            passo = differenza/(abs(differenza/7));
            numeroCaseDaInterporre = abs(differenza/7) - 1;
        }
        else if (differenza%9 == 0) {
            passo = differenza/(abs(differenza/9));
            numeroCaseDaInterporre = abs(differenza/9) - 1;
        }
        short casaDaInterporre = casaPezzoCheDaScacco;
        //NSLog(@"Il passo è %d e il numero case da interporre è %d", passo, numeroCaseDaInterporre);
        for (int i=1; i<=numeroCaseDaInterporre; i++) {
            casaDaInterporre += passo;
            NSString *colore;
            if (_whiteHasToMove) {
                colore = @"w";
            }
            else {
                colore = @"b";
            }
            NSArray *pezziDaInterporre = [self getListaPezziDaInterporreIn:casaDaInterporre :colore];
            [listaPezziDaInterporre addObjectsFromArray:pezziDaInterporre];
            
            NSMutableArray *pezziDaEscludere = [[NSMutableArray alloc] init];
            for (NSNumber *nc in listaPezziDaInterporre) {
                short tagPartenza = [self getTagValueFromSquareValue:[nc shortValue]];
                if ([self reSottoScacco:tagPartenza :casaDaInterporre]) {
                    [pezziDaEscludere addObject:nc];
                }
            }
            [listaPezziDaInterporre removeObjectsInArray:pezziDaEscludere];
            
            //for (NSNumber *n in pezziDaInterporre) {
            //    NSString *pezzo = [self trovaContenutoConNumeroCasa:[n shortValue]];
            //    NSLog(@"Pezzo da interporre nella casa %d = %@ che si trova nella casa %d", casaDaInterporre, pezzo, [self getTagValueFromSquareValue:[n shortValue]]);
            //}
        }
    }
    else if ([pezzoCheDaScacco hasSuffix:@"r"]) {
        //NSLog(@"Interposizione tra Torre in %d e Re in %d", casaPezzoCheDaScacco, casaReSottoScacco);
        if (differenza%8 == 0) {
            passo = differenza/(abs(differenza/8));
            numeroCaseDaInterporre = abs(differenza/8) - 1;
        }
        else if (differenza%1 == 0) {
            passo = differenza/(abs(differenza/1));
            numeroCaseDaInterporre = abs(differenza/1) - 1;
        }
        short casaDaInterporre = casaPezzoCheDaScacco;
        //NSLog(@"Il passo è %d e il numero case da interporre è %d", passo, numeroCaseDaInterporre);
        for (int i=1; i<=numeroCaseDaInterporre; i++) {
            casaDaInterporre += passo;
            NSString *colore;
            if (_whiteHasToMove) {
                colore = @"w";
            }
            else {
                colore = @"b";
            }
            NSArray *pezziDaInterporre = [self getListaPezziDaInterporreIn:casaDaInterporre :colore];
            [listaPezziDaInterporre addObjectsFromArray:pezziDaInterporre];
            
            
            NSMutableArray *pezziDaEscludere = [[NSMutableArray alloc] init];
            for (NSNumber *nc in listaPezziDaInterporre) {
                short tagPartenza = [self getTagValueFromSquareValue:[nc shortValue]];
                if ([self reSottoScacco:tagPartenza :casaDaInterporre]) {
                    [pezziDaEscludere addObject:nc];
                }
            }
            [listaPezziDaInterporre removeObjectsInArray:pezziDaEscludere];
            
            //for (NSNumber *n in pezziDaInterporre) {
            //    NSString *pezzo = [self trovaContenutoConNumeroCasa:[n shortValue]];
            //    NSLog(@"Pezzo da interporre nella casa %d = %@ che si trova nella casa %d", casaDaInterporre, pezzo, [self getTagValueFromSquareValue:[n shortValue]]);
            //}
        }
    }
    else if ([pezzoCheDaScacco hasSuffix:@"q"]) {
        //NSLog(@"Interposizione tra Donna in %d e Re in %d", casaPezzoCheDaScacco, casaReSottoScacco);
        if (differenza%7 == 0) {
            passo = differenza/(abs(differenza/7));
            numeroCaseDaInterporre = abs(differenza/7) - 1;
        }
        else if (differenza%9 == 0) {
            passo = differenza/(abs(differenza/9));
            numeroCaseDaInterporre = abs(differenza/9) - 1;
        }
        else if (differenza%8 == 0) {
            passo = differenza/(abs(differenza/8));
            numeroCaseDaInterporre = abs(differenza/8) - 1;
        }
        else if (differenza%1 == 0) {
            passo = differenza/(abs(differenza/1));
            numeroCaseDaInterporre = abs(differenza/1) - 1;
        }
        short casaDaInterporre = casaPezzoCheDaScacco;
        //NSLog(@"Il passo è %d e il numero case da interporre è %d", passo, numeroCaseDaInterporre);
        for (int i=1; i<=numeroCaseDaInterporre; i++) {
            casaDaInterporre += passo;
            NSString *colore;
            if (_whiteHasToMove) {
                colore = @"w";
            }
            else {
                colore = @"b";
            }
            NSArray *pezziDaInterporre = [self getListaPezziDaInterporreIn:casaDaInterporre :colore];
            [listaPezziDaInterporre addObjectsFromArray:pezziDaInterporre];
            
            
            NSMutableArray *pezziDaEscludere = [[NSMutableArray alloc] init];
            for (NSNumber *nc in listaPezziDaInterporre) {
                short tagPartenza = [self getTagValueFromSquareValue:[nc shortValue]];
                if ([self reSottoScacco:tagPartenza :casaDaInterporre]) {
                    [pezziDaEscludere addObject:nc];
                }
            }
            [listaPezziDaInterporre removeObjectsInArray:pezziDaEscludere];
            
            //for (NSNumber *n in pezziDaInterporre) {
            //    NSString *pezzo = [self trovaContenutoConNumeroCasa:[n shortValue]];
            //    NSLog(@"Pezzo da interporre nella casa %d = %@ che si trova nella casa %d", casaDaInterporre, pezzo, [self getTagValueFromSquareValue:[n shortValue]]);
            //}
        }
    }
    return listaPezziDaInterporre;
}


- (NSArray *) getListaPezziDaInterporreIn:(short)casa :(NSString *)colore {
    NSMutableArray *listaPezziDaInterporre = [[NSMutableArray alloc] init];
    int squareNumber = [self convertTagValueToSquareValue:casa];
    //NSLog(@"Casa = %d e SquareNumber = %d", casa, squareNumber);
    
    
    //Vedo se la casa può essere occupata da un Cavallo
    for (NSNumber *n in cavalloPath) {
        short passo = [n shortValue];
        short casaDovePotrebbeEssereIlCavallo = squareNumber + passo;
        if ([self esisteCasa:casaDovePotrebbeEssereIlCavallo]) {
            //NSLog(@"Devo vedere se la casa %d contiene un cavallo", casaDovePotrebbeEssereIlCavallo);
            NSString *pezzo = [self trovaContenutoConNumeroCasa:casaDovePotrebbeEssereIlCavallo];
            if ([pezzo hasPrefix:colore] && [pezzo hasSuffix:@"n"]) {
                //NSLog(@"Ho trovato un cavallo %@ nella casa %d", pezzo, casaDovePotrebbeEssereIlCavallo);
                [listaPezziDaInterporre addObject:[NSNumber numberWithShort:casaDovePotrebbeEssereIlCavallo]];
            }
        }
    }
    //Vedo se la casa può essere occupata da un Alfiere
    for (NSNumber *n in alfierePath) {
        short passo = [n shortValue];
        
        short casaPezzo = [self trovaPezzo:squareNumber :passo :colore :@"b"];
        if (casaPezzo>=0) {
            //NSLog(@"Ho trovato un Alfiere %@ nella casa %d", [self trovaContenutoConNumeroCasa:casaPezzo], casaPezzo);
            [listaPezziDaInterporre addObject:[NSNumber numberWithShort:casaPezzo]];
        }
    }
    
    //Vedo se la casa può essere occupata dalla Torre
    
    for (NSNumber *n in torrePath) {
        short passo = [n shortValue];
        short casaPezzo = [self trovaPezzo:squareNumber :passo :colore :@"r"];
        if (casaPezzo>=0) {
            //NSLog(@"Ho trovato una Torre %@ nella casa %d", [self trovaContenutoConNumeroCasa:casaPezzo], casaPezzo);
            [listaPezziDaInterporre addObject:[NSNumber numberWithShort:casaPezzo]];
        }
    }
    
    //Vedo se la casa può essere occupata dalla Donna
    
    for (NSNumber *n in donnaPath) {
        short passo = [n shortValue];
        short casaPezzo = [self trovaPezzo:squareNumber :passo :colore :@"q"];
        if (casaPezzo>=0) {
            //NSLog(@"Ho trovato una Donna %@ nella casa %d", [self trovaContenutoConNumeroCasa:casaPezzo], casaPezzo);
            [listaPezziDaInterporre addObject:[NSNumber numberWithShort:casaPezzo]];
        }
    }
    
    //vedo se la casa può essere occupata da un Pedone
    short passo = 0;
    if ([colore isEqualToString:@"w"]) {
        passo = [[pedoneNeroPath objectAtIndex:0] shortValue];
    }
    else {
        passo = [[pedoneBiancoPath objectAtIndex:0] shortValue];
    }
    short casaPezzo = [self trovaPezzo:squareNumber :passo :colore :@"p"];
    if (casaPezzo>=0) {
        //NSLog(@"Ho trovato una Pedone %@ nella casa %d", [self trovaContenutoConNumeroCasa:casaPezzo], casaPezzo);
        [listaPezziDaInterporre addObject:[NSNumber numberWithShort:casaPezzo]];
    }
    else {
        //NSLog(@"Non esistono pedone nella casa %d", squareNumber + passo);
        
        if ([colore isEqualToString:@"b"] && [self getRowFromSquare:[self getTagValueFromSquareValue:squareNumber]] == 4) {
            //NSLog(@"Il pedone NERO può trovarsi nella casa di partenza");
            casaPezzo = [self trovaPezzo:squareNumber + passo :passo :colore :@"p"];
            if (casaPezzo>=0) {
                //NSLog(@"Ho trovato una Pedone %@ nella casa %d", [self trovaContenutoConNumeroCasa:casaPezzo], casaPezzo);
                [listaPezziDaInterporre addObject:[NSNumber numberWithShort:casaPezzo]];
            }
        }
        else if ([colore isEqualToString:@"w"] && [self getRowFromSquare:[self getTagValueFromSquareValue:squareNumber]] == 3) {
            //NSLog(@"Il pedone BIANCO può trovarsi nella casa di partenza");
            casaPezzo = [self trovaPezzo:squareNumber + passo :passo :colore :@"p"];
            if (casaPezzo>=0) {
                //NSLog(@"Ho trovato una Pedone %@ nella casa %d", [self trovaContenutoConNumeroCasa:casaPezzo], casaPezzo);
                [listaPezziDaInterporre addObject:[NSNumber numberWithShort:casaPezzo]];
            }
        }
    }
    
    return listaPezziDaInterporre;
}

- (short) trovaPezzo :(short)casaOrigine :(short)passo :(NSString *)colore :(NSString *)pezzo {
    short casaDovePotrebbeEssereIlPezzo = casaOrigine + passo;
    if ([self esisteCasa:casaDovePotrebbeEssereIlPezzo]) {
        NSString *pezzoTrovato = [self trovaContenutoConNumeroCasa:casaDovePotrebbeEssereIlPezzo];
        if ([pezzoTrovato hasPrefix:colore] && [pezzoTrovato hasSuffix:pezzo]) {
            return casaDovePotrebbeEssereIlPezzo;
        }
        if ([pezzoTrovato isEqualToString:EMPTY] && ![pezzo isEqualToString:@"p"]) {
            return [self trovaPezzo:casaDovePotrebbeEssereIlPezzo :passo :colore :pezzo];
        }
        return -1;
    }
    return -1;
}

- (BOOL) pedoneMaiMosso:(short) casaOrigine {
    //NSLog(@"Devo verificare se il pedone in %d è stato mai mosso", casaOrigine);
    return NO;
}

- (BOOL) hoDatoScaccoMatto {
    BOOL scaccoMatto = YES;
    short tagKingPartenza = -1;
    short tagKingArrivo = -1;
    if (_whiteHasToMove) {
        tagKingPartenza = [self getKingSquareTag:@"wk"];
    }
    else {
        tagKingPartenza = [self getKingSquareTag:@"bk"];
    }
    short colPartenza = [self getColumnFromSquare:tagKingPartenza];
    short rowPartenza = [self getRowFromSquare:tagKingPartenza];
    short colArrivo = -1;
    short rowArrivo = -1;
    for (PGNSquare *square in kingSearchPath) {
        colArrivo = colPartenza + square.column;
        rowArrivo = rowPartenza + square.row;
        if ((colArrivo<0) || (colArrivo>7) || (rowArrivo<0) || (rowArrivo>7)) {
            //continue;
        }
        else {
            tagKingArrivo = [self getSquareValueFromColumnAndRaw:colArrivo :rowArrivo];
            if (![self sonoPezziDelloStessoColore:tagKingPartenza :tagKingArrivo]) {
                if (![self reSottoScacco:tagKingPartenza :tagKingArrivo]) {
                    scaccoMatto = NO;
                    break;
                }
            }
        }
    }
    return scaccoMatto;
}

- (BOOL) ilPezzoNellaCasaPuoEssereCatturato:(NSUInteger)casa {
    BOOL puoEssereCatturato = NO;
    NSString *pezzoDaCatturare = [self getPieceAtSquareTag:(int)casa];
    //NSLog(@"Il pezzo da catturare è %@", pezzoDaCatturare);
    NSString *colore = [pezzoDaCatturare substringToIndex:1];
    //NSLog(@"Colore = %@", colore);
    if ([self verificaCasaSottoAttacco:(int)casa :colore]) {
        puoEssereCatturato = YES;
    }
    return puoEssereCatturato;
}

- (BOOL) verificaCasaSottoAttacco:(int)casa :(NSString *)fromColor {
    NSMutableArray *listaPezzi;
    listaPezzi = [self checkedSquare2:casa :fromColor :-1];
    NSMutableArray *pezziDaEscludere = [[NSMutableArray alloc] init];
    for (NSNumber *nc in listaPezzi) {
        //NSLog(@"Pezzo che può catturare = %d", [self getTagValueFromSquareValue:[nc shortValue]]);
        short tagPartenza = [self getTagValueFromSquareValue:[nc shortValue]];
        if ([self reSottoScacco:tagPartenza :casa]) {
            [pezziDaEscludere addObject:nc];
        }
    }
    [listaPezzi removeObjectsInArray:pezziDaEscludere];
    return listaPezzi.count>0;
}

- (BOOL) reSottoScacco:(int)casaPartenza :(int)casaArrivo {
    //NSLog(@"BoardModel  Re SottoScacco  Mossa: %d - %d", casaPartenza, casaArrivo);
    NSString *pezzo = [_pieces objectAtIndex:casaPartenza];
    NSString *pezzoInCasaArrivo = [_pieces objectAtIndex:casaArrivo];
    
    //NSLog(@"PEZZO CASA PARTENZA =%@        PEZZO IN CASA ARRIVO = %@", pezzo, pezzoInCasaArrivo);
    
    
    //Le seguenti istruzioni impostano la posizione che si deve controllare compreso il controllo della presa al varco.
    [_pieces replaceObjectAtIndex:casaPartenza withObject:EMPTY];
    [_pieces replaceObjectAtIndex:casaArrivo withObject:pezzo];
    if ([self canCaptureEnPassant]) {
        if ([pezzo hasSuffix:@"wp"] && casaArrivo == _casaEnPassant) {
            [_pieces replaceObjectAtIndex:_casaEnPassant - 8 withObject:EMPTY];
        }
        else if ([pezzo hasSuffix:@"bp"] && casaArrivo == _casaEnPassant) {
            [_pieces replaceObjectAtIndex:_casaEnPassant + 8 withObject:EMPTY];
        }
    }
    
    //[self printPosition];
    
    //Controllo vero e proprio della posizione impostata per vedere se il Re è sotto Scacco
    int tagRe = 0;
    NSMutableArray *kingChecked;
    if (_whiteHasToMove) {
        tagRe = [self getKingSquareTag:@"wk"];
        kingChecked = [self checkedSquare:tagRe :@"w" :-1];
    }
    else {
        tagRe = [self getKingSquareTag:@"bk"];
        kingChecked = [self checkedSquare:tagRe :@"b" :-1];
    }
    
    //Ripsristino della posizione iniziale
    [_pieces replaceObjectAtIndex:casaPartenza withObject:pezzo];
    [_pieces replaceObjectAtIndex:casaArrivo withObject:pezzoInCasaArrivo];
    if ([self canCaptureEnPassant]) {
        if ([pezzo hasSuffix:@"wp"] && casaArrivo == _casaEnPassant) {
            [_pieces replaceObjectAtIndex:_casaEnPassant - 8 withObject:pezzo];
        }
        else if ([pezzo hasSuffix:@"bp"] && casaArrivo == _casaEnPassant) {
            [_pieces replaceObjectAtIndex:_casaEnPassant + 8 withObject:pezzo];
        }
    }
    
    
    //[self printPosition];
    
    //NSLog(@"Numero in KingChecked = %d", kingChecked.count);
    
    return kingChecked.count>0;
}

- (BOOL) kingCheckedMate {
    BOOL sottoScacco = YES;
    short tagKingPartenza = -1;
    short tagKingArrivo = -1;
    if (_whiteHasToMove) {
        tagKingPartenza = [self getKingSquareTag:@"wk"];
    }
    else {
        tagKingPartenza = [self getKingSquareTag:@"bk"];
    }
    short colPartenza = [self getColumnFromSquare:tagKingPartenza];
    short rowPartenza = [self getRowFromSquare:tagKingPartenza];
    short colArrivo = -1;
    short rowArrivo = -1;
    for (PGNSquare *square in kingSearchPath) {
        colArrivo = colPartenza + square.column;
        rowArrivo = rowPartenza + square.row;
        if ((colArrivo<0) || (colArrivo>7) || (rowArrivo<0) || (rowArrivo>7)) {
            //continue;
        }
        else {
            tagKingArrivo = [self getSquareValueFromColumnAndRaw:colArrivo :rowArrivo];
            if (![self sonoPezziDelloStessoColore:tagKingPartenza :tagKingArrivo]) {
                if (![self reSottoScacco:tagKingPartenza :tagKingArrivo]) {
                    sottoScacco = NO;
                    break;
                }
            }
        }
    }
    return sottoScacco;
}

- (short) getColumnFromSquare:(short) square {
    for (short r = 0; r<=7; r++) {
        for (short c = 0; c<=7; c++) {
            short sq = c + r*8;
            if (sq == square) {
                return c;
            }
        }
    }
    return -1;
}

- (short) getRowFromSquare:(short) square {
    for (short r = 0; r<=7; r++) {
        for (short c = 0; c<=7; c++) {
            short sq = c + r*8;
            if (sq == square) {
                return r;
            }
        }
    }
    return -1;
}

- (short) getSquareValueFromColumnAndRaw:(short)column :(short)row {
    short squareValue = 0;
    for (int r=0; r<=row; r++) {
        squareValue = column + r*8;
    }
    return squareValue;
}


- (BOOL) casaSottoAttacco:(int)casa :(NSString *)fromColor {
    NSMutableArray *listaPezzi;
    listaPezzi = [self checkedSquare:casa :fromColor :-1];
    for (NSString *pezzo in listaPezzi) {
        NSLog(@"Pezzo che può catturare = %@", pezzo);
    }
    return listaPezzi.count>0;
}



- (NSMutableArray *) listaPezziCheControllano:(int)casa :(NSString *)fromColor {
    NSMutableArray *listaPezzi;
    listaPezzi = [self checkedSquare:casa :fromColor :-1];
    //for (int i=0; i<listaPezzi.count; i++) {
    //    NSLog(@"Pezzo: %@", [listaPezzi objectAtIndex:i]);
    //}
    return listaPezzi;
}


- (NSMutableArray *) listaPezziCheControllano:(int)casaPartenza :(int)casaArrivo :(NSString *)fromColor {
    //NSLog(@"Mossa: %d - %d", casaPartenza, casaArrivo);
    NSString *pezzo = [_pieces objectAtIndex:casaPartenza];
    NSString *pezzoInCasaArrivo = [_pieces objectAtIndex:casaArrivo];
    [_pieces replaceObjectAtIndex:casaPartenza withObject:pezzoInCasaArrivo];
    [_pieces replaceObjectAtIndex:casaArrivo withObject:EMPTY];
    
    
    NSMutableArray *listaPezzi;
    listaPezzi = [self checkedSquare:casaArrivo :fromColor :-1];
    //for (int i=0; i<listaPezzi.count; i++) {
    //    NSLog(@"Pezzo: %@", [listaPezzi objectAtIndex:i]);
    //}
    
    [_pieces replaceObjectAtIndex:casaPartenza withObject:pezzo];
    [_pieces replaceObjectAtIndex:casaArrivo withObject:pezzoInCasaArrivo];
    return listaPezzi;
}

- (NSMutableArray *) listaCaseControllateDaiPezzi:(int)casaPartenza :(int)casaArrivo :(NSString *)fromColor {
    //NSLog(@"Mossa: %d - %d      FROMCOLOR:%@", casaPartenza, casaArrivo, fromColor);
    //[self printPosition];
    NSString *pezzo = [_pieces objectAtIndex:casaPartenza];
    NSString *pezzoInCasaArrivo = [_pieces objectAtIndex:casaArrivo];
    [_pieces replaceObjectAtIndex:casaPartenza withObject:pezzoInCasaArrivo];
    [_pieces replaceObjectAtIndex:casaArrivo withObject:EMPTY];
    
    
    //[self printPosition];
    
    NSMutableArray *listaPezzi;
    listaPezzi = [self checkedSquare2:casaArrivo :fromColor :-1];
    //for (int i=0; i<listaPezzi.count; i++) {
    //    NSLog(@"Pezzo: %@", [listaPezzi objectAtIndex:i]);
    //}
    
    //[self printPosition];
    
    [_pieces replaceObjectAtIndex:casaPartenza withObject:pezzo];
    [_pieces replaceObjectAtIndex:casaArrivo withObject:pezzoInCasaArrivo];
    
    //[self printPosition];
    return listaPezzi;
}


- (BOOL) reMatto {
    NSUInteger tagRe = 0;
    BOOL checked = NO;
    BOOL checkMate = NO;
    if (_whiteHasToMove) {
        tagRe = [self getKingSquareTag:@"wk"];
        //NSLog(@"Devo vedere se il re %d è sotto scacco", tagRe);
        //checked = [self checkedSquare:tagRe :@"w" :-1];
        checked = [self casaSottoAttacco:(int)tagRe :@"w"];
        if (checked) {
            //NSLog(@"Eseguo il controllo per vedere se è matto wk");
        }
        else {
            //NSLog(@"NON Eseguo il controllo per vedere se è matto wk pecrhè non è sotto scacco");
        }
    }
    else {
        tagRe = [self getKingSquareTag:@"bk"];
        //NSLog(@"Devo vedere se il re %d è sotto scacco", tagRe);
        //checked = [self checkedSquare:tagRe :@"b" :-1];
        checked = [self casaSottoAttacco:(int)tagRe :@"b"];
        if (checked) {
            //NSLog(@"Eseguo il controllo per vedere se è matto bk");
        }
        else {
            //NSLog(@"NON Eseguo il controllo per vedere se è matto bk pecrhè non è sotto scacco");
        }
    }
    if (checked) {
        checkMate = checked;
        NSInteger tagDestination;
        for (int i=1; i<=8; i++) {
            switch (i) {
                case 1:
                    tagDestination = tagRe + 8;
                    break;
                case 2:
                    tagDestination = tagRe - 8;
                    break;
                case 3:
                    tagDestination = tagRe + 1;
                    break;
                case 4:
                    tagDestination = tagRe - 1;
                    break;
                case 5:
                    tagDestination = tagRe + 7;
                    break;
                case 6:
                    tagDestination = tagRe - 7;
                    break;
                case 7:
                    tagDestination = tagRe + 9;
                    break;
                case 8:
                    tagDestination = tagRe - 9;
                    break;
                default:
                    break;
            }
            if (tagDestination>=0 && tagDestination<=63) {
                NSUInteger tagDestinationConvertito = [self convertTagValueToSquareValue:(int)tagDestination];
                //NSLog(@"Casa destinazione RE prima = %d e convertita = %d", tagDestination,   tagDestinationConvertito);
                NSString *contenutoTagDestination = [self trovaContenutoConNumeroCasa:(int)tagDestinationConvertito];
                NSLog(@"Contenuto Destination = %@", contenutoTagDestination);
                if ([self sonoPezziDelloStessoColore:(int)tagRe :(int)tagDestination]) {
                    NSLog(@"I due pezzi sono dello stesso colore quindi continuo con la prossima casa");
                    continue;
                }
                else {
                    if (_whiteHasToMove) {
                        if (![self casaSottoAttacco:(int)tagDestination :@"w"]) {
                            //NSLog(@"La casa non %d è sotto attacco", tagDestination);
                            return NO;
                        }
                    }
                    else {
                        if (![self casaSottoAttacco:(int)tagDestination :@"b"]) {
                            //NSLog(@"La casa %d non è sotto attacco", tagDestination);
                            return NO;
                        }
                    }
                }
            }
        }
        return checkMate;
        
    }
    return NO;
}

#pragma mark - Metodo checkedSquare duplicato e cambiato di nome in cui viene restituito un array di case piuttosto che un array di pezzi che danno scacco

- (NSMutableArray *) checkedSquare2:(int) square :(NSString *)fromColor :(int)casaInclusa {
    
    NSMutableArray *caseCheControllano = [[NSMutableArray alloc] init];
    
    //pezziCheControllano = [[NSMutableArray alloc] init];
    int squareNumber = [self convertTagValueToSquareValue:square];
    if (casaInclusa != -1) {
        casaInclusa = [self convertTagValueToSquareValue:casaInclusa];
    }
    unsigned int nuovaCasa = 0;
    NSString *pezzoInNuovaCasa;
    BOOL continua = YES;
    for (int direction = 1; direction<=16; direction++) {
        nuovaCasa = squareNumber;
        switch (direction) {
            case 1:
                do {
                    nuovaCasa = nuovaCasa + 1;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa: %@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY]  || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (nuovaCasa - squareNumber == 1)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"q"] || [pezzoInNuovaCasa hasSuffix:@"r"]) {
                                //NSLog(@"Ho trovato una Torre o una Donna che controllano la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 2:
                do {
                    nuovaCasa = nuovaCasa - 1;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (squareNumber - nuovaCasa == 1)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"q"] || [pezzoInNuovaCasa hasSuffix:@"r"]) {
                                //NSLog(@"Ho trovato una Torre o una Donna che controllano la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 3:
                do {
                    nuovaCasa = nuovaCasa + 10;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (nuovaCasa - squareNumber == 10)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"q"] || [pezzoInNuovaCasa hasSuffix:@"r"]) {
                                //NSLog(@"Ho trovato una Torre o una Donna che controllano la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 4:
                do {
                    nuovaCasa = nuovaCasa - 10;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (squareNumber - nuovaCasa == 1)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"q"] || [pezzoInNuovaCasa hasSuffix:@"r"]) {
                                //NSLog(@"Ho trovato una Torre o una Donna che controllano la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 5:
                do {
                    nuovaCasa = nuovaCasa + 11;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (nuovaCasa - squareNumber == 11)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"p"] && (nuovaCasa - squareNumber == 11) && [fromColor isEqualToString:@"w"]) {
                                //NSLog(@"Ho trovato un Pedone che controlla la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"b"] || [pezzoInNuovaCasa hasSuffix:@"q"]) {
                                //NSLog(@"Ho trovato un Alfiere o una Donna che controllano la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 6:
                do {
                    nuovaCasa = nuovaCasa - 11;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (squareNumber - nuovaCasa == 11)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"p"] && (squareNumber - nuovaCasa == 11) && [fromColor isEqualToString:@"b"]) {
                                //NSLog(@"Ho trovato un Pedone che controlla la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"b"] || [pezzoInNuovaCasa hasSuffix:@"q"]) {
                                //NSLog(@"Ho trovato un Alfiere o una Donna che controllano la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 7:
                do {
                    nuovaCasa = nuovaCasa + 9;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (nuovaCasa - squareNumber == 9)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"p"] && (nuovaCasa - squareNumber == 9) && [fromColor isEqualToString:@"b"]) {
                                //NSLog(@"Ho trovato un Pedone che controlla la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"b"] || [pezzoInNuovaCasa hasSuffix:@"q"]) {
                                //NSLog(@"Ho trovato un Alfiere o una Donna che controllano la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 8:
                do {
                    nuovaCasa = nuovaCasa - 9;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (squareNumber - nuovaCasa == 9)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"p"] && (squareNumber - nuovaCasa == 9) && [fromColor isEqualToString:@"w"]) {
                                //NSLog(@"Ho trovato un Pedone che controlla la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"b"] || [pezzoInNuovaCasa hasSuffix:@"q"]) {
                                //NSLog(@"Ho trovato un Alfiere o una Donna  che controllano la casa");
                                //[pezziCheControllano addObject:pezzoInNuovaCasa];
                                [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 9: {
                nuovaCasa = nuovaCasa + 12;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            //[pezziCheControllano addObject:pezzoInNuovaCasa];
                            [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
            }
                break;
            case 10: {
                nuovaCasa = nuovaCasa - 12;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            //[pezziCheControllano addObject:pezzoInNuovaCasa];
                            [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
            }
                break;
            case 11:
                nuovaCasa = nuovaCasa + 8;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            //[pezziCheControllano addObject:pezzoInNuovaCasa];
                            [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                break;
            case 12:
                nuovaCasa = nuovaCasa - 8;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            //[pezziCheControllano addObject:pezzoInNuovaCasa];
                            [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                break;
            case 13:
                nuovaCasa = nuovaCasa + 21;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            //[pezziCheControllano addObject:pezzoInNuovaCasa];
                            [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                break;
            case 14:
                nuovaCasa = nuovaCasa - 21;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            //[pezziCheControllano addObject:pezzoInNuovaCasa];
                            [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                break;
            case 15:
                nuovaCasa = nuovaCasa + 19;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            //[pezziCheControllano addObject:pezzoInNuovaCasa];
                            [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                break;
            case 16:
                nuovaCasa = nuovaCasa - 19;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            //[pezziCheControllano addObject:pezzoInNuovaCasa];
                            [caseCheControllano addObject:[NSNumber numberWithShort:nuovaCasa]];
                        }
                    }
                }
                break;
        }
    }
    //return pezziCheControllano;
    return caseCheControllano;
}



//metodi per la generazione delle mosse

/*
- (void) calcolaMossePseudoLegali {
    for (int r=7; r>=0; r--) {
        for (int c=0; c<8; c++) {
            int sn = r*8+c;
            NSString *piece = [_pieces objectAtIndex:sn];
            if (![piece isEqualToString:EMPTY]) {
                NSLog(@"calcolo mosse pseudo legali di %@ nella casa %d", piece, sn);
            }
        }
    }
}*/

#pragma mark - Gestione degli arrocchi

- (BOOL) biancoPuoArroccareCorto {
    if (!(reBiancoMosso || torreBiancaAlaReMossa)) {
        if (![self casaSottoAttacco:5 :@"w"]) {
            if (![self casaSottoAttacco:4 :@"w"]) {
                if (![self casaSottoAttacco:6 :@"w"]) {
                    if ([[_pieces objectAtIndex:7] isEqualToString:@"wr"]) {
                        if ([[_pieces objectAtIndex:6] isEqualToString:EMPTY]) {
                            if ([[_pieces objectAtIndex:5] isEqualToString:EMPTY]) {
                                return YES;
                            }
                        }
                    }
                }
            }
        }
    }
    return NO;
    //return !(reBiancoMosso || torreBiancaAlaReMossa);
}

- (BOOL) biancoPuoArroccareLungo {
    if (!(reBiancoMosso || torreBiancaAlaDonnaMossa)) {
        if (![self casaSottoAttacco:3 :@"w"]) {
            if (![self casaSottoAttacco:4 :@"w"]) {
                if (![self casaSottoAttacco:2 :@"w"]) {
                    if ([[_pieces objectAtIndex:0] isEqualToString:@"wr"]) {
                        if ([[_pieces objectAtIndex:1] isEqualToString:EMPTY]) {
                            if ([[_pieces objectAtIndex:2] isEqualToString:EMPTY]) {
                                if ([[_pieces objectAtIndex:3] isEqualToString:EMPTY]) {
                                    return YES;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return NO;
    //return !(reBiancoMosso || torreBiancaAlaDonnaMossa);
}

- (BOOL) neroPuoArroccareCorto {
    if (!(reNeroMosso || torreNeraAlaReMossa)) {
        
        if (![self casaSottoAttacco:61 :@"b"]) {
            if (![self casaSottoAttacco:62 :@"b"]) {
                if (![self casaSottoAttacco:60 :@"b"]) {
                    if ([[_pieces objectAtIndex:63] isEqualToString:@"br"]) {
                        if ([[_pieces objectAtIndex:61] isEqualToString:EMPTY]) {
                            if ([[_pieces objectAtIndex:62] isEqualToString:EMPTY]) {
                                return YES;
                            }
                        }
                    }
                }
            }
        }
    }
    return NO;
    //return !(reNeroMosso || torreNeraAlaReMossa);
}

- (BOOL) neroPuoArroccareLungo {
    if (!(reNeroMosso || torreNeraAlaDonnaMossa)) {
        if (![self casaSottoAttacco:59 :@"b"]) {
            if (![self casaSottoAttacco:58 :@"b"]) {
                if (![self casaSottoAttacco:60 :@"b"]) {
                    if ([[_pieces objectAtIndex:56] isEqualToString:@"br"]) {
                        if ([[_pieces objectAtIndex:57] isEqualToString:EMPTY]) {
                            if ([[_pieces objectAtIndex:58] isEqualToString:EMPTY]) {
                                if ([[_pieces objectAtIndex:59] isEqualToString:EMPTY]) {
                                    return YES;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return NO;
    //return !(reNeroMosso || torreNeraAlaDonnaMossa);
}

- (BOOL) biancoPuoArroccareCortoPerFen {
    if (!(reBiancoMosso || torreBiancaAlaReMossa)) {
        if ([[_pieces objectAtIndex:7] isEqualToString:@"wr"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) biancoPuoArroccareLungoPerFen {
    if (!(reBiancoMosso || torreBiancaAlaDonnaMossa)) {
        if ([[_pieces objectAtIndex:0] isEqualToString:@"wr"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) neroPuoArroccareCortoPerFen {
    if (!(reNeroMosso || torreNeraAlaReMossa)) {
        if ([[_pieces objectAtIndex:63] isEqualToString:@"br"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) neroPuoArroccareLungoPerFen {
    if (!(reNeroMosso || torreNeraAlaDonnaMossa)) {
        if ([[_pieces objectAtIndex:56] isEqualToString:@"br"]) {
            return YES;
        }
    }
    return NO;
}


- (BOOL) laCasaSiTrovaNeiConfiniDellaScacchiera:(NSString *)casa {
    return [setCaseScacchieraNotazioneCorr containsObject:casa];
}

- (void) stampaStackfFen {
    //for (NSUInteger i=0; i<stackFen.count; i++) {
        //NSLog(@"%@", [stackFen objectAtIndex:i]);
    //}
    if ([self biancoPuoArroccareCortoPerFen]) {
        NSLog(@"Il Bianco può arroccare corto per Fen");
    }
    else {
        NSLog(@"Il Bianco non può arroccare corto per Fen");
    }
    if ([self biancoPuoArroccareLungoPerFen]) {
        NSLog(@"Il Bianco può arroccare lungo per Fen");
    }
    else {
        NSLog(@"Il Bianco non può arroccare lungo per Fen");
    }
    if ([self neroPuoArroccareCortoPerFen]) {
        NSLog(@"Il Nero può arroccare corto per Fen");
    }
    else {
        NSLog(@"Il Nero non può arroccare corto per Fen");
    }
    if ([self neroPuoArroccareLungoPerFen]) {
        NSLog(@"Il Nero può arroccare lungo per Fen");
    }
    else {
        NSLog(@"Il Nero non può arroccare lungo per Fen");
    }
    
    
    if ([self biancoPuoArroccareCorto]) {
        NSLog(@"Al momento il Bianco può arroccare corto");
    }
    else {
        NSLog(@"Al momento il Bianco non può arroccare corto");
    }
    if ([self biancoPuoArroccareLungo]) {
        NSLog(@"Al momento il Bianco può arroccare lungo");
    }
    else {
        NSLog(@"Al momento il Bianco non può arroccare lungo");
    }
    if ([self neroPuoArroccareCorto]) {
        NSLog(@"Al momento il Nero può arroccare corto");
    }
    else {
        NSLog(@"Al momento il Nero non può arroccare corto");
    }
    if ([self neroPuoArroccareLungo]) {
        NSLog(@"Al momento il Nero può arroccare lungo");
    }
    else {
        NSLog(@"Al momento il Nero non può arroccare lungo");
    }
}



#pragma mark - Implementazione Metodi per PgnParser

- (void) muoviAvanti:(PGNMove *)pgnMove {
   
    //NSLog(@"ESEGUO MUOVI AVANTI IN BOARD MODEL di %@", pgnMove.fullMove);
    //NSLog(@"VECCHIA SEMIMOSSA = %d", numeroSemiMossa);
    //NSLog(@"NUOVA SEMIMOSSA = %d", numeroSemiMossa);
    
    _whiteHasToMove = !_whiteHasToMove;
    
    if ([pgnMove endGameMarked]) {
        return;
    }
    
    if ([pgnMove.fullMove isEqualToString:@"XXX"]) {
        return;
    }
    
    numeroSemiMossa++;
    
    if ([pgnMove pedoneMossoDiDuePassi]) {
        fenEnPassant = YES;
        if ([pgnMove.color isEqualToString:@"w"]) {
            fenEnPassantSquare = [self getAlgebricValueFromSquareTag:pgnMove.fromSquare + 8];
        }
        else {
            fenEnPassantSquare = [self getAlgebricValueFromSquareTag:pgnMove.fromSquare - 8];
        }
    }
    else {
        fenEnPassant = NO;
        fenEnPassantSquare = nil;
    }
    
    if ([pgnMove mossaDiPedoneOCattura]) {
        numeroSemimosseDaUltimaMossaPedoneOPresa = 0;
    }
    else {
        numeroSemimosseDaUltimaMossaPedoneOPresa++;
    }
    
    
    
    if (pgnMove.isCastle) {
        if (pgnMove.kingSideCastle) {
            if ([pgnMove.color isEqualToString:@"w"]) {
                //NSLog(@"Arrocco Corto Bianco");
                [self replaceContentOfSquare:6 :4];
                [self replaceContentOfSquare:5 :7];
                [self emptySquare:4];
                [self emptySquare:7];
                reBiancoMosso = YES;
                torreBiancaAlaReMossa = YES;
            }
            else {
                //NSLog(@"Arrocco Corto Nero");
                [self replaceContentOfSquare:62 :60];
                [self replaceContentOfSquare:61 :63];
                [self emptySquare:60];
                [self emptySquare:63];
                reNeroMosso = YES;
                torreNeraAlaReMossa = YES;
            }
        }
        else {
            if ([pgnMove.color isEqualToString:@"w"]) {
                //NSLog(@"Arrocco Lungo Bianco");
                [self replaceContentOfSquare:2 :4];
                [self replaceContentOfSquare:3 :0];
                [self emptySquare:4];
                [self emptySquare:0];
                reBiancoMosso = YES;
                torreBiancaAlaDonnaMossa = YES;
            }
            else {
                //NSLog(@"Arrocco Lungo Nero");
                [self replaceContentOfSquare:58 :60];
                [self replaceContentOfSquare:59 :56];
                [self emptySquare:60];
                [self emptySquare:56];
                reNeroMosso = YES;
                torreNeraAlaDonnaMossa = YES;
            }
        }
        //[self printPosition];
        return;
    }
    if (pgnMove.promoted) {
        [self replacePiece:pgnMove.fromSquare :0];
        [self replacePiece:pgnMove.toSquare :[self getNumberPieceFromStringPiece:pgnMove.pezzoPromosso]];
        if ([pgnMove isExtendedMove]) {
            [pgnMove convertExtendedMoveToFullMove:nil];
            [self controllaSeDevoAggiungereScacco:pgnMove];
        }
        
        //[self printPosition];
        return;
    }
    
    
    if ([pgnMove isExtendedMove] && [pgnMove capture]) {
        NSString *pedoneCheCatturaEnPassant = [_pieces objectAtIndex:pgnMove.fromSquare];
        NSString *pedoneDaCatturareEnPassant = [_pieces objectAtIndex:pgnMove.toSquare];
        if ([pedoneCheCatturaEnPassant hasSuffix:@"p"] && [pedoneDaCatturareEnPassant hasPrefix:@"em"]) {
            //NSLog(@"Devo gestire la presa en passant con notazione estesa");
            [pgnMove setEnPassantCapture:YES];
            if (_whiteHasToMove) {
                [pgnMove setEnPassantPieceSquare:pgnMove.toSquare + 8];
                //NSLog(@"********************************   EN PASSANT PIECE SQUARE:%d", pgnMove.enPassantPieceSquare);
            }
            else {
                [pgnMove setEnPassantPieceSquare:pgnMove.toSquare - 8];
                //NSLog(@"********************************   EN PASSANT PIECE SQUARE:%d", pgnMove.enPassantPieceSquare);
            }
        }
    }

    
    
    if (pgnMove.enPassantCapture) {
        //NSLog(@"PRIMA EN PASSANT: %d", pgnMove.enPassantPieceSquare);
        if ([pgnMove isExtendedMove]) {
            [pgnMove convertExtendedMoveToFullMove:nil];
            [self controllaSeDevoAggiungereScacco:pgnMove];
        }
        
        //[self printPosition];
        [self replacePiece:pgnMove.fromSquare :0];
        //NSLog(@"INTERMEDIO ENPASSANMT");
        //[self printPosition];
        if ([pgnMove.color isEqualToString:@"w"]) {
            [self replacePiece:pgnMove.toSquare :-1];
        }
        else {
            [self replacePiece:pgnMove.toSquare :1];
        }
        [self replacePiece:pgnMove.enPassantPieceSquare :0];
        
        
        //NSLog(@"DOPO ENPASSANT");
        //[self printPosition];
        return;
    }
    
    
    if ([pgnMove isExtendedMove]) {
        
        //NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  %@              move:%@        fullmove:%@", pgnMove.description, pgnMove.move, pgnMove.fullMove);
        NSString *pezzo = [_pieces objectAtIndex:pgnMove.fromSquare];
        NSString *prefix = [self controllaSeAltriPezziDelloStessoTipoPossonoRaggiungereUnaCasa2:pezzo :pgnMove.fromSquare :pgnMove.toSquare];
        if (!prefix) {
            [pgnMove convertExtendedMoveToFullMove:prefix];
        }
        else {
            //NSLog(@"PREFIX = %@", prefix);
            [pgnMove convertExtendedMoveToFullMove:prefix];
        }
        [self controllaSeDevoAggiungereScacco:pgnMove];

    }
    
    
    //NSNumber *pezzoMosso = [self getPieceNumberAtSquare:pgnMove.fromSquare];
    [_pieces replaceObjectAtIndex:pgnMove.toSquare withObject:[_pieces objectAtIndex:pgnMove.fromSquare]];
    //[board replaceObjectAtIndex:pgnMove.toSquare withObject:pezzoMosso];
    [self replacePiece:pgnMove.fromSquare :0];
    //[self printPosition];

}


- (void) muoviIndietro:(PGNMove *)pgnMove {
    
    _whiteHasToMove = !_whiteHasToMove;
    numeroSemiMossa--;
    
    //NSLog(@"MUOVI INDIETRO CHIAMATA DA PGNPARSE VALORE NUMEROSEMIMOSSA = %d", numeroSemiMossa);
    
    if (numeroSemiMossa == -1) {
        numeroSemiMossa = 0;
    }
    
    NSString *pezzoMosso = [_pieces objectAtIndex:pgnMove.toSquare];
    NSString *pezzoCatturato = nil;
    
    if (pgnMove.isCastle) {
        if (pgnMove.kingSideCastle) {
            if ([pgnMove.color isEqualToString:@"w"]) {
                //NSLog(@"Ripristino Arrocco corto bianco");
                [self replaceContentOfSquare:4 :6];
                [self replaceContentOfSquare:7 :5];
                [self emptySquare:6];
                [self emptySquare:5];
                reBiancoMosso = NO;
                torreBiancaAlaReMossa = NO;
            }
            else {
                //NSLog(@"Ripristino arrocco corto Nero");
                [self replaceContentOfSquare:60 :62];
                [self replaceContentOfSquare:63 :61];
                [self emptySquare:62];
                [self emptySquare:61];
                reNeroMosso = NO;
                torreNeraAlaReMossa = NO;
            }
        }
        else {
            if ([pgnMove.color isEqualToString:@"w"]) {
                //NSLog(@"Ripristino Arrocco Lungo bianco");
                [self replaceContentOfSquare:4 :2];
                [self replaceContentOfSquare:0 :3];
                [self emptySquare:2];
                [self emptySquare:3];
                reBiancoMosso = NO;
                torreBiancaAlaDonnaMossa = NO;
            }
            else {
                //NSLog(@"Ripristino Arrocco Lungo Nero");
                [self replaceContentOfSquare:60 :58];
                [self replaceContentOfSquare:56 :59];
                [self emptySquare:58];
                [self emptySquare:59];
                reNeroMosso = NO;
                torreNeraAlaDonnaMossa = NO;
            }
        }
        //[self printPosition];
        return;
    }
    if (pgnMove.promoted) {
        if ([pgnMove.color isEqualToString:@"w"]) {
            [self replacePiece:pgnMove.fromSquare :-1];
        }
        else {
            [self replacePiece:pgnMove.fromSquare :1];
        }
        if (pgnMove.capture) {
            [self replacePiece:pgnMove.toSquare :[self getNumberPieceFromStringPiece:pgnMove.captured]];
        }
        else {
            [self replacePiece:pgnMove.toSquare :0];
        }
        //[self printPosition];
        return;
    }
    
    if (pgnMove.enPassantCapture) {
        [self emptySquare:pgnMove.toSquare];
        if ([pgnMove.color isEqualToString:@"w"]) {
            [self replacePiece:pgnMove.fromSquare :-1];
            [self replacePiece:pgnMove.enPassantPieceSquare :1];
        }
        else {
            [self replacePiece:pgnMove.fromSquare :1];
            [self replacePiece:pgnMove.enPassantPieceSquare :-1];
        }
        //[self printPosition];
        return;
    }
    
    if (pgnMove.capture) {
        //NSLog(@"Devo prendere il pezzo catturato");
        pezzoCatturato = pgnMove.captured;
        
    }
    else {
        pezzoCatturato = EMPTY;
    }
    [_pieces replaceObjectAtIndex:pgnMove.toSquare withObject:pezzoCatturato];
    [_pieces replaceObjectAtIndex:pgnMove.fromSquare withObject:pezzoMosso];
    //[self printPosition];

}

- (void) replaceContentOfSquare:(short)squareTo :(short)squareFrom {
    NSString *stringPezzoFrom = [_pieces objectAtIndex:squareFrom];
    [_pieces replaceObjectAtIndex:squareTo withObject:stringPezzoFrom];
}

- (void) emptySquare:(short)square {
    [_pieces replaceObjectAtIndex:square withObject:EMPTY];
}

- (void) replacePiece:(short)squareTo :(short)piece {
    NSString *stringPezzo = [self getStringPieceFromNumberPiece:piece];
    [_pieces replaceObjectAtIndex:squareTo withObject:stringPezzo];
}

- (short) getPieceAtSquare:(short)square {
    NSString *stringPezzo = [_pieces objectAtIndex:square];
    return [self getNumberPieceFromStringPiece:stringPezzo];
}

- (BOOL) squareIsEmpty:(short)square {
    return [[_pieces objectAtIndex:square] isEqualToString:EMPTY];
}

- (BOOL) squareContainsPiece:(short)square :(short)piece {
    
    //NSLog(@"METODO SQUARE CONTAINS PIECE");
    //NSLog(@"SQUARE = %d    PEZZO = %d", square, piece);
    
    NSString *stringPiece = [self getStringPieceFromNumberPiece:piece];
    return [[_pieces objectAtIndex:square] isEqualToString:stringPiece];
}

- (NSNumber *) getPieceNumberAtSquare:(short)square {
    NSString *stringPezzo = [_pieces objectAtIndex:square];
    if ([stringPezzo isEqualToString:EMPTY]) {
        return [NSNumber numberWithShort:0];
    }
    short shortPezzo = [self getNumberPieceFromStringPiece:stringPezzo];
    return [NSNumber numberWithShort:shortPezzo];
}

- (short) getPieceAtSquare:(short)column :(short)row {
    short square = column*8 + row;
    NSString *stringPezzo = [_pieces objectAtIndex:square];
    return [self getNumberPieceFromStringPiece:stringPezzo];
}

- (NSString *) getStringPieceFromNumberPiece:(short)piece {
    switch (piece) {
        case -1:
            return @"wp";
        case -2:
            return @"wn";
        case -3:
            return @"wb";
        case -4:
            return @"wr";
        case -5:
            return @"wq";
        case -6:
            return @"wk";
        case 1:
            return @"bp";
        case 2:
            return @"bn";
        case 3:
            return @"bb";
        case 4:
            return @"br";
        case 5:
            return @"bq";
        case 6:
            return @"bk";
    }
    return @"em";
}

- (short) getNumberPieceFromStringPiece:(NSString *)piece {
    if ([piece isEqualToString:EMPTY]) {
        return 0;
    }
    short colorePezzo = 1;
    if ([piece hasPrefix:@"w"]) {
        colorePezzo = -1;
    }
    else {
        colorePezzo = 1;
    }
    if ([piece hasSuffix:@"k"]) {
        return (colorePezzo * 6);
    }
    else if ([piece hasSuffix:@"q"]) {
        return (colorePezzo * 5);
    }
    else if ([piece hasSuffix:@"r"]) {
        return (colorePezzo * 4);
    }
    else if ([piece hasSuffix:@"b"]) {
        return (colorePezzo * 3);
    }
    else if ([piece hasSuffix:@"n"]) {
        return (colorePezzo * 2);
    }
    return (colorePezzo * 1);
}

- (void) switchColor {
    _whiteHasToMove = !_whiteHasToMove;
    numeroSemiMossa--;
}
            
#pragma mark - Implementazione Metodi per Setup Position

- (void) setPiece:(short)squareTo :(NSString *)piece {
    [_pieces replaceObjectAtIndex:squareTo withObject:piece];
}

- (NSInteger) checkSetupPosition {
    
    if ([[self fenNotation] isEqualToString:FEN_START_POSITION]) {
        _whiteHasToMove = YES;
        return 5;
    }
    
    if ([self reOk:@"wk"] && [self reOk:@"bk"]) {
        if ([self posizioneCorrettaDeiRe]) {
            BOOL reBiancoSottoScacco = [self reSottoScacco:@"wk"];
            BOOL reNeroSottoScacco = [self reSottoScacco:@"bk"];
            if (reBiancoSottoScacco && reNeroSottoScacco) {
                return -2;
            }
            else if (reBiancoSottoScacco && !reNeroSottoScacco) {
                _whiteHasToMove = YES;
                
                NSString *risu = [self controllaScaccoEScaccoMatto:@"POSIZIONE" :100];
                if ([risu hasSuffix:@"#"]) {
                    return 3;
                }
                return 1;
            }
            else if (!reBiancoSottoScacco && reNeroSottoScacco) {
                _whiteHasToMove = NO;
                NSString *risu = [self controllaScaccoEScaccoMatto:@"POSIZIONE" :100];
                if ([risu hasSuffix:@"#"]) {
                    return 4;
                }
                return 2;
            }
            return 0;
        }
    }
    return -1;
}

- (BOOL) reSottoScacco:(NSString *)re {
    NSUInteger posizioneRe = [self trovaPosizioneDelRe:re];
    BOOL scacco;
    if ([re hasPrefix:@"w"]) {
        scacco = [self casaSottoAttacco:(int)posizioneRe :@"w"];
        if (scacco) {
            //NSLog(@"il re bianco è sotto scacco");
            return YES;
        }
    }
    else {
        scacco = [self casaSottoAttacco:(int)posizioneRe :@"b"];
        if (scacco) {
            //NSLog(@"il re nero è sotto scacco");
            return YES;
        }
    }
    return NO;
}

- (BOOL) reOk:(NSString *)re {
    NSUInteger numeroRe = 0;
    for (NSString *pezzo in _pieces) {
        if ([pezzo isEqualToString:re]) {
            numeroRe++;
        }
    }
    if (numeroRe == 1) {
        return YES;
    }
    return NO;
}

- (BOOL) posizioneCorrettaDeiRe {
    NSUInteger posizioneReBianco = [self convertTagValueToSquareValue:(int)[self trovaPosizioneDelRe:@"wk"]];
    NSUInteger posizioneReNero = [self convertTagValueToSquareValue:(int)[self trovaPosizioneDelRe:@"bk"]];

    //NSLog(@"Posizione Re Bianco = %d", posizioneReBianco);
    //NSLog(@"Posizione Re Nero = %d", posizioneReNero);
    
    if ((posizioneReBianco + 1) == posizioneReNero) {
        return NO;
    }
    else if ((posizioneReBianco - 1) == posizioneReNero) {
        return NO;
    }
    else if ((posizioneReBianco + 9) == posizioneReNero) {
        return NO;
    }
    else if ((posizioneReBianco - 9) == posizioneReNero) {
        return NO;
    }
    else if ((posizioneReBianco + 11) == posizioneReNero) {
        return NO;
    }
    else if ((posizioneReBianco - 11) == posizioneReNero) {
        return NO;
    }
    else if ((posizioneReBianco + 10) == posizioneReNero) {
        return NO;
    }
    else if ((posizioneReBianco - 10) == posizioneReNero) {
        return NO;
    }
    return YES;
}

- (NSUInteger) trovaPosizioneDelRe:(NSString *)re {
    for (NSString *pezzo in _pieces) {
        if ([pezzo isEqualToString:re]) {
            return [_pieces indexOfObject:pezzo];
        }
    }
    return 64;
}

- (BOOL) almenoUnArroccoPossibile {
    [self checkArrocchi];
    if ([self biancoPuoArroccareCortoInPosizione]) {
        return YES;
    }
    if ([self biancoPuoArroccareLungoInPosizione]) {
        NSLog(@"Il bianco può arroccare lungo");
        return YES;
    }
    if ([self neroPuoArroccareCortoInPosizione]) {
        NSLog(@"Il nero può arroccare corto");
        return YES;
    }
    if ([self neroPuoArroccareLungoInPosizione]) {
        NSLog(@"Il nero può arroccare lungo");
        return YES;
    }
    return NO;
}

- (void) checkArrocchi {
    
    NSUInteger reBianco = [self trovaPosizioneDelRe:@"wk"];
    if (reBianco != 4) {
        reBiancoMosso = YES;
    }
    else {
        reBiancoMosso = NO;
    }
    NSUInteger reNero = [self trovaPosizioneDelRe:@"bk"];
    if (reNero != 60) {
        reNeroMosso = YES;
    }
    else {
        reNeroMosso = NO;
    }
    
    NSString *rook = [self getPieceAtSquareTag:7];
    if ([rook isEqualToString:@"wr"]) {
        torreBiancaAlaReMossa = NO;
    }
    else {
        torreBiancaAlaReMossa = YES;
    }
    
    rook = [self getPieceAtSquareTag:0];
    if ([rook isEqualToString:@"wr"]) {
        torreBiancaAlaDonnaMossa = NO;
    }
    else {
        torreBiancaAlaDonnaMossa = YES;
    }

    rook = [self getPieceAtSquareTag:63];
    if ([rook isEqualToString:@"br"]) {
        torreNeraAlaReMossa = NO;
    }
    else {
        torreNeraAlaReMossa = YES;
    }
    
    rook = [self getPieceAtSquareTag:56];
    if ([rook isEqualToString:@"br"]) {
        torreNeraAlaDonnaMossa = NO;
    }
    else {
        torreNeraAlaDonnaMossa = YES;
    }
}

- (BOOL) biancoPuoArroccareCortoInPosizione {
    if (!reBiancoMosso && !torreBiancaAlaReMossa) {
        return YES;
    }
    return NO;
}

- (BOOL) biancoPuoArroccareLungoInPosizione {
    if (!reBiancoMosso && !torreBiancaAlaDonnaMossa) {
        return YES;
    }
    return NO;
}

- (BOOL) neroPuoArroccareCortoInPosizione {
    if (!reNeroMosso && !torreNeraAlaReMossa) {
        return YES;
    }
    return NO;
}

- (BOOL) neroPuoArroccareLungoInPosizione {
    if (!reNeroMosso && !torreNeraAlaDonnaMossa) {
        return YES;
    }
    return NO;
}

- (void) setBiancoPuoArroccareCorto:(BOOL)si {
    if (si) {
        reBiancoMosso = !si;
        torreBiancaAlaReMossa = !si;
    }
    else if (!reBiancoMosso) {
        torreBiancaAlaReMossa = !si;
    }
}

- (void) setBiancoPuoArroccareLungo:(BOOL)si {
    if (si) {
        reBiancoMosso = !si;
        torreBiancaAlaDonnaMossa = !si;
    }
    else if (!reBiancoMosso) {
        torreBiancaAlaDonnaMossa = !si;
    }
}

- (void) setNeroPuoArroccareCorto:(BOOL)si {
    if (si) {
        reNeroMosso = !si;
        torreNeraAlaReMossa = !si;
    }
    else if (!reNeroMosso) {
        torreNeraAlaReMossa = !si;
    }
}

- (void) setNeroPuoArroccareLungo:(BOOL)si {
    if (si) {
        reNeroMosso = !si;
        torreNeraAlaDonnaMossa = !si;
    }
    else if (!reNeroMosso) {
        torreNeraAlaDonnaMossa = !si;
    }
}

- (NSArray *) getArrocchiPermessiInPosizione {
    NSMutableArray *castleAllowed = [[NSMutableArray alloc] init];
    if ([self biancoPuoArroccareCortoInPosizione]) {
        [castleAllowed addObject:NSLocalizedString(@"SETUP_POSITION_WHITE_OO", nil)];
    }
    if ([self biancoPuoArroccareLungoInPosizione]) {
        [castleAllowed addObject:NSLocalizedString(@"SETUP_POSITION_WHITE_OOO", nil)];
    }
    if ([self neroPuoArroccareCortoInPosizione]) {
        [castleAllowed addObject:NSLocalizedString(@"SETUP_POSITION_BLACK_OO", nil)];
    }
    if ([self neroPuoArroccareLungoInPosizione]) {
        [castleAllowed addObject:NSLocalizedString(@"SETUP_POSITION_BLACK_OOO", nil)];
    }
    return castleAllowed;
}

- (BOOL) esisteAlmenoUnaPresaEnPassant {
    
    
    return [[self trovaCaseEnPassant] count]>0;
    
    
    
    
    NSUInteger numPedoniSpintiDiDuePassi = 0;
    NSMutableArray *caseEnPassant = [[NSMutableArray alloc] init];
    if (_whiteHasToMove) {
        for (int i=32; i<40; i++) {
            NSString *p = [self getPieceAtSquareTag:i];
            if ([p isEqualToString:@"bp"] && [[self getPieceAtSquareTag:i+8] isEqualToString:@"em"] && [[self getPieceAtSquareTag:i+8+8] isEqualToString:@"em"]) {
                numPedoniSpintiDiDuePassi++;
                [caseEnPassant addObject:[NSNumber numberWithInteger:i]];
            }
        }
        //for (NSNumber *n in caseEnPassant) {
            //int cep = [n intValue] + 8;
            //NSLog(@"CASA EN PASSANT = %d",cep);
        //}
        if (numPedoniSpintiDiDuePassi > 0) {
            return YES;
        }
    }
    else {
        for (int i=24; i<32; i++) {
            NSString *p = [self getPieceAtSquareTag:i];
            if ([p isEqualToString:@"wp"] && [[self getPieceAtSquareTag:i-8] isEqualToString:@"em"] && [[self getPieceAtSquareTag:i-8-8] isEqualToString:@"em"]) {
                numPedoniSpintiDiDuePassi++;
                [caseEnPassant addObject:[NSNumber numberWithInteger:i]];
            }
        }
        //for (NSNumber *n in caseEnPassant) {
            //int cep = [n intValue] - 8;
            //NSLog(@"CASA EN PASSANT = %d",cep);
        //}
        if (numPedoniSpintiDiDuePassi > 0) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *) trovaCaseEnPassant {
    NSMutableArray *caseEnPassant = [[NSMutableArray alloc] init];
    if (_whiteHasToMove) {
        for (NSUInteger i=32; i<40; i++) {
            NSString *p = [self getPieceAtSquareTag:(int)i];
            if ([p isEqualToString:@"bp"] && [[self getPieceAtSquareTag:(int)(i+8)] isEqualToString:@"em"] && [[self getPieceAtSquareTag:(int)(i+8+8)] isEqualToString:@"em"]) {
                switch (i) {
                    case 33: case 34: case 35: case 36: case 37: case 38:
                        if ([[self getPieceAtSquareTag:(int)(i-1)] isEqualToString:@"wp"] || [[self getPieceAtSquareTag:(int)(i+1)] isEqualToString:@"wp"]) {
                            [caseEnPassant addObject:[NSNumber numberWithInteger:i + 8]];
                        }
                        break;
                    case 32:
                        if ([[self getPieceAtSquareTag:(int)(i+1)] isEqualToString:@"wp"]) {
                            [caseEnPassant addObject:[NSNumber numberWithInteger:i + 8]];
                        }
                        break;
                    case 39:
                        if ([[self getPieceAtSquareTag:(int)(i-1)] isEqualToString:@"wp"]) {
                            [caseEnPassant addObject:[NSNumber numberWithInteger:i + 8]];
                        }
                        break;
                    default:
                        break;
                }
            }
        }
        return caseEnPassant;
    }
    else {
        for (NSUInteger i=24; i<32; i++) {
            NSString *p = [self getPieceAtSquareTag:(int)i];
            if ([p isEqualToString:@"wp"] && [[self getPieceAtSquareTag:(int)(i-8)] isEqualToString:@"em"] && [[self getPieceAtSquareTag:(int)(i-8-8)] isEqualToString:@"em"]) {
                
                switch (i) {
                    case 25: case 26: case 27: case 28: case 29: case 30:
                        if ([[self getPieceAtSquareTag:(int)(i-1)] isEqualToString:@"bp"] || [[self getPieceAtSquareTag:(int)(i+1)] isEqualToString:@"bp"]) {
                            [caseEnPassant addObject:[NSNumber numberWithInteger:i - 8]];
                        }
                        break;
                    case 24:
                        if ([[self getPieceAtSquareTag:(int)(i+1)] isEqualToString:@"bp"]) {
                            [caseEnPassant addObject:[NSNumber numberWithInteger:i - 8]];
                        }
                        break;
                    case 31:
                        if ([[self getPieceAtSquareTag:(int)(i-1)] isEqualToString:@"bp"]) {
                            [caseEnPassant addObject:[NSNumber numberWithInteger:i - 8]];
                        }
                        break;
                    default:
                        break;
                }
            }
        }
        return caseEnPassant;
    }
}

- (void) setPresaEnPassantPossibile:(BOOL)presaPossibile :(NSUInteger)casaEnPassant {
    fenEnPassant = presaPossibile;
    if (fenEnPassant) {
        fenEnPassantSquare = [self getAlgebricValueFromSquareTag:(int)casaEnPassant];
        NSLog(@"Presa en passant possibile nella casa %@", fenEnPassantSquare);
    }
    else {
        fenEnPassantSquare = nil;
        NSLog(@"Nessuna presa en passant possibile");
    }
}

- (NSString *) getSelectedSquareEnPassant {
    return fenEnPassantSquare;
}

- (NSUInteger) getSelectedEnPassantSquare {
    if (fenEnPassantSquare) {
        return [self getSquareTagFromAlgebricValue:fenEnPassantSquare];
    }
    return 0;
}

- (void) resetEnPassantInPosition {
    fenEnPassant = NO;
    fenEnPassantSquare = nil;
}


- (void) stampaDatiMetodoChiamante {
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    //NSLog(@"Stack = %@", [array objectAtIndex:0]);
    //NSLog(@"Framework = %@", [array objectAtIndex:1]);
    //NSLog(@"Memory address = %@", [array objectAtIndex:2]);
    //NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    //NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    //NSLog(@"Line caller = %@", [array objectAtIndex:5]);
}

#pragma mark - Metodi per poter muovere un pezzo partendo dalla selezione della casa di arrivo

- (NSMutableArray *) getListaPezziCheControllano:(int) square :(NSString *)fromColor :(int)casaInclusa {
    NSMutableArray *pezziCheControllano = [[NSMutableArray alloc] init];
    NSMutableArray *casePezziCheControllano = [[NSMutableArray alloc] init];
    int squareNumber = [self convertTagValueToSquareValue:square];
    if (casaInclusa != -1) {
        //casaInclusa = [self convertTagValueToSquareValue:casaInclusa];
        casaInclusa = -1;
    }
    unsigned int nuovaCasa = 0;
    NSString *pezzoInNuovaCasa;
    BOOL continua = YES;
    for (int direction = 1; direction<=18; direction++) {
        nuovaCasa = squareNumber;
        switch (direction) {
            case 1:
                do {
                    nuovaCasa = nuovaCasa + 1;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa: %@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY]  || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (nuovaCasa - squareNumber == 1)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //NSLog(@"Casa = %d", nuovaCasa);
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //[caseInveceDeiPezzi addObject:[NSNumber numberWithShort:nuovaCasa]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"q"] || [pezzoInNuovaCasa hasSuffix:@"r"]) {
                                //NSLog(@"Ho trovato una Torre o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //NSLog(@"Casa = %d", nuovaCasa);
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 2:
                do {
                    nuovaCasa = nuovaCasa - 1;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                        //NSLog(@"Casa Inclusa = %d", casaInclusa);
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (squareNumber - nuovaCasa == 1)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //NSLog(@"Casa = %d", nuovaCasa);
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"q"] || [pezzoInNuovaCasa hasSuffix:@"r"]) {
                                //NSLog(@"Ho trovato una Torre o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                //NSLog(@"Casa = %d", nuovaCasa);
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 3:
                do {
                    nuovaCasa = nuovaCasa + 10;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (nuovaCasa - squareNumber == 10)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"q"] || [pezzoInNuovaCasa hasSuffix:@"r"]) {
                                //NSLog(@"Ho trovato una Torre o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 4:
                do {
                    nuovaCasa = nuovaCasa - 10;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (squareNumber - nuovaCasa == 10)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"q"] || [pezzoInNuovaCasa hasSuffix:@"r"]) {
                                //NSLog(@"Ho trovato una Torre o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 5:
                do {
                    nuovaCasa = nuovaCasa + 11;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (nuovaCasa - squareNumber == 11)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"p"] && (nuovaCasa - squareNumber == 11) && [fromColor isEqualToString:@"w"]) {
                                //NSLog(@"Ho trovato un Pedone che controlla la casa");
                                
                                NSString *pezzoDestinazione = [self trovaContenutoConNumeroCasa:squareNumber];
                                if (![pezzoDestinazione isEqualToString:EMPTY]) {
                                    [pezziCheControllano addObject:pezzoInNuovaCasa];
                                    [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                }
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"b"] || [pezzoInNuovaCasa hasSuffix:@"q"]) {
                                //NSLog(@"Ho trovato un Alfiere o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 6:
                do {
                    nuovaCasa = nuovaCasa - 11;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (squareNumber - nuovaCasa == 11)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"p"] && (squareNumber - nuovaCasa == 11) && [fromColor isEqualToString:@"b"]) {
                                //NSLog(@"Ho trovato un Pedone che controlla la casa");
                                NSString *pezzoDestinazione = [self trovaContenutoConNumeroCasa:squareNumber];
                                if (![pezzoDestinazione isEqualToString:EMPTY]) {
                                    [pezziCheControllano addObject:pezzoInNuovaCasa];
                                    [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                }
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"b"] || [pezzoInNuovaCasa hasSuffix:@"q"]) {
                                //NSLog(@"Ho trovato un Alfiere o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 7:
                do {
                    nuovaCasa = nuovaCasa + 9;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (nuovaCasa - squareNumber == 9)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"p"] && (nuovaCasa - squareNumber == 9) && [fromColor isEqualToString:@"b"]) {
                                //NSLog(@"Ho trovato un Pedone che controlla la casa");
                                NSString *pezzoDestinazione = [self trovaContenutoConNumeroCasa:squareNumber];
                                if (![pezzoDestinazione isEqualToString:EMPTY]) {
                                    [pezziCheControllano addObject:pezzoInNuovaCasa];
                                    [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                }
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"b"] || [pezzoInNuovaCasa hasSuffix:@"q"]) {
                                //NSLog(@"Ho trovato un Alfiere o una Donna che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 8:
                do {
                    nuovaCasa = nuovaCasa - 9;
                    //NSLog(@"Analizzo casa %d", nuovaCasa);
                    if (![self esisteCasa:nuovaCasa]) {
                        //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                        break;
                    }
                    pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                    //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                    if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                        continua = YES;
                        //NSLog(@"Non mi fermo perchè la casa è libera");
                    }
                    else {
                        if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                            continua = NO;
                            //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                        }
                        else {
                            //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                            if ([pezzoInNuovaCasa hasSuffix:@"k"] && (squareNumber - nuovaCasa == 9)) {
                                //NSLog(@"Ho trovato un Re che controlla la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"p"] && (squareNumber - nuovaCasa == 9) && [fromColor isEqualToString:@"w"]) {
                                //NSLog(@"Ho trovato un Pedone che controlla la casa");
                                NSString *pezzoDestinazione = [self trovaContenutoConNumeroCasa:squareNumber];
                                if (![pezzoDestinazione isEqualToString:EMPTY]) {
                                    [pezziCheControllano addObject:pezzoInNuovaCasa];
                                    [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                }
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            if ([pezzoInNuovaCasa hasSuffix:@"b"] || [pezzoInNuovaCasa hasSuffix:@"q"]) {
                                //NSLog(@"Ho trovato un Alfiere o una Donna  che controllano la casa");
                                [pezziCheControllano addObject:pezzoInNuovaCasa];
                                [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                                //NSLog(@"Casa = %d", nuovaCasa);
                            }
                            continua = NO;
                        }
                    }
                } while (continua);
                break;
            case 9: {
                nuovaCasa = nuovaCasa + 12;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                            //NSLog(@"Casa = %d", nuovaCasa);
                        }
                    }
                }
            }
                break;
            case 10: {
                nuovaCasa = nuovaCasa - 12;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                            //NSLog(@"Casa = %d", nuovaCasa);
                        }
                    }
                }
            }
                break;
            case 11:
                nuovaCasa = nuovaCasa + 8;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                            //NSLog(@"Casa = %d", nuovaCasa);
                        }
                    }
                }
                break;
            case 12:
                nuovaCasa = nuovaCasa - 8;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                            //NSLog(@"Casa = %d", nuovaCasa);
                        }
                    }
                }
                break;
            case 13:
                nuovaCasa = nuovaCasa + 21;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                            //NSLog(@"Casa = %d", nuovaCasa);
                        }
                    }
                }
                break;
            case 14:
                nuovaCasa = nuovaCasa - 21;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                            //NSLog(@"Casa = %d", nuovaCasa);
                        }
                    }
                }
                break;
            case 15:
                nuovaCasa = nuovaCasa + 19;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                            //NSLog(@"Casa = %d", nuovaCasa);
                        }
                    }
                }
                break;
            case 16:
                nuovaCasa = nuovaCasa - 19;
                //NSLog(@"Analizzo casa %d", nuovaCasa);
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Pezzo in Nuova casa :%@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY] || nuovaCasa == casaInclusa) {
                    //NSLog(@"Mi fermo perchè non ho trovato un cavallo");
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasPrefix:fromColor]) {
                        //NSLog(@"Mi fermo perchè la casa è occupata da un pezzo del mio colore");
                    }
                    else {
                        //NSLog(@"La casa è occupata dal pezzo %@ e devo valutare cosa fare, comunque esco dal ciclo", pezzoInNuovaCasa);
                        if ([pezzoInNuovaCasa hasSuffix:@"n"]) {
                            //NSLog(@"Ho trovato un cavallo che controlla la casa");
                            [pezziCheControllano addObject:pezzoInNuovaCasa];
                            [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                            //NSLog(@"Casa = %d", nuovaCasa);
                        }
                    }
                }
                break;
            case 17:
                
                if ((_whiteHasToMove && [fromColor isEqualToString:@"w"]) || (!_whiteHasToMove && [fromColor isEqualToString:@"b"])) {
                    break;
                }
                
                if (![[self trovaContenutoConNumeroCasa:squareNumber] isEqualToString:EMPTY]) {
                    NSLog(@"La casa %d non è vuota quindi la mossa di pedone è impossibile", squareNumber);
                    break;
                }
                
                
                if (_whiteHasToMove) {
                    nuovaCasa = nuovaCasa - 1;
                }
                else {
                    nuovaCasa = nuovaCasa + 1;
                }
                if (![self esisteCasa:nuovaCasa]) {
                    //NSLog(@"La casa %d non è compatibile", nuovaCasa);
                    break;
                }
                
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                //NSLog(@"Case 17: PezzoInNuovaCasa = %@", pezzoInNuovaCasa);
                
                
                if ([[self trovaContenutoConNumeroCasa:squareNumber] hasSuffix:@"p"]) {
                    break;
                }
                
                
                
                if ([pezzoInNuovaCasa isEqualToString:EMPTY]) {
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasSuffix:@"p"]) {
                        //NSLog(@"Ho trovato un cavallo che controlla la casa");
                        [pezziCheControllano addObject:pezzoInNuovaCasa];
                        [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                        //NSLog(@"Case 17:  NuovaCasa = %d", nuovaCasa);
                    }
                }
                
                break;
            case 18:
                
                if ((_whiteHasToMove && [fromColor isEqualToString:@"w"]) || (!_whiteHasToMove && [fromColor isEqualToString:@"b"])) {
                    break;
                }
                
                NSString *casaArrivo = [self trovaContenutoConNumeroCasa:squareNumber];
                if (![casaArrivo isEqualToString:EMPTY]) {
                    NSLog(@"La casa %d non è vuota quindi la mossa di pedone è impossibile", squareNumber);
                    break;
                }
                
                
                if (_whiteHasToMove) {
                    nuovaCasa = nuovaCasa - 2;
                    if (nuovaCasa%10 != 2) {
                        break;
                    }
                }
                else {
                    nuovaCasa = nuovaCasa + 2;
                    if (nuovaCasa%10 != 7) {
                        break;
                    }
                }
                
                if (_whiteHasToMove) {
                    int casaIntermedia = nuovaCasa + 1;
                    NSString *pezzoInCasaInteremedia = [self trovaContenutoConNumeroCasa:casaIntermedia];
                    if (![pezzoInCasaInteremedia isEqualToString:EMPTY]) {
                        break;
                    }
                }
                else {
                    int casaIntermedia = nuovaCasa - 1;
                    NSString *pezzoInCasaInteremedia = [self trovaContenutoConNumeroCasa:casaIntermedia];
                    if (![pezzoInCasaInteremedia isEqualToString:EMPTY]) {
                        break;
                    }
                }
                
                if ([[self trovaContenutoConNumeroCasa:squareNumber] hasSuffix:@"p"]) {
                    break;
                }
                
                pezzoInNuovaCasa = [self trovaContenutoConNumeroCasa:nuovaCasa];
                NSLog(@"Case 17: PezzoInNuovaCasa = %@", pezzoInNuovaCasa);
                if ([pezzoInNuovaCasa isEqualToString:EMPTY]) {
                    break;
                }
                else {
                    if ([pezzoInNuovaCasa hasSuffix:@"p"]) {
                        //NSLog(@"Ho trovato un cavallo che controlla la casa");
                        [pezziCheControllano addObject:pezzoInNuovaCasa];
                        [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
                        NSLog(@"Case 18: NuovaCasa = %d", nuovaCasa);
                    }
                }
                break;
                
        }
    }
    
    if (_whiteHasToMove) {
        if (([self biancoPuoArroccareCorto] && squareNumber == 71) || ([self biancoPuoArroccareLungo] && squareNumber == 31)) {
            nuovaCasa = 51;
            [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
        }
    }
    else {
        if (([self neroPuoArroccareCorto] && squareNumber == 78) || ([self neroPuoArroccareLungo] && squareNumber == 38)) {
            nuovaCasa = 58;
            [casePezziCheControllano addObject:[NSNumber numberWithInt:[self getTagValueFromSquareValue:nuovaCasa]]];
        }
    }
    
    
    //return pezziCheControllano;
    return casePezziCheControllano;
}

- (NSString *) fenNotationNalimov {
    NSString *fenPosition = [self fenNotation];
    NSArray *fenArray = [fenPosition componentsSeparatedByString:@" "];
    return [fenArray objectAtIndex:0];
}

- (NSString *) getPieceSymbolAtSquareTag:(int)squareTag {
    NSNumber *pn = [self getPieceNumberAtSquare:squareTag];
    switch ([pn intValue]) {
        case 0:
            return @"";
            break;
        case 1:
        case -1:
            return @"";
        case 2:
        case -2:
            return @"N";
        case 3:
        case -3:
            return @"B";
        case 4:
        case -4:
            return @"R";
        case 5:
        case -5:
            return @"Q";
        case 6:
        case -6:
            return @"K";
        default:
            break;
    }
    return [pn stringValue];
}

- (void) setupForNalimov {
    numeroSemiMossa = 0;
    [self setNumberFirstMoveInSetupPosition:1];
    [self setBiancoPuoArroccareCorto:NO];
    [self setBiancoPuoArroccareLungo:NO];
    [self setNeroPuoArroccareCorto:NO];
    [self setNeroPuoArroccareLungo:NO];
}

- (int) getNumberPiecesInBoard {
    int numberPieces = 0;
    for (int i=0; i<64; i++) {
        if ([_pieces objectAtIndex:i] != EMPTY) {
            numberPieces++;
        }
    }
    return numberPieces;
}

- (int) getNumberWhitePiecesInBoard {
    int numberWhitePieces = 0;
    for (int i=0; i<64; i++) {
        NSString *pz = [_pieces objectAtIndex:i];
        if ((pz != EMPTY) && ([pz hasPrefix:@"w"])) {
            numberWhitePieces++;
        }
    }
    return numberWhitePieces;
}

- (int) getNumberBlackPiecesInBoard {
    int numberBlackPieces = 0;
    for (int i=0; i<64; i++) {
        NSString *pz = [_pieces objectAtIndex:i];
        if ((pz != EMPTY) && ([pz hasPrefix:@"b"])) {
            numberBlackPieces++;
        }
    }
    return numberBlackPieces;
}

- (BOOL) isPositionForNalimovTablebase {
    
    int reBianco = [self getNumberOf:@"k" ofColor:@"w"];
    int reNero = [self getNumberOf:@"k" ofColor:@"b"];
    if (reBianco == 0 || reNero == 0) {
        return NO;
    }
    
    int numeroPezziTotali = [self getNumberPiecesInBoard];
    if (numeroPezziTotali > 6 || numeroPezziTotali<2) {
        return NO;
    }
    int numeroPezziBianchi = [self getNumberWhitePiecesInBoard];
    int numeroPezziNeri = [self getNumberBlackPiecesInBoard];
    if (numeroPezziBianchi == 1 && numeroPezziNeri == 5) {
        return NO;
    }
    if (numeroPezziNeri == 1 && numeroPezziBianchi == 5) {
        return NO;
    }
    return YES;
}

- (int) getNumberOf:(NSString *)piece ofColor:(NSString *)color {
    int numPieces = 0;
    for (int i=0; i<64; i++) {
        NSString *pz = [_pieces objectAtIndex:i];
        if ((pz != EMPTY) && ([pz hasPrefix:color]) && [pz hasSuffix:piece]) {
            numPieces++;
        }
    }
    return numPieces;
}

- (int) isPositionCorrectForNalimovTablebase {
    if ([self isPositionForNalimovTablebase]) {
        return 0;
    }
    int wk = [self getNumberOf:@"k" ofColor:@"w"];
    int bk = [self getNumberOf:@"k" ofColor:@"b"];
    if (wk >= 1 && bk == 0) { //Manca il Re Nero
        return -1;
    }
    else if (wk == 0 && bk >= 1) {  //Manca il Re Bianco
        return -2;
    }
    else if (wk == 0 && bk == 0) {  //Mancano i Re
        return -3;
    }
    else if (wk >= 1 && bk >= 1) { //Troppi Re
        return -4;
    }
    return 0;
}


@end
