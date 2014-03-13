//
//  SBTextField.m
//  Study Bunny
//
//  Created by Gregoire on 3/11/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "SBTextField.h"

@implementation SBTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:SECONDARYCOLOR];
        [self setTextColor:MAINCOLOR];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setFont:[UIFont fontWithName:FONT size:30]];
        //[self.layer setCornerRadius:5];
        [self setAdjustsFontSizeToFitWidth:YES];
        [self setAlpha:0.9];
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
