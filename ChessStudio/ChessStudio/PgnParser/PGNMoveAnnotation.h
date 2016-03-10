//
//  PGNMoveAnnotation.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 23/10/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGNUtil.h"

@interface PGNMoveAnnotation : NSObject


- (void) setNag:(NSString *)nag;  //Sostitusce o aggiunge un nuovo nag ad un precedente dello stesso tipo
- (void) removeNag:(NSString *)nag; //Elimina un nag.

- (NSString *) getMoveAnnotation;
- (NSString *) getWebMoveAnnotation;
- (NSString *) getWebMoveAnnotationForGameMovesWebView;
- (BOOL) containsNag:(NSString *)nag;

@end
