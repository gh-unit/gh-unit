//
//  GHTestOnMainThread.m
//  GHUnit
//
//  Created by Gabriel Handford on 7/18/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestCase.h"

@interface GHTestOnMainThread : GHTestCase { }
@end

static BOOL gGHTestOnMainThreadRunning = NO;

@implementation GHTestOnMainThread

- (BOOL)shouldRunOnMainThread {
  return YES;
}

- (void)setUp {
  GHAssertTrue([NSThread isMainThread], nil);
}

- (void)tearDown {
  GHAssertTrue([NSThread isMainThread], nil);
}

- (void)setUpClass {
  GHAssertTrue([NSThread isMainThread], nil);
}

- (void)tearDownClass {
  GHAssertTrue([NSThread isMainThread], nil);
}

- (void)testFail_EXPECTED {
  GHAssertTrue([NSThread isMainThread], nil);
  GHFail(@"Test failure");
}

- (void)testSucceedAfterFail {
  GHAssertTrue([NSThread isMainThread], nil);
}

- (void)testNotConcurrent {
  GHAssertFalse(gGHTestOnMainThreadRunning, nil);
  [NSThread sleepForTimeInterval:1];
  GHAssertFalse(gGHTestOnMainThreadRunning, nil);
}


@end


@interface GHTestOnMainThreadNotConcurrent : GHTestCase { }
@end

@implementation GHTestOnMainThreadNotConcurrent

- (void)testNotConcurrent {
  gGHTestOnMainThreadRunning = YES;
  [NSThread sleepForTimeInterval:1];
  gGHTestOnMainThreadRunning = NO;
}

@end

