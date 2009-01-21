//
//  GHTestViewModel.m
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

#import "GHTestViewModel.h"

@implementation GHTestViewModel

@synthesize testCaseItems=testCaseItems_, currentTestCaseItem=currentTestCaseItem_;

- (id)initWithTestSuite:(GHTestSuite *)testSuite {
	if ((self = [super init])) {
		testSuite_ = [testSuite retain];
		testCaseItems_ = [[NSMutableArray array] retain];
		testCaseMap_ = [[NSMutableDictionary dictionary] retain];
	}
	return self;
}

- (void)dealloc {
	[testSuite_ release];
	[testCaseMap_ release];
	[testCaseItems_ release];
	[currentTestCaseItem_ release];
	[super dealloc];
}

- (void)addTestCaseItem:(GHTestCaseItem *)testCaseItem {
	self.currentTestCaseItem = testCaseItem;
	[testCaseMap_ setObject:testCaseItem forKey:testCaseItem.testCase.name];
	[testCaseItems_ addObject:testCaseItem];
	GTMLoggerDebug(@"Done");
}

- (BOOL)isCurrentTestCase:(GHTestCase *)testCase {
	return (currentTestCaseItem_ && currentTestCaseItem_.testCase == testCase);
}

- (GHTestCaseItem *)findTestCaseItem:(GHTestCase *)testCase {
	return [testCaseMap_ objectForKey:testCase.name];
}

- (GHTestItem *)findTestItem:(GHTest *)test {
	GHTestCaseItem *testCaseItem = [self findTestCaseItem:test.testCase];
	return [testCaseItem findTestItem:test];
}

- (NSInteger)numberOfChildren {
	return [testCaseItems_ count];
}

- (id)objectAtIndex:(NSInteger)index {
	return [testCaseItems_ objectAtIndex:index];
}

- (NSString *)name {
	return [testSuite_ name];
}

- (NSString *)statusString {
	return [testSuite_ statusString];
}

- (GHTestStatus)status {
	return [testSuite_ status];
}

@end

@implementation GHTestCaseItem

@synthesize testCase=testCase_, testItems=testItems_;

- (id)initWithTestCase:(GHTestCase *)testCase {
	if ((self = [super init])) {
		testCase_ = [testCase retain];
		testItems_ = [[NSMutableArray array] retain];
		testItemMap_ = [[NSMutableDictionary dictionary] retain];
		
		name_ = [NSStringFromClass([testCase_ class]) retain];
	}
	return self;
}

+ (id)testCaseItemWithTestCase:(GHTestCase *)testCase {
	return [[[self alloc] initWithTestCase:testCase] autorelease];
}

- (void)dealloc {
	[testCase_ release];
	[name_ release];
	[testItems_ release];
	[testItemMap_ release];
	[super dealloc];
}

- (NSString *)description {
	return GHDescription(self, @"testCase", @"testItems");
}

- (void)addTestItem:(GHTestItem *)testItem {
	[testItemMap_ setObject:testItem forKey:testItem.test.name];
	[testItems_ addObject:testItem];
}

- (NSInteger)numberOfChildren {
	return [testItems_ count];
}

- (id)objectAtIndex:(NSInteger)index {
	return [testItems_ objectAtIndex:index];
}

- (NSString *)name {
	return name_;
}

- (NSString *)statusString {
	return [testCase_ statusString];
}

- (GHTestStatus)status {
	return [testCase_ status];
}

- (GHTestItem *)findTestItem:(GHTest *)test {
	return [testItemMap_ objectForKey:test.name];
}

@end

@implementation GHTestItem

@synthesize test=test_;

- (id)initWithTest:(GHTest *)test {
	if ((self = [super init])) {
		test_ = [test retain];
	}
	return self;
}

- (void)dealloc {
	[test_ release];
	[super dealloc];
}

+ (id)testItemWithTest:(GHTest *)test {
	return [[[self alloc] initWithTest:test] autorelease];
}

- (NSString *)description {
	return GHDescription(self, @"name", @"statusString");
}

- (NSString *)name {
	return test_.name;
}

- (NSString *)statusString {
	return test_.statusString;
}

- (GHTestStatus)status {
	return [test_ status];
}

- (NSInteger)numberOfChildren {
	return 0;
}

@end


