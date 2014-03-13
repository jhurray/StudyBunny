//
//  MatchedUser.m
//  Study Bunny
//
//  Created by Gregoire on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MatchedUser.h"

@implementation MatchedUser
@synthesize name, matchedCourses, userId, fbId, coord, online;

-(id)initWithPFUser:(PFUser *)user
{
    if (self = [super init]) {
        userId = user.objectId;
        matchedCourses = nil;
        name = [user objectForKey:@"name"];
        fbId = [user objectForKey:@"facebook_id"];
        online = [[user objectForKey:@"online"] boolValue];
        PFGeoPoint *tmp = [user objectForKey:@"location"];
        coord = CLLocationCoordinate2DMake(tmp.latitude, tmp.longitude);
    }
    return self;
}

-(NSString *)getConcatenatedCourses
{
    NSString *matchesString;
    for (unsigned int i = 0; i < self.matchedCourses.count; ++i)
    {
        Course *c = (Course *)self.matchedCourses[i];
        if(i == 0)
        {
            matchesString = [NSString stringWithFormat:@"%@ %@", c.subjectCode, c.catalogNum ];
            continue;
        }
        matchesString = [NSString stringWithFormat:@"%@, %@ %@", matchesString, c.subjectCode, c.catalogNum];
    }
    return matchesString;
}

@end
