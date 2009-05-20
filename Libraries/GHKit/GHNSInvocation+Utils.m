//
//  GHNSInvocation+Utils.m
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

#import "GHNSInvocation+Utils.h"


@implementation NSInvocation (GHUtils_GHUNIT)

+ (id)ghu_invokeWithTarget:(id)target selector:(SEL)selector withObjects:object, ... {
	GHConvertVarArgs(object);
	return [self ghu_invokeWithTarget:target selector:selector arguments:arguments];
}
	
+ (id)ghu_invokeWithTarget:(id)target selector:(SEL)selector arguments:(NSArray *)arguments {
	return [self ghu_invokeWithTarget:target selector:selector afterDelay:-1 arguments:arguments];
}

+ (id)ghu_invokeWithTarget:(id)target selector:(SEL)selector afterDelay:(NSTimeInterval)delay arguments:(NSArray *)arguments {
	BOOL hasReturnValue = NO;
	NSInvocation *invocation = [self ghu_invocationWithTarget:target selector:selector hasReturnValue:&hasReturnValue arguments:arguments];
	if (delay >= 0) {
		[invocation performSelector:@selector(invoke) withObject:nil afterDelay:delay];
	} else {
		[invocation invoke];
	
		if (hasReturnValue) {
			id retval = NULL;
			[invocation getReturnValue:&retval];
			return retval;
		}
	}
	return nil;
}

+ (void)ghu_invokeTargetOnMainThread:(id)target selector:(SEL)selector waitUntilDone:(BOOL)waitUntilDone withObjects:object, ... {
	GHConvertVarArgs(object);
	[self ghu_invokeTargetOnMainThread:target selector:selector waitUntilDone:waitUntilDone arguments:arguments];
}

+ (void)ghu_invokeTargetOnMainThread:(id)target selector:(SEL)selector waitUntilDone:(BOOL)waitUntilDone arguments:(NSArray *)arguments {
	NSInvocation *invocation = [self ghu_invocationWithTarget:target selector:selector hasReturnValue:nil arguments:arguments];
	[invocation ghu_invokeOnMainThread:waitUntilDone];	
}

+ (void)ghu_invokeTargetOnMainThread:(id)target selector:(SEL)selector waitUntilDone:(BOOL)waitUntilDone afterDelay:(NSTimeInterval)delay arguments:(NSArray *)arguments {	
	NSInvocation *invocation = [self ghu_invocationWithTarget:target selector:selector hasReturnValue:nil arguments:arguments];	
	if (delay >= 0) {
		SEL selector = @selector(ghu_invokeOnMainThreadAndWaitUntilDone);
		if (!waitUntilDone) selector = @selector(ghu_invokeOnMainThread);	
		[invocation performSelector:selector withObject:nil afterDelay:delay];
	} else {
		[invocation ghu_invokeOnMainThread:waitUntilDone];	
	}
}

- (void)ghu_invokeOnMainThread {
	[self ghu_invokeOnMainThread:NO];
}

- (void)ghu_invokeOnMainThreadAndWaitUntilDone {
	[self ghu_invokeOnMainThread:YES];
}

- (void)ghu_invokeOnMainThread:(BOOL)waitUntilDone {
	// Retain args, since we are invoking on a separate thread
	if (![self argumentsRetained]) [self retainArguments];
	[self performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:waitUntilDone];		
}

+ (NSInvocation *)ghu_invocationWithTarget:target selector:(SEL)selector hasReturnValue:(BOOL *)hasReturnValue withObjects:object, ... {
	GHConvertVarArgs(object);
	return [self ghu_invocationWithTarget:target selector:selector hasReturnValue:hasReturnValue arguments:arguments];
}

+ (NSInvocation *)ghu_invocationWithTarget:target selector:(SEL)selector hasReturnValue:(BOOL *)hasReturnValue arguments:(NSArray *)arguments {
	
	if (![target respondsToSelector:selector])
		[NSException raise:NSInvalidArgumentException format:@"Target '%@' does not response to selector '%@'", NSStringFromClass([target class]), NSStringFromSelector(selector)];
		
	NSMethodSignature *methodSignature = [target methodSignatureForSelector:selector];
	if (hasReturnValue)
		*hasReturnValue = ([methodSignature methodReturnLength] > 0);
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
	// Subtract by 2, since "NSMethodSignature object includes the hidden arguments self and _cmd, 
	// which are the first two arguments passed to every method implementation."
	NSInteger selectorArgCount = [methodSignature numberOfArguments] - 2;
	for(NSInteger i = 0; i < selectorArgCount && i < [arguments count]; i++) {
		id arg = [arguments objectAtIndex:i];
		if (![[NSNull null] isEqual:arg]) {
			[invocation setArgument:&arg atIndex:(i + 2)];
		}
	}
	[invocation setTarget:target];
	[invocation setSelector:selector];
	return invocation;
}

@end
