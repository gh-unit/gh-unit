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

- (void)testSlowA {
	[NSThread sleepForTimeInterval:1.0];
}

- (void)testSlowB {
	[NSThread sleepForTimeInterval:1.0];
}

- (void)testSlowC {
	[NSThread sleepForTimeInterval:1.0];
}

@end
