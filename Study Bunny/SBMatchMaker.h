//
//  SBMatchMaker.h
//  Study Bunny
//
//  Created by Gregoire on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Course.h"
@class SBMatchMaker;

@protocol SBMatchMakerDelegate <NSObject>

-(void)matchesMade:(SBMatchMaker *)matchMaker WithError:(NSError *)error;

@end

@interface SBMatchMaker : NSObject

@property (nonatomic, weak) id <SBMatchMakerDelegate> delegate;
@property (nonatomic, strong) NSArray *myCourses;
@property (nonatomic, strong) NSMutableArray *userMatches;
@property (nonatomic, strong) NSMutableDictionary *usersMappedToCourses;

-(void)getMatches;

@end
