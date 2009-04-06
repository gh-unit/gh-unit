//
//  GHTestCase.h
//  GHUnit
//
//  Created by Gabriel Handford on 1/21/09.
//  Copyright 2009. All rights reserved.
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

#import "GHTestMacros.h"

// Log to your test case logger.
// For example, GHTestLog(@"Some debug info, %@", obj)
#define GHTestLog(...) [self _log:[NSString stringWithFormat:__VA_ARGS__, nil]]

// Test cases should implement this protocol (but don't have to)
@protocol GHUnitTestCase <NSObject>
- (void)failWithException:(NSException*)exception;
- (void)handleException:(NSException *)exception;
- (void)setUp;
- (void)tearDown;
@end

/*!
 Delegate which is notified of log messages from inside GHTestCase.
 */
@protocol GHTestCaseLogDelegate <NSObject>
- (void)testCase:(id)testCase log:(NSString *)message;
@end

/*!
 Test case. 
 Tests can subclass and write tests by adding methods with the 'test' prefix.
 The setUp and tearDown methods are run before and after each test method.
 */
@interface GHTestCase : NSObject <GHUnitTestCase> {
	id<GHTestCaseLogDelegate> logDelegate_; // weak
}

@property (assign, nonatomic) id<GHTestCaseLogDelegate> logDelegate;

/*!
 Log a message, which notifies the id<GHTestCaseLogDelegate> logDelegate_.
 This is not meant to be used directly, see GHTestLog(...) macro.
 */
- (void)_log:(NSString *)message;

// GTM_BEGIN
- (void)setUp;
- (void)tearDown;
- (void)failWithException:(NSException*)exception;
// GTM_END

@end
