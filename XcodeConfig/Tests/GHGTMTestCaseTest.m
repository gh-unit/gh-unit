//
//  GHGTMTestCaseTest.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/30/09.
//  Copyright 2009. All rights reserved.
//

#import "GTMSenTestCase.h"

// To test that we work with GTMTestCase
@interface GHGTMTestCaseTest : GTMTestCase { }
@end

@implementation GHGTMTestCaseTest

- (void)test {
  STAssertTrue(YES, nil);
}

@end
