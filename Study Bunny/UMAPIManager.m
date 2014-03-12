//
//  UMAPIManager.m
//  Study Bunny
//
//  Created by Gregoire on 2/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "UMAPIManager.h"

@implementation UMAPIManager

@synthesize refreshToken, authToken;

static UMAPIManager *sharedClient;

+(void)grabSharedClient{
    if(!sharedClient){
        sharedClient = [[UMAPIManager alloc] init];
       [UMAPIManager askForAuthTokenWithBlock:^{
           NSLog(@"Got me that singleton son");
       }];
    }
}

+(void)askForAuthTokenWithBlock:(void(^)(void))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //[UMAPIManager grabSharedClient];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api-km.it.umich.edu/token?grant_type=client_credentials&scope=PRODUCTION"]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        //https://api.it.umich.edu/store/site/pages/subscriptions.jag
        [request setValue:[NSString stringWithFormat:@"Basic %@", KEYSECRET64] forHTTPHeaderField:@"Authorization"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        NSError *error;
        NSURLResponse *response;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            NSLog(@"\n An error occured: %@\n", error.description);
            [UMAPIManager askForAuthTokenWithBlock:^{
                NSLog(@"Grabbed on second try...");
            }];
            return;
        }
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@", dictionary);
        if([dictionary objectForKey:@"refresh_token"]){
            sharedClient.refreshToken = [dictionary objectForKey:@"refresh_token"];
        }
        if ([dictionary objectForKey:@"access_token"]) {
            sharedClient.authToken = [dictionary objectForKey:@"access_token"];
            
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    });
    
}


+(void)refreshAuthTokenWithBlock:(void(^)(void))block
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //[UMAPIManager grabSharedClient];   dont need sould be created
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api-km.it.umich.edu/token?grant_type=refresh_token&refresh_token=%@&scope=PRODUCTION", sharedClient.refreshToken]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        //https://api.it.umich.edu/store/site/pages/subscriptions.jag
        [request setValue:[NSString stringWithFormat:@"Basic %@", KEYSECRET64] forHTTPHeaderField:@"Authorization"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        NSError *error;
        NSURLResponse *response;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            NSLog(@"\n An error occured: %@\n", error.description);
            return;
        }
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@", dictionary);
        if([dictionary objectForKey:@"refresh_token"]){
            sharedClient.refreshToken = [dictionary objectForKey:@"refresh_token"];
        }
        if ([dictionary objectForKey:@"access_token"]) {
            sharedClient.authToken = [dictionary objectForKey:@"access_token"];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    });
    
    
}


+(void)getCoursesWithSchoolCode:(NSString *)code andSubject:(NSString *)subject andCompletion:(UMAPIBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[UMAPIManager grabSharedClient];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api-gw.it.umich.edu/Curriculum/SOC/v1/Terms/%@/Schools/%@/Subjects/%@/CatalogNbrs", WN14, code, subject ]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setURL:url];
        [request setHTTPMethod:@"GET"];
        //https://api.it.umich.edu/store/site/pages/subscriptions.jag
        [request setValue:[NSString stringWithFormat:@"Bearer %@", sharedClient.authToken] forHTTPHeaderField:@"Authorization"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSError *error;
        NSURLResponse *response;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            //gets the token then recalls itself
            [UMAPIManager askForAuthTokenWithBlock:^{
                [UMAPIManager getCoursesWithSchoolCode:code andSubject:subject andCompletion:^(NSDictionary *dict) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        block(dict[@"getSOCCtlgNbrsResponse"]);
                    });
                }];
            }];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(dictionary[@"getSOCCtlgNbrsResponse"]);
        });
        
    });
    
    
}


+(void)getSubjectsWithSchoolCode:(NSString *)code andCompletion:(UMAPIBlock)block
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[UMAPIManager grabSharedClient];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api-gw.it.umich.edu/Curriculum/SOC/v1/Terms/%@/Schools/%@/Subjects",WN14 , code ]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setURL:url];
        [request setHTTPMethod:@"GET"];
        //https://api.it.umich.edu/store/site/pages/subscriptions.jag
        [request setValue:[NSString stringWithFormat:@"Bearer %@", sharedClient.authToken] forHTTPHeaderField:@"Authorization"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSError *error;
        NSURLResponse *response;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            //gets the token then recalls itself
            [UMAPIManager askForAuthTokenWithBlock:^{
                [UMAPIManager getSubjectsWithSchoolCode:code andCompletion:^(NSDictionary *dict) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        block(dict[@"getSOCSubjectsResponse"]);
                    });
                }];
            }];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(dictionary[@"getSOCSubjectsResponse"]);
        });
        
    });
    
    
}





+(void)getSchoolsWithCompletion:(UMAPIBlock)block
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[UMAPIManager grabSharedClient];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api-gw.it.umich.edu/Curriculum/SOC/v1/Terms/%@/Schools" , WN14]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setURL:url];
        [request setHTTPMethod:@"GET"];
        //https://api.it.umich.edu/store/site/pages/subscriptions.jag
        [request setValue:[NSString stringWithFormat:@"Bearer %@", sharedClient.authToken] forHTTPHeaderField:@"Authorization"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSError *error;
        NSURLResponse *response;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            //gets the token then recalls itself
            [UMAPIManager askForAuthTokenWithBlock:^{
                [UMAPIManager getSchoolsWithCompletion:^(NSDictionary *dict) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        block(dict[@"getSOCSchoolsResponse"]);
                    });
                }];
            }];
        }
        NSLog(@"%@", dictionary);
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(dictionary[@"getSOCSchoolsResponse"]);
        });
        
    });
    
    
}


+(void)getCampusesWithCompletion:(UMAPIBlock)block
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[UMAPIManager grabSharedClient];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api-gw.it.umich.edu/Facilities/Buildings/v1/Campuses" ]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setURL:url];
        [request setHTTPMethod:@"GET"];
        //https://api.it.umich.edu/store/site/pages/subscriptions.jag
        [request setValue:[NSString stringWithFormat:@"Bearer %@", sharedClient.authToken] forHTTPHeaderField:@"Authorization"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSError *error;
        NSURLResponse *response;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            //gets the token then recalls itself
            [UMAPIManager refreshAuthTokenWithBlock:^{
                [UMAPIManager getCampusesWithCompletion:^(NSDictionary *dict) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        block(dict);
                    });
                }];
            }];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(dictionary);
        });
        
    });
    
    
}

// ------------------------------------   HELPER FUNCS ------------------------------------------ //
-(void)reauthorize{
    if(sharedClient.refreshToken){
        
    }
}

-(NSString *)getAuthToken{
    return sharedClient.authToken;
}

@end
