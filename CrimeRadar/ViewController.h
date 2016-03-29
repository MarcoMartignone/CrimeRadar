//
//  ViewController.h
//  CrimeRadar
//
//  Created by Marco Martignone on 02/03/2016.
//  Copyright © 2016 Marco Martignone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ADClusterMapView.h"

@interface ViewController : UIViewController  <CLLocationManagerDelegate , ADClusterMapViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *locateMeButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet UIView *loadingView;

- (IBAction)locateMeButtonPressed:(UIButton *)sender;

@end

