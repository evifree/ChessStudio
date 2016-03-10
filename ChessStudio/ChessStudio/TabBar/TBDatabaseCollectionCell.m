//
//  TBDatabaseCollectionCell.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 06/11/14.
//  Copyright (c) 2014 Giordano Vicoli. All rights reserved.
//

#import "TBDatabaseCollectionCell.h"
#import "TBDatabaseCollectionViewController.h"

@interface TBDatabaseCollectionCell() {
    
    UIImage *image;
    BOOL checked;
    
}

@end

@implementation TBDatabaseCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) layoutSubviews {
    [super layoutSubviews];
     _cellLabel.textColor = [UIColor blackColor];
    self.layer.cornerRadius = 10.0;
    _cellImageView.frame = CGRectMake(20, 10, 80, 80);
    _checkBoxButton.frame = CGRectMake(105, 10, 30, 30);
    checked = NO;
    _editMode = NO;
    if (_editMode) {
        _checkBoxButton.hidden = NO;
    }
    else {
        _checkBoxButton.hidden = YES;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setFile:(BOOL)file {
    _file = file;
    if (_file) {
        image = [UIImage imageNamed:@"PgnChess.png"];
    }
    else {
        image = [UIImage imageNamed:@"ChessFolder.png"];
    }
    _cellImageView.image = image;
}

- (IBAction)checkBoxButtonPressed:(UIButton *)sender {
    UIResponder *resp = [[[self nextResponder] nextResponder] nextResponder];
    TBDatabaseCollectionViewController *cvc = (TBDatabaseCollectionViewController *)resp;
    [cvc bottonePremuto:self];
    return;
    
    if (!checked) {
        [_checkBoxButton setImage:[UIImage imageNamed:@"CheckBoxChecked"] forState:UIControlStateNormal];
        checked = YES;
    }
    else {
        [_checkBoxButton setImage:[UIImage imageNamed:@"CheckBoxNormal"] forState:UIControlStateNormal];
        checked = NO;
    }
}

- (void) setCheckedBoxButton:(BOOL)fileEdit {
    if (fileEdit) {
        [_checkBoxButton setImage:[UIImage imageNamed:@"CheckBoxChecked"] forState:UIControlStateNormal];
        checked = YES;
    }
    else {
        [_checkBoxButton setImage:[UIImage imageNamed:@"CheckBoxNormal"] forState:UIControlStateNormal];
        checked = NO;
    }
}

- (void) setEditMode:(BOOL)editMode {
    _editMode = editMode;
    if ([self isEditMode]) {
        _checkBoxButton.hidden = NO;
    }
    else {
        _checkBoxButton.hidden = YES;
    }
}

@end
