//
//  GameWebView.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 27/11/12.
//  Copyright (c) 2012 Giordano Vicoli. All rights reserved.
//

#import "GameWebView.h"
#import "SettingManager.h"

@interface GameWebView() {

    NSString *testa;
    NSString *coda;
    NSString *contenuto;
    int indiceMossaRossa;
    
    NSString *mossaRossa;
    //NSString *mossaSfondoRosso;
    
    NSString *mossaLinkApri;
    NSString *mossaLinkChiudi;
    NSString *mossaLinkChiudiAngolare;
    NSString *mossaLinkChiudiSpan;
    
    //NSString *plyCountSpanApri;
    //NSString *plyCountSpanChiudi;
    
    
    unsigned int contatoreMosse;
    unsigned int numeroMossa;
    
    //NSUInteger plyCount;
    
    
    NSMutableString *mosseWeb;
    
    
    
    NSString *patternMossa;
    NSRegularExpression *regexPatternMossa;
    
    NSArray *_pgnMovesArray;
    NSMutableArray *webMovesArray;
    short mossaEvidenziata;
    
    //NSUInteger moveNotation;
    NSUInteger numParentesiAperte;
    
    
    NSMutableString *testaNew;
    NSMutableString *body1;
    NSMutableString *body2;
    NSMutableString *bodyEnd;
    
    
    //BOOL variante;
    
    
    PGNMove *_rootMove;
    
    
    NSMutableString *openingString;
    NSString *testaOpeningString;
    NSString *codaOpeningString;
    
    NSMutableString *bookMovesString;
    NSString *testBookMoves;
    NSString *codaBookMoves;
    
    NSString *testaBookMovesArray;
    NSString *codaBookMovesArray;
    
    SettingManager *settingManager;
}

@end

@implementation GameWebView

//@synthesize movesArray = _movesArray;
//@synthesize gameToViewArray = _gameToViewArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setOpaque:NO];
        //self.backgroundColor = UIColorFromRGB(0xffffff);
        self.backgroundColor = [UIColor colorWithRed:0.000 green:0.557 blue:0.165 alpha:1.000];
        [self awakeFromNib];
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

- (void) awakeFromNib {
    
    
    //NSLog(@"Sto eseguendo AwakeFromNib in GamewebView");
    
    //<style type='text/css'>.variante{color: #0043b4; font-weight: normal}</style>
    
    if (IS_PAD) {
        //testa = @"<html><head><style type='text/css'>.ultima{border-radius:4px; background:black; color:white}</style><style type='text/css'>a{text-decoration: none}</style><style type='text/css'>a{color:inherit}</style></head><body bgcolor='#ffffa6'><font size='3' face='Helvetica-Bold'>";
        
        testa = @"<html><head><meta http-equiv='Content-type' content='text/html; charset=UTF-8'/><style type='text/css'>.ultima{border-radius:4px; background:inherit; color:red}</style><style type='text/css'>a{text-decoration: none}</style><style type='text/css'>.variante{color: #0043b4; font-weight: normal}</style><style type='text/css'>a{color:inherit}</style><style type='text/css'>a{white-space:nowrap}</style></head><body bgcolor='#ffffa6'><font size='3' face='Helvetica-Bold' text-align='bottom'>";
        
    }
    else {
        //testa = @"<html><head><style type='text/css'>.ultima{border-radius:4px; background:black; color:white}</style><style type='text/css'>a{text-decoration: none}</style><style type='text/css'>a{color:inherit}</style></head><body bgcolor='#ffffa6'><font size='1' face='Helvetica-Bold'>";
        //testa = @"<html><head><style type='text/css'>.ultima{border-radius:4px; background:inherit; color:red}</style><style type='text/css'>a{text-decoration: none}</style><style type='text/css'>a{color:inherit}</style></head><body bgcolor='#ffffa6'><font size='2' face='Helvetica-Bold'>";
        testa = @"<html><head><meta http-equiv='Content-type' content='text/html; charset=UTF-8'/><style type='text/css'>.ultima{border-radius:4px; background:inherit; color:red}</style><style type='text/css'>a{text-decoration: none}</style><style type='text/css'>a{color:inherit}</style><style type='text/css'>a{white-space:nowrap}</style></head><body bgcolor='#ffffa6'><font size='2' face='Helvetica-Bold' text-align='bottom'>";
    }
    
    coda = @"</body></html>";
    [self loadHTMLString:[testa stringByAppendingString:coda] baseURL:nil];
    mossaRossa = @"<span class='ultima'  ID='mossaevidenziata' >";
    //mossaSfondoRosso = @"<span style='background-color:red'>";
    
    mossaLinkApri = @"<a class='mossalink' href=\"";
    mossaLinkChiudi = @"</a>";
    mossaLinkChiudiAngolare = @"\">";
    mossaLinkChiudiSpan = @"</span>";
    
    //plyCountSpanApri = @"<span class='plycount'>";
    //plyCountSpanChiudi = @"</span>";
    
    
    
    
    patternMossa = @"((?:[PNBRQK]?[a-h]?[1-8]?x?[a-h][1-8](?:=[PNBRQK])?|O(-?O){1,2})[\\+#]?(\\s*[!\?]+)?)";
    NSError *error = NULL;
    regexPatternMossa = [[NSRegularExpression alloc] initWithPattern:patternMossa options:0 error:&error];
    mossaEvidenziata = -1;
    
    settingManager = [SettingManager sharedSettingManager];
    
    //moveNotation = [[[NSUserDefaults standardUserDefaults] stringForKey:@"notation"] integerValue];
    
    
    
    testaNew = [[NSMutableString alloc] init];
    if (IS_PAD) {
        [testaNew appendString:@"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN''XHTML1-s.dtd'>"];
        [testaNew appendString:@"<html xmlns:v='urn:schemas-microsoft-com:vml'xmlns='http://www.w3.org/1999/xhtml'>"];
        [testaNew appendString:@"<head>"];
        [testaNew appendString:@"<meta name='viewport' content='initial-scale=1.0, user-scalable=no'/>"];
        [testaNew appendString:@"<meta http-equiv='Content-Type'content='text/html; charset=UTF-8' />"];
        [testaNew appendString:@"<style type='text/css'>html, body, ul { margin: 0; padding: 0;} ul { display:inline;} .result, li { display: inline; font-weight: bold;} a { color:inherit; text-decoration: none; font-weight: bold; white-space:nowrap} .comment { color: #0043b4; font-weight: normal;}"];
        [testaNew appendString:@"li a, li span {line-height: 180%;}"];
        [testaNew appendString:@"body {font-family: sans-serif; padding: 5px;} ul ul {color: #444;} ul ul li {font-weight: normal;}"];
        [testaNew appendString:@"ul ul .variationStart, ul ul .variationEnd { display: none; } .selected {border-radius: 4px;background: inherit;color: red;} .variante {background:inherit; color:inherit; font-weight:normal;} .selectedVariante {border-radius: 4px;background: inherit;color: red; font-weight:normal;}  .commento {border-radius: 4px;background: inherit;color:blue;font-weight:normal;}  </style>"];
        [testaNew appendString:@"</head>"];
    }
    else {
        [testaNew appendString:@"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN''XHTML1-s.dtd'>"];
        [testaNew appendString:@"<html xmlns:v='urn:schemas-microsoft-com:vml'xmlns='http://www.w3.org/1999/xhtml'>"];
        [testaNew appendString:@"<head>"];
        [testaNew appendString:@"<meta name='viewport' content='initial-scale=1.0, user-scalable=no'/>"];
        [testaNew appendString:@"<meta http-equiv='Content-Type'content='text/html; charset=UTF-8' />"];
        [testaNew appendString:@"<style type='text/css'>html, body, ul { margin: 0; padding: 0; } ul { display: inline; } .result, li { display: inline; font-weight: bold; font-size:small;} a { color:inherit; text-decoration: none; font-weight: bold; font-size:small; white-space:nowrap} .comment { color: #0043b4; font-weight: normal; font-size:small;}"];
        [testaNew appendString:@"li a, li span {line-height:10px;}"];
        [testaNew appendString:@"body {font-family: sans-serif; padding: 5px;} ul ul {color: #444;} ul ul li {font-weight: normal; font-size:small;}"];
        [testaNew appendString:@"ul ul .variationStart, ul ul .variationEnd { display: none; } .selected {border-radius: 4px;background: inherit;color: red;} .variante {background:inherit; color:inherit; font-weight:normal; font-size:small;} .selectedVariante {border-radius: 4px;background: inherit;color: red; font-weight:normal; font-size:small;} .commento {border-radius: 4px;background: inherit;color:blue;font-weight:normal;font-size:small;}  </style>"];
        [testaNew appendString:@"</head>"];
    }

    
    body1 = [[NSMutableString alloc] init];
    [body1 appendString:@"<body bgcolor='#ffffa6'>"];
    //[body1 appendString:@"<body bgcolor='#CAE1FF'>"];
    
    //openingString = [[NSMutableString alloc] init];
    //[openingString appendString:@"<a href=\"-1\"><font size=\"2\" color=\"blue\" face=\"arial\">"];
    //[openingString appendString:@"BOO Pawn Opening"];
    //[openingString appendString:@"</font></a>"];
    
    if (IS_PAD) {
        testaOpeningString = @"<a href=\"-1\"><font size=\"2\" color=\"blue\" face=\"arial\">";
        codaOpeningString = @"</font></a><hr>";
    }
    else {
        testaOpeningString = @"<a href=\"-1\"><font size=\"1\" color=\"blue\" face=\"arial\">";
        codaOpeningString = @"</font></a><hr>";
    }
    
    if (IS_PAD) {
        testBookMoves = @"<a href=\"-2\"><font size=\"2\" color=\"blue\" face=\"arial\">";
        codaBookMoves = @"</font></a><hr>";
    }
    else {
        testBookMoves = @"<a href=\"-2\"><font size=\"1\" color=\"blue\" face=\"arial\">";
        codaBookMoves = @"</font></a><hr>";
        //testBookMoves = nil;
        //codaBookMoves = nil;
    }
    
    if (IS_PAD) {
        testaBookMovesArray = @"<a href=\"*\"><font size=\"2\" color=\"blue\" face=\"arial\">";
        codaBookMovesArray = @"</font></a>";
    }
    else {
        testaBookMovesArray = @"<a href=\"*\"><font size=\"1\" color=\"blue\" face=\"arial\">";
        codaBookMovesArray = @"</font></a>";
        //testaBookMovesArray = nil;
        //codaBookMovesArray = nil;
    }

    
    //[body1 appendString:testaOpeningString];
    //[body1 appendString:@"Apertura"];
    //[body1 appendString:codaOpeningString];
    
    
    body2 = [[NSMutableString alloc] init];
    
    [body2 appendString:@"<div id='game'>"];
    [body2 appendString:@"<ul>"];
    
    bodyEnd = [[NSMutableString alloc] init];
    [bodyEnd appendString:@"</ul>"];
    
    
    [self loadHTMLString:[[testaNew stringByAppendingString:body1] stringByAppendingString:body2] baseURL:nil];
    
    
    //variante = NO;
}

- (void) setRootMove:(PGNMove *)rootMove {
    _rootMove = rootMove;
    return;
    
    
    
    [rootMove resetWebArray];
    [rootMove visitaAlberoAnticipato2];
    NSArray *gameArray = [rootMove getGameArrayDopoAlberoAnticipato2];
    [self setPgnMovesArray:gameArray];
}


- (void) setPgnMovesArray:(NSArray *)pgnMovesArray {
    numParentesiAperte = 0;
    mossaEvidenziata = -1;
    _pgnMovesArray = pgnMovesArray;
    webMovesArray = [[NSMutableArray alloc] init];
    NSUInteger numMossa = 0;
    NSMutableString *mossaPerWebView;
    
    
    if (_rootMove) {
        //NSLog(@"Sto analizzando root Move da WebView prima di analizzare il resto delle mosse!");
        if (_rootMove.textAfter) {
            //NSLog(@"ESISTE UN COMMENTO INIZIALE DELLA PARTITA = %@", _rootMove.textAfter);
            NSMutableString *testoPrimaDellaPartita = [[NSMutableString alloc] init];
            [testoPrimaDellaPartita appendString:@"<span class='commento'>"];
            [testoPrimaDellaPartita appendString:_rootMove.textAfter];
            [testoPrimaDellaPartita appendString:@"</span>"];
            [webMovesArray addObject:testoPrimaDellaPartita];
        }
    }
    
    for (NSObject *obj in _pgnMovesArray) {
        if ([obj isKindOfClass:[PGNMove class]]) {
            PGNMove *pgnMove = (PGNMove *)obj;
            
            //NSLog(@"STAMPO MOSSA = %@", [pgnMove getMossaTest]);
            //NSLog(@"STAMPO MOSSA = %@", [pgnMove getMossaCompletaConParentesi]);
            //NSLog(@"STAMPO MOSSA DA WEB VIEW = %@", pgnMove.fullMove);
            
            //if ([pgnMove isFirstMoveAfterRootWithDots]) {
                //[pgnMove setEvidenzia:YES];
            //}
            
            NSString *mossaWeb = [pgnMove getMossaPerWebView];
            
            /*
            NSLog(@"MOSSA PER WEB VIEW = %@", mossaWeb);
            if ([mossaWeb isEqualToString:@"1..."]) {
                [pgnMove setEvidenzia:YES];
            }*/
            
            //NSString *mossaWeb = [pgnMove getMossaPerVarianti];
            
            //NSString *mossaWeb = [pgnMove getMossaPerWebView2];
            //NSString *mossaWeb = [pgnMove getMossaCompletaConParentesi];
            
            if ([pgnMove evidenzia]) {  //MOSSA EVIDENZIATA
                if (IS_PAD) {
                    //if (moveNotation == 1) {
                    if ([settingManager isFigurineNotation]) {
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbtr.png' width='16' height='16' alt='B'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wntr.png' width='16' height='16' alt='N'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrtr.png' width='16' height='16' alt='R'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqtr.png' width='16' height='16' alt='Q'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wktr.png' width='16' height='16' alt='K'/>"];
                    }
                    
                    mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"+=" withString:@"<img src='14.png' width='17' height='17' alt='$14'/>"];
                    mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"=+" withString:@"<img src='15.png' width='17' height='17' alt='$15'/>"];
                    mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"\u2313" withString:@"<img src='142.png' width='16' height='16' alt='$142'/>"];
                    mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"=\u221E" withString:@"<img src='44.png' width='16' height='16' alt='$44'/>"];
                    mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"+-" withString:@"<img src='18.png' width='25' height='16' alt='$18'/>"];
                    mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"-+" withString:@"<img src='19.png' width='25' height='16' alt='$19'/>"];
                }
                else {
                    if ([settingManager isFigurineNotation]) {
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbtr.png' width='10' height='10' alt='B'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wntr.png' width='10' height='10' alt='N'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrtr.png' width='10' height='10' alt='R'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqtr.png' width='10' height='10' alt='Q'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wktr.png' width='10' height='10' alt='K'/>"];
                    }
                }
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"\u24C3" withString:@"N"];
                
                //mossaWeb = [mossaWeb stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                
                /*
                NSMutableString *mossaPerWebView = [[NSMutableString alloc] initWithString:[PGNUtil getMossaEvidenziata]];
                [mossaPerWebView appendString:[PGNUtil getMossaLinkApri]];
                NSUInteger indice = [_pgnMovesArray indexOfObject:pgnMove];
                [mossaPerWebView appendString:[NSString stringWithFormat:@"%d", indice]];
                [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudiAngolare]];
                
                //if (numParentesiAperte>0) {
                //    [mossaPerWebView appendString:@"<span class='variante'>"];
                //}
                //[mossaPerWebView appendString:mossaWeb];
                //if (numParentesiAperte>0) {
                //    [mossaPerWebView appendString:@"</span>"];
                //}
                
                [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudi]];
                [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudiSpan]];
                [mossaPerWebView appendString:@" "];
                [webMovesArray addObject:mossaPerWebView];
                
                mossaEvidenziata = [_pgnMovesArray indexOfObject:pgnMove];
                NSLog(@"Ora mossa evidenziata vale %d", mossaEvidenziata);
                */
                
                mossaPerWebView = [[NSMutableString alloc] init];
                
                [mossaPerWebView appendString:@"<li class='move'>"];
                
                NSUInteger indice = [_pgnMovesArray indexOfObject:pgnMove];
                if ([[pgnMove color] isEqualToString:@"w"]) {
                    //mossaPerWebView = [[NSMutableString alloc] init];
                    //numMossa++;
                    //[mossaPerWebView appendString:@"<li class='move'>"];
                    //[mossaPerWebView appendString:@"<span class='number'>"];
                    //[mossaPerWebView appendString:[NSString stringWithFormat:@"%d. ", numMossa]];
                    //[mossaPerWebView appendString:@"</span>"];
                    //[mossaPerWebView appendString:@"<a class='whiteMove' href='javascript:void(0)'>"];
                    [mossaPerWebView appendFormat:@"<a class='whiteMove selected' ID='selected' href='%lu'>", (unsigned long)indice];
                    [mossaPerWebView appendString:mossaWeb];
                    
                    
                    [mossaPerWebView appendString:@"</a>"];
                    
                    if ([pgnMove inVariante]) {
                        if ([pgnMove getNextMoves]) {
                            [mossaPerWebView appendString:@" "];
                        }
                    }
                    else {
                        [mossaPerWebView appendString:@" "];
                    }
                    
                    
                    
                    if ([pgnMove textBefore]) {
                        
                        NSMutableString *testoPrimaDellaMossa = [[NSMutableString alloc] init];
                        [testoPrimaDellaMossa appendString:@"<span class='commento'>"];
                        [testoPrimaDellaMossa appendString:pgnMove.textBefore];
                        [testoPrimaDellaMossa appendString:@"</span>"];
                        [mossaPerWebView insertString:testoPrimaDellaMossa atIndex:0];
                        //[mossaPerWebView insertString:@"<span class='commento'>" atIndex:0];
                        //[mossaPerWebView appendString:@"<span class='commento'>"];
                        //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                        //[mossaPerWebView appendString:pgnMove.textBefore];
                        //[mossaPerWebView appendString:@"</a>"];
                        //[mossaPerWebView appendString:@"</span>"];
                    }
                    
                    if ([pgnMove textAfter]) {
                        [mossaPerWebView appendString:@"<span class='commento'>"];
                        //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                        [mossaPerWebView appendString:pgnMove.textAfter];
                        //[mossaPerWebView appendString:@"</a>"];
                        [mossaPerWebView appendString:@"</span>"];
                    }
                    
                    
                    //[mossaPerWebView appendString:@" "];
                    //[webMovesArray addObject:mossaPerWebView];
                }
                else if ([[pgnMove color] isEqualToString:@"b"]) {
                    //[mossaPerWebView appendString:@"<a class='blackMove' href='javascript:void(0)'>"];
                    [mossaPerWebView appendFormat:@"<a class='blackMove selected' ID='selected' href='%d'>", (int)indice];
                    [mossaPerWebView appendString:mossaWeb];
                    
                    
                    
                    
                    [mossaPerWebView appendString:@"</a>"];
                    
                    if ([pgnMove inVariante]) {
                        if ([pgnMove getNextMoves]) {
                            [mossaPerWebView appendString:@" "];
                        }
                    }
                    else {
                        [mossaPerWebView appendString:@" "];
                    }
                    
                    
                    if ([pgnMove textBefore]) {
                        
                        NSMutableString *testoPrimaDellaMossa = [[NSMutableString alloc] init];
                        [testoPrimaDellaMossa appendString:@"<span class='commento'>"];
                        [testoPrimaDellaMossa appendString:pgnMove.textBefore];
                        [testoPrimaDellaMossa appendString:@"</span>"];
                        [mossaPerWebView insertString:testoPrimaDellaMossa atIndex:0];
                        //[mossaPerWebView insertString:@"<span class='commento'>" atIndex:0];
                        //[mossaPerWebView appendString:@"<span class='commento'>"];
                        //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                        //[mossaPerWebView appendString:pgnMove.textBefore];
                        //[mossaPerWebView appendString:@"</a>"];
                        //[mossaPerWebView appendString:@"</span>"];
                    }
                    
                    if ([pgnMove textAfter]) {
                        [mossaPerWebView appendString:@"<span class='commento'>"];
                        //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                        [mossaPerWebView appendString:pgnMove.textAfter];
                        //[mossaPerWebView appendString:@"</a>"];
                        [mossaPerWebView appendString:@"</span>"];
                    }
                    
                    
                    
                    //[mossaPerWebView appendString:@" "];
                    //[mossaPerWebView appendString:@"</li>"];
                    //[webMovesArray addObject:mossaPerWebView];
                }
                else if ([pgnMove endGameMarked]) {
                    [mossaPerWebView appendString:@"</ul>"];
                    [mossaPerWebView appendFormat:@"<div class='result'>%@</div>", pgnMove.fullMove];
                    [mossaPerWebView appendString:@"</div>"];
                    [mossaPerWebView appendString:@"</body>"];
                    [mossaPerWebView appendString:@"</html>"];
                    //[webMovesArray addObject:mossaPerWebView];
                }
                
                [mossaPerWebView appendString:@"</li>"];
                
                mossaEvidenziata = [_pgnMovesArray indexOfObject:pgnMove];
                [webMovesArray addObject:mossaPerWebView];
                
                
            }
            else {  //MOSSA NON EVIDENZIATA
                if (IS_PAD) {
                    
                    if ([settingManager isFigurineNotation]) {
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbt.png' width='16' height='16' alt='B'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wnt.png' width='16' height='16' alt='N'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrt.png' width='16' height='16' alt='R'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqt.png' width='16' height='16' alt='Q'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wkt.png' width='16' height='16' alt='K'/>"];
                    }
                    
                    mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"+=" withString:@"<img src='14.png' width='17' height='17' alt='$14'/>"];
                    mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"=+" withString:@"<img src='15.png' width='17' height='17' alt='$15'/>"];
                    mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"\u2313" withString:@"<img src='142.png' width='16' height='16' alt='$142'/>"];
                    mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"=\u221E" withString:@"<img src='44.png' width='16' height='16' alt='$44'/>"];
                    mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"+-" withString:@"<img src='18.png' width='25' height='16' alt='$18'/>"];
                    mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"-+" withString:@"<img src='19.png' width='25' height='16' alt='$19'/>"];
                }
                else {
                    if ([settingManager isFigurineNotation]) {
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbt.png' width='10' height='10' alt='B'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wnt.png' width='10' height='10' alt='N'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrt.png' width='10' height='10' alt='R'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqt.png' width='10' height='10' alt='Q'/>"];
                        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wkt.png' width='10' height='10' alt='K'/>"];
                    }
                }
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"\u24C3" withString:@"N"];
                
                //mossaWeb = [mossaWeb stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                /*
                NSMutableString *mossaPerWebView = [[NSMutableString alloc] init];
                [mossaPerWebView appendString:[PGNUtil getMossaLinkApri]];
                NSUInteger indice = [_pgnMovesArray indexOfObject:pgnMove];
                [mossaPerWebView appendString:[NSString stringWithFormat:@"%d", indice]];
                [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudiAngolare]];
                [mossaPerWebView appendString:mossaWeb];
                [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudi]];
                [mossaPerWebView appendString:@" "];
                [webMovesArray addObject:mossaPerWebView];
                */
                
                //NSLog(@"MOSSA WEB = %@", mossaWeb);
                
                mossaPerWebView = [[NSMutableString alloc] init];
                
                
                [mossaPerWebView appendString:@"<li class='move'>"];
                
                
                
                
                int indice = (int)[_pgnMovesArray indexOfObject:pgnMove];
                if ([[pgnMove color] isEqualToString:@"w"]) {
                    //mossaPerWebView = [[NSMutableString alloc] init];
                    numMossa++;
                    //[mossaPerWebView appendString:@"<li class='move'>"];
                    //[mossaPerWebView appendString:@"<span class='number'>"];
                    //[mossaPerWebView appendString:[NSString stringWithFormat:@"%d. ", numMossa]];
                    //[mossaPerWebView appendString:@"</span>"];
                    //[mossaPerWebView appendString:@"<a class='whiteMove' href='javascript:void(0)'>"];
                    if ([pgnMove inVariante]) {
                        [mossaPerWebView appendFormat:@"<a class='whiteMove variante' href='%d'>", indice];
                    }
                    else {
                        [mossaPerWebView appendFormat:@"<a class='whiteMove' href='%d'>", indice];
                    }
                    [mossaPerWebView appendString:mossaWeb];
                    
                    
                    [mossaPerWebView appendString:@"</a>"];
                    
                    
                    if ([pgnMove inVariante]) {
                        if ([pgnMove getNextMoves]) {
                            [mossaPerWebView appendString:@" "];
                        }
                    }
                    else {
                        [mossaPerWebView appendString:@" "];
                    }
                    
                    
                    if ([pgnMove textBefore]) {
                        
                        NSMutableString *testoPrimaDellaMossa = [[NSMutableString alloc] init];
                        [testoPrimaDellaMossa appendString:@"<span class='commento'>"];
                        [testoPrimaDellaMossa appendString:pgnMove.textBefore];
                        [testoPrimaDellaMossa appendString:@"</span>"];
                        [mossaPerWebView insertString:testoPrimaDellaMossa atIndex:0];
                        //[mossaPerWebView insertString:@"<span class='commento'>" atIndex:0];
                        //[mossaPerWebView appendString:@"<span class='commento'>"];
                        //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                        //[mossaPerWebView appendString:pgnMove.textBefore];
                        //[mossaPerWebView appendString:@"</a>"];
                        //[mossaPerWebView appendString:@"</span>"];
                    }
                    
                    if ([pgnMove textAfter]) {
                        [mossaPerWebView appendString:@"<span class='commento'>"];
                        //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                        [mossaPerWebView appendString:pgnMove.textAfter];
                        //[mossaPerWebView appendString:@"</a>"];
                        [mossaPerWebView appendString:@"</span>"];
                    }
                    
                    
                    //[mossaPerWebView appendString:@"</li>"];
                    //[webMovesArray addObject:mossaPerWebView];
                }
                else if ([[pgnMove color] isEqualToString:@"b"]) {
                    //[mossaPerWebView appendString:@"<a class='blackMove' href='javascript:void(0)'>"];
                    //[mossaPerWebView appendString:@"<li class='move'>"];
                    if ([pgnMove inVariante]) {
                        [mossaPerWebView appendFormat:@"<a class='blackMove variante' href='%d'>", indice];
                    }
                    else {
                        [mossaPerWebView appendFormat:@"<a class='blackMove' href='%d'>", indice];
                    }
                    [mossaPerWebView appendString:mossaWeb];
                    
                    
                    [mossaPerWebView appendString:@"</a>"];
                    
                    if ([pgnMove inVariante]) {
                        if ([pgnMove getNextMoves]) {
                            [mossaPerWebView appendString:@" "];
                        }
                    }
                    else {
                        [mossaPerWebView appendString:@" "];
                    }
                    
                    
                    if ([pgnMove textBefore]) {
                        
                        NSMutableString *testoPrimaDellaMossa = [[NSMutableString alloc] init];
                        [testoPrimaDellaMossa appendString:@"<span class='commento'>"];
                        [testoPrimaDellaMossa appendString:pgnMove.textBefore];
                        [testoPrimaDellaMossa appendString:@"</span>"];
                        [mossaPerWebView insertString:testoPrimaDellaMossa atIndex:0];
                        //[mossaPerWebView insertString:@"<span class='commento'>" atIndex:0];
                        //[mossaPerWebView appendString:@"<span class='commento'>"];
                        //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                        //[mossaPerWebView appendString:pgnMove.textBefore];
                        //[mossaPerWebView appendString:@"</a>"];
                        //[mossaPerWebView appendString:@"</span>"];
                    }
                    
                    if ([pgnMove textAfter]) {
                        [mossaPerWebView appendString:@"<span class='commento'>"];
                        //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                        [mossaPerWebView appendString:pgnMove.textAfter];
                        //[mossaPerWebView appendString:@"</a>"];
                        [mossaPerWebView appendString:@"</span>"];
                    }
                    
                    //[mossaPerWebView appendString:@" "];
                    //[mossaPerWebView appendString:@"</li>"];
                    //[webMovesArray addObject:mossaPerWebView];
                }
                else if ([pgnMove endGameMarked]) {
                    
                    if (pgnMove.textBefore) {
                        NSMutableString *testoPrimaDellaMossa = [[NSMutableString alloc] init];
                        [testoPrimaDellaMossa appendString:@"<span class='commento'>"];
                        [testoPrimaDellaMossa appendString:pgnMove.textBefore];
                        [testoPrimaDellaMossa appendString:@"</span>"];
                        [mossaPerWebView insertString:testoPrimaDellaMossa atIndex:0];
                    }
                    
                    //[mossaPerWebView appendString:@"</ul>"];
                    //[mossaPerWebView appendFormat:@"<div class='result'>%@</div>", pgnMove.fullMove];
                    //[mossaPerWebView appendString:@"</div>"];
                    
                    [mossaPerWebView appendFormat:@"<a class='resultMove' href='%d'>", indice];
                    [mossaPerWebView appendString:pgnMove.fullMove];
                    [mossaPerWebView appendString:@"</a>"];
                    [mossaPerWebView appendString:@"</body>"];
                    [mossaPerWebView appendString:@"</html>"];
                    //[webMovesArray addObject:mossaPerWebView];
                    
                    
                    //NSLog(@"MOSSA WEBVIEW = %@", mossaPerWebView);
                }
                
                
                [mossaPerWebView appendString:@"</li>"];
                
                //NSLog(@"MOSSA WEBVIEW = %@", mossaPerWebView);
                [webMovesArray addObject:mossaPerWebView];
            }
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            NSString *parentesi = (NSString *)obj;
            if ([parentesi isEqualToString:@"["] || [parentesi isEqualToString:@"("]) {
                numParentesiAperte++;
                //NSString *variante = [[@"<span class='variante'>" stringByAppendingString:altro] stringByAppendingString:@"</span>"];
                //[webMovesArray addObject:variante];
                if (numParentesiAperte>0) {
                    //NSLog(@"Nelle successive mosse devo tenere conto che sono dentro una variante");
                    mossaPerWebView = [[NSMutableString alloc] init];
                    [mossaPerWebView appendFormat:@"<span class='variationStart'>%@</span>", parentesi];
                    //[mossaPerWebView appendString:parentesi];
                    [webMovesArray addObject:mossaPerWebView];
                }
                
            }
            else if ([parentesi isEqualToString:@"]"] || [parentesi isEqualToString:@")"]) {
                //NSLog(@"Nelle successive mosse devo tenere conto che sono dentro una variante");
                mossaPerWebView = [[NSMutableString alloc] init];
                [mossaPerWebView appendFormat:@"<span class='variationEnd'>%@ </span>", parentesi];
                //[mossaPerWebView appendString:parentesi];
                [webMovesArray addObject:mossaPerWebView];
                numParentesiAperte--;
            }
            else {
                //NSLog(@"Sono nella variante principale");
            }
            /*
            if (numParentesiAperte>0) {
                variante = YES;
            }
            else {
                variante = NO;
            }
            */
            //[webMovesArray addObject:mossaPerWebView];
        }
    }
    /*
    NSLog(@"***********************************");
    for (NSString *s in webMovesArray) {
        NSLog(@"%@", s);
    }
    NSLog(@"***********************************");
    */
    [self setWebGameArray:webMovesArray];
}




- (void) setWebGameArray:(NSArray *)webGameArray {
    _gameToViewArray = webGameArray;
    //mosseWeb = [[NSMutableString alloc] initWithString:testa];
    mosseWeb = [[NSMutableString alloc] initWithString:testaNew];
    
    
    [mosseWeb appendString:body1];
    
    if ([settingManager showEco]) {
        if (_opening && testaOpeningString && codaOpeningString) {
            [mosseWeb appendString:testaOpeningString];
            [mosseWeb appendString:_opening];
            [mosseWeb appendString:codaOpeningString];
        }
    }
    
    if ([settingManager showBookMoves]) {
        if (_bookMovesArray && testaBookMovesArray && codaBookMovesArray) {
            for (int i=0; i<_bookMovesArray.count; i++) {
                NSString *m = [_bookMovesArray objectAtIndex:i];
                
                if ([settingManager isFigurineNotation]) {
                    m = [m stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbt.png' width='12' height='12' alt='B'/>"];
                    m = [m stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wnt.png' width='12' height='12' alt='N'/>"];
                    m = [m stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrt.png' width='12' height='12' alt='R'/>"];
                    m = [m stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqt.png' width='12' height='12' alt='Q'/>"];
                    m = [m stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wkt.png' width='12' height='12' alt='K'/>"];
                }
                
                
                NSMutableString *ms = [[NSMutableString alloc] init];
                
                NSString *newTestaBook = [testaBookMovesArray stringByReplacingOccurrencesOfString:@"*" withString:[NSString stringWithFormat:@"b%d", i]];
                
                [ms appendString:newTestaBook];
                [ms appendString:m];
                [ms appendString:codaBookMovesArray];
                [ms appendString:@"  "];
                
                if (i==0) {
                    if (IS_PAD) {
                        [mosseWeb appendString:@"<font size=\"2\" color=\"black\" face=\"arial\"><b>Book: </b></font>"];
                    }
                    else {
                        [mosseWeb appendString:@"<font size=\"1\" color=\"black\" face=\"arial\"><b>Book: </b></font>"];
                    }
                }
                
                [mosseWeb appendString:ms];
            }
            
            if (_bookMovesArray.count>0) {
                [mosseWeb appendString:@"<hr>"];
            }
        }
    }

    

    
    /*
    if (_bookMoves && testBookMoves && codaBookMoves) {
        [mosseWeb appendString:testBookMoves];
        [mosseWeb appendString:_bookMoves];
        [mosseWeb appendString:codaBookMoves];
    }*/

    
    [mosseWeb appendString:body2];
    
    
    
    for (NSString *mossaWeb in _gameToViewArray) {
        //if ([mossaWeb isEqualToString:@"["] || [mossaWeb isEqualToString:@"]"] || [mossaWeb isEqualToString:@"("] || [mossaWeb isEqualToString:@")"]) {
        //    [mosseWeb appendString:mossaWeb];
        //    [mosseWeb appendString:@" "];
        //}
        //else {
            [mosseWeb appendString:mossaWeb];
        //}
        //NSLog(@"%@", mossaWeb);
    }
    //[mosseWeb appendString:coda];
    
    [self loadHTMLString:mosseWeb baseURL:[[NSBundle mainBundle]bundleURL]];
}

- (NSString *) getMosseWebPerEmail {
    return mosseWeb;
}
 
- (void) refresh {
    if (mosseWeb) {
        //NSLog(@"REFRESH:%@", mosseWeb);
        [self loadHTMLString:mosseWeb baseURL:[[NSBundle mainBundle]bundleURL]];
    }
}
 
- (void) resetGame {
    _gameToViewArray = [[NSArray alloc] init];
    //plyCount = 0;
    _opening = nil;
    _bookMoves = nil;
    [webMovesArray removeAllObjects];
    [self setWebGameArray:webMovesArray];
}

/*
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches began from GameWebView");
}
*/

- (NSString *) getMossaPerWebGameArray:(PGNMove *)move {
    NSString *mossaWeb = [move getMossaPerWebView];
    //NSString *mossaWeb = [move getMossaPerWebView2];
    NSMutableString *mossaPerWebView;
    mossaPerWebView = [[NSMutableString alloc] init];
    
    [mossaPerWebView appendString:@"<li class='move'>"];
    
    
    if ([move evidenzia]) {
        if (IS_PAD) {
            
            if ([settingManager isFigurineNotation]) {
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbtr.png' width='16' height='16' alt='B'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wntr.png' width='16' height='16' alt='N'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrtr.png' width='16' height='16' alt='R'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqtr.png' width='16' height='16' alt='Q'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wktr.png' width='16' height='16' alt='K'/>"];
            }
            
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"+=" withString:@"<img src='14.png' width='17' height='17' alt='$14'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"=+" withString:@"<img src='15.png' width='17' height='17' alt='$15'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"\u2313" withString:@"<img src='142.png' width='16' height='16' alt='$142'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"=\u221E" withString:@"<img src='44.png' width='16' height='16' alt='$44'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"+-" withString:@"<img src='18.png' width='25' height='16' alt='$18'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"-+" withString:@"<img src='19.png' width='25' height='16' alt='$19'/>"];
        }
        else {
            if ([settingManager isFigurineNotation]) {
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbtr.png' width='10' height='10' alt='B'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wntr.png' width='10' height='10' alt='N'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrtr.png' width='10' height='10' alt='R'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqtr.png' width='10' height='10' alt='Q'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wktr.png' width='10' height='10' alt='K'/>"];
            }
        }
        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"\u24C3" withString:@"N"];
        
        mossaWeb = [mossaWeb stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        int indice = (int)[_pgnMovesArray indexOfObject:move];
        if ([[move color] isEqualToString:@"w"]) {
            //NSUInteger numMossa = [move getNumeroMossa];
            //[mossaPerWebView appendString:@"<li class='move'>"];
            //[mossaPerWebView appendString:@"<span class='number'>"];
            //[mossaPerWebView appendString:[NSString stringWithFormat:@"%d. ", numMossa]];
            //[mossaPerWebView appendString:@"</span>"];
            //[mossaPerWebView appendString:@"<a class='whiteMove' href='javascript:void(0)'>"];
            if ([move inVariante]) {
                [mossaPerWebView appendFormat:@"<a class='whiteMove selectedVariante' ID='selected' href='%d'>", indice];
            }
            else {
                [mossaPerWebView appendFormat:@"<a class='whiteMove selected' ID='selected' href='%d'>", indice];
            }
            [mossaPerWebView appendString:mossaWeb];
            [mossaPerWebView appendString:@"</a>"];
            
            if ([move inVariante]) {
                if ([move getNextMoves]) {
                    [mossaPerWebView appendString:@" "];
                }
            }
            else {
                [mossaPerWebView appendString:@" "];
            }
            
            if ([move textBefore]) {
                
                NSMutableString *testoPrimaDellaMossa = [[NSMutableString alloc] init];
                [testoPrimaDellaMossa appendString:@"<span class='commento'>"];
                [testoPrimaDellaMossa appendString:move.textBefore];
                [testoPrimaDellaMossa appendString:@"</span>"];
                [mossaPerWebView insertString:testoPrimaDellaMossa atIndex:0];
                //[mossaPerWebView insertString:@"<span class='commento'>" atIndex:0];
                //[mossaPerWebView appendString:@"<span class='commento'>"];
                //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                //[mossaPerWebView appendString:pgnMove.textBefore];
                //[mossaPerWebView appendString:@"</a>"];
                //[mossaPerWebView appendString:@"</span>"];
            }
            
            if ([move textAfter]) {
                [mossaPerWebView appendString:@"<span class='commento'>"];
                //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                [mossaPerWebView appendString:move.textAfter];
                //[mossaPerWebView appendString:@"</a>"];
                [mossaPerWebView appendString:@"</span>"];
            }
            
            
            //[mossaPerWebView appendString:@" "];
        }
        else if ([[move color] isEqualToString:@"b"]) {
            //[mossaPerWebView appendString:@"<a class='blackMove' href='javascript:void(0)'>"];
            if ([move inVariante]) {
                [mossaPerWebView appendFormat:@"<a class='blackMove selectedVariante' ID='selected' href='%d'>", indice];
            }
            else {
                [mossaPerWebView appendFormat:@"<a class='blackMove selected' ID='selected' href='%d'>", indice];
            }
            [mossaPerWebView appendString:mossaWeb];
            [mossaPerWebView appendString:@"</a>"];
            
            if ([move inVariante]) {
                if ([move getNextMoves]) {
                    [mossaPerWebView appendString:@" "];
                }
            }
            else {
                [mossaPerWebView appendString:@" "];
            }
            
            if ([move textBefore]) {
                
                NSMutableString *testoPrimaDellaMossa = [[NSMutableString alloc] init];
                [testoPrimaDellaMossa appendString:@"<span class='commento'>"];
                [testoPrimaDellaMossa appendString:move.textBefore];
                [testoPrimaDellaMossa appendString:@"</span>"];
                [mossaPerWebView insertString:testoPrimaDellaMossa atIndex:0];
                
                //[mossaPerWebView insertString:@"<span class='commento'>" atIndex:0];
                //[mossaPerWebView appendString:@"<span class='commento'>"];
                //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                //[mossaPerWebView appendString:pgnMove.textBefore];
                //[mossaPerWebView appendString:@"</a>"];
                //[mossaPerWebView appendString:@"</span>"];
            }
            
            if ([move textAfter]) {
                [mossaPerWebView appendString:@"<span class='commento'>"];
                //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                [mossaPerWebView appendString:move.textAfter];
                //[mossaPerWebView appendString:@"</a>"];
                [mossaPerWebView appendString:@"</span>"];
            }
            
            //[mossaPerWebView appendString:@" "];
            //[mossaPerWebView appendString:@"</li>"];
        }
        else if ([move endGameMarked]) {
            [mossaPerWebView appendString:@"</ul>"];
            [mossaPerWebView appendFormat:@"<div class='result'>%@</div>", move.fullMove];
            [mossaPerWebView appendString:@"</div>"];
            [mossaPerWebView appendString:@"</body>"];
            [mossaPerWebView appendString:@"</html>"];
        }
        return mossaPerWebView;
        
        /*
        NSMutableString *mossaPerWebView = [[NSMutableString alloc] initWithString:[PGNUtil getMossaEvidenziata]];
        [mossaPerWebView appendString:[PGNUtil getMossaLinkApri]];
        NSUInteger indice = [_pgnMovesArray indexOfObject:move];
        [mossaPerWebView appendString:[NSString stringWithFormat:@"%d", indice]];
        [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudiAngolare]];
        [mossaPerWebView appendString:mossaWeb];
        [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudi]];
        [mossaPerWebView appendString:[PGNUtil getMossaLinkChiudiSpan]];
        [mossaPerWebView appendString:@" "];
        return mossaPerWebView;
        */
    }
    else {
        if (IS_PAD) {
            
            if ([settingManager isFigurineNotation]) {
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbt.png' width='16' height='16' alt='B'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wnt.png' width='16' height='16' alt='N'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrt.png' width='16' height='16' alt='R'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqt.png' width='16' height='16' alt='Q'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wkt.png' width='16' height='16' alt='K'/>"];
            }
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"+=" withString:@"<img src='14.png' width='17' height='17' alt='$14'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"=+" withString:@"<img src='15.png' width='17' height='17' alt='$15'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"\u2313" withString:@"<img src='142.png' width='16' height='16' alt='$142'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"=\u221E" withString:@"<img src='44.png' width='16' height='16' alt='$44'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"+-" withString:@"<img src='18.png' width='25' height='16' alt='$18'/>"];
            mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"-+" withString:@"<img src='19.png' width='25' height='16' alt='$19'/>"];
        }
        else {
            if ([settingManager isFigurineNotation]) {
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"B" withString:@"<img src='wbt.png' width='10' height='10' alt='B'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"N" withString:@"<img src='wnt.png' width='10' height='10' alt='N'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"R" withString:@"<img src='wrt.png' width='10' height='10' alt='R'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"Q" withString:@"<img src='wqt.png' width='10' height='10' alt='Q'/>"];
                mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"K" withString:@"<img src='wkt.png' width='10' height='10' alt='K'/>"];
            }
        }
        mossaWeb = [mossaWeb stringByReplacingOccurrencesOfString:@"\u24C3" withString:@"N"];
        
        mossaWeb = [mossaWeb stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        int indice = (int)[_pgnMovesArray indexOfObject:move];
        if ([[move color] isEqualToString:@"w"]) {
            mossaPerWebView = [[NSMutableString alloc] init];
            //NSUInteger numMossa = [move getNumeroMossa];
            //[mossaPerWebView appendString:@"<li class='move'>"];
            //[mossaPerWebView appendString:@"<span class='number'>"];
            //[mossaPerWebView appendString:[NSString stringWithFormat:@"%d. ", numMossa]];
            //[mossaPerWebView appendString:@"</span>"];
            //[mossaPerWebView appendString:@"<a class='whiteMove' href='javascript:void(0)'>"];
            if ([move inVariante]) {
                [mossaPerWebView appendFormat:@"<a class='whiteMove variante' href='%d'>", indice];
            }
            else {
                [mossaPerWebView appendFormat:@"<a class='whiteMove' href='%d'>", indice];
            }
            [mossaPerWebView appendString:mossaWeb];
            [mossaPerWebView appendString:@"</a>"];
            
            if ([move inVariante]) {
                if ([move getNextMoves]) {
                    [mossaPerWebView appendString:@" "];
                }
            }
            else {
                [mossaPerWebView appendString:@" "];
            }
            
            if ([move textBefore]) {
                
                NSMutableString *testoPrimaDellaMossa = [[NSMutableString alloc] init];
                [testoPrimaDellaMossa appendString:@"<span class='commento'>"];
                [testoPrimaDellaMossa appendString:move.textBefore];
                [testoPrimaDellaMossa appendString:@"</span>"];
                [mossaPerWebView insertString:testoPrimaDellaMossa atIndex:0];
                
                //[mossaPerWebView insertString:@"<span class='commento'>" atIndex:0];
                //[mossaPerWebView appendString:@"<span class='commento'>"];
                //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                //[mossaPerWebView appendString:pgnMove.textBefore];
                //[mossaPerWebView appendString:@"</a>"];
                //[mossaPerWebView appendString:@"</span>"];
            }
            
            if ([move textAfter]) {
                [mossaPerWebView appendString:@"<span class='commento'>"];
                //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                [mossaPerWebView appendString:move.textAfter];
                //[mossaPerWebView appendString:@"</a>"];
                [mossaPerWebView appendString:@"</span>"];
            }
            
            //[mossaPerWebView appendString:@" "];
        }
        else if ([[move color] isEqualToString:@"b"]) {
            //[mossaPerWebView appendString:@"<a class='blackMove' href='javascript:void(0)'>"];
            if ([move inVariante]) {
                [mossaPerWebView appendFormat:@"<a class='blackMove variante' href='%d'>", indice];
            }
            else {
                [mossaPerWebView appendFormat:@"<a class='blackMove' href='%d'>", indice];
            }
            [mossaPerWebView appendString:mossaWeb];
            [mossaPerWebView appendString:@"</a>"];
            
            if ([move inVariante]) {
                if ([move getNextMoves]) {
                    [mossaPerWebView appendString:@" "];
                }
            }
            else {
                [mossaPerWebView appendString:@" "];
            }
            
            if ([move textBefore]) {
                
                NSMutableString *testoPrimaDellaMossa = [[NSMutableString alloc] init];
                [testoPrimaDellaMossa appendString:@"<span class='commento'>"];
                [testoPrimaDellaMossa appendString:move.textBefore];
                [testoPrimaDellaMossa appendString:@"</span>"];
                [mossaPerWebView insertString:testoPrimaDellaMossa atIndex:0];
                
                //[mossaPerWebView insertString:@"<span class='commento'>" atIndex:0];
                //[mossaPerWebView appendString:@"<span class='commento'>"];
                //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                //[mossaPerWebView appendString:pgnMove.textBefore];
                //[mossaPerWebView appendString:@"</a>"];
                //[mossaPerWebView appendString:@"</span>"];
            }
            
            
            if ([move textAfter]) {
                [mossaPerWebView appendString:@"<span class='commento'>"];
                //[mossaPerWebView appendFormat:@"<a class='commento selected' ID='commento' href='%d'>", indice];
                [mossaPerWebView appendString:move.textAfter];
                //[mossaPerWebView appendString:@"</a>"];
                [mossaPerWebView appendString:@"</span>"];
            }
            
            //[mossaPerWebView appendString:@" "];
            //[mossaPerWebView appendString:@"</li>"];
        }
        else if ([move endGameMarked]) {
            [mossaPerWebView appendString:@"</ul>"];
            [mossaPerWebView appendFormat:@"<div class='result'>%@</div>", move.fullMove];
            [mossaPerWebView appendString:@"</div>"];
            [mossaPerWebView appendString:@"</body>"];
            [mossaPerWebView appendString:@"</html>"];
        }
        
        [mossaPerWebView appendString:@"</li>"];
        
        return mossaPerWebView;
        
    }
    return nil;
}

- (short) getNumeroMossaEvidenziata {
    return mossaEvidenziata;
}

- (void) aggiornaWebView {
    PGNMove *pgnMoveSel = [_pgnMovesArray objectAtIndex:mossaEvidenziata];
    [self aggiornaWebViewAvanti:pgnMoveSel];
}

- (void) aggiornaWebViewAvanti:(PGNMove *)nextMove {
    //NSLog(@"Sto eseguendo aggiornaWebViewAvanti con valore mossa evidenziata = %d", mossaEvidenziata);
    
    NSString *primoElemento = nil;
    if (_rootMove.textAfter) {
        primoElemento = [webMovesArray objectAtIndex:0];
        [webMovesArray removeObjectAtIndex:0];
    }
    
    
    if ([nextMove isRootMove]) {
        PGNMove *pgnMoveSel = [_pgnMovesArray objectAtIndex:mossaEvidenziata];
        [pgnMoveSel setEvidenzia:NO];
        [webMovesArray replaceObjectAtIndex:mossaEvidenziata withObject:[self getMossaPerWebGameArray:pgnMoveSel]];
        
        if (_rootMove.textAfter) {
            [webMovesArray insertObject:primoElemento atIndex:0];
        }
        [self setWebGameArray:webMovesArray];
        return;
    }

    
    if (mossaEvidenziata == -1) {
        mossaEvidenziata = [_pgnMovesArray indexOfObject:nextMove];
        //NSLog(@"Devo sostituire la mossa e mossa evidenziata == %d", mossaEvidenziata);
        //NSString *nuovaMossa = [self getMossaPerWebGameArray:nextMove];
        //[nextMove setEvidenzia:YES];
        //NSLog(@"Devo inserire in web movesarray %@", nuovaMossa);
        [webMovesArray replaceObjectAtIndex:mossaEvidenziata withObject:[self getMossaPerWebGameArray:nextMove]];
    }
    else {
        PGNMove *pgnMoveSel = [_pgnMovesArray objectAtIndex:mossaEvidenziata];
        [pgnMoveSel setEvidenzia:NO];
        [webMovesArray replaceObjectAtIndex:mossaEvidenziata withObject:[self getMossaPerWebGameArray:pgnMoveSel]];
        //NSLog(@"Prima mossa evidenziata = %d con valore %@", mossaEvidenziata, [pgnMoveSel getMossaPerWebView]);
        [nextMove setEvidenzia:YES];
        mossaEvidenziata = [_pgnMovesArray indexOfObject:nextMove];
        //NSLog(@"Ora mossa evidenziata = %d con numero %d e valore %@", mossaEvidenziata, [nextMove getNumeroMossa] ,[nextMove getMossaPerWebView]);
        [webMovesArray replaceObjectAtIndex:mossaEvidenziata withObject:[self getMossaPerWebGameArray:nextMove]];
    }
    
    if (_rootMove.textAfter) {
        [webMovesArray insertObject:primoElemento atIndex:0];
    }
    
    
    [self setWebGameArray:webMovesArray];
    /*
    for (int i=0; i<_pgnMovesArray.count; i++) {
        NSObject *obj = [_pgnMovesArray objectAtIndex:i];
        if ([obj isKindOfClass:[PGNMove class]]) {
            PGNMove *m = (PGNMove *)obj;
            NSLog(@"Elemento numero %d con valore %@ ed index %d", i, m.getMossaPerWebView, [_pgnMovesArray indexOfObject:m]);
        }
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *p = (NSString *)obj;
            NSLog(@"Elemento numero %d con valore %@ ed index %d", i, p, [_pgnMovesArray indexOfObject:p]);
        }
    }
    for (int i=0; i<webMovesArray.count; i++) {
        NSLog(@"Elemento n. %d con valore %@", i, [webMovesArray objectAtIndex:i]);
    }
    */
}

- (void) aggiornaWebViewIndietro:(PGNMove *)prevMove {
    //NSLog(@"Sto eseguendo aggiornaWebViewIndietro con valore mossa evidenziata = %d", mossaEvidenziata);
    
    NSString *primoElemento = nil;
    if (_rootMove.textAfter) {
        primoElemento = [webMovesArray objectAtIndex:0];
        [webMovesArray removeObjectAtIndex:0];
    }
    
    
    PGNMove *pgnMoveSel = [_pgnMovesArray objectAtIndex:mossaEvidenziata];
    [pgnMoveSel setEvidenzia:NO];
    [webMovesArray replaceObjectAtIndex:mossaEvidenziata withObject:[self getMossaPerWebGameArray:pgnMoveSel]];
    
    if (prevMove.fullMove) {
        //NSLog(@"Prev Move esiste ed è = %@", prevMove.fullMove);
        [prevMove setEvidenzia:YES];
        mossaEvidenziata = [_pgnMovesArray indexOfObject:prevMove];
        [webMovesArray replaceObjectAtIndex:mossaEvidenziata withObject:[self getMossaPerWebGameArray:prevMove]];
    }
    else {
        mossaEvidenziata = -1;
    }
    
    if (_rootMove.textAfter) {
        [webMovesArray insertObject:primoElemento atIndex:0];
    }
    
    [self setWebGameArray:webMovesArray];
}


- (PGNMove *) getMoveByNumber:(short)number {
    return [_pgnMovesArray objectAtIndex:number];
}

- (NSUInteger) getNumberByMove:(PGNMove *)move {
    if (!move) {
        return -1;
    }
    return [_pgnMovesArray indexOfObject:move];
}

- (void) stampaPgnMovesArray {
    for (int i=0; i<_pgnMovesArray.count; i++) {
        NSObject *obj = [_pgnMovesArray objectAtIndex:i];
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *s = (NSString *)obj;
            NSLog(@"%d         %@", i, s);
        }
        if ([obj isKindOfClass:[PGNMove class]]) {
            PGNMove *m = (PGNMove *)obj;
            NSLog(@"%d         %@", i, m.getMossaPerVarianti);
        }
        
    }
}

- (void) setMoveNotation:(NSUInteger)movNotation {
    //moveNotation = movNotation;
}

- (void) setNotation:(NSString *)notation {
    if ([notation isEqualToString:NSLocalizedString(@"LETTER", nil)]) {
        //moveNotation = 0;
    }
    else if ([notation isEqualToString:NSLocalizedString(@"FIGURINE", nil)]) {
        //moveNotation = 1;
    }
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    _lastTouchPosition = point;
    return [super hitTest:point withEvent:event];
}

@end
