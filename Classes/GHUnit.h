//
//  GHUnit.h
//  GHUnit
//

#import "GHTestCase.h"
#import "GHAsyncTestCase.h"
#import "GHTestSuite.h"
#import "GHTestMacros.h"
#import "GHTestRunner.h"
#import "GHTest.h"
#import "GHTesting.h"
#import "GHTestOperation.h"
#import "GHTestGroup.h"
#import "GHTest+JUnitXML.h"
#import "GHTestGroup+JUnitXML.h"
#import "NSException+GHTestFailureExceptions.h"
#import "NSValue+GHValueFormatter.h"

#if TARGET_OS_IPHONE
#import "GHTestUtils.h"
#import "GHUnitIOSAppDelegate.h"
#import "GHViewTestCase.h"
#endif

#ifdef DEBUG
#define GHUDebug(fmt, ...) do { \
fputs([[[NSString stringWithFormat:fmt, ##__VA_ARGS__] stringByAppendingString:@"\n"] UTF8String], stdout); \
} while(0)
#else
#define GHUDebug(fmt, ...) do {} while(0)
#endif
