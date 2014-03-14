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

#define PHONEPROMPT @"Please enter your phone number..."
#define EMAILPROMPT @"Please enter your email address..."

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize loginBtn, phoneInput, bunnyCircle, bunny, done, phoneNum, email;

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
    [prompt setTextColor:SECONDARYCOLOR];
    [prompt setFont:[UIFont fontWithName:FONT size:48.0]];
    [prompt setBackgroundColor:[UIColor clearColor]];
    [prompt setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:prompt];
    
    CGFloat promptBottom = prompt.frame.origin.y + prompt.frame.size.height;
    CGFloat inputMiddle = (DEVICEHEIGHT-promptBottom-KEYBOARDHEIGHT)/2 + promptBottom;
    CGFloat inputHeight = DEVICEHEIGHT/9;
    phoneInput = [[SBTextField alloc] initWithFrame:CGRectMake(0, inputMiddle-inputHeight, DEVICEWIDTH, inputHeight)];
    [phoneInput setDelegate:self];
    [phoneInput setText:PHONEPROMPT];
    [phoneInput setAlpha:0];
    [phoneInput setKeyboardType:UIKeyboardTypeDecimalPad];
    [phoneInput setReturnKeyType:UIReturnKeyDone];
    [self.view addSubview:phoneInput];
    
    CGFloat inputBottom = phoneInput.frame.origin.y + phoneInput.frame.size.height;
    CGFloat doneMiddle = (DEVICEHEIGHT-inputBottom-KEYBOARDHEIGHT)/2 + inputBottom;
    CGFloat doneHeight = DEVICEHEIGHT/13;
    done = [[SBButton alloc] initWithFrame:CGRectMake(110, doneMiddle-doneHeight/2, DEVICEWIDTH-220, doneHeight)];
    [done setTitle:@"Done" forState:UIControlStateNormal];
    [done addTarget:self  action:@selector(startEmailInput) forControlEvents:UIControlEventTouchUpInside];
    [done setAlpha:0];
    
    CGFloat bunnyFrame = 195;
    bunnyCircle = [[UIView alloc] initWithFrame:CGRectMake((DEVICEWIDTH-bunnyFrame)/2, DEVICEHEIGHT/3-15, bunnyFrame, bunnyFrame)];
    [bunnyCircle setBackgroundColor:SECONDARYCOLOR];
    [bunnyCircle.layer setCornerRadius:bunnyFrame/2];
    [self.view addSubview:bunnyCircle];
    
    CGFloat bunnyImgFrame = 140;
    bunny = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bunnyImgFrame, bunnyImgFrame)];
    [bunny setCenter:bunnyCircle.center];
    UIImage *bunnyImg = [UIImage imageNamed:@"bunny.png"];
    [bunny setImage:[self changeImage:bunnyImg toColor:MAINCOLOR]];
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
                NSLog(@"Uh oh. An error occurred: \n\n%@", error);
            }
        } else if (!user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            
            //adding a column to user table
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self animatePhoneInput];

        } else {
            
            NSLog(@"User with facebook logged in!");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.navigationController pushViewController:[[MasterViewController alloc] init] animated:NO];

        }
    }];
    [MBProgressHUD showHUDAddedTo:self.view withText:@"Logging in..."];
}

-(void)animateDoneBtn
{
    [self.view addSubview:done];
    [UIView animateWithDuration:0.5 delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [done setAlpha:1.0];
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void)startEmailInput
{
    if (done.tag == 1) {
        email = phoneInput.text;
        [self animateReversePhoneInput];
        return;
    }
    
    phoneNum = phoneInput.text;
    [phoneInput setKeyboardType:UIKeyboardTypeEmailAddress];
    [phoneInput setText:EMAILPROMPT];
    [phoneInput setTextColor:MAINCOLOR];
    [done setTag:1];
    [done removeFromSuperview];
    [done setAlpha:0];
    [phoneInput reloadInputViews];
}

-(void)animateReversePhoneInput
{
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [phoneInput setAlpha:0.0];
                         [done setAlpha:0];
                     } completion:^(BOOL finished) {
                         [phoneInput removeFromSuperview];
                         [done removeFromSuperview];
                         [phoneInput resignFirstResponder];
                         [UIView animateWithDuration:0.4 delay:0
                                             options:UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              
                                              [bunnyCircle setAlpha:1.0];
                                              [bunny setAlpha:1.0];
                                              
                                          } completion:^(BOOL finished) {
                                              [self getNewUserFacebookInfoWithPhoneNumber];
                                          }];
                     }];
}

-(void)animatePhoneInput
{
    [UIView animateWithDuration:0.4 delay:0
                    options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [bunnyCircle setAlpha:0];
                         [bunny setAlpha:0];
                         
                     } completion:^(BOOL finished) {
                         if (![self.view.subviews containsObject:phoneInput]) {
                             [phoneInput setText:PHONEPROMPT];
                             [self.view addSubview:phoneInput];
                         }
                         [phoneInput becomeFirstResponder];
                         [UIView animateWithDuration:0.4 delay:0
                                             options:UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              [phoneInput setAlpha:0.8];
                                              
                                          } completion:^(BOOL finished) {
                                              
                                          }];
                     }];
}

-(void)getNewUserFacebookInfoWithPhoneNumber
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"Facebook request started!\n" );
        if (!error) {
            
             NSDictionary *userData = (NSDictionary *)result;
            [[PFUser currentUser] setObject:userData[@"id"] forKey:@"facebook_id"];
            [[PFUser currentUser] setObject:userData[@"name"] forKey:@"name"];
            [[PFUser currentUser] setObject:phoneNum forKey:@"phoneNumber"];
            [[PFUser currentUser] setObject:email forKey:@"email"];
            [[PFUser currentUser] setObject:[NSArray array] forKey:@"madeMatches"];
            [[PFUser currentUser] setObject:[NSArray array] forKey:@"pendingMatches"];
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
    [MBProgressHUD showHUDAddedTo:self.view withText:@"Finishing Login..."];
}

// ********************************************** TEXT FIELD DELEGATE METHODS ****************************************************//



-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    /*
    if([textField.text isEqualToString:@"  Please enter your phone number  "]){
        [textField setTextColor:MAINCOLOR];
        [textField setText:@""];
    }
     */
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"ending yeee");
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField.text isEqualToString:PHONEPROMPT] || [textField.text isEqualToString:@""] ){
        return NO;
    }
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    // this is here to get rid of prompt
    NSUInteger futureLength = [textField.text length]+1;
    if (futureLength > 12 && ([textField.text isEqualToString:PHONEPROMPT] || [textField.text isEqualToString:EMAILPROMPT])) {
        // to get rid of the prompt
        textField.text = @"";
        [textField setTextColor:MAINCOLOR];
        return YES;
    }
    
    // this is here for email address
    if (done.tag == 1) {
        NSRange range = [textField.text rangeOfString:@"@"];
        if (range.location != NSNotFound)
        {
            NSRange range = [textField.text rangeOfString:@"."];
            if (range.location != NSNotFound)
            {
                [self animateDoneBtn];
            }
        }
        return YES;
    }
    
    if (futureLength == 11 && ![string isEqualToString:@""]) {
        // to prevent more than 10 digits
        return NO;
    }
    if(futureLength >= 10){
        // for backspaces
        if ([string isEqualToString:@""]) {
            [done setAlpha:0];
            [done removeFromSuperview];
            return YES;
        }
        // for being done
        if(![self.view.subviews containsObject:done]){
            [self animateDoneBtn];
        }
        return YES;
    }
    else{
        
        return YES;
    }
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
