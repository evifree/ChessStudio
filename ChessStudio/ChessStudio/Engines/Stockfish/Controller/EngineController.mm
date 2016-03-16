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

#import "EngineController.h"
//#import "GameController.h"

#include <pthread.h>
//#include "../Engine/iphone.h"

#include "iphone.h"

#import "PGNMove.h"

EngineController *GlobalEngineController; // HACK

@implementation EngineController

@synthesize engineIsThinking, engineThreadIsRunning;

/*
- (id)initWithGameController:(GameController *)gc {
   if (self = [super init]) {
      commandQueue = [[Queue alloc] init];
      //gameController = gc;

      // Initialize locks and conditions
      pthread_mutex_init(&WaitConditionLock, NULL);
      pthread_cond_init(&WaitCondition, NULL);

      // Start engine thread
      NSThread *thread =
         [[NSThread alloc] initWithTarget: self
                                 selector: @selector(startEngine:)
                                   object: nil];
      [thread setStackSize: 0x100000];
      [thread start];
      [thread release];

      ignoreBestmove = NO;
      engineIsThinking = NO;
   }
   GlobalEngineController = self;
   return self;
}*/

- (id) initWithoutGameController {
    if (self = [super init]) {
        commandQueue = [[Queue alloc] init];
        // Initialize locks and conditions
        pthread_mutex_init(&WaitConditionLock, NULL);
        pthread_cond_init(&WaitCondition, NULL);
        
        // Start engine thread
        NSThread *thread =
        [[NSThread alloc] initWithTarget: self
                                selector: @selector(startEngine:)
                                  object: nil];
        [thread setStackSize: 0x100000];
        [thread start];
        //[thread release];
        
        ignoreBestmove = NO;
        engineIsThinking = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveReceived:) name:@"EngineNotification" object:nil];
        
    }
    GlobalEngineController = self;
    return self;
}

- (void)startEngine:(id)anObject {
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

   engineThreadIsRunning = YES;
   engineThreadShouldStop = NO;

   engine_init();

   //engine_uci_loop();
   while (!engineThreadShouldStop) {
      pthread_mutex_lock(&WaitConditionLock);
      if ([commandQueue isEmpty]) {
         NSLog(@"Nothing to do, sleeping. Wake me up when something happens!");
         pthread_cond_wait(&WaitCondition, &WaitConditionLock);
         NSLog(@"Waking up, work to do!");
      }
      pthread_mutex_unlock(&WaitConditionLock);
      while (![commandQueue isEmpty]) {
         NSString *command = [commandQueue pop];
         /*
         if ([command hasPrefix: @"go"]) {
            while (engineIsThinking);
            engineIsThinking = YES;
         }
         */
         NSLog(@"Executing command: %@", command);
         execute_command(std::string([command UTF8String]));
          ///esegui_comando(std::string([command UTF8String]));
         //engineIsThinking = NO;
      }
   }

   NSLog(@"engine is quitting");
   engine_exit();

   [pool release];
   engineThreadIsRunning = NO;
}

- (void)sendCommand:(NSString *)command {
    NSLog(@"Sto eseguendo sendCommand %@", command);
   NSLog(@"sending %@", command);
   [commandQueue push: command];
}

- (void)abortSearch {
   NSLog(@"aborting search");
   [self sendCommand: @"stop"];
   [self commitCommands];
}


- (void)commitCommands {
   NSLog(@"commiting commands");
   pthread_mutex_lock(&WaitConditionLock);
   pthread_cond_signal(&WaitCondition);
   pthread_mutex_unlock(&WaitConditionLock);
}


- (BOOL)commandIsWaiting {
   return ![commandQueue isEmpty];
}


- (NSString *)getCommand {
   //assert(![commandQueue isEmpty]);
   if ([commandQueue isEmpty])
      return @"";
   else
      return [commandQueue pop];
}


- (void)sendPV:(NSString *)pv {
   //[gameController displayPV: pv];
    NSLog(@"displayPV: %@", pv);
    if (_delegate) {
        [_delegate inviaPV:pv];
    }
}


- (void)sendSearchStats:(NSString *)searchStats {
   //[gameController displaySearchStats: searchStats];
    NSLog(@"display Search Stats: %@", searchStats);
    
    if (_delegate) {
        [_delegate inviaSearchStarts:searchStats];
    }
    
}


- (void)sendBestMove:(NSString *)bestMove ponderMove:(NSString *)ponderMove {
   NSLog(@"received best move: %@ ponder move: %@", bestMove, ponderMove);
   engineIsThinking = NO;
   if (!ignoreBestmove)
       
       NSLog(@"non ignoro best move");
      //[gameController performSelectorOnMainThread: @selector(engineMadeMove:) withObject: [NSArray arrayWithObjects:bestMove, ponderMove, nil] waitUntilDone: NO];
    
    if (_delegate) {
        [_delegate ilMotoreHaMosso:[NSArray arrayWithObjects:bestMove, ponderMove, nil]];
    }
    
   else {
      NSLog(@"ignoring best move");
      ignoreBestmove = NO;
   }
}


- (void)ponderhit {
   NSLog(@"Ponder hit");
   [self sendCommand: @"ponderhit"];
   [self commitCommands];
}


- (void)pondermiss {
   NSLog(@"Ponder miss");
   ignoreBestmove = YES;
   [self sendCommand: @"stop"];
   [self commitCommands];
}


- (void)dealloc {
   NSLog(@"EngineController dealloc");
   [commandQueue release];
   pthread_cond_destroy(&WaitCondition);
   pthread_mutex_destroy(&WaitConditionLock);
   [super dealloc];
}


- (void)quit {
   //ignoreBestmove = YES;
   //engineThreadShouldStop = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
   [self sendCommand: @"quit"];
   [self commitCommands];
   NSLog(@"waiting for engine thread to exit...");
   while (![NSThread isMultiThreaded]);
   NSLog(@"engine thread exited");
}


- (void)setOption:(NSString *)name value:(NSString *)value {
   [self sendCommand: [NSString stringWithFormat: @"setoption name %@ value %@", name, value]];
}


- (void)setPlayStyle:(NSString *)style {
   if ([style isEqualToString: @"Passive"]) {
      [self setOption: @"Mobility (Midgame)" value: @"40"];
      [self setOption: @"Mobility (Endgame)" value: @"40"];
      [self setOption: @"Space" value: @"0"];
      [self setOption: @"Cowardice" value: @"150"];
      [self setOption: @"Aggressiveness" value: @"40"];
   } else if ([style isEqualToString: @"Solid"]) {
      [self setOption: @"Mobility (Midgame)" value: @"80"];
      [self setOption: @"Mobility (Endgame)" value: @"80"];
      [self setOption: @"Space" value: @"70"];
      [self setOption: @"Cowardice" value: @"150"];
      [self setOption: @"Aggressiveness" value: @"80"];
   } else if ([style isEqualToString: @"Active"]) {
      [self setOption: @"Mobility (Midgame)" value: @"100"];
      [self setOption: @"Mobility (Endgame)" value: @"100"];
      [self setOption: @"Space" value: @"100"];
      [self setOption: @"Cowardice" value: @"100"];
      [self setOption: @"Aggressiveness" value: @"100"];
   } else if ([style isEqualToString: @"Aggressive"]) {
      [self setOption: @"Mobility (Midgame)" value: @"120"];
      [self setOption: @"Mobility (Endgame)" value: @"120"];
      [self setOption: @"Space" value: @"120"];
      [self setOption: @"Cowardice" value: @"100"];
      [self setOption: @"Aggressiveness" value: @"150"];
   } else if ([style isEqualToString: @"Suicidal"]) {
      [self setOption: @"Mobility (Midgame)" value: @"150"];
      [self setOption: @"Mobility (Endgame)" value: @"150"];
      [self setOption: @"Space" value: @"150"];
      [self setOption: @"Cowardice" value: @"80"];
      [self setOption: @"Aggressiveness" value: @"200"];
   } else {
      NSLog(@"Unknown play style: %@", style);
   }
}

- (void) moveReceived:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    PGNMove *move = [userInfo objectForKey:@"MOSSA"];
    //NSLog(@"MOSSA RICEVUTA con fen = %@", move.fen);
    
    [move resetEngineMoves];
    [move visitaAlberoIndietroPerMotore];
    //NSLog(@"%@", [move getMosseDopoVisitaAlberoIndietroPerMotore]);
    
    //NSString *engineString = [[@"position fen rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" stringByAppendingString:@" moves "] stringByAppendingString:[move getMosseDopoVisitaAlberoIndietroPerMotore]];
    
    NSMutableString *engineString = [[NSMutableString alloc] init];
    [engineString appendString:@"position fen "];
    [engineString appendString:_startFenPosition];
    [engineString appendString:@" moves "];
    [engineString appendString:[move getMosseDopoVisitaAlberoIndietroPerMotore]];
    
    
    //NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&     ENGINE STRING = %@", engineString);
    
    [self abortSearch];
    [self sendCommand:engineString];
    [self setOption: @"UCI_AnalyseMode" value: @"true"];
    [self sendCommand: @"go infinite"];
    
    [self commitCommands];
}


@end
