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
       [UMAPIManager askForAuthToken];
    }
}

+(void)askForAuthToken
{
    [UMAPIManager grabSharedClient];
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
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@", dictionary);
    sharedClient.refreshToken = [dictionary objectForKey:@"refresh_token"];
    sharedClient.authToken = [dictionary objectForKey:@"access_token"];
}

+(void)getCampusesWithCompletion:(UMAPIBlock)block
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [UMAPIManager grabSharedClient];
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
            [UMAPIManager askForAuthToken];
            [UMAPIManager getCampusesWithCompletion:^(NSDictionary *dict) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    block(dict);
                });
            }];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(dictionary);
        });
        
    });
    
    
}

// ------------------------------------   HELPER FUNCS ------------------------------------------ //
-(NSString *)getAuthToken{
    return sharedClient.authToken;
}

@end
