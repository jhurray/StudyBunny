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
        loginBtn = [[SBButton alloc] initWithFrame:CGRectMake(30, (DEVICEHEIGHT/4)*3, 260, 70)];
        [loginBtn setTitle:@"Login with Facebook" forState:UIControlStateNormal];
        [loginBtn addTarget:self action:@selector(loginWithFacebook) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    
    
    [self.view setBackgroundColor:MAINCOLOR];
    
    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(15, DEVICEHEIGHT/10, DEVICEWIDTH-30, DEVICEHEIGHT/12)];
    [prompt setText:[NSString stringWithFormat:@"Study Bunny"]];
    [prompt setTextAlignment:NSTextAlignmentCenter];
    [prompt setTextColor:[UIColor whiteColor]];
    [prompt setFont:[UIFont fontWithName:FONT size:48.0]];
    [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:prompt];
    
    CGFloat bunnyFrame = 195;
    UIView *orangeCircle = [[UIView alloc] initWithFrame:CGRectMake((DEVICEWIDTH-bunnyFrame)/2, DEVICEHEIGHT/3-15, bunnyFrame, bunnyFrame)];
    [orangeCircle setBackgroundColor:SECONDARYCOLOR];
    [orangeCircle.layer setCornerRadius:bunnyFrame/2];
    [self.view addSubview:orangeCircle];
    
    CGFloat bunnyImgFrame = 140;
    UIImageView *bunny = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bunnyImgFrame, bunnyImgFrame)];
    [bunny setCenter:orangeCircle.center];
    UIImage *bunnyImg = [UIImage imageNamed:@"bunny.png"];
    [bunny setImage:[self changeImage:bunnyImg toColor:[UIColor whiteColor]]];
    [self.view addSubview:bunny];
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
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
    [MBProgressHUD showHUDAddedTo:self.view withText:@"Logging in..."];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage *)changeImage:(UIImage *)image toColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 140, 140);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    return flippedImage;
}

@end
