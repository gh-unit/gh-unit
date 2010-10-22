# GHUnit

GHUnit is a test framework for Objective-C (Mac OS X 10.5 and above and iPhone 3.x and above).
It can be used with SenTestingKit, GTM or all by itself. 

For example, your test cases will be run if they subclass any of the following:

- GHTestCase
- SenTestCase
- GTMTestCase

The goals of GHUnit are:

- Runs unit tests, allowing you to breakpoint and interact with the XCode Debugger.
- Ability to run from Makefile's or the command line.
- Run tests in parallel.
- Allow testing of UI components.
- View metrics; Search and filter tests; View logging by test case.
- Show stack traces and useful debugging information.
- Be embeddable as a framework (using @rpath) for Mac OSX apps, or as a static library in your iPhone projects.

Future plans include:

- Mocks (maybe integrate OCMock?)

## Documentation

For documentation see [http://gabriel.github.com/gh-unit/](http://gabriel.github.com/gh-unit/)

## Group

For questions and discussions see the [GHUnit Google Group](http://groups.google.com/group/ghunit)


