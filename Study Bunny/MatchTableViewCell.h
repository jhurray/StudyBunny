//
//  MatchTableViewCell.h
//  Study Bunny
//
//  Created by Gregoire on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchedUser.h"

@interface MatchTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *matches;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) NSString *fbId;
@property (nonatomic, strong) UILabel *matchPending;

@property BOOL matchMade;

// indicator for selected (maybe stage of match)?

-(void)setCellFeaturesWithMatchedUser:(MatchedUser *)matchedUser;
-(void)makeHighlighted;
-(void)makeUnhighlighted;

@end
