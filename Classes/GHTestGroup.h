//
//  GHTestGroup.h
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

#import "GHTest.h"
#import "GHTestCase.h"

@protocol GHTestGroup <GHTest>
- (id<GHTestGroup>)parent;
- (NSArray *)children;
@end

@interface GHTestGroup : NSObject <GHTestDelegate, GHTestGroup, GHTestCaseLogDelegate> {
	
	id<GHTestDelegate> delegate_; // weak
	id<GHTestGroup> parent_; // weak
	
	NSMutableArray *children_;
		
	NSString *name_;
	NSTimeInterval interval_;
	GHTestStatus status_;
	GHTestStats stats_;
	
	id<GHTest> currentTest_; // weak
}

@property (readonly, nonatomic) NSArray *children;
@property (assign, nonatomic) id<GHTestDelegate> delegate;
@property (assign, nonatomic) id<GHTestGroup> parent;

@property (readonly, nonatomic) NSString *identifier;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) GHTestStatus status;

@property (readonly, nonatomic) NSTimeInterval interval;
@property (readonly, nonatomic) GHTestStats stats;

/*!
 Create empty test group.
 @param name
 @param delegate
 */
- (id)initWithName:(NSString *)name delegate:(id<GHTestDelegate>)delegate;

/*!
 Create test group from test case.
 A test group is a collection of GHTest.
 
 @param testCase Should be a subclass of SenTestCase or GHTestCase
 @param delegate
 */
- (id)initWithTestCase:(id)testCase delegate:(id<GHTestDelegate>)delegate;

/*!
 Create test group from test case.
 A test case contains a set of test methods.
 @param testCase Should be a subclass of SenTestCase or GHTestCase
 @param delegate
 */
+ (GHTestGroup *)testGroupFromTestCase:(id)testCase delegate:(id<GHTestDelegate>)delegate;

/*!
 Add tests from the specified test case to group.
 You may want to use initWithTestCase or addTestCase instead.
 Generally a test group represents a set of a single test case's methods.
 @param testCase Should be a subclass of SenTestCase or GHTestCase
 */
- (void)addTestsFromTestCase:(id)testCase;

/*!
 Add a test case (test group) to this test group.
 @param testCase Should be a subclass of SenTestCase or GHTestCase
 */
- (void)addTestCase:(id)testCase;

/*!
 Add a test.
 @param test
 */
- (void)addTest:(id<GHTest>)test;

/*!
 Add a set of tests.
 @param tests
 */
- (void)addTests:(NSArray *)tests;

/*!
 Run test group.
 Will notify delegate as tests are run.
 */
- (void)run;

@end
