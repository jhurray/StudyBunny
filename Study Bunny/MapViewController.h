//
//  MapViewController.h
//  Study Bunny
//
//  Created by Gregoire on 2/1/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) NSMutableArray *matches;
@property (nonatomic) CGFloat currentMapDist;
@property (nonatomic, strong) NSArray *myCourses;

@end
