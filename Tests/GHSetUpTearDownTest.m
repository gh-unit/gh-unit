//
//  GHSetUpTearDownTest.m
//  GHUnit
//
//  Created by Gabriel Handford on 1/19/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestCase.h"

@interface GHSetUpTearDownTest : GHTestCase { }
@end

@implementation GHSetUpTearDownTest

static NSInteger setUpCount = 0;
static NSInteger setUpClassCount = 0;
static NSInteger tearDownCount = 0;
static NSInteger tearDownClassCount = 0;

- (void)setUp { 
  setUpCount++;
}

- (void)tearDown {
  tearDownCount++;
}

- (void)setUpClass {
  if (tearDownClassCount != 0) GHFail(@"tearDownClass called before setUpClass");
  
  setUpClassCount++;
  if (setUpClassCount != 1) GHFail(@"setUpClass called more than once");
}

- (void)tearDownClass { 
  if (setUpClassCount == 0) GHFail(@"setUpClass was never called");
  
  tearDownClassCount++;
  if (tearDownClassCount != 1) GHFail(@"tearDownClassCount called more than once"); 
  
  // Also assert that we had 3 regular set up and tear downs
  if (setUpCount != 3) GHFail(@"Should have had 3 tear downs");
  if (tearDownCount != 3) GHFail(@"Should have had 3 tear downs");
  
  // Cleanup
  setUpCount = 0;
  setUpClassCount = 0;
  tearDownCount = 0;
  tearDownClassCount = 0;
}

- (void)test1 {
  if (setUpClassCount == 0) GHFail(@"setUpClass never called");
}

- (void)test2 {
  
}

- (void)test3 { 

}

@end

@interface GHSetUpClassFailureTest : GHTestCase { }
@end

@implementation GHSetUpClassFailureTest

- (void)setUpClass {
  GHFail(@"Test fail");
}


- (void)test1_EXPECTED { }
- (void)test2_EXPECTED { }

@end

@interface GHTearDownClassFailureTest : GHTestCase { }
@end

@implementation GHTearDownClassFailureTest

- (void)tearDownClass {
  GHFail(@"Test fail");
}


- (void)test1_EXPECTED { }
- (void)test2_EXPECTED { }

@end

