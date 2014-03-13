//
//  LoginViewController.h
//  Study Bunny
//
//  Created by Gregoire on 2/1/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBButton.h"
#import "SBTextField.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) SBButton *loginBtn;
@property (nonatomic, strong) SBTextField *phoneInput;
@property (nonatomic, strong) SBButton *done;
@property (nonatomic, strong) UIView *bunnyCircle;
@property (nonatomic, strong) UIImageView *bunny;
@property (nonatomic, strong) NSString *phoneNum;
@property (nonatomic, strong) NSString *email;

@end
