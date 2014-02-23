//
//  CoursePickerViewController.h
//  Study Bunny
//
//  Created by Gregoire on 2/14/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course.h"
#import "CoursePickerSegmentView.h"

@protocol CoursePickerDelegate <NSObject>

-(void)didAddNewCourse:(Course *)course;

@end

@interface CoursePickerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CourseDelegate>

@property (nonatomic, weak) id<CoursePickerDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) Course *course;
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) CoursePickerSegmentView *pickerView;

@property (nonatomic, strong) NSArray *schoolData;
@property (nonatomic, strong) NSArray *subjectData;
@property (nonatomic, strong) NSArray *classData;

@end
