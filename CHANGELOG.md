# Release 0.3.4 (TBD)

## 2008-04-08
- Added GHAsyncTestCase for asynchronous tests (seems really complex :/, might have gone mental on it)
- Supporting streaming logging with GHTestLog(...)
- GHUNIT_VERSION from xcconfig in Info plists and shown in test GUI
- Mocks for NSURLConnection and NSHTTPURLResponse
- Added setUpClass/tearDownClass for GHTestCase
- Added currentSelector property for GHTestCase

# Release 0.3.3 (2009/04/08)

## 2008-04-08
- Removed GTMLogger and GHLogger; Not used in Release and potentially can 
  conflict with project logging with iPhone static library

# Release 0.3.2 (2009/04/05)

## 2008-04-05
- Building as static library for iPhone
- Adding in support for running single test case or test

# Release 0.3.1

## 2008-03-22
- Renamed TEST_CLI to GHUNIT_CLI
- Removing main from target; Projects should specify their own test target main.
- Added test for special registered test case classes

## 2008-03-21
- Renamed Examples/MyTestable to MyTestable-IPhone

## 2008-03-19
- Commented a bunch of the code
- Renamed GHTestUtils to GHTesting


