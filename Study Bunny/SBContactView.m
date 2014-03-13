//
//  SBContactView.m
//  Study Bunny
//
//  Created by Gregoire on 3/13/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "SBContactView.h"

@implementation SBContactView

@synthesize input, control, title;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:TERTIARYCOLOR];
        title = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 3*frame.size.width/4, frame.size.height/4+10)];
        [title setTextColor:MAINCOLOR];
        [title setFont: [UIFont fontWithName:FONT size:16]];
        [title setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:title];
        
        control = [UIButton buttonWithType:UIButtonTypeCustom];
        [control setFrame:CGRectMake(DEVICEWIDTH-frame.size.width/4-5, 0, frame.size.width/4, frame.size.height/4+10)];
        [control.titleLabel setTextColor:TERTIARYCOLOR];
        //[control setBackgroundColor:[UIColor redColor]];
        [control.titleLabel setFont:[UIFont fontWithName:FONT size:16]];
        [control.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [control setTitle:@"Edit" forState:UIControlStateNormal];
        [control setTag:0];
        [control addTarget:self action:@selector(controlPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control];
        
        input = [[UITextField alloc] initWithFrame:CGRectMake(0, frame.size.height/4+10, DEVICEWIDTH, frame.size.height/4*3-10)];
        [input setBackgroundColor:SECONDARYCOLOR];
        [input setDelegate:self];
        [input setEnabled:NO];
        [input setTextColor:MAINCOLOR];
        [input setTextAlignment:NSTextAlignmentCenter];
        [input setFont:[UIFont fontWithName:FONT size:24]];
        [input setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:input];
        
        
    }
    return self;
}

-(void)controlPressed
{
    
    if (control.tag == 0) {
        // entering edit mode
        [control setTitle:@"Done" forState:UIControlStateNormal];
        [control setTag:1];
        
        if ([self.parseKey isEqualToString:@"email"]) {
            [input setKeyboardType:UIKeyboardTypeEmailAddress];
        }
        else if([self.parseKey isEqualToString:@"phoneNumber"]){
            [input setKeyboardType:UIKeyboardTypeDecimalPad];
        }
        
        [input setEnabled:YES];
        [input setSelected:YES];
        [input becomeFirstResponder];
        [self.delegate editModeEnteredForParseKey:self.parseKey];
    }
    else{
        // done with edit
        [control setTitle:@"Edit" forState:UIControlStateNormal];
        [control setTag:0];
        [input setEnabled:NO];
    }
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
