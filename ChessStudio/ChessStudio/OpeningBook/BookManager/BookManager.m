//
//  BookManager.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 26/11/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "BookManager.h"

#include <stdio.h>
#include <string.h>

#include "book.h"
#include "move.h"
#include "hash.h"
#include "board.h"

#define MAX_MOVES 100

@interface BookManager() {
    FILE *b;

    //char *fen;
    
    char *book;
    entry_t entry;
    board_t board;
    int count,offset,total_weight,i;
    entry_t entries[MAX_MOVES];
    uint64 key;
    char move_s[6];
}

@end

@implementation BookManager


- (id) initWithBook:(NSString *)book {
    self = [super init];
    if (self) {
        [self caricaDefaultBook];
        if (b==NULL) {
            return nil;
        }
    }
    return self;
}


- (void) caricaDefaultBook {
    
    NSLog(@"APRO PERFORMANCE.BIN");
    NSString *path = [[NSBundle mainBundle] pathForResource: @"performance" ofType: @"bin"];
    
    b = fopen([path cStringUsingEncoding:1],"rb");
    if (b==NULL) {
        perror(book);
        return;
    }
}

- (void) interrogaBook:(NSString *)fenInput {
    NSLog(@"ESEGUO INTERROGA BOOK");
    if (b==NULL) {
        return;
    }
    const char *utf8String = [fenInput UTF8String];
    size_t len = strlen(utf8String) + 1;
    char fen[len];
    memcpy(fen, utf8String, len);
    if(board_from_fen(&board,fen)){
        fprintf(stderr,"%s: Illegal FEN\n",fen);
        return;
    }
    key=hash(&board);
    
    offset=find_key(b,key,&entry);
    if(entry.key!=key){
        fprintf(stderr,"%s: No such fen in \"%s\"\n", fen,book);
        fclose(b);
        return;
    }
    
    entries[0]=entry;
    count=1;
    fseek(b,16*(offset+1),SEEK_SET);
    while(TRUE){
        if(entry_from_file(b,&entry)){
            break;
        }
        if(entry.key!=key){
            break;
        }
        if(count==MAX_MOVES){
            fprintf(stderr,"pg_query: Too many moves in this position (max=%d)\n",MAX_MOVES);
            return;
        }
        entries[count++]=entry;
    }
    total_weight=0;
    for(i=0;i<count;i++){
        total_weight+=entries[i].weight;
    }
    for(i=0;i<count;i++){
        move_to_string(move_s,entries[i].move);
        printf("move=%s weight=%5.2f%%\n",
               move_s,
               100*((double) entries[i].weight/ (double) total_weight));
    }
}

- (NSString *) getBookMoves:(NSString *)fenInput {
    NSLog(@"ESEGUO INTERROGA BOOK");
    if (b==NULL) {
        return nil;
    }
    const char *utf8String = [fenInput UTF8String];
    size_t len = strlen(utf8String) + 1;
    char fen[len];
    memcpy(fen, utf8String, len);
    if(board_from_fen(&board,fen)){
        fprintf(stderr,"%s: Illegal FEN\n",fen);
        return nil;
    }
    key=hash(&board);
    
    offset=find_key(b,key,&entry);
    if(entry.key!=key){
        fprintf(stderr,"%s: No such fen in \"%s\"\n", fen,book);
        fclose(b);
        return nil;
    }
    
    entries[0]=entry;
    count=1;
    fseek(b,16*(offset+1),SEEK_SET);
    while(TRUE){
        if(entry_from_file(b,&entry)){
            break;
        }
        if(entry.key!=key){
            break;
        }
        if(count==MAX_MOVES){
            fprintf(stderr,"pg_query: Too many moves in this position (max=%d)\n",MAX_MOVES);
            return nil;
        }
        entries[count++]=entry;
    }
    total_weight=0;
    for(i=0;i<count;i++){
        total_weight+=entries[i].weight;
    }
    
    NSMutableString *bookMoves = [[NSMutableString alloc] init];
    
    for(i=0;i<count;i++){
        move_to_string(move_s,entries[i].move);
        NSString *move = [NSString stringWithFormat:@"move=%s weight=%5.2f%%\n", move_s, 100*((double) entries[i].weight/ (double) total_weight)];
        [bookMoves appendString:move];
        [bookMoves appendString:@" "];
        printf("move=%s weight=%5.2f%%\n", move_s, 100*((double) entries[i].weight/ (double) total_weight));
    }
    
    return bookMoves;
}


@end
