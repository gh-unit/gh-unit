# Release 0.4.29
- Changing paths to use iOS instead of iPhone
- Rebuilding iOS project using XCode 4

# Release 0.4.28
- Building as GHUnitIOS.framework for iOS.
- Fix issue #37
- Fix issue #38
- Fix issue #39
- Fix issue #36
- Fix issue #19

# Release 0.4.27
- Added in GHUnitIOSAppDelegate for subclassing test app delegate

# Release 0.4.26
- Fixing LLVM/clang warnings (Whitney Young, nolanw)
- GHAssertNotEqualStrings will allow for nils (Rusty Zarse)
- Build warnings under 10.6 (MacOSX); (zykloid)
- Better error handling on JUnit XML results writing (zykloid)
- GHAsyncTestCase#runForInterval (Adapted from Robert Palmer, pauseForTimeout)

# Release 0.4.25
- Set DEPLOYMENT_POSTPROCESSING (MacOSX); So breakpointing doesn't warn about missing symbols

# Release 0.4.24
- Moved build settings into xcconfig (MacOSX)
- Striping linked build

# Release 0.4.21
- Moved build settings into xcconfig (iPhone)
- Flexible layouts; Works in iPad as universal app

# Release 0.4.20
- Fix armv6/armv7 device build setting

# Release 0.4.19
- Fix autorun env on iPhone
- Added re-run test (experimental!)
- Test log viewer (iPhone)
- Showing time in tests vs time running

# Release 0.4.18
- Fixing test stats on parallel running
- Adding reraiseException options (MacOSX)
- Adding env var support for reraise and autorun (see README)
- Smaller font size for test view (iPhone)
- Show filename/line number in trace on failure
- Show link to exception filename on failure (MacOSX)
- Fix bug where test trace/log doesn't update if selected before running

# Release 0.4.17
- Fixing disabled on new test bug
- Fixing bugs with All/Failed/Edit views not showing tests properly (MacOSX)

# Release 0.4.16
- Fixing hidden tests bug

# Release 0.4.15
- Text filter (MacOSX)
- Text filter now searches test case and test names (prefix)
- Failed filter (MacOSX/iPhone)
- Copy text in text view (MacOSX)
- Remember test state

# Release 0.4.14
- Fix window resizing when showing details
- Adding test for 0 found test cases

# Release 0.4.13
- Fixing framework build: Header error and 32/64 bit universal (MacOSX)
- Fixing SenTest macros not failing correctly
- Fixing persist of test enabled/disabled state
- Fixing SenTest macros

# Release 0.4.12
- Fixing compile warning in main (iPhone)

# Release 0.4.11
- Added value formatter (from http://github.com/JohannesRudolph); For better Assert error messages.
- Fixed deprecation warning (iPhone)
- Added default exception handler to give stack trace if triggered outside of GHUnit run

# Release 0.4.10
- Added Search Bar
- Added GHTestSuite#suiteWithPrefix:options

# Release 0.4.9
- Fix compile warning

# Release 0.4.8
- Fix bug with turning Parallel off not working
- Building 32/64 bit universal

# Release 0.4.7
- Removing redirect, was a bad idea; Test output goes to stderr, you can redirect stdout yourself

# Release 0.4.6
- Redirecting test output to file
- Test output does OK/FAIL
- Disabled tests appear gray (MacOSX)
- UI fixes

# Release 0.4.5 (2008-07-21)
- Including GHUnitIOSAppDelegate so you can subclass and interact with UIApplication delegate in tests

# Release 0.4.4 (2008-07-20)
- Ignore disable/cancelled tests in scroll (iPhone)
- Only start group test (notify) if we have tests to run

# Release 0.4.3 (2008-07-20)
- When running test on main thread should wait until finished
- Auto scrolls to middle instead of bottom (iPhone)

# Release 0.4.2 (2008-07-19)
- Fixing run warning

# Release 0.4.1 (2008-07-18)
- Option to use NSOperationQueue to manage tests runs
- Updated how test groups run
- Handling failure in setUpClass/tearDownClass
- Updated how shouldRunOnMainThread works
- Added Edit UI for Mac OSX tests
- Bug fixes and other refactoring

# Release 0.3.19 (2008-06-15)
- Fixed bug in Edit->Save crash (iPhone)
- Tweaking test text color (iPhone)
- Re-run crash
- Added reset to GHTest protocol
- Added testDidUpdate: to GHTestDelegate protocol
- On Edit->Save, triggers reset
- Added cancel to GHTest protocol
- Added cancelling, cancelled enums to test status
- Changed testDidFinish to testDidEnd (since test may be cancelled)

# Release 0.3.18 (2008-06-15)
- Adding Run button; By default tests do not automatically run on start
- Added AutoRun setting

# Release 0.3.17 (2008-06-09)
- Updating RunTests.sh

# Release 0.3.16 (2008-06-09)
- Rebuilding from 3.0 GM
- Setting debug variables in main directly instead of from setenv (which doesn't seem to work)

# Release 0.3.14 (2008-06-08)
- Creating separate iPhone 3.0 builds

# Release 0.3.12 (2008-05-25)
- Creating iPhone static library with device and simulator platforms

# Release 0.3.11 (2008-05-20)
- Fixing version number
- Creating separate version with CoreLocation linked

# Release 0.3.10 (2008-05-20)
- Fix namespace issue

# Release 0.3.9 (2008-05-19)

## 2008-05-19
- 3.0 compatibility fixes
- Added GHUITestCase
- Added shouldRunOnMainThread to test case, and if present and YES will run the tests on the main thread

## 2008-05-05
- (iPhone) Added select/deselect to iPhone test UI
- (iPhone) Fixed auto-scroll if you manually scroll (will stop auto-scrolling)

# Release 0.3.8 (2008-04-28)

## 2008-04-28
- Removed button enabled cell from Mac OS X view; Makes NSOutlineView really slow; Need to figure out how to do it right

# Release 0.3.7 (2008-04-26)

## 2008-04-20
- CLLocationManager mock
- Fixed afterDelay not using delay value
- Select/unselect (ignore) tests in Mac OSX view
- Added initWithTestSuite to GHTestApp for custom suites from test main

## 2008-04-16
- Adding ability to set run loops in async test case
- Adding more methods to NSURLConnection mock

# Release 0.3.6 (2008-04-13)

## 2008-04-13
- Adding swizzle methods for mocking
- Adding NSLocale mock
- Adding NSURLConnection, NSHTTPURLResponse mocks
- Fix bug with setUpClass/tearDownClass not working for single command line tests
- Setting Installation Directory to @rpath (Thanks chapados), so you can embed the framework with your app
- Sorting tests by class name (as well as method name)

# Release 0.3.4 (2009-04-11)

## 2008-04-11
- Added Doxygen support

## 2008-04-08
- Added GHAsyncTestCase for asynchronous tests (seems really complex :/, might have gone mental on it)
- Supporting streaming logging with GHTestLog(...)
- GHUNIT_VERSION from xcconfig in Info plists and shown in test GUI
- Mocks for NSURLConnection and NSHTTPURLResponse
- Added setUpClass/tearDownClass for GHTestCase
- Added currentSelector property for GHTestCase

# Release 0.3.3 (2009-04-08)

## 2009-04-08
- Removed GTMLogger and GHLogger; Not used in Release and potentially can 
  conflict with project logging with iPhone static library

# Release 0.3.2 (2009-04-05)

## 2009-04-05
- Building as static library for iPhone
- Adding in support for running single test case or test

# Release 0.3.1

## 2009-03-22
- Renamed TEST_CLI to GHUNIT_CLI
- Removing main from target; Projects should specify their own test target main.
- Added test for special registered test case classes

## 2009-03-21
- Renamed Examples/MyTestable to MyTestable-IPhone

## 2009-03-19
- Commented a bunch of the code
- Renamed GHTestUtils to GHTesting


