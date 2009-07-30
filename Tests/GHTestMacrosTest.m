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
	GHAssertEqualsWithAccuracy(15, 15.000001, 0.001, nil);
}

@end