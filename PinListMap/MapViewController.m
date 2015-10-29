//
//  MapViewController.m
//  PinListMap
//
//  Created by Hongjin Su on 10/21/15.
//  Copyright © 2015 Hongjin Su. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView_showPins;
@property (weak, nonatomic) IBOutlet UIButton *button_show;
@property (strong, nonatomic) NSArray *array_cityList;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _array_cityList = [_dictionary_cityList allKeys];
    _mapView_showPins.delegate = self;
    
    // To make the button shape rounded rectangular
    _button_show.layer.cornerRadius = 4;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)ButtonAction_Show:(id)sender {
    [self loadMap];
    [self loadAnnotations];
}

-(void)loadAnnotations {
    
    if (_mapView_showPins.annotations.count) {
        
        [_mapView_showPins removeAnnotations:_mapView_showPins.annotations];
    }
    
    for (int i = 0; i < [_array_cityList count]; i++) {
        
        //placing the pin for the given city
        MKPointAnnotation *annoPin = [[MKPointAnnotation alloc]init];
        CLLocation *Location = [_dictionary_cityList objectForKey:_array_cityList[i]];
        annoPin.coordinate = Location.coordinate;
        [annoPin setTitle:_array_cityList[i]];
        NSString *title = [NSString stringWithFormat:@"Latitude:%.6f, Longitude:%.6f", Location.coordinate.latitude, Location.coordinate.longitude];
        [annoPin setSubtitle:title];
        [_mapView_showPins addAnnotation:annoPin];
    }
}

-(void)loadMap {
    
    // To get the dictionary with max and min information
    NSDictionary *Dict_mm = [[NSDictionary alloc] init];
    Dict_mm = [self findMaxNMin];
    MKCoordinateSpan _span;
    CLLocationCoordinate2D _center;
    MKCoordinateRegion reg;
    
    // To take out all the info from the dictionary
    NSString *city_lon_max = [Dict_mm objectForKey:@"City_Lon_Max"];
    NSString *city_lon_min = [Dict_mm objectForKey:@"City_Lon_Min"];
    NSString *city_lat_max = [Dict_mm objectForKey:@"City_Lat_Max"];
    NSString *city_lat_min = [Dict_mm objectForKey:@"City_Lat_Min"];
    
    CLLocation *Loc_lon_max = [_dictionary_cityList objectForKey:city_lon_max];
    CLLocation *Loc_lon_min = [_dictionary_cityList objectForKey:city_lon_min];
    CLLocation *Loc_lat_max = [_dictionary_cityList objectForKey:city_lat_max];
    CLLocation *Loc_lat_min = [_dictionary_cityList objectForKey:city_lat_min];
    
    double maxLat = Loc_lat_max.coordinate.latitude;
    double minLat = Loc_lat_min.coordinate.latitude;
    double maxLon = Loc_lon_max.coordinate.longitude;
    double minLon = Loc_lon_min.coordinate.longitude;
    
    _span.latitudeDelta = (maxLat - minLat + 10);
    _span.longitudeDelta = (maxLon - minLon + 10);
    // the center point is the average of the max and mins
    _center.latitude = (minLat + maxLat) / 2;
    _center.longitude = (minLon + maxLon) / 2;
    reg.center = _center;
    reg.span = _span;
    
    [_mapView_showPins setRegion:reg animated:YES];
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    MKPinAnnotationView *annotationview = nil;
    
    static NSString *str = @"Identifier";
    MKPinAnnotationView *areaPin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:str];
    if (!areaPin) {
            
        MKPinAnnotationView *areaPin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:str];
        areaPin.pinTintColor = [self getRandomColor];
        //areaPin.pinTintColor = [UIColor blueColor];
        areaPin.animatesDrop = YES;
        areaPin.canShowCallout = YES;
        annotationview = areaPin;
    }
    return annotationview;
}

// To get random color for pin: https://gist.github.com/kylefox/1689973
- (UIColor*) getRandomColor {
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
    CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

// To get the max and mix of latitude and longitude
- (NSDictionary *)findMaxNMin {
    
    // To initialize all the max and min
    CLLocation *Loc = [_dictionary_cityList objectForKey:_array_cityList[0]];
    double lon_max = Loc.coordinate.longitude;
    double lon_min = Loc.coordinate.longitude;
    double lat_max = Loc.coordinate.latitude;
    double lat_min = Loc.coordinate.latitude;
    
    // To take notes on their city name
    NSString *city_lon_max = _array_cityList[0];
    NSString *city_lon_min = _array_cityList[0];
    NSString *city_lat_max = _array_cityList[0];
    NSString *city_lat_min = _array_cityList[0];
    
    // To find out the max and min and their city names
    for (int i = 1; i < [_array_cityList count]; i++) {
        
        CLLocation *cur_Loc = [_dictionary_cityList objectForKey:_array_cityList[i]];
        if (cur_Loc.coordinate.latitude > lat_max) {
            lat_max = cur_Loc.coordinate.latitude;
            city_lat_max = _array_cityList[i];
        }
        if (cur_Loc.coordinate.latitude < lat_min) {
            lat_min = cur_Loc.coordinate.latitude;
            city_lat_min = _array_cityList[i];
        }
        if (cur_Loc.coordinate.longitude > lon_max) {
            lon_max = cur_Loc.coordinate.longitude;
            city_lon_max = _array_cityList[i];
        }
        if (cur_Loc.coordinate.longitude < lon_min) {
            lon_min = cur_Loc.coordinate.longitude;
            city_lon_min = _array_cityList[i];
        }
    }
    
    // To store the info into a dictionary
    NSDictionary *dict_MM = [[NSDictionary alloc] initWithObjectsAndKeys:
                             city_lon_max, @"City_Lon_Max",
                             city_lon_min, @"City_Lon_Min",
                             city_lat_max, @"City_Lat_Max",
                             city_lat_min, @"City_Lat_Min",
                             nil];
    return dict_MM;
}

@end
