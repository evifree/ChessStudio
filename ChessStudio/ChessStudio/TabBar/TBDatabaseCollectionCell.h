//
//  TBDatabaseCollectionCell.h
//  ChessStudio
//
//  Created by Giordano Vicoli on 06/11/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBDatabaseCollectionCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *cellImageView;
@property (strong, nonatomic) IBOutlet UILabel *cellLabel;
@property (nonatomic, assign, getter = isFile) BOOL file;
@property (strong, nonatomic) IBOutlet UIButton *checkBoxButton;
@property (nonatomic, assign, getter = isEditMode) BOOL editMode;


- (IBAction)checkBoxButtonPressed:(UIButton *)sender;

- (void) setCheckedBoxButton:(BOOL)fileEdit;

@end
