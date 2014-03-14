//
//  MyMatchesViewController.m
//  Study Bunny
//
//  Created by Gregoire on 3/13/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MyMatchesViewController.h"

@interface MyMatchesViewController ()

@end

@implementation MyMatchesViewController

@synthesize tableView = _tableView, titleView, myCourses, matcher, matchedUsers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        matchedUsers = [NSMutableArray array];
        myCourses = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    self.navigationItem.hidesBackButton = NO;
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIFont fontWithName:FONT size:18.0f],NSFontAttributeName,
                                                          nil] forState:UIControlStateNormal];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBarTintColor:SECONDARYCOLOR];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    UIImageView *bunnyBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, DEVICEWIDTH, DEVICEHEIGHT-20)];
    [bunnyBack setImage:[self changeImage:[UIImage imageNamed:@"bunny.png"] toColor:TERTIARYCOLOR]];
    
    titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, NAVBARHEIGHT)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleView setText:@"My Matches"];
    [titleView setFont:[UIFont fontWithName:FONT size:20.0]];
    [titleView setTextAlignment:NSTextAlignmentCenter];
    [titleView setTextColor:[UIColor whiteColor]];
    [self.navigationItem setTitleView:titleView];
    
    //background view
    [self.view addSubview:bunnyBack];
    
	//Table view setup
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBARHEIGHT+STATUSBARHEIGHT, DEVICEWIDTH, DEVICEHEIGHT-NAVBARHEIGHT-STATUSBARHEIGHT) style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[UIColor whiteColor]];
    [_tableView setAlpha:0.9];
    [_tableView setTintColor:TERTIARYCOLOR];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView registerClass:[MyMatchesTableViewCell class] forCellReuseIdentifier:@"MyMatchCell"];
    [self.view addSubview:_tableView];
    
    // match maker goes here
    matcher = [[SBMatchMaker alloc] init];
    matcher.delegate = self;
    [matcher getMatches];
    
    [MBProgressHUD showHUDAddedTo:self.view withText:@"Finding Matches..."];
    
}

// ----------------------------------------- SELECTOR METHODS  -----------------------------------------//

-(void)fetchMatchedUsers
{
    PFQuery *q = [PFUser query];
    [q whereKey:@"objectId" containedIn:[NSArray arrayWithArray:[[PFUser currentUser] objectForKey:@"madeMatches" ]]];
    [q orderByAscending:@"name"];
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: failed fetching matched users %@\n", error.localizedDescription);
            return;
        }
        NSLog(@"\nuser objects count is %lu\n", (unsigned long)objects.count);
        for (PFUser *u in objects)
        {
            MatchedUser *mu = [[MatchedUser alloc] initWithPFUser:u];
            mu.matchedCourses = [matcher.usersMappedToCourses objectForKey:mu.userId];
            [matchedUsers addObject:mu];
        }
        [_tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

// ------------------------------------------ MY MATCHES TVC DELEGATE METHODS ---------------------------------//



-(void)contactRequest:(BOOL)byPhone withContactInfo:(NSString *)info
{
    NSLog(@"CONTACT REQUEST PRESSED!!");
    
    
    if (byPhone) {
        [self showSMS:info];
    }
    else
    {
        [self sendEmailTo:info];
    }
}

-(void)blockRequest
{
     NSLog(@"BLOCK REQUEST PRESSED!!");
}

// *************************************** SEND TEXT ****************************************************//

- (void)showSMS:(NSString*)number {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = [NSArray arrayWithObject:number];
    NSString *message = [NSString stringWithFormat:@"Message from %@, a match on Study Bunny:\n\n", [[PFUser currentUser] objectForKey:@"name"] ];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// *************************************** SEND EMAIL ****************************************************//

- (void)sendEmailTo:(NSString *)address{
    NSLog(@"So you want to email...");
    if ([MFMailComposeViewController canSendMail])
    {
        NSLog(@"Well now you can start!");
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Lets Study!"];
        [mailViewController setToRecipients:[NSArray arrayWithObject:address]];
        //mailViewController.navigationBar.barStyle = UIBarStyleBlack;
        mailViewController.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
        [mailViewController setMessageBody:[NSString stringWithFormat:@"Message from %@, a match on Study Bunny:\n\n", [[PFUser currentUser] objectForKey:@"name"] ] isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:^{
            NSLog(@"GOGOGO!");
        }];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"Cant Send Email Right Now."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)finishedWithEmail:(NSString *)email body:(NSString *)body {
    
    
}


-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if(result == MFMailComposeResultCancelled){
        return;
    }
    NSLog(@"Succesful email sent!");
}

- (void)canceled{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}



// ------------------------------------------ MATCH MAKER DELEGATE METHODS ---------------------------------//

-(void)matchesMade:(SBMatchMaker *)matchMaker WithError:(NSError *)error
{
    if (error) {
        NSLog(@"Error in MacthesMadeWithError: %@\n", error.localizedDescription);
        
        // alert view here
        
        return;
    }
    myCourses = matchMaker.myCourses;
    NSLog(@"Mapped dictionary is \n%@\n", matchMaker.usersMappedToCourses);
    [[MBProgressHUD HUDForView:self.view] setLabelText:@"Loading Matches..."];
    [self fetchMatchedUsers];
}


// ------------------------------------------ TABLE VIEW DELEGATE METHODS ---------------------------------//

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MYMATCHCELLHEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [matchedUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"MatchCell";
    
    MyMatchesTableViewCell *cell = (MyMatchesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[MyMatchesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setDelegate:self];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setTintColor:TERTIARYCOLOR];
    [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    MatchedUser *user = [matchedUsers objectAtIndex:indexPath.row];
    [cell setCellFeaturesWithMatchedUser:user];

    
    
    //cell.textLabel.text = [NSString stringWithFormat:@"%@ has %lu matches", user.name, user.matchedCourses.count];
    
    return cell;
}

// ------------------------------------------ MEMORY WARNING ---------------------------------//

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
