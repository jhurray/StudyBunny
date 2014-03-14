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
@property (nonatomic, strong) NSMutableArray *pendingMatches;
@property (nonatomic, strong) NSMutableArray *madeMatches;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fbId;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;
@property CLLocationCoordinate2D coord;
@property BOOL contactByPhone;
@property BOOL online;
@property (nonatomic, strong) PFUser *userPtr;


//0 = unmatched
//1 = match pending
//2 = match made

-(NSString *)getConcatenatedCourses;
-(id)initWithPFUser:(PFUser *)user;
-(void)saveAsPFUser;


@end
