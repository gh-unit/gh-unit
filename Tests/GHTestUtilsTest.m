//
//  GHTestUtilsTest.m
//  GHUnitIOS
//
//  Created by John Boiles on 10/22/12.
//  Copyright (c) 2012. All rights reserved.
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
#import "GHTestUtils.h"

@interface GHTestUtilsTest : GHTestCase

@property (nonatomic, assign) BOOL value;

@end

@implementation GHTestUtilsTest

@synthesize value = _value;

- (BOOL)shouldRunOnMainThread { return YES; }

- (void)setUp {
  _value = NO;
}

- (void)testRunForInterval {
  
  __weak typeof(self) wself = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [wself setValue:YES];
  });
  GHRunForInterval(0.1);
  GHAssertTrue(_value, @"_value should have been set to true when running the main loop.");
}

- (void)testRunWhile {
  __weak typeof(self) wself = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    [wself setValue:YES];
  });
  
  GHRunUntilTimeoutWhileBlock(10.0, ^BOOL{
    return ![wself value];
  });
  GHAssertTrue(_value, @"_value should have been set to true when running the main loop.");
}

- (void)testRunWhileTimesOut {
  
  __weak typeof(self) wself = self;
  double delayInSeconds = 0.5;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_current_queue(), ^(void){
    [wself setValue:YES];
  });
  
  GHRunUntilTimeoutWhileBlock(0.1, ^BOOL{
    return ![wself value];
  });
  GHAssertFalse(_value, @"_value should not have been set to true since GHRunUntilTimeoutWhileBlock should have timed out.");
}

@end
