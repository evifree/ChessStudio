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

#import <UIKit/UIKit.h>

enum GameMode {
   GAME_MODE_COMPUTER_BLACK,
   GAME_MODE_COMPUTER_WHITE,
   GAME_MODE_ANALYSE,
   GAME_MODE_TWO_PLAYER
};

enum GameLevel {
   LEVEL_GAME_IN_2,
   LEVEL_GAME_IN_2_PLUS_1,
   LEVEL_GAME_IN_5,
   LEVEL_GAME_IN_5_PLUS_2,
   LEVEL_GAME_IN_15,
   LEVEL_GAME_IN_15_PLUS_5,
   LEVEL_GAME_IN_30,
   LEVEL_GAME_IN_30_PLUS_5,
   LEVEL_1S_PER_MOVE,
   LEVEL_2S_PER_MOVE,
   LEVEL_5S_PER_MOVE,
   LEVEL_10S_PER_MOVE,
   LEVEL_30S_PER_MOVE
};

enum BoardSize {
    SMALL,
    MEDIUM,
    BIG
};

@interface Options : NSObject {
   UIColor *darkSquareColor, *lightSquareColor, *highlightColor, *selectedSquareColor;
   UIImage *darkSquareImage, *lightSquareImage;
   NSString *colorScheme;
   NSString *playStyle;
   NSString *bookVariety;
   BOOL bookVarietyWasChanged;
   NSString *pieceSet;
   BOOL moveSound;
   BOOL figurineNotation;
   BOOL showAnalysis;
   BOOL showBookMoves;
   BOOL showLegalMoves;
   BOOL permanentBrain;

   enum GameMode gameMode;
   BOOL gameModeWasChanged;
   enum GameLevel gameLevel;
   BOOL gameLevelWasChanged;

   BOOL playStyleWasChanged;
   BOOL strengthWasChanged;

   NSString *saveGameFile;
   NSString *loadGameFile;
   int loadGameFileGameNumber;

   NSString *fullUserName;
   NSString *emailAddress;

   BOOL displayMoveGestureStepForwardHint;
   BOOL displayMoveGestureTakebackHint;

   NSString *serverName;
   int serverPort;

   int strength;

   BOOL showCoordinates;
   
   BOOL displayGameListSearchFieldHint;
   BOOL displayGamePreviewSwipingHint;   
}

@property (nonatomic, readonly) UIColor *darkSquareColor;
@property (nonatomic, readonly) UIColor *lightSquareColor;
@property (nonatomic, readonly) UIColor *highlightColor;
@property (nonatomic, readonly) UIColor *selectedSquareColor;
@property (nonatomic, readonly) UIImage *darkSquareImage;
@property (nonatomic, readonly) UIImage *lightSquareImage;
@property (nonatomic, retain) NSString *colorScheme;
@property (nonatomic, retain) NSString *playStyle;
@property (nonatomic, retain) NSString *bookVariety;
@property (nonatomic, readonly) BOOL bookVarietyWasChanged;
@property (nonatomic, retain) NSString *pieceSet;
@property (nonatomic, readwrite) BOOL moveSound;
@property (nonatomic, readwrite) BOOL figurineNotation;
@property (nonatomic, readwrite) BOOL showAnalysis;
@property (nonatomic, readwrite) BOOL showBookMoves;
@property (nonatomic, readwrite) BOOL showLegalMoves;
@property (nonatomic, readwrite) BOOL showCoordinates;
@property (nonatomic, readwrite) BOOL permanentBrain;
@property (nonatomic, assign) enum GameMode gameMode;
@property (nonatomic, assign) enum GameLevel gameLevel;
@property (nonatomic, readonly) BOOL gameModeWasChanged;
@property (nonatomic, readonly) BOOL gameLevelWasChanged;
@property (nonatomic, readonly) BOOL playStyleWasChanged;
@property (nonatomic, retain) NSString *saveGameFile;
@property (nonatomic, retain) NSString *loadGameFile;
@property (nonatomic, assign) int loadGameFileGameNumber;
@property (nonatomic, retain) NSString *emailAddress;
@property (nonatomic, retain) NSString *fullUserName;
@property (nonatomic, readonly) BOOL displayMoveGestureStepForwardHint;
@property (nonatomic, readonly) BOOL displayMoveGestureTakebackHint;
@property (nonatomic, assign) int strength;
@property (nonatomic, readonly) BOOL strengthWasChanged;
@property (nonatomic, retain) NSString *serverName;
@property (nonatomic, assign) int serverPort;
@property (nonatomic, readonly) BOOL displayGameListSearchFieldHint;
@property (nonatomic, readonly) BOOL displayGamePreviewSwipingHint;

+ (Options *)sharedOptions;

- (UIColor *)darkSquareColorForColorScheme:(NSString *)scheme;
- (UIColor *)lightSquareColorForColorScheme:(NSString *)scheme;
- (UIImage *)darkSquareImageForColorScheme:(NSString *)scheme large:(BOOL)large;
- (UIImage *)lightSquareImageForColorScheme:(NSString *)scheme large:(BOOL)large;
- (UIColor *)highlightColorForColorScheme:(NSString *)scheme;
- (UIColor *)selectedSquareColorForColorScheme:(NSString *)scheme;
- (void)updateColors;
- (BOOL)isFixedTimeLevel;
- (int)baseTime;
- (int)timeIncrement;
- (int)playStyleAsInt;
- (BOOL)maxStrength;

@end
