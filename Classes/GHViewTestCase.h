//
//  GHViewTestCase.h
//  GHUnitIOS
//
//  Created by John Boiles on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
