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



@interface TestController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeControl;

@property (strong, nonatomic) NSMutableSet *coordinates;

@end

@implementation TestController

- (void)viewDidLoad {
   
    [super viewDidLoad];
    Student *student = [Student generateRandonStudent];
    
}

//- (void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    
//    CLLocationCoordinate2D myCoordinate = self.mapView.userLocation.location.coordinate;
//    [self.mapView setCenterCoordinate:myCoordinate animated:YES];
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (Student *)generateRandomStudent {
    
    Student *student = [[Student alloc] init];
 
    
        
      CLLocation  *currentLocation = [[CLLocation alloc] initWithLatitude:29.33891 longitude:48.077202];
        
//        CGFloat latitude=[[d valueForKey:@"latitude"] floatValue];
//        CGFloat longitude=[[d valueForKey:@"longitude"] floatValue];
//        CLLocation *newPinLocation=[[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
//        double distanceValue=[currentLocation distanceFromLocation:newPinLocation];
//        
    
    
    
    
    return student;
}

#pragma mark - Actions

-(NSMutableSet *)coordinates{
    if (_coordinates) {
        _coordinates = [[NSMutableSet alloc] init];
    }
    return _coordinates;
}

- (IBAction)changeMapType:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
            
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
            
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
    
}

- (IBAction)addPin:(id)sender
{
    CLLocationCoordinate2D coordinate = self.mapView.region.center;
    MyAnnotation *annotation = [[MyAnnotation alloc] initWithTitle:@"Test"
                                                          subTitle:@"Subtitle"
                                                       coordinate:coordinate];
    NSValue *value = [NSValue valueWithMKCoordinate:coordinate];
    [self.coordinates addObject:value];
  
    if ([self.coordinates containsObject:value]) {
        return;
    }else{
        [self.mapView addAnnotation:annotation];
    }
}

- (void) setSegmentedControlAlpha:(CGFloat)alpha
{
    [UIView animateWithDuration:0.3f animations:^{
        self.mapTypeControl.alpha = alpha;
        [self.view layoutIfNeeded];
    }];
}

-(IBAction)showAllPin:(id)sender
{
    
    MKMapRect zoomRect = MKMapRectNull;
    
    
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        CLLocationCoordinate2D location = annotation.coordinate;
        MKMapPoint center = MKMapPointForCoordinate(location);
        double delta = 50000;
        
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
//    [self setSegmentedControlAlpha:0.0f];
    NSLog(@"regionWillChangeAnimated");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    [self setSegmentedControlAlpha:1.0f];
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
        pin.image = [UIImage imageNamed:@"pin"];
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        pin.draggable = YES;
    }else{
        pin.annotation = annotation;
    }
    

    
    return pin;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
}

//- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
//{
//    NSLog(@"mapViewWillStartLoadingMap");
//}
//
//- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
//{
//    NSLog(@"mapViewDidFinishLoadingMap");
//}
//
//- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
//{
//    NSLog(@"mapViewDidFailLoadingMap");
//}
//
//- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView
//{
//    NSLog(@"mapViewWillStartRenderingMap");
//}
//
//- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
//{
//    NSLog(@"mapViewDidFinishRenderingMap");
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
