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
//

#import "GHTest.h"

#import "GTMStackTrace.h"

@implementation GHTest

@synthesize testCase=testCase_, selector=selector_, interval=interval_, exception=exception_, status=status_;

- (id)initWithTestCase:(GHTestCase *)testCase selector:(SEL)selector interval:(NSTimeInterval)interval exception:(NSException *)exception {
	if ((self = [super init])) {
		testCase_ = [testCase retain];
		selector_ = selector;
		interval_ = interval;
		exception_ = [exception retain];
		
		selectorName_ = [NSStringFromSelector(selector_) retain];
	}
	return self;	
}

+ (id)testWithTestCase:(GHTestCase *)testCase selector:(SEL)selector {
	return [[[self alloc] initWithTestCase:testCase selector:selector interval:-1 exception:nil] autorelease];
}


+ (id)testWithTestCase:(GHTestCase *)testCase selector:(SEL)selector interval:(NSTimeInterval)interval exception:(NSException *)exception {
	return [[[self alloc] initWithTestCase:testCase selector:selector interval:interval exception:exception] autorelease];
}

- (void)dealloc {
	[testCase_ release];
	[exception_ release];
	[backTrace_ release];
	[selectorName_ release];
	[super dealloc];
}

- (NSUInteger)hash {
	return [selectorName_ hash];
}

- (BOOL)isEqual:(id)obj {
	return ([obj isMemberOfClass:[self class]] && [[obj name] isEqual:[self name]]);
}

- (NSString *)name {
	return selectorName_;
}

+ (NSString *)stringFromStatus:(GHTestStatus)status withDefault:(NSString *)defaultValue {
	switch(status) {
		case GHTestStatusRunning: return @"Running";
		case GHTestStatusPassed: return @"Passed";
		case GHTestStatusFailed: return @"Failed";
	}			
	return defaultValue;
}	

- (BOOL)failed {
	return (status_ == GHTestStatusFailed);
}

- (NSString *)backTrace {
	if (!backTrace_ && exception_)
		backTrace_ = [GTMStackTraceFromException(exception_) retain];
	return backTrace_;
}

- (NSString *)statusString {
	return [NSString stringWithFormat:@"%@ (%0.3fs)", [GHTest stringFromStatus:status_ withDefault:@""], interval_];
}

- (BOOL)run {
	status_ = GHTestStatusRunning;
// GTM_BEGIN
	NSDate *startDate = [NSDate date];
  @try {
    // Wrap things in autorelease pools because they may
    // have an STMacro in their dealloc which may get called
    // when the pool is cleaned up
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // We don't log exceptions here, instead we let the person that called
    // this log the exception.  This ensures they are only logged once but the
    // outer layers get the exceptions to report counts, etc.
    @try {
      [testCase_ performSelector:@selector(setUp)];
      @try {				
        [testCase_ performSelector:selector_];
      } @catch (NSException *exception) {
        exception_ = [exception retain];
      }
      [testCase_ performSelector:@selector(tearDown)];
    } @catch (NSException *exception) {
      exception_ = [exception retain];
    }
    [pool release];
  } @catch (NSException *exception) {
    exception_ = [exception retain];
  }
// GTM_END	
	interval_ = [[NSDate date] timeIntervalSinceDate:startDate];
	
	BOOL passed = (!exception_);
	status_ = passed ? GHTestStatusPassed : GHTestStatusFailed;
	return passed;
}

@end
