//
//  GHSlowTest.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/24/09.
//  Copyright 2009. All rights reserved.
//

@interface GHSlowTest : GHTestCase { }
@end


@implementation GHSlowTest

- (void)testSlow {
	[NSThread sleepForTimeInterval:5.0];
}

@end
