//
//  MyMatchesTableViewCell.h
//  Study Bunny
//
//  Created by Gregoire on 3/13/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MatchedUser.h"
#import <UIKit/UIKit.h>

@protocol MyMatchTableViewCellDelegate <NSObject>

-(void)contactRequest;
-(void)blockRequest;

@end


@interface MyMatchesTableViewCell : UITableViewCell

@property (nonatomic, weak) id <MyMatchTableViewCellDelegate> delegate;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *matches;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) NSString *fbId;
@property (nonatomic, strong) UILabel *mutualFriends;
@property (nonatomic, strong) UIButton *contact;
@property (nonatomic, strong) UIButton *block;


-(void)setCellFeaturesWithMatchedUser:(MatchedUser *)matchedUser;


@end
