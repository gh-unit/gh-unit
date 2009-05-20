//
//  GHNSInvocationProxy_GHUNIT.m
//  GHKit
//
//  Modified by Gabriel Handford on 5/9/09.
//  This class is based on DDInvocationGrabber.
//

/*
 * Copyright (c) 2007-2009 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


/*
 *  This class is based on CInvocationGrabber:
 *
 *  Copyright (c) 2007, Toxic Software
 *  All rights reserved.
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *  
 *  * Redistributions of source code must retain the above copyright notice,
 *  this list of conditions and the following disclaimer.
 *  
 *  * Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *  
 *  * Neither the name of the Toxic Software nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *  
 *  THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *  THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "GHNSInvocationProxy.h"


@implementation GHNSInvocationProxy_GHUNIT

@synthesize target=target_, invocation=invocation_, waitUntilDone=waitUntilDone_, thread=thread_, delay=delay_, time=time_;

+ (id)invocation {
	return([[[self alloc] init] autorelease]);
}

- (id)init {
	return self;
}

- (id)prepareWithInvocationTarget:(id)target {
	self.target = target;
	return self;
}

- (void)dealloc {
	[target_ release];
	[invocation_ release];
	[thread_ release];
	[super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
	return [[self target] methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {	
	self.invocation = invocation;
	
	invocation.target = target_;
	
	BOOL invokeOnOtherThread = (thread_ && ![thread_ isEqual:[NSThread currentThread]]) || delay_ > 0;
	if (invokeOnOtherThread && !waitUntilDone_) {
		[invocation retainArguments];
	}
	
	NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
	if (thread_) {
		[invocation_ performSelector:@selector(invoke) onThread:thread_ withObject:nil waitUntilDone:waitUntilDone_];
	} else {
		if (delay_) {
			[invocation_ performSelector:@selector(invoke) withObject:nil afterDelay:delay_];
		} else {
			[invocation_ performSelector:@selector(invoke) withObject:nil];
		}
	}
	NSTimeInterval endTime = [NSDate timeIntervalSinceReferenceDate];
	if (time_) *time_ = (endTime - startTime);
}

@end
