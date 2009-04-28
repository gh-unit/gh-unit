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
ignore=ignore_;

- (id)initWithName:(NSString *)name delegate:(id<GHTestDelegate>)delegate {
	if ((self = [super init])) {
		name_ = [name retain];		
		children_ = [[NSMutableArray array] retain];
		delegate_ = delegate;
	} 
	return self;
}

- (id)initWithTestCase:(id)testCase delegate:(id<GHTestDelegate>)delegate {
	if ([self initWithName:NSStringFromClass([testCase class]) delegate:delegate]) {
		testCase_ = [testCase retain];
		[self _addTestsFromTestCase:testCase];
	}
	return self;
}

- (id)initWithTestCase:(id)testCase selector:(SEL)selector delegate:(id<GHTestDelegate>)delegate {
	if ([self initWithName:NSStringFromClass([testCase class]) delegate:delegate]) {
		testCase_ = [testCase retain];
		[self _addTest:[GHTest testWithTarget:testCase selector:selector]];
	}
	return self;
}

+ (GHTestGroup *)testGroupFromTestCase:(id)testCase delegate:(id<GHTestDelegate>)delegate {
	return [[[GHTestGroup alloc] initWithTestCase:testCase delegate:delegate] autorelease];
}

- (void)dealloc {
	for(id<GHTest> test in children_)
		[test setDelegate:nil];
	
	[name_ release];
	[children_ release];
	[testCase_ release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@, %d %0.3f %d/%d (%d failures)", 
								 name_, status_, interval_, stats_.runCount, stats_.testCount, stats_.failureCount];
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

- (void)addTestCase:(id)testCase {
	GHTestGroup *testCaseGroup = [[GHTestGroup alloc] initWithTestCase:testCase delegate:self];
	[self addTestGroup:testCaseGroup];
	[testCaseGroup release];
}

- (void)addTestGroup:(GHTestGroup *)testGroup {
	[self _addTest:testGroup];
	[testGroup setParent:self];		
}

- (void)_addTest:(id<GHTest>)test {
	stats_.testCount += [test stats].testCount;
	
	// TODO(gabe): Logging stuff may need some refactoring
	if ([test respondsToSelector:@selector(setLogDelegate:)])
		[test performSelector:@selector(setLogDelegate:) withObject:self];

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

- (NSException *)exception {
	// TODO(gabe): What to do with exception in setUpClass/tearDownClass?
	return exception_;
}

- (void)run {		
	if (ignore_) {
		status_ = GHTestStatusIgnored;
		return;
	}
	
	status_ = GHTestStatusRunning;
	
	if ([testCase_ respondsToSelector:@selector(setUpClass)]) 
		[testCase_ performSelector:@selector(setUpClass)];
	
	for(id<GHTest> test in children_) {				
		currentTest_ = test;
		[[GHTesting sharedInstance] runTest:test selector:@selector(run) exception:&exception_ interval:nil];
		if (exception_) {
			NSLog(@"Exception: %@\n%@", [exception_ reason], GHU_GTMStackTraceFromException(exception_));
		}
		currentTest_ = nil;
	}
	
	if ([testCase_ respondsToSelector:@selector(tearDownClass)]) 
		[testCase_ performSelector:@selector(tearDownClass)];
	
	status_ = GHTestStatusFinished;
}

#pragma mark Delegates (GHTestDelegate)

// Notification from GHTestGroup; For example, would be called when a test case starts
- (void)testDidStart:(id<GHTest>)test {
	stats_.runCount += [test stats].runCount;
	[delegate_ testDidStart:test];	
}

// Notification from GHTestGroup; For example, would be called when a test case ends
- (void)testDidFinish:(id<GHTest>)test {
	interval_ += [test interval];
	if (exception_)
		stats_.failureCount += [test stats].runCount;	
	else
		stats_.failureCount += [test stats].failureCount;	

	[delegate_ testDidFinish:test];
}

- (void)testDidIgnore:(id<GHTest>)test {
	stats_.ignoreCount += [test stats].ignoreCount;
	[delegate_ testDidIgnore:test];
}

@end
