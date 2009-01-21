//
//  GHTest.h
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

@class GHTestCase;

typedef enum {
	GHTestStatusNone,
	GHTestStatusRunning,
	GHTestStatusPassed,
	GHTestStatusFailed
} GHTestStatus;

@interface GHTest : NSObject {
	GHTestCase *testCase_;
	SEL selector_;
	NSTimeInterval interval_;
	
	// If errored
	NSException *exception_; 
	NSString *backTrace_;
	
	GHTestStatus status_;
	
	NSString *selectorName_;
}

- (id)initWithTestCase:(GHTestCase *)testCase selector:(SEL)selector interval:(NSTimeInterval)interval exception:(NSException *)exception;

+ (id)testWithTestCase:(GHTestCase *)testCase selector:(SEL)selector;
+ (id)testWithTestCase:(GHTestCase *)testCase selector:(SEL)selector interval:(NSTimeInterval)interval exception:(NSException *)exception;

@property (readonly) GHTestCase *testCase;
@property (readonly) SEL selector;
@property (readonly) NSTimeInterval interval;
@property (readonly) NSException *exception;
@property (readonly) NSString *backTrace;

@property (readonly) NSString *name;
@property (readonly) NSString *statusString;

@property (assign) GHTestStatus status;
@property (readonly) BOOL failed;

/*!
 Run the test.
 After running, the interval and exception properties may be set.
 @result Yes if passed, NO otherwise
 */
- (BOOL)run;

+ (NSString *)stringFromStatus:(GHTestStatus)status withDefault:(NSString *)defaultValue;

@end
