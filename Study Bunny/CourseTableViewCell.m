//
//  CourseTableViewCell.m
//  Study Bunny
//
//  Created by Gregoire on 2/20/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "CourseTableViewCell.h"



@implementation CourseTableViewCell

@synthesize topView, bottomView, editMode;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setFrame:CGRectMake(0, 0, DEVICEWIDTH, CELLHEIGHT)];
        editMode = FALSE;
        topView = [[UIView alloc] initWithFrame:self.frame];
        bottomView = [UIButton buttonWithType:UIButtonTypeCustom];
        [bottomView setFrame:CGRectMake(0, 0, DELETEOFFSET, CELLHEIGHT)];
        [bottomView.titleLabel setFont:[UIFont fontWithName:FONT size:18]];
        [bottomView.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [bottomView setTitle:@"Delete" forState:UIControlStateNormal];
        [bottomView setBackgroundColor:DELETECOLOR];
        [topView setBackgroundColor:MAINCOLOR];
        [bottomView addTarget:self action:@selector(bottomViewTouched) forControlEvents:UIControlEventTouchUpInside];
        
        // NSLog(@"%f, %f, %f, %f", self.frame.origin.x,self.frame.origin.y, self.frame.size.height, self.frame.size.width );
        [self addSubview:bottomView];
        [self addSubview:topView];
        //[self bringSubviewToFront:self.contentView];
        [self.contentView removeFromSuperview];
        [topView addSubview:self.contentView];
        
    }
    return self;
}

-(void)makeNormalMode
{
    [topView setFrame:CGRectMake(0, 0, DEVICEWIDTH, CELLHEIGHT)];
    editMode = FALSE;
}

-(void)makeEditingMode
{
    [topView setCenter:CGPointMake(topView.center.x+DELETEOFFSET, topView.center.y)];
    editMode = TRUE;
}

-(void)bottomViewTouched
{
    [self.delegate bottomButtonPressedForCourseTableViewCell:self];
}

-(void)animateEditingModeWithDelay:(CGFloat)delay
{
    editMode = TRUE;
    [UIView animateWithDuration:0.6 delay:delay usingSpringWithDamping:0.25 initialSpringVelocity:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [topView setCenter:CGPointMake(topView.center.x+DELETEOFFSET, topView.center.y)];
        
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void)animateNormalModeWithDelay:(CGFloat)delay
{
    editMode = FALSE;
    [UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [topView setCenter:CGPointMake(topView.center.x-DELETEOFFSET, topView.center.y)];
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
