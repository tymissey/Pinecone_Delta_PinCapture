//
//  Flag.m
//  Capture The Pin
//
//  Created by Ty Missey on 10/25/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
#import <Mapkit/Mapkit.h>
#import "Flag.h"
#import "Pin.h"

@implementation Flag
-(id)initWithLocation:(CLLocationCoordinate2D )location pointValue:(NSInteger)points size:(double)radius title:(NSString *)title{
    if(self = [super init]){
        m_pinLocation = [[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
        m_radius = radius;
        m_points = points;
        m_title = title;
    }
    return self;
}



-(CLLocationCoordinate2D) getCoordinate{
    return m_pinLocation.coordinate;
}

-(void)setCoordinate:(CLLocationCoordinate2D)coordinate{
    m_pinLocation = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
}


-(CLLocation *)getLocation{
    return m_pinLocation;
}
-(NSInteger)getPoints{
    return m_points;
}

-(double)getRad{
    return m_radius;
}

-(void)setRad:(double)rad{
    m_radius = rad;
}

-(void)setPoints:(NSInteger)newPoints{
    m_points = newPoints;
}

-(NSString *) getTitle{
    return  m_title;
}

@end
