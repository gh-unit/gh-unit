//
//  GHLogger.m
//  GHKit
//
//  Created by Gabriel Handford on 1/24/09.
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

#import "GHLogger.h"

@implementation GHLogger

+ (void)setLogLevel:(GTMLoggerLevel)level {
	[[GTMLogger sharedLogger] setFilter:[[[GHLogLevelFilter alloc] initWithLevel:level] autorelease]];
}

@end

@implementation GHLogLevelFilter

@synthesize level=level_;

- (id)initWithLevel:(GTMLoggerLevel)level {
	if ((self = [super init])) {
		level_ = level;
	}
	return self;
}

- (BOOL)filterAllowsMessage:(NSString *)msg level:(GTMLoggerLevel)level {
	return (level >= level_);
}

@end
