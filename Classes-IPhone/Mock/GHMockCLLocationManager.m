//
//  GHMockCLLocationManager.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 4/19/09.
//  Copyright 2009. All rights reserved.
//

#import "GHMockCLLocationManager.h"

#import "GHNSObject+Invocation.h"

@implementation GHMockCLLocationManager

@synthesize delegate=_delegate;

- (id)init {
	if ((self = [super init])) {
		_locationServicesEnabled = YES;
	}
	return self;
}

- (void)dealloc {
	_delegate = nil;
	[_previousLocation release];
	[super dealloc];
}

- (BOOL)locationServicesEnabled {
	return _locationServicesEnabled;
}

- (void)setLocationServicesEnabled:(BOOL)enabled {
	_locationServicesEnabled = enabled;
}

- (void)startUpdatingLocation {
	_updatingLocation = YES;
}

- (void)stopUpdatingLocation {
	_updatingLocation = NO;
}

- (void)_notifyErrorCode:(NSNumber *)errorCodeNumber {
	NSError *error = [NSError errorWithDomain:kCLErrorDomain code:[errorCodeNumber integerValue] userInfo:nil];
	[_delegate locationManager:self didFailWithError:error];
}

- (void)notifyDeniedAfterDelay:(NSTimeInterval)delay {
	[self ghu_performSelector:@selector(_notifyErrorCode:) afterDelay:delay withObjects:[NSNumber numberWithInteger:kCLErrorDenied], nil];
}

- (void)notifyUnknownAfterDelay:(NSTimeInterval)delay {
	[self ghu_performSelector:@selector(_notifyErrorCode:) afterDelay:delay withObjects:[NSNumber numberWithInteger:kCLErrorLocationUnknown], nil];
}

- (void)notifyLocationCoordinate:(CLLocationCoordinate2D)coordinate afterDelay:(NSTimeInterval)delay {
	CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:0 horizontalAccuracy:kCLLocationAccuracyBest 
																							 verticalAccuracy:kCLLocationAccuracyBest timestamp:[NSDate date]];
	[(id)_delegate ghu_performSelector:@selector(locationManager:didUpdateToLocation:fromLocation:) afterDelay:delay withObjects:self, location, _previousLocation, nil];
	[_previousLocation release];
	_previousLocation = location;
}

- (void)move:(CLLocationDistance)distance bearingInDegrees:(double)bearingInDegrees afterDelay:(NSTimeInterval)delay {
	NSAssert(_previousLocation, @"Must have previous location to move from");
	
	CLLocationCoordinate2D coordinate = GHULocationAtDistance(_previousLocation.coordinate, distance, GHUDegreesToRadians(bearingInDegrees));
	[self notifyLocationCoordinate:coordinate afterDelay:delay];
}

@end

double GHUDegreesToRadians(double val) {
	return val * (M_PI/180);
}

double GHURadiansToDegrees(double val) {
	return val * (180/M_PI);
}

CLLocationCoordinate2D GHULocationAtDistance(CLLocationCoordinate2D coordinate, CLLocationDistance distance, double bearingInRadians) {
	double lat1 = GHUDegreesToRadians(coordinate.latitude);
	double lon1 = GHUDegreesToRadians(coordinate.longitude);
	
	double a = 6378137, b = 6356752.3142, f = 1/298.257223563;  // WGS-84 ellipsiod
	double s = distance;
	double alpha1 = bearingInRadians;
	double sinAlpha1 = sin(alpha1);
	double cosAlpha1 = cos(alpha1);
	
	double tanU1 = (1 - f) * tan(lat1);
	double cosU1 = 1 / sqrt((1 + tanU1 * tanU1));
	double sinU1 = tanU1 * cosU1;
	double sigma1 = atan2(tanU1, cosAlpha1);
	double sinAlpha = cosU1 * sinAlpha1;
	double cosSqAlpha = 1 - sinAlpha * sinAlpha;
	double uSq = cosSqAlpha * (a * a - b * b) / (b * b);
	double A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
	double B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
	
	double sigma = s / (b * A);
	double sigmaP = 2 * M_PI;
	
	double cos2SigmaM, sinSigma, cosSigma;
	
	while(abs(sigma - sigmaP) > 1e-12) {
		cos2SigmaM = cos(2 * sigma1 + sigma);
		sinSigma = sin(sigma);
		cosSigma = cos(sigma);
		double deltaSigma = B * sinSigma * (cos2SigmaM + B / 4 * (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) - B / 6 * cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 * cos2SigmaM * cos2SigmaM)));
		sigmaP = sigma;
		sigma = s / (b * A) + deltaSigma;
	}
	
	double tmp = sinU1 * sinSigma - cosU1 * cosSigma * cosAlpha1;
	double lat2 = atan2(sinU1 * cosSigma + cosU1 * sinSigma * cosAlpha1, (1 - f) * sqrt(sinAlpha * sinAlpha + tmp * tmp));
	double lambda = atan2(sinSigma * sinAlpha1, cosU1 * cosSigma - sinU1 * sinSigma * cosAlpha1);
	double C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
	double L = lambda - (1 - C) * f * sinAlpha * (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
	
	double lon2 = lon1 + L;
	
	CLLocationCoordinate2D dest;
	dest.latitude = GHURadiansToDegrees(lat2);
	dest.longitude = GHURadiansToDegrees(lon2);
	return dest;
}