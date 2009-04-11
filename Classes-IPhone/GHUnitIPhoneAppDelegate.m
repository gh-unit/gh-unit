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

- (void)runTests {	
	[NSThread detachNewThreadSelector:@selector(_runTests) toTarget:self withObject:nil];	
}

- (void)_runTests {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GHTestRunner *runner = [[[GHTestRunner runnerFromEnv] retain] autorelease];
	runner.delegate = self;
	runner.delegateOnMainThread = YES;
	// To allow exceptions to raise into the debugger, uncomment below
	//runner.raiseExceptions = YES;
	
	[runner run];
	[pool release];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	viewController_ = [[GHUnitIPhoneViewController alloc] init];
	navigationController_ = [[UINavigationController alloc] initWithRootViewController:viewController_];
	CGSize size = [[UIScreen mainScreen] applicationFrame].size;
	window_ = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
	[window_ addSubview:navigationController_.view];
	[window_ makeKeyAndVisible];	
	[self runTests];
}

- (void)dealloc {
	[navigationController_ release];
	[viewController_ release];
	[window_ release];
	[super dealloc];
}

#pragma mark Delegates (GHTestRunner)

- (void)testRunner:(GHTestRunner *)runner didLog:(NSString *)message {
	[viewController_ setStatusText:message];
}

- (void)testRunner:(GHTestRunner *)runner test:(id<GHTest>)test didLog:(NSString *)message {

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
