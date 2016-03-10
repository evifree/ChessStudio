//
//  PGNUtil.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 22/04/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGNUtil : NSObject


+ (NSString *) nagToSymbol:(NSString *)nag;
+ (NSString *) nagToSymbolForGameMovesWebView:(NSString *)nag;
+ (NSString *) symbolToNag:(NSString *)symbol;
+ (NSString *) moveWithLetterToMoveWithSymbol:(NSString *)moveWithLetter;

+ (NSString *) getMossaEvidenziata;
+ (NSString *) getMossaLinkApri;
+ (NSString *) getMossaLinkChiudi;
+ (NSString *) getMossaLinkChiudiAngolare;
+ (NSString *) getMossaLinkChiudiSpan;

+ (NSString *) nagToSymbolForAttributedTextMoves:(NSString *)nag;

@end
