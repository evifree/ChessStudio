//
//  EngineView.m
//  ChessStudio
//
//  Created by Giordano Vicoli on 27/11/13.
//  Copyright (c) 2013 Giordano Vicoli. All rights reserved.
//

#import "EngineView.h"
#import <QuartzCore/QuartzCore.h>

@interface EngineView() {

    UILabel *analysisView;

}

@end

@implementation EngineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.backgroundColor = [[UIColor alloc] initWithRed:90.0/255.0 green:200.0/255.0 blue:250.0/255.0 alpha:1.0];
        analysisView = [[UILabel alloc] initWithFrame:frame];
        [analysisView setFont: [UIFont systemFontOfSize: 14.0]];
        [analysisView setBackgroundColor: [UIColor whiteColor]];
        analysisView.layer.borderColor = [UIColor colorWithRed: 0.781 green: 0.777 blue: 0.797 alpha:1.0].CGColor;
        analysisView.layer.borderWidth = 1.0;
        [self addSubview:analysisView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
