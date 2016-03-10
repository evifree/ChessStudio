//
//  UtilToView.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 22/04/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "UtilToView.h"
#import <sys/utsname.h>

#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UtilToView

#define A 0xA4D40E
#define B 0xFCF204
#define C 0x3DADDF
#define D 0xD70302
#define E 0xFA8801


+ (CGSize) getSizeOfMBProgress {
    if (IS_PAD) {
        return CGSizeMake(250, 150);
    }
    return CGSizeMake(150, 100);
}

+ (UIStoryboard *) getStoryBoard {
    if (IS_PAD) {
        return [UIStoryboard storyboardWithName:@"iPad" bundle:[NSBundle mainBundle]];
    }
    return [UIStoryboard storyboardWithName:@"iPhone" bundle:[NSBundle mainBundle]];
}

+ (NSString *)machine {
    NSString *machine;
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *name = malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    machine = [NSString stringWithUTF8String:name];
    free(name);
    return machine;
}

+ (NSString *) deviceModelName {
    /*
     @"i386"      on the simulator
     @"iPod1,1"   on iPod Touch
     @"iPod2,1"   on iPod Touch Second Generation
     @"iPod3,1"   on iPod Touch Third Generation
     @"iPod4,1"   on iPod Touch Fourth Generation
     @"iPhone1,1" on iPhone
     @"iPhone1,2" on iPhone 3G
     @"iPhone2,1" on iPhone 3GS
     @"iPad1,1"   on iPad
     @"iPad2,1"   on iPad 2
     @"iPhone3,1" on iPhone 4
     @"iPhone4,1" on iPhone 4S
     @"iPhone5,1" on iPhone 5
     */
    
    struct utsname systemInfo;
    NSString *modelName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if([modelName isEqualToString:@"i386"]) {
        modelName = @"iPhone Simulator";
    }
    else if([modelName isEqualToString:@"iPhone1,1"]) {
        modelName = @"iPhone";
    }
    else if([modelName isEqualToString:@"iPhone1,2"]) {
        modelName = @"iPhone 3G";
    }
    else if([modelName isEqualToString:@"iPhone2,1"]) {
        modelName = @"iPhone 3GS";
    }
    else if([modelName isEqualToString:@"iPhone3,1"]) {
        modelName = @"iPhone 4";
    }
    else if([modelName isEqualToString:@"iPhone4,1"]) {
        modelName = @"iPhone 4S";
    }
    else if([modelName isEqualToString:@"iPhone5,1"]) {
        modelName = @"iPhone 5";
    }
    else if([modelName isEqualToString:@"iPod1,1"]) {
        modelName = @"iPod 1st Gen";
    }
    else if([modelName isEqualToString:@"iPod2,1"]) {
        modelName = @"iPod 2nd Gen";
    }
    else if([modelName isEqualToString:@"iPod3,1"]) {
        modelName = @"iPod 3rd Gen";
    }
    else if([modelName isEqualToString:@"iPad1,1"]) {
        modelName = @"iPad";
    }
    else if([modelName isEqualToString:@"iPad2,1"]) {
        modelName = @"iPad 2(WiFi)";
    }
    else if([modelName isEqualToString:@"iPad2,2"]) {
        modelName = @"iPad 2(GSM)";
    }
    else if([modelName isEqualToString:@"iPad2,3"]) {
        modelName = @"iPad 2(CDMA)";
    }
    else if([modelName isEqualToString:@"iPad2,4"]) {
        modelName = @"iPad 2(WiFi + New Chip)";
    }
    else if([modelName isEqualToString:@"iPad2,5"]) {
        modelName = @"iPad mini (WiFi)";
    }
    else if([modelName isEqualToString:@"iPad2,6"]) {
        modelName = @"iPad mini (GSM)";
    }
    
    return modelName;
}

+ (NSArray *) getTipoPezziArray {
    return [NSArray arrayWithObjects:@"Zurich", @"Linares", @"Hastings", @"Condal", @"Adventurer", nil];
}

+ (NSArray *) getTipoCoordinate {
    //return [NSArray arrayWithObjects:@"No Coordinates", @"Algebric", @"Numeric", @"Development", nil];
    return [NSArray arrayWithObjects:NSLocalizedString(@"NO_COORDINATES", nil), NSLocalizedString(@"ALGEBRAIC", nil), NSLocalizedString(@"NUMERIC", nil), NSLocalizedString(@"DEVELOPMENT", nil), NSLocalizedString(@"EDGE", nil), nil];
}

+ (NSArray *) getTipoSquares {
    return [NSArray arrayWithObjects:@"square1", @"square3", @"square5", @"square4", @"square2", @"square6", @"square7", @"square8", @"square9", @"square10", nil];
}

+ (NSArray *) getTipoNotation {
    //return [NSArray arrayWithObjects:@"Simboli", @"Lettere", nil];
    return [NSArray arrayWithObjects:NSLocalizedString(@"LETTER", nil), NSLocalizedString(@"FIGURINE", nil), nil];
}

+ (NSArray *) getVistaMotore {
    return [NSArray arrayWithObjects:NSLocalizedString(@"ENGINE_VIEW_OPEN", nil), NSLocalizedString(@"ENGINE_VIEW_CLOSED", nil), nil];
}

+ (NSArray *) getTipoBoardSize {
    return [NSArray arrayWithObjects:NSLocalizedString(@"SMALL", nil), NSLocalizedString(@"MEDIUM", nil), NSLocalizedString(@"BIG", nil), nil];
}

+ (NSArray *) getSevenTagRoster {
    return [NSArray arrayWithObjects:@"Event", @"Site", @"Date", @"Round", @"White", @"Black", @"Result", nil];
}

+ (NSArray *) getEngines {
    return [NSArray arrayWithObjects:@"Stockfish", NSLocalizedString(@"ENGINE_NOTATION", nil), NSLocalizedString(@"ENGINE_PLAY_STYLE", nil), NSLocalizedString(@"ENGINE_STRENGTH", nil), nil];
}

+ (NSString *) getTagRosterByIndex:(NSUInteger)index {
    if (index == 0) {
        return @"Event";
    }
    else if (index == 1) {
        return @"Site";
    }
    else if (index == 2) {
        return @"Date";
    }
    else if (index == 3) {
        return @"Round";
    }
    else if (index == 4) {
        return @"White";
    }
    else if (index == 5) {
        return @"Black";
    }
    else if (index == 6) {
        return @"Result";
    }
    return nil;
}

+ (NSString *) getTagRosterDefaultValueByIndex:(NSUInteger)index {
    if (index == 0) {
        return @"?";
    }
    else if (index == 1) {
        return @"?";
    }
    else if (index == 2) {
        return @"????.??.??";
    }
    else if (index == 3) {
        return @"?";
    }
    else if (index == 4) {
        return @"?";
    }
    else if (index == 5) {
        return @"?";
    }
    else if (index == 6) {
        return @"*";
    }
    return nil;
}

+ (NSArray *) getResultsArray {
    return [NSArray arrayWithObjects:@"1-0", @"0-1", @"1/2-1/2", @"*", nil];
}

+ (NSArray *) getAdditionalTagArray {
    return [NSArray arrayWithObjects:@"Title", @"Elo", @"ECO", @"Opening", @"Variation", @"SubVariation", @"FideId", @"EventDate", nil];
    return [NSArray arrayWithObjects:@"WhiteTitle", @"BlackTitle", @"WhiteElo", @"BlackElo", @"ECO", @"Opening", @"Variation", @"SubVariation", @"WhiteFideId", @"BlackFideId", @"EventDate", nil];
}

+ (NSArray *) getAdditionalTagSection {
    return [NSArray arrayWithObjects:@"Player", @"Event", @"Opening", nil];
}

+ (NSDictionary *) getAdditionalTagSectionValues {
    NSArray *playerTag = [NSArray arrayWithObjects:@"Title", @"Elo", @"FideId", nil];
    NSArray *eventTag = [NSArray arrayWithObjects:@"EventDate", nil];
    NSArray *openingTags = [NSArray arrayWithObjects:@"ECO", @"Opening", @"Variation", @"SubVariation", nil];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:playerTag forKey:@"Player"];
    [dictionary setObject:eventTag forKey:@"Event"];
    [dictionary setObject:openingTags forKey:@"Opening"];
    return dictionary;
}

+ (NSDictionary *) getSupplementalTagSectionValues {
    NSArray *playerTag = [NSArray arrayWithObjects:@"WhiteTitle", @"BlackTitle", @"WhiteElo", @"BlackElo", @"WhiteFideId", @"BlackFideId", nil];
    NSArray *eventTag = [NSArray arrayWithObjects:@"EventDate", nil];
    NSArray *openingTags = [NSArray arrayWithObjects:@"ECO", @"Opening", @"Variation", @"SubVariation", nil];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:playerTag forKey:@"Player"];
    [dictionary setObject:eventTag forKey:@"Event"];
    [dictionary setObject:openingTags forKey:@"Opening"];
    return dictionary;
}

+ (NSArray *) getSupplementalTagValues {
    NSArray *suppTagValues = [NSArray arrayWithObjects:@"WhiteTitle", @"BlackTitle", @"WhiteElo", @"BlackElo", @"WhiteFideId", @"BlackFideId", @"EventDate", @"ECO", @"Opening", @"Variation", @"SubVariation", nil];
    return suppTagValues;
}

+ (NSArray *) getTitleArray {
    return [NSArray arrayWithObjects:/*@"CM",*/ @"FM", @"IM", @"GM", /*@"WCM",*/ @"WFM", @"WIM", @"WGM", nil];
}

+ (NSArray *) getEcoLetterArray {
    return [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", nil];
}

+ (NSArray *) getEcoNumberArray {
    return [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
}


+ (NSArray *) getMoveAnnotationText {
    return [NSArray arrayWithObjects:NSLocalizedString(@"NO_MOVE_ANNOTATION", nil), NSLocalizedString(@"A_VERY_GOOD_MOVE", nil), NSLocalizedString(@"A_MISTAKE", nil), NSLocalizedString(@"EXCELLENT_MOVE", nil), NSLocalizedString(@"BLUNDER", nil), NSLocalizedString(@"MOVE_DESERVING_ATTENTION", nil), NSLocalizedString(@"DUBIOUS_MOVE", nil), NSLocalizedString(@"ONLY_MOVE", nil), NSLocalizedString(@"NOVELTY", nil), nil];
    
}

+ (NSArray *) getMoveAnnotationImage {
    return [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"146", nil];
}

+ (NSArray *) getPositionAnnotationText {
    return [NSArray arrayWithObjects:@"No position annotation", @"White stands slightly better", @"Black stands slightly better", @"White has the upper hand", @"Black has the upper hand", @"White has a decisive advantage", @"Black has a decisive advantage", @"Even", @"Unclear", @"With compensation for the material", @"Development advantage", nil];
}

+ (NSArray *) getPositionAnnotationImage {
    return [NSArray arrayWithObjects:@"0", @"14", @"15", @"16", @"17", @"18", @"19", @"10", @"13", @"44", @"32", nil];
}

+ (NSArray *) getPrefixAnnotationText {
    return [NSArray arrayWithObjects:@"No move prefix", @"Better is", nil];
}

+ (NSArray *) getPrefixAnnotationImage {
    return [NSArray arrayWithObjects:@"0", @"142", nil];
}

+ (UIColor *) getEcoColor:(NSString *)ecoCode {
    if ([ecoCode hasPrefix:@"A"]) {
        //return UIColorFromRGB(0xD3E0A8);
        return UIColorFromRGB(A);
    }
    else if ([ecoCode hasPrefix:@"B"]) {
        //return UIColorFromRGB(0xFDFCAC);
        return UIColorFromRGB(B);
    }
    else if ([ecoCode hasPrefix:@"C"]) {
        //return UIColorFromRGB(0xC4E2EC);
        return UIColorFromRGB(C);
    }
    else if ([ecoCode hasPrefix:@"D"]) {
        //return UIColorFromRGB(0xE9BFC0);
        return UIColorFromRGB(D);
    }
    else if ([ecoCode hasPrefix:@"E"]) {
        //return UIColorFromRGB(0xE9DBAA);
        return UIColorFromRGB(E);
    }
    else if ([ecoCode hasPrefix:@"0"]) {
        return [UIColor whiteColor];
    }
    return [UIColor clearColor];
}

+ (CGRect) getRectByDevice {
    if (IS_PAD) {
        if (IS_PORTRAIT) {
            return CGRectMake(0, 0, 768, 1024);
        }
        else {
            return CGRectMake(0, 0, 1024, 768);
        }
    }
    else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            return CGRectMake(0, 0, 320, 568);
        }
        else {
            return CGRectMake(0, 0, 568, 320);
        }
    }
    else if (IS_PHONE) {
        if (IS_PORTRAIT) {
            return CGRectMake(0, 0, 320, 480);
        }
        else {
            return CGRectMake(0, 0, 480, 320);
        }
    }
    return CGRectZero;
}

#pragma mark - Metodo utilizzato nel setup delle posizioni da SetupPositionView

+ (NSString *) getPieceSetupPositionByNumber:(NSInteger)squareNumber {
    if (squareNumber==0) {
        return @"bk";
    }
    else if (squareNumber==1) {
        return @"bq";
    }
    else if (squareNumber==2) {
        return @"br";
    }
    else if (squareNumber==3) {
        return @"bb";
    }
    else if (squareNumber==4) {
        return @"bn";
    }
    else if (squareNumber==5) {
        return @"bp";
    }
    else if (squareNumber==6) {
        return @"wk";
    }
    else if (squareNumber==7) {
        return @"wq";
    }
    else if (squareNumber==8) {
        return @"wr";
    }
    else if (squareNumber==9) {
        return @"wb";
    }
    else if (squareNumber==10) {
        return @"wn";
    }
    else if (squareNumber==11) {
        return @"wp";
    }
    return @"";
}

#pragma mark - Metodi per recuperare i valori impostati per quanto riguarda il tipo pezzi, caselle etc.

+ (NSString *) getPieceType {
    NSString *pieceType = [[NSUserDefaults standardUserDefaults] stringForKey:@"pieces"];
    if (!pieceType) {
        //NSLog(@"Nessun tipo pezzo salvato");
        pieceType = @"zur96";
        //NSDictionary *defaults = [NSDictionary dictionaryWithObject:pieceType forKey:@"pieces"];
        //[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    }
    return pieceType;
}

+ (NSString *) getSquareType {
    NSString *squareType = [[NSUserDefaults standardUserDefaults] stringForKey:@"squares"];
    if (!squareType) {
        squareType = @"square5";
        //NSDictionary *defaults = [NSDictionary dictionaryWithObject:squares forKey:@"squares"];
        //[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    }
    return squareType;
}

+ (UIImage *) getDarkImageForSquare:(NSString *)squareType {
    if (!squareType) {
        squareType = [self getSquareType];
    }
    if ([squareType hasPrefix:@"square1"]) {
        return [UIImage imageNamed:@"BlackSquare96.png"];
    }
    else if ([squareType hasPrefix:@"square2"]) {
        return [UIImage imageNamed:@"BlackMarmo.png"];
    }
    else if ([squareType hasPrefix:@"square3"]) {
        return [UIImage imageNamed:@"BlackWood2.png"];
    }
    else if ([squareType hasPrefix:@"square4"]) {
        return [UIImage imageNamed:@"BlackTexture.png"];
    }
    else if ([squareType hasPrefix:@"square5"]) {
        return [UIImage imageNamed:@"BlackWood3.png"];
    }
    return nil;
}

+ (UIImage *) getLightImageForSquare:(NSString *)squareType {
    if (!squareType) {
        squareType = [self getSquareType];
    }
    if ([squareType hasPrefix:@"square1"]) {
        return [UIImage imageNamed:@"WhiteSquare96.png"];
    }
    else if ([squareType hasPrefix:@"square2"]) {
        return [UIImage imageNamed:@"WhiteMarmo.png"];
    }
    else if ([squareType hasPrefix:@"square3"]) {
        return [UIImage imageNamed:@"WhiteWood2.png"];
    }
    else if ([squareType hasPrefix:@"square4"]) {
        return [UIImage imageNamed:@"WhiteTexture.png"];
    }
    else if ([squareType hasPrefix:@"square5"]) {
        return [UIImage imageNamed:@"WhiteWood3.png"];
    }
    return nil;
}

#pragma mark - Metodi per recuperare le dimensioni dei frame pr le varie necessità

+ (CGRect) getPadPortraitEngineViewFrame {
    if (IS_PAD_PRO) {
        return CGRectMake(0.0, 1220.0, 1024.0, 38.0);
    }
    return CGRectMake(0.0, 879.0, 768.0, 38.0);
}

+ (CGRect) getPadPortraitMovesFrameWithEngine {
    return CGRectMake(0.0, 768.0, 768.0, 110.0);
    //return CGRectMake(0.0, 768.0, 768.0, 112.0);
}

+ (CGRect) getPadPortraitMovesFrameWithoutEngine {
    return CGRectMake(0.0, 768.0, 768.0, 148.0);
}

+ (CGRect) getPadPortraitEngineFrame {
    //return CGRectMake(0.0, 898.0, 768.0, 18.0);
    return CGRectMake(0.0, 898.0, 490.0, 19.0);
}

+ (CGRect) getPadPortraitStatsEngineFrame {
    return CGRectMake(490.0, 898.0, 278.0, 19.0);
}

+ (CGRect) getPhone5PortraitEngineViewFrame {
    return CGRectMake(0.0, 0.0, 0.0, 0.0);
}

#pragma mark - Metodi per gestire i tag

+ (NSArray *) getOrderedSevenTags {
    return [NSArray arrayWithObjects: @"Event",@"Site", @"Date", @"Round", @"White", @"Black", @"Result",  nil];
}

+ (NSArray *) getOrderedSuppTags {
    return [NSArray arrayWithObjects:@"WhiteTitle", @"BlackTitle", @"WhiteElo", @"BlackElo", @"WhiteFideId", @"BlackFideId", @"EventDate", @"ECO", @"Opening", @"Variation", @"SubVariation", nil];
}

+ (NSArray *) getPositionTags {
    return [NSArray arrayWithObjects: @"SetUp", @"FEN", nil];
}

@end
