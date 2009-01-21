//
//  GHTestSuite.m
//  GHKit
//
//  Created by Gabriel Handford on 1/18/09.
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

#import "GHTestSuite.h"

#import "GTMDefines.h"
#import <objc/runtime.h>

@implementation GHTestSuite

@synthesize status=status_, name=name_, failedCount=failedCount_, totalCount=totalCount_, runCount=runCount_, 
delegate=delegate_, interval=interval_;

- (id)init {
	if ((self = [super init])) {		
		name_ = @"Tests"; //[[[NSBundle mainBundle] bundleIdentifier] retain];
	}
	return self;	
}

- (id)initWithTestCases:(NSArray *)testCases {
	if ([self init]) {
		testCases_ = [testCases retain];
	}
	return self;	
}

- (void)dealloc {
	[testCases_ release];
	[name_ release];
	[super dealloc];
}

- (NSString *)statusString {
	return [NSString stringWithFormat:@"%@ (%0.3fs)", [GHTest stringFromStatus:status_ withDefault:@""], interval_];
}	

+ (GHTestSuite *)allTestCases {
	GHTestSuite *testSuite = [[GHTestSuite alloc] init];	
	[testSuite loadTestCases];
	return testSuite;
}

- (BOOL)run {
	status_ = GHTestStatusRunning;
	NSDate *startDate = [NSDate date];
	BOOL passedAll = YES;
		
	// Load total count
	for(GHTestCase *testCase in testCases_) {
		totalCount_ = totalCount_ + testCase.totalCount;
	}
	
	for(GHTestCase *testCase in testCases_) {
		testCase.delegate = self;
		BOOL passed = [testCase run];
		failedCount_ = failedCount_ + testCase.failedCount;
		passedAll = (passedAll && passed);
		interval_ = [[NSDate date] timeIntervalSinceDate:startDate];
	}
	
	if (passedAll) status_ = GHTestStatusPassed;
	else status_ = GHTestStatusFailed;
	
	interval_ = [[NSDate date] timeIntervalSinceDate:startDate];
	
	return passedAll;
}

#pragma mark Delegate (GHTestCase)

- (void)testCaseDidStart:(GHTestCase *)testCase {
	[delegate_ testCaseDidStart:testCase];
}

- (void)testCase:(GHTestCase *)testCase didStartTest:(GHTest *)test {
	[delegate_ testCase:testCase didStartTest:test];
}

- (void)testCase:(GHTestCase *)testCase didFinishTest:(GHTest *)test passed:(BOOL)passed {
	runCount_++;
	[delegate_ testCase:testCase didFinishTest:test passed:passed];
}

- (void)testCaseDidFinish:(GHTestCase *)testCase {
	[delegate_ testCaseDidFinish:testCase];
}

// GTM_BEGIN

// Return YES if class is subclass (1 or more generations) of SenTestCase
+ (BOOL)isTestFixture:(Class)aClass {
  BOOL iscase = NO;
  Class testCaseClass = [GHTestCase class];
  Class superclass;
  for (superclass = aClass; 
       !iscase && superclass; 
       superclass = class_getSuperclass(superclass)) {
    iscase = superclass == testCaseClass ? YES : NO;
  }
  return iscase;
}

- (void)loadTestCases {
	NSMutableArray *testCases = [NSMutableArray array];
	
	int count = objc_getClassList(NULL, 0);
  NSMutableData *classData = [NSMutableData dataWithLength:sizeof(Class) * count];
  Class *classes = (Class*)[classData mutableBytes];
  _GTMDevAssert(classes, @"Couldn't allocate class list");
  objc_getClassList(classes, count);

  for (int i = 0; i < count; ++i) {
    Class currClass = classes[i];
    if ([GHTestSuite isTestFixture:currClass]) {			
      id testcase = [[currClass alloc] initWithTestSuite:self];
			
      _GTMDevAssert(testcase, @"Unable to instantiate Test Suite: '%@'\n",
                    NSStringFromClass(currClass));
			
			[testCases addObject:testcase];
      
      [testcase release];      
    }
  }
	[testCases_ release];
	testCases_ = [testCases retain];	
}	

// GTM_END

@end
