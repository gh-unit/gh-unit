//
//  GHNSURLConnectionMockTest.m
//  GHUnit
//
//  Created by Gabriel Handford on 4/9/09.
//  Copyright 2009. All rights reserved.
//

#import "GHAsyncTestCase.h"
#import "GHMockNSURLConnection.h"

@interface GHNSURLConnectionMockTest : GHAsyncTestCase { 
	NSDictionary *testHeaders_;
	NSData *testData_;
}
@end

@implementation GHNSURLConnectionMockTest

- (void)setUpClass {
	testHeaders_= [[NSDictionary dictionaryWithObjectsAndKeys:@"somehexdata", @"ETag", nil] retain];
	testData_ = [[@"This is test data" dataUsingEncoding:NSUTF8StringEncoding] retain];
}

- (void)tearDownClass {
	[testHeaders_ release];
	[testData_ release];
}

- (void)testMock {
	[self prepare];
	GHMockNSURLConnection *connection = [[GHMockNSURLConnection alloc] initWithRequest:nil delegate:self];	
	[connection receiveHTTPResponseWithStatusCode:204 headers:testHeaders_ afterDelay:0.1];
	[connection receiveData:testData_ afterDelay:0.2];
	[connection finishAfterDelay:0.3];
	[self waitFor:kGHUnitWaitStatusSuccess timeout:1.0];
}
	
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	GHAssertEquals([(NSHTTPURLResponse *)response statusCode], 204, nil);
	GHAssertEqualObjects([(NSHTTPURLResponse *)response allHeaderFields], testHeaders_, nil);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	GHAssertEqualObjects(data, testData_, nil);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testMock)];
}

@end

@interface GHNSURLConnectionMockPathTest : GHAsyncTestCase {  }
@end

@implementation GHNSURLConnectionMockPathTest

- (void)testMock {
	[self prepare];
	GHMockNSURLConnection *connection = [[GHMockNSURLConnection alloc] initWithRequest:nil delegate:self];	
	[connection receiveFromPath:@"example.json" statusCode:200 MIMEType:@"text/json" afterDelay:0.1];
	[self waitFor:kGHUnitWaitStatusSuccess timeout:1.0];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	GHAssertEquals([(NSHTTPURLResponse *)response statusCode], 200, nil);

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

