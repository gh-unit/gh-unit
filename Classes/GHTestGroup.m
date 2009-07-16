//
//  GHTestGroup.m
//
//  Created by Gabriel Handford on 1/16/09.
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

#import "GHTestGroup.h"
#import "GHTestCase.h"

#import "GHTesting.h"
#import "GTMStackTrace.h"

@interface GHTestGroup (Private)
- (void)_addTest:(id<GHTest>)test;
- (void)_addTestsFromTestCase:(id)testCase;
@end

@implementation GHTestGroup

@synthesize stats=stats_, parent=parent_, children=children_, delegate=delegate_, interval=interval_, status=status_, testCase=testCase_, 
operationQueue=operationQueue_, exception=exception_;

- (id)initWithName:(NSString *)name delegate:(id<GHTestDelegate>)delegate {
	if ((self = [super init])) {
		name_ = [name retain];		
		children_ = [[NSMutableArray array] retain];
		delegate_ = delegate;
	} 
	return self;
}

- (id)initWithTestCase:(id)testCase operationQueue:(NSOperationQueue *)operationQueue delegate:(id<GHTestDelegate>)delegate {
	if ([self initWithName:NSStringFromClass([testCase class]) delegate:delegate]) {
		testCase_ = [testCase retain];
		operationQueue_ = operationQueue;
		[self _addTestsFromTestCase:testCase];
	}
	return self;
}

- (id)initWithTestCase:(id)testCase selector:(SEL)selector operationQueue:(NSOperationQueue *)operationQueue delegate:(id<GHTestDelegate>)delegate {
	if ([self initWithName:NSStringFromClass([testCase class]) delegate:delegate]) {
		testCase_ = [testCase retain];
		operationQueue_ = operationQueue;
		[self _addTest:[GHTest testWithTarget:testCase selector:selector]];
	}
	return self;
}

+ (GHTestGroup *)testGroupFromTestCase:(id)testCase operationQueue:(NSOperationQueue *)operationQueue delegate:(id<GHTestDelegate>)delegate {
	return [[[GHTestGroup alloc] initWithTestCase:testCase operationQueue:operationQueue delegate:delegate] autorelease];
}

- (void)dealloc {
	for(id<GHTest> test in children_)
		[test setDelegate:nil];
	[name_ release];
	[children_ release];
	[testCase_ release];
	operationQueue_ = nil;
	delegate_ = nil;
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@, %d %0.3f %d/%d (%d failures)", 
								 name_, status_, interval_, stats_.succeedCount, stats_.testCount, stats_.failureCount];
}
	
- (NSString *)name {
	return name_;
}

- (void)_addTestsFromTestCase:(id)testCase {
	NSArray *tests = [[GHTesting sharedInstance] loadTestsFromTarget:testCase];
	for(GHTest *test in tests) {
		[self _addTest:test];
	}
}

- (void)addTestCase:(id)testCase operationQueue:(NSOperationQueue *)operationQueue {
	GHTestGroup *testCaseGroup = [[GHTestGroup alloc] initWithTestCase:testCase operationQueue:operationQueue delegate:self];
	[self addTestGroup:testCaseGroup];
	[testCaseGroup release];
}

- (void)addTestGroup:(GHTestGroup *)testGroup {
	[self _addTest:testGroup];
	[testGroup setParent:self];		
}

- (void)_addTest:(id<GHTest>)test {
	stats_.testCount += [test stats].testCount;
		
	[test setDelegate:self];	
	[children_ addObject:test];	
}

- (NSString *)identifier {
	return name_;
}

// Forward up
- (void)test:(id<GHTest>)test didLog:(NSString *)message {
	[delegate_ test:test didLog:message];	
}

- (NSArray *)log {
	// Not supported for group (though may be an aggregate of child test logs in the future?)
	return nil;
}

- (void)reset {
	status_ = GHTestStatusNone;
	stats_ = GHTestStatsMake(0, 0, 0, 0, 0);
	[exception_ release];
	exception_ = nil;
	for(id<GHTest> test in children_)
		[test reset];
}

- (void)cancel {
	if (status_ == GHTestStatusRunning) {
		status_ = GHTestStatusCancelling;
	} else {
		status_ = GHTestStatusCancelled;
	}
}

- (void)disable {
	status_ = GHTestStatusDisabled;
}

- (void)_run {		
	status_ = GHTestStatusRunning;
	[delegate_ testDidStart:self];
	
	@try {
		if ([testCase_ respondsToSelector:@selector(setUpClass)])			
			[testCase_ setUpClass];
	} @catch(NSException *exception) {
		// If we fail in the setUpClass, then we will cancel all the child tests
		exception_ = [exception retain];
		status_ = GHTestStatusErrored;
	}
	
	for(id<GHTest> test in children_) {
		if ([test status] == GHTestStatusDisabled) {
			stats_.disabledCount++;
		} else if (status_ == GHTestStatusCancelling) {
			stats_.cancelCount++;
		} else if (status_ == GHTestStatusErrored) {
			stats_.failureCount++;
		} else {
			[test run];
		}
	}

	if (status_ == GHTestStatusRunning) {
		@try {
			if ([testCase_ respondsToSelector:@selector(tearDownClass)])		
				[testCase_ tearDownClass];
		} @catch(NSException *exception) {					
			exception_ = [exception retain];
			status_ = GHTestStatusErrored;
		}
	}
	
	if (status_ == GHTestStatusCancelling) {
		status_ = GHTestStatusCancelled;
	} else if (exception_ || stats_.failureCount > 0) {
		status_ = GHTestStatusErrored;
	} else {
		status_ = GHTestStatusSucceeded;
	}
	[delegate_ testDidEnd:self];
}

- (void)main {
	if ([self shouldRunOnMainThread]) {
		[self performSelectorOnMainThread:@selector(_run) withObject:nil waitUntilDone:YES];
	} else {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		self.delegate = [self.delegate ghu_proxyOnMainThread:YES];
		[self _run];
		[pool release];
	}
}

- (BOOL)shouldRunOnMainThread {
	if ([testCase_ respondsToSelector:@selector(shouldRunOnMainThread)]) 
		return [testCase_ shouldRunOnMainThread];
	return NO;
}

- (void)run {	
	if (operationQueue_) {
		[operationQueue_ addOperation:self];
	} else {
		[self _run];
	}
}

#pragma mark Delegates (GHTestDelegate)

// Add stats and pass test up
- (void)testDidStart:(id<GHTest>)test {
	[delegate_ testDidStart:test];
}

- (void)testDidUpdate:(id<GHTest>)test {
	[delegate_ testDidUpdate:test];	
}

// Add stats and pass test up
- (void)testDidEnd:(id<GHTest>)test {	
	if ([test interval] >= 0)
		interval_ += [test interval];	
	stats_.failureCount += [test stats].failureCount;
	stats_.succeedCount += [test stats].succeedCount;
	stats_.cancelCount += [test stats].cancelCount;
	stats_.disabledCount += [test stats].disabledCount;
	[delegate_ testDidUpdate:test];
}

@end
