//
//  TestController.m
//  userTestTask
//
//  Created by Mobindustry on 2/12/15.
//  Copyright (c) 2015 ARC. All rights reserved.
//

#import "TestController.h"
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"
#import "Student.h"
#import "UIView+MKAnnotationView.h"
#import <CoreLocation/CoreLocation.h>

@interface TestController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSMutableSet *coordinates;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *myLocation;

@end

@implementation TestController

{
    NSMutableArray *annotations;
    NSMutableArray *students;
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
//    CLLocationCoordinate2D fixedPoint = CLLocationCoordinate2DMake(48.450115, 35.020692);
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    
    annotations = [NSMutableArray array];
    students = [NSMutableArray array];
    for (int a = 0; a < 10; a++) {
        
        Student *student = [[Student alloc] initWithRandomData];
        MyAnnotation *annotation = [[MyAnnotation alloc] initWithTitle:student.name
                                                              subTitle:student.surname
                                                                gender:student.gender
                                                            coordinate:student.coordinate];
        [students addObject:student];
        [annotations addObject:annotation];
        
    }
    [self.mapView addAnnotations:annotations];
   
   
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.myLocation.coordinate.latitude, self.myLocation.coordinate.longitude);

    MKCircle *circle = [MKCircle circleWithCenterCoordinate:coord radius:1000];
    [self.mapView addOverlay:circle];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

-(NSMutableSet *)coordinates{
    if (_coordinates) {
        _coordinates = [[NSMutableSet alloc] init];
    }
    return _coordinates;
}


- (IBAction)addPin:(id)sender
{
//    [self.mapView showAnnotations:annotations animated:YES];
//    [self.mapView addAnnotations:annotations];
}


-(IBAction)showAllPin:(id)sender
{
    
    MKMapRect zoomRect = MKMapRectNull;
    
    
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        CLLocationCoordinate2D location = annotation.coordinate;
        MKMapPoint center = MKMapPointForCoordinate(location);
        double delta = 500;
        
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
        
        zoomRect = MKMapRectUnion(zoomRect, rect);
    }
    zoomRect = [self.mapView mapRectThatFits:zoomRect];
    NSInteger inset = 50;
    UIEdgeInsets insets = UIEdgeInsetsMake(inset, inset, inset, inset);
    
    [self.mapView setVisibleMapRect:zoomRect
                        edgePadding:insets
                           animated:YES];
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    NSLog(@"regionWillChangeAnimated");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"regionDidChangeAnimated");
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    static NSString *pinID = @"pin";
    MKPinAnnotationView *pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinID];
        MyAnnotation *ann = (MyAnnotation *)annotation;
        if (ann.isMale) {
            pin.image = [UIImage imageNamed:@"man"];
        }else{
            pin.image = [UIImage imageNamed:@"woman"];
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self action:@selector(showUserDetail:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = button;
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        pin.draggable = NO;
    }else{
        pin.annotation = annotation;
    }
    

    
    return pin;
}

- (void)showUserDetail:(UIButton *)sender {
    
    Student *student = (Student <MKAnnotation> *)[sender superAnnotationView];

}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor redColor];
    circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
    return circleView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
//    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [self.locationManager stopUpdatingLocation];
    
    self.myLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude
                                                 longitude:newLocation.coordinate.longitude];
    
     
}

@end
