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
	navigationController_ = [[UINavigationController alloc] initWithRootViewController:viewController];
	[viewController release];
	CGSize size = [[UIScreen mainScreen] applicationFrame].size;
	window_ = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
	GHUDebug(@"Setting window view");
	[window_ addSubview:navigationController_.view];
	[window_ makeKeyAndVisible];
}

- (void)dealloc {
	[navigationController_ release];
	[window_ release];
	[super dealloc];
}

@end
