#include <string.h>

#include "types.h"

char *promote_pieces=" nbrq";

int move_from_string(char move_s[6], uint16 *move){
    int fr,ff,tr,tf,p;
    char c;
    char *p_enc;
    c=move_s[0];
    if(c<'a' || c>'h') return 1;
    ff=c-'a';
    c=move_s[1];
    if(c<'1' || c>'8') return 1;
    fr=c-'1';
    c=move_s[2];
    if(c<'a' || c>'h') return 1;
    tf=c-'a';
    c=move_s[3];
    if(c<'1' || c>'8') return 1;
    tr=c-'1';
    c=move_s[4];
    p=0;
    if(c!=0){
        p_enc=strchr(promote_pieces,c);
        if(!p_enc) return 1;
        p=p_enc-promote_pieces;
    }
    *move=(p<<12)+(fr<<9)+(ff<<6)+(tr<<3)+tf;
    return 0;
}

int move_to_string(char move_s[6], uint16 move){
    int f,fr,ff,t,tr,tf,p;
    f=(move>>6)&077;
    fr=(f>>3)&0x7;
    ff=f&0x7;
    t=move&077;
    tr=(t>>3)&0x7;
    tf=t&0x7;
    p=(move>>12)&0x7;
    move_s[0]=ff+'a';
    move_s[1]=fr+'1';
    move_s[2]=tf+'a';
    move_s[3]=tr+'1';
    if(p){
        if(p>5) return 1;
        move_s[4]=promote_pieces[p];
        move_s[5]='\0';
    }else{
        move_s[4]='\0';
    }
    if(!strcmp(move_s,"e1h1")){
        strcpy(move_s,"e1g1");
    }else  if(!strcmp(move_s,"e1a1")){
        strcpy(move_s,"e1c1");
    }else  if(!strcmp(move_s,"e8h8")){
        strcpy(move_s,"e8g8");
    }else  if(!strcmp(move_s,"e8a8")){
        strcpy(move_s,"e8c8");
    }
    return 0;
}
