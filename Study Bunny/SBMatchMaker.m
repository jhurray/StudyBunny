//
//  SBMatchMaker.m
//  Study Bunny
//
//  Created by Gregoire on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "SBMatchMaker.h"

@implementation SBMatchMaker

@synthesize usersMappedToCourses, userMatches, myCourses, delegate, madeMatches, pendingMatches;

-(id)init
{
    if(self = [super init])
    {
        myCourses = [NSArray array];
        usersMappedToCourses = [NSMutableDictionary dictionary];
        userMatches = [NSMutableArray array];
        madeMatches = [NSMutableArray array];
        pendingMatches = [NSMutableArray array];
    }
    return self;
}

-(void)getMatches
{
    [Course getMyCoursesWithCompletion:^(NSArray *courses) {
        myCourses = courses;
        NSMutableArray *subjectCodes = [NSMutableArray array];
        NSMutableArray *catalogNumbers = [NSMutableArray array];
        for (Course *c in courses) {
            [subjectCodes addObject:c.subjectCode];
            [catalogNumbers addObject:c.catalogNum];
        }
        [self getStudyMatchesForSubjectCodes:subjectCodes andCatalogNums:catalogNumbers];
        
    }];
}


-(void)getStudyMatchesForSubjectCodes:(NSArray *)subCodes andCatalogNums:(NSArray *)catNums
{
    madeMatches = [[[PFUser currentUser] objectForKey:@"madeMatches"] mutableCopy];
    pendingMatches = [[[PFUser currentUser] objectForKey:@"pendingMatches"] mutableCopy];
    
    PFQuery *q = [PFQuery queryWithClassName:@"Course"];
    [q whereKey:@"subjectCode" containedIn:subCodes];
    [q whereKey:@"catalogNum" containedIn:catNums];
    [q whereKey:@"owner" notEqualTo:[PFUser currentUser].objectId];
    // so that no made matches come up
    [q whereKey:@"objectId" notContainedIn:madeMatches];
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // do user query and push that shit into Matches
        if (error) {
            NSLog(@"An error occured: %@", error.localizedDescription);
            [delegate matchesMade:self WithError:error];
            return;
        }
        //NSLog(@"DONE WITH QUERY\n");
        //NSLog(@"objects are: \n\n%@\n", objects);
        for (PFObject *o in objects) {
            Course *course = [[Course alloc] initWithPFObject:o];
            if([userMatches containsObject:course.owner])
            {// user exists already, maybe it is a new course
                NSMutableArray *arr = [usersMappedToCourses objectForKey:course.owner];
                if(![arr containsObject:course])
                {
                    [arr addObject:course];
                }
            }
            else
            {// user is new to the match making game
                [userMatches addObject:course.owner];
                [usersMappedToCourses setValue:[NSMutableArray arrayWithObject:course] forKey:course.owner];
            }
        }//endfor
        
        if([userMatches count] == 0)
        {
            NSMutableDictionary *description = [NSMutableDictionary dictionaryWithObject:@"SBMatchMaking Error: no matches found for user..." forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"MatchMaking" code:13 userInfo:description];
            [delegate matchesMade:self WithError:error];
            return;
        }
        // matches made without errors
        [delegate matchesMade:self WithError:error];
        // all done
    }];
}


@end
