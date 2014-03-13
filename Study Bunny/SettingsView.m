//
//  SettingsView.m
//  Study Bunny
//
//  Created by Dylan Hurd on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "SettingsView.h"


#define kLogoutBottomMargin 100
#define kLogoutWidth 200
#define kLogoutHeight 50

#define kCancelBtnTopMargin 25
#define kCancelBtnLeftMargin 25
#define kCancelBtnWidth 25
#define kCancelBtnHeight 25

@implementation SettingsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initHelper];
    }
    return self;
}

- (void)initHelper
{
    [self setBackgroundColor:MAINCOLOR];
    
    CGFloat logoutBtnTopMargin = self.frame.size.height - kLogoutBottomMargin - kLogoutHeight;
    CGFloat logoutBtnLeftMargin = (self.frame.size.width - kLogoutWidth)/2;
    self.logoutBtn = [[SBButton alloc] initWithFrame:CGRectMake(logoutBtnLeftMargin, logoutBtnTopMargin, kLogoutWidth, kLogoutHeight)];
    [self.logoutBtn setTitle:@"Logout" forState:UIControlStateNormal];
    
    [self addSubview:self.logoutBtn];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
