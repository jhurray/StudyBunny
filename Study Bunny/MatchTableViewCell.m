//
//  MatchTableViewCell.m
//  Study Bunny
//
//  Created by Gregoire on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MatchTableViewCell.h"
#import "Course.h"

#define CENTERSELECTED MATCHCELLHEIGHT/1.6
#define CENTERUNSELECTED MATCHCELLHEIGHT/1.21212121

@implementation MatchTableViewCell

@synthesize name, matches, matchMade, imgView, matchPending, reentering, mutualFriends;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setFrame:CGRectMake(0, 0, DEVICEWIDTH, MATCHCELLHEIGHT)];
        
        matchMade = false;
        reentering = FALSE;
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(MATCHCELLHEIGHT/10, MATCHCELLHEIGHT/10, 0.4*MATCHCELLHEIGHT, 0.4*MATCHCELLHEIGHT)];
        [imgView setBackgroundColor:LIGHTGRAYTEXTCOLOR];
        imgView.layer.cornerRadius = 8.0f;
        imgView.layer.masksToBounds = YES;
        [self addSubview:imgView];
        
        
        //name config
        name = [[UILabel alloc] initWithFrame:CGRectMake(2*MATCHCELLHEIGHT/10+imgView.frame.size.width, MATCHCELLHEIGHT/13, DEVICEWIDTH*2/3, MATCHCELLHEIGHT/2 - MATCHCELLHEIGHT/5)];
        [name setTextColor:SECONDARYCOLOR];
        [name setFont:[UIFont fontWithName:FONT size:30]];
        [name setAdjustsFontSizeToFitWidth:YES];
        
        //mutual frinds config
        mutualFriends = [[UILabel alloc] initWithFrame:CGRectMake(2*MATCHCELLHEIGHT/10+imgView.frame.size.width, name.frame.size.height+name.frame.origin.y, DEVICEWIDTH*2/3,MATCHCELLHEIGHT/5)];
        [mutualFriends setTextColor:GRAYTEXTCOLOR];
        [mutualFriends setFont:[UIFont fontWithName:FONT size:14]];
        [mutualFriends setAdjustsFontSizeToFitWidth:YES];
        
        matchPending = [[UILabel alloc] initWithFrame:CGRectMake(MATCHCELLHEIGHT/10, MATCHCELLHEIGHT/2+MATCHCELLHEIGHT/5, DEVICEWIDTH-40, MATCHCELLHEIGHT/4)];
        [matchPending setAlpha:0];
        [matchPending setText:@"Study Request Pending..."];
        [matchPending setFont:[UIFont fontWithName:FONT size:16]];
        [matchPending setTextColor:LIGHTBLUECOLOR];
        [matchPending setTextAlignment:NSTextAlignmentCenter];
        
        //matches config
        matches = [[UILabel alloc] initWithFrame:CGRectMake(MATCHCELLHEIGHT/10, MATCHCELLHEIGHT/2+MATCHCELLHEIGHT/5, DEVICEWIDTH-40, MATCHCELLHEIGHT/4)];
        [matches setTextColor:GRAYTEXTCOLOR];
        [matches setFont:[UIFont fontWithName:FONT size:16]];
        [matches setAdjustsFontSizeToFitWidth:NO];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setTintColor:TERTIARYCOLOR];
        [self addSubview:matchPending];
        [self addSubview:name];
        [self addSubview:mutualFriends];
        [self addSubview:matches];
    }
    return self;
}


-(void)animateMatchPending
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
       
        [matches setCenter:CGPointMake(matches.center.x, CENTERSELECTED)];
        [mutualFriends setAlpha:0];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{

            [matchPending setAlpha:1];
            
        } completion:^(BOOL finished) {
            
        }];
    }];
}

-(void)animateMatchCancelled
{
    //[self setBackgroundColor:[UIColor clearColor]];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [matchPending setAlpha:0];
        
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            [matches setCenter:CGPointMake(matches.center.x, CENTERUNSELECTED)];
            [mutualFriends setAlpha:1];
            
        } completion:^(BOOL finished) {
            
        }];
    }];
}

-(void)loadPicforImageView
{
    NSLog(@"fb ifd is %@", self.fbId);
    NSString *query = [NSString stringWithFormat:@"SELECT pic_square, mutual_friend_count FROM user WHERE uid=%@ AND uid", self.fbId];    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                 // NSLog(@"Result: %@", result);
                                  UIImage *image = [UIImage imageWithData:
                                                    [NSData dataWithContentsOfURL:
                                                     [NSURL URLWithString:
                                                      result[@"data"][0][@"pic_square"]]]];
                                  imgView.image = image;
                                  mutualFriends.text = [NSString stringWithFormat:@"%@ mutual friends",result[@"data"][0][@"mutual_friend_count"]];
                              }
                          }];
}

-(void)setCellFeaturesWithMatchedUser:(MatchedUser *)matchedUser
{
    [name setText:matchedUser.name];
    [matches setText: [matchedUser getConcatenatedCourses]];
    self.fbId = matchedUser.fbId;
    [self loadPicforImageView];
}

-(void)makeHighlighted
{
    [self.contentView setBackgroundColor:SECONDARYCOLOR];
    [matches setTextColor:LIGHTGRAYTEXTCOLOR];
    [name setTextColor:MAINCOLOR];
    [mutualFriends setTextColor:MAINCOLOR];
    [matchPending setAlpha:0];
    [self setAccessoryType:UITableViewCellAccessoryCheckmark];
    [self animateMatchPending];
}

-(void)makeUnhighlighted
{
    [name setTextColor:SECONDARYCOLOR];
    [matches setTextColor:GRAYTEXTCOLOR];
    [mutualFriends setTextColor:GRAYTEXTCOLOR];
    
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self setAccessoryType:UITableViewCellAccessoryNone];
    [self animateMatchCancelled];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (!selected) {
        matchMade = FALSE;
        return;
    }
    
    
    if (matchMade && !reentering) {
        [self makeUnhighlighted];
        matchMade = false;
    }
    else if(!reentering)
    {
        [self makeHighlighted];
        matchMade = true;
        NSLog(@"\n\nIn Here!!\n\n");
    }
}

@end
