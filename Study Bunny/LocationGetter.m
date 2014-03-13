//
//  LocationGetter.m
//  Study Bunny
//
//  Created by Jeff Hurray on 6/14/13.
//  Copyright (c) 2013 jhurrayApps. All rights reserved.
//


#import "LocationGetter.h"
#import <CoreLocation/CoreLocation.h>

@implementation LocationGetter

@synthesize locationManager, delegate, timer;

BOOL didUpdate = NO;

static LocationGetter *sharedClient;
+(id)sharedInstance{
    
    if(sharedClient == nil){
        sharedClient = [[LocationGetter alloc] init];
    }
    return sharedClient;
    
}

-(double)getLongitude{
    return sharedClient.locationManager.location.coordinate.longitude;
}
-(double)getLatitude{
    return sharedClient.locationManager.location.coordinate.latitude;
}
-(CLLocationCoordinate2D) getCoord{
    return sharedClient.locationManager.location.coordinate;
}

-(void)continueUpdates
{
    [locationManager startUpdatingLocation];
}

- (void)startUpdates
{
    NSLog(@"Starting Location Updates");
    
    if (locationManager == nil)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    
    // locationManager.distanceFilter = 1000;  // update is triggered after device travels this far (meters)
    
    // Alternatively you can use kCLLocationAccuracyHundredMeters or kCLLocationAccuracyHundredMeters, though higher accuracy takes longer to resolve
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation];
    
    // set location to update every 5 minutes
    timer = [NSTimer scheduledTimerWithTimeInterval:60*5 target:self selector:@selector(continueUpdates) userInfo:nil repeats:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your location could not be determined." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manage didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    /*
    if (didUpdate)
        return;
    
    didUpdate = YES;
    */
    
    NSLog(@"Updated Location Succesfully");
    // Disable future updates to save power.
    [locationManager stopUpdatingLocation];
    
    // let our delegate know we're done
    [delegate newLocation:newLocation];
    
    
    
    //save user
    PFGeoPoint *location = [PFGeoPoint geoPointWithLocation:newLocation];
    [[PFUser currentUser] setObject:location forKey:@"location"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (error) {
            NSLog(@"error with location save... %@\n", error.localizedDescription);
            [[PFUser currentUser] setObject:location forKey:@"location"];
            [[PFUser currentUser] saveEventually];
        }
        NSLog(@"Successful user location save!");
    }];
    
}
@end