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
//  Created by Gabriel Handford on 1/19/09.
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

#import <objc/runtime.h>

// GTM_BEGIN

// Used for sorting methods below
static int MethodSort(const void *a, const void *b) {
  const char *nameA = sel_getName(method_getName(*(Method*)a));
  const char *nameB = sel_getName(method_getName(*(Method*)b));
  return strcmp(nameA, nameB);
}

// GTM_END

@implementation GHTest

@synthesize delegate=delegate_, target=target_, selector=selector_, name=name_, interval=interval_, exception=exception_, status=status_, failed=failed_, stats=stats_;

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
	[backTrace_ release];
	[super dealloc];
}

- (NSString *)identifier {
	return [NSString stringWithFormat:@"%@/%@", NSStringFromClass([target_ class]), NSStringFromSelector(selector_)];
}

// GTM_BEGIN

+ (NSArray *)loadTestsFromTarget:(id)target {
	NSMutableArray *tests = [NSMutableArray array];
	
	unsigned int methodCount;
	Method *methods = class_copyMethodList([target class], &methodCount);
	if (!methods) {
		return nil;
	}
	// This handles disposing of methods for us even if an
	// exception should fly. 
	[NSData dataWithBytesNoCopy:methods
											 length:sizeof(Method) * methodCount];
	// Sort our methods so they are called in Alphabetical order just
	// because we can.
	qsort(methods, methodCount, sizeof(Method), MethodSort);
	for (size_t j = 0; j < methodCount; ++j) {
		Method currMethod = methods[j];
		SEL sel = method_getName(currMethod);
		char *returnType = NULL;
		const char *name = sel_getName(sel);
		// If it starts with test, takes 2 args (target and sel) and returns
		// void run it.
		if (strstr(name, "test") == name) {
			returnType = method_copyReturnType(currMethod);
			if (returnType) {
				// This handles disposing of returnType for us even if an
				// exception should fly. Length +1 for the terminator, not that
				// the length really matters here, as we never reference inside
				// the data block.
				[NSData dataWithBytesNoCopy:returnType
														 length:strlen(returnType) + 1];
			}
		}
		if (returnType  // True if name starts with "test"
				&& strcmp(returnType, @encode(void)) == 0
				&& method_getNumberOfArguments(currMethod) == 2) {
			
			GHTest *test = [GHTest testWithTarget:target selector:sel];
			[tests addObject:test];
		}
	}
	
	return tests;
}

// GTM_END

- (NSString *)backTrace {
	if (!backTrace_ && exception_)
		backTrace_ = [GTMStackTraceFromException(exception_) retain];
	return backTrace_;
}

- (void)run {
	[delegate_ testWillStart:self];
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
			if ([target_ respondsToSelector:@selector(setUp)])
				[target_ performSelector:@selector(setUp)];
      @try {	
        [target_ performSelector:selector_];
      } @catch (NSException *exception) {
        exception_ = [exception retain];
      }
			if ([target_ respondsToSelector:@selector(tearDown)])
				[target_ performSelector:@selector(tearDown)];
    } @catch (NSException *exception) {
      exception_ = [exception retain];
    }
    [pool release];
  } @catch (NSException *exception) {
    exception_ = [exception retain];
  }
// GTM_END	
	interval_ = [[NSDate date] timeIntervalSinceDate:startDate];
	status_ = GHTestStatusFinished;	
	failed_ = (!!exception_);
	stats_ = GHTestStatsMake(1, failed_ ? 1 : 0, 1);
	[delegate_ testDidFinish:self];
}

@end
