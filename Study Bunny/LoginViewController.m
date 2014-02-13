//
//  LoginViewController.m
//  Study Bunny
//
//  Created by Gregoire on 2/1/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "LoginViewController.h"
#import "MasterViewController.h"
#import "MBProgressHUD.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize loginBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self.navigationController setNavigationBarHidden:YES];
        //login button
        loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginBtn setFrame:CGRectMake(60, (DEVICEHEIGHT/4)*3, 200, 80)];
        [loginBtn setBackgroundColor:[UIColor clearColor]];
        [loginBtn setTitle:@"Login with Facebook" forState:UIControlStateNormal];
        [loginBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [loginBtn.layer setBorderColor:[UIColor blueColor].CGColor];
        [loginBtn.layer setBorderWidth:3];
        [loginBtn.layer setCornerRadius:30];
        [loginBtn addTarget:self action:@selector(loginWithFacebook) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    // add all subviews
    [self.view addSubview:loginBtn];
    
    
    // bypass login screen if user is already cached
    if ([PFUser currentUser] && // Check if a user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) // Check if user is linked to Facebook
    {
        NSLog(@"\n FB User already signed in\n");
        // Push the next view controller without animation
        [self.navigationController pushViewController:[[MasterViewController alloc] init] animated:NO];
    }
    
}

-(void)loginWithFacebook{
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            
            //adding a column to user table
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                NSLog(@"Facebook request started!\n" );
                if (!error) {
                    
                    [PFUser currentUser][@"facebook_id"] = @"blah";
                    [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"facebook_id"];
                    
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(succeeded){
                            NSLog(@"successful save!!");
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            [self.navigationController pushViewController:[[MasterViewController alloc] init] animated:NO];
                        }
                        else{
                            NSLog(@"%@", [error localizedDescription]);
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                            message:@"Something went wrong"
                                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                    }];
                    
                }
            }];

        } else {
            NSLog(@"User with facebook logged in!");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.navigationController pushViewController:[[MasterViewController alloc] init] animated:NO];
        }
    }];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
