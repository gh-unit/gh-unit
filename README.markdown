# GHUnit

GHUnit is a test framework for Objective-C (Mac OS X 10.5 and iPhone 2.0 and above).
It can be used with SenTestingKit or by itself. 

For example, your test cases will be run if they subclass any of the following:

- GHTestCase
- SenTestCase
- GTMTestCase

(Although you can register additional classes at runtime; if you have your own.)

## Download

[GHUnit-0.2.5.zip](http://rel.me.s3.amazonaws.com/gh-unit/GHUnit-0.2.5.zip) (2009/02/05)

## Why?

The goals of GHUnit are:

- Runs unit tests within XCode, allowing you to fully utilize the XCode Debugger.
- A simple GUI to help you visualize your tests.
- Show stack traces.
- Be installable as a framework (for Cocoa apps) with a simple (or not) target setup; or easy to package into your iPhone project.

`GHTestCase` is the base class for your tests.
Tests are defined by methods that start with 'test', take no arguments and return void. 
Your setup and tear down methods are `- (void)setUp;` and `- (void)tearDown;`. 
You know, pretty much like every test framework in existence.

## Adding a GHUnit Test Target (Mac OS X)

To add `GHUnit.framework` to your project:

- Copy `GHUnit.framework` to `/Library/Frameworks/`
- Add a `New Target`. Select `Cocoa -> Application`. Name it `Tests` (or something similar).
- In the `Target 'Tests' Info` window, `General` tab:
	- Add a linked library, under `Mac OS X 10.5 SDK` section, select `GHUnit.framework`
	- Add a linked library, select your project.
	- Add a direct dependency, and select your project. (This will cause your application or framework to build before the test target.)
- Create a test main. For example, create a file called `TestsMain.m` (or similar), that loads and runs the test application. This file and your tests need only to exist in the test target. 

The `TestMain.m` should look like:
 
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
	
- Now create a test (either by subclassing `SenTestCase` or `GHTestCase`). Add it to your test target. 

For example `MyTest.m`:

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
		
		GHTestLog(@"I can log to the GHUnit test console: %@", foo);
		
		// Assert a is not NULL, with no custom error description
		GHAssertNotNULL(a, nil);
	
		// Assert equal objects, add custom error description
		GHAssertEqualObjects(a, b, @"Foo should be equal to: %@. Something bad happened", bar);
	}

	- (void)testBar {
		// Another test
	}

	@end

Now you should be ready to Build and Run the test target.

You should see something similar to the following screen shots:

![gh-unit2](http://rel.me.s3.amazonaws.com/gh-unit/images/gh-unit2.jpg)

![gh-unit4](http://rel.me.s3.amazonaws.com/gh-unit/images/gh-unit4.jpg)

- Optionally, you can create and and set a prefix header (`Tests_Prefix.pch`) and add `#import <GHUnit/GHUnit.h>` to it, and then you won't have to include that import for every test.
- To embed GHUnit in your project (to use it without having to install in `/Library/Frameworks/`) see below.

## Adding a GHUnit Test Target (iPhone)

Coming soon!

![gh-unit-iphone1](https://rel.me.s3.amazonaws.com/gh-unit/images/gh-unit-iphone1.jpg)

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

## Embedding GHUnit in your project (Mac OS X)

- Copy GHUnit.framework into your project directory somewhere.
- Add a New Target. Select Cocoa Application. Name it 'Tests' (or something similar).
- Add an 'Existing Framework' and select GHUnit.framework from your project directory.
- Double check to make sure GHUnit.framework is a linked library in the test target info.
- Make your application or framework a direct dependency in the test target info. (This will cause your application or framework to build before the test target.)
- Add a New Build Phase | New Copy Files Build Phase to the test target.
	- Select Absolute Path (hidden in drop-down), and for the path enter: `$(TARGET_BUILD_DIR)`
- Create a test main. For example, create a file called TestsMain.m (or similar), that loads and runs the test application. (See above.)

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

## Notes

GHUnit was inspired by and uses parts of GTM (google-toolbox-for-mac) code, most from [UnitTesting](http://code.google.com/p/google-toolbox-for-mac/source/browse/trunk/UnitTesting/).
