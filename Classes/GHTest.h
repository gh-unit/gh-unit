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

typedef enum {
	GHTestStatusNone,
	GHTestStatusRunning,
	GHTestStatusFinished,
} GHTestStatus;

static __inline__ NSString* NSStringFromGHTestStatus(GHTestStatus status) {
	switch(status) {
		case GHTestStatusNone: return NSLocalizedString(@"Waiting", @"Test status / Waiting");
		case GHTestStatusRunning: return NSLocalizedString(@"Running", @"Test status / Running");
		case GHTestStatusFinished: return NSLocalizedString(@"Finished", @"Test status / Finished");
		default: return NSLocalizedString(@"Unknown", @"Test status / Unknown");
	}
}

typedef struct {
	NSInteger runCount;
	NSInteger failureCount;
	NSInteger testCount;
} GHTestStats;

static __inline__ GHTestStats GHTestStatsMake(NSInteger runCount, NSInteger failureCount, NSInteger testCount) {
	GHTestStats stats;
	stats.runCount = runCount;
	stats.failureCount = failureCount; 
	stats.testCount = testCount;
	return stats;
}

#define NSStringFromGHTestStats(stats) [NSString stringWithFormat:@"%d/%d/%d", stats.runCount, stats.testCount, stats.failureCount]

@protocol GHTest <NSObject>

- (void)run;

- (NSString *)identifier;
- (NSString *)name;

- (NSTimeInterval)interval;
- (GHTestStatus)status;
- (GHTestStats)stats;

- (NSException *)exception;

- (void)log:(NSString *)message;
- (NSArray *)log;

@end

@protocol GHTestDelegate <NSObject>
- (void)testDidStart:(id<GHTest>)test;
- (void)testDidFinish:(id<GHTest>)test;
@end

@interface GHTest : NSObject <GHTest> {
	
	id<GHTestDelegate> delegate_; // weak
	
	id target_;
	SEL selector_;
	
	NSString *name_;
	GHTestStatus status_;
	NSTimeInterval interval_;
	BOOL failed_;
	
	GHTestStats stats_;
	
	// Log
	NSMutableArray *log_;
	
	// If errored
	NSException *exception_; 
	
}

- (id)initWithTarget:(id)target selector:(SEL)selector interval:(NSTimeInterval)interval exception:(NSException *)exception;

+ (id)testWithTarget:(id)target selector:(SEL)selector;
+ (id)testWithTarget:(id)target selector:(SEL)selector interval:(NSTimeInterval)interval exception:(NSException *)exception;

@property (readonly, nonatomic) id target;
@property (readonly, nonatomic) SEL selector;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSTimeInterval interval;
@property (readonly, nonatomic) NSException *exception;
@property (readonly, nonatomic) GHTestStatus status;
@property (readonly, nonatomic) BOOL failed;
@property (readonly, nonatomic) GHTestStats stats;
@property (readonly, nonatomic) NSArray *log;

@property (assign, nonatomic) id<GHTestDelegate> delegate;

/*!
 Run the test.
 After running, the interval and exception properties may be set.
 @result Yes if passed, NO otherwise
 */
- (void)run;

@end
