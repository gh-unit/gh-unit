//
//  GHKVObserveTest.m
//  GHUnitIOS
//
//  Created by Gabriel Handford on 11/14/10.
//  Copyright 2010. All rights reserved.
//


#import "GHAsyncTestCase.h"

@interface GHKVObserve : NSObject {
  NSString *_text;
}

@property (strong, nonatomic) NSString *text;

- (void)updateText;

@end


@interface GHKVObserveTest : GHAsyncTestCase { }
@end


@implementation GHKVObserveTest

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testObserve)];
}

- (void)testObserve {
  GHKVObserve *observe = [[GHKVObserve alloc] init];
  [self prepare];
  [observe addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
  [observe updateText];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
  GHAssertEqualStrings(observe.text, @"Test", nil);
}

@end

#pragma mark -

@implementation GHKVObserve

@synthesize text=_text;


- (void)updateText {
  [self performSelector:@selector(setText:) withObject:@"Test" afterDelay:0.1];
}

@end
