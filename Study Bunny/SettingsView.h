//
//  SettingsView.h
//  Study Bunny
//
//  Created by Dylan Hurd on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBContactView.h"

@interface SettingsView : UIView <SBContactViewDelegate>

@property (nonatomic, strong) UISegmentedControl *picker;
@property (nonatomic, strong) UILabel *prompt;
@property (strong, nonatomic) SBButton *logoutBtn;
@property (nonatomic, strong) SBContactView *phoneView;
@property (nonatomic, strong) SBContactView *emailView;

@property BOOL changesMade;

@end
