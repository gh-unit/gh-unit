# GHUnit

GHUnit is a test framework for Objective-C (Mac OS X 10.5 and iPhone 2.0 and above).
It can be used with SenTestingKit or by itself.
GHUnit uses lots of GTM (google-toolbox-for-mac) code, specifically from the [UnitTesting](http://code.google.com/p/google-toolbox-for-mac/source/browse/trunk/UnitTesting/) parts.

The goals of GHUnit are:

- Runs unit tests within XCode, allowing you to fully utilize the XCode Debugger.
- A simple GUI to help you visualize your tests.
- Show stack traces.
- Be installable as a framework (for Cocoa apps) with a simple target setup; or easy to package into your iPhone project.

`GHTestCase` is the base class for your tests.
Tests are defined by methods that start with 'test', take no arguments and return void. 
Your setup and tear down methods are `- (void)setUp;` and `- (void)tearDown;`. 
You know, pretty much like every test framework in existence.

## A Test Case

	#import <GHUnit/GHUnit.h>
	
	@interface MyTest : GHTestCase { }
	@end
	
	@implementation MyTest
	
	- (void)setUp {
		// Run before each test method
	}
	
	- (void)tearDown {
		// Run after each test method
	}
 
	- (void)testFoo {
		// Assert a is not NULL, with no custom error description
		GHAssertNotNULL(a, nil);
		
		// Assert equal objects, add custom error description
		GHAssertEqualObjects(a, b, @"Foo should be equal to: %@. Something bad happened", bar);
	}
	
	- (void)testBar {
		// Another test
	}
	
	@end

## Test Macros
 
The following test macros are included. They are the same or similar to SenTest macros (STAssertTrue, etc). 
The `description` arg appends extra information for when the assert fails; though most of the time you might leave it as nil.
 
	GHAssertNoErr(a1, description, ...)
	GHAssertErr(a1, a2, description, ...)
	GHAssertNotNULL(a1, description, ...)
	GHAssertNULL(a1, description, ...)
	GHAssertNotEquals(a1, a2, description, ...)
	GHAssertNotEqualObjects(a1, a2, desc, ...)
	GHAssertOperation(a1, a2, op, description, ...)
	GHAssertGreaterThan(a1, a2, description, ...)
	GHAssertGreaterThanOrEqual(a1, a2, description, ...)
	GHAssertLessThan(a1, a2, description, ...)
	GHAssertLessThanOrEqual(a1, a2, description, ...)
	GHAssertEqualStrings(a1, a2, description, ...)
	GHAssertNotEqualStrings(a1, a2, description, ...)
	GHAssertEqualCStrings(a1, a2, description, ...)
	GHAssertNotEqualCStrings(a1, a2, description, ...)
	GHAssertEqualObjects(a1, a2, description, ...)
	GHAssertEquals(a1, a2, description, ...)
	GHAbsoluteDifference(left,right) (MAX(left,right)-MIN(left,right))
	GHAssertEqualsWithAccuracy(a1, a2, accuracy, description, ...)
	GHFail(description, ...)
	GHAssertNil(a1, description, ...)
	GHAssertNotNil(a1, description, ...)
	GHAssertTrue(expr, description, ...)
	GHAssertTrueNoThrow(expr, description, ...)
	GHAssertFalse(expr, description, ...)
	GHAssertFalseNoThrow(expr, description, ...)
	GHAssertThrows(expr, description, ...)
	GHAssertThrowsSpecific(expr, specificException, description, ...)
	GHAssertThrowsSpecificNamed(expr, specificException, aName, description, ...)
	GHAssertNoThrow(expr, description, ...)
	GHAssertNoThrowSpecific(expr, specificException, description, ...)
	GHAssertNoThrowSpecificNamed(expr, specificException, aName, description, ...)

## Adding a GHUnit Test Target (Cocoa Apps)

The following steps will give you a test target:

- Install GHKit.framework by copying it to /Library/Frameworks/
- Install GHUnit.framework by copying it to /Library/Frameworks/
- Add a New Target. Select Cocoa Application. Name it something like 'Tests'.
- Add the GHUnit.framework as a linked library to the test target.
- Create a test main. For example, add a file called TestsMain.m (or similar) with the following:

.
	#import <Foundation/Foundation.h>
	#import <Foundation/NSDebug.h>

	#import <GHUnit/GHUnit.h>
	#import <GHUnit/GHTestApp.h>

	int main(int argc, char *argv[]) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		GHTestApp *app = [[GHTestApp alloc] init];
		[NSApp run];
		[app release];
		[pool release];
	}
	
- Create a test (either by subclassing SenTestCase or GHTestCase). Adding it to your test target. For example MyTest.m:

.
	#import <GHUnit/GHUnit.h>

	@interface MyTest : GHTestCase { }
	@end

	@implementation MyTest

	- (void)setUp {
		// Run before each test method
	}

	- (void)tearDown {
		// Run after each test method
	}

	- (void)testFoo {
		// Assert a is not NULL, with no custom error description
		GHAssertNotNULL(a, nil);
	
		// Assert equal objects, add custom error description
		GHAssertEqualObjects(a, b, @"Foo should be equal to: %@. Something bad happened", bar);
	}

	- (void)testBar {
		// Another test
	}

	@end

- Make sure the Test target is currently selected and click Build & Go.
- You should see the following: TODO(gabe)

Optionally, you can create a prefix header (Tests_Prefix.pch) and add #import <GHUnit/GHUnit.h> to it, and then you won't have to include that import for every test.

## Adding a GHUnit Test Target (iPhone)

Coming soon!

## Using SenTestingKit

You can also use GHUnit with SenTestCase, for example:

	#import <SenTestingKit/SenTestingKit.h>

	@interface MyTest : SenTestCase { }
	@end

	@implementation MyTest

	- (void)setUp {
		// Run before each test method
	}

	- (void)tearDown {
		// Run after each test method
	}

	- (void)testFoo {
		// Assert a is not NULL, with no custom error description
		STAssertNotNULL(a, nil);
	
		// Assert equal objects, add custom error description
		STAssertEqualObjects(a, b, @"Foo should be equal to: %@. Something bad happened", bar);
	}

	- (void)testBar {
		// Another test
	}

	@end
