//
//  GHUnitIPhoneTestViewController.h
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 2/20/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestViewModel.h"

@interface GHUnitIPhoneTestViewController : UIViewController <GHTestRunnerDelegate> {
	UITextView *textView_;

  GHTestNode *testNode_;
  
  GHTestRunner *runner_;
}

- (void)setTest:(id<GHTest>)test;

@end
