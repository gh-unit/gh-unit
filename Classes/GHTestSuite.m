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

@implementation GHTestSuite

- (id)initWithName:(NSString *)name testCases:(NSArray *)testCases delegate:(id<GHTestDelegate>)delegate {
	if ((self = [super initWithName:name delegate:delegate])) {
		for(id testCase in testCases) {
			[self addTestCase:testCase];
		}
	}
	return self;
}

- (id)initWithName:(NSString *)name tests:(NSArray/* of id<GHTest>*/ *)tests delegate:(id<GHTestDelegate>)delegate {
	if ((self = [super initWithName:name delegate:delegate])) {
		[self addTests:tests];
	}
	return self;
}

+ (GHTestSuite *)allTests {
	return [self allTests:NO];
}

+ (GHTestSuite *)allTests:(BOOL)flatten {
	NSArray *testCases = [[GHTesting sharedInstance] loadAllTestCases];
	GHTestSuite *allTests = [[self alloc] initWithName:@"Tests" delegate:nil];	
	for(id testCase in testCases) {
		if (flatten) {
			[allTests addTestsFromTestCase:testCase];
		} else {
			[allTests addTestCase:testCase];
		}
	}
	return [allTests autorelease];
}

+ (GHTestSuite *)suiteWithTestFilter:(NSString *)testFilter {
	NSArray *tests = nil;
	NSArray *components = [testFilter componentsSeparatedByString:@"/"];
	if ([components count] == 2) {		
		NSString *testCaseClassName = [components objectAtIndex:0];
		Class testCaseClass = NSClassFromString(testCaseClassName);
		id testCase = [[[testCaseClass alloc] init] autorelease];
		NSString *methodName = [components objectAtIndex:1];
		GHTest *test = [GHTest testWithTarget:testCase selector:NSSelectorFromString(methodName)];
		tests = [NSArray arrayWithObject:test];
	} else {
		Class testCaseClass = NSClassFromString(testFilter);
		id testCase = [[[testCaseClass alloc] init] autorelease];
		tests = [[GHTesting sharedInstance] loadTestsFromTarget:testCase];
	}
	
	return [[[GHTestSuite alloc] initWithName:testFilter tests:tests delegate:nil] autorelease];
}

@end
