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

@interface GHTestRunner (Private)
- (void)_notifyStart;
- (void)_notifyFinished;
- (void)_log:(NSString *)message;
- (void)_updateTest:(id<GHTest>)test;
@end

// GTM_BEGIN
#import <stdio.h>

@implementation GHTestRunner

@synthesize testable=testable_, raiseExceptions=raiseExceptions_, delegate=delegate_, delegateOnMainThread=delegateOnMainThread_;

- (id)initWithTestable:(id<GHTest>)testable {
	if ((self = [super init])) {
		testable_ = [testable retain];
		delegateOnMainThread_ = YES;
	}
	return self;
}

+ (GHTestRunner *)allTests {
	GHTestGroup *allGroup = [GHTestGroup allTests:nil];
	GHTestRunner *runner = [[GHTestRunner alloc] initWithTestable:allGroup];
	allGroup.delegate = runner;
	return [runner autorelease];
}

- (void)dealloc {
	[testable_ release];
	[super dealloc];
}

- (void)run {
	NSParameterAssert(testable_);
	[self _notifyStart];	
	[testable_ run]; 
	[self _notifyFinished];
}

// GTM_END

- (void)_log:(NSString *)message {
	fputs([[message stringByAppendingString:@"\n"] UTF8String], stderr);
  fflush(stderr);
	
	if ([delegate_ respondsToSelector:@selector(testRunner:didLog:)]) 
		[delegate_ testRunner:self didLog:message];
}

#define kGHTestRunnerInvokeWaitUntilDone YES

- (void)_updateTest:(id<GHTest>)test {
	if ([delegate_ respondsToSelector:@selector(testRunner:didUpdateTest:)])
		[(id)delegate_ gh_performSelector:@selector(testRunner:didUpdateTest:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, test, nil];	
}

#pragma mark Delegates (GHTest)

- (void)testWillStart:(id<GHTest>)test {

}

- (void)testUpdated:(id<GHTest>)test {
	[self _updateTest:test];
}

- (void)testDidFinish:(id<GHTest>)test {
	
	NSString *message = [NSString stringWithFormat:@"Test '%@' %@ (%0.3f seconds).",
											 [test name], [test stats].failureCount > 0 ? @"failed" : @"passed", [test interval]];	
	[self _log:message];
	[self _updateTest:test];
}

#pragma mark Notifications (Private)

- (void)_notifyStart {	
	NSString *message = [NSString stringWithFormat:@"Test Group '%@' started.", [testable_ name]];
	[self _log:message];
	
	if ([delegate_ respondsToSelector:@selector(testRunnerDidStart:)])
		[(id)delegate_ gh_performSelector:@selector(testRunnerDidStart:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, nil];
}

- (void)_notifyFinished {
	NSString *message = [NSString stringWithFormat:@"Test Group '%@' finished.\n"
											 "Executed %d tests, with %d failures in %0.3f seconds.\n",
											 [testable_ name], [testable_ stats].testCount, [testable_ stats].failureCount, [testable_ interval]];
	[self _log:message];
	
	
	if ([delegate_ respondsToSelector:@selector(testRunnerDidFinish:)]) 
		[(id)delegate_ gh_performSelector:@selector(testRunnerDidFinish:) onMainThread:delegateOnMainThread_ 
												waitUntilDone:kGHTestRunnerInvokeWaitUntilDone withObjects:self, nil];
}
	

@end


