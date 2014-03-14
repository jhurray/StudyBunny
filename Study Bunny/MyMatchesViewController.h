//
//  MyMatchesViewController.h
//  Study Bunny
//
//  Created by Gregoire on 3/13/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "Course.h"
#import "SBMatchMaker.h"
#import <UIKit/UIKit.h>
#import "MyMatchesTableViewCell.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface MyMatchesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SBMatchMakerDelegate, MyMatchTableViewCellDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) NSArray *myCourses;
@property (nonatomic, strong) SBMatchMaker *matcher;
@property (nonatomic, strong) NSMutableArray *matchedUsers;


@end
