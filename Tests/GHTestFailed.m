//
//  GHTestFailed.m
//  GHKit
//
//  Created by Gabriel Handford on 1/19/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestFailed.h"


@implementation GHTestFailed

- (void)testException {
	[NSException raise:@"SomeException" format:@"Some reason for the exception"];
}

@end
