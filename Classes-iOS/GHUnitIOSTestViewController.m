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
#import "GHViewTestCase.h"

@implementation GHUnitIOSTestViewController

- (id)init {
  if ((self = [super init])) {
    UIBarButtonItem *runButton = [[UIBarButtonItem alloc] initWithTitle:@"Re-run" style:UIBarButtonItemStyleDone
                                                 target:self action:@selector(_runTest)];
    self.navigationItem.rightBarButtonItem = runButton;
  }
  return self;
}


- (void)loadView {
  testView_ = [[GHUnitIOSTestView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
  testView_.controlDelegate = self;
  self.view = testView_;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)_runTest {
  id<GHTest> test = [testNode_.test copyWithZone:NULL];
  NSLog(@"Re-running: %@", test);
  [testView_ setText:@"Running..."];
  [test run:GHTestOptionForceSetUpTearDownClass];  
  [self setTest:test];
}

- (void)_showImageDiff {
  if (!imageDiffView_) imageDiffView_ = [[GHImageDiffView alloc] initWithFrame:CGRectZero];
  UIImage *savedImage = [testNode_.test.exception.userInfo objectForKey:@"SavedImage"];
  UIImage *renderedImage = [testNode_.test.exception.userInfo objectForKey:@"RenderedImage"];
  UIImage *diffImage = [testNode_.test.exception.userInfo objectForKey:@"DiffImage"];
  [imageDiffView_ setSavedImage:savedImage renderedImage:renderedImage diffImage:diffImage];
  UIViewController *viewController = [[UIViewController alloc] init];
  viewController.view = imageDiffView_;
  [self.navigationController pushViewController:viewController animated:YES];
}

- (NSString *)updateTestView {
  NSMutableString *text = [NSMutableString stringWithCapacity:200];
  [text appendFormat:@"%@ %@\n", [testNode_ identifier], [testNode_ statusString]];
  NSString *log = [testNode_ log];
  if (log) [text appendFormat:@"\nLog:\n%@\n", log];
  NSString *stackTrace = [testNode_ stackTrace];
  if (stackTrace) [text appendFormat:@"\n%@\n", stackTrace];
  if ([testNode_.test.exception.name isEqualToString:@"GHViewChangeException"]) {
    NSDictionary *exceptionUserInfo = testNode_.test.exception.userInfo;
    UIImage *savedImage = [exceptionUserInfo objectForKey:@"SavedImage"];
    UIImage *renderedImage = [exceptionUserInfo objectForKey:@"RenderedImage"];
    [testView_ setSavedImage:savedImage renderedImage:renderedImage text:text];
  } else if ([testNode_.test.exception.name isEqualToString:@"GHViewUnavailableException"]) {
    NSDictionary *exceptionUserInfo = testNode_.test.exception.userInfo;
    UIImage *renderedImage = [exceptionUserInfo objectForKey:@"RenderedImage"];
    [testView_ setSavedImage:nil renderedImage:renderedImage text:text];
  } else {
    [testView_ setText:text];
  }
  return text;
}

- (void)setTest:(id<GHTest>)test {
  [self view];
  self.title = [test name];

  testNode_ = [GHTestNode nodeWithTest:test children:nil source:nil];
  NSString *text = [self updateTestView];
  NSLog(@"%@", text);
}

#pragma mark Delegates (GHUnitIOSTestView)

- (void)testViewDidSelectSavedImage:(GHUnitIOSTestView *)testView {
  [self _showImageDiff];
  [imageDiffView_ showSavedImage];
}

- (void)testViewDidSelectRenderedImage:(GHUnitIOSTestView *)testView {
  [self _showImageDiff];
  [imageDiffView_ showRenderedImage];
}

- (void)testViewDidApproveChange:(GHUnitIOSTestView *)testView {
  // Save new image as the approved version
  NSString *imageFilename = [testNode_.test.exception.userInfo objectForKey:@"ImageFilename"];
  UIImage *renderedImage = [testNode_.test.exception.userInfo objectForKey:@"RenderedImage"];
  [GHViewTestCase saveApprovedViewTestImage:renderedImage filename:imageFilename];
  testNode_.test.status = GHTestStatusSucceeded;
  [self _runTest];
}

@end
