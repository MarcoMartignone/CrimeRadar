//
//  ViewController.m
//  CrimeRadar
//
//  Created by Marco Martignone on 02/03/2016.
//  Copyright © 2016 Marco Martignone. All rights reserved.
//

/*
 Hi and welcome to my brand new CrimeRadar that i built just for you.
 This app is based on the London Police API https://data.police.uk/docs and it fetches
 crimes around your location.
 
 To understand the meaning of every different emoji have a look at -(void)emojiFromTitle
 
 There's still a lot to do: data visualization, loading annotations while panning far from your location, updating
 API url every time new data are released.
*/

#import "ViewController.h"
#import "Crime.h"

@interface ViewController () <CLLocationManagerDelegate , ADClusterMapViewDelegate>

@property (strong, nonatomic) NSURLSession *session;

@property (strong, nonatomic) IBOutlet ADClusterMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *userLocation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Creating blurred loading view
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.loadingView.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.loadingView addSubview:blurEffectView];
    }
    else {
        self.loadingView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    }
    
    // Showing loading view and spinner
    self.loadingView.alpha = 1;
    self.spinner.alpha = 1;
    [self.spinner startAnimating];
    
    // Initializing and setting delegate to CoreLocation manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Handling location permission
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }

    // Setting CoreLocation accuracy and start locating
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    
    // Setting MapKit delegate
    self.mapView.delegate = self;
    // Showing location dot on the map
    self.mapView.showsUserLocation = YES;
    // Disabling 3D view
    self.mapView.pitchEnabled = NO;
    // Disabling POI
    self.mapView.showsPointsOfInterest = NO;

    // UI setup of location button
    self.locateMeButton.layer.cornerRadius = 2;
    self.locateMeButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.locateMeButton.layer.shadowOpacity = 0.4;
    self.locateMeButton.layer.shadowRadius = 5;
    self.locateMeButton.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    [self.locateMeButton setTitle:@"🚀" forState:UIControlStateNormal];
}

// CLLocationManagerDelegate called every time there is a location update
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    // Saving user location
    self.userLocation = locations.lastObject;
    
    // Setting map distance and showing coordinates on map
    CLLocationDistance distance = 300;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.userLocation.coordinate, distance, distance);
    [self.mapView setRegion:viewRegion animated:YES];

    // Stop location update (we don't need it)
    [self.locationManager stopUpdatingLocation];
    
    // Starting to fetch data
    [self fetchJsonFeed];
}

// Networking method that fetch, parse and create map annotations
- (void)fetchJsonFeed
{
    __block NSArray *jsonData = [[NSArray alloc] init];
    NSMutableArray *crimeAnnotations = [[NSMutableArray alloc] init];
    
    self.session = [NSURLSession sharedSession];
    
    // Setting API url with user location
    NSString *urlString = [NSString stringWithFormat:@"https://data.police.uk/api/crimes-street/all-crime?lat=%f&lng=%f&date=2015-12", self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude];
    
    NSURL *apiUrl = [NSURL URLWithString:urlString];
    
    // Starting asyncronous call to the server
    NSURLSessionTask *dataTask = [self.session dataTaskWithURL:apiUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // Serializing data
        jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        // Creating annotation for every dictionary found in the array
        for (NSDictionary *crime in jsonData) {
            Crime *annotation = [[Crime alloc] initWithDictionary:crime];
            [crimeAnnotations addObject:annotation];
        }
        
        // Jumping in the main thread and adding annotation to map
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Adding annotation");
            [self.mapView setAnnotations:crimeAnnotations];
        });
    }];
    
    [dataTask resume];
}

// Locate the user when the button is pressed
- (IBAction)locateMeButtonPressed:(UIButton *)sender
{
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

// CoreLocation delegate method that sets emoji instead of boring pins
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Taking care of the blue location dot that doens't have to be replaced
    if (annotation == mapView.userLocation)
    {
        return nil;
    }
    
    // Creating view, adding a label and assigning the right emoji
    MKAnnotationView * pinView = nil;
    if (!pinView) {
        pinView = [[MKAnnotationView alloc] init];
       
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        label.text = [self emojiFromTitle:annotation.title];
        
        pinView.frame = label.frame;
        pinView.canShowCallout = YES;
        [pinView addSubview:label];
    }
    else {
        pinView.annotation = annotation;
    }
    
    return pinView;
}

#pragma mark - ADClusterMapViewDelegate

// ADClusterMapView delegate method that sets the emoji of clusters while you zoom out
- (MKAnnotationView *)mapView:(ADClusterMapView *)mapView viewForClusterAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView * pinView = nil;
    if (!pinView) {
        pinView = [[MKAnnotationView alloc] init];
        
        UILabel *emojiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        emojiLabel.text = @"🚨";
        
        pinView.frame = emojiLabel.frame;
        [pinView addSubview:emojiLabel];
    }
    else {
        pinView.annotation = annotation;
    }
    return pinView;
}

// ADClusterMapView delegate method called when the map loaded the clusters
- (void)mapViewDidFinishClustering:(ADClusterMapView *)mapView {
    NSLog(@"Done");

    // Hide loading screen and stop spinner
    [UIView animateWithDuration:0.5 animations:^{
        self.loadingView.alpha = 0;
        self.spinner.alpha = 0;
    } completion:^(BOOL finished) {
        [self.spinner stopAnimating];
    }];
}

// ADClusterMapView delegate method to define the number of clusters
- (NSInteger)numberOfClustersInMapView:(ADClusterMapView *)mapView {
    return 70;
}

#pragma mark - UtilityMethods

// Compare the title fetched from the API and return the right emoji
- (NSString *)emojiFromTitle:(NSString *)title
{
    NSString *emoji = [[NSString alloc] init];
    
    if ([title isEqualToString:@"anti-social-behaviour"]) {
        emoji = @"💩";
    } else if ([title isEqualToString:@"bicycle-theft"]) {
        emoji = @"🚲";
    } else if ([title isEqualToString:@"burglary"]) {
        emoji = @"🔑";
    } else if ([title isEqualToString:@"criminal-damage-arson"]) {
        emoji = @"🔥";
    } else if ([title isEqualToString:@"drugs"]) {
        emoji = @"💊";
    } else if ([title isEqualToString:@"other-theft"]) {
        emoji = @"👻";
    } else if ([title isEqualToString:@"possession-of-weapons"]) {
        emoji = @"🔫";
    } else if ([title isEqualToString:@"public-order"]) {
        emoji = @"😤";
    } else if ([title isEqualToString:@"robbery"]) {
        emoji = @"💷";
    } else if ([title isEqualToString:@"shoplifting"]) {
        emoji = @"🛍";
    } else if ([title isEqualToString:@"theft-from-the-person"]) {
        emoji = @"👛";
    } else if ([title isEqualToString:@"vehicle-crime"]) {
        emoji = @"🚙";
    } else if ([title isEqualToString:@"violent-crime"]) {
        emoji = @"🔪";
    } else if ([title isEqualToString:@"other-crime"]) {
        emoji = @"☠️";
    } else {
        emoji = @"";
    }
    
    return emoji;
}

@end
