#ifndef BOARD_H
#define BOARD_H

#include "types.h"

#define NO_EP_FILE 8
#define WHITE_CAN_CASTLE_SHORT(flags) (flags & 1)
#define WHITE_CAN_CASTLE_LONG(flags) (flags & 2)
#define BLACK_CAN_CASTLE_SHORT(flags) (flags & 4)
#define BLACK_CAN_CASTLE_LONG(flags) (flags & 8)
#define SET_WHITE_CAN_CASTLE_SHORT(flags) (flags |= 1)
#define SET_WHITE_CAN_CASTLE_LONG(flags) (flags |= 2)
#define SET_BLACK_CAN_CASTLE_SHORT(flags) (flags |= 4)
#define SET_BLACK_CAN_CASTLE_LONG(flags) (flags |= 8)
#define WHITE 1
#define BLACK 0

typedef struct {
    char pieces[8][8];    // 1st index=file
    uint8 castle_flags;      // bit/flag:  0/Wh-Sh  1/Wh-Lo 2/Bl-Sh 3/Bl-Lo
    uint8 ep_file;           // NO_EP_FILE for no ep_file
    uint8 to_move;           // 1 is white to move, 0 is black to move
} board_t;

void board_init(board_t *board);
void board_print(board_t *board);
int board_from_fen(board_t *board, char *fen);

#endif

