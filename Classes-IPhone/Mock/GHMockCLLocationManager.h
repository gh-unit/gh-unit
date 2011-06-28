//
//  GHMockCLLocationManager.h
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 4/19/09.
//  Copyright 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface GHMockCLLocationManager : CLLocationManager {
	id<CLLocationManagerDelegate> _delegate; // weak
	
	CLLocation *_previousLocation;
	
	BOOL _locationServicesEnabled;
	BOOL _updatingLocation;
}

- (void)setLocationServicesEnabled:(BOOL)enabled;

- (void)notifyDeniedAfterDelay:(NSTimeInterval)delay;
- (void)notifyUnknownAfterDelay:(NSTimeInterval)delay;
- (void)notifyLocationCoordinate:(CLLocationCoordinate2D)coordinate afterDelay:(NSTimeInterval)delay;

- (void)move:(CLLocationDistance)distance bearingInDegrees:(double)bearingInDegrees afterDelay:(NSTimeInterval)delay;

@end


/*!
 Calculate an endpoint given a startpoint, bearing and distance
 Vincenty 'Direct' formula based on the formula as described at http://www.movable-type.co.uk/scripts/latlong-vincenty-direct.html
 Original JavaScript implementation © 2002-2006 Chris Veness
 Obj-C code derived from http://www.thismuchiknow.co.uk/?p=120
 @param source Starting lat/lng coordinates
 @param distance Distance in meters to move
 @param bearingInRadians Bearing in radians (bearing is 0 north clockwise compass direction; 0 degrees is north, 90 degrees is east)
 @result New lat/lng coordinate
 */
CLLocationCoordinate2D GHULocationAtDistance(CLLocationCoordinate2D source, CLLocationDistance distance, double bearingInRadians);

double GHUDegreesToRadians(double val);
