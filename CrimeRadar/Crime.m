//
//  Crime.m
//  CrimeRadar
//
//  Created by Marco Martignone on 02/03/2016.
//  Copyright © 2016 Marco Martignone. All rights reserved.
//

#import "Crime.h"
#import "ADMapCluster.h"

@implementation Crime

// Annotation initializer called from the API call in the ViewController
- (id)initWithDictionary:(NSDictionary *)dictionary
{
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = [dictionary[@"location"][@"latitude"] doubleValue];
    coordinate.longitude = [dictionary[@"location"][@"longitude"] doubleValue];
    
    NSString *title = dictionary[@"category"];
    
    self.coordinate = coordinate;
    self.title = title;
    
    return self;
}

@end
