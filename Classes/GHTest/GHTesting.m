//
//  GHTesting.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/30/09.
//  Copyright 2008 Gabriel Handford
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

//! @cond DEV

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

#import "GHTesting.h"
#import "GHTest.h"
#import "GHTestCase.h"
#import "GTMStackTrace.h"

#import <objc/runtime.h>

NSString *GHUStackTraceFromException(NSException *e) {
  return GHU_GTMStackTraceFromException(e);
}

NSInteger ClassSort(id a, id b, void *context) {
  const char *nameA = class_getName([a class]);
  const char *nameB = class_getName([b class]);
  return strcmp(nameA, nameB);
}

// GTM_BEGIN
// Used for sorting methods below
static int MethodSort(const void *a, const void *b) {
  const char *nameA = sel_getName(method_getName(*(Method*)a));
  const char *nameB = sel_getName(method_getName(*(Method*)b));
  return strcmp(nameA, nameB);
}

BOOL isTestFixtureOfClass(Class aClass, Class testCaseClass) {
  if (testCaseClass == NULL) return NO;
  BOOL iscase = NO;
  Class superclass;
  for (superclass = aClass; 
       !iscase && superclass; 
       superclass = class_getSuperclass(superclass)) {
    iscase = superclass == testCaseClass ? YES : NO;
  }
  return iscase;
}
// GTM_END

@implementation GHTesting

static GHTesting *gSharedInstance;

+ (GHTesting *)sharedInstance {
  @synchronized(self) {   
    if (!gSharedInstance) gSharedInstance = [[GHTesting alloc] init];   
  }
  return gSharedInstance;
}

- (id)init {
  if ((self = [super init])) {
    // Default test cases
    testCaseClassNames_ = [[NSMutableArray arrayWithObjects:
                            @"GHTestCase",
                            @"SenTestCase",
                            @"GTMTestCase", 
                            nil] retain];
  }
  return self;
}

- (BOOL)isTestCaseClass:(Class)aClass {
  for(NSString *className in testCaseClassNames_) {
    if (isTestFixtureOfClass(aClass, NSClassFromString(className))) return YES;
  }
  return NO;
}

- (void)registerClass:(Class)aClass {
  [self registerClassName:NSStringFromClass(aClass)];
}

- (void)registerClassName:(NSString *)className {
  [testCaseClassNames_ addObject:className];
}

+ (NSString *)descriptionForException:(NSException *)exception {
  NSNumber *lineNumber = [[exception userInfo] objectForKey:GHTestLineNumberKey];
  NSString *lineDescription = (lineNumber ? [lineNumber description] : @"Unknown");
  NSString *filename = [[[[exception userInfo] objectForKey:GHTestFilenameKey] stringByStandardizingPath] stringByAbbreviatingWithTildeInPath];
  NSString *filenameDescription = (filename ? filename : @"Unknown");
  
  return [NSString stringWithFormat:@"\n\tName: %@\n\tFile: %@\n\tLine: %@\n\tReason: %@\n\n%@", 
          [exception name],
          filenameDescription, 
          lineDescription, 
          [exception reason], 
          GHU_GTMStackTraceFromException(exception)];
}  

+ (NSString *)exceptionFilenameForTest:(id<GHTest>)test {
  return [[[[[test exception] userInfo] objectForKey:GHTestFilenameKey] stringByStandardizingPath] stringByAbbreviatingWithTildeInPath];
}

+ (NSInteger)exceptionLineNumberForTest:(id<GHTest>)test {
  return [[[[test exception] userInfo] objectForKey:GHTestLineNumberKey] integerValue];
}


- (NSArray *)loadAllTestCases {
  NSMutableArray *testCases = [NSMutableArray array];

  int count = objc_getClassList(NULL, 0);
  NSMutableData *classData = [NSMutableData dataWithLength:sizeof(Class) * count];
  Class *classes = (Class*)[classData mutableBytes];
  NSAssert(classes, @"Couldn't allocate class list");
  objc_getClassList(classes, count);
  
  for (int i = 0; i < count; ++i) {
    Class currClass = classes[i];
    id testcase = nil;
    
    if ([self isTestCaseClass:currClass]) {
      testcase = [[currClass alloc] init];
    } else {
      continue;
    }
    
    [testCases addObject:testcase];
    [testcase release];
  }
  
  return [testCases sortedArrayUsingFunction:ClassSort context:NULL];
}

// GTM_BEGIN

- (NSArray *)loadTestsFromTarget:(id)target {
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

+ (BOOL)runTestWithTarget:(id)target selector:(SEL)selector exception:(NSException **)exception interval:(NSTimeInterval *)interval
 reraiseExceptions:(BOOL)reraiseExceptions {

  // If re-raising, run runTestOrRaise
  if (reraiseExceptions) return [self runTestOrRaiseWithTarget:target selector:selector exception:exception interval:interval];
  
  NSDate *startDate = [NSDate date];  
  NSException *testException = nil;

  @try {
    // Wrap things in autorelease pools because they may
    // have an STMacro in their dealloc which may get called
    // when the pool is cleaned up
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // We don't log exceptions here, instead we let the person that called
    // this log the exception.  This ensures they are only logged once but the
    // outer layers get the exceptions to report counts, etc.
    @try {
      // Private setUp internal to GHUnit (in case subclasses fail to call super)
      if ([target respondsToSelector:@selector(_setUp)])
        [target performSelector:@selector(_setUp)];

      if ([target respondsToSelector:@selector(setUp)])
        [target performSelector:@selector(setUp)];
      @try {  
        if ([target respondsToSelector:@selector(setCurrentSelector:)])
          [target setCurrentSelector:selector];

        // If this isn't set SenTest macros don't raise
        if ([target respondsToSelector:@selector(raiseAfterFailure)])
          [target raiseAfterFailure];
        
        // Runs the test
        [target performSelector:selector];
        
      } @catch (NSException *exception) {
        if (!testException) testException = [exception retain];
      }
      if ([target respondsToSelector:@selector(setCurrentSelector:)])
        [target setCurrentSelector:NULL];

      if ([target respondsToSelector:@selector(tearDown)])
        [target performSelector:@selector(tearDown)];
      
      // Private tearDown internal to GHUnit (in case subclasses fail to call super)
      if ([target respondsToSelector:@selector(_tearDown)])
        [target performSelector:@selector(_tearDown)];

    } @catch (NSException *exception) {
      if (!testException) testException = [exception retain];
    }
    [pool release];
  } @catch (NSException *exception) {
    if (!testException) testException = [exception retain]; 
  }  

  if (interval) *interval = [[NSDate date] timeIntervalSinceDate:startDate];
  if (exception) *exception = testException;
  BOOL passed = (!testException);
  
  if (testException && [target respondsToSelector:@selector(handleException:)]) {
    [target handleException:testException];
  }
  
  return passed;
}

+ (BOOL)runTestOrRaiseWithTarget:(id)target selector:(SEL)selector exception:(NSException **)exception interval:(NSTimeInterval *)interval {
  
  NSDate *startDate = [NSDate date];  
  NSException *testException = nil;
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  if ([target respondsToSelector:@selector(_setUp)])
    [target performSelector:@selector(_setUp)];
      
  if ([target respondsToSelector:@selector(setUp)])
    [target performSelector:@selector(setUp)];

  if ([target respondsToSelector:@selector(setCurrentSelector:)])
    [target setCurrentSelector:selector];
        
  // If this isn't set SenTest macros don't raise
  if ([target respondsToSelector:@selector(raiseAfterFailure)])
    [target raiseAfterFailure];
        
  // Runs the test
  [target performSelector:selector];
        
  if ([target respondsToSelector:@selector(setCurrentSelector:)])
    [target setCurrentSelector:NULL];
      
  if ([target respondsToSelector:@selector(tearDown)])
    [target performSelector:@selector(tearDown)];
      
  // Private tearDown internal to GHUnit (in case subclasses fail to call super)
  if ([target respondsToSelector:@selector(_tearDown)])
    [target performSelector:@selector(_tearDown)];
      
  
  [pool release];
  
  if (interval) *interval = [[NSDate date] timeIntervalSinceDate:startDate];
  if (exception) *exception = testException;
  BOOL passed = (!testException);
  
  if (testException && [target respondsToSelector:@selector(handleException:)]) {
    [target handleException:testException];
  }
  
  return passed;
}

// GTM_END

@end

//! @endcond
