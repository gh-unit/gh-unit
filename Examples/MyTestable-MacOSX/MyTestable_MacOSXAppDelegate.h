//
//  MyTestable_MacOSXAppDelegate.h
//  MyTestable-MacOSX
//
//  Created by Gabriel Handford on 11/4/09.
//  Copyright 2009 Yelp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyTestable_MacOSXAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
