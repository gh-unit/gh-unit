//
//  GHTestCore.m
//  GHKit
//
//  Created by Gabriel Handford on 1/19/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestCase.h"

@interface GHTestCore : GHTestCase { }
@end

@implementation GHTestCore

- (void)testLog {
	GHTestLog(@"A simple log message");
	GHTestLog(@"A %@ message with var args, %d", @"log", 1);
}

- (void)testException {
	GHTestLog(@"Will raise an exception");
	[NSException raise:@"SomeException" format:@"Some reason for the exception"];
}

- (void)testMacroFail {
	GHAssertTrue(NO, @"Test fail");
}

@end
