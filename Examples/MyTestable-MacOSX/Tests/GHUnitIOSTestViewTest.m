//
//  GHUnitIOSTestViewTest.m
//  GHUnitIOS
//
//  Created by John Boiles on 7/24/12.
//  Copyright (c) 2012. All rights reserved.
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

#import "GHViewTestCase.h"
#import "GHUnitIOSTestView.h"

@interface GHUnitIOSTestViewTest : GHViewTestCase
@end

@implementation GHUnitIOSTestViewTest

- (void)testNoSavedImage {
  GHUnitIOSTestView *testView = [[GHUnitIOSTestView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
  NSString *testText = 
@"GHUnitIOSTestViewTest/test ✘ 4.79s\n"
"\n"
"               Name: GHViewUnavailableException\n"
"               File: /Users/johnb/Programming/gh-unit2/Tests/GHUnitIOSTestViewTest.m\n"
"               Line: 21\n"
"             Reason: No image saved for view\n"
"   \n"
"   (\n"
"    0   CoreFoundation                      0x0142a03e __exceptionPreprocess + 206\n"
"    1   libobjc.A.dylib                     0x015bbcd6 objc_exception_throw + 44\n"
"    2   CoreFoundation                      0x01429ee1 -[NSException raise] + 17\n"
"    3   Tests                               0x00031531 -[GHViewTestCase verifyView:filename:lineNumber:] + 1825\n"
"    4   Tests                               0x0000e4fc -[GHUnitIOSTestViewTest test] + 780\n"
"    5   CoreFoundation                      0x0142bdea -[NSObject performSelector:] + 58\n"
"    6   Tests                               0x00018123 +[GHTesting runTestWithTarget:selector:exception:interval:reraiseExceptions:] + 787\n"
"    7   Tests                               0x00010f1d -[GHTest run:] + 429\n"
"    8   Tests                               0x00027794 -[GHUnitIOSTestViewController _runTest] + 228\n"
"    9   CoreFoundation                      0x0142be99 -[NSObject performSelector:withObject:withObject:] + 73\n"
"    10  UIKit                               0x0007714e -[UIApplication sendAction:to:from:forEvent:] + 96\n"
"    11  UIKit                               0x002b5a0e -[UIBarButtonItem(UIInternal) _sendAction:withEvent:] + 145\n"
"    12  CoreFoundation                      0x0142be99 -[NSObject performSelector:withObject:withObject:] + 73\n"
"    13  UIKit                               0x0007714e -[UIApplication sendAction:to:from:forEvent:] + 96\n"
"    14  UIKit                               0x000770e6 -[UIApplication sendAction:toTarget:fromSender:forEvent:] + 61\n"
"    15  UIKit                               0x0011dade -[UIControl sendAction:to:forEvent:] + 66\n"
"    16  UIKit                               0x0011dfa7 -[UIControl(Internal) _sendActionsForEvents:withEvent:] + 503\n"
"    17  UIKit                               0x0011d266 -[UIControl touchesEnded:withEvent:] + 549\n"
"    18  UIKit                               0x0009c3c0 -[UIWindow _sendTouchesForEvent:] + 513\n"
"    19  UIKit                               0x0009c5e6 -[UIWindow sendEvent:] + 273\n"
"    20  UIKit                               0x00082dc4 -[UIApplication sendEvent:] + 464\n"
"    21  UIKit                               0x00076634 _UIApplicationHandleEvent + 8196\n"
"    22  GraphicsServices                    0x01314ef5 PurpleEventCallback + 1274\n"
"    23  CoreFoundation                      0x013fe195 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__ + 53\n"
"    24  CoreFoundation                      0x01362ff2 __CFRunLoopDoSource1 + 146\n"
"    25  CoreFoundation                      0x013618da __CFRunLoopRun + 2218\n"
"    26  CoreFoundation                      0x01360d84 CFRunLoopRunSpecific + 212\n"
"    27  CoreFoundation                      0x01360c9b CFRunLoopRunInMode + 123\n"
"    28  GraphicsServices                    0x013137d8 GSEventRunModal + 190\n"
"    29  GraphicsServices                    0x0131388a GSEventRun + 103\n"
"    30  UIKit                               0x00074626 UIApplicationMain + 1163\n"
"    31  Tests                               0x0000bb86 main + 134\n"
"    32  Tests                               0x00001f15 start + 53\n"
"    )";
  // Create an image for a new view
  UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
  colorView.backgroundColor = [UIColor greenColor];
  [testView setSavedImage:nil renderedImage:[GHViewTestCase imageWithView:colorView] text:testText];
  GHVerifyView(testView);
}

@end
