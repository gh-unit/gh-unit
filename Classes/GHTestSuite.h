//
//  GHTestSuite.h
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

#import "GHTestCase.h"

@interface GHTestSuite : NSObject <GHTestCaseDelegate> {
	NSArray *testCases_; // of GHTestCase
	
	NSTimeInterval interval_;
	
	id<GHTestCaseDelegate> delegate_;
	
	NSInteger runCount_;
	NSInteger failedCount_;
	NSInteger totalCount_;
	
	NSString *name_;
	GHTestStatus status_;
}

@property (readonly) NSString *name;
@property (readonly) NSInteger failedCount;
@property (readonly) NSInteger runCount;
@property (readonly) NSInteger totalCount;
@property (readonly) NSTimeInterval interval;
@property (readonly) GHTestStatus status;
@property (readonly) NSString *statusString;

@property (assign) id<GHTestCaseDelegate> delegate;

- (id)initWithTestCases:(NSArray *)testCases;

+ (GHTestSuite *)allTestCases;

+ (BOOL)isTestFixture:(Class)aClass;

- (void)loadTestCases;

- (BOOL)run;

@end
