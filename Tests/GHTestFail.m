//
//  GHTestSingleFail.m
//  GHUnit
//
//  Created by Gabriel Handford on 7/15/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestCase.h"

@interface GHTestFail : GHTestCase { }
@end

@implementation GHTestFail

- (void)testFail {
	GHFail(@"Test failure");
}

- (void)testSucceedAfterFail {
}

@end

@interface GHTestException : GHTestCase { }
@end

@implementation GHTestException : GHTestCase { }

- (void)testException {
	GHTestLog(@"Will raise an exception");
	[NSException raise:@"SomeException" format:@"Some reason for the exception"];
}

@end