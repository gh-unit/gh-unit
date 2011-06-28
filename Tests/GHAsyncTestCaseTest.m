//
//  GHAsyncTestCaseTest.m
//  GHUnit
//
//  Created by Gabriel Handford on 4/8/09.
//  Copyright 2009. All rights reserved.
//

#import "GHAsyncTestCase.h"

@interface GHAsyncTestCaseTest : GHAsyncTestCase { }
@end

@implementation GHAsyncTestCaseTest

- (void)testStatusSuccess {
	[self prepare];
	[self performSelector:@selector(_testStatusSuccessNotify) withObject:nil afterDelay:0.0];
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)_testStatusSuccessNotify {
	[self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testStatusSuccess)];
}

- (void)testStatusFailure {
	[self prepare];
	[self performSelector:@selector(_testStatusFailureNotify) withObject:nil afterDelay:0.0];
	[self waitForStatus:kGHUnitWaitStatusFailure timeout:1.0];
}

- (void)_testStatusFailureNotify {
	[self notify:kGHUnitWaitStatusFailure forSelector:@selector(testStatusFailure)];
}

- (void)testStatusSuccessWithDelay {
	[self prepare];
	[self performSelector:@selector(_testStatusSuccessWithDelayNotify) withObject:nil afterDelay:0.3];
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)_testStatusSuccessWithDelayNotify {
	[self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testStatusSuccessWithDelay)];
}

- (void)testBadStatus {	
	[self prepare];
	[self performSelector:@selector(_testBadStatusNotify) withObject:nil afterDelay:0.0];
	GHAssertThrows([self waitForStatus:kGHUnitWaitStatusFailure timeout:1.0], @"Status should be mismatched");
}

- (void)_testBadStatusNotify {
	[self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testBadStatus)];
}

- (void)testMissingPrepare {
	GHAssertThrows([self waitForStatus:kGHUnitWaitStatusUnknown timeout:1.0], @"Should fail since we didn't call prepare");
}

- (void)testFinishBeforeWait {
	[self prepare];
	[self performSelectorInBackground:@selector(_testFinishBeforeWaitNotify) withObject:nil];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]]; // 0.2 is arbitrary, we want enough time for performSelectorInBackground to be called
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)_testFinishBeforeWaitNotify {
	[self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testFinishBeforeWait)];
}

- (void)testWaitNoSelectorCheck {
	[self prepare];
	[self performSelectorInBackground:@selector(_testWaitNoSelectorCheck) withObject:nil];
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)_testWaitNoSelectorCheck {
	[self notify:kGHUnitWaitStatusSuccess forSelector:NULL];
}

@end


@interface GHAsyncConnectionTestCaseTest : GHAsyncTestCase { }
@end

@implementation GHAsyncConnectionTestCaseTest

- (void)_testURLConnection {
	[self prepare];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
	[[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES] retain];
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testURLConnection)];
}

@end

