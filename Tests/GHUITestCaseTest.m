//
//  GHUITestCaseTest.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 5/19/09.
//  Copyright 2009. All rights reserved.
//

#import "GHUITestCase.h"

@interface GHUITestCaseTest : GHUITestCase { }
@end


@implementation GHUITestCaseTest

- (void)testOnMainThread {
	GHAssertTrue([NSThread isMainThread], @"Should be on main thread for UI test");
}

@end
