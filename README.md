# GHUnit

GHUnit is a test framework for Objective-C (Mac OS X 10.5 and iPhone 2.x/3.x).
It can be used with SenTestingKit, GTM or by itself. 

For example, your test cases will be run if they subclass any of the following:

- GHTestCase
- SenTestCase
- GTMTestCase

## Download

### Mac OS X

[GHUnit-0.4.11.zip](http://rel.me.s3.amazonaws.com/gh-unit/GHUnit-0.4.11.zip) *GHUnit.framework* (2009/10/04)

Note: If you are updating your framework, you should also update your `GHUnitTestMain.m`; It is not required though new features may not be included otherwise).

### iPhone OS 3.0 or above

[libGHUnitIPhone3_0-0.4.11.zip](http://rel.me.s3.amazonaws.com/gh-unit/libGHUnitIPhone3_0-0.4.11.zip) *iPhone Static Library for OS 3.0 or above (Device+Simulator)* (2009/10/04)

## Why?

The goals of GHUnit are:

- Runs unit tests within XCode, allowing you to fully utilize the XCode Debugger.
- Ability to run from Makefile's or the command line.
- A simple GUI to help you visualize your tests.
- Show stack traces.
- Be embeddable as a framework (using @rpath) for Mac OSX apps, or as a static library in your iPhone projects.

Future plans include:
- Mocks (maybe integrate OCMock?)

`GHTestCase` is the base class for your tests.

- Tests are defined by methods that start with `test`, take no arguments and return void. For example, `- (void)testFoo { }`
- Your setup and tear down methods are `- (void)setUp;` and `- (void)tearDown;`. 
- Your class setup and tear down methods are `- (void)setUpClass;` and `- (void)tearDownClass;`. 
- By default tests are run on a separate thread. For a UI test or to run on the main thread, implement:

    `- (BOOL)shouldRunOnMainThread { return YES; }`

## Group

For questions and discussions see the [GHUnit Google Group](http://groups.google.com/group/ghunit)

## Adding a GHUnit Test Target (Mac OS X)

There are two options. You can install it globally in /Library/Frameworks or with a little extra effort embed it with your project.

### Installing in /Library/Frameworks

- Copy `GHUnit.framework` to `/Library/Frameworks/`
- Add a `New Target`. Select `Cocoa -> Application`. Name it `Tests` (or something similar).
- In the `Target 'Tests' Info` window, `General` tab:
	- Add a linked library, under `Mac OS X 10.5 SDK` section, select `GHUnit.framework`
	- Add a linked library, select your project.
	- Add a direct dependency, and select your project. (This will cause your application or framework to build before the test target.)

- Copy [GHUnitTestMain.m](http://github.com/gabriel/gh-unit/tree/master/Classes-MacOSX/GHUnitTestMain.m) into your project and include in the Test target.
- Now create a test (either by subclassing `SenTestCase` or `GHTestCase`), adding it to your test target. (See example test case below.)

### Installing in your project

- Add a `New Target`. Select `Cocoa -> Application`. Name it `Tests` (or something similar).
- Copy `GHUnit.framework` to your project directory (maybe in MyProject/Frameworks/.)
- Add the `GHUnit.framekwork` files (from MyProject/Frameworks/) to the `Tests` target. It should be visible as a `Linked Framework` in the target. 
- Under Build Settings, add `@loader_path/../Frameworks` to `Runpath Search Paths` 
- Add `New Build Phase` | `New Copy Files Build Phase`. 
	- Change the Destination to `Frameworks`.
	- Drag `GHUnit.framework` into the the build phase
	- Make sure the copy phase appears before any `Run Script` phases 
- Copy [GHUnitTestMain.m](http://github.com/gabriel/gh-unit/tree/master/Classes-MacOSX/GHUnitTestMain.m) into your project and include in the Test target.
- Now create a test (either by subclassing `SenTestCase` or `GHTestCase`), adding it to your test target. (See example test case below.)

### Example test case (Mac OS X)

For example `MyTest.m`:

	#import <GHUnit/GHUnit.h>

	@interface MyTest : GHTestCase { }
	@end

	@implementation MyTest
	
	- (BOOL)shouldRunOnMainThread {
		// By default NO, but if you have a UI test or test dependent on running on the main thread return YES
	}
	
	- (void)setUpClass {
		// Run at start of all tests in the class
	}

	- (void)tearDownClass {
		// Run at end of all tests in the class
	}

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

You should see something like:

![GHUnit-0.4.1-expanded](http://rel.me.s3.amazonaws.com/gh-unit/images/GHUnit-0.4.1-expanded.jpg)
![GHUnit-0.4.1](http://rel.me.s3.amazonaws.com/gh-unit/images/GHUnit-0.4.1.jpg)

- Optionally, you can create and and set a prefix header (`Tests_Prefix.pch`) and add `#import <GHUnit/GHUnit.h>` to it, and then you won't have to include that import for every test.

## Adding a GHUnit Test Target (iPhone)

Frameworks and dynamic libraries are not supported in the iPhone environment, but you can use the libGHUnitIPhone.a static library.

- Add a `New Target`. Select `Cocoa Touch -> Application`. Name it `Tests` (or something similar).
- Add some frameworks to `Linked Libraries`
  - `CoreGraphics.framework`
  - `Foundation.framework`
  - `UIKit.framework`
  - `CoreLocation.framework` (optional)
- Include the GHUnit files (from the GHUnit/iPhone Static Library download above), in your `Test` target. These files should include:
	- libGHUnitIPhone.a (static library)
	- GHUnit header files
	- GHUnit test main
- Under 'Other Linker Flags' in the `Test` target, add `-ObjC` and `-all_load`  (`-all_load` may be necessary for running on 3.0 device)

Now you can create a test (either by subclassing `SenTestCase` or `GHTestCase`), adding it to your test target.

### Example test case (iPhone)

For example `MyTest.m`:

	#import "GHUnit.h"

	@interface MyTest : GHTestCase { }
	@end

	@implementation MyTest

	- (BOOL)shouldRunOnMainThread {
		// By default NO, but if you have a UI test or test dependent on running on the main thread return YES
	}
	
	- (void)setUpClass {
		// Run at start of all tests in the class
	}

	- (void)tearDownClass {
		// Run at end of all tests in the class
	}
	
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

You should see something like:

![GHUnit-0.4.1-iphone](http://rel.me.s3.amazonaws.com/gh-unit/images/GHUnit-0.4.1-iphone.jpg)

- Optionally, you can create and and set a prefix header (`Tests_Prefix.pch`) and add `#import "GHUnit.h"` to it, and then you won't have to include that import for every test.

An example of an iPhone project with GHUnit test setup can be found at: [MyTestable-IPhone](http://github.com/gabriel/gh-unit/tree/master/Examples/MyTestable-IPhone).

## Test Environment Variables for Debugging (Optional)

Go into the "Get Info" contextual menu of your (test) executable (inside the "Executables" group in the left panel of XCode). 
Then go in the "Arguments" tab. You can add the following environment variables:
	 

	Environment Variable:                 Default:  Set to:
	NSDebugEnabled                           NO       YES
	NSZombieEnabled	                         NO       YES
	NSDeallocateZombies                      NO       YES
	NSHangOnUncaughtException                NO       YES

	NSEnableAutoreleasePool                  YES      NO
	NSAutoreleaseFreedObjectCheckEnabled     NO       YES
	NSAutoreleaseHighWaterMark               0        non-negative integer
	NSAutoreleaseHighWaterResolution         0        non-negative integer
	
For more info on these varaiables see [NSDebug.h](http://theshadow.uw.hu/iPhoneSDKdoc/Foundation.framework/NSDebug.h.html)

For malloc debugging:

	MallocStackLogging
	MallocStackLoggingNoCompact
	MallocScribble
	MallocPreScribble
	MallocGuardEdges
	MallocDoNotProtectPrelude
	MallocDoNotProtectPostlude
	MallocCheckHeapStart
	MallocCheckHeapEach
	
For more info on these variables see [MallocDebug](http://developer.apple.com/mac/library/documentation/Performance/Conceptual/ManagingMemory/Articles/MallocDebug.html)

## Command Line

To run the tests from the command line:

- Copy the [RunTests.sh](http://github.com/gabriel/gh-unit/tree/master/Classes/RunTests.sh) file into your project directory (if you haven't already).
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
