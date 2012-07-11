## Running from the Command Line

To run the tests from the command line:

- Copy [RunTests.sh](http://github.com/gabriel/gh-unit/tree/master/Scripts/RunTests.sh) and [RunIPhoneSecurityd.sh](http://github.com/gabriel/gh-unit/tree/master/Scripts/RunIPhoneSecurityd.sh) into your project in the same directory as the xcodeproj file.

- In the Tests target, Build Phases, Select Add Build Phase + button, and select Add Run Script.

![Add Build Phase](images/cli_2_add_build_phase.png)

- For the script enter: `sh RunTests.sh`

![Configure Build Phase](images/cli_3_configure_phase.png)

The path to RunTests.sh should be relative to the xcode project file (.xcodeproj). You can uncheck 'Show environment variables in build log' if you want.

Now run the tests From the command line:

    // For iOS app
    GHUNIT_CLI=1 xcodebuild -target Tests -configuration Debug -sdk iphonesimulator build

    // For mac app
    GHUNIT_CLI=1 xcodebuild -target Tests -configuration Debug -sdk macosx build	

If you get and error like: `Couldn't register Tests with the bootstrap server.` it means an iPhone simulator is running and you need to close it.

### GHUNIT_CLI

The RunTests.sh script will only run the tests if the env variable GHUNIT_CLI is set. This is why this RunScript phase is ignored when running the test GUI. This is how we use a single Test target for both the GUI and command line testing.

This may seem strange that we run via xcodebuild with a RunScript phase in order to work on the command line, but otherwise we may not have the environment settings or other Xcode specific configuration right.

## Makefile

Follow the directions above for adding command line support.

Example Makefile's for Mac or iPhone apps:

- [Makefile (Mac OS X)](http://github.com/gabriel/gh-unit/tree/master/Project/Makefile.example)
- [Makefile (iOS)](http://github.com/gabriel/gh-unit/tree/master/Project-iOS/Makefile.example)

The script will return a non-zero exit code on test failure.

To run the tests via the Makefile:

    make test

## Running a Test Case

The `TEST` environment variable can be used to run a single test or test case.

    // Run all tests in GHSlowTest
    make test TEST="GHSlowTest"

    // Run the method testSlowA in GHSlowTest	
    make test TEST="GHSlowTest/testSlowA"

## GHUnit Environment Variables

- `TEST`: To run a specific test (from the command line). Use `TEST="GHSlowTest/testSlowA"` for a specific test or `TEST="GHSlowTest"` for a test case.
- `GHUNIT_RERAISE`: Default NO; If an exception is encountered it re-raises it allowing you to crash into the debugger
- `GHUNIT_AUTORUN`: Default NO; If YES, tests will start automatically
- `GHUNIT_AUTOEXIT`: Default NO; If YES, will exit upon test completion (no matter what). For command line MacOSX testing
- `GHUNIT_CLI`: Default NO; Specifies that the tests are being run from the command line. For command line MacOSX testing
- `WRITE_JUNIT_XML`: Default NO; Whether to write out JUnit XML output. For Jenkins CI integration
- `JUNIT_XML_DIR`: Default to temporary directory. Specify to have files written to a different directory. For Jenkins CI integration.

