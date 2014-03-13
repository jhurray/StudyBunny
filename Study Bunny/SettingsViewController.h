//
//  SettingsViewController.h
//  Study Bunny
//
//  Created by Dylan Hurd on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsView.h"

@protocol SettingsViewDelegate <NSObject>

- (void)didLogout;

@end

@interface SettingsViewController : UIViewController

@property (nonatomic, strong) UILabel *titleView;
@property (strong, nonatomic) SettingsView *view;
@property (weak, nonatomic) id<SettingsViewDelegate> delegate;

@end
