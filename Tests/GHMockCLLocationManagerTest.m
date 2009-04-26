//
//  GHMockCLLocationManagerTest.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 4/23/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestCase.h"
#import "GHMockCLLocationManager.h"

@interface GHMockCLLocationManagerTest : GHTestCase {}
@end

@implementation GHMockCLLocationManagerTest

- (void)testNotify {
	GHMockCLLocationManager *locationManager = [[GHMockCLLocationManager alloc] init];
	//locationManager.delegate = self;
	// TODO(gabe): Finish test
	[locationManager release];
}

@end
