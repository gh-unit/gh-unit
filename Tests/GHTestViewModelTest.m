//
//  GHTestViewModelTest.m
//  GHKit
//
//  Created by Gabriel Handford on 1/18/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestViewModelTest.h"

#import "GHTestViewModel.h"

@interface GHMockTestCase : GHTestCase { }
@end

@implementation GHMockTestCase
- (void)test1 { }
- (void)test2 { }
@end

@implementation GHTestViewModelTest

- (void)testModel {
	GHMockTestCase *mock = [[GHMockTestCase alloc] init];
	
	GHTestViewModel *model = [[GHTestViewModel alloc] init];
	GHTestCaseItem *testCaseItem = [[GHTestCaseItem alloc] initWithTestCase:mock];	
	[mock release];
	[model addTestCaseItem:testCaseItem];	
	GHAssertTrue([model numberOfChildren] == 1, nil);	
	
	GHAssertEqualObjects([model objectAtIndex:0], testCaseItem, nil);
	
	GHTestCaseItem *found = [model findTestCaseItem:mock];
	GHAssertNotNULL(found, nil);
	
	GHAssertEqualObjects(found, testCaseItem, nil);
}

@end
