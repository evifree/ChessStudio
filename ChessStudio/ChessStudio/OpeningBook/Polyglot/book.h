#ifndef BOOK_H
#define BOOK_H

#include <stdio.h>

#include "types.h"

typedef struct {
    uint64 key;
    uint16 move;
    uint16 weight;
    uint32 learn;
} entry_t;

extern entry_t entry_none;



void entry_to_file(FILE *f, entry_t *entry);
int entry_from_file(FILE *f, entry_t *entry);
int find_key(FILE *f, uint64 key, entry_t *entry);

#endif
