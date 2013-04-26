
## Create a Test

- Command click on the Tests folder and select: New File...
- Select Objective-C class (iOS, Cocoa Touch or Mac OS X, Cocoa) and select Next. Leave the default subclass and select Next again.
- Name the file MyTest.m and make sure its enabled only for the "Tests" target.
- Delete the MyTest.h file and update the MyTest.m file.

        #import <GHUnitIOS/GHUnit.h> 

        @interface MyTest : GHTestCase { }
        @end

        @implementation MyTest

        - (void)testStrings {       
          NSString *string1 = @"a string";
          GHTestLog(@"I can log to the GHUnit test console: %@", string1);

          // Assert string1 is not NULL, with no custom error description
          GHAssertNotNULL(string1, nil);

          // Assert equal objects, add custom error description
          NSString *string2 = @"a string";
          GHAssertEqualObjects(string1, string2, @"A custom error message. string1 should be equal to: %@.", string2);
        }

        @end


![Add Test](images/13_adding_test.png)

- Now run the "Tests" target. Hit the Run button in the top right.

![Running Test](images/14_running_with_test.png)

## Examples

ExampleTest.m:

    // For iOS
    #import <GHUnitIOS/GHUnit.h> 
    // For Mac OS X
    //#import <GHUnit/GHUnit.h>

    @interface ExampleTest : GHTestCase { }
    @end

    @implementation ExampleTest

    - (BOOL)shouldRunOnMainThread {
      // By default NO, but if you have a UI test or test dependent on running on the main thread return YES.
      // Also an async test that calls back on the main thread, you'll probably want to return YES.
      return NO;
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
      NSString *a = @"foo";
      GHTestLog(@"I can log to the GHUnit test console: %@", a);

      // Assert a is not NULL, with no custom error description
      GHAssertNotNULL(a, nil);

      // Assert equal objects, add custom error description
      NSString *b = @"bar";
      GHAssertEqualObjects(a, b, @"A custom error message. a should be equal to: %@.", b);
    }

    - (void)testBar {
      // Another test
    }

    @end


ExampleAsyncTest.m:

    // For iOS
    #import <GHUnitIOS/GHUnit.h> 
    // For Mac OS X
    //#import <GHUnit/GHUnit.h> 

    @interface ExampleAsyncTest : GHAsyncTestCase { }
    @end

    @implementation ExampleAsyncTest
 
    - (void)testURLConnection {
  
      // Call prepare to setup the asynchronous action.
      // This helps in cases where the action is synchronous and the
      // action occurs before the wait is actually called.
      [self prepare];

      NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
      NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];

      // Wait until notify called for timeout (seconds); If notify is not called with kGHUnitWaitStatusSuccess then
      // we will throw an error.
      [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];

      [connection release];
    }

    - (void)connectionDidFinishLoading:(NSURLConnection *)connection {
      // Notify of success, specifying the method where wait is called.
      // This prevents stray notifies from affecting other tests.
      [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testURLConnection)];
    }

    - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
      // Notify of connection failure
      [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testURLConnection)];
    }

    - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
      GHTestLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    } 

    @end

Example projects can be found at: http://github.com/gabriel/gh-unit/tree/master/Examples/

## Assert Macros

The following test macros are included. 
 
These macros are directly from: [GTMSenTestCase.h](http://code.google.com/p/google-toolbox-for-mac/source/browse/trunk/UnitTesting/GTMSenTestCase.h)
prefixed with GH so as not to conflict with the GTM macros if you are using those in your project.

The description argument appends extra information for when the assert fails; though most of the time you might leave it as nil.
 
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


## Custom Test Case Classes

You can register additional classes at runtime; if you have your own. For example:

    [[GHTesting sharedInstance] registerClassName:@"MySpecialTestCase"];

## Using an Alternate (Test) iOS Application Delegate

If you want to use a custom application delegate in your test environment, you should subclass GHUnitIOSAppDelegate:

     @interface MyTestApplicationDelegate : GHUnitIOSAppDelegate { }
     @end

Then in main.m (or GHUnitIOSTestMain.m):

    int retVal = UIApplicationMain(argc, argv, nil, @"MyTestApplicationDelegate");

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

