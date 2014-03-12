//
//  MatchedUser.h
//  Study Bunny
//
//  Created by Gregoire on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//


@interface MatchedUser : NSObject

@property (nonatomic, strong) NSArray *matchedCourses;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;

-(id)initWithPFUser:(PFUser *)user;

@end
