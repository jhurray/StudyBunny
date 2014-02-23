//
//  MapViewController.m
//  Study Bunny
//
//  Created by Gregoire on 2/1/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import "MapViewController.h"
#import "Course.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize map, titleView, matches, currentMapDist, myCourses;

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
	// Do any additional setup after loading the view.
    
    //back button setup
    self.navigationItem.hidesBackButton = NO;
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIFont fontWithName:FONT size:18.0f],NSFontAttributeName,
                                                          nil] forState:UIControlStateNormal];
    
    //title view
    titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, NAVBARHEIGHT)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleView setText:@"Study Now!"];
    [titleView setFont:[UIFont fontWithName:FONT size:20.0]];
    [titleView setTextAlignment:NSTextAlignmentCenter];
    [titleView setTextColor:[UIColor whiteColor]];
    [self.navigationItem setTitleView:titleView];
    
    // add map
    currentMapDist = 1.5*METERS_PER_MILE;
    map = [[MKMapView alloc] initWithFrame:self.view.frame];
    [map setShowsUserLocation:YES];
    [map setShowsBuildings:YES];
    [map setShowsPointsOfInterest:YES];
    [map setMapType:MKMapTypeStandard];
    [map setDelegate:self];
    [self.view addSubview:map];
    
    [Course getMyCoursesWithCompletion:^(NSArray *courses) {
        myCourses = courses;
        [self getStudyMatchesForCourse:courses[0]];
    }];
    [MBProgressHUD showHUDAddedTo:self.view withText:@"Loading Courses"];
}

// ------------------------------------- SELECTOR FUNCS -----------------------------------------------------//


-(void)getStudyMatchesForCourse:(Course *)course
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    [hud setLabelText:@"Finding Study Partners..."];
    PFQuery *q = [PFQuery queryWithClassName:@"Course"];
    [q whereKey:@"subjectCode" equalTo:course.subjectCode];
    [q whereKey:@"catalogNum" equalTo:course.catalogNum];
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       // do user query and push that shit into Matches
    }];
}

// ------------------------------------- MAP VIEW DELEGATE FUNCS -------------------------------------------------//

-(void) viewWillAppear:(BOOL)animated{
    
    CLLocationCoordinate2D zoomLocation = [[LocationGetter sharedInstance] getCoord];
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, currentMapDist, currentMapDist);
    [map setRegion:mapRegion animated:YES];
}


-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    MKMapRect mapRect = mapView.visibleMapRect;
    MKMapPoint eastPoint = MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMidY(mapRect));
    MKMapPoint westPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMidY(mapRect));
    currentMapDist = MKMetersBetweenMapPoints(eastPoint, westPoint);
    NSLog(@"\nCurrent map distance is %f\n", currentMapDist);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
