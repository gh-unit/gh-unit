//
//  GHNSObject+Invocation.h
//  GHKit
//
//  Created by Gabriel Handford on 1/18/09.
//  Copyright 2009. All rights reserved.
//

#import "GHNSInvocation+Utils.h"

/*!
 Adds performSelector methods that take a nil-terminated variable argument list,
 for when you need to pass more arguments to performSelector.
 */
@interface NSObject (GHInvocation)

/*!
 Invoke selector with arguments.
 @param selector
 @param withObjects nil terminated variable argument list 
 */
- (id)gh_performSelector:(SEL)selector withObjects:object, ...;

/*!
 Invoke selector with arguments on main thread.
 Does not wait until selector is finished.
 @param selector
 @param withObjects nil terminated variable argument list 
 */
- (void)gh_performSelectorOnMainThread:(SEL)selector withObjects:object, ...;

/*!
 Invoke selector with arguments on main thread.
 @param selector
 @param waitUntilDone Whether to join on selector and wait for it to finish.
 @param withObjects nil terminated variable argument list 
 */
- (void)gh_performSelectorOnMainThread:(SEL)selector waitUntilDone:(BOOL)waitUntilDone withObjects:object, ...;


- (void)gh_performSelector:(SEL)selector onMainThread:(BOOL)onMainThread waitUntilDone:(BOOL)waitUntilDone withObjects:object, ...;

@end
