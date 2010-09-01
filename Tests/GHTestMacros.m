//
//  GHTestMacros.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 8/31/10.
//  Copyright 2010. All rights reserved.
//


#import "GHTestCase.h"

// Test macros in cases where we made modifications from GTM
@interface GHTestMacros : GHTestCase { }
@end

@implementation GHTestMacros

- (void)testGHAssertNotEqualStrings {
  GHAssertNotEqualStrings(@"a", @"b", nil);
  GHAssertNotEqualStrings(@"a", nil, nil);
  GHAssertNotEqualStrings(nil, @"a", nil);
  GHAssertThrows({ GHAssertNotEqualStrings(@"a", @"a", nil); }, nil);
}

@end
