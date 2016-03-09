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
//#include "ucioption.h"

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

/*
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
*/

void engine_exit() {
   Threads.exit();
}

NSInteger __depth__;
std::vector<std::vector<int> > __types__;
std::vector<std::vector<int> > __promotes__;
std::vector<std::vector<std::pair<unsigned, unsigned> > > __srcs__;
std::vector<std::vector<std::pair<unsigned, unsigned> > > __dsts__;

std::string engineSendAnalysis(const Position& pos, std::vector<Search::RootMove> &roots, std::size_t size, long depth, Value value, long nps)
{
    const bool isUserWhite = (pos.side_to_move() == WHITE);
    
    // The value received from the engine is always evaluated from the perspective of the engine, we need to revert it back
    const auto score = (Chess::value_to_centipawns(isUserWhite ? (Chess::Value) value : (Chess::Value) -value) / 100.0);
    
    /*
     * Show analysis
     */
    
    std::stringstream ss;
    
    if (abs(value) >= VALUE_MATE_IN_MAX_PLY)
    {
        const int mate = (value > 0 ? VALUE_MATE - value + 1 : -VALUE_MATE - value) / 2;
        
        if (value < 0)
        {
            ss << '#' << abs(mate);
        }
        else
        {
            ss << '#' << abs(mate);
        }
    }
    else
    {
        ss << (((isUserWhite && value > 0) || (!isUserWhite && value < 0))? "+" : "") << std::setiosflags(std::ios::fixed) << std::setprecision(1) << score;
    }
    
    // Defined in san.cpp
    extern std::string createAnalysis(const std::string &fen,
                                      const std::vector<int> &types,
                                      const std::vector<std::pair<unsigned, unsigned> > &srcs,
                                      const std::vector<std::pair<unsigned, unsigned> > &dsts,
                                      const std::vector<int> &promotes,
                                      bool appendMoveNumber);
    
    extern NSInteger __depth__;
    extern std::vector<std::vector<int> > __types__;
    extern std::vector<std::vector<int> > __promotes__;
    extern std::vector<std::vector<std::pair<unsigned, unsigned> > > __srcs__;
    extern std::vector<std::vector<std::pair<unsigned, unsigned> > > __dsts__;
    
    __depth__ = depth;
    
    __srcs__.reserve(size);
    __dsts__.reserve(size);
    __types__.reserve(size);
    __promotes__.reserve(size);
    
    __srcs__.clear();
    __dsts__.clear();
    __types__.clear();
    __promotes__.clear();
    
    for (unsigned i = 0; i < size; i++)
    {
        if (i && !Search::Limits.infinite && abs(roots[i].score - roots[0].score) >=  2.0)
        {
            break;
        }
        
        const std::vector<Move> &pv = roots[i].pv;
        
        __types__.push_back(std::vector<int>());
        __promotes__.push_back(std::vector<int>());
        __srcs__.push_back(std::vector<std::pair<unsigned, unsigned> >());
        __dsts__.push_back(std::vector<std::pair<unsigned, unsigned> >());
        
        for (std::size_t j = 0; j < roots[i].pv.size(); j++)
        {
            const Move &move = pv[j];
            const Square src = from_sq(move);
            Square dst = to_sq(move);
            
            switch (type_of(move))
            {
                case PROMOTION: { __types__[i].push_back(3); break; }
                case ENPASSANT: { __types__[i].push_back(2); break; }
                case CASTLING:  { __types__[i].push_back(1); break; }
                default:        { __types__[i].push_back(0); break; }
            }
            
            if (type_of(move) == PROMOTION)
            {
                __promotes__[i].push_back(promotion_type(move));
            }
            else
            {
                __promotes__[i].push_back(QUEEN);
            }
            
            __srcs__[i].push_back(std::pair<int,int>(file_of(src), rank_of(src)));
            __dsts__[i].push_back(std::pair<int,int>(file_of(dst), rank_of(dst)));
        }
    }
    
    std::string fuck;
    
    for (std::size_t i = 0; i < __srcs__.size(); i++)
    {
        fuck = createAnalysis(pos.fen(),
                                                      __types__[i],
                                                      __srcs__[i],
                                                      __dsts__[i],
                                                      __promotes__[i],
                                                      NO);
    }
    
    return fuck;
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


void getFuckingMoveCount(int moveCount, int movenum, int depth)
{
    CurrentMoveNumber = moveCount;
    CurrentDepth = depth;
    TotalMoveCount = movenum;
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
