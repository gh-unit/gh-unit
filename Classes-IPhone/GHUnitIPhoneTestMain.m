//
//  GHUnitIPhoneTestMain.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 1/25/09.
//  Copyright 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/NSDebug.h>

// Creates an application that runs all tests from classes extending
// SenTestCase, outputs results and test run time, and terminates right
// afterwards.
int main(int argc, char *argv[]) {
	NSDebugEnabled = YES;
	NSZombieEnabled = YES;
	NSDeallocateZombies = NO;
	NSHangOnUncaughtException = YES;
	[NSAutoreleasePool enableFreedObjectCheck:YES];
	setenv("NSAutoreleaseFreedObjectCheckEnabled", "1", 1);
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	
	int retVal = UIApplicationMain(argc, argv, nil, @"GHUnitIPhoneAppDelegate");
	[pool release];
	return retVal;
}
