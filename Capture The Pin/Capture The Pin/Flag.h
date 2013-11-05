//
//  Flag.h
//  Capture The Pin
//
//  Created by Ty Missey on 10/25/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Mapkit/Mapkit.h>

@interface Flag : NSObject{
    CLLocation *m_pinLocation;          //location of the flag
    NSInteger m_points;                 //points awarded for successful capture
    double m_radius;                    //radius of the flag boundaries
    NSString *m_title;                  //title used to spawn pins ad color code them
}
-(id)initWithLocation:(CLLocationCoordinate2D )location pointValue:(NSInteger)points size:(double)radius title:(NSString *)title;                                                   //initializes flag
-(CLLocationCoordinate2D)getCoordinate;                         //return coordinate
-(CLLocation *)getLocation;                                     //return location
-(void)setCoordinate:(CLLocationCoordinate2D)coordinate;        //set coordinate
-(NSInteger)getPoints;                                          //return m_points
-(double)getRad;                                                //returns radius
-(void)setRad:(double)rad;                                      //sets the new radius
-(void)setPoints:(NSInteger)newPoints;                          //sets the points awarded
-(NSString *) getTitle;                                         //returns title
@end
