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

@synthesize map, titleView, matches, currentMapDist, myCourses, matchedUsers, matcher;

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
    
    matcher = [[SBMatchMaker alloc] init];
    [matcher setDelegate:self];
    [matcher getMatches];
    
     
    [MBProgressHUD showHUDAddedTo:self.view withText:@"Loading Courses"];
}

// ------------------------------------- SBMATCHMAKER DELEGATE -----------------------------------------------------//

-(void)matchesMade:(SBMatchMaker *)matchMaker WithError:(NSError *)error
{
    if (error) {
        NSLog(@"Error in MacthesMadeWithError: %@\n", error.localizedDescription);
        
        // alert view here
        
        return;
    }
    myCourses = matchMaker.myCourses;
    NSLog(@"Mapped dictionary is \n%@\n", matchMaker.usersMappedToCourses);
    [self fetchMatchedUsers];
    
}


// ------------------------------------- SELECTOR FUNCS -----------------------------------------------------//

-(void)fetchMatchedUsers
{
    PFQuery *q = [PFUser query];
    [q whereKey:@"objectId" containedIn:matcher.userMatches];
    
    [q whereKey:@"location"
       nearGeoPoint:[PFGeoPoint geoPointWithLatitude:[[LocationGetter sharedInstance] getLatitude]
                                           longitude:[[LocationGetter sharedInstance]getLongitude]]
   withinKilometers:20];
    
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: failed fetching matched users %@\n", error.localizedDescription);
            return;
        }
        NSLog(@"\nuser objects count is %lu\n", (unsigned long)objects.count);
        for (PFUser *u in objects)
        {
            if ([matcher.madeMatches containsObject:u.objectId] ) {
                //continue;
            }
            MatchedUser *mu = [[MatchedUser alloc] initWithPFUser:u];
            mu.matchedCourses = [matcher.usersMappedToCourses objectForKey:mu.userId];
            [matchedUsers addObject:mu];
            MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
            [ann setCoordinate:mu.coord];
            [ann setTitle:mu.name];  
            [ann setSubtitle:[mu getConcatenatedCourses]];
            [map addAnnotation:ann];
        }
        
        // drop Pins
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}


// ------------------------------------- MAP VIEW DELEGATE FUNCS -------------------------------------------------//


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            pinView.pinColor = MKPinAnnotationColorRed;
            
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}


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
