//
//  SettingsView.m
//  Study Bunny
//
//  Created by Dylan Hurd on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "SettingsView.h"


#define kLogoutBottomMargin DEVICEHEIGHT/10
#define kLogoutWidth 200
#define kLogoutHeight 50

#define kCancelBtnTopMargin 25
#define kCancelBtnLeftMargin 25
#define kCancelBtnWidth 25
#define kCancelBtnHeight 25

#define kContactViewHeight DEVICEHEIGHT/6

@implementation SettingsView

@synthesize logoutBtn, emailView, phoneView, picker, prompt;

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
    
    self.changesMade = NO;
     // inputs
    phoneView = [[SBContactView alloc] initWithFrame:CGRectMake(0, DEVICEHEIGHT/5, DEVICEWIDTH, kContactViewHeight)];
    [phoneView.input setText:[PFUser currentUser][@"phoneNumber"]];
    [phoneView.title setText:@"Phone Number"];
    [phoneView setAlpha:0.8];
    [phoneView setParseKey:@"phoneNumber"];
    phoneView.delegate = self;
    [self addSubview:phoneView];
    
    emailView= [[SBContactView alloc] initWithFrame:CGRectMake(0, DEVICEHEIGHT/5+kContactViewHeight, DEVICEWIDTH, kContactViewHeight)];
    [emailView.input setText:[PFUser currentUser][@"email"]];
    [emailView.title setText:@"Email"];
    [emailView setAlpha:0.8];
    [emailView setParseKey:@"email"];
    emailView.delegate = self;
    [self addSubview:emailView];
    
    
    CGFloat logoutBtnTopMargin = self.frame.size.height - kLogoutBottomMargin - kLogoutHeight;
    //CGFloat logoutBtnLeftMargin = (self.frame.size.width - kLogoutWidth)/2;
    //self.logoutBtn = [[SBButton alloc] initWithFrame:CGRectMake(logoutBtnLeftMargin, logoutBtnTopMargin, kLogoutWidth, kLogoutHeight)];
    self.logoutBtn = [[SBButton alloc] initWithFrame:CGRectMake(-10, logoutBtnTopMargin, DEVICEWIDTH+20, kLogoutHeight)];
    [self.logoutBtn setTitle:@"Logout" forState:UIControlStateNormal];
    
    [self addSubview:self.logoutBtn];
    
    
    
    CGFloat editBottom = emailView.frame.origin.y+emailView.frame.size.height;
    CGFloat logoutTop = logoutBtn.frame.origin.y;
    NSLog(@"%f %f", editBottom, logoutTop);
    //CGFloat middle = (logoutTop - editBottom)/2 + editBottom;
    CGFloat difference = logoutTop - editBottom;
    CGFloat promptMargin = 20;
    CGFloat vertMargin = 5;
    prompt = [[UILabel alloc] initWithFrame:CGRectMake(promptMargin, editBottom+vertMargin, DEVICEWIDTH-promptMargin*2, difference/2-2*vertMargin)];
    [prompt setText:@"How would you like to be contacted?"];
    [prompt setFont:[UIFont fontWithName:FONT size:18]];
    [prompt setAdjustsFontSizeToFitWidth:YES];
    [prompt setTextColor:SECONDARYCOLOR];
    [self addSubview:prompt];
    
    picker = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Phone", @"Email", nil]]
    ;
    [picker setFrame:CGRectMake(promptMargin, editBottom+prompt.frame.size.height+vertMargin, DEVICEWIDTH-promptMargin*2, 45)];
    [picker setBackgroundColor:[UIColor clearColor]];
    [picker setTintColor:SECONDARYCOLOR];
    [picker setSelectedSegmentIndex:![[PFUser currentUser][@"contactByPhone"] boolValue]];
    [picker addTarget:self action:@selector(pickerChanged) forControlEvents:UIControlEventValueChanged];
    UIFont *font = [UIFont fontWithName:FONT size:18.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [picker setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self addSubview:picker];
   
}

-(void)pickerChanged
{
    self.changesMade = YES;
}

-(void)editModeEnteredForParseKey:(NSString *)key
{
    self.changesMade = YES;
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
