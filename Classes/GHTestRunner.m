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

@interface GHTestRunner (Notifications)
- (void)didStart;
- (void)didFinish;
@end

#import "GHTestCase.h"
#import "GTMDefines.h"

@interface GHTestRunner (Private)
- (void)_log:(NSString *)message;
@end

// GTM_BEGIN
#import <stdio.h>

@implementation GHTestRunner

@synthesize testSuite=testSuite_, raiseExceptions=raiseExceptions_, delegate=delegate_, delegateOnMainThread=delegateOnMainThread_;

- (id)initWithTestSuite:(GHTestSuite *)testSuite {
	if ((self = [super init])) {
		testSuite_ = [testSuite retain];
		testSuite_.delegate = self;
		delegateOnMainThread_ = YES;
	}
	return self;
}

- (void)dealloc {
	[testSuite_ release];
	[super dealloc];
}

- (BOOL)run {
	[self didStart];	
	BOOL passed = [testSuite_ run]; 
	[self didFinish];
	return passed;
}

// GTM_END

- (void)_log:(NSString *)message {
	fputs([[message stringByAppendingString:@"\n"] UTF8String], stderr);
  fflush(stderr);
	
	if ([delegate_ respondsToSelector:@selector(testRunner:didLog:)]) 
		[delegate_ testRunner:self didLog:message];
}

#define kGHTestRunnerInvokeWaitUntilDone YES

- (void)testCaseDidStart:(GHTestCase *)testCase {
	if ([delegate_ respondsToSelector:@selector(testRunner:didStartTestCase:)])
		[(id)delegate_ gh_performSelector:@selector(testRunner:didStartTestCase:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, testCase, nil];

}

- (void)testCase:(GHTestCase *)testCase didStartTest:(GHTest *)test {
	if ([delegate_ respondsToSelector:@selector(testRunner:didStartTest:)]) 
		[(id)delegate_ gh_performSelector:@selector(testRunner:didStartTest:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, test, nil];	

}

- (void)testCase:(GHTestCase *)testCase didFinishTest:(GHTest *)test passed:(BOOL)passed {
	
	NSString *message = [NSString stringWithFormat:@"Test '-[%@ %@]' %@ (%0.3f seconds).",
											 testCase.name, test.name, passed ? @"passed" : @"failed", test.interval];	
	[self _log:message];
	
	if ([delegate_ respondsToSelector:@selector(testRunner:didUpdateTest:)])
		[(id)delegate_ gh_performSelector:@selector(testRunner:didUpdateTest:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, test, nil];
}

- (void)testCaseDidFinish:(GHTestCase *)testCase {

	NSString *message = [NSString stringWithFormat:@"Test Case '%@' finished.\n"
											 "Executed %d tests, with %d failures in %0.3f seconds.\n",
											 testCase.name, testCase.totalCount, testCase.failedCount, testCase.interval];
	[self _log:message];
	
	
	if ([delegate_ respondsToSelector:@selector(testRunner:didFinishTestCase:)]) 
		[(id)delegate_ gh_performSelector:@selector(testRunner:didFinishTestCase:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, testCase, nil];

}


- (void)didStart {	
	NSString *message = [NSString stringWithFormat:@"Test Suite '%@' started.", testSuite_.name];
	[self _log:message];
	
	if ([delegate_ respondsToSelector:@selector(testRunnerDidStart:)])
		[(id)delegate_ gh_performSelector:@selector(testRunnerDidStart:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, nil];
}

- (void)didFinish {
	NSString *message = [NSString stringWithFormat:@"Test Suite '%@' finished.\n"
											 "Executed %d tests, with %d failures in %0.3f seconds.\n",
											 testSuite_.name, testSuite_.totalCount, testSuite_.failedCount, testSuite_.interval];
	[self _log:message];
	
	
	if ([delegate_ respondsToSelector:@selector(testRunnerDidFinish:)]) 
		[(id)delegate_ gh_performSelector:@selector(testRunnerDidFinish:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, nil];
}
	

@end


