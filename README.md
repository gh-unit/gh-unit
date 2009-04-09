# GHUnit

GHUnit is a test framework for Objective-C (Mac OS X 10.5 and iPhone 2.0 and above).
It can be used with SenTestingKit, GTM or by itself. 

For example, your test cases will be run if they subclass any of the following:

- GHTestCase
- SenTestCase
- GTMTestCase

## Download

[GHUnit-0.3.2.zip](http://rel.me.s3.amazonaws.com/gh-unit/GHUnit-0.3.2.zip) *GHUnit.framework* (2009/04/05)

[libGHUnitIPhone-0.3.3.zip](http://rel.me.s3.amazonaws.com/gh-unit/libGHUnitIPhone-0.3.3.zip) *iPhone Static Library* (2009/04/08)

## Why?

The goals of GHUnit are:

- Runs unit tests within XCode, allowing you to fully utilize the XCode Debugger.
- Ability to run from Makefile's or the command line.
- A simple GUI to help you visualize your tests.
- Show stack traces.
- Be installable as a framework (for Cocoa apps) with a simpler/more flexible target setup; or easy to package into your iPhone project.

`GHTestCase` is the base class for your tests.
Tests are defined by methods that start with 'test', take no arguments and return void. 
Your setup and tear down methods are `- (void)setUp;` and `- (void)tearDown;`. 
You know, pretty much like every test framework in existence.

## Group

For questions and discussions see the [GHUnit Google Group](http://groups.google.com/group/ghunit)

## Adding a GHUnit Test Target (Mac OS X)

To add `GHUnit.framework` to your project:

- Copy `GHUnit.framework` to `/Library/Frameworks/`
- Add a `New Target`. Select `Cocoa -> Application`. Name it `Tests` (or something similar).
- In the `Target 'Tests' Info` window, `General` tab:
	- Add a linked library, under `Mac OS X 10.5 SDK` section, select `GHUnit.framework`
	- Add a linked library, select your project.
	- Add a direct dependency, and select your project. (This will cause your application or framework to build before the test target.)

- Copy [GHUnitTestMain.m](http://github.com/gabriel/gh-unit/tree/master/Classes-MacOSX/GHUnitTestMain.m) into your project and include in the Test target.
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

![gh-unit4](http://rel.me.s3.amazonaws.com/gh-unit/images/gh-unit5.jpg)

![gh-unit2](http://rel.me.s3.amazonaws.com/gh-unit/images/gh-unit2.jpg)

- Optionally, you can create and and set a prefix header (`Tests_Prefix.pch`) and add `#import <GHUnit/GHUnit.h>` to it, and then you won't have to include that import for every test.
- To embed GHUnit in your project (to use it without having to install in `/Library/Frameworks/`) see below.

## Adding a GHUnit Test Target (iPhone)

Frameworks and dynamic libraries are not supported in the iPhone environment, but you can use the libGHUnitIPhone.a static library.

- Add a `New Target`. Select `Cocoa Touch -> Application`. Name it `Tests` (or something similar).
- Add `CoreGraphics.framework` to `Linked Libraries`
- Include the GHUnit files (from the GHUnit/iPhone Static Library download above), in your `Test` target. These files should include:
	- libGHUnitIPhone.a (static library)
	- GHUnit header files
	- GHUnit test main
- Under 'Other Linker Flags' in the `Test` target, add `-ObjC`

Now you can create a test (either by subclassing `SenTestCase` or `GHTestCase`) and add it to your test target.

For example `MyTest.m`:

	#import "GHUnit.h"

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

Now you should be ready to Build and Run the `Test` target.

You should see something similar to the following:

![gh-unit-iphone1](http://rel.me.s3.amazonaws.com/gh-unit/images/gh-unit-iphone1.jpg)

- Optionally, you can create and and set a prefix header (`Tests_Prefix.pch`) and add `#import "GHUnit.h"` to it, and then you won't have to include that import for every test.

An example of an iPhone project with GHUnit test setup can be found at: [MyTestable-IPhone](http://github.com/gabriel/gh-unit/tree/master/Examples/MyTestable-IPhone).

## Command Line

To run the tests from the command line:

- Copy the [RunTests.sh](http://github.com/gabriel/gh-unit/tree/master/Classes/RunTests.sh) file into your project directory.
- In XCode:
  - To the `Tests` target, Add | New Build Phase | New Run Script Build Phrase
  - Enter in the path to the RunTests.sh file. This path should be relative to the xcode project file (.xcodeproj)!
	- (Optional) Uncheck 'Show environment variables in build log'

From the command line, run the tests from xcodebuild (with the GHUNIT_CLI environment variable set) :

	// For mac app
	GHUNIT_CLI=1 xcodebuild -target Tests -configuration Debug -sdk macosx10.5 build	
	
	// For iPhone app
	GHUNIT_CLI=1 xcodebuild -target Tests -configuration Debug -sdk iphonesimulator2.2 build

If you are wondering, the `RunTests.sh` script will only run the tests if the env variable GHUNIT_CLI is set. 
This is why this RunScript phase is ignored when running the test GUI. This is how we use a single Test target for both the GUI and command line testing.

This may seem strange that we run via xcodebuild with a RunScript phase in order to work on the command line, but otherwise we may not have
the environment settings or other XCode specific configuration right.

## Makefile

Example Makefile's for Mac or iPhone apps:

- [Makefile](http://github.com/gabriel/gh-unit/tree/master/Project/Makefile) (for a Mac App)
- [Makefile](http://github.com/gabriel/gh-unit/tree/master/Project-IPhone/Makefile) (for an iPhone App)

The script will return a non-zero exit code on test failure.

To run the tests via the Makefile:

	make test

## Running a Test Case / Single Test

The `TEST` environment variable can be used to run a single test or test case.

	// Run all tests in GHSlowTest
	make test TEST="GHSlowTest"
	
	// Run the method testSlowA in GHSlowTest	
	make test TEST="GHSlowTest/testSlowA"

## Custom Test Case Classes

You can register additional classes at runtime; if you have your own. For example:

        [[GHTesting sharedInstance] registerClassName:@"MySpecialTestCase"];



## Test Macros
 
The following test macros are included. 

These macros are directly from: [GTMSenTestCase.h](http://code.google.com/p/google-toolbox-for-mac/source/browse/trunk/UnitTesting/GTMSenTestCase.h)
prefixed with GH so as not to conflict with the GTM macros if you are using those in your project.

The `description` argument appends extra information for when the assert fails; though most of the time you might leave it as nil.
 
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
