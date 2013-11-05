//
//  Pin.m
//  Capture The Pin
//
//  Created by Ty Missey on 10/25/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Pin.h"

@implementation Pin
@synthesize title = _title;
@synthesize coordinate = _coordinate;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinateVal andTitle:(NSString *)titleVal{
    self = [super init];
    
    if (self != nil)
    {
        _coordinate = coordinateVal;
        _title = titleVal;
    }
    
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    _coordinate = newCoordinate;
}

@end
