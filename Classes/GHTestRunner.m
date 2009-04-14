//
//  GHTestRunner.m
//
//  Copyright 2008 Gabriel Handford
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

//
// Portions of this file fall under the following license, marked with:
// GTM_BEGIN : GTM_END
//
//  Copyright 2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "GHTestRunner.h"
#import "GHTestSuite.h"
#import "GHTesting.h"
#import "GHNSObject+Invocation.h"

#import <stdio.h>

@interface GHTestRunner (Private)
- (void)_notifyStart;
- (void)_notifyFinished;
- (void)_log:(NSString *)message;
- (void)_updateTest:(id<GHTest>)test;
@end

@implementation GHTestRunner

@synthesize test=test_, raiseExceptions=raiseExceptions_, delegate=delegate_, delegateOnMainThread=delegateOnMainThread_;

- (id)init {
	if ((self = [super init])) {
		delegateOnMainThread_ = YES;
	}
	return self;
}

- (id)initWithTest:(id<GHTest>)test {
	if ((self = [self init])) {
		test_ = [test retain];
	}
	return self;
}

+ (GHTestRunner *)runnerForAllTests {
	GHTestSuite *suite = [GHTestSuite allTests];
	return [self runnerForSuite:suite];
}

+ (GHTestRunner *)runnerForSuite:(GHTestSuite *)suite {	
	GHTestRunner *runner = [[GHTestRunner alloc] initWithTest:suite];
	suite.delegate = runner;
	return [runner autorelease];
}

+ (GHTestRunner *)runnerFromEnv {	
	GHTestRunner *testRunner = nil;
	
	const char* cTestFilter = getenv("TEST");
	if (cTestFilter) {
		NSString *testFilter = [NSString stringWithUTF8String:cTestFilter];
		GHTestSuite *suite = [GHTestSuite suiteWithTestFilter:testFilter];	
		if (!suite) return nil;
		// Run a single or set of tests
		testRunner = [GHTestRunner runnerForSuite:suite];
	} else {			
		// Default option is to run all tests
		testRunner = [GHTestRunner runnerForAllTests];
	}
	return testRunner;
}	

+ (int)run {
	GHTestRunner *testRunner = [GHTestRunner runnerFromEnv];
	[testRunner run];
	return testRunner.stats.failureCount;
}

- (void)dealloc {
	[test_ release];
	[super dealloc];
}

- (void)run {
	[self _notifyStart];	
	[test_ run]; 
	[self _notifyFinished];
}

- (GHTestStats)stats {
	return [test_ stats];
}

#define kGHTestRunnerInvokeWaitUntilDone YES

- (void)_log:(NSString *)message {
	fputs([[message stringByAppendingString:@"\n"] UTF8String], stderr);
  fflush(stderr);
	
	if ([delegate_ respondsToSelector:@selector(testRunner:didLog:)])
		[(id)delegate_ gh_performSelector:@selector(testRunner:didLog:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, message, nil];	
}

- (void)_didStartTest:(id<GHTest>)test {
	if ([delegate_ respondsToSelector:@selector(testRunner:didStartTest:)])
		[(id)delegate_ gh_performSelector:@selector(testRunner:didStartTest:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, test, nil];	
}

- (void)_didFinishTest:(id<GHTest>)test {
	if ([delegate_ respondsToSelector:@selector(testRunner:didFinishTest:)])
		[(id)delegate_ gh_performSelector:@selector(testRunner:didFinishTest:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, test, nil];	
}

- (void)_test:(id<GHTest>)test didLog:(NSString *)message {
	NSLog(@"%@; %@\n", [test identifier], message);

	if ([delegate_ respondsToSelector:@selector(testRunner:test:didLog:)])
		[delegate_ testRunner:self test:test didLog:message];
}	

#pragma mark Delegates (GHTest)

- (void)testDidStart:(id<GHTest>)test {
	[self _didStartTest:test];
}

- (void)testDidFinish:(id<GHTest>)test {
	
	NSString *message = [NSString stringWithFormat:@"Test '%@' %@ (%0.3f seconds).",
											 [test name], [test stats].failureCount > 0 ? @"failed" : @"passed", [test interval]];	
	[self _log:message];
	[self _didFinishTest:test];
}

- (void)test:(id<GHTest>)test didLog:(NSString *)message {	
	[self gh_performSelector:@selector(_test:didLog:) onMainThread:delegateOnMainThread_ 
						 waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:test, message, nil];
}

#pragma mark Notifications (Private)

- (void)_notifyStart {	
	NSString *message = [NSString stringWithFormat:@"Test Suite '%@' started.", [test_ name]];
	[self _log:message];
	
	if ([delegate_ respondsToSelector:@selector(testRunnerDidStart:)])
		[(id)delegate_ gh_performSelector:@selector(testRunnerDidStart:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, nil];
}

- (void)_notifyFinished {
	NSString *message = [NSString stringWithFormat:@"Test Suite '%@' finished.\n"
											 "Executed %d tests, with %d failures in %0.3f seconds.\n",
											 [test_ name], [test_ stats].testCount, [test_ stats].failureCount, [test_ interval]];
	[self _log:message];
	
	
	if ([delegate_ respondsToSelector:@selector(testRunnerDidFinish:)]) 
		[(id)delegate_ gh_performSelector:@selector(testRunnerDidFinish:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, nil];
}

@end


