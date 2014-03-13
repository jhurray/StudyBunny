//
//  SBButton.m
//  Study Bunny
//
//  Created by Gregoire on 2/14/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "SBButton.h"

@implementation SBButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:SECONDARYCOLOR];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont fontWithName:FONT size:24.0]];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
//        [self.layer setBorderColor:[UIColor whiteColor].CGColor];
//        [self.layer setBorderWidth:1];
        [self.layer setCornerRadius:frame.size.height/5];
        [self addTarget:self action:@selector(highlight) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(unhighlight) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(unhighlight) forControlEvents:UIControlEventTouchDragOutside];
    }
    return self;
}

-(void)highlight{
    [self setBackgroundColor:TERTIARYCOLOR];
}

-(void)unhighlight{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self setBackgroundColor:SECONDARYCOLOR];
    } completion:^(BOOL finished) {
        
    } ];
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
