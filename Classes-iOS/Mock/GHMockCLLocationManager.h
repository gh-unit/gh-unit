//
//  GHMockCLLocationManager.h
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 4/19/09.
//  Copyright 2009. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
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
