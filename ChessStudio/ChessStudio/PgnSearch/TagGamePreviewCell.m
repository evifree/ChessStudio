//
//  TagGamePreviewCell.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 17/07/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "TagGamePreviewCell.h"

@implementation TagGamePreviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}


@end
