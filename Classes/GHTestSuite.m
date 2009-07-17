//
//  GHTestSuite.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/25/09.
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

#import "GHTestSuite.h"

#import "GHTesting.h"

NSString *GHUnitTest = NULL;

@implementation GHTestSuite

- (id)initWithName:(NSString *)name testCases:(NSArray *)testCases operationQueue:(NSOperationQueue *)operationQueue delegate:(id<GHTestDelegate>)delegate {
	if ((self = [super initWithName:name operationQueue:nil delegate:delegate])) {
		for(id testCase in testCases) {
			[self addTestCase:testCase operationQueue:operationQueue];
		}
	}
	return self;
}

+ (GHTestSuite *)allTests:(NSOperationQueue *)operationQueue {
	NSArray *testCases = [[GHTesting sharedInstance] loadAllTestCases];
	GHTestSuite *allTests = [[self alloc] initWithName:@"Tests" operationQueue:operationQueue delegate:nil];	
	for(id testCase in testCases) {
		[allTests addTestCase:testCase operationQueue:operationQueue];
	}
	return [allTests autorelease];
}

+ (GHTestSuite *)suiteWithTestCaseClass:(Class)testCaseClass method:(SEL)method operationQueue:(NSOperationQueue *)operationQueue {	
	NSString *name = [NSString stringWithFormat:@"%@/%@", NSStringFromClass(testCaseClass), NSStringFromSelector(method)];
	GHTestSuite *testSuite = [[GHTestSuite alloc] initWithName:name operationQueue:operationQueue delegate:nil];
	id testCase = [[[testCaseClass alloc] init] autorelease];
	if (!testCase) {
		NSLog(@"Couldn't instantiate test: %@", NSStringFromClass(testCaseClass));
		return nil;
	}
	GHTestGroup *group = [[GHTestGroup alloc] initWithTestCase:testCase selector:method operationQueue:operationQueue delegate:nil];
	[testSuite addTestGroup:group];
	return [testSuite autorelease];	
}

+ (GHTestSuite *)suiteWithTestFilter:(NSString *)testFilterString operationQueue:(NSOperationQueue *)operationQueue {
	NSArray *testFilters = [testFilterString componentsSeparatedByString:@","];
	GHTestSuite *testSuite = [[GHTestSuite alloc] initWithName:testFilterString operationQueue:operationQueue delegate:nil];

	for(NSString *testFilter in testFilters) {
		NSArray *components = [testFilter componentsSeparatedByString:@"/"];
		if ([components count] == 2) {		
			NSString *testCaseClassName = [components objectAtIndex:0];
			Class testCaseClass = NSClassFromString(testCaseClassName);
			id testCase = [[[testCaseClass alloc] init] autorelease];
			if (!testCase) {
				NSLog(@"Couldn't find test: %@", testCaseClassName);
				continue;
			}
			NSString *methodName = [components objectAtIndex:1];
			GHTestGroup *group = [[GHTestGroup alloc] initWithTestCase:testCase selector:NSSelectorFromString(methodName) 
																									operationQueue:operationQueue delegate:nil];
			[testSuite addTestGroup:group];
			[group release];
		} else {
			Class testCaseClass = NSClassFromString(testFilter);
			id testCase = [[[testCaseClass alloc] init] autorelease];
			if (!testCase) {
				NSLog(@"Couldn't find test: %@", testFilter);
				continue;
			}		
			[testSuite addTestCase:testCase operationQueue:operationQueue];
		}
	}
	
	return [testSuite autorelease];
}

+ (GHTestSuite *)suiteFromEnv:(NSOperationQueue *)operationQueue {
	const char* cTestFilter = getenv("TEST");
	if (cTestFilter) {
		NSString *testFilter = [NSString stringWithUTF8String:cTestFilter];
		return [GHTestSuite suiteWithTestFilter:testFilter operationQueue:operationQueue];
	} else {	
		if (GHUnitTest != NULL) return [GHTestSuite suiteWithTestFilter:GHUnitTest operationQueue:operationQueue];
		return [GHTestSuite allTests:operationQueue];
	}
}

@end
