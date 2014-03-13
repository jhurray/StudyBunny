//
//  CoursePickerSegmentView.m
//  Study Bunny
//
//  Created by Gregoire on 2/14/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "CoursePickerSegmentView.h"

@implementation CoursePickerSegmentView

@synthesize picker;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:TERTIARYCOLOR];
        CGFloat xOffset = 30;
        CGFloat yOFfset = 10;
        picker = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"School", @"Subject", @"Course", nil]];
        UIFont *font = [UIFont fontWithName:FONT size:14.0];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        [picker setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [picker setFrame:CGRectMake(xOffset, yOFfset, DEVICEWIDTH-2*xOffset, frame.size.height-2*yOFfset)];
        [picker setBackgroundColor:[UIColor clearColor]];
        [picker setTintColor:[UIColor whiteColor]];
        [picker setSelectedSegmentIndex:0];
        [self addSubview:picker];
        self.step = 0;
        
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
