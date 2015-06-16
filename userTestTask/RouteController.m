//
//  RouteController.m
//  userTestTask
//
//  Created by Mobindustry on 2/10/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import "RouteController.h"
#import <CoreLocation/CoreLocation.h>
#import <RKDropdownAlert/RKDropdownAlert.h>
#import <MapKit/MapKit.h>

//static NSArray *places = @[@(49.753073  31.465350), ];

@interface RouteController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (assign, nonatomic) CLLocationCoordinate2D currentCoord;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *map;

@end

@implementation RouteController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocationDidUpdate:) name:CurrentLocationDidUpdateNotification object:nil];
    [self getCurrentLocation];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) currentLocationDidUpdate:(NSNotification *) notification
{
    if (CLCOORDINATES_EQUAL(_currentCoord, _destinationCoord)) {
        
        [RKDropdownAlert title:@"Attention!"
                       message:@"Current coordinates are same with destination coordinates."
               backgroundColor:[UIColor yellowColor]
                     textColor:[UIColor blackColor]];
    }else{
        MKPlacemark *pm = [[MKPlacemark alloc] initWithCoordinate:self.destinationCoord addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:pm];
        
        
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        
        request.source = [MKMapItem mapItemForCurrentLocation];
        
        request.destination = mapItem;
        request.requestsAlternateRoutes = YES;
        MKDirections *directions =
        [[MKDirections alloc] initWithRequest:request];
        
        [directions calculateDirectionsWithCompletionHandler:
         ^(MKDirectionsResponse *response, NSError *error) {
             if (error) {
#if DEBUG
                 NSLog(@"Error creation of route: %@", [error userInfo]);
#endif
                 [RKDropdownAlert title:@"Error!"
             message:@"Can't create route to destination point."
             backgroundColor:[UIColor yellowColor]
             textColor:[UIColor blackColor]];
             } else {
                 [self showRoute:response];
             }
         }];
    }
}

- (void) showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.map addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}

- (IBAction) dismissRouteController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)getCurrentLocation
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
#if DEBUG
    NSLog(@"Current location: %@", newLocation);
#endif
     [self.locationManager stopUpdatingLocation];
    self.currentCoord = newLocation.coordinate;

    [[NSNotificationCenter defaultCenter] postNotificationName:CurrentLocationDidUpdateNotification object:nil];
   
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [RKDropdownAlert title:NSLocalizedString(@"error", nil)
                   message:NSLocalizedString(@"error_getting_current_location", nil)
           backgroundColor:[UIColor yellowColor]
                 textColor:[UIColor blackColor]];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor greenColor];
    renderer.lineWidth = 3.0;
    
    return renderer;
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
