//
//  Pin.h
//  Capture The Pin
//
//  Created by Ty Missey on 10/25/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Mapkit/Mapkit.h>

@interface Pin : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinateVal andTitle:(NSString *)titleVal;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
