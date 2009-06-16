//
//  GHUnitIPhoneAppDelegate.h
//  GHUnitIPhone
//
//  Created by Gabriel Handford on 1/25/09.
//  Copyright 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GHUnit.h"

#import "GHUnitIPhoneViewController.h"

@interface GHUnitIPhoneAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window_;
	
	UINavigationController *navigationController_;
	GHUnitIPhoneViewController *viewController_;
}

@end

