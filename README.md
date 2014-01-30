# GHUnit [![Build Status](https://travis-ci.org/gh-unit/gh-unit.png)](https://travis-ci.org/gh-unit/gh-unit) [![Cocoa Pod](https://cocoapod-badges.herokuapp.com/v/GHUnit/badge.png)](http://gh-unit.github.io/gh-unit/) [![Cocoa Pod](https://cocoapod-badges.herokuapp.com/p/GHUnit/badge.png)](http://gh-unit.github.io/gh-unit/) [![License](https://go-shields.herokuapp.com/license-MIT-blue.png)](http://opensource.org/licenses/MIT)

GHUnit is a test framework for Mac OS X and iOS.
It can be used standalone or with other testing frameworks like SenTestingKit or GTM.

## Features

- Run tests, breakpoint and interact directly with the XCode Debugger.
- Run from the command line or via a Makefile.
- Run tests in parallel.
- Allow testing of UI components.
- Capture and display test metrics.
- Search and filter tests by keywords.
- View logging by test case.
- Show stack traces and useful debugging information.
- Include as a framework in your projects
- Determine whether views have changed (UI verification)
- Quickly approve and record view changes
- View image diff to see where views have changed

## Install (iOS)

### Install the GHUnit gem

```xml
$ gem install ghunit
```

### Install the Tests target

This will edit your ProjectName.xcodeproj file and create a Tests target, scheme, and a sample test file.

```xml
$ ghunit install -n ProjectName
```

### Add the Tests target to your Podfile

1. Create a new file named `Podfile` in the directory that contains the your `.xcodeproj` file, or edit it if it already exists.

```ruby
# Podfile
platform :ios, '6.0'

target :Tests do
	pod 'GHUnit', '~> 0.5.9'
end
```

2. Install your project's pods. CocoaPods will then download and configure the required libraries for your project:
```xml
$ pod install
```

3. You should use the `.xcworkspace` file to work on your project:
```xml
$ open myproject.xcworkspace
```

### Install Command Line

```xml
$ ghunit install_cli -n ProjectName
```

Install ios-sim using homebrew:

```xml
$ brew install ios-sim
```

Now you can run tests from the command line:

```xml
$ ghunit run -n ProjectName
```

## Install (From Source)

### iOS
```bash
cd Project-iOS && make
```

Add the `GHUnitIOS.framework` to your project

### OS X
```bash
cd Project-MacOSX && make
```
Add the `GHUnit.framework` to your project

## Documentation

- [How to install, create and run tests](http://gh-unit.github.io/gh-unit/docs/index.html)
- [Online documentation](http://gh-unit.github.io/gh-unit/)
- [Google Group (Deprecated - Use Github Issues instead)](http://groups.google.com/group/ghunit)

## iOS

![GHUnit-IPhone-0.5.8](https://raw.github.com/gh-unit/gh-unit/master/Documentation/images/ios.png)

## Mac OS X

![GHUnit-0.5.8](https://raw.github.com/gh-unit/gh-unit/master/Documentation/images/macosx01.png)

