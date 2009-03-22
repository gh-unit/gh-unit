//
//  MyTestableAppDelegate.h
//  MyTestable
//
//  Created by Gabriel Handford on 2/15/09.
//  Copyright 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTestableAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

