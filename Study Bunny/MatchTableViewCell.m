//
//  MatchTableViewCell.m
//  Study Bunny
//
//  Created by Gregoire on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MatchTableViewCell.h"
#import "Course.h"

@implementation MatchTableViewCell

@synthesize name, matches;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setFrame:CGRectMake(0, 0, DEVICEWIDTH, MATCHCELLHEIGHT)];
        
        //name config
        name = [[UILabel alloc] initWithFrame:CGRectMake(MATCHCELLHEIGHT/10, MATCHCELLHEIGHT/10, DEVICEWIDTH*2/3, MATCHCELLHEIGHT/2)];
        [name setTextColor:MAINCOLOR];
        [name setFont:[UIFont fontWithName:FONT size:30]];
        [name setAdjustsFontSizeToFitWidth:YES];
        
        //matches config
        matches = [[UILabel alloc] initWithFrame:CGRectMake(MATCHCELLHEIGHT/10, MATCHCELLHEIGHT/2+MATCHCELLHEIGHT/5, DEVICEWIDTH-40, MATCHCELLHEIGHT/4)];
        [matches setTextColor:[UIColor grayColor]];
        [matches setFont:[UIFont fontWithName:FONT size:16]];
        [matches setAdjustsFontSizeToFitWidth:NO];
        
        [self addSubview:name];
        [self addSubview:matches];
    }
    return self;
}

-(void)setCellFeaturesWithMatchedUser:(MatchedUser *)matchedUser
{
    [name setText:matchedUser.name];
    NSString *matchesString;
    for (unsigned int i = 0; i < matchedUser.matchedCourses.count; ++i)
    {
        Course *c = (Course *)matchedUser.matchedCourses[i];
        if(i == 0)
        {
            matchesString = [NSString stringWithFormat:@"%@ %@", c.subjectCode, c.catalogNum ];
            continue;
        }
        matchesString = [NSString stringWithFormat:@"%@, %@ %@", matchesString, c.subjectCode, c.catalogNum];
    }
    [matches setText:matchesString];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if(selected)
    {
        // Configure the view for the selected state
        [self.contentView setBackgroundColor:MAINCOLOR];
        [matches setTextColor:[UIColor lightGrayColor]];
        [name setTextColor:[UIColor whiteColor]];
        [self setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        [name setTextColor:MAINCOLOR];
        [matches setTextColor:[UIColor grayColor]];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryNone];
    }
}

@end
