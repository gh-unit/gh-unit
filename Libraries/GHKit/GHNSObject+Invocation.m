//
//  GHNSObject+Invocation.m
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

#import "GHNSObject+Invocation.h"

@implementation NSObject (GHInvocation_GHUNIT)

- (id)ghu_performIfRespondsToSelector:(SEL)selector {
	if ([self respondsToSelector:selector]) return [self performSelector:selector];
	return nil;
}

- (id)ghu_performIfRespondsToSelector:(SEL)selector withObjects:object, ... {
	if ([self respondsToSelector:selector]) {
		GHConvertVarArgs(object);
		return [NSInvocation ghu_invokeWithTarget:self selector:selector arguments:arguments];
	}
	return nil;
}

- (id)ghu_performSelector:(SEL)selector withObjects:object, ... {
	GHConvertVarArgs(object);
	return [NSInvocation ghu_invokeWithTarget:self selector:selector arguments:arguments];	
}

- (id)ghu_performSelector:(SEL)selector afterDelay:(NSTimeInterval)delay withObjects:object, ... {
	GHConvertVarArgs(object);
	return [NSInvocation ghu_invokeWithTarget:self selector:selector afterDelay:delay arguments:arguments];		
}

- (void)ghu_performSelectorOnMainThread:(SEL)selector withObjects:object, ... {
	GHConvertVarArgs(object);
	[NSInvocation ghu_invokeTargetOnMainThread:self selector:selector waitUntilDone:NO arguments:arguments];	
}

- (void)ghu_performSelectorOnMainThread:(SEL)selector waitUntilDone:(BOOL)waitUntilDone withObjects:object, ... {
	GHConvertVarArgs(object);
	[NSInvocation ghu_invokeTargetOnMainThread:self selector:selector waitUntilDone:waitUntilDone arguments:arguments];	
}

- (void)ghu_performSelector:(SEL)selector onMainThread:(BOOL)onMainThread waitUntilDone:(BOOL)waitUntilDone withObjects:object, ... {
	GHConvertVarArgs(object);
	[self ghu_performSelector:selector onMainThread:onMainThread waitUntilDone:waitUntilDone arguments:arguments];
}	

- (void)ghu_performSelector:(SEL)selector onMainThread:(BOOL)onMainThread waitUntilDone:(BOOL)waitUntilDone arguments:(NSArray *)arguments {
	[self ghu_performSelector:selector onMainThread:onMainThread waitUntilDone:waitUntilDone afterDelay:-1 arguments:arguments];
}

- (void)ghu_performSelector:(SEL)selector onMainThread:(BOOL)onMainThread waitUntilDone:(BOOL)waitUntilDone 
								afterDelay:(NSTimeInterval)delay arguments:(NSArray *)arguments {

	if (!onMainThread) {
		[NSInvocation ghu_invokeWithTarget:self selector:selector afterDelay:delay arguments:arguments];	
	} else {
		[NSInvocation ghu_invokeTargetOnMainThread:self selector:selector waitUntilDone:waitUntilDone afterDelay:delay arguments:arguments];	
	}
}

// From DDFoundation, NSObject+DDExtensions 
// (Changed namespaced to make it easier to include in static library without conflicting)

- (id)ghu_proxyOnMainThread {
	return [self ghu_proxyOnMainThread:NO];
}

- (id)ghu_proxyOnMainThread:(BOOL)waitUntilDone {
	GHNSInvocationProxy_GHUNIT *proxy = [GHNSInvocationProxy_GHUNIT invocation];
	proxy.thread = [NSThread mainThread];
	proxy.waitUntilDone = waitUntilDone;
	return [proxy prepareWithInvocationTarget:self];
}

- (id)ghu_proxyOnThread:(NSThread *)thread {
	return [self ghu_proxyOnThread:thread waitUntilDone:NO];
}

- (id)ghu_proxyOnThread:(NSThread *)thread waitUntilDone:(BOOL)waitUntilDone {
	GHNSInvocationProxy_GHUNIT *proxy = [GHNSInvocationProxy_GHUNIT invocation];
	proxy.thread = thread;
	proxy.waitUntilDone = waitUntilDone;
	return [proxy prepareWithInvocationTarget:self];
}

- (id)ghu_proxyAfterDelay:(NSTimeInterval)delay {
	GHNSInvocationProxy_GHUNIT *proxy = [GHNSInvocationProxy_GHUNIT invocation];
	proxy.delay = delay;
	return [proxy prepareWithInvocationTarget:self];	
}

- (id)ghu_timedProxy:(NSTimeInterval *)time {
	return [self ghu_debugProxy:time proxy:nil];
}

- (id)ghu_debugProxy:(NSTimeInterval *)time proxy:(GHNSInvocationProxy_GHUNIT **)proxy {
	GHNSInvocationProxy_GHUNIT *lproxy = [GHNSInvocationProxy_GHUNIT invocation];
	if (proxy) *proxy = lproxy;
	lproxy.time = time;	
	return [lproxy prepareWithInvocationTarget:self];		
}

@end
