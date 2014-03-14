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
#import "MyMatchesViewController.h"

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
    
    //nav bar
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBarTintColor:SECONDARYCOLOR];
    [self.navigationController.navigationBar setTintColor:MAINCOLOR];
    
    //nav bar buttons
    UIButton *settingsBtn = [[UIButton alloc] initWithFrame:BARBUTTONFRAME];
    UIImage *settings = [UIImage imageNamed:@"settings.png"];
    [settingsBtn setImage:settings forState:UIControlStateNormal];
    [settingsBtn addTarget:self action:@selector(settingsBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingsBtn];
    self.navigationItem.rightBarButtonItem = settingsBarButton;
    
    UIButton *myCoursesBtn = [[UIButton alloc] initWithFrame:BARBUTTONFRAME];
    UIImage *menuImg = [self changeImage:[UIImage imageNamed:@"hollowMenu.png"] toColor:[UIColor whiteColor]];
    [myCoursesBtn setImage:menuImg forState:UIControlStateNormal];
    [myCoursesBtn addTarget:self action:@selector(seeMyCourses) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *myCoursesBarButton = [[UIBarButtonItem alloc] initWithCustomView:myCoursesBtn];
    self.navigationItem.leftBarButtonItem = myCoursesBarButton;
   
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, NAVBARHEIGHT)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleView setText:@"Study Bunny"];
    [titleView setFont:[UIFont fontWithName:FONT size:28.0]];
    [titleView setTextAlignment:NSTextAlignmentCenter];
    [titleView setTextColor:[UIColor whiteColor]];
    [self.navigationItem setTitleView:titleView];
    
    
    [self.view setBackgroundColor:MAINCOLOR];

    CGFloat bunnyFrame = 185;
    UIView *bunnyCircle = [[UIView alloc] initWithFrame:CGRectMake((DEVICEWIDTH-bunnyFrame)/2, DEVICEHEIGHT/4-20, bunnyFrame, bunnyFrame)];
    [bunnyCircle setBackgroundColor:SECONDARYCOLOR];
    [bunnyCircle.layer setCornerRadius:bunnyFrame/2];
    [self.view addSubview:bunnyCircle];
    
    CGFloat bunnyImgFrame = 120;
    UIImageView *bunny = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bunnyImgFrame, bunnyImgFrame)];
    [bunny setCenter:bunnyCircle.center];
    UIImage *bunnyImg = [UIImage imageNamed:@"bunny.png"];
    [bunny setImage:[self changeImage:bunnyImg toColor:[UIColor whiteColor]]];
    [self.view addSubview:bunny];
    
    CGFloat buttonHeight = 50;
    CGFloat buttonOffset = 70;
    SBButton *studyNow = [[SBButton alloc] initWithFrame:CGRectMake(60, 3*DEVICEHEIGHT/5, 200, buttonHeight)];
    [studyNow setTitle:@"Study Now" forState:UIControlStateNormal];
    [studyNow addTarget:self action:@selector(studyNow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:studyNow];
    
    SBButton *findMatches = [[SBButton alloc] initWithFrame:CGRectMake(60, 3*DEVICEHEIGHT/5+buttonOffset, 200, buttonHeight)];
    [findMatches setTitle:@"Find Matches" forState:UIControlStateNormal];
    [findMatches addTarget:self action:@selector(findMatches) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:findMatches];
    
    SBButton *myMatches = [[SBButton alloc] initWithFrame:CGRectMake(60, 3*DEVICEHEIGHT/5+2*buttonOffset, 200, buttonHeight)];
    [myMatches setTitle:@"My Matches" forState:UIControlStateNormal];
    [myMatches addTarget:self action:@selector(seeMyMatches) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myMatches];
    
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"Succesful facebook request!\n");
        }
        else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [PFUser logOut];
            [self.navigationController popToRootViewControllerAnimated:YES];
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

-(void)seeMyMatches
{
    [self.navigationController pushViewController:[[MyMatchesViewController alloc] initWithNibName:nil bundle:nil] animated:NO];
}

-(void)seeMyCourses
{
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[[MyCoursesViewController alloc] init]] animated:YES completion:^{
        
    }];
}

- (void)settingsBtnHandler
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    settingsViewController.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:settingsViewController] animated:YES completion:NULL];
}

- (void)didLogout
{
    
    [[[LocationGetter sharedInstance] timer] invalidate];
    [PFUser logOut]; // Log out
    
    // Return to login page
    [self.navigationController popToRootViewControllerAnimated:NO];
    
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
