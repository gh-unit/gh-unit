//
//  GHTestApplicationDelegateTest.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 2/1/10.
//  Copyright 2010 Yelp. All rights reserved.
//


#import "GHTestCase.h"
#import "GHTestRunner.h"

@interface GHTestApplicationDelegateTest : GHTestCase { }
@end

@interface GHTestApplication : UIApplication {}
@end

@interface GHTestApplicationDelegate : NSObject <UIApplicationDelegate> {}
@end

@implementation GHTestApplication
@end

@implementation GHTestApplicationDelegate
@end

@implementation GHTestApplicationDelegateTest

- (void)testApplication {
  if (!getenv("GHUNIT_CLI")) return; // Only testable via command line
  
  [GHTestRunner setApplicationClassName:@"GHTestApplication" delegateClassName:@"GHTestApplicationDelegate"];  
  GHAssertNotNil([UIApplication sharedApplication], nil);
  id delegate = [UIApplication sharedApplication].delegate;  
  GHAssertNotNil(delegate, nil);
  GHAssertEqualStrings(NSStringFromClass([delegate class]), @"GHTestApplicationDelegate", nil);
}

@end