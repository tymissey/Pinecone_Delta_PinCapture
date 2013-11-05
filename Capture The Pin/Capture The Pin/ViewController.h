//
//  ViewController.h
//  Capture The Pin
//
//  Created by Ty Missey on 10/24/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <Social/Social.h>

#import "Flag.h"
#import "Pin.h"

@interface ViewController : UIViewController
<CLLocationManagerDelegate, MKMapViewDelegate, UIActionSheetDelegate>
{
    MKMapView *mapView;  
    NSInteger m_score;                                  //stores score
    double m_zoom;                                      //zoom level for focusing
    NSTimer *m_time;                                    //timer for resetting pins
    NSTimer *m_timerB;                                  //timer for resizing pins
    NSInteger m_interval;                               //variable to set m_time
    IBOutlet UILabel *timeDisplay;                      //display remaining time before pin reset
    IBOutlet UILabel *scoreDisplay;                     //shows score
    NSInteger currentClock;                             //m_time value
    NSInteger currentClockB;                            //m_timerB value
    NSArray *m_boundaries;                              //holds values for pins to spawn between
    NSMutableArray *m_flags;                            //holds flag data for the annotations
    NSMutableArray *m_annotations;                      //the pins that get drawn to mapview
    NSMutableArray *m_closePins;                        //array to store pins that can be captured 
    NSInteger *m_counter;                               //number of pins
    NSInteger *m_closePinCounter;                       //number of pins that can be captured
    float m_multiplier;                                 //gets changed when pins grow
}

@property (nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic,retain) IBOutlet UIButton *cap;    //capture button

-(IBAction)setMapType:(id)sender;                       //map|hybrid|satellite
-(IBAction)refocus:(id)sender;                          //center map on user
-(IBAction)capturePin:(id)sender;                       //awards points for being within flag radiuses and hitting capture button. Then moves pins.
-(IBAction)post:(id)sender;                             //allows posting score to Facebook or Twitter

-(void)startTimer;                                      //starts the new pin timer
-(void)startTimerB;                                     //starts the pin resize timer
-(void)focus;                                           //centers map on user
-(void)countdown;                                       //called by starttimer. handles main timer function
-(void)countdownB;                                       //called by starttimerB. handles resize flag function
-(void)newPins;
-(Flag *)spawnPin:(NSInteger)points size:(double)radius title:(NSString *)title;        //used to spawn a flag
-(double) getRandom:(NSInteger)min maxNumber: (NSInteger) max;               //returns random variance to add to latitude or longitude
-(NSInteger) getRandomint:(NSInteger)min maxNumber: (NSInteger) max;        //return random int to make variance more random
-(void)checkDistances;                                  //checks distance between user and flags    
-(void)drawBounds;                                      //draws circle overlays to depict flag boundaries
-(void)loadScore;                                       //load player score
-(void)saveScore;                                       //save player score
-(void)resizeFlags;                                     //doubles the flag sizes and halves the points awarded when called

@end


