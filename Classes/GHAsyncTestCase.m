//
//  GHAsyncTestCase.m
//  GHUnit
//
//  Created by Gabriel Handford on 4/8/09.
//  Copyright 2009. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "GHAsyncTestCase.h"
#import <objc/runtime.h>

@implementation GHAsyncTestCase

// Internal GHUnit setUp
- (void)_setUp {
	lock_ = [[NSRecursiveLock alloc] init];
	prepared_ = NO;
	notifiedStatus_ = kGHUnitWaitStatusUnknown;
}

// Internal GHUnit tear down
- (void)_tearDown {	
	waitSelector_ = NULL;
	if (prepared_) [lock_ unlock]; // If we prepared but never waited we need to unlock
	[lock_ release];
	lock_ = nil;
}

- (void)prepare {
	[self prepare:self.currentSelector];
}

- (void)prepare:(SEL)selector {	
	[lock_ lock];
	prepared_ = YES;
	waitSelector_ = selector;
	notifiedStatus_ = kGHUnitWaitStatusUnknown;
}

- (void)waitFor:(NSInteger)status timeout:(NSTimeInterval)timeout {	
	if (!prepared_) {
		GHFail(@"Call prepare before calling asynchronous method and waitFor:timeout:");
		return;
	}
	prepared_ = NO;
	
	waitForStatus_ = status;

	NSTimeInterval checkEveryInterval = 0.1;
	NSDate *runUntilDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
	BOOL timedOut = NO;
	while(notifiedStatus_ == kGHUnitWaitStatusUnknown) {
		
		[lock_ unlock];
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:checkEveryInterval]];
		[lock_ lock];
		
		// If current date is after the run until date
		if ([runUntilDate compare:[NSDate date]] == NSOrderedAscending) {
			timedOut = YES;
			break;
		}
	}
	[lock_ unlock];

	if (timedOut) {
		GHFail(@"Request timed out");
	} else if (waitForStatus_ != notifiedStatus_) {
		GHFail(@"Request finished with the wrong status: %d != %d", waitForStatus_, notifiedStatus_);	
	}	
}

- (void)notify:(NSInteger)status forSelector:(SEL)selector {
	// Note: If this is called from a stray thread or delayed call, we may not be in an autorelease pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Make sure the notify is for the currently waiting test
	if (selector != NULL && !sel_isEqual(waitSelector_, selector)) {
		NSLog(@"Warning: Notified from %@ but we were waiting for %@", NSStringFromSelector(selector), NSStringFromSelector(waitSelector_));
		return;
	}	

	[lock_ lock];
	notifiedStatus_ = status;
	[lock_ unlock];
	[pool release];
}

@end
