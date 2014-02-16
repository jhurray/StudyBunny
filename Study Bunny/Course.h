//
//  Course.h
//  Study Bunny
//
//  Created by Gregoire on 2/13/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Course : NSObject

@property (nonatomic, strong) NSString *school;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *schoolCode;
@property (nonatomic, strong) NSString *subjectCode;
@property (nonatomic, strong) NSString *catalogNum;
@property (nonatomic, strong) NSString *description;

@end
