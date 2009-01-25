//
//  GHTestCase.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/21/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestCase.h"


@implementation GHTestCase

// GTM_BEGIN

- (void)failWithException:(NSException*)exception { }

- (void)setUp { }

- (void)tearDown { }

+ (void)printException:(NSException *)exception fromTestName:(NSString *)name {
	
	NSDictionary *userInfo = [exception userInfo];
  NSString *filename = [userInfo objectForKey:GHTestFilenameKey];
  NSNumber *lineNumber = [userInfo objectForKey:GHTestLineNumberKey];
  if ([filename length] == 0) {
    filename = @"Unknown.m";
  }
	
	NSString *className = NSStringFromClass([self class]);
	NSString *exceptionInfo = [NSString stringWithFormat:@"%@:%d: error: -[%@ %@] %@\n", 
														 filename,
														 [lineNumber integerValue],
														 className, 
														 name,
														 [exception reason]];
	
	NSString *exceptionTrace = [NSString stringWithFormat:@"%@\n%@\n", 
															exceptionInfo, 
															GTMStackTraceFromException(exception)];
	
  fprintf(stderr, [exceptionInfo UTF8String]);
  fflush(stderr);
	fprintf(stderr, [exceptionTrace UTF8String]);
	fflush(stderr);
}

@end
// GTM_END
