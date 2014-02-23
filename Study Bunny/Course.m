//
//  Course.m
//  Study Bunny
//
//  Created by Gregoire on 2/13/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "Course.h"

@implementation Course
@synthesize subject, subjectCode, school, schoolCode, description, catalogNum, delegate, parseId, editMode;

-(id)initWithPFObject:(PFObject *)course{
    
    if(self = [super init]){
        subject = [course objectForKey:@"subject"];
        subjectCode = [course objectForKey:@"subjectCode"];
        school = [course objectForKey:@"school"];
        schoolCode = [course objectForKey:@"schoolCode"];
        catalogNum = [course objectForKey:@"catalogNum"];
        description = [course objectForKey:@"description"];
        parseId = [course objectId];
        editMode = FALSE;
    }
    return self;
}


+(void)getMyCoursesWithCompletion:(void(^)(NSArray *courses))completion
{
    
    PFQuery *q = [PFQuery queryWithClassName:@"Course"];
    [q whereKey:@"owner" equalTo:[PFUser currentUser].objectId];
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *arr = [NSMutableArray array];
        for (PFObject *obj in objects) {
            Course *temp = [[Course alloc] initWithPFObject:obj];
            temp.isNew = FALSE;
            [arr addObject:temp];
        }
        completion(arr);
    }];
}

-(void)deleteFromParse
{
    PFObject *course = [PFObject objectWithoutDataWithClassName:@"Course" objectId:parseId];
    [course deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"Delete finished successfully");
        }
        if(error){
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void)saveToParse
{
    PFObject *course = [PFObject objectWithClassName:@"Course"];
    [course setObject:school forKey:@"school"];
    [course setObject:schoolCode forKey:@"schoolCode"];
    [course setObject:subjectCode forKey:@"subjectCode"];
    [course setObject:subject forKey:@"subject"];
    [course setObject:catalogNum forKey:@"catalogNum"];
    [course setObject:description forKey:@"description"];
    [course setObject:[PFUser currentUser].objectId forKey:@"owner"];
    [course saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Succesful save!!!");
        }
        self.isNew = TRUE;
        parseId = course.objectId;
        [delegate course:self finishedSavingWithError:error];
    }];
    
}


@end
