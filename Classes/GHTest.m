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

#import "GHTestUtils.h"

/*!
 GHTest represents a single test method. It is composed of a target and selector.
 A GHTestGroup is a collection of GHTests (or GHTestGroups).
 */
@implementation GHTest

@synthesize delegate=delegate_, target=target_, selector=selector_, name=name_, interval=interval_, 
exception=exception_, status=status_, failed=failed_, stats=stats_, log=log_;

- (id)initWithTarget:(id)target selector:(SEL)selector interval:(NSTimeInterval)interval exception:(NSException *)exception {
	if ((self = [super init])) {
		target_ = [target retain];
		selector_ = selector;
		name_ = [NSStringFromSelector(selector_) retain];
		interval_ = interval;
		exception_ = [exception retain];
		stats_ = GHTestStatsMake(0, 0, 1);
	}
	return self;	
}

+ (id)testWithTarget:(id)target selector:(SEL)selector {
	return [[[self alloc] initWithTarget:target selector:selector interval:-1 exception:nil] autorelease];
}

+ (id)testWithTarget:(id)target selector:(SEL)selector interval:(NSTimeInterval)interval exception:(NSException *)exception {
	return [[[self alloc] initWithTarget:target selector:selector interval:interval exception:exception] autorelease];
}

- (void)dealloc {
	[name_ release];
	[target_ release];
	[exception_ release];
	[log_ release];
	[super dealloc];
}

- (NSString *)identifier {
	return [NSString stringWithFormat:@"%@/%@", NSStringFromClass([target_ class]), NSStringFromSelector(selector_)];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@", self.identifier, [super description]];
}

- (void)setLogDelegate:(id<GHTestCaseLogDelegate>)delegate {
	if ([target_ respondsToSelector:@selector(setLogDelegate:)])
		[target_ setLogDelegate:delegate];
}

- (void)log:(NSString *)message {	
	@synchronized(self) {
		if (!log_) log_ = [[NSMutableArray array] retain];
		[log_ addObject:message];
	}
}

- (void)run {	
	status_ = GHTestStatusRunning;
	stats_ = GHTestStatsMake(1, 0, 1);
	[delegate_ testDidStart:self];

	failed_ = ![GHTestUtils runTest:target_ selector:selector_ exception:&exception_ interval:&interval_];				
	
	status_ = GHTestStatusFinished;	
	stats_ = GHTestStatsMake(1, failed_ ? 1 : 0, 1);
	[delegate_ testDidFinish:self];
}

@end
