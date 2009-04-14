//
//  GHSlowTest.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/24/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestCase.h"

@interface GHSlowTest : GHTestCase { }
@end


@implementation GHSlowTest

#define kSlowTestTimeInterval 0.1

- (void)testSlow {
	[NSThread sleepForTimeInterval:kSlowTestTimeInterval];
	// TODO(gabe): Check interval > kSlowTestTimeInterval
}

- (void)testLog {
	for(NSInteger i = 0; i < 30; i++) {
		GHTestLog(@"Line: %d", i);
		[NSThread sleepForTimeInterval:0.03];
	}
}

// For testing display

- (void)testException {
	GHTestLog(@"Will raise an exception");
	[NSException raise:@"SomeException" format:@"Some reason for the exception"];
}

- (void)testMacroFail {
	GHAssertTrue(NO, @"Test fail");
}


@end
