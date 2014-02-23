//
//  Course.h
//  Study Bunny
//
//  Created by Gregoire on 2/13/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Course;

@protocol CourseDelegate <NSObject>

@optional
-(void)course:(Course *)course finishedSavingWithError:(NSError *)error;

@end

@interface Course : NSObject

@property (nonatomic, weak) id <CourseDelegate> delegate;
@property (nonatomic, strong) NSString *school;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *schoolCode;
@property (nonatomic, strong) NSString *subjectCode;
@property (nonatomic, strong) NSString *catalogNum;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *parseId;
@property (nonatomic) BOOL isNew;
@property (nonatomic) BOOL editMode;

-(void)saveToParse;
-(void)deleteFromParse;
+(void)getMyCoursesWithCompletion:(void(^)(NSArray *courses))completion;

@end
