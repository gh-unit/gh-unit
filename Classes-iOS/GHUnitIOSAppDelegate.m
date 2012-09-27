//
//  GHUnitIOSAppDelegate.m
//  GHUnitIOS
//
//  Created by Gabriel Handford on 1/25/09.
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

#import "GHUnitIOSAppDelegate.h"
#import "GHUnitIOSViewController.h"
#import "GHUnit.h"

@interface GHUnitIOSAppDelegate (Terminate)
- (void)_terminateWithStatus:(int)status;
@end

@implementation GHUnitIOSAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  if (getenv("GHUNIT_CLI")) {
    int exitStatus = [GHTestRunner run];
    if ([application respondsToSelector:@selector(_terminateWithStatus:)]) {
      [(id)application _terminateWithStatus:exitStatus];
    } else {
      exit(exitStatus);
    }
  }
  GHUnitIOSViewController *viewController = [[GHUnitIOSViewController alloc] init];
  [viewController loadDefaults];
  navigationController_ = [[UINavigationController alloc] initWithRootViewController:viewController];
  CGSize size = [[UIScreen mainScreen] bounds].size;
  window_ = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
  window_.rootViewController = navigationController_;
  [window_ addSubview:navigationController_.view];
  [window_ makeKeyAndVisible];

  // Delete all interim saved images from previous UI tests
  [GHViewTestCase clearTestImages];

  if (getenv("GHUNIT_AUTORUN")) [viewController runTests];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called only graceful terminate; Closing simulator won't trigger this
  [[[navigationController_ viewControllers] objectAtIndex:0] saveDefaults]; 
}


@end
