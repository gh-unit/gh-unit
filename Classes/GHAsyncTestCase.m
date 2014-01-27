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
#import "PGMockRunLoop.h"
#import <objc/runtime.h>

typedef enum {
  kGHUnitAsyncErrorNone,
  kGHUnitAsyncErrorUnprepared,
  kGHUnitAsyncErrorTimedOut,
  kGHUnitAsyncErrorInvalidStatus
} GHUnitAsyncError;

@implementation GHAsyncTestCase

@synthesize runLoopModes=_runLoopModes;
@synthesize notifiedStatus = notifiedStatus_;


// Internal GHUnit setUp
- (void)_setUp {
  //lock_ = [[NSRecursiveLock alloc] init];
    notified_status_lock_ = [[NSRecursiveLock alloc] init];
  prepared_ = NO;
    [notified_status_lock_ lock];
  notifiedStatus_ = kGHUnitWaitStatusUnknown;
    [notified_status_lock_ unlock];
}

// Internal GHUnit tear down
- (void)_tearDown { 
  waitSelector_ = NULL;
  //if (prepared_) [lock_ unlock]; // If we prepared but never waited we need to unlock
  //lock_ = nil;
}

- (void)prepare {
  [self prepare:self.currentSelector];
}

- (void)prepare:(SEL)selector { 
  //[lock_ lock];
  prepared_ = YES;
  waitSelector_ = selector;
    [notified_status_lock_ lock];
  notifiedStatus_ = kGHUnitWaitStatusUnknown;
    [notified_status_lock_ unlock];
}

- (void)_waitFor:(NSInteger)status timeout:(NSTimeInterval)timeout callbackTarget:(id) target selector:(SEL) selector {
    NSArray* args = [NSArray arrayWithObjects:[NSNumber numberWithInt:status], target, [NSValue valueWithPointer:selector], nil];
    [PGMockRunLoop addTimeoutTarget:self selector:@selector(_wait_callback:) argument:args timeout:timeout status:(NSInteger) status testCase:self];

}


-(void) _wait_callback:(NSArray*) args {
    int status = ((NSNumber*)args[0]).intValue;
    id callbackTarget = args[1];
    SEL callbackSelector = (SEL)((NSValue*)args[2]).pointerValue;
    GHUnitAsyncError testCaseError;
    [notified_status_lock_ lock];
    if (failedWithException) {
        testCaseError = kGHUnitAsyncErrorInvalidStatus;
    } else if (status == kGHUnitWaitStatusUnknown) {
        testCaseError = kGHUnitAsyncErrorTimedOut;
    } else if (status!= notifiedStatus_) {
        testCaseError = kGHUnitAsyncErrorInvalidStatus;
    } else {
        testCaseError = kGHUnitAsyncErrorNone;
    }

    NSArray* callback_args = [NSArray arrayWithObjects:[NSNumber numberWithInt:testCaseError],
                     [NSNumber numberWithInt:status],
                     [NSNumber numberWithInt:notifiedStatus_],
                              nil];
        [notified_status_lock_ unlock];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [callbackTarget performSelector:callbackSelector withObject:callback_args];
#pragma clang diagnostic pop


}

- (void)waitFor:(NSInteger)status timeout:(NSTimeInterval)timeout {
  [NSException raise:NSDestinationInvalidException format:@"Deprecated; Use waitForStatus:timeout:"];
}

- (void)waitForStatus:(NSInteger)status {
    [PGMockRunLoop requestCallbackAfterCurrentRunLoopCompleteTarget:self selector:@selector(waitForStatusCallback:) argument:[NSNumber numberWithInt:status]];

}

- (void)waitForStatusCallback:(NSNumber*)status {
        [notified_status_lock_ lock];
    if (failedWithException) {
        [notified_status_lock_ unlock];
        GHFail(@"Request failed with an exception: %@", failedWithException);
    } else if (notifiedStatus_ != status.intValue) {
        [notified_status_lock_ unlock];
        GHFail(@"Request finished with the wrong status: %d != %d", status.intValue, notifiedStatus_);
    } else {
        [notified_status_lock_ unlock];
    }
}


- (void)waitForStatus:(NSInteger)status timeout:(NSTimeInterval)timeout {

  [self _waitFor:status timeout:timeout callbackTarget:self selector:@selector(waitForStatusCleanup:)];

}

-(void) waitForStatusCleanup:(NSArray*) args {
    GHUnitAsyncError errorFromTest = ((NSNumber*)args[0]).intValue;
    if (errorFromTest == kGHUnitAsyncErrorTimedOut) {
        GHFail(@"Request timed out");
    } else if (errorFromTest == kGHUnitAsyncErrorInvalidStatus) {
        int requestedStatus =((NSNumber*)args[1]).intValue;
        int notifiedStatus =((NSNumber*)args[2]).intValue;
        GHFail(@"Request finished with the wrong status: %d != %d", requestedStatus, notifiedStatus);
    } else if (errorFromTest == kGHUnitAsyncErrorUnprepared) {
        GHFail(@"Call prepare before calling asynchronous method and waitForStatus:timeout:");
    }
}

- (void)waitForTimeout:(NSTimeInterval)timeout {

  [self _waitFor:-1 timeout:timeout callbackTarget:self selector:@selector(waitForTimeoutCleanup:)];
}

-(void) waitForTimeoutCleanup:(NSArray*) args {
    GHUnitAsyncError errorFromTest = ((NSNumber*)args[0]).intValue;
    if (errorFromTest != kGHUnitAsyncErrorTimedOut) {
        GHFail(@"Request should have timed out");
    }
}

// Similar to _waitFor:timeout: but just runs the loops
// From Robert Palmer, pauseForTimeout
- (void)runForInterval:(NSTimeInterval)interval {
	NSTimeInterval checkEveryInterval = 0.05;
	NSDate *runUntilDate = [NSDate dateWithTimeIntervalSinceNow:interval];
  
	if (!_runLoopModes)
		_runLoopModes = @[NSDefaultRunLoopMode, NSRunLoopCommonModes];
  
	NSInteger runIndex = 0;
  
	while ([runUntilDate compare:[NSDate dateWithTimeIntervalSinceNow:0]] == NSOrderedDescending) {
		NSString *mode = _runLoopModes[(runIndex++ % [_runLoopModes count])];
    
		//[lock_ unlock];
		@autoreleasepool {
			if (!mode || ![[NSRunLoop currentRunLoop] runMode:mode beforeDate:[NSDate dateWithTimeIntervalSinceNow:checkEveryInterval]])
				// If there were no run loop sources or timers then we should sleep for the interval
				[NSThread sleepForTimeInterval:checkEveryInterval];
		}
		//[lock_ lock];
	}
}

- (void)notify:(NSInteger)status {
  [self notify:status forSelector:NULL];
}

- (void)notify:(NSInteger)status forSelector:(SEL)selector {
  // Note: If this is called from a stray thread or delayed call, we may not be in an autorelease pool
  @autoreleasepool {
  
  // Make sure the notify is for the currently waiting test
    if (selector != NULL && !sel_isEqual(waitSelector_, selector)) {
      NSLog(@"Warning: Notified from %@ but we were waiting for %@", NSStringFromSelector(selector), NSStringFromSelector(waitSelector_));
    }  else {
          [notified_status_lock_ lock];
            notifiedStatus_ = status;
          [notified_status_lock_ unlock];
    }

  }
}

@end
