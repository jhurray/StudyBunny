//
//  MasterViewController.m
//  Study Bunny
//
//  Created by Gregoire on 2/1/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //login button
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setFrame:CGRectMake(60, 3*DEVICEHEIGHT/4 - DEVICEHEIGHT/10, 200, DEVICEHEIGHT/5)];
    [logoutBtn setBackgroundColor:[UIColor clearColor]];
    [logoutBtn setTitle:@"Logout Prease" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [logoutBtn.layer setBorderColor:[UIColor blueColor].CGColor];
    [logoutBtn.layer setBorderWidth:3];
    [logoutBtn.layer setCornerRadius:30];
    [logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutBtn];
    
    UILabel *helloWorld = [[UILabel alloc] initWithFrame:CGRectMake(0, DEVICEHEIGHT/4 - DEVICEHEIGHT/10, DEVICEWIDTH, DEVICEHEIGHT/5)];
    [helloWorld setText:@"Hello World!"];
    [helloWorld setTextAlignment:NSTextAlignmentCenter];
    [helloWorld setTextColor:[UIColor blueColor]];
    [helloWorld setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:helloWorld];
    
    UILabel *userInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 2*DEVICEHEIGHT/4 - DEVICEHEIGHT/10, DEVICEWIDTH, DEVICEHEIGHT/5)];
    [userInfo setTextAlignment:NSTextAlignmentCenter];
    [userInfo setTextColor:[UIColor blueColor]];
    [userInfo setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:userInfo];
    
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            NSString *name = userData[@"name"];
            
            userInfo.text = name;
        }
        else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [self logout];
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
    
}

-(void)logout
{
    [PFUser logOut]; // Log out
    
    // Return to login page
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
