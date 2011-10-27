//
//  GHViewTestCase.h
//  GHUnitIOS
//
//  Created by John Boiles on 10/20/11.
//  Copyright (c) 2011. All rights reserved.
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

#import "GHTestCase.h"
#import <UIKit/UIKit.h>

/*! 
 Assert that a view has not changed. Raises exception if the view has changed or if
 no image exists from previous test runs.

 @param view The view to verify
 */
#define GHVerifyView(view) \
do { \
[self verifyView:view inFilename:[NSString stringWithUTF8String:__FILE__] atLineNumber:__LINE__];\
} while (0)


@interface GHViewTestCase : GHTestCase {  
  NSInteger imageVerifyCount_;
}

- (BOOL)isCLIDisabled;

- (void)verifyView:(UIView *)view inFilename:(NSString *)filename atLineNumber:(int)lineNumber;

+ (void)clearTestImages;

+ (void)saveToDocumentsWithImage:(UIImage *)image filename:(NSString *)filename;

@end
