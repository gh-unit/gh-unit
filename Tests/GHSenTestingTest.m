//
//  GHSenTestingTest.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/21/09.
//  Copyright 2009. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>

// To test that we work with SenTestCase as well
@interface GHSenTestingTest : SenTestCase { }
@end

@implementation GHSenTestingTest

- (void)test {
	STAssertTrue(YES, nil);
}

@end
