//
//  GHTestCase.m
//
//  Created by Gabriel Handford on 1/16/09.
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

#import "GHTestCase.h"

#import "GTMStackTrace.h"
#import <objc/runtime.h>

// GTM_BEGIN
@interface GHTestCase (Private)
// our method of logging errors
+ (void)printException:(NSException *)exception fromTestName:(NSString *)name;
- (void)_loadTests:(BOOL)reload;
@end

// Used for sorting methods below
static int MethodSort(const void *a, const void *b) {
  const char *nameA = sel_getName(method_getName(*(Method*)a));
  const char *nameB = sel_getName(method_getName(*(Method*)b));
  return strcmp(nameA, nameB);
}

// GTM_END

@implementation GHTestCase

@synthesize testSuite=testSuite_, delegate=delegate_, failedCount=failedCount_, interval=interval_, status=status_;

- (id)init {
	if ((self = [super init])) {
		className_ = [NSStringFromClass([self class]) retain];
		failedCount_ = 0;
	}
	return self;	
}

- (id)initWithTestSuite:(GHTestSuite *)testSuite {
	if ([self init]) {
		testSuite_ = [testSuite retain];
		[self _loadTests:NO];
	}
	return self;
}

- (void)dealloc {
	[testSuite_ release];
	[tests_ release];
	[className_ release];
	[super dealloc];
}

- (NSString *)name {
	return className_;
}

- (NSInteger)totalCount {
	return [tests_ count];
}

- (NSString *)statusString {
	return [NSString stringWithFormat:@"%@ (%0.3fs)", [GHTest stringFromStatus:status_ withDefault:@""], interval_];
}

- (BOOL)run {	
	[self _loadTests:NO];
	
	status_ = GHTestStatusRunning;
	NSDate *startDate = [NSDate date];	
	if ([delegate_ respondsToSelector:@selector(testCaseDidStart:)]) 
		[delegate_ testCaseDidStart:self];
	
	BOOL passedAll = YES;
	
	for(GHTest *test in tests_) {
		if ([delegate_ respondsToSelector:@selector(testCase:didStartTest:)]) 
			[delegate_ testCase:self didStartTest:test];

		BOOL passed = [test run];
		if (!passed) {			
			failedCount_++;
			[self failWithException:test.exception];
		}
		
		passedAll = (passedAll && passed);
		interval_ = [[NSDate date] timeIntervalSinceDate:startDate];
		
		if ([delegate_ respondsToSelector:@selector(testCase:didFinishTest:passed:)]) 
			[delegate_ testCase:self didFinishTest:test passed:passed];
	}
	
	if (passedAll) status_ = GHTestStatusPassed;
	else status_ = GHTestStatusFailed;
		
	if ([delegate_ respondsToSelector:@selector(testCaseDidFinish:)]) 
		[delegate_ testCaseDidFinish:self];
	
	return passedAll;
}


- (NSUInteger)hash {
	return [className_ hash];
}

- (BOOL)isEqual:(id)obj {
	return ([obj isMemberOfClass:[self class]] && [[obj name] isEqual:[self name]]);
}

// GTM_BEGIN

- (void)_loadTests:(BOOL)reload {
	if (testsLoaded_ && !reload) return;
	
	NSMutableArray *tests = [NSMutableArray array];
	
	unsigned int methodCount;
	Method *methods = class_copyMethodList([self class], &methodCount);
	if (!methods) {
		return;
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
			
			GHTest *test = [GHTest testWithTestCase:self selector:sel];
			[tests addObject:test];
		}
	}
	
	[tests_ release];
	tests_ = [tests retain];
	testsLoaded_ = YES;
}

- (void)failWithException:(NSException*)exception {
  //[exception raise];
}

- (void)setUp {
}

+ (void)printException:(NSException *)exception fromTestName:(NSString *)name {
	
	NSDictionary *userInfo = [exception userInfo];
  NSString *filename = [userInfo objectForKey:GHTestFilenameKey];
  NSNumber *lineNumber = [userInfo objectForKey:GHTestLineNumberKey];
  if ([filename length] == 0) {
    filename = @"Unknown.m";
  }
	
	NSString *className = NSStringFromClass([self class]);
	NSString *exceptionInfo = [NSString stringWithFormat:@"%@:%d: error: -[%@ %@] %@\n", 
														 filename,
														 [lineNumber integerValue],
														 className, 
														 name,
														 [exception reason]];
	
	NSString *exceptionTrace = [NSString stringWithFormat:@"%@\n%@\n", 
															exceptionInfo, 
															GTMStackTraceFromException(exception)];
	
  fprintf(stderr, [exceptionInfo UTF8String]);
  fflush(stderr);
	NSLog(exceptionTrace);
}

- (void)tearDown {
}

@end
// GTM_END
