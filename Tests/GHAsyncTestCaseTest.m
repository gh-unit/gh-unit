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

- (void)testURLConnection {
  
  // Call prepare to setup the asynchronous action.
  // This helps in cases where the action is synchronous and the
  // action occurs before the wait is actually called.
  [self prepare];
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
  
  // Wait until notify called for timeout (seconds); If notify is not called with kGHUnitWaitStatusSuccess then
  // we will throw an error.
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
  
  [connection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  GHTestLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  // Notify of success, specifying the method where wait is called.
  // This prevents stray notifies from affecting other tests.
  [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testURLConnection)];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  // Notify of connection failure
  [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testURLConnection)];
}

@end

