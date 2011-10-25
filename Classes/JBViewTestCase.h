//
//  JBViewTestCase.h
//  GHUnitIOS
//
//  Created by John Boiles on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GHTestCase.h"
#import <UIKit/UIKit.h>

/*! Assert that a view has not changed
 */
#define GHVerifyView(view) \
do { \
[self verifyView:view];\
} while (0)

@interface JBViewTestCase : GHTestCase {  
  NSInteger imageVerifyCount_;
}

- (BOOL)verifyView:(UIView *)view;

+ (void)clearTestImages;

+ (void)saveToDocumentsWithImage:(UIImage *)image filename:(NSString *)filename;

@end
