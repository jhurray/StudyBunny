//
//  MyCoursesViewController.m
//  Study Bunny
//
//  Created by Gregoire on 2/17/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//


#import "MyCoursesViewController.h"
#import "AppDelegate.h"

@interface MyCoursesViewController ()

@end

@implementation MyCoursesViewController
@synthesize tableView = _tableView, titleView, myCourses, edit, editingMode;

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
    self.navigationItem.hidesBackButton = NO;
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIFont fontWithName:FONT size:18.0f],NSFontAttributeName,
                                                                   nil] forState:UIControlStateNormal];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBarTintColor:SECONDARYCOLOR];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    UIImageView *bunnyBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, DEVICEWIDTH, DEVICEHEIGHT-20)];
    [bunnyBack setImage:[self changeImage:[UIImage imageNamed:@"bunny.png"] toColor:SECONDARYCOLOR]];
    
    titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, NAVBARHEIGHT)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleView setText:@"My Courses"];
    [titleView setFont:[UIFont fontWithName:FONT size:20.0]];
    [titleView setTextAlignment:NSTextAlignmentCenter];
    [titleView setTextColor:[UIColor whiteColor]];
    [self.navigationItem setTitleView:titleView];
    
    //bar button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClass)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];

    //background view
    [self.view addSubview:bunnyBack];
    
    //height for edit btn
    CGFloat btnHeight = 40;
	//Table view setup
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBARHEIGHT+STATUSBARHEIGHT, DEVICEWIDTH, DEVICEHEIGHT-NAVBARHEIGHT-STATUSBARHEIGHT-btnHeight) style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[UIColor whiteColor]];
    [_tableView setAlpha:0.9];
    [_tableView setTintColor:SECONDARYCOLOR];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView registerClass:[CourseTableViewCell class] forCellReuseIdentifier:@"CourseCell"];
    [self.view addSubview:_tableView];
    
    //edit button
    
    editingMode = FALSE;
    edit = [[UIButton alloc] initWithFrame:CGRectMake(0, DEVICEHEIGHT-btnHeight, DEVICEWIDTH, btnHeight)];
    [edit setTitle:@"Edit Courses" forState:UIControlStateNormal];
    [edit.titleLabel setFont:[UIFont fontWithName:FONT size:18.0]];
    [edit setBackgroundColor:MAINCOLOR];
    edit.tag = 0;
    [edit addTarget:self action:@selector(editClasses:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:edit];
    
    [Course getMyCoursesWithCompletion:^(NSArray *courses) {
        NSMutableArray *arr = [courses mutableCopy];
        for (Course *c in arr) {
            if([deathRow containsObject:c.parseId]){
                [arr removeObject:c];
                [c deleteFromParse];
                NSLog(@"Dis nigga on the death row");
            }
        }
        myCourses = [arr mutableCopy];
        
        [_tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    [MBProgressHUD showHUDAddedTo:self.view withText:@"Loading Courses..."];
    
}

// ----------------------------------------- SELECTOR METHODS  -----------------------------------------//

-(void)editClasses:(UIButton *)sender
{
    if(sender.tag == 1){
        [edit setTitle:@"Edit Courses" forState:UIControlStateNormal];
        edit.tag = 0;
        editingMode = FALSE;
        CGFloat delay = 0.0;
        for (Course *c in myCourses) {
            c.editMode = FALSE;
        }
        for (NSIndexPath *i in [_tableView indexPathsForVisibleRows]) {
            CourseTableViewCell *cell = (CourseTableViewCell *)[_tableView cellForRowAtIndexPath:i];
            if(cell.editMode){
                [cell animateNormalModeWithDelay:delay];
                delay+=0.07;
            }
        }
        
    }
    else{
        [edit setTitle:@"Done" forState:UIControlStateNormal];
        edit.tag = 1;
        editingMode = TRUE;
        CGFloat delay = 0.0;
        for (Course *c in myCourses) {
            c.editMode = TRUE;
        }
        for (NSIndexPath *i in [_tableView indexPathsForVisibleRows]) {
            CourseTableViewCell *cell = (CourseTableViewCell *)[_tableView cellForRowAtIndexPath:i];
            if(!cell.editMode){
                [cell animateEditingModeWithDelay:delay];
                delay+=0.07;
            }
        }
        
    }
}

-(void)addClass
{
    CoursePickerViewController *cpVC = [[CoursePickerViewController alloc] init];
    cpVC.delegate = self;
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:cpVC] animated:YES completion:nil];
}

// ------------------------------------------ COURSE TVC DELEGATE METHODS ---------------------------------//

-(void)bottomButtonPressedForCourseTableViewCell:(CourseTableViewCell *)cell{
    
    NSMutableArray *arr = [myCourses mutableCopy];
    Course *course = [arr objectAtIndex:cell.indexPath.row];
    [deathRow addObject:course.parseId];
    [course deleteFromParse];
    [arr removeObjectAtIndex:cell.indexPath.row];
    myCourses = [arr mutableCopy];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [_tableView reloadData];
}

// ------------------------------------------ COURSE PICKER DELEGATE METHODS ---------------------------------//

-(void)didAddNewCourse:(Course *)course{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:myCourses];
    [arr addObject:course];
    myCourses = arr;
    [_tableView reloadData];
}

// ------------------------------------------ TABLE VIEW DELEGATE METHODS ---------------------------------//

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CourseTableViewCell *cell = (CourseTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    Course *course = [myCourses objectAtIndex:indexPath.row];
    
    if(cell.editMode)
    {
        [cell animateNormalModeWithDelay:0];
        course.editMode = FALSE;

    }
    else{
        [edit setTitle:@"Done" forState:UIControlStateNormal];
        course.editMode = TRUE;
        edit.tag = 1;
        [cell animateEditingModeWithDelay:0];
    }
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Editing mode: %i, cell EditMode: %i, cell title: %@", editingMode,((CourseTableViewCell *)cell).editMode, cell.textLabel.text );
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    Course *course = [myCourses objectAtIndex:indexPath.row];
    
    if(editingMode ){
        if(!((CourseTableViewCell *)cell).editMode){
            [((CourseTableViewCell *)cell) makeEditingMode];
        }
        else{
            
        }
    }
    else {
        if(course.editMode && !((CourseTableViewCell *)cell).editMode){
            [((CourseTableViewCell *)cell) makeEditingMode];
        }
        else if(!course.editMode && ((CourseTableViewCell *)cell).editMode){
            [((CourseTableViewCell *)cell) makeNormalMode];
        }
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELLHEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [myCourses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"CourseCell";
    
    CourseTableViewCell *cell = (CourseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[CourseTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setTintColor:SECONDARYCOLOR];
    [cell.textLabel setTextColor:MAINCOLOR];
    [cell.textLabel setFont:[UIFont fontWithName:FONT size:22]];
    [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    Course *course = [myCourses objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@: %@", course.subjectCode, course.catalogNum, course.description];
    cell.indexPath = indexPath;
    cell.delegate = self;
    if (course.isNew && cell.editMode) {
        [cell makeNormalMode];
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
