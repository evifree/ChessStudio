#include "types.h"
#include "book.h"

entry_t entry_none={0,0,0,0};

void int_to_file(FILE *f, int l, uint64 r){
    int i,c;
    for(i=0;i<l;i++){
        c=(r>>8*(l-i-1))&0xff;
        fputc(c,f);
    }
}

void entry_to_file(FILE *f, entry_t *entry){
    int_to_file(f,8,entry->key);
    int_to_file(f,2,entry->move);
    int_to_file(f,2,entry->weight);
    int_to_file(f,4,entry->learn);
}


int int_from_file(FILE *f, int l, uint64 *r){
    int i,c;
    for(i=0;i<l;i++){
        c=fgetc(f);
        if(c==EOF){
            return 1;
        }
        (*r)=((*r)<<8)+c;
    }
    return 0;
}

int entry_from_file(FILE *f, entry_t *entry){
    int ret;
    uint64 r;
    ret=int_from_file(f,8,&r);
    if(ret) return 1;
    entry->key=r;
    ret=int_from_file(f,2,&r);
    if(ret) return 1;
    entry->move=r;
    ret=int_from_file(f,2,&r);
    if(ret) return 1;
    entry->weight=r;
    ret=int_from_file(f,4,&r);
    if(ret) return 1;
    entry->learn=r;
    return 0;
}

int find_key(FILE *f, uint64 key, entry_t *entry){
    int first, last, middle;
    entry_t first_entry=entry_none, last_entry,middle_entry;
    first=-1;
    if(fseek(f,-16,SEEK_END)){
        *entry=entry_none;
        entry->key=key+1; //hack
        return -1;
    }
    last=ftell(f)/16;
    entry_from_file(f,&last_entry);
    while(1){
        if(last-first==1){
            *entry=last_entry;
            return last;
        }
        middle=(first+last)/2;
        fseek(f,16*middle,SEEK_SET);
        entry_from_file(f,&middle_entry);
        if(key<=middle_entry.key){
            last=middle;
            last_entry=middle_entry;
        }else{
            first=middle;
            first_entry=middle_entry;
        }
    }
}
