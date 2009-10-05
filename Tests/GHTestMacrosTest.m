//
//  GHTestMacrosTest.m
//  GHUnit
//
//  Created by Gabriel Handford on 7/30/09.
//  Copyright 2009 Yelp. All rights reserved.
//


#import "GHTestCase.h"

@interface GHTestMacrosTest : GHTestCase { }
@end

@implementation GHTestMacrosTest

- (void)testEquals {
	GHAssertEqualsWithAccuracy(15.0, 15.000001, 0.001, nil);
}

- (void)testEqualsAccuracyMessage {
	GHAssertThrows({
		GHAssertEqualsWithAccuracy(15.0, 16.0, 0.001, nil);
	}, nil);
}

- (void)testNSLog {
	NSLog(@"Testing NSLog");	
	// TODO(gabe): Test this was output
}

@end