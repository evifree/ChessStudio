//
//  PGNUtil.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 22/04/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "PGNUtil.h"

@implementation PGNUtil


+ (NSString *) nagToSymbol:(NSString *)nag {
    NSUInteger nagNumber = 0;
    if ([nag hasPrefix:@"$"]) {
        nagNumber = [[nag substringFromIndex:1] integerValue];
    }
    else {
        nagNumber = [nag integerValue];
    }
    //if ([nag hasPrefix:@"$"]) {
        //NSInteger nugNumber = [[nag substringFromIndex:1] integerValue];
        switch (nagNumber) {
            case 0:
                return @"";
            case 1:
                return @"!";
            case 2:
                return @"?";
            case 3:
                return @"\u203C";
            case 4:
                return @"\u2047";
            case 5:
                return @"\u2049";
            case 6:
                return @"\u2048";
            case 7:
            case 8:
                return @"\u25A1";
            case 10:
            case 11:
            case 12:
                return @"=";
            case 13:
                return @"\u221E";
            case 14:
                //return @"\u2A72";
                return @"+=";
            case 15:
                //return @"\u2A71";
                return @"=+";
            case 16:
                return @"\u00B1";
            case 17:
                return @"\u2213";
            case 18:
                return @"+-";
            case 19:
                return @"-+";
            case 36:
                return @"\u2192";
            case 40:
                return @"\u2191";
            case 44:
                //return @"\u224c";
                return [@"=" stringByAppendingString:@"\u221E"];
            case 132:
                return @"\u21C6";
            case 138:
                return @"\u2295";
            case 140:
                return @"\u2206";
            case 142:
                return @"\u2313";
            case 146:
                return @"\u24C3";
                //return @"N";
            default:
                break;
        }
        
    //}
    return nag;
}


+ (NSString *) nagToSymbolForGameMovesWebView:(NSString *)nag {
    NSUInteger nagNumber = 0;
    if ([nag hasPrefix:@"$"]) {
        nagNumber = [[nag substringFromIndex:1] integerValue];
    }
    else {
        nagNumber = [nag integerValue];
    }
    //if ([nag hasPrefix:@"$"]) {
    //NSInteger nugNumber = [[nag substringFromIndex:1] integerValue];
    switch (nagNumber) {
        case 0:
            return @"";
        case 1:
            //return @"!";
            return @"<span class='move-annotation'>]</span>";
        case 2:
            //return @"?";
            return @"<span class='move-annotation'>_</span>";
        case 3:
            //return @"!!";
            return @"<span class='move-annotation'>^</span>";
        case 4:
            //return @"??";
            return @"<span class='move-annotation'>\u0060</span>";
        case 5:
            //return @"!?";
            return @"<span class='move-annotation'>a</span>";
        case 6:
            //return @"?!";
            return @"<span class='move-annotation'>b</span>";
        case 7:
        case 8:
            return @"\u2122";
        case 10:
        case 11:
        case 12:
            return @"<span class='move-annotation'>S</span>";
            return @"=";
        case 13:
            return @"<span class='move-annotation'>T</span>";
            return @"\u221E";
        case 14:
            //return @"\u2A72";
            //return @"\u00B2";
            return @"<span class='move-annotation'>M</span>";
        case 15:
            //return @"\u2A71";
            return @"<span class='move-annotation'>N</span>";
            return @"\u00B3";
        case 16:
            return @"<span class='move-annotation'>O</span>";
            return @"\u00B1";
        case 17:
            return @"<span class='move-annotation'>P</span>";
            return @"\u2213";
        case 18:
            return @"<span class='move-annotation'>Q</span>";
            return @"+-";
        case 19:
            return @"<span class='move-annotation'>R</span>";
            return @"-+";
        case 22:
            return @"<span class='move-annotation'>[</span>";
        case 23:
            return @"<span class='move-annotation'>[</span>";
        case 32:
            return @"<span class='move-annotation'>V</span>";
        case 33:
            return @"<span class='move-annotation'>V</span>";
        case 36:
            return @"<span class='move-annotation'>X</span>";
            return @"\u2192";
        case 40:
            return @"<span class='move-annotation'>Y</span>";
            return @"\u2191";
        case 44:
            return @"<span class='move-annotation'>U</span>";
            return @"\u00A9";
            //return [@"=" stringByAppendingString:@"\u221E"];
        case 132:
            return @"<span class='move-annotation'>Z</span>";
            return @"\u21C6";
        case 138:
            return @"\u2020";
        case 140:
            return @"\u2206";
        case 142:
            return @"<span class='move-annotation'>e</span>";
            return @"\u00B9";
        case 145:
            return @"<span class='figorg'>RR</span>";
        case 146:
            //return @"\u24C3";
            return @"<span class='figorg'>N</span>";
        case 239:
            return @"<span class='move-annotation'>f</span>";
        case 240:
            return @"<span class='move-annotation'>g</span>";
        case 241:
            return @"<span class='move-annotation'>h</span>";
        case 242:
            return @"<span class='move-annotation'>i</span>";
        case 243:
            return @"<span class='move-annotation'>j</span>";
        case 245:
            return @"<span class='move-annotation'>l</span>";
        case 246:
            return @"<span class='move-annotation'>m</span>";
        case 247:
            return @"<span class='move-annotation'>n</span>";
        case 248:
            return @"<span class='move-annotation'>o</span>";
        case 249:
            return @"<span class='move-annotation'>p</span>";
        case 250:
            return @"<span class='move-annotation'>q</span>";
        case 251:
            return @"<span class='move-annotation'>r</span>";
        case 252:
            return @"<span class='move-annotation'>s</span>";
        case 253:
            return @"<span class='move-annotation'>t</span>";
        case 254:
            return @"<span class='move-annotation'>v</span>";
        case 255:
            return @"<span class='move-annotation'>w</span>";
            default:
            break;
    }
    return nag;
}


+ (NSString *) symbolToNag:(NSString *)symbol {
    return nil;
}


+ (NSString *) moveWithLetterToMoveWithSymbol:(NSString *)moveWithLetter {
    NSString *moveWithSymbol = [moveWithLetter stringByReplacingOccurrencesOfString:@"N" withString:whiteKnightSymbol];
    moveWithSymbol = [moveWithSymbol stringByReplacingOccurrencesOfString:@"B" withString:whiteBishopSymbol];
    moveWithSymbol = [moveWithSymbol stringByReplacingOccurrencesOfString:@"R" withString:whiteRookSymbol];
    moveWithSymbol = [moveWithSymbol stringByReplacingOccurrencesOfString:@"Q" withString:whiteQueenSymbol];
    moveWithSymbol = [moveWithSymbol stringByReplacingOccurrencesOfString:@"K" withString:whiteKingSymbol];
    return moveWithSymbol;
}


+ (NSString *) getMossaEvidenziata {
    return @"<span class='ultima'  ID='mossaevidenziata' >";
}

+ (NSString *) getMossaLinkApri {
    return @"<a class='mossalink' href=\"";
}

+ (NSString *) getMossaLinkChiudi {
    return @"</a>";
}

+ (NSString *) getMossaLinkChiudiAngolare {
    return @"\">";
}

+ (NSString *) getMossaLinkChiudiSpan {
    return @"</span>";
}


+ (NSString *) nagToSymbolForAttributedTextMoves:(NSString *)nag { //ISChess Font
    NSUInteger nagNumber = 0;
    if ([nag hasPrefix:@"$"]) {
        nagNumber = [[nag substringFromIndex:1] integerValue];
    }
    else {
        nagNumber = [nag integerValue];
    }
    switch (nagNumber) {
        case 0:
            return @"";
        case 1:
            return@"]";
        case 2:
            return @"_";
        case 3:
            return @"^";
        case 4:
            return @"\u0060";
        case 5:
            return @"a";
        case 6:
            return @"b";
        case 7:
        case 8:
            return @"d";
            return @"\u2122";
        case 10:
        case 11:
        case 12:
            return @"S";
        case 13:
            return @"T";
        case 14:
            return @"M";
        case 15:
            return @"N";
        case 16:
            return @"O";
        case 17:
            return @"P";
        case 18:
            return @"Q";
        case 19:
            return @"R";
        case 22:
            return @"[";
        case 23:
            return @"[";
        case 32:
            return @"V";
        case 33:
            return @"V";
        case 36:
            return @"X";
        case 40:
            return @"Y";
        case 44:
            return @"U";
        case 132:
            return @"Z";
        case 138:
            return @"\u2020";
        case 140:
            return @"\u2206";
        case 142:
            return @"e";
        case 145:
            return @"RR";
        case 146:
            return @"9";
        case 239:
            return @"f";
        case 240:
            return @"g";
        case 241:
            return @"h";
        case 242:
            return @"i";
        case 243:
            return @"j";
        case 245:
            return @"l";
        case 246:
            return @"m";
        case 247:
            return @"n";
        case 248:
            return @"o";
        case 249:
            return @"p";
        case 250:
            return @"q";
        case 251:
            return @"r";
        case 252:
            return @"s";
        case 253:
            return @"t";
        case 254:
            return @"v";
        case 255:
            return @"w";
        default:
            break;
    }
    return @"";
}

@end
