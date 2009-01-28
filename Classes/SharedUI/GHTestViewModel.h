//
//  GHTest.h
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

#import "GHTestGroup.h"

@class GHTestNode;

@interface GHTestViewModel : NSObject {
	
	GHTestNode *root_;
	
	NSMutableDictionary *map_;

}

@property (readonly, nonatomic) GHTestNode *root;

- (id)initWithRoot:(id<GHTestGroup>)root;

- (NSString *)name;
- (NSString *)statusString;

- (GHTestNode *)findTestNode:(id<GHTest>)test;
- (void)registerNode:(GHTestNode *)node;

@end

@interface GHTestNode : NSObject {

	id<GHTest> test_;
	NSMutableArray *children_;

}

@property (readonly, nonatomic) NSString *identifier;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSArray *children;
@property (readonly, nonatomic) id<GHTest> test;
@property (readonly, nonatomic) GHTestStatus status;
@property (readonly, nonatomic) BOOL failed;
@property (readonly, nonatomic) NSString *statusString;
@property (readonly, nonatomic) NSString *stackTrace;
@property (readonly, nonatomic) NSString *log;
@property (readonly, nonatomic) BOOL isRunning;
@property (readonly, nonatomic) BOOL isFinished;
@property (readonly, nonatomic) BOOL isGroupTest; // YES if test has "sub tests"

- (id)initWithTest:(id<GHTest>)test children:(NSArray *)children source:(GHTestViewModel *)source;
+ (GHTestNode *)nodeWithTest:(id<GHTest>)test children:(NSArray *)children source:(GHTestViewModel *)source;

@end
