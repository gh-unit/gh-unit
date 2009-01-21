//
//  GHNSInvocation+Utils.h
//  GHKit
//
//  Created by Gabriel Handford on 1/17/09.
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

#import <Foundation/Foundation.h>

//
// Creates arguments NSArray from var args, with first object named 'object'
// - (void)methodName:(id)arg1 withObjects:object, ...
//
#define GHConvertVarArgs(object) \
NSMutableArray *arguments = [NSMutableArray array]; \
id arg; \
va_list args; \
if (object) { \
[arguments addObject:object]; \
va_start(args, object); \
while (arg = va_arg(args, id)) \
[arguments addObject:arg]; \
va_end(args); \
}

@interface NSInvocation (GHUtils)

/*!
 Invoke on main thread.
 @param waitUntilDone Whether to join on the call
 */
- (void)gh_invokeOnMainThread:(BOOL)waitUntilDone;

/*!
 Invoke selector on target with multiple arguments.
 @param target Invocation target
 @param selector Method
 @param withObjects (Variable) Arguments list
 */
+ (id)gh_invokeWithTarget:(id)target selector:(SEL)selector withObjects:object, ...;

+ (id)gh_invokeWithTarget:(id)target selector:(SEL)selector arguments:(NSArray *)arguments;

/*!
 Invoke selector on target on main thread with multiple arguments.
 Use [NSNull null] for nil arguments.
 @param target
 @param selector
 @param waitUntilDone
 @param withObjects
 */
+ (void)gh_invokeTargetOnMainThread:(id)target selector:(SEL)selector waitUntilDone:(BOOL)waitUntilDone withObjects:object, ...;

+ (void)gh_invokeTargetOnMainThread:(id)target selector:(SEL)selector waitUntilDone:(BOOL)waitUntilDone arguments:(NSArray *)arguments;

/*!
 Create invocation with variable arguments.
 Use [NSNull null] for nil arguments.
 @param target Invocation target
 @param selector Method
 @param hasReturnValue Will be set to YES, if there is a return value
 @param withObjects (Variable) Arguments list
 */
+ (NSInvocation *)gh_invocationWithTarget:(id)target selector:(SEL)selector hasReturnValue:(BOOL *)hasReturnValue withObjects:object, ...;

/*!
 Create invocation with variable arguments.
 Use [NSNull null] for nil arguments.
 @param target Invocation target
 @param selector Method
 @param hasReturnValue Will be set to YES, if there is a return value
 @param arguments Arguments array
 */
+ (NSInvocation *)gh_invocationWithTarget:target selector:(SEL)selector hasReturnValue:(BOOL *)hasReturnValue arguments:(NSArray *)arguments;

@end
