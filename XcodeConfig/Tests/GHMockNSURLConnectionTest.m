//
//  GHNSURLConnectionMockTest.m
//  GHUnit
//
//  Created by Gabriel Handford on 4/9/09.
//  Copyright 2009. All rights reserved.
//

#import "GHAsyncTestCase.h"
#import "GHMockNSURLConnection.h"

@interface GHMockNSURLConnectionTest : GHAsyncTestCase { 
  NSDictionary *testHeaders_;
  NSData *testData_;
}
@end

@implementation GHMockNSURLConnectionTest

- (void)setUpClass {
  testHeaders_= [NSDictionary dictionaryWithObjectsAndKeys:@"somehexdata", @"ETag", nil];
  testData_ = [@"This is test data" dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)tearDownClass {
  testHeaders_ = nil;
  testData_ = nil;
}

- (void)testMock {
  [self prepare];
  GHMockNSURLConnection *connection = [[GHMockNSURLConnection alloc] initWithRequest:nil delegate:self];  
  [connection receiveHTTPResponseWithStatusCode:204 headers:testHeaders_ afterDelay:0.1];
  [connection receiveData:testData_ afterDelay:0.2];
  [connection finishAfterDelay:0.3];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}
  
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  GHAssertEquals([(NSHTTPURLResponse *)response statusCode], (NSInteger)204, nil);
  GHAssertEqualObjects([(NSHTTPURLResponse *)response allHeaderFields], testHeaders_, nil);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  GHAssertEqualObjects(data, testData_, nil);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testMock)];
}

@end

@interface GHMockNSURLConnectionErrorTest : GHAsyncTestCase { 
  NSError *error_;
}
@end

@implementation GHMockNSURLConnectionErrorTest

- (void)testError {
  [self prepare];
  GHMockNSURLConnection *connection = [[GHMockNSURLConnection alloc] initWithRequest:nil delegate:self];
  error_ = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
  [connection failWithError:error_ afterDelay:0.2];
  [self waitForStatus:kGHUnitWaitStatusFailure timeout:1.0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  GHAssertEqualObjects(error, error_, nil);
  [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testError)];
}

@end


@interface GHMockNSURLConnectionPathTest : GHAsyncTestCase {  }
@end

@implementation GHMockNSURLConnectionPathTest

- (void)testMock {
  [self prepare];
  GHMockNSURLConnection *connection = [[GHMockNSURLConnection alloc] initWithRequest:nil delegate:self];  
  [connection receiveFromPath:@"example.json" statusCode:200 MIMEType:@"text/json" afterDelay:0.1];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  GHAssertEquals([(NSHTTPURLResponse *)response statusCode], (NSInteger)200, nil);

  NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
  GHTestLog(@"headers=%@", headers);
  //GHAssertEqualStrings(@"text/json", [headers objectForKey:@"Content-Type"], nil);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  // TODO(gabe): Assert data
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testMock)];
}

@end

