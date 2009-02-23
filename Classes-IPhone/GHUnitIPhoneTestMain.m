//
//  GHUnitIPhoneTestMain.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 1/25/09.
//  Copyright 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/NSDebug.h>
#import "GHUnit.h"

// Creates an application that runs all tests from classes extending
// SenTestCase, outputs results and test run time, and terminates right
// afterwards.
int main(int argc, char *argv[]) {
	NSDebugEnabled = YES;
	NSZombieEnabled = YES;
	NSDeallocateZombies = NO;
	NSHangOnUncaughtException = YES;
	setenv("NSAutoreleaseFreedObjectCheckEnabled", "1", 1);
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	
	int retVal = -1;
	if (getenv("TEST_CLI")) {
		GHTestRunner *testRunner = [GHTestRunner runnerForAllTests];
		[testRunner run];
		retVal = testRunner.stats.failureCount;
	} else {		
		retVal = UIApplicationMain(argc, argv, nil, @"GHUnitIPhoneAppDelegate");
	}
	[pool release];
	return retVal;
}
