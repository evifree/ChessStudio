////
//// Includes
////

#import "EngineController.h"

#include <iomanip>
#include <sstream>

#include "bitboard.h"
#include "endgame.h"
#include "evaluate.h"
#include "material.h"
#include "san.h"
#include "search.h"
#include "thread.h"
#include "tt.h"
#include "ucioption.h"

using std::string;

namespace {
  string CurrentMove;
  int CurrentMoveNumber, TotalMoveCount;
  int CurrentDepth;
}

////
//// Functions   STOCKFISH 5
////

extern void kpk_bitbase_init();

void engine_init() {
   UCI::init(Options);
   Bitboards::init();
   Position::init();
   Bitbases::init_kpk();
   Search::init();
   Pawns::init();
   Eval::init();
   Threads.init();
   TT.resize(Options["Hash"]);
}


void engine_exit() {
   Threads.exit();
}


void pv_to_ui(const string &pv, int depth, int score, int scoreType, bool mate) {
  NSString *string = [[NSString alloc] initWithUTF8String: pv.c_str()];
    
    //NSLog(@">>>>>>>>>>>>>>>>>>>>>STOCKFISH 5:  Stringa ricevuta sa Search.cpp  = %@", string);
    
   dispatch_async(dispatch_get_main_queue(), ^{
      //[GlobalEngineController sendPV:string depth:depth score:score scoreType:scoreType mate: (mate ? YES : NO)];
       [GlobalEngineController sendPV:string];
   });
}

void pv_to_ui2(const string &pv) {
    NSString *string = [[NSString alloc] initWithUTF8String: pv.c_str()];
    
    //NSLog(@">>>>>>>>>>>>>>>>>>>>>  Stringa ricevuta sa Search.cpp = %@", string);
    
    //[GlobalEngineController performSelectorOnMainThread: @selector(sendPV:) withObject: string waitUntilDone: NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //[GlobalEngineController sendPV:string depth:depth score:score scoreType:scoreType mate: (mate ? YES : NO)];
        [GlobalEngineController sendPV:string];
    });
}


void currmove_to_ui(const string currmove, int currmovenum, int movenum, int depth) {
    
  CurrentMove = currmove;
  CurrentMoveNumber = currmovenum;
  CurrentDepth = depth;
  TotalMoveCount = movenum;
    
    //NSLog(@"*********************************************************    CHIAMO CURRMOVE TO UI = %s", currmove.c_str());
}

static const string time_string(int millisecs) {
    
    const int MSecMinute = 1000 * 60;
    const int MSecHour   = 1000 * 60 * 60;
    
    std::stringstream s;
    s << std::setfill('0');
    
    int hours = millisecs / MSecHour;
    int minutes = (millisecs - hours * MSecHour) / MSecMinute;
    int seconds = (millisecs - hours * MSecHour - minutes * MSecMinute) / 1000;
    
    if (hours)
        s << hours << ':';
    
    s << std::setw(2) << minutes << ':' << std::setw(2) << seconds;
    return s.str();
}

void searchstats_to_ui(int64_t nodes, long time) {
    
    std::stringstream s;
    s << " " << time_string((int)time) << "  " << CurrentDepth
    << "  " << CurrentMove
    << " (" << CurrentMoveNumber << "/" << TotalMoveCount << ")"
    << "  ";
    if (nodes < 1000000000)
        s << nodes/1000 << "kN";
    else
        s << std::setiosflags(std::ios::fixed) << std::setprecision(1) << nodes/1000000.0 << "MN";
    if(time > 0)
        s << std::setiosflags(std::ios::fixed) << std::setprecision(1)
        << "  " <<  (nodes*1.0) / time << "kN/s";
    
    NSString *string = [[NSString alloc] initWithUTF8String: s.str().c_str()];

   dispatch_async(dispatch_get_main_queue(), ^{
      //[GlobalEngineController sendCurrentMove:[NSString stringWithUTF8String:CurrentMove.c_str()] currentMoveNumber:CurrentMoveNumber numberOfMoves:TotalMoveCount depth:CurrentDepth time:time nodes:nodes];
      //[GlobalEngineController sendSearchStats:[NSString stringWithUTF8String:CurrentMove.c_str()]];
       [GlobalEngineController sendSearchStats:string];
   });
}


void bestmove_to_ui(const string &best, const string &ponder) {
   NSString *bestString = [[NSString alloc] initWithUTF8String: best.c_str()];
   NSString *ponderString = [[NSString alloc] initWithUTF8String: ponder.c_str()];
  [GlobalEngineController sendBestMove: bestString
                            ponderMove: ponderString];
}


extern void execute_command(const string &command);

void command_to_engine(const string &command) {
   execute_command(command);
}


bool command_is_waiting() {
  return [GlobalEngineController commandIsWaiting];
}


string get_command() {
   return string([[GlobalEngineController getCommand] UTF8String]);
}
