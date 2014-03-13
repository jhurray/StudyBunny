//
//  MatchPickerViewController.m
//  Study Bunny
//
//  Created by Gregoire on 3/12/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MatchPickerViewController.h"
#import "MatchTableViewCell.h"

@interface MatchPickerViewController ()

@end

@implementation MatchPickerViewController
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
    [titleView setText:@"Find Matches"];
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
    [_tableView setTintColor:SECONDARYCOLOR];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView registerClass:[MatchTableViewCell class] forCellReuseIdentifier:@"MatchCell"];
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
    [q whereKey:@"objectId" containedIn:matcher.userMatches];
    [q orderByAscending:@"name"];
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: failed fetching matched users %@\n", error.localizedDescription);
            return;
        }
        NSLog(@"\nuser objects count is %lu\n", objects.count);
        for (PFUser *u in objects)
        {
            if ([matcher.madeMatches containsObject:u.objectId] ) {
                //continue;
            }
            MatchedUser *mu = [[MatchedUser alloc] initWithPFUser:u];
            mu.matchedCourses = [matcher.usersMappedToCourses objectForKey:mu.userId];
            [matchedUsers addObject:mu];
        }
        [_tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
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
    MatchTableViewCell *cell = (MatchTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    PFObject *match = [PFObject objectWithClassName:@"Match"];
    NSString *myUid = [PFUser currentUser].objectId;
    NSString *otherUid = ((MatchedUser *)[matchedUsers objectAtIndex:indexPath.row]).userId;
    // largest goes first!!!!
    if (myUid > otherUid) {
        [match setObject:myUid forKey:@"uid1"];
        [match setObject:otherUid forKey:@"uid2"];
    }
    else{
        [match setObject:otherUid forKey:@"uid1"];
        [match setObject:myUid forKey:@"uid2"];
    }
    PFQuery *q = [PFQuery queryWithClassName:@"Match"];
    [q whereKey:@"uid1" equalTo:match[@"uid1"]];
    [q whereKey:@"uid2" equalTo:match[@"uid2"]];
    [q whereKey:@"count" equalTo:[NSNumber numberWithInt:1]];
    
    if(cell.matchMade)
    {
        
        [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Match query sucked!!!... %@", error.localizedDescription);
                return ;
            }
            if (objects.count == 0) {
                // no match
                [match setObject:[NSNumber numberWithInt:1] forKey:@"count"];
                [match saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Match Not saved!!!... %@", error.localizedDescription);
                        return ;
                    }
                    
                    // manipulate the matcher
                    NSString *matchId = [matchedUsers objectAtIndex:indexPath.row];
                    [matcher.pendingMatches addObject:matchId];
                    NSLog(@"Succesful new match save!");
                }];
            }
            else{
                PFObject *qMatch = objects[0];
                [qMatch setObject:[NSNumber numberWithInt:2] forKey:@"count"];
                [qMatch saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Match Not saved!!!... %@", error.localizedDescription);
                        return ;
                    }
                    
                    // manipulate the matcher
                    NSString *matchId = [matchedUsers objectAtIndex:indexPath.row];
                    [matcher.madeMatches addObject:matchId];
                    [matcher. pendingMatches removeObject:matchId];
                    NSLog(@"Succesful match updated!");
                }];
            }
        }];
        
    }
    else{
        
        // delete the shit!!!!
        [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
           
            if (error) {
                NSLog(@"Match Not deleted!!!... %@", error.localizedDescription);
                return ;
            }
            for (PFObject *o in objects) {
                [o deleteInBackground];
                NSString *matchId = [matchedUsers objectAtIndex:indexPath.row];
                [matcher.pendingMatches removeObject:matchId];
            }
            
        }];
        
    }
    
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MATCHCELLHEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [matchedUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"MatchCell";
    
    MatchTableViewCell *cell = (MatchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[MatchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setTintColor:SECONDARYCOLOR];
    [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    MatchedUser *user = [matchedUsers objectAtIndex:indexPath.row];
    [cell setCellFeaturesWithMatchedUser:user];
    if ([matcher.pendingMatches containsObject:user.userId]) {
        cell.matchMade = TRUE;
    }
    if (cell.matchMade) {
        [cell makeHighlighted];
    }
    

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
