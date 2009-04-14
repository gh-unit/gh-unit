//
//  GHUnitMockTest.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 4/13/09.
//  Copyright 2009 Yelp. All rights reserved.
//

#import "GHTestCase.h"
#import "GHNSLocale+Mock.h"

@interface GHUnitMockTest : GHTestCase { }
@end

@implementation GHUnitMockTest

- (void)testLocaleMock {
	[NSLocale gh_setLocaleIdentifier:@"en_GB"];
	NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
	GHAssertEqualStrings(localeIdentifier, @"en_GB", nil);
}

@end
