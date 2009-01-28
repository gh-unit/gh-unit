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

#import <objc/runtime.h>

@implementation GHTestGroup

@synthesize stats=stats_, parent=parent_, children=children_, delegate=delegate_, interval=interval_, status=status_;

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
		[self addTestsFromTestCase:testCase];
	}
	return self;
}

+ (GHTestGroup *)testGroupFromTestCase:(id)testCase delegate:(id<GHTestDelegate>)delegate {
	return [[[GHTestGroup alloc] initWithTestCase:testCase delegate:delegate] autorelease];
}

- (void)dealloc {
	[name_ release];
	[children_ release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@, %d %0.3f %d/%d (%d failures)", 
								 name_, status_, interval_, stats_.runCount, stats_.testCount, stats_.failureCount];
}
	
- (NSString *)name {
	return name_;
}

- (void)addTestsFromTestCase:(id)testCase {
	NSArray *tests = [GHTest loadTestsFromTarget:testCase];
	for(GHTest *test in tests) {
		[test setDelegate:self];
		[self addTest:test];
	}
}

- (void)addTestCase:(id)testCase {
	GHTestGroup *testCaseGroup = [[GHTestGroup alloc] initWithTestCase:testCase delegate:self];
	[self addTest:testCaseGroup];
	[testCaseGroup setParent:self];
	[testCaseGroup release];
}

- (void)addTests:(NSArray *)tests {
	for(id test in tests) {
		if (![test conformsToProtocol:@protocol(GHTest)]) 
			[NSException raise:NSInvalidArgumentException format:@"Tests must conform to GHTest protocol"];
		[self addTest:(id<GHTest>)test];
	}
}

- (void)addTest:(id<GHTest>)test {
	stats_.testCount += [test stats].testCount;
	
	// TODO(gabe): This logging stuff seems a little convoluted
	if ([test respondsToSelector:@selector(setLogDelegate:)])
		[(id)test setLogDelegate:self];

	[children_ addObject:test];
}

- (NSString *)identifier {
	return name_;
}

// Send log messages to current test
- (void)testCase:(id)testCase didLog:(NSString *)message {
	[self log:message];
}

- (NSArray *)log {
	// Not supported for group
	return nil;
}

- (void)log:(NSString *)message {
	[currentTest_ log:message];
}

- (NSException *)exception {
	// Not supported for group
	return nil;
}

- (void)run {		
	status_ = GHTestStatusRunning;
	
	for(id<GHTest> test in children_) {				
		currentTest_ = test;
		[test run];			
		currentTest_ = nil;
	}
	
	status_ = GHTestStatusFinished;
}

#pragma mark Parent Notifications

- (void)testDidStart:(id<GHTest>)test {
	stats_.runCount += [test stats].runCount;
	[delegate_ testDidStart:test];
}

- (void)testDidFinish:(id<GHTest>)test {
	interval_ += [test interval];
	//stats_.runCount += [test stats].runCount;
	stats_.failureCount += [test stats].failureCount;
	[delegate_ testDidFinish:test];
}

@end

@implementation GHTestGroup (GHTestLoading)

+ (BOOL)isSenTestCaseClass:(Class)aClass {
	Class senTestCaseClass = NSClassFromString(@"SenTestCase");
	return [self isTestFixture:aClass testCaseClass:senTestCaseClass];
}

// GTM_BEGIN

// Return YES if class is subclass (1 or more generations) of GHTestCase
+ (BOOL)isTestFixture:(Class)aClass {
	return [self isTestFixture:aClass testCaseClass:[GHTestCase class]];
}

+ (BOOL)isTestFixture:(Class)aClass testCaseClass:(Class)testCaseClass {	
	if (testCaseClass == NULL) return NO;
  BOOL iscase = NO;
  Class superclass;
  for (superclass = aClass; 
       !iscase && superclass; 
       superclass = class_getSuperclass(superclass)) {
    iscase = superclass == testCaseClass ? YES : NO;
  }
  return iscase;
}

+ (NSArray *)loadTestCases {
	NSMutableArray *testCases = [NSMutableArray array];
	
	int count = objc_getClassList(NULL, 0);
  NSMutableData *classData = [NSMutableData dataWithLength:sizeof(Class) * count];
  Class *classes = (Class*)[classData mutableBytes];
  //_GTMDevAssert(classes, @"Couldn't allocate class list");
  objc_getClassList(classes, count);
	
  for (int i = 0; i < count; ++i) {
    Class currClass = classes[i];
		id testcase = nil;
		
    if ([self isTestFixture:currClass]) {			
			testcase = [[currClass alloc] init];
		} else if ([self isSenTestCaseClass:currClass]) {
			testcase = [[currClass alloc] init];
		} else {
			continue;
		}
		
		[testCases addObject:testcase];
		[testcase release];
  }
	return testCases;
	// GTM_END
}

@end
