//
//  GHUnitIOSTestMain.m
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

#import <objc/runtime.h>

//see https://github.com/gh-unit/gh-unit/issues/96#issuecomment-12881447

@interface UIWindow (Private)
- (void) swizzled_createContext;
@end

@implementation UIWindow (Private)

- (void) swizzled_createContext {
    // Should not create a context
}

@end

int main(int argc, char *argv[]) {
    int retVal;
    @autoreleasepool {
        
        BOOL isCli = getenv("GHUNIT_CLI") ? YES : NO;
        CFMessagePortRef portRef = NULL;
        if (isCli == YES) {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Wselector"
            Method originalWindowCreateContext = class_getInstanceMethod([UIWindow class], @selector(_createContext));
#pragma clang diagnostic pop
            
            Method swizzledWindowCreateConext = class_getInstanceMethod([UIWindow class], @selector(swizzled_createContext));
            method_exchangeImplementations(originalWindowCreateContext, swizzledWindowCreateConext);
            
            portRef = CFMessagePortCreateLocal(NULL, (CFStringRef) @"PurpleWorkspacePort", NULL, NULL, NULL);
        }
        
        retVal = UIApplicationMain(argc, argv, NSStringFromClass([UIApplication class]), @"GHUnitIOSAppDelegate");
        if (portRef != NULL) { CFRelease(portRef); }
    }
    return retVal;
}