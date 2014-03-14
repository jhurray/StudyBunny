//
//  MatchedUser.m
//  Study Bunny
//
//  Created by Gregoire on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MatchedUser.h"

@implementation MatchedUser
@synthesize name, matchedCourses, userId, fbId, coord, online, email, phone, contactByPhone, madeMatches, pendingMatches, userPtr;

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
        phone = [user objectForKey:@"phoneNumber"];
        email = [user objectForKey:@"email"];
        contactByPhone = [[user objectForKey:@"contactByPhone"] boolValue];
        madeMatches = [NSMutableArray arrayWithArray:[user objectForKey:@"madeMatches"]];
        pendingMatches = [NSMutableArray arrayWithArray:[user objectForKey:@"pendingMatches"]];
        if(!madeMatches){
            madeMatches = [NSMutableArray array];
        }
        if (!pendingMatches) {
            pendingMatches = [NSMutableArray array];
        }
    }
    return self;
}

-(void)saveAsPFUser
{

    [PFCloud callFunctionInBackground:@"modifyUser"
                       withParameters:@{@"userId": userId, @"switchId": [PFUser currentUser].objectId }
                                block:^(NSArray *results, NSError *error) {
                                    if (error) {
                                        // this is where you handle the results and change the UI.
                                        NSLog(@"An error occured in the cloud code... \n%@\n%@", error.description, error.localizedDescription);
                                        return;
                                    }
                                    NSLog(@"Succesful Cloud code save!");
                                }];
     
     
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
