//
//  GHUnitIPhoneExceptionViewController.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 2/20/09.
//  Copyright 2009. All rights reserved.
//

#import "GHUnitIPhoneExceptionViewController.h"


@implementation GHUnitIPhoneExceptionViewController

@synthesize stackTrace=stackTrace_;

- (void)dealloc {
	[stackTrace_ release];
	[super dealloc];
}

- (void)loadView {	
	textView_ = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	textView_.contentSize = CGSizeMake(1000, 10000);
	textView_.font = [UIFont fontWithName:@"Courier New" size:14];
	textView_.backgroundColor = [UIColor blackColor];
	textView_.textColor = [UIColor whiteColor];
	textView_.editable = NO;
	textView_.showsHorizontalScrollIndicator = YES;
	textView_.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	[textView_ setNeedsLayout];
	self.view = textView_;
	[textView_ release]; // Retained by self.view
}

- (void)setStackTrace:(NSString *)stackTrace {
	[stackTrace retain];
	[stackTrace_ release];
	stackTrace_ = stackTrace;
	textView_.text = stackTrace;
}

@end
