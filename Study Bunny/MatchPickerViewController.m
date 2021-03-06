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
    [_tableView setTintColor:TERTIARYCOLOR];
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
        NSLog(@"\nuser objects count is %lu\n", (unsigned long)objects.count);
        for (PFUser *u in objects)
        {
            // DELETE THIS BLOCK EVENTUALLY
            if ([matcher.madeMatches containsObject:u.objectId] ) {
                continue;
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
    
    if (cell.reentering) {
        return;
    }
    
    MatchedUser *matchedUser= ((MatchedUser *)[matchedUsers objectAtIndex:indexPath.row]);
    PFUser *me = [PFUser currentUser];
    
    if(cell.matchMade)
    {
        NSLog(@"\nIn cell selected: \nPending matches: %@\n\n made matches: %@\n\n", matchedUser.pendingMatches, matchedUser.madeMatches);
        if([matchedUser.pendingMatches containsObject:[PFUser currentUser].objectId])
        {
            //this is a made match!!! make it...
            //change mine
            [matcher.pendingMatches removeObject:matchedUser.userId];
            [matcher.madeMatches addObject:matchedUser.userId];
            //then change theirs
            [matchedUser.pendingMatches removeObject:me.objectId];
            [matchedUser.madeMatches addObject:me.objectId];
            //now save them
            [matchedUser saveAsPFUser];
            // now save me
            [me setObject:matcher.pendingMatches forKey:@"pendingMatches"];
            [me setObject:matcher.madeMatches forKey:@"madeMatches"];
            [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error)
                {
                    NSLog(@"Error saving myself after match... %@", error.localizedDescription);
                    return;
                }
                NSLog(@"Succesful made match save for myself!!!");
                PFObject *match = [PFObject objectWithClassName:@"Match"];
                [match setObject:me.objectId forKey:@"uid1"];
                [match setObject:matchedUser.userId forKey:@"uid2"];
                [match saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(error)
                    {
                        NSLog(@"Error saving myself after match... %@", error.localizedDescription);
                        return;
                    }
                    NSLog(@"Succesful save of match!!!");
                    [matchedUsers removeObject:matchedUser];
                    [_tableView reloadData];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                    message:[NSString stringWithFormat:@"You are matched with %@!", matchedUser.name]
                                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }];
            }];
        }
        else
        {
            // I am the first to make a match.... put into pending matches for me
            [matcher.pendingMatches addObject:matchedUser.userId];
            [me setObject:matcher.pendingMatches forKey:@"pendingMatches"];
            [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error)
                {
                    NSLog(@"Error saving myself after pending match... %@", error.localizedDescription);
                    return;
                }
                NSLog(@"Succesful pending match save for myself!!!");
            }];
        }
        
    }
    else{
        
        // delete the shit!!!!
        // I am the first to make a match.... put into pending matches for me
        [matcher.pendingMatches removeObject:matchedUser.userId];
        [me setObject:matcher.pendingMatches forKey:@"pendingMatches"];
        [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error)
            {
                NSLog(@"Error saving myself after deleting pending match... %@", error.localizedDescription);
                return;
            }
            NSLog(@"Succesful pending match delete for myself!!!");
        }];
        
    }
    
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MatchTableViewCell *mCell = (MatchTableViewCell *)cell;
    MatchedUser *user = [matchedUsers objectAtIndex:indexPath.row];
    
    //NSLog(@"\nIn Will display cell: \nPending matches: %@\n\n made matches: %@\n\n", matcher.pendingMatches, matcher.madeMatches);
    
    if ([matcher.pendingMatches containsObject:user.userId]) {
        mCell.matchMade = TRUE;
        [mCell makeHighlighted];
    }
    mCell.reentering = FALSE;
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
    [cell setTintColor:TERTIARYCOLOR];
    [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    MatchedUser *user = [matchedUsers objectAtIndex:indexPath.row];
    [cell setCellFeaturesWithMatchedUser:user];
    cell.reentering = TRUE;
    NSLog(@"\nIn CELL FOR ROW: \nPending matches: %@\n\n made matches: %@\n\n", matcher.pendingMatches, matcher.madeMatches);
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
