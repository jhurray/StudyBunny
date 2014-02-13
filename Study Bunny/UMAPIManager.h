//
//  UMAPIManager.h
//  Study Bunny
//
//  Created by Gregoire on 2/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <Foundation/Foundation.h>

//blocks
typedef void (^UMAPIBlock)(NSDictionary *dict);

@interface UMAPIManager : NSObject

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *refreshToken;

-(NSString *)getAuthToken;
+(void)getCampusesWithCompletion:(UMAPIBlock)block;
+(void)askForAuthToken;



@end
