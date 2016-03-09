#if !defined(IPHONE_H_INCLUDED)
#define IPHONE_H_INCLUDED


#include <stdio.h>
#include <iomanip>
#include <string>
#include <sstream>

////
//// Prototypes
////

extern void engine_init();
extern void engine_exit();
extern void pv_to_ui(const std::string &pv, int depth, int score, int scoreType, bool mate);
extern void pv_to_ui2(const std::string &pv);
extern void currmove_to_ui(const std::string currmove, int currmovenum,
                           int movenum, int depth);
extern void bestmove_to_ui(const std::string &best, const std::string &ponder);
extern void searchstats_to_ui(int64_t nodes, long time);
extern int get_command(std::string &cmd);
extern void command_to_engine(const std::string &command);
extern bool command_is_waiting();
extern std::string get_command();
extern void wake_up_listener();
extern void execute_command(const std::string &cmd);

#endif // !defined(IPHONE_H_INCLUDED)
