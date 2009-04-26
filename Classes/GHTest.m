//
//  GHTest.m
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

#import "GHTest.h"

#import "GHTesting.h"

NSString* NSStringFromGHTestStatus(GHTestStatus status) {
	switch(status) {
		case GHTestStatusNone: return NSLocalizedString(@"Waiting", @"Test status / Waiting");
		case GHTestStatusRunning: return NSLocalizedString(@"Running", @"Test status / Running");
		case GHTestStatusFinished: return NSLocalizedString(@"Finished", @"Test status / Finished");
		case GHTestStatusIgnored: return NSLocalizedString(@"Ignored", @"Test status / Ignored");
		default: return NSLocalizedString(@"Unknown", @"Test status / Unknown");
	}
}

GHTestStats GHTestStatsMake(NSInteger runCount, NSInteger failureCount, NSInteger ignoreCount, NSInteger testCount) {
	GHTestStats stats;
	stats.runCount = runCount;
	stats.failureCount = failureCount; 
	stats.ignoreCount = ignoreCount;
	stats.testCount = testCount;
	return stats;
}

@implementation GHTest

@synthesize delegate=delegate_, target=target_, selector=selector_, name=name_, interval=interval_, 
exception=exception_, status=status_, failed=failed_, stats=stats_, log=log_, identifier=identifier_, ignore=ignore_;

- (id)initWithTarget:(id)target selector:(SEL)selector {
	if ((self = [super init])) {
		target_ = [target retain];
		selector_ = selector;
		interval_ = -1;
		name_ = [NSStringFromSelector(selector_) copy];
		stats_ = GHTestStatsMake(0, 0, 0, 1);
		identifier_ = [[NSString stringWithFormat:@"%@/%@", NSStringFromClass([target_ class]), NSStringFromSelector(selector_)] copy];
	}
	return self;	
}

+ (id)testWithTarget:(id)target selector:(SEL)selector {
	return [[[self alloc] initWithTarget:target selector:selector] autorelease];
}

- (void)dealloc {
	[name_ release];
	[target_ release];
	[exception_ release];
	[log_ release];
	[identifier_ release];
	[super dealloc];
}

- (BOOL)isEqual:(id)test {
	return ((test == self) || 
					([test conformsToProtocol:@protocol(GHTest)] && 
					 [self.identifier isEqual:[test identifier]]));
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@", self.identifier, [super description]];
}

- (void)setLoggingEnabled:(BOOL)enabled {
	if ([target_ respondsToSelector:@selector(setLogDelegate:)])
		[target_ performSelector:@selector(setLogDelegate:) withObject:(enabled ? self : NULL)];
}	

- (void)run {	

	if (ignore_) {
		status_ = GHTestStatusIgnored;
		stats_ = GHTestStatsMake(0, 0, 1, 1);
		[delegate_ testDidIgnore:self];
	}	else {
		status_ = GHTestStatusRunning;
		stats_ = GHTestStatsMake(1, 0, 0, 1);
		[delegate_ testDidStart:self];
		[self setLoggingEnabled:YES];

		failed_ = ![[GHTesting sharedInstance] runTest:target_ selector:selector_ exception:&exception_ interval:&interval_];
	
		[self setLoggingEnabled:NO];
	
		status_ = GHTestStatusFinished;	
		stats_ = GHTestStatsMake(1, failed_ ? 1 : 0, 0, 1);
		[delegate_ testDidFinish:self];
	}		
}

- (void)testCase:(id)testCase didLog:(NSString *)message {
	if (!log_) log_ = [[NSMutableArray array] retain];
	[log_ addObject:message];
	[delegate_ test:self didLog:message];
}

@end
