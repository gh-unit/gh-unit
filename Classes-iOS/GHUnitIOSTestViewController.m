//
//  GHUnitIOSTestViewController.m
//  GHUnitIOS
//
//  Created by Gabriel Handford on 2/20/09.
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

#import "GHUnitIOSTestViewController.h"


@implementation GHUnitIOSTestViewController

- (id)init {
  if ((self = [super init])) {
    UIBarButtonItem *runButton = [[UIBarButtonItem alloc] initWithTitle:@"Re-run" style:UIBarButtonItemStyleDone
                                                 target:self action:@selector(_runTest)];
    self.navigationItem.rightBarButtonItem = runButton;
    [runButton release];
  }
  return self;
}

- (void)dealloc {
  [testNode_ release];
  [super dealloc];
}

- (void)loadView {  
  textView_ = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];  
  textView_.font = [UIFont fontWithName:@"Courier New-Bold" size:12];
  textView_.backgroundColor = [UIColor colorWithWhite:0.96f alpha:1.0f];
  textView_.textColor = [UIColor blackColor];
  textView_.editable = NO;
  textView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  textView_.showsHorizontalScrollIndicator = YES;
  textView_.showsVerticalScrollIndicator = YES;
  textView_.indicatorStyle = UIScrollViewIndicatorStyleWhite;
  textView_.contentSize = CGSizeMake(10000, 10000);
  textView_.scrollEnabled = YES;
  self.view = textView_;
  [textView_ release]; // Retained by self.view
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)_runTest {
  id<GHTest> test = [testNode_.test copyWithZone:NULL];
  NSLog(@"Re-running: %@", test);
  textView_.text = @"Running...";
  [test run:GHTestOptionForceSetUpTearDownClass];  
  [self setTest:test];
  [test release];
}

- (NSString *)updateTestView {
  NSMutableString *text = [NSMutableString stringWithCapacity:200];
  [text appendFormat:@"%@ %@\n", [testNode_ identifier], [testNode_ statusString]];
  NSString *log = [testNode_ log];
  if (log) [text appendFormat:@"\nLog:\n%@\n", log];
  NSString *stackTrace = [testNode_ stackTrace];
  if (stackTrace) [text appendFormat:@"\n%@\n", stackTrace];
  textView_.text = text;    
  return text;
}

- (void)setTest:(id<GHTest>)test {
  [self view];
  self.title = [test name];

  [testNode_ release];
  testNode_ = [[GHTestNode nodeWithTest:test children:nil source:nil] retain];
  NSString *text = [self updateTestView];
  NSLog(@"%@", text);
}

@end
