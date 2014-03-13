//
//  CoursePickerViewController.m
//  Study Bunny
//
//  Created by Gregoire on 2/14/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//
#import "UMAPIManager.h"
#import "CoursePickerViewController.h"

@interface CoursePickerViewController ()

@end

@implementation CoursePickerViewController

@synthesize tableView = _tableView, course, titleView, schoolData, classData, subjectData, pickerView, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        course = [[Course alloc] init];
        course.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBarTintColor:SECONDARYCOLOR];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    UIImageView *bunnyBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, DEVICEWIDTH, DEVICEHEIGHT-20)];
    [bunnyBack setImage:[self changeImage:[UIImage imageNamed:@"bunny.png"] toColor:TERTIARYCOLOR]];
    
    titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, NAVBARHEIGHT)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleView setText:@"Choose Your School"];
    [titleView setFont:[UIFont fontWithName:FONT size:20.0]];
    [titleView setTextAlignment:NSTextAlignmentCenter];
    [titleView setTextColor:[UIColor whiteColor]];
    [self.navigationItem setTitleView:titleView];
    
    CGFloat pickerViewHeight = 50;
    pickerView = [[CoursePickerSegmentView alloc] initWithFrame:CGRectMake(0, NAVBARHEIGHT+STATUSBARHEIGHT, DEVICEWIDTH, pickerViewHeight)];
    [pickerView setAlpha:1.0];
    [pickerView.picker addTarget:self action:@selector(pickerChanged) forControlEvents:UIControlEventValueChanged];
    
    UIButton *checkBtn = [[UIButton alloc] initWithFrame:BARBUTTONFRAME];
    UIImage *check = [UIImage imageNamed:@"check.png"];
    [checkBtn setImage:check forState:UIControlStateNormal];
    [checkBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *checkBarButton = [[UIBarButtonItem alloc] initWithCustomView:checkBtn];
    self.navigationItem.rightBarButtonItem = checkBarButton;
    
    UIButton *crossBtn = [[UIButton alloc] initWithFrame:BARBUTTONFRAME];
    UIImage *cross = [UIImage imageNamed:@"cross.png"];
    [crossBtn setImage:cross forState:UIControlStateNormal];
    [crossBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *crossBarBtn = [[UIBarButtonItem alloc]initWithCustomView:crossBtn];
    self.navigationItem.leftBarButtonItem = crossBarBtn;
    
    //background view
    [self.view addSubview:bunnyBack];
    [self.view addSubview:pickerView];
    
	//Table view setup
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBARHEIGHT+STATUSBARHEIGHT+pickerViewHeight, DEVICEWIDTH, DEVICEHEIGHT-NAVBARHEIGHT-STATUSBARHEIGHT-pickerViewHeight) style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[UIColor whiteColor]];
    [_tableView setAlpha:0.9];
    [_tableView setTintColor:SECONDARYCOLOR];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [self.view addSubview:_tableView];
    
    [UMAPIManager getSchoolsWithCompletion:^(NSDictionary *dict) {
        schoolData = dict[@"School"];
        [_tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } ];
    [MBProgressHUD showHUDAddedTo:self.view withText:@"Loading Schools"];
    
}

// ----------------------------------------- SELECTOR METHODS  -----------------------------------------//



-(void)pickerChanged
{
    if(pickerView.step < [pickerView.picker selectedSegmentIndex]){
        
        //alert view mofucka
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"you need to fill out more info before you can see this!"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        [pickerView.picker setSelectedSegmentIndex:pickerView.step];
    }
    
    pickerView.step = [pickerView.picker selectedSegmentIndex];
    [_tableView reloadData];
    
    
    switch ([pickerView.picker selectedSegmentIndex]) {
        case 0:
            [titleView setText:@"Choose Your School"];
            break;
        case 1:
            [titleView setText:@"Choose Your Subject"];
            break;
        case 2:
            [titleView setText:@"Choose Your Course"];
            break;
            
        default:
            break;
    }
    
}

-(void)save
{
    if( !(course.description &&course.catalogNum)){
        //alert view bitch
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Oops!"]
                                                        message:@"Please choose a school, subject, and class..."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [course saveToParse];
    [MBProgressHUD showHUDAddedTo:self.view withText:@"Saving Course..."];
    [delegate didAddNewCourse:self.course];
}

-(void)cancel
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

// ------------------------------------------ COURSE DELEGATE METHODS ---------------------------------//

-(void)course:(Course *)course finishedSavingWithError:(NSError *)error
{
    if (error) {
        NSLog(@"An error occured: %@", error.localizedDescription);
        //alert view mofucka
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"An error occured. Please try again."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    // otherwise kill the progress hud and resign
    [MBProgressHUD HUDForView:self.view].labelText = @"Success!";
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}

// ------------------------------------------ TABLE VIEW DELEGATE METHODS ---------------------------------//

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([pickerView.picker selectedSegmentIndex]) {
        case 0:
        {
            pickerView.step = 1;
            course.schoolCode = [[schoolData objectAtIndex:indexPath.row] objectForKey:@"SchoolCode"];
            course.school = [[schoolData objectAtIndex:indexPath.row] objectForKey:@"SchoolDescr"];
            [UMAPIManager getSubjectsWithSchoolCode:course.schoolCode andCompletion:^(NSDictionary *dict) {
                
                // if only one option
                if ([[dict objectForKey:@"Subject"] isKindOfClass:[NSDictionary class]]) {
                    subjectData = [NSArray arrayWithObject:[dict objectForKey:@"Subject"]];
                }
                else{
                    subjectData = [dict objectForKey:@"Subject"];
                }
                NSLog(@"%@", subjectData);
                [pickerView.picker setSelectedSegmentIndex:pickerView.step];
                [titleView setText:@"Choose Your Subject"];
                [tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
            [MBProgressHUD showHUDAddedTo:self.view withText:@"Loading Subjects"];
        }
            break;
        case 1:
        {
            pickerView.step = 2;
            course.subjectCode = [[subjectData objectAtIndex:indexPath.row] objectForKey:@"SubjectCode"];
            course.subject = [[subjectData objectAtIndex:indexPath.row] objectForKey:@"SubjectDescr"];
            [UMAPIManager getCoursesWithSchoolCode:course.schoolCode andSubject:course.subjectCode andCompletion:^(NSDictionary *dict) {
                classData = [dict objectForKey:@"ClassOffered"];
                NSLog(@"%@", classData);
                [pickerView.picker setSelectedSegmentIndex:pickerView.step];
                [titleView setText:@"Choose Your Course"];
                [tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
            [MBProgressHUD showHUDAddedTo:self.view withText:@"Loading Courses"];
        }
            break;
        case 2:
        {
            course.description = [[classData objectAtIndex:indexPath.row] objectForKey:@"CourseDescr"];
            course.catalogNum = [[classData objectAtIndex:indexPath.row] objectForKey:@"CatalogNumber"];
            
            //alert view bitch
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You chose: %@ %@", course.subjectCode, course.catalogNum]
                                                            message:@"If this is the correct class, save it by hitting the top right checkbox!"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
            
            break;
            
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1. Setup the CATransform3D structure
    CATransform3D rotation;
    rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 1.0, 0.0, 0.0);
    //rotation = CATransform3DMakeTranslation(30, 0, 0);
    rotation.m34 = 1.0/ -600;
    
    
    //2. Define the initial state (Before the animation)
    cell.layer.shadowColor = SECONDARYCOLOR.CGColor;
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    cell.alpha = 0.7;
    
    cell.layer.transform = rotation;
    cell.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    
    //3. Define the final state (After the animation) and commit the animation
    [UIView beginAnimations:@"rotation.x" context:NULL];
    [UIView setAnimationDuration:0.4];
    cell.layer.transform = CATransform3DIdentity;
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch ([pickerView.picker selectedSegmentIndex]) {
        case 0:
            return [schoolData count];
            break;
        case 1:
            return [subjectData count];
            break;
        case 2:
            return [classData count];
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setTintColor:SECONDARYCOLOR];
    [cell.textLabel setTextColor:SECONDARYCOLOR];
    [cell.textLabel setFont:[UIFont fontWithName:FONT size:22]];
    [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    //[cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    
    NSString *courseNum, *descr;
    if(pickerView.step == 2){
        courseNum = [[classData objectAtIndex:indexPath.row] objectForKey:@"CatalogNumber"];
        descr = [[classData objectAtIndex:indexPath.row] objectForKey:@"CourseDescr"];
    }
    
    switch ([pickerView.picker selectedSegmentIndex]) {
        case 0:
            cell.textLabel.text = [[schoolData objectAtIndex:indexPath.row] objectForKey:@"SchoolDescr"];
            break;
        case 1:
            //NSLog(@"subject count is %ui", (unsigned int)[subjectData count]);
            cell.textLabel.text = [[subjectData objectAtIndex:indexPath.row] objectForKey:@"SubjectDescr"];
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@: %@", course.subjectCode, courseNum, descr];
            break;
            
        default:
            break;
    }
    
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
