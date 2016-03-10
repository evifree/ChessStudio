#include <stdio.h>

#include "board.h"
#include "string.h"

void board_init(board_t *board){
    uint8 r,f;
    for(r=0;r<=7;r++){
        for(f=0;f<=7;f++){
            (board->pieces)[f][r]='-';
        }
    }
    board->ep_file=NO_EP_FILE;
    board->castle_flags=0;
    board->to_move=1;
}

void board_print(board_t *board){
    uint8 r,f;
    for(r=8;r>0;r--){
        for(f=0;f<=7;f++){
            printf("%c",(board->pieces)[f][r-1]);
        }
        printf("\n");
    }
    if(board->to_move==WHITE){
        printf("White to move\n");
    }else{
        printf("Black to move\n");
    }
    if(WHITE_CAN_CASTLE_SHORT(board->castle_flags)){
        printf("White can castle short\n");
    }
    if(WHITE_CAN_CASTLE_LONG(board->castle_flags)){
        printf("White can castle long\n");
    }
    if(BLACK_CAN_CASTLE_SHORT(board->castle_flags)){
        printf("Black can castle short\n");
    }
    if(BLACK_CAN_CASTLE_LONG(board->castle_flags)){
        printf("Black can castle long\n");
    }
    if(board->ep_file!=NO_EP_FILE){
        printf("En passant file: %c\n",board->ep_file+'a');
    }
}

int board_from_fen(board_t *board, char *fen){
    char board_s[72+1];
    char to_move_c;
    char castle_flags_s[4+1];
    char ep_square_s[2+1];
    int ret,p,i;
    char c;
    uint8 row, file;
    board_init(board);
    ret=sscanf(fen,"%72s %c %4s %2s",
               board_s,
               &to_move_c,
               castle_flags_s,
               ep_square_s);
    if(ret<4) return 1;
    row=7;
    file=0;
    p=0;
    while(TRUE){
        if(p>=strlen(board_s)) break;
        c=board_s[p++];
        if(c=='/'){
            if(row==0) return 1;
            row--;
            file=0;
            continue;
        }
        if(('1'<=c)&&('8'>=c)){
            for(i=0;i<=c-'1';i++){
                if(file>7) return 1;
                (board->pieces)[file++][row]='-';
            }
            continue;
        }
        if(file>7) return 1;
        (board->pieces)[file++][row]=c;
    }
    if(to_move_c=='w'){
        board->to_move=WHITE;
    }else{
        board->to_move=BLACK;
    }
    p=0;
    while(TRUE){
        if(p>=strlen(castle_flags_s)) break;
        c=castle_flags_s[p++];
        switch(c){
	    case '-' :
	        break;
            case 'K' :
                SET_WHITE_CAN_CASTLE_SHORT(board->castle_flags);
                break;
            case 'Q' :
                SET_WHITE_CAN_CASTLE_LONG(board->castle_flags);
                break;
            case 'k' :
                SET_BLACK_CAN_CASTLE_SHORT(board->castle_flags);
                break;
            case 'q' :
                SET_BLACK_CAN_CASTLE_LONG(board->castle_flags);
                break;
            default:
                return 1;
                break;
          
        }
    }
    board->ep_file=NO_EP_FILE;
    if(ep_square_s[0]=='-'){
    }else{
        file=ep_square_s[0]-'a';
        if(file>7) return 1;
        if(board->to_move==BLACK){
            if(((file>0) && ((board->pieces)[file-1][3]=='p'))||
               ((file<7) && ((board->pieces)[file+1][3]=='p'))){
                board->ep_file=file;
            }
        }else{
            if(((file>0) && ((board->pieces)[file-1][4]=='P'))||
               ((file<7) && ((board->pieces)[file+1][4]=='P'))){
                board->ep_file=file;
            }
        }
    }
       
    return 0;
}

