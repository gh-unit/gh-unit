//
//  GHKit.h
//
//  Created by Gabe on 6/30/08.
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

// Categories
#import "GHNSString+Utils.h"
#import "GHNSDate+Parsing.h"
#import "GHNSFileManager+Utils.h"
#import "GHNSURL+Utils.h"
#import "GHNSString+TimeInterval.h"
#import "GHNSString+Validation.h"
#import "GHNSString+HMAC.h"
#import "GHNSNumber+Utils.h"
#import "GHNSArray+Utils.h"
#import "GHNSDictionary+NSNull.h"
#import "GHNSXMLNode+Utils.h"
#import "GHNSXMLElement+Utils.h"
#import "GHNSInvocation+Utils.h"
#import "GHNSObject+Invocation.h"

// Utilities
#import "GHKeychainStore.h"
#import "GHCGUtils.h"
#import "GHLogger.h"

// Non-iPhone
#ifndef TARGET_OS_IPHONE
#import "GHViewAnimation.h"
#endif

// From GTM
#import "GTMDefines.h"
#import "GTMBase64.h"
#import "GTMRegex.h"
#import "GTMLogger.h"
#import "GTMStackTrace.h"

// JRSwizzle
#import "JRSwizzle.h"

// iPhone Only
#ifdef TARGET_OS_IPHONE
#import "GHKitIPhone.h"
#endif

// Defines

#define GHInteger(n) [NSNumber numberWithInteger:n]

#define GHStr(fmt, ...) \
[NSString stringWithFormat:(fmt), ## __VA_ARGS__]

#define GHDict(key, ...) \
[NSDictionary dictionaryWithKeysAndObjectsMaybeNil: key, ## __VA_ARGS__, nil]

#define GHCGRectToString(rect) NSStringFromRect(NSRectFromCGRect(rect))
#define GHCGSizeToString(size) NSStringFromSize(NSSizeFromCGSize(size))
#define GHCGPointToString(point) NSStringFromPoint(NSPointFromCGPoint(point))

#define GHAssertMainThread() NSAssert([NSThread isMainThread], @"Should be on main thread")

// Default epsilon for float comparisons
#define GH_EPSILON 1.0E-5

#define GHDescription(obj, ...) [[obj dictionaryWithValuesForKeys:[NSArray arrayWithObjects:__VA_ARGS__, nil]] description]
