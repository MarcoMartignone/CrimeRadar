//
//  Crime.h
//  CrimeRadar
//
//  Created by Marco Martignone on 02/03/2016.
//  Copyright © 2016 Marco Martignone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ADMapCluster.h"

@interface Crime : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
