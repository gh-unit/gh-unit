//
//  GHUnitIPhoneExceptionViewController.h
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 2/20/09.
//  Copyright 2009. All rights reserved.
//

@interface GHUnitIPhoneExceptionViewController : UIViewController {
	UITextView *textView_;
	
	NSString *stackTrace_;
}

@property (retain, nonatomic) NSString *stackTrace;

@end
