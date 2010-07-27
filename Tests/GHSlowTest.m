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

- (void)test2Seconds {
  [NSThread sleepForTimeInterval:2];
}

@end
