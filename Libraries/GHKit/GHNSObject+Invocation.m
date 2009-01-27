//
//  GHNSObject+Invocation.m
//  GHKit
//
//  Created by Gabriel Handford on 1/18/09.
//  Copyright 2009. All rights reserved.
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

#import "GHNSObject+Invocation.h"


@implementation NSObject (GHInvocation)

- (id)gh_performIfRespondsToSelector:(SEL)selector {
	if ([self respondsToSelector:selector]) return [self performSelector:selector];
	return nil;
}

- (id)gh_performIfRespondsToSelector:(SEL)selector withObjects:object, ... {
	if ([self respondsToSelector:selector]) {
		GHConvertVarArgs(object);
		return [NSInvocation gh_invokeWithTarget:self selector:selector arguments:arguments];
	}
	return nil;
}

- (id)gh_performSelector:(SEL)selector withObjects:object, ... {
	GHConvertVarArgs(object);
	return [NSInvocation gh_invokeWithTarget:self selector:selector arguments:arguments];	
}

- (void)gh_performSelectorOnMainThread:(SEL)selector withObjects:object, ... {
	GHConvertVarArgs(object);
	[NSInvocation gh_invokeTargetOnMainThread:self selector:selector waitUntilDone:NO arguments:arguments];	
}

- (void)gh_performSelectorOnMainThread:(SEL)selector waitUntilDone:(BOOL)waitUntilDone withObjects:object, ... {
	GHConvertVarArgs(object);
	[NSInvocation gh_invokeTargetOnMainThread:self selector:selector waitUntilDone:waitUntilDone arguments:arguments];	
}

- (void)gh_performSelector:(SEL)selector onMainThread:(BOOL)onMainThread waitUntilDone:(BOOL)waitUntilDone withObjects:object, ... {
	GHConvertVarArgs(object);
	if (!onMainThread) {
		[NSInvocation gh_invokeWithTarget:self selector:selector arguments:arguments];	
	} else {
		[NSInvocation gh_invokeTargetOnMainThread:self selector:selector waitUntilDone:waitUntilDone arguments:arguments];	
	}
}

@end
