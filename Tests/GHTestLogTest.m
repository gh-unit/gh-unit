//
//  GHTestLogTest.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 7/30/09.
//  Copyright 2009 Yelp. All rights reserved.
//

#import "GHTestCase.h"

@interface GHTestLogTest : GHTestCase { }
@end

@implementation GHTestLogTest

- (void)testLog {
	for(NSInteger i = 0; i < 30; i++) {
		GHTestLog(@"Line: %d", i);
		[NSThread sleepForTimeInterval:0.01];
	}
}

- (void)testNSLog {
	for(NSInteger i = 0; i < 5; i++) {
		NSLog(@"Using NSLog: %d", i);
		fputs([@"stdout\n" UTF8String], stdout);
		fflush(stdout);		
	}
}

@end
