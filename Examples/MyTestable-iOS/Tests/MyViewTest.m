//
//  MyViewTest.m
//  MyTestable
//
//  Created by John Boiles on 10/26/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h> 
#import "MyTestableViewController_iPhone.h"
#import "MyTestableViewController_iPad.h"

@interface MyViewTest : GHViewTestCase { }
@end

@implementation MyViewTest

- (void)testIPhoneViewController {
  MyTestableViewController_iPhone *viewController = [[MyTestableViewController_iPhone alloc] init];
  GHVerifyView(viewController.view);
}

- (void)testIPadViewController {
  MyTestableViewController_iPad *viewController = [[MyTestableViewController_iPad alloc] init];
  GHVerifyView(viewController.view);
}

@end
