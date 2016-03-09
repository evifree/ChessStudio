/*
  Stockfish, a chess program for the Apple iPhone.
  Copyright (C) 2004-2010 Tord Romstad, Marco Costalba, Joona Kiiski.

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

#include <sys/types.h>
#include <sys/stat.h>

#import "OpeningBook.h"
#import "Options.h"

#include "../Chess/mersenne.h"
#include "../Chess/san.h"


// Constants

static const uint64_t BOOK_KEY_MASK = 0xFFFFFFFFFFFF0000ULL;
static const uint64_t BOOK_MOVE_MASK = 0xFFFFULL;


// Types

struct BookEntry {
   Move move;
   unsigned score, factor;
};


// Function prototypes

static uint64_t read_uint64(FILE *f);
static int compare(const void *a, const void *b);
static void sort_book_moves(BookEntry *moves, int n);
static Move translate_from_old_move_format(int oldMove);
static Move fix_castling_and_promotion(Position *p, Move m);

// Private methods

@interface OpeningBook (PrivateAPI)
- (int)searchForKey:(uint64_t)key;
- (int)findBookMovesForKey:(uint64_t)key storeInArray:(BookEntry *)moves;
@end


// Implementation

@implementation OpeningBook

- (id)initWithFilename:(NSString *)filename {
   struct stat fs;
   unsigned i, j;

   if (self = [super init]) {
      file = fopen([filename UTF8String], "rb");
      assert(file != NULL);
      int val = stat([filename UTF8String], &fs);
      NSLog(@"stat returned %d\n", val);
      size = (int)fs.st_size;

      // SUPER HACK: For some reason, size ends up being 0 on the iPad.
      // Hard-code the correct book size here instead.
      if (size == 0 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
         NSLog(@"Failed to read file size, assuming a size of 7635488.");
         size = 7635488;
      }

      NSLog(@"opened book, %d positions, size is %d", size/16, size);

      firstKey = read_uint64(file) & BOOK_KEY_MASK;
      fseek(file, size-16, SEEK_SET);
      lastKey = read_uint64(file) & BOOK_KEY_MASK;

      // Seed random move generator for book moves:
      i = abs(get_system_time()) % 10000;
      for (j = 0; j < i; j++) genrand_int32();
   }
   return self;
}


- (id)init {
   return [self initWithFilename:
                   [[NSBundle bundleForClass: [self class]]
                      pathForResource: @"guibook"
                               ofType: @"bin"]];
}


- (void)close {
   if (file != NULL) fclose(file);
}


- (int)searchForKey:(uint64_t)key {
   int start, middle, end;
   uint64_t k;

   start = 0;
   end = size/16 - 1;

   while (start < end) {
      middle = (start + end) / 2;
      fseek(file, 16 * middle, SEEK_SET);
      k = read_uint64(file) & BOOK_KEY_MASK;
      if (key <= k) end = middle; else start = middle + 1;
   }

   fseek(file, 16 * start, SEEK_SET);
   k = read_uint64(file) & BOOK_KEY_MASK;

   return (k == key)? start : -1;
}


- (int)findBookMovesForKey:(uint64_t)key storeInArray:(BookEntry *)moves {
   int i, n = 0;
   uint64_t bookData, bookKey;

   key &= BOOK_KEY_MASK;
    
    //NSLog(@"find book moves for key");
    //NSLog(@"KEY = %" PRIu64, key);
    
   i = [self searchForKey: key];
   if (i == -1) return 0;
   fseek(file, i * 16, SEEK_SET);

   do {
      bookData = read_uint64(file);
      bookKey = bookData & BOOK_KEY_MASK;

      if (bookKey == key) {
         moves[n].move = translate_from_old_move_format(bookData & BOOK_MOVE_MASK);
         bookData = read_uint64(file);
         moves[n].score = (unsigned)(bookData & 0xFFFFFFFF);
         moves[n].factor = (unsigned)(bookData >> 32);
         if ([[[Options sharedOptions] bookVariety] isEqualToString: @"Low"])
            moves[n].factor = moves[n].factor * moves[n].factor;
         else if ([[[Options sharedOptions] bookVariety]
                     isEqualToString: @"High"])
            moves[n].factor = 1;
         n++, i++;
      }
   } while (bookKey == key && i < size);

   return n;
}


- (Move)pickMoveForPosition:(Position *)position {
   BookEntry moves[64];
   unsigned n, i, r, s, sum;

   n = [self findBookMovesForKey: position->get_key() storeInArray: moves];
   if (n == 0) return MOVE_NONE;
   sort_book_moves(moves, n);

   sum = 0;
   for (i = 0; i < n; i++)
      sum += moves[i].factor * moves[i].score;
   r = genrand_int32() % sum;
   s = 0;
   for (i = 0; i < n; i++) {
      s += moves[i].factor * moves[i].score;
      if (s > r) break;
   }

   return fix_castling_and_promotion(position, moves[i].move);
}


- (void)allMovesForPosition:(Position *)position toArray:(Move *)array {
   BookEntry moves[64];
   unsigned n, i;

   n = [self findBookMovesForKey: position->get_key() storeInArray: moves];
   if (n == 0) {
      array[0] = MOVE_NONE;
      return;
   }
   for (i = 0; i < n; i++)
      array[i] = fix_castling_and_promotion(position, moves[i].move);
   array[i] = MOVE_NONE;
}


- (NSString *)bookMovesAsString:(Position *)position {
   BookEntry moves[64];
   unsigned n, i;
   NSMutableString *buf = [NSMutableString stringWithCapacity: 60];

   n = [self findBookMovesForKey: position->get_key() storeInArray: moves];
   if (n == 0) return nil;
   sort_book_moves(moves, n);

   int sum = 0;
   for (i = 0; i < n; i++)
      sum += moves[i].factor * moves[i].score;
   for (i = 0; i < n; i++) {
      Move m = fix_castling_and_promotion(position, moves[i].move);
      if (n <= 4 || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
         [buf appendFormat: @"%s (%.0f%%) ",
              move_to_san(*position, m).c_str(),
              (moves[i].factor * moves[i].score * 100.0) / sum];
      else if (n <= 5)
         [buf appendFormat: @"%s(%.0f%%) ",
              move_to_san(*position, m).c_str(),
              (moves[i].factor * moves[i].score * 100.0) / sum];
      else
         [buf appendFormat: @"%s(%.0f) ",
              move_to_san(*position, m).c_str(),
              (moves[i].factor * moves[i].score * 100.0) / sum];
   }
   NSString *string = [NSString stringWithString: buf];
   if ([[Options sharedOptions] figurineNotation]) {
      unichar c;
      NSString *s;
      NSString *pc[6] = { @"K", @"Q", @"R", @"B", @"N" };
      int i;
      for (i = 0, c = 0x2654; i < 5; i++, c++) {
         s = [NSString stringWithCharacters: &c length: 1];
         string = [string stringByReplacingOccurrencesOfString: pc[i]
                                                    withString: s];
      }
   }
   return string;
}

- (NSArray *) bookMovesAsArray:(Chess::Position *)position {
    BookEntry moves[64];
    unsigned n, i;
    NSMutableString *buf = [NSMutableString stringWithCapacity: 60];
    NSMutableString *buf2 = [[NSMutableString alloc] init];
    
    n = [self findBookMovesForKey: position->get_key() storeInArray: moves];
    if (n == 0) return nil;
    sort_book_moves(moves, n);
    
    int sum = 0;
    for (i = 0; i < n; i++)
        sum += moves[i].factor * moves[i].score;
    
    for (i = 0; i < n; i++) {
        Move m = fix_castling_and_promotion(position, moves[i].move);
        
        //NSLog(@"MOVE TO STRING: %s", move_to_string(m).c_str());
        //NSLog(@"MOVE TO SAN: %s", move_to_san(*position, m).c_str());
        
        if (n <= 4 || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [buf appendFormat: @"%s (%.0f%%) ",
             move_to_san(*position, m).c_str(),
             (moves[i].factor * moves[i].score * 100.0) / sum];
            
            [buf2 appendFormat:@"%s ", move_to_string(m).c_str()];
        }
        else if (n <= 5) {
            [buf appendFormat: @"%s(%.0f%%) ",
             move_to_san(*position, m).c_str(),
             (moves[i].factor * moves[i].score * 100.0) / sum];
            
            [buf2 appendFormat:@"%s ", move_to_string(m).c_str()];
        }
        else {
            [buf appendFormat: @"%s(%.0f) ",
             move_to_san(*position, m).c_str(),
             (moves[i].factor * moves[i].score * 100.0) / sum];
            [buf2 appendFormat:@"%s ", move_to_string(m).c_str()];
        }
    }
    
    //NSLog(@"BUF2 = %@", buf2);
    
    NSString *string = [NSString stringWithString: buf];
    
    
    
    /*
     if ([[Options sharedOptions] figurineNotation]) {
     unichar c;
     NSString *s;
     NSString *pc[6] = { @"K", @"Q", @"R", @"B", @"N" };
     int i;
     for (i = 0, c = 0x2654; i < 5; i++, c++) {
     s = [NSString stringWithCharacters: &c length: 1];
     string = [string stringByReplacingOccurrencesOfString: pc[i]
     withString: s];
     }
     }*/
    
    
    
    //NSLog(@"BUF2 = %@", buf2);
    //NSLog(@"STRING = %@", string);
    
    return [NSArray arrayWithObjects:string, buf2, nil];
}


-(void)dealloc {
   if (file != NULL)
      fclose(file);
   [super dealloc];
}

@end


static uint64_t read_uint64(FILE *f) {
   int i;
   unsigned char c;
   uint64_t result = 0;

   for (i = 7; i >= 0; i--) {
      c = fgetc(f);
      result += (uint64_t)(((uint64_t)c) << ((uint64_t)i*8ULL));
   }
   return result;
}


static int compare(const void *a, const void *b) {
   BookEntry *b1, *b2;
   b1 = (BookEntry *)a; b2 = (BookEntry *)b;
   if (b1->factor * b1->score < b2->factor * b2->score) return 1;
   else return -1;
}


static void sort_book_moves(BookEntry moves[], int n) {
   qsort(moves, n, sizeof(BookEntry), compare);
}


static Move translate_from_old_move_format(int oldMove) {
   int oldTo = oldMove & 127;
   int oldFrom = (oldMove >> 7) & 127;
   int oldProm = (oldMove >> 14) & 7;
   Square to = Square((oldTo & 15) | ((oldTo >> 4) << 3));
   Square from = Square((oldFrom & 15) | ((oldFrom >> 4) << 3));
   PieceType prom;
   if (!oldProm)
      prom = NO_PIECE_TYPE;
   else if (oldProm == 1)
      prom = QUEEN;
   else
      prom = PieceType(oldProm);
   return make_promotion_move(from, to, prom);
}


static Move fix_castling_and_promotion(Position *p, Move m) {
   Move mlist[32];
   int j, n;
   n = p->moves_from(move_from(m), mlist);
   for (j = 0; j < n; j++) {
      if (move_to(mlist[j]) == move_to(m)
          && move_promotion(mlist[j]) == move_promotion(m))
         return mlist[j];
      else if (move_is_short_castle(mlist[j])
               && p->type_of_piece_on(move_from(m)) == KING
               && move_to(m) - move_from(m) == 2)
         return mlist[j];
      else if(move_is_long_castle(mlist[j])
              && p->type_of_piece_on(move_from(m)) == KING
              && move_to(m) - move_from(m) == -2)
         return mlist[j];
   }
   NSLog(@"this shouldn't happen, but it did! move was %x to %x",
         move_from(m), move_to(m));
   return MOVE_NONE;
}
