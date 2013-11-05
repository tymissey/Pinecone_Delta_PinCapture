//
//  ViewController.m
//  Capture The Pin
//
//  Created by Ty Missey on 10/24/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize mapView, locationManager, cap;



-(IBAction)setMapType:(id)sender{
    switch(((UISegmentedControl *)sender).selectedSegmentIndex){
        case 0:
            mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            mapView.mapType = MKMapTypeHybrid;
            break;
        case 2:
            mapView.mapType = MKMapTypeSatellite;
            break;
        default:
            mapView.mapType = MKMapTypeStandard;
            break;
    }
}
-(IBAction)refocus:(id)sender{
    [self focus];
}
-(IBAction)capturePin:(id)sender{
    NSInteger loop = 0;
    NSInteger subloop = 0;
    Pin *temp = [[Pin alloc]init];
    Flag *flag = [[Flag alloc]init ];
    Flag *flagData = [[Flag alloc]init];
    for(NSInteger *i = 0; i < self->m_closePinCounter; i++){
        flag = [self->m_closePins objectAtIndex:loop];
        for(NSInteger *l = 0; l < self->m_counter; l++){
            temp = [self->m_annotations objectAtIndex:subloop];
            if((temp.coordinate.latitude == [flag getCoordinate].latitude) && (temp.coordinate.longitude == [flag getCoordinate].longitude)){
                
                flagData = [self->m_flags objectAtIndex:subloop];                
                self->m_score += ([flagData getPoints] * self->m_multiplier);
               // self->m_didCapture = YES;
                [self startTimerB];
                [self saveScore];
                
                [self->m_flags replaceObjectAtIndex:subloop withObject:[self spawnPin:[flagData getPoints] size:[flagData getRad]title:[flagData getTitle]]];                
                flagData = [self->m_flags objectAtIndex:subloop];

                Pin *pin = [[Pin alloc] initWithCoordinate:[flagData getCoordinate] andTitle:[flagData getTitle]];
                [self->m_annotations replaceObjectAtIndex:subloop withObject:pin];
                [mapView removeAnnotations:mapView.annotations];
                int loopcount = 0;
                for(int *t = 0; t < self->m_counter; t++){
                    [mapView addAnnotation:[self->m_annotations objectAtIndex:loopcount]];
                    loopcount += 1;
                }
                [self drawBounds];
                
                break;
            }else{
                subloop +=1;
            }
        } 
        loop +=1;
    }
}

-(IBAction)post:(id)sender{
    UIActionSheet *share = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", nil];
    [share showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
            SLComposeViewController *fb = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [fb setInitialText:[NSString stringWithFormat:@"I have %i points in Capture-The-Pin! Can you beat it?", self->m_score]];
            [self presentViewController:fb animated:YES completion:nil];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"Please make sure you have a Facebook account on this device and have allowed access to this application" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }else if(buttonIndex == 1){
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
            SLComposeViewController *tw = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tw setInitialText:[NSString stringWithFormat:@"I have %i points in Capture-The-Pin! Can you beat it?", self->m_score]];
            [self presentViewController:tw animated:YES completion:nil];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"Please make sure you have a Twitter account on this device and have allowed access to this application" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }
}

-(void)startTimer{
    self->currentClock = self->m_interval;
    self->m_time = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
    [self startTimerB];
}

-(void)startTimerB{
    self->currentClockB = 600;
    self->m_timerB = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdownB) userInfo:nil repeats:YES];
}

-(void)countdown{
    self->currentClock -= 1;
    timeDisplay.text = [NSString stringWithFormat:@"%02d:%02d",(self->currentClock / 60 ),(self->currentClock % 60)];
    scoreDisplay.text = [NSString stringWithFormat:@"Score: %i",self->m_score];
    [self drawBounds];
    if(self->currentClock == 0){
        [self->m_time invalidate];
        [self newPins];
        [self startTimer];
    }
    [self checkDistances];
    
}
-(void)countdownB{
    self->currentClockB -= 1;
    if(self->currentClockB == 0){
        [self resizeFlags];
        [self->m_timerB invalidate];
        [self startTimerB];
    }
}

-(void)resizeFlags{
    Flag *flag = [[Flag alloc] init];
    NSInteger loop =0;
    for(NSInteger *l = 0; l < self->m_counter;l++){
        flag = [self->m_flags objectAtIndex:loop];
        [flag setRad:[flag getRad] * 2];
        [flag setPoints:[flag getPoints] / 2];
        [self->m_flags replaceObjectAtIndex:loop withObject:flag];
        loop += 1;
    }
    [self drawBounds];
}


-(void)drawBounds{
    [mapView removeOverlays: [mapView overlays]];
    NSInteger loop = 0;
    MKCircle *circle = [[MKCircle alloc]init];
    Flag *flag = [[Flag alloc]init];
    for (NSInteger *i = 0; i < self->m_counter; i++) {
        flag = [self->m_flags objectAtIndex:loop];
        circle = [MKCircle circleWithCenterCoordinate:[flag getCoordinate] radius:[flag getRad]];
        circle.title = [flag getTitle];
        
        [mapView addOverlay:circle];
        loop += 1;
    }
}

-(void)checkDistances{
    if(self->m_counter > 0){
        [self->m_closePins removeAllObjects];
        self->m_closePinCounter = 0;
        CLLocationDistance distance;
        CLLocation *user = [[CLLocation alloc] initWithLatitude:mapView.userLocation.coordinate.latitude longitude:mapView.userLocation.coordinate.longitude];
        NSInteger loop = 0;
        BOOL test = NO;
        CLLocationDistance closest;
        for(NSInteger *w = 0; w < self->m_counter; w++){
            Flag *flag = [[Flag alloc]init];
            flag = [self->m_flags objectAtIndex:loop];
            distance = [[flag getLocation] distanceFromLocation:user ];
            if(loop == 0){closest = distance;}
            if(distance < [flag getRad]){
                if(distance - [flag getRad] < closest){closest = distance - [flag getRad];}
                [self->m_closePins addObject:flag];
                self->m_closePinCounter +=1;
                [cap setUserInteractionEnabled:YES];
                test = YES;
            }
            loop += 1;
        }
        [cap setUserInteractionEnabled:test];
        if(test == YES){
            cap.titleLabel.text = @"Capture";
        }else{
            cap.titleLabel.text = @"Nope";
        }
    }
}

-(void)newPins{
    if(m_counter > 0){
        [mapView removeAnnotations:self->m_annotations];
        [self->m_annotations removeAllObjects];
        [self->m_flags removeAllObjects];        
        m_counter = 0;
     }
    Flag *flag = [[Flag alloc] init];
    for(NSInteger v = 0; v < 3; v++){
        //spawn easy
        for(NSInteger x = 0; x < 4; x++){
            flag = [self spawnPin:100 size:100 title:@"Easy"];
            Pin *annotation = [[Pin alloc]initWithCoordinate:[flag getCoordinate] andTitle:@"Easy"];
            [self->m_flags addObject:flag];
            [self->m_annotations addObject:annotation];
            self->m_counter += 1;
        }
        //spawn medium
        for(NSInteger x = 0; x < 3; x++){
            flag = [self spawnPin:500 size:250 title:@"Medium"];
            Pin *annotation = [[Pin alloc]initWithCoordinate:[flag getCoordinate] andTitle:@"Medium"];
            [self->m_flags addObject:flag];
            [self->m_annotations addObject:annotation];
            self->m_counter += 1;
        }
        //spawn hard
        for(NSInteger x = 0; x < 2; x++){
            flag = [self spawnPin:2000 size:1000 title:@"Hard"];
            Pin *annotation = [[Pin alloc]initWithCoordinate:[flag getCoordinate] andTitle:@"Hard"];
            [self->m_flags addObject:flag];
            [self->m_annotations addObject:annotation];
            self->m_counter += 1;
        }
    }
    NSInteger loop = 0;
    for(NSInteger *o = 0; o < self->m_counter; o++){
        [mapView addAnnotation:[self->m_annotations objectAtIndex:loop]];
        loop += 1;
        
    }
    [self drawBounds];
    self->m_multiplier = 1.0;
}

-(Flag *)spawnPin:(NSInteger)points size:(double)radius title:(NSString *)title{
    
    double latVar,lonVar;
    NSInteger decider;
    if(title == @"Easy"){
        lonVar = [self getRandom:[[self->m_boundaries objectAtIndex:0]intValue] maxNumber:[[self->m_boundaries objectAtIndex:1]intValue]];
        latVar = [self getRandom:[[self->m_boundaries objectAtIndex:0]intValue] maxNumber:[[self->m_boundaries objectAtIndex:1]intValue]];
    }else{
        if(title == @"Medium"){
            lonVar = [self getRandom:[[self->m_boundaries objectAtIndex:0]intValue] maxNumber:[[self->m_boundaries objectAtIndex:3]intValue]];
            latVar = [self getRandom:[[self->m_boundaries objectAtIndex:0]intValue] maxNumber:[[self->m_boundaries objectAtIndex:3]intValue]];
        }else{
            lonVar = [self getRandom:[[self->m_boundaries objectAtIndex:2]intValue] maxNumber:[[self->m_boundaries objectAtIndex:4]intValue]];
            latVar = [self getRandom:[[self->m_boundaries objectAtIndex:2]intValue] maxNumber:[[self->m_boundaries objectAtIndex:4]intValue]];
        }
    }
    decider = [self getRandomint:1 maxNumber:3];
    if(decider == 1){
        latVar *= -1;
    }
    decider = [self getRandomint:1 maxNumber:3];
    if(decider == 1){
        lonVar *= -1;
    }
    CLLocation *location = [[CLLocation alloc]initWithLatitude:mapView.userLocation.coordinate.latitude + latVar longitude:mapView.userLocation.coordinate.longitude +lonVar];
    Flag *flag = [[Flag alloc] initWithLocation:location.coordinate pointValue:points size:radius title: title];
    return flag;
}


-(void)focus{
    [self.mapView setShowsUserLocation:YES];
    [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    mapView.showsBuildings = YES;
    mapView.showsPointsOfInterest = YES;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, self->m_zoom, self->m_zoom);
    [self.mapView setRegion:region];
   
}

-(double) getRandom:(NSInteger)min maxNumber: (NSInteger) max{
    NSInteger ranny = arc4random_uniform((max - min));
    ranny += min;
    double ran = (double) ranny/1000;
    return ran;
}

-(NSInteger) getRandomint:(NSInteger)min maxNumber: (NSInteger) max{
    NSInteger ranny = arc4random() % (max - min);
    ranny += min;
    return ranny;
}

-(void)saveScore {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self->m_score forKey:@"Score"];
    [defaults synchronize];
}

-(void)loadScore{
    self->m_score = [[NSUserDefaults standardUserDefaults] integerForKey: @"Score"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc]init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    //set otherproperties
    self->m_counter = 0;
    self->m_score = 0;
    self->m_multiplier = 1.0;
    self->m_zoom = 1000.0;
    self->m_interval = 10;
    self->m_boundaries = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithFloat:15],[NSNumber numberWithFloat:50],[NSNumber numberWithFloat:125],[NSNumber numberWithFloat:400], nil];
    self->m_flags = [[NSMutableArray alloc]init];
    self->m_annotations = [[NSMutableArray alloc]init];
    self->m_closePins = [[NSMutableArray alloc]init];
    //run app
    [self focus];
    [self loadScore];
    [self startTimer];
    
    self->m_interval = 1800;

 
}

//-(void)mapView: (MKMapView *) mapView didAddAnnotationViews:(NSArray *)views{
//
//}


- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    static NSString *AnnotationViewID = @"annotationViewID";

        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        
        if (annotationView == nil)
        {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        }
    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        annotationView.animatesDrop = NO;
    }
    annotationView.annotation = annotation;
    if(annotation.title == @"Easy"){
        annotationView.pinColor = MKPinAnnotationColorGreen;
    }
    if(annotation.title == @"Medium"){
        annotationView.pinColor = MKPinAnnotationColorPurple;
    }
    if(annotation.title == @"Hard"){
        annotationView.pinColor = MKPinAnnotationColorRed;
    }
    return annotationView;
    

}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKCircle* circle = overlay;
    MKCircleView* circleView = [[MKCircleView alloc] initWithCircle: circle];
    if ([circle.title compare: @"Easy"] == NSOrderedSame) {
        circleView.fillColor = [UIColor clearColor];
        circleView.strokeColor = [UIColor greenColor];
    } else {
        if ([circle.title compare: @"Medium"] == NSOrderedSame) {
            circleView.fillColor = [UIColor clearColor];
            circleView.strokeColor = [UIColor purpleColor];
        }else{
            circleView.fillColor = [UIColor clearColor];
            circleView.strokeColor = [UIColor redColor];  
        }
    }
    circleView.lineWidth = 2.0;
    
    return circleView;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
