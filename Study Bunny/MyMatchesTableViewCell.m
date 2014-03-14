//
//  MyMatchesTableViewCell.m
//  Study Bunny
//
//  Created by Gregoire on 3/13/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MyMatchesTableViewCell.h"

@implementation MyMatchesTableViewCell

@synthesize name, matches, imgView, mutualFriends, delegate, contact, block;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setFrame:CGRectMake(0, 0, DEVICEWIDTH, MYMATCHCELLHEIGHT)];
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(MYMATCHCELLHEIGHT/10, MYMATCHCELLHEIGHT/10, 0.4*MYMATCHCELLHEIGHT, 0.4*MYMATCHCELLHEIGHT)];
        [imgView setBackgroundColor:LIGHTGRAYTEXTCOLOR];
        imgView.layer.cornerRadius = 8.0f;
        imgView.layer.masksToBounds = YES;
        [self addSubview:imgView];
        
        
        //name config
        name = [[UILabel alloc] initWithFrame:CGRectMake(2*MYMATCHCELLHEIGHT/10+imgView.frame.size.width, MYMATCHCELLHEIGHT/15, DEVICEWIDTH*2/3, MYMATCHCELLHEIGHT/2 - MYMATCHCELLHEIGHT/5)];
        [name setTextColor:SECONDARYCOLOR];
        [name setFont:[UIFont fontWithName:FONT size:34]];
        [name setAdjustsFontSizeToFitWidth:YES];
        
        //mutual frinds config
        mutualFriends = [[UILabel alloc] initWithFrame:CGRectMake(2*MYMATCHCELLHEIGHT/10+imgView.frame.size.width, name.frame.size.height+name.frame.origin.y-10, DEVICEWIDTH*2/3,MYMATCHCELLHEIGHT/5)];
        [mutualFriends setTextColor:GRAYTEXTCOLOR];
        [mutualFriends setFont:[UIFont fontWithName:FONT size:14]];
        [mutualFriends setAdjustsFontSizeToFitWidth:YES];
        
        //matches config
        matches = [[UILabel alloc] initWithFrame:CGRectMake(MYMATCHCELLHEIGHT/10, MYMATCHCELLHEIGHT/2+MYMATCHCELLHEIGHT/25, DEVICEWIDTH-40, MYMATCHCELLHEIGHT/6)];
        [matches setTextColor:GRAYTEXTCOLOR];
        [matches setFont:[UIFont fontWithName:FONT size:16]];
        [matches setAdjustsFontSizeToFitWidth:NO];
        
        
        // BUTTONS
        CGFloat btnTop = matches.frame.origin.y+matches.frame.size.height;
        
        contact = [UIButton buttonWithType:UIButtonTypeCustom];
        [contact setBackgroundColor:TERTIARYCOLOR];
        [contact.titleLabel setFont:[UIFont fontWithName:FONT size:18]];
        [contact setTitle:@"Contact" forState:UIControlStateNormal];
        [contact addTarget:self action:@selector(contactBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        [contact setFrame:CGRectMake(DEVICEWIDTH*2/7, btnTop, DEVICEWIDTH*5/7, MYMATCHCELLHEIGHT-btnTop)];
        
        block = [UIButton buttonWithType:UIButtonTypeCustom];
        [block setBackgroundColor:DELETECOLOR];
        [block.titleLabel setFont:[UIFont fontWithName:FONT size:18]];
        [block setTitle:@"Block" forState:UIControlStateNormal];
        [block addTarget:self action:@selector(blockBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        [block setFrame:CGRectMake(0, btnTop, DEVICEWIDTH*2/7, MYMATCHCELLHEIGHT-btnTop)];
        
        [self addSubview:contact];
        [self addSubview:block];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setTintColor:TERTIARYCOLOR];
        [self addSubview:name];
        [self addSubview:mutualFriends];
        [self addSubview:matches];
    }
    return self;
}


-(void)contactBtnTouched
{
    [delegate contactRequest:self.contactByPhone withContactInfo:self.contactInfo];
}

-(void)blockBtnTouched
{
    [delegate blockRequest];
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
    self.contactByPhone = [matchedUser contactByPhone];
    if(self.contactByPhone)
    {
        self.contactInfo = matchedUser.phone;
    }
    else{
        self.contactInfo = matchedUser.email;
    }
    [self loadPicforImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    return;
}

@end
