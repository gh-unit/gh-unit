//
//  GHUnitIPhoneAppDelegate.m
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 1/25/09.
//  Copyright 2009. All rights reserved.
//

#import "GHUnitIPhoneAppDelegate.h"
#import "GHUnitIPhoneViewController.h"

@implementation GHUnitIPhoneAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  GHUnitIPhoneViewController *viewController = [[GHUnitIPhoneViewController alloc] init];		
  [viewController loadDefaults];
	navigationController_ = [[UINavigationController alloc] initWithRootViewController:viewController];
  [viewController release];
	CGSize size = [[UIScreen mainScreen] bounds].size;
	window_ = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
	GHUDebug(@"Setting window view");
	[window_ addSubview:navigationController_.view];
	[window_ makeKeyAndVisible];
  
  if (getenv("GHUNIT_AUTORUN")) [viewController runTests];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called only graceful terminate; Closing simulator won't trigger this
  [[[navigationController_ viewControllers] objectAtIndex:0] saveDefaults]; 
}

- (void)dealloc {
	[navigationController_ release];
	[window_ release];
	[super dealloc];
}

@end
