//
//  GHTestApp.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/20/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestApp.h"

@implementation GHTestApp

- (id)init {
	if ((self = [super init])) {
		windowController_ = [[GHTestWindowController alloc] init];
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];	
		topLevelObjects_ = [[NSMutableArray alloc] init]; 
		NSDictionary *externalNameTable = [NSDictionary dictionaryWithObjectsAndKeys:self, @"NSOwner", topLevelObjects_, @"NSTopLevelObjects", nil]; 
		[bundle loadNibFile:@"GHTestApp" externalNameTable:externalNameTable withZone:[self zone]];			
	}
	return self;
}

- (id)initWithSuite:(GHTestSuite *)suite {
	// Since init loads XIB we need to set suite early; For backwards compat.
	suite_ = [suite retain];
	if ((self = [self init])) { }
	return self;
}

- (void)awakeFromNib { 
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) 
																							 name:NSApplicationWillTerminateNotification object:nil];
	// For backwards compatibility
	[self runTests];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[suite_ release];
	[topLevelObjects_ release];
	[super dealloc];
}

- (void)runTests {
	[windowController_ showWindow:nil];
	[NSThread detachNewThreadSelector:@selector(_runTests) toTarget:self withObject:nil];	
}

- (void)_runTests {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];		

	// For backwards compatibility
	if (!suite_)
		suite_ = [[GHTestSuite suiteFromEnv] retain];
	
	GHTestRunner *runner = [[GHTestRunner runnerForSuite:suite_] retain];
	runner.delegate = self;
	runner.delegateOnMainThread = YES;
	// To allow exceptions to raise into the debugger, uncomment below
	//runner.raiseExceptions = YES;
	
	[runner run];
	[runner release];
	[pool release];
}

#pragma mark Notifications (NSApplication)

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Delegates (GHTestRunner)

- (void)testRunner:(GHTestRunner *)runner didLog:(NSString *)message {
	[windowController_.viewController log:message];
}

- (void)testRunner:(GHTestRunner *)runner test:(id<GHTest>)test didLog:(NSString *)message {
	[windowController_.viewController test:test didLog:message];
}

- (void)testRunner:(GHTestRunner *)runner didStartTest:(id<GHTest>)test {
	[windowController_.viewController updateTest:test];
}

- (void)testRunner:(GHTestRunner *)runner didFinishTest:(id<GHTest>)test {
	[windowController_.viewController updateTest:test];
}

- (void)testRunnerDidStart:(GHTestRunner *)runner { 
	[windowController_.viewController setRoot:(id<GHTestGroup>)runner.test];
	[windowController_.viewController updateTest:runner.test];
}

- (void)testRunnerDidFinish:(GHTestRunner *)runner {
	[windowController_.viewController updateTest:runner.test];
	[windowController_.viewController selectFirstFailure];
	//[[NSApplication sharedApplication] terminate:nil];
}

@end
