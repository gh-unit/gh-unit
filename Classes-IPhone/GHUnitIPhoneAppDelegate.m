//
//  GHUnitIPhoneAppDelegate.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 1/25/09.
//  Copyright 2009. All rights reserved.
//

#import "GHUnitIPhoneAppDelegate.h"
#import "GHUnitIPhoneViewController.h"

@implementation GHUnitIPhoneAppDelegate

@synthesize window=window_;

- (void)runTests {	
	[NSThread detachNewThreadSelector:@selector(_runTests) toTarget:self withObject:nil];	
}

- (void)_runTests {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GHTestSuite *suite = [GHTestSuite allTests];
	GHTestRunner *runner = [[[GHTestRunner runnerForSuite:suite] retain] autorelease];
	runner.delegate = self;
	runner.delegateOnMainThread = YES;
	// To allow exceptions to raise into the debugger, uncomment below
	//runner.raiseExceptions = YES;
	
	[runner run];
	[pool release];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	viewController_ = [[GHUnitIPhoneViewController alloc] init];
	
	[window_ addSubview:viewController_.view];
	[window_ makeKeyAndVisible];
	
	[self runTests];
}

- (void)dealloc {
	[viewController_ release];
	[window_ release];
	[super dealloc];
}

#pragma mark Delegates (GHTestRunner)

- (void)testRunner:(GHTestRunner *)runner didLog:(NSString *)message {
}

- (void)testRunner:(GHTestRunner *)runner didStartTest:(id<GHTest>)test {
	[viewController_ updateTest:test];
}

- (void)testRunner:(GHTestRunner *)runner didFinishTest:(id<GHTest>)test {
	[viewController_ updateTest:test];
}

- (void)testRunnerDidStart:(GHTestRunner *)runner { 
	[viewController_ setGroup:(id<GHTestGroup>)runner.test];
}

- (void)testRunnerDidFinish:(GHTestRunner *)runner {
	
}

@end
