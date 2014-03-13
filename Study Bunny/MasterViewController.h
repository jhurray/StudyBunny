//
//  MasterViewController.h
//  Study Bunny
//
//  Created by Gregoire on 2/1/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@interface MasterViewController : UIViewController <SettingsViewDelegate>

@property (strong, nonatomic) SettingsViewController *settingsViewController;

@end
