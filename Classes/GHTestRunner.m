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

#import <stdio.h>

@interface GHTestRunner (Private)
- (void)_notifyStart;
- (void)_notifyCancelled;
- (void)_notifyFinished;
- (void)_log:(NSString *)message;
- (void)_updateTest:(id<GHTest>)test;
@end

@implementation GHTestRunner

@synthesize test=test_, raiseExceptions=raiseExceptions_, delegate=delegate_, running=running_;

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

+ (GHTestRunner *)runnerForTestClassName:(NSString *)testClassName methodName:(NSString *)methodName {
	return [self runnerForSuite:[GHTestSuite suiteWithTestCaseClass:NSClassFromString(testClassName) method:NSSelectorFromString(methodName)]];
}

+ (GHTestRunner *)runnerFromEnv {	
	GHTestSuite *suite = [GHTestSuite suiteFromEnv];
	return [GHTestRunner runnerForSuite:suite];
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

- (int)run {
	cancelled_ = NO;
	running_ = YES;
	[self _notifyStart];
	[test_ run];
	if (cancelled_) {
		[self _notifyCancelled];
	} else {
		[self _notifyFinished];
	}
	running_ = NO;
	return self.stats.failureCount;
}

- (void)cancel {
	cancelled_ = YES;
	[test_ cancel];
	if ([delegate_ respondsToSelector:@selector(testRunnerDidCancel:)])
		[delegate_ testRunnerDidCancel:self];
}

- (GHTestStats)stats {
	return [test_ stats];
}

#define kGHTestRunnerInvokeWaitUntilDone YES

- (void)_log:(NSString *)message {
	fputs([[message stringByAppendingString:@"\n"] UTF8String], stderr);
  fflush(stderr);
	
	if ([delegate_ respondsToSelector:@selector(testRunner:didLog:)])
		[[(NSObject *)delegate_ ghu_proxyOnMainThread:kGHTestRunnerInvokeWaitUntilDone] 
		 testRunner:self didLog:message];
}

- (void)_didEndTest:(id<GHTest>)test {
	
	if ([delegate_ respondsToSelector:@selector(testRunner:didFinishTest:)])
		[[(NSObject *)delegate_ ghu_proxyOnMainThread:kGHTestRunnerInvokeWaitUntilDone] 
		 testRunner:self didEndTest:test];
}

#pragma mark Delegates (GHTest)

- (void)testDidStart:(id<GHTest>)test {
	if ([delegate_ respondsToSelector:@selector(testRunner:didStartTest:)])
		[[(NSObject *)delegate_ ghu_proxyOnMainThread:kGHTestRunnerInvokeWaitUntilDone] 
		 testRunner:self didStartTest:test];	
}

- (void)testDidUpdate:(id<GHTest>)test {	
	if ([delegate_ respondsToSelector:@selector(testRunner:didUpdateTest:)])
		[[(NSObject *)delegate_ ghu_proxyOnMainThread:kGHTestRunnerInvokeWaitUntilDone] 
		 testRunner:self didUpdateTest:test];	
}

- (void)testDidEnd:(id<GHTest>)test {	
	NSString *message = [NSString stringWithFormat:@"Test '%@' %@ (%0.3f seconds).",
											 [test name], [test stats].failureCount > 0 ? @"failed" : @"passed", [test interval]];	
	[self _log:message];
	
	if ([delegate_ respondsToSelector:@selector(testRunner:didEndTest:)])
		[[(NSObject *)delegate_ ghu_proxyOnMainThread:kGHTestRunnerInvokeWaitUntilDone] 
		 testRunner:self didEndTest:test];
}

- (void)test:(id<GHTest>)test didLog:(NSString *)message {
	if ([delegate_ respondsToSelector:@selector(testRunner:test:didLog:)])
		[[(NSObject *)delegate_ ghu_proxyOnMainThread:kGHTestRunnerInvokeWaitUntilDone] 
		 testRunner:self test:test didLog:message];
}

- (void)testDidIgnore:(id<GHTest>)test {
	
}

#pragma mark Notifications (Private)

- (void)_notifyStart {	
	NSString *message = [NSString stringWithFormat:@"Test Suite '%@' started.", [test_ name]];
	[self _log:message];
	
	if ([delegate_ respondsToSelector:@selector(testRunnerDidStart:)])
		[[(NSObject *)delegate_ ghu_proxyOnMainThread:kGHTestRunnerInvokeWaitUntilDone] 
		 testRunnerDidStart:self];
}

- (void)_notifyCancelled {
	NSString *message = [NSString stringWithFormat:@"Test Suite '%@' cancelled.\n", [test_ name]];
	[self _log:message];
	
	if ([delegate_ respondsToSelector:@selector(testRunnerDidEnd:)])
		[[(NSObject *)delegate_ ghu_proxyOnMainThread:kGHTestRunnerInvokeWaitUntilDone] 
		 testRunnerDidEnd:self];
}

- (void)_notifyFinished {
	NSString *message = [NSString stringWithFormat:@"Test Suite '%@' finished.\n"
											 "Executed %d tests, with %d failures in %0.3f seconds.\n",
											 [test_ name], [test_ stats].testCount - [test_ stats].ignoreCount, [test_ stats].failureCount, [test_ interval]];
	[self _log:message];
	
	
	if ([delegate_ respondsToSelector:@selector(testRunnerDidEnd:)])
		[[(NSObject *)delegate_ ghu_proxyOnMainThread:kGHTestRunnerInvokeWaitUntilDone] 
		 testRunnerDidEnd:self];
}

@end


