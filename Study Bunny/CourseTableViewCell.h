//
//  CourseTableViewCell.h
//  Study Bunny
//
//  Created by Gregoire on 2/20/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DELETEOFFSET 70

@class CourseTableViewCell;
@protocol CourseTVCDelegate <NSObject>

-(void)bottomButtonPressedForCourseTableViewCell:(CourseTableViewCell *)cell;

@end

@interface CourseTableViewCell : UITableViewCell

@property (nonatomic, weak) id <CourseTVCDelegate> delegate;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *bottomView;
@property (nonatomic) BOOL editMode;
@property (nonatomic, strong) NSIndexPath *indexPath;

-(void)makeEditingMode;
-(void)makeNormalMode;
-(void)animateEditingModeWithDelay:(CGFloat)delay;
-(void)animateNormalModeWithDelay:(CGFloat)delay;

@end
