//
//  TBDatabaseCollectionViewController.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 06/11/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBDatabaseCollectionCell.h"

@interface TBDatabaseCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSMutableArray *listFile;

- (void) bottonePremuto:(TBDatabaseCollectionCell *)sender;

@end
