//
//  GHNSLocale+Mock.h
//  GHUnit
//
//  Created by Gabriel Handford on 4/13/09.
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
#import "GHNSLocale+Mock.h"

#import "GHUNSObject+Swizzle.h"

// Allows us to override the current locale for testing
@implementation NSLocale (GHMock)

static NSString *gGHUNSLocaleLocaleIdentifier = NULL;
static NSArray *gGHUNSLocalePreferredLanguages = NULL;
static BOOL gGHUNSLocaleMockSetup = NO;

+ (void)_gh_setUpMock {
	@synchronized([NSLocale class]) {
		if (!gGHUNSLocaleMockSetup) {
			// TODO(gabe): Check and handle swizzle errors
			[NSLocale ghu_swizzleClassMethod:@selector(currentLocale) withClassMethod:@selector(gh_currentLocale)];
			[NSLocale ghu_swizzleClassMethod:@selector(preferredLanguages) withClassMethod:@selector(gh_preferredLanguages)];
			gGHUNSLocaleMockSetup = YES;
		}		
	}
}

+ (void)gh_setLocaleIdentifier:(NSString *)localeIdentifier {
	[self _gh_setUpMock];
	[gGHUNSLocaleLocaleIdentifier release];
	gGHUNSLocaleLocaleIdentifier = [localeIdentifier copy];
}

+ (void)gh_setPreferredLanguages:(NSArray *)preferredLanguages {
	[self _gh_setUpMock];
	[preferredLanguages retain];
	[gGHUNSLocalePreferredLanguages release];
	gGHUNSLocalePreferredLanguages = preferredLanguages;	
}

+ (NSLocale *)gh_currentLocale {
	if (gGHUNSLocaleLocaleIdentifier != NULL) {
		return [[[NSLocale alloc] initWithLocaleIdentifier:gGHUNSLocaleLocaleIdentifier] autorelease];
	} else {
		return [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	}
}

+ (NSArray *)gh_preferredLanguages {
	if (gGHUNSLocalePreferredLanguages != NULL) {
		return gGHUNSLocalePreferredLanguages;
	} else {
		return [NSArray arrayWithObject:@"en"];
	}
}

@end 

