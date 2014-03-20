//
//  PGRunLoop.h
//  GHUnitIOS
//
//  Created by lipa on 1/24/14.
//
//

#import <Foundation/Foundation.h>
#import "GHAsyncTestCase.h"
@interface PGMockRunLoop : NSObject

+(void) runInFakeRunLoopTarget:(id) target selector:(SEL) selector withCallbackTarget:(id) callbacktarget callbackSelector:(SEL) callbackselctor callBackArguments:(NSDictionary*) arg;

+(void) requestCallbackAfterCurrentRunLoopCompleteTarget:(id) target selector:(SEL) selector argument:(id) argument;

+(void) addTimeoutTarget:(id) target selector:(SEL) selector argument:(id) argument timeout:(CFTimeInterval) timeout status:(NSInteger) status testCase:(GHAsyncTestCase*)testCase;

+(void) cancelPreviousPerformRequestsWithTarget:(id)aTarget;

@end
