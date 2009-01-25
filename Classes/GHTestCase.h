//
//  GHTestCase.h
//  GHUnit
//
//  Created by Gabriel Handford on 1/21/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestMacros.h"

@interface GHTestCase : NSObject {

}

// GTM_BEGIN
- (void)setUp;
- (void)tearDown;
- (void)failWithException:(NSException*)exception;

+ (void)printException:(NSException *)exception fromTestName:(NSString *)name;
// GTM_END

@end
