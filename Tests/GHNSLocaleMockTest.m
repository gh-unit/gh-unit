//
//  GHUnitMockTest.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 4/13/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestCase.h"
#import "GHNSLocale+Mock.h"

@interface GHNSLocaleMockTest : GHTestCase { }
@end

@implementation GHNSLocaleMockTest

- (void)testLocale {
	[NSLocale gh_setLocaleIdentifier:@"en_GB"];
	NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
	GHAssertEqualStrings(localeIdentifier, @"en_GB", nil);
}

@end
