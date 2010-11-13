//
//  GHSenTestingTest.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/21/09.
//  Copyright 2009. All rights reserved.
//

#define TEST_SENTEST 0

#if TEST_SENTEST
#import <SenTestingKit/SenTestingKit.h>

// To test that we work with SenTestCase as well
@interface GHSenTestingTest : SenTestCase { }
@end

@implementation GHSenTestingTest

- (void)test {
  STAssertTrue(YES, nil);
}

- (void)testFail_EXPECTED {
  STAssertTrue(NO, nil);
}

@end

@interface GHSenTestFailWithException : SenTestCase {
  BOOL _failWithException;
}
@end

@implementation GHSenTestFailWithException

- (void)failWithException:(NSException *)exception {
  _failWithException = YES;
  NSLog(@"Failed with exception: %@", exception);
}

- (void)testFailWithException {
  STFail(@"Fail");
  NSAssert(_failWithException, @"failWithException: was overriden");
}

- (void)testFailWithExceptionCall_EXPECTED {
  [super failWithException:[NSException exceptionWithName:@"GHSenTestFailWithException" reason:@"Testing" userInfo:nil]];
}

@end

#endif
