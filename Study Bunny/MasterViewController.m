//
//  MasterViewController.m
//  Study Bunny
//
//  Created by Gregoire on 2/1/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MasterViewController.h"
#import "UMAPIManager.h"
#import "MyCoursesViewController.h"
#import "MapViewController.h"
#import "MatchPickerViewController.h"

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
    
    //set up singletons
    [UMAPIManager grabSharedClient];
    [[LocationGetter sharedInstance] startUpdates];
    
	// Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setBarTintColor:SECONDARYCOLOR];
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //nav bar buttons
    UIButton *settingsBtn = [[UIButton alloc] initWithFrame:BARBUTTONFRAME];
    UIImage *settings = [UIImage imageNamed:@"settings.png"];
    [settingsBtn setImage:settings forState:UIControlStateNormal];
    [settingsBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingsBtn];
    self.navigationItem.rightBarButtonItem = settingsBarButton;
    
   
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, NAVBARHEIGHT)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleView setText:@"Study Bunny"];
    [titleView setFont:[UIFont fontWithName:FONT size:28.0]];
    [titleView setTextAlignment:NSTextAlignmentCenter];
    [titleView setTextColor:[UIColor whiteColor]];
    [self.navigationItem setTitleView:titleView];
    
    
    [self.view setBackgroundColor:MAINCOLOR];

    
    UILabel *helloWorld = [[UILabel alloc] initWithFrame:CGRectMake(15, DEVICEHEIGHT/8, DEVICEWIDTH-30, DEVICEHEIGHT/12)];
    [helloWorld setText:[NSString stringWithFormat:@"Hello!"]];
    [helloWorld setTextAlignment:NSTextAlignmentCenter];
    [helloWorld setTextColor:[UIColor whiteColor]];
    [helloWorld setFont:[UIFont fontWithName:FONT size:24.0]];
    [helloWorld setBackgroundColor:[UIColor clearColor]];
    [helloWorld setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:helloWorld];
    
    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(15, DEVICEHEIGHT/8 + DEVICEHEIGHT/12-10, DEVICEWIDTH-30, DEVICEHEIGHT/12)];
    [prompt setText:[NSString stringWithFormat:@"Ready to Study?"]];
    [prompt setTextAlignment:NSTextAlignmentCenter];
    [prompt setTextColor:[UIColor whiteColor]];
    [prompt setFont:[UIFont fontWithName:FONT size:24.0]];
    [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:prompt];
    
    CGFloat bunnyFrame = 145;
    UIView *orangeCircle = [[UIView alloc] initWithFrame:CGRectMake((DEVICEWIDTH-bunnyFrame)/2, DEVICEHEIGHT/3-20, bunnyFrame, bunnyFrame)];
    [orangeCircle setBackgroundColor:SECONDARYCOLOR];
    [orangeCircle.layer setCornerRadius:bunnyFrame/2];
    [self.view addSubview:orangeCircle];
    
    CGFloat bunnyImgFrame = 100;
    UIImageView *bunny = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bunnyImgFrame, bunnyImgFrame)];
    [bunny setCenter:orangeCircle.center];
    UIImage *bunnyImg = [UIImage imageNamed:@"bunny.png"];
    [bunny setImage:[self changeImage:bunnyImg toColor:[UIColor whiteColor]]];
    [self.view addSubview:bunny];
    
    CGFloat buttonHeight = 50;
    CGFloat buttonOffset = 70;
    SBButton *studyNow = [[SBButton alloc] initWithFrame:CGRectMake(60, 3*DEVICEHEIGHT/5, 200, buttonHeight)];
    [studyNow setTitle:@"Study Now" forState:UIControlStateNormal];
    [studyNow addTarget:self action:@selector(studyNow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:studyNow];
    
    SBButton *myCourses = [[SBButton alloc] initWithFrame:CGRectMake(60, 3*DEVICEHEIGHT/5+buttonOffset, 200, buttonHeight)];
    [myCourses setTitle:@"My Courses" forState:UIControlStateNormal];
    [myCourses addTarget:self action:@selector(seeMyCourses) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myCourses];
    
    SBButton *findMatches = [[SBButton alloc] initWithFrame:CGRectMake(60, 3*DEVICEHEIGHT/5+2*buttonOffset, 200, buttonHeight)];
    [findMatches setTitle:@"Find Matches" forState:UIControlStateNormal];
    [findMatches addTarget:self action:@selector(findMatches) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:findMatches];
    
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            NSString *name = userData[@"name"];
            NSLog(@"Succesful facebook request!\n");
            //animate name change
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                [helloWorld setText:[NSString stringWithFormat:@"Hello %@!", name]];
            } completion:nil];
        }
        else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [self logout];
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
    
}

-(void) findMatches
{
    [self.navigationController pushViewController:[[MatchPickerViewController alloc] init] animated:NO];
}

-(void)studyNow
{
    [self.navigationController pushViewController:[[MapViewController alloc] initWithNibName:nil bundle:nil] animated:NO];
}

-(void)seeMyCourses
{
    [self.navigationController pushViewController:[[MyCoursesViewController alloc] init] animated:NO];
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

-(UIImage *)changeImage:(UIImage *)image toColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 100, 100);
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
