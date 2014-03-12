//
//  MatchedUser.m
//  Study Bunny
//
//  Created by Gregoire on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MatchedUser.h"

@implementation MatchedUser
@synthesize name, matchedCourses, userId;

-(id)initWithPFUser:(PFUser *)user
{
    if (self = [super init]) {
        userId = user.objectId;
        matchedCourses = nil;
        name = [user objectForKey:@"name"];
    }
    return self;
}

@end
