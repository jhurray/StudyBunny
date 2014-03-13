//
//  MatchedUser.h
//  Study Bunny
//
//  Created by Gregoire on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#include "Course.h"

@interface MatchedUser : NSObject

@property (nonatomic, strong) NSArray *matchedCourses;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fbId;
@property CLLocationCoordinate2D coord;
@property BOOL online;


//0 = unmatched
//1 = match pending
//2 = match made

-(NSString *)getConcatenatedCourses;
-(id)initWithPFUser:(PFUser *)user;

@end
