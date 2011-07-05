//
//  MyTestableAppDelegate.m
//  MyTestable
//
//  Created by Gabriel Handford on 2/15/09.
//  Copyright 2009. All rights reserved.
//

#import "MyTestableAppDelegate.h"

@implementation MyTestableAppDelegate

@synthesize window=window_;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window_ makeKeyAndVisible];
}

- (void)dealloc {
    [window_ release];
    [super dealloc];
}

@end
