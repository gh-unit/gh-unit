# GHUnit

GHUnit is a test framework for Objective-C. Its meant to be a simpler alternative (to SenTest), target 10.5 (and iPhone 2.0) and above.
GHUnit uses lots of GTM (google-toolbox-for-mac) code, specifically from the [UnitTesting](http://code.google.com/p/google-toolbox-for-mac/source/browse/trunk/UnitTesting/) parts, 
which is a great alternative as well.

The goals of GHUnit are:

- Runs unit tests within XCode, allowing you to crash into the XCode Debugger.
- A simple GUI to help you visualize your tests, back traces, improve your testing flow. (Maybe even auto-test.)
- Be installable as a framework (for Cocoa apps) with a simple target setup; or easy to package into your iPhone project.

`GHTestCase` is the base class for your tests.

Tests are defined by methods that start with 'test', take no arguments and return void. 

Your setup and tear down methods are `- (void)setUp;` and `- (void)tearDown;`. 

You know, pretty much like every test framework in existance.

## A Test Case
 
For example,
 
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
 
The following test macros are included. They are the same or similar to SenTest macros (STAssertTrue, etc), except
that they start with GH. The `description` arg appends extra information for when the assert fails; though most of the time
you might leave it as nil.
 
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
