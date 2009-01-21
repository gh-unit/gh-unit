//
//  GHTest.h
//  GHKit
//
//  Created by Gabriel Handford on 1/17/09.
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

#import "GHTestCase.h"

@class GHTestCaseItem;
@class GHTestItem;

@interface GHTestViewModel : NSObject {
	GHTestSuite *testSuite_;
	
	NSMutableArray *testCaseItems_; // of GHTestCaseItem	
	NSMutableDictionary *testCaseMap_; // of (GHTestCase -> GHTestCaseItem)
	GHTestCaseItem *currentTestCaseItem_;	
}

@property (readonly) NSArray *testCaseItems;
@property (retain) GHTestCaseItem *currentTestCaseItem;
@property (readonly) GHTestStatus status;

- (id)initWithTestSuite:(GHTestSuite *)testSuite;

- (BOOL)isCurrentTestCase:(GHTestCase *)testCase;
- (void)addTestCaseItem:(GHTestCaseItem *)testCaseItem;

- (GHTestCaseItem *)findTestCaseItem:(GHTestCase *)testCase;
- (GHTestItem *)findTestItem:(GHTest *)test;

- (NSInteger)numberOfChildren;
- (id)objectAtIndex:(NSInteger)index;
- (NSString *)name;
- (NSString *)statusString;

@end

@interface GHTestCaseItem : NSObject {
	GHTestCase *testCase_;
	NSMutableArray *testItems_; // of GHTestItem
	NSMutableDictionary *testItemMap_; // of (Selector Name -> GHTestItem)
	
	NSString *name_;
}

@property (readonly, nonatomic) GHTestCase *testCase;
@property (readonly, nonatomic) NSArray *testItems; // of GHTestItem
@property (readonly) GHTestStatus status;

- (id)initWithTestCase:(GHTestCase *)testCase;
+ (id)testCaseItemWithTestCase:(GHTestCase *)testCase;

- (void)addTestItem:(GHTestItem *)test;
- (NSInteger)numberOfChildren;
- (id)objectAtIndex:(NSInteger)index;

- (NSString *)name;
- (NSString *)statusString;

- (GHTestItem *)findTestItem:(GHTest *)test;

@end

@interface GHTestItem : NSObject {
	GHTest *test_;
}

@property (readonly) GHTest *test;
@property (readonly) GHTestStatus status;

- (id)initWithTest:(GHTest *)test;
+ (id)testItemWithTest:(GHTest *)test;

- (NSInteger)numberOfChildren;
- (NSString *)name;
- (NSString *)statusString;

@end
