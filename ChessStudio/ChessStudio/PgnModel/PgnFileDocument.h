//
//  PgnFileDocument.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 07/02/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PgnFileInfo.h"

@interface PgnFileDocument : UIDocument


@property (nonatomic, strong) PgnFileInfo *pgnFileInfo;


@end
