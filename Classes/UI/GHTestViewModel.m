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

//#import "GHUnit.h"
#import "GHTestViewModel.h"

@implementation GHTestViewModel

@synthesize root=root_;

- (id)initWithRoot:(id<GHTestGroup>)root {
	if ((self = [super init])) {
		root_ = [[GHTestNode alloc] initWithTest:root children:[root children] source:self];
		map_ = [[NSMutableDictionary dictionary] retain];
	}
	return self;
}

- (void)dealloc {
	[root_ release];
	[map_ release];
	[super dealloc];
}

- (NSString *)name {
	return [root_ name];
}

- (NSString *)statusString {
	return [root_ statusString];
}

- (void)registerNode:(GHTestNode *)node {
	[map_ setObject:node forKey:node.identifier];
}

- (GHTestNode *)findTestNode:(id<GHTest>)test {
	return [map_ objectForKey:[test identifier]];
}

@end

@implementation GHTestNode

@synthesize test=test_, identifier=identifier_, name=name_, children=children_;

- (id)initWithTest:(id<GHTest>)test children:(NSArray *)children source:(GHTestViewModel *)source {
	if ((self = [super init])) {
		test_ = [test retain];
		
		NSMutableArray *nodeChildren = [NSMutableArray array];
		for(id<GHTest> test in children) {	
			
			GHTestNode *node = nil;
			if ([test conformsToProtocol:@protocol(GHTestGroup)]) {
				NSArray *testChildren = [(id<GHTestGroup>)test children];
				if ([testChildren count] > 0) 
					node = [GHTestNode nodeWithTest:test children:testChildren source:source];
			} else {
				node = [GHTestNode nodeWithTest:test children:nil source:source];
			}			
			if (node)
				[nodeChildren addObject:node];
		}
		children_ = [nodeChildren retain];
		[source registerNode:self];
	}
	return self;
}

- (void)dealloc {
	[test_ release];
	[super dealloc];
}

+ (GHTestNode *)nodeWithTest:(id<GHTest>)test children:(NSArray *)children source:(GHTestViewModel *)source {
	return [[[GHTestNode alloc] initWithTest:test children:children source:source] autorelease];
}

- (NSString *)name {
	return [test_ name];
}

- (NSString *)identifier {
	return [test_ identifier];
}

- (NSString *)statusString {
	return [NSString stringWithFormat:@"%d %@", [test_ status], NSStringFromGHTestStats([test_ stats])];
}

- (BOOL)failed {
	return ([test_ stats].failureCount > 0);
}

- (GHTestStatus)status {
	return [test_ status];
}

- (NSString *)detail {
	return [test_ backTrace];
}

@end
