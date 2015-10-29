//
//  ViewController.m
//  PinListMap
//
//  Created by Hongjin Su on 10/21/15.
//  Copyright © 2015 Hongjin Su. All rights reserved.
//

#import "ViewController.h"
#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField_city; // To get city from user
@property (weak, nonatomic) IBOutlet UITextView *textView_cityList; // To present the list of cities
//@property (strong, nonatomic) CLLocation *location; // To get the location of a certain city
@property (strong, nonatomic) NSMutableDictionary *dict_cityList; // To make a list of cities to show on map
@property (strong, nonatomic) NSArray *array_CityList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dict_cityList = [[NSMutableDictionary alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// To act on "Add lat and lon" button click
- (IBAction)ButtonAction_AddCity:(id)sender {
    
    _array_CityList = [_dict_cityList allKeys];
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder geocodeAddressString:_textField_city.text completionHandler:^(NSArray *placeMarks, NSError *error) {
        
         if (!error) {
             
             CLPlacemark *placemak = [placeMarks objectAtIndex:0];
             CLLocation *location = placemak.location;
             
             // To try to find out if the location is already there
             BOOL duplicate = NO;
             for (int i = 0; i < [_array_CityList count]; i++) {
                 CLLocation *currentLocation = [_dict_cityList objectForKey:_array_CityList[i]];
                 if ((currentLocation.coordinate.latitude == location.coordinate.latitude) && (currentLocation.coordinate.longitude == location.coordinate.longitude)) {
                     duplicate = YES;
                     break;
                 }
             }
             
             if (duplicate == YES) {
                 
                 // To pop up a warning alert if the location is already there
                 UIAlertController *alertCont =[UIAlertController alertControllerWithTitle:@"Warning!" message:@"Location already exists!" preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *okButton =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                 
                 [alertCont addAction:okButton];
                 
                 [self presentViewController:alertCont animated:YES completion:nil];
                 
                 // To clear the textfield
                 _textField_city.text = @"";
             }
             else {
                 
                 // NSLog(@"%@",[placemak description]);
                 
                 // To add the location to the dictionary
                 [_dict_cityList setObject:location forKey:_textField_city.text];
                 
                 // To make a new string with the city name, its latitude and its longitude
                 NSString *city = [NSString stringWithFormat:@"City: %@ with Latidude: %.6f and Longitude: %.6f \n", _textField_city.text, location.coordinate.latitude, location.coordinate.longitude];
                 
                 // To append the new city string to the textview string
                 _textView_cityList.text = [_textView_cityList.text stringByAppendingString:city];
                 
                 // To clear the textfield
                 _textField_city.text = @"";
             }
         }
         else {
             
             //NSLog(@"Error in Locating the lat and long");
             
             // To pop up a warning alert if the location is not valid
             UIAlertController *alertCont =[UIAlertController alertControllerWithTitle:@"Warning!" message:@"Location is not found!" preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okButton =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
             [alertCont addAction:okButton];
            
             [self presentViewController:alertCont animated:YES completion:nil];
             
             // To clear the textfield
             _textField_city.text = @"";
         }
     }];
    //NSLog(@"%@", [_dict_cityList description]);
}

- (IBAction)ButtonAction_ShowOnMap:(id)sender {
    
}

#pragma mark UITextFeild Delegate Methods
//return the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// To resign the keyboard by touch the screen
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_textField_city resignFirstResponder];
}

// To process to the next screen
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier]isEqualToString:@"ShowPinsPush"]) {
        MapViewController *objMVC = [segue destinationViewController];
        objMVC.dictionary_cityList = _dict_cityList;
    }
}

@end
