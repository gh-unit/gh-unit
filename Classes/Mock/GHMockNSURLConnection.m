//
//  GHMockNSURLConnection.m
//  GHUnit
//
//  Created by Gabriel Handford on 4/9/09.
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

#import "GHMockNSURLConnection.h"
#import "GHMockNSHTTPURLResponse.h"
#import "GHNSObject+Invocation.h"

NSString *const GHMockNSURLConnectionException = @"GHMockNSURLConnectionException";

@implementation GHMockNSURLConnection

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate {
	if ((self = [super init])) {
		request_ = [request retain];
		delegate_ = delegate;
	}
	return self;
}

- (void)dealloc {
	[request_ release];
	[super dealloc];
}

#pragma mark -

- (void)cancel {
	cancelled_ = YES;
}

#pragma mark -

- (void)receiveData:(NSData *)data afterDelay:(NSTimeInterval)delay {
	[delegate_ gh_performSelector:@selector(connection:didReceiveData:) afterDelay:delay withObjects:[NSNull null], data, nil];
}

- (void)receiveFromPath:(NSString *)path statusCode:(NSInteger)statusCode MIMEType:(NSString *)MIMEType afterDelay:(NSTimeInterval)delay {
	NSString *resourcePath = [[NSBundle mainBundle] pathForResource:[path stringByDeletingPathExtension] ofType:[path pathExtension]];
	
	NSError *error = nil;	
	NSString *data = [NSString stringWithContentsOfFile:resourcePath encoding:NSUTF8StringEncoding error:&error];	
	if (error)
		[NSException raise:GHMockNSURLConnectionException format:@"%@", error];
	
	GHMockNSHTTPURLResponse *response = [[[GHMockNSHTTPURLResponse alloc] initWithURL:[request_ URL] 
																																					 MIMEType:MIMEType
																															expectedContentLength:[data lengthOfBytesUsingEncoding:NSUTF8StringEncoding] 
																																	 textEncodingName:nil] autorelease];
	
	[response setStatusCode:statusCode];
	[self receiveResponse:response afterDelay:delay];
	[self receiveData:[data dataUsingEncoding:NSUTF8StringEncoding] afterDelay:delay];
	[self finishAfterDelay:delay];
	
}

- (void)receiveHTTPResponseWithStatusCode:(int)statusCode headers:(NSDictionary *)headers afterDelay:(NSTimeInterval)delay {
	[self receiveResponse:[[[GHMockNSHTTPURLResponse alloc] initWithStatusCode:statusCode headers:headers] autorelease] afterDelay:delay];
}

- (void)receiveResponse:(NSURLResponse *)response afterDelay:(NSTimeInterval)delay {
	[delegate_ gh_performSelector:@selector(connection:didReceiveResponse:) afterDelay:delay withObjects:self, response, nil];
}

- (void)finishAfterDelay:(NSTimeInterval)delay {
	[delegate_ gh_performSelector:@selector(connectionDidFinishLoading:) afterDelay:delay withObjects:self, nil];
}

@end
