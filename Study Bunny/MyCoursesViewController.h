//
//  MyCoursesViewController.h
//  Study Bunny
//
//  Created by Gregoire on 2/17/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "CoursePickerViewController.h"
#import "CourseTableViewCell.h"
#import "Course.h"
#import <UIKit/UIKit.h>

@interface MyCoursesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CoursePickerDelegate, CourseTVCDelegate >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) NSArray *myCourses;
@property (nonatomic, strong) UIButton *edit;
@property (nonatomic) BOOL editingMode;

@end
