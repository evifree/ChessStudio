/*
  Stockfish, a chess program for iOS.
  Copyright (C) 2004-2013 Tord Romstad, Marco Costalba, Joona Kiiski.

  Stockfish is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Stockfish is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "Options.h"


@implementation Options

@synthesize darkSquareColor, lightSquareColor, highlightColor, selectedSquareColor;
@synthesize darkSquareImage, lightSquareImage;
@dynamic colorScheme, pieceSet, figurineNotation;
@dynamic playStyle, bookVariety, bookVarietyWasChanged, moveSound;
@dynamic showAnalysis, showBookMoves, showLegalMoves, permanentBrain, showCoordinates;
@dynamic gameMode, gameLevel, gameModeWasChanged, gameLevelWasChanged;
@dynamic saveGameFile, emailAddress, fullUserName;
@dynamic displayMoveGestureStepForwardHint, displayMoveGestureTakebackHint;
@dynamic playStyleWasChanged, strength, strengthWasChanged;
@dynamic serverName, serverPort;
@dynamic loadGameFile, loadGameFileGameNumber;
@dynamic displayGameListSearchFieldHint, displayGamePreviewSwipingHint;

- (id)init {
   if (self = [super init]) {
       
       NSLog(@"Inizializzo Options");
       
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

      loadGameFile = [defaults objectForKey: @"loadGameFile"];
      if (!loadGameFile) {
         loadGameFile = [@"" retain];
      }
      loadGameFileGameNumber = (int)[defaults integerForKey: @"loadGameFileGameNumber"];
      if (!loadGameFileGameNumber) {
         loadGameFileGameNumber = 0;
      }
      if (![defaults objectForKey: @"showAnalysis2"]) {
         showAnalysis = YES;
         [defaults setBool: YES forKey: @"showAnalysis2"];
      }
      else
         showAnalysis = [defaults boolForKey: @"showAnalysis2"];

      if (![defaults objectForKey: @"showBookMoves2"]) {
         showBookMoves = YES;
         [defaults setBool: YES forKey: @"showBookMoves2"];
      }
      else
         showBookMoves = [defaults boolForKey: @"showBookMoves2"];

      if (![defaults objectForKey: @"showLegalMoves2"]) {
         showLegalMoves = YES;
         [defaults setBool: YES forKey: @"showLegalMoves2"];
      }
      else
         showLegalMoves = [defaults boolForKey: @"showLegalMoves2"];

      if (![defaults objectForKey: @"showCoordinates"]) {
         showCoordinates = YES;
         [defaults setBool: YES forKey: @"showCoordinates"];
      }
      else
         showCoordinates = [defaults boolForKey: @"showCoordinates"];

      if (![defaults objectForKey: @"permanentBrain2"]) {
         permanentBrain = NO;
         [defaults setBool: NO forKey: @"permanentBrain2"];
      }
      else
         permanentBrain = [defaults boolForKey: @"permanentBrain2"];

      pieceSet = [defaults objectForKey: @"pieceSet4"];
      if (!pieceSet) {
         // For some reason, I prefer the Leipzig pieces on the iPhone,
         // but Alpha on the iPad.
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            pieceSet = [@"Alpha" retain];
            [defaults setObject: @"Alpha" forKey: @"pieceSet4"];
         }
         else {
            pieceSet = [@"Leipzig" retain];
            [defaults setObject: @"Leipzig" forKey: @"pieceSet4"];
         }
      }

      playStyle = [defaults objectForKey: @"playStyle3"];
      if (!playStyle) {
         playStyle = [@"Active" retain];
         [defaults setObject: @"Active" forKey: @"playStyle3"];
      }

      bookVariety = [defaults objectForKey: @"bookVariety2"];
      if (!bookVariety) {
         bookVariety = [@"Medium" retain];
         [defaults setObject: @"Medium" forKey: @"bookVariety2"];
      }

      if (![defaults objectForKey: @"moveSound"]) {
         moveSound = YES;
         [defaults setBool: YES forKey: @"moveSound"];
      }
      else
         moveSound = [defaults boolForKey: @"moveSound"];

      if (![defaults objectForKey: @"figurineNotation2"]) {
         figurineNotation = NO;
         [defaults setBool: NO forKey: @"figurineNotation2"];
      }
      else
         figurineNotation = [defaults boolForKey: @"figurineNotation2"];

      colorScheme = [defaults objectForKey: @"colorScheme3"];
      if (!colorScheme) {
         colorScheme = [@"Green" retain];
         [defaults setObject: @"Green" forKey: @"colorScheme3"];
      }
      darkSquareColor = lightSquareColor = highlightColor = selectedSquareColor = nil;
      [self updateColors];

      gameMode = GAME_MODE_COMPUTER_BLACK;
      gameLevel = LEVEL_GAME_IN_5;
      gameModeWasChanged = NO;
      gameLevelWasChanged = NO;
      playStyleWasChanged = NO;
      strengthWasChanged = NO;

      saveGameFile = [defaults objectForKey: @"saveGameFile2"];
      if (!saveGameFile) {
         saveGameFile = [@"My games.pgn" retain];
         [defaults setObject: @"My Games.pgn" forKey: @"saveGameFile2"];
      }

      emailAddress = [defaults objectForKey: @"emailAddress2"];
      if (!emailAddress) {
         emailAddress = [@"" retain];
         [defaults setObject: @"" forKey: @"emailAddress2"];
      }

      fullUserName = [defaults objectForKey: @"fullUserName2"];
      if (!fullUserName) {
         fullUserName = [@"Me" retain];
         [defaults setObject: @"Me" forKey: @"fullUserName2"];
      }

      strength = (int)[defaults integerForKey: @"Elo5"];
      if (!strength) {
         strength = 1600;
         [defaults setInteger: 1600 forKey: @"Elo5"];
      }

      NSString *tmp = [defaults objectForKey: @"displayMoveGestureTakebackHint2"];
      if (!tmp) {
         [defaults setObject: @"YES"
                      forKey: @"displayMoveGestureTakebackHint2"];
         displayMoveGestureTakebackHint = YES;
      }
      else if ([tmp isEqualToString: @"YES"])
         displayMoveGestureTakebackHint = YES;
      else
         displayMoveGestureTakebackHint = NO;

      tmp = [defaults objectForKey: @"displayMoveGestureStepForwardHint2"];
      if (!tmp) {
         [defaults setObject: @"YES"
                      forKey: @"displayMoveGestureStepForwardHint2"];
         displayMoveGestureStepForwardHint = YES;
      }
      else if ([tmp isEqualToString: @"YES"])
         displayMoveGestureStepForwardHint = YES;
      else
         displayMoveGestureStepForwardHint = NO;

      serverName = [defaults objectForKey: @"serverName2"];
      if (!serverName) {
         serverName = [@"" retain];
         [defaults setObject: @"" forKey: @"serverName2"];
      }

      serverPort = (int)[defaults integerForKey: @"serverPort2"];
      if (!serverPort) {
         serverPort = 1685;
         [defaults setInteger: 1685 forKey: @"serverPort2"];
      }
      
      tmp = [defaults objectForKey: @"displayGameListSearchFieldHint"];
      if (!tmp) {
         [defaults setObject: @"YES"
                      forKey: @"displayGameListSearchFieldHint"];
         displayGameListSearchFieldHint = YES;
      }
      else if ([tmp isEqualToString: @"YES"])
         displayGameListSearchFieldHint = YES;
      else
         displayGameListSearchFieldHint = NO;
      
      tmp = [defaults objectForKey: @"displayGamePreviewSwipingHint"];
      if (!tmp) {
         [defaults setObject: @"YES"
                      forKey: @"displayGamePreviewSwipingHint"];
         displayGamePreviewSwipingHint = YES;
      }
      else if ([tmp isEqualToString: @"YES"])
         displayGamePreviewSwipingHint = YES;
      else
         displayGamePreviewSwipingHint = NO;

      [defaults synchronize];
   }
   return self;
}


- (UIColor *)darkSquareColorForColorScheme:(NSString *)scheme {
   if ([scheme isEqualToString: @"Blue"])
      return [UIColor colorWithRed: 0.2 green: 0.4 blue: 0.7 alpha: 1.0];
   else if ([scheme isEqualToString: @"Gray"])
      return [UIColor colorWithRed: 0.5 green: 0.5 blue: 0.5 alpha: 1.0];
   else if ([scheme isEqualToString: @"Red"])
      return [UIColor colorWithRed: 0.6 green: 0.28 blue: 0.28 alpha: 1.0];
   else // Default, brown
      return [UIColor colorWithRed: 0.625 green: 0.32 blue: 0.176 alpha: 1.0];
}


- (UIColor *)lightSquareColorForColorScheme:(NSString *)scheme {
   if ([scheme isEqualToString: @"Blue"])
      return [UIColor colorWithRed: 0.69 green: 0.78 blue: 1.0 alpha: 1.0];
   else if ([scheme isEqualToString: @"Gray"])
      return [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 1.0];
   else if ([scheme isEqualToString: @"Red"])
      return [UIColor colorWithRed: 1.0 green: 0.8 blue: 0.8 alpha: 1.0];
   else // Default, brown
      return [UIColor colorWithRed: 0.867 green: 0.719 blue: 0.527 alpha: 1.0];
}


- (UIImage *)darkSquareImageForColorScheme:(NSString *)scheme large:(BOOL)large {
   if (large) {
      if ([scheme isEqualToString: @"Green"])
         return [UIImage imageNamed: @"DarkGreenMarble96.png"];
      else if ([scheme isEqualToString: @"Wood"])
         return [UIImage imageNamed: @"DarkWood96.png"];
      else if ([scheme isEqualToString: @"Marble"])
         return [UIImage imageNamed: @"DarkMarble96.png"];
      else if ([scheme isEqualToString: @"Newspaper"])
         return [UIImage imageNamed: @"DarkNewspaper96.png"];
      else
         return nil;
   } else {
      if ([scheme isEqualToString: @"Green"])
         return [UIImage imageNamed: @"DarkGreenMarble.png"];
      else if ([scheme isEqualToString: @"Wood"])
         return [UIImage imageNamed: @"DarkWood.png"];
      else if ([scheme isEqualToString: @"Marble"])
         return [UIImage imageNamed: @"DarkMarble.png"];
      else if ([scheme isEqualToString: @"Newspaper"])
         return [UIImage imageNamed: @"DarkNewspaper.png"];
      else
         return nil;
   }
}


- (UIImage *)lightSquareImageForColorScheme:(NSString *)scheme large:(BOOL)large {
   if (large) {
      if ([scheme isEqualToString: @"Green"])
         return [UIImage imageNamed: @"LightGreenMarble96.png"];
      else if ([scheme isEqualToString: @"Wood"])
         return [UIImage imageNamed: @"LightWood96.png"];
      else if ([scheme isEqualToString: @"Marble"])
         return [UIImage imageNamed: @"LightMarble96.png"];
      else if ([scheme isEqualToString: @"Newspaper"])
         return [UIImage imageNamed: @"LightNewspaper96.png"];
      else
         return nil;
   } else {
      if ([scheme isEqualToString: @"Green"])
         return [UIImage imageNamed: @"LightGreenMarble.png"];
      else if ([scheme isEqualToString: @"Wood"])
         return [UIImage imageNamed: @"LightWood.png"];
      else if ([scheme isEqualToString: @"Marble"])
         return [UIImage imageNamed: @"LightMarble.png"];
      else if ([scheme isEqualToString: @"Newspaper"])
         return [UIImage imageNamed: @"LightNewspaper.png"];
      else
         return nil;
   }
}


- (UIColor *)highlightColorForColorScheme:(NSString *)scheme {
   if ([scheme isEqualToString: @"Blue"])
      return [UIColor purpleColor];
   else
      return [UIColor blueColor];
}


- (UIColor *)selectedSquareColorForColorScheme:(NSString *)scheme {
   if ([scheme isEqualToString: @"Marble"])
      return [UIColor colorWithRed: 0.75 green: 0.9 blue: 0.75 alpha: 0.5];
   else if ([scheme isEqualToString: @"Newspaper"])
      return [UIColor colorWithRed: 0.2 green: 0.6 blue: 1.0 alpha: 0.4];
   else
      return [UIColor colorWithRed: 0.7 green: 1.0 blue: 1.0 alpha: 0.4];
}



- (void)updateColors {
   [darkSquareColor release];
   [lightSquareColor release];
   [highlightColor release];
   [selectedSquareColor release];
   [darkSquareImage release]; darkSquareImage = nil;
   [lightSquareImage release]; lightSquareImage = nil;
   
   BOOL large = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
   
   darkSquareColor = [[self darkSquareColorForColorScheme: colorScheme] retain];
   lightSquareColor = [[self lightSquareColorForColorScheme: colorScheme] retain];
   highlightColor = [[self highlightColorForColorScheme: colorScheme] retain];
   selectedSquareColor = [[self selectedSquareColorForColorScheme: colorScheme]
                          retain];
   darkSquareImage = [[self darkSquareImageForColorScheme: colorScheme
                                                    large: large] retain];
   lightSquareImage = [[self lightSquareImageForColorScheme: colorScheme
                                                      large: large] retain];

   // Post a notification about the new colors, in order to make the board
   // update itself:
   [[NSNotificationCenter defaultCenter]
    postNotificationName: @"StockfishColorSchemeChanged"
    object: self];

   return;
}


- (NSString *)colorScheme {
   return colorScheme;
}


- (void)setColorScheme:(NSString *)newColorScheme {
   [colorScheme release];
   colorScheme = [newColorScheme retain];
   [[NSUserDefaults standardUserDefaults] setObject: newColorScheme
                                             forKey: @"colorScheme3"];
   [[NSUserDefaults standardUserDefaults] synchronize];
   [[NSNotificationCenter defaultCenter]
      postNotificationName: @"StockfishPieceSetChanged"
                    object: self];
   [self updateColors];
}


- (BOOL)figurineNotation {
   return figurineNotation;
}


- (void)setFigurineNotation:(BOOL)newValue {
   figurineNotation = newValue;
   [[NSUserDefaults standardUserDefaults] setBool: figurineNotation forKey: @"figurineNotation2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)moveSound {
   return moveSound;
}


- (void)setMoveSound:(BOOL)newValue {
   moveSound = newValue;
   [[NSUserDefaults standardUserDefaults] setBool: moveSound
                                           forKey: @"moveSound"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)pieceSet {
   return pieceSet;
}


- (void)setPieceSet:(NSString *)newPieceSet {
   [pieceSet release];
   pieceSet = [newPieceSet retain];
   [[NSUserDefaults standardUserDefaults] setObject: newPieceSet
                                             forKey: @"pieceSet4"];
   [[NSUserDefaults standardUserDefaults] synchronize];
   [[NSNotificationCenter defaultCenter]
      postNotificationName: @"StockfishPieceSetChanged"
                    object: self];
}


- (NSString *)playStyle {
   return playStyle;
}


- (void)setPlayStyle:(NSString *)newPlayStyle {
   [playStyle release];
   playStyle = [newPlayStyle retain];
   playStyleWasChanged = YES;
   [[NSUserDefaults standardUserDefaults] setObject: newPlayStyle
                                             forKey: @"playStyle3"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)playStyleWasChanged {
   BOOL result = playStyleWasChanged;
   playStyleWasChanged = NO;
   return result;
}


- (NSString *)bookVariety {
   return bookVariety;
}


- (void)setBookVariety:(NSString *)newBookVariety {
   [bookVariety release];
   bookVariety = [newBookVariety retain];
   bookVarietyWasChanged = YES;
   [[NSUserDefaults standardUserDefaults] setObject: newBookVariety
                                             forKey: @"bookVariety2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)bookVarietyWasChanged {
   BOOL result = bookVarietyWasChanged;
   bookVarietyWasChanged = NO;
   return result;
}


- (BOOL)showAnalysis {
   return showAnalysis;
}


- (void)setShowAnalysis:(BOOL)shouldShowAnalysis {
   showAnalysis = shouldShowAnalysis;
   [[NSUserDefaults standardUserDefaults] setBool: showAnalysis
                                           forKey: @"showAnalysis2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)showBookMoves {
   return showBookMoves;
}


- (void)setShowBookMoves:(BOOL)shouldShowBookMoves {
   showBookMoves = shouldShowBookMoves;
   [[NSUserDefaults standardUserDefaults] setBool: showBookMoves
                                           forKey: @"showBookMoves2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)showLegalMoves {
   return showLegalMoves;
}


- (void)setShowLegalMoves:(BOOL)shouldShowLegalMoves {
   showLegalMoves = shouldShowLegalMoves;
   [[NSUserDefaults standardUserDefaults] setBool: showLegalMoves
                                           forKey: @"showLegalMoves2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)showCoordinates {
   return showCoordinates;
}


- (void)setShowCoordinates:(BOOL)shouldShowCoordinates {
   showCoordinates = shouldShowCoordinates;
   [[NSUserDefaults standardUserDefaults] setBool: showCoordinates
                                           forKey: @"showCoordinates"];
   [[NSUserDefaults standardUserDefaults] synchronize];
   [[NSNotificationCenter defaultCenter]
      postNotificationName: @"StockfishShowCoordinatesChanged"
                    object: self];
}


- (BOOL)permanentBrain {
   return permanentBrain;
}


- (void)setPermanentBrain:(BOOL)shouldUsePermanentBrain {
   permanentBrain = shouldUsePermanentBrain;
   [[NSUserDefaults standardUserDefaults] setBool: permanentBrain
                                           forKey: @"permanentBrain2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)dealloc {
   //[darkSquareColor release];
   //[lightSquareColor release];
   //[highlightColor release];
   [darkSquareImage release];
   [lightSquareImage release];
   [colorScheme release];
   [playStyle release];
   [bookVariety release];
   [pieceSet release];
   [saveGameFile release];
   [emailAddress release];
   [fullUserName release];
   [super dealloc];
}


+ (Options *)sharedOptions {
   static Options *o = nil;
   if (o == nil) {
      o = [[Options alloc] init];
   }
   return o;
}


- (GameLevel)gameLevel {
   return gameLevel;
}


- (void)setGameLevel:(GameLevel)newGameLevel {
   gameLevel = newGameLevel;
   gameLevelWasChanged = YES;
}

- (GameMode)gameMode {
   return gameMode;
}


- (void)setGameMode:(GameMode)newGameMode {
   gameMode = newGameMode;
   gameModeWasChanged = YES;
}


- (BOOL)gameModeWasChanged {
   BOOL result = gameModeWasChanged;
   gameModeWasChanged = NO;
   return result;
}


- (BOOL)gameLevelWasChanged {
   BOOL result = gameLevelWasChanged;
   gameLevelWasChanged = NO;
   return result;
}


- (NSString *)saveGameFile {
   return saveGameFile;
}


- (void)setSaveGameFile:(NSString *)newFileName {
   [saveGameFile release];
   saveGameFile = [newFileName retain];
   [[NSUserDefaults standardUserDefaults] setObject: saveGameFile
                                             forKey: @"saveGameFile2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)emailAddress {
   return emailAddress;
}


- (void)setEmailAddress:(NSString *)newEmailAddress {
   [emailAddress release];
   emailAddress = [newEmailAddress retain];
   [[NSUserDefaults standardUserDefaults] setObject: emailAddress
                                             forKey: @"emailAddress2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)fullUserName {
   return fullUserName;
}


- (void)setFullUserName:(NSString *)name {
   [fullUserName release];
   fullUserName = [name retain];
   [[NSUserDefaults standardUserDefaults] setObject: fullUserName
                                             forKey: @"fullUserName2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (int)strength {
   return strength;
}

- (BOOL)maxStrength {
   return strength == 20;
}

- (void)setStrength:(int)newStrength {
   strength = newStrength;
   strengthWasChanged = YES;
   [[NSUserDefaults standardUserDefaults] setInteger: newStrength
                                              forKey: @"Elo5"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)strengthWasChanged {
   BOOL result = strengthWasChanged;
   strengthWasChanged = NO;
   return result;
}


- (NSString *)loadGameFile {
   return loadGameFile;
}

- (void)setLoadGameFile:(NSString *)lgf {
   [loadGameFile release];
   loadGameFile = [lgf retain];
   [[NSUserDefaults standardUserDefaults] setObject: loadGameFile
                                             forKey: @"loadGameFile"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)loadGameFileGameNumber {
   return loadGameFileGameNumber;
}

- (void)setLoadGameFileGameNumber:(int)lgfgn {
   loadGameFileGameNumber = lgfgn;
   [[NSUserDefaults standardUserDefaults] setInteger: loadGameFileGameNumber
                                              forKey: @"loadGameFileGameNumber"];
}

- (BOOL)displayMoveGestureTakebackHint {
   BOOL tmp = displayMoveGestureTakebackHint;
   displayMoveGestureTakebackHint = NO;
   [[NSUserDefaults standardUserDefaults] setObject: @"NO"
                                             forKey: @"displayMoveGestureTakebackHint2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
   return tmp;
}


- (BOOL)displayMoveGestureStepForwardHint {
   BOOL tmp = displayMoveGestureStepForwardHint;
   displayMoveGestureStepForwardHint = NO;
   [[NSUserDefaults standardUserDefaults] setObject: @"NO"
                                             forKey: @"displayMoveGestureStepForwardHint2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
   return tmp;
}


- (BOOL)displayGameListSearchFieldHint {
   BOOL tmp = displayGameListSearchFieldHint;
   displayGameListSearchFieldHint = NO;
   [[NSUserDefaults standardUserDefaults] setObject: @"NO"
                                             forKey: @"displayGameListSearchFieldHint"];
   [[NSUserDefaults standardUserDefaults] synchronize];
   return tmp;
}


- (BOOL)displayGamePreviewSwipingHint {
   BOOL tmp = displayGamePreviewSwipingHint;
   displayGamePreviewSwipingHint = NO;
   [[NSUserDefaults standardUserDefaults] setObject: @"NO"
                                             forKey: @"displayGamePreviewSwipingHint"];
   [[NSUserDefaults standardUserDefaults] synchronize];
   return tmp;
}



static const BOOL FixedTime[13] = {
   NO, NO, NO, NO, NO, NO, NO, NO, YES, YES, YES, YES, YES
};
static const int LevelTime[13] = {
   2, 2, 5, 5, 15, 15, 30, 30, 0, 0, 0, 0, 0
};
static const int LevelIncr[13] = {
   0, 1, 0, 2, 0, 5, 0, 5, 1, 2, 5, 10, 30
};

- (BOOL)isFixedTimeLevel {
   assert(gameLevel < 13);
   return FixedTime[gameLevel];
}

- (int)baseTime {
   assert(gameLevel < 13);
   return LevelTime[gameLevel] * 60000;
}

- (int)timeIncrement {
   assert(gameLevel < 13);
   return LevelIncr[gameLevel] * 1000;
}

- (NSString *)serverName {
   return serverName;
}

- (void)setServerName:(NSString *)newServerName {
   [serverName release];
   serverName = [newServerName retain];
   [[NSUserDefaults standardUserDefaults] setObject: serverName
                                             forKey: @"serverName2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)serverPort {
   return serverPort;
}

- (void)setServerPort:(int)newPort {
   serverPort = newPort;
   [[NSUserDefaults standardUserDefaults] setInteger: serverPort
                                              forKey: @"serverPort2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (int)playStyleAsInt {
   if ([playStyle isEqualToString: @"Passive"])
      return 0;
   else if ([playStyle isEqualToString: @"Solid"])
      return 1;
   else if ([playStyle isEqualToString: @"Active"])
      return 2;
   else if ([playStyle isEqualToString: @"Aggressive"])
      return 3;
   else if ([playStyle isEqualToString: @"Suicidal"])
      return 4;
   NSLog(@"unknown play style: %@", playStyle);
   return 2;
}


@end
