//
//  MatchPickerViewController.h
//  Study Bunny
//
//  Created by Gregoire on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course.h"
#import "SBMatchMaker.h"

@interface MatchPickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SBMatchMakerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) NSArray *myCourses;
@property (nonatomic, strong) SBMatchMaker *matcher;
@property (nonatomic, strong) NSMutableArray *matchedUsers;

@end
