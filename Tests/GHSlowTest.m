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

#define kSlowTestTimeInterval 0.3

- (void)testSlowA {
	[NSThread sleepForTimeInterval:kSlowTestTimeInterval];
}

- (void)testSlowB {
	[NSThread sleepForTimeInterval:kSlowTestTimeInterval];
}

- (void)testSlowC {
	[NSThread sleepForTimeInterval:kSlowTestTimeInterval];
}

@end
