
## Installing in iOS (Xcode 3)

To use GHUnit in your project, you'll need to create and configure a test target.

- Add a `New Target`. Select `iOS -> Application`. Name it `Tests` (or something similar).
- Copy and add `GHUnitIOS.framework` into your project: Add Files to ..., select `GHUnitIOS.framework`, and select the `Tests` target.
- Add the following frameworks to `Linked Libraries`:
   - `GHUnitIOS.framework`
   - `CoreGraphics.framework`
   - `Foundation.framework`
   - `UIKit.framework`
- In Build Settings, under 'Framework Search Paths' make sure the (parent) directory to GHUnitIOS.framework is listed.
- In Build Settings, under 'Other Linker Flags' in the `Tests` target, add `-ObjC` and `-all_load`
- By default, the Tests-Info.plist file includes `MainWindow` for `Main nib file base name`. You should clear this field.
- Add the [GHUnitIOSTestMain.m](http://github.com/gabriel/gh-unit/blob/master/Project-iOS/GHUnitIOSTestMain.m) file into your project and make sure its enabled for the "Tests" target.
- (Optional) Create and and set a prefix header (`Tests_Prefix.pch`) and add `#import <GHUnitIOS/GHUnit.h>` to it, and then you won't have to include that import for every test.
- Now you can [create and run tests](guide_testing.html)!



## Installing in Mac OS X (Xcode 3)

To use GHUnit in your project, you'll need to create and configure a test target.

- Add a `New Target`. Select `Cocoa -> Application`. Name it `Tests` (or something similar).
- In the Finder, copy `GHUnit.framework` to your project directory (maybe in MyProject/Frameworks/.)
- In the `Tests` target, add the `GHUnit.framework` files (from MyProject/Frameworks/). It should now be visible as a `Linked Framework` in the target. 
- In the `Tests` target, under Build Settings, add `@loader_path/../Frameworks` to `Runpath Search Paths` (Under All Configurations)
- In the `Tests` target, add `New Build Phase` | `New Copy Files Build Phase`. 
   - Change the Destination to `Frameworks`.
   - Drag `GHUnit.framework` into the the build phase
   - Make sure the copy phase appears before any `Run Script` phases 
- Copy [GHUnitTestMain.m](http://github.com/gabriel/gh-unit/tree/master/Classes-MacOSX/GHUnitTestMain.m) into your project and include in the Test target.

- If your main target is a library: 
   - In the `Target 'Tests' Info` window, `General` tab: 
       - Add a linked library, and select your main target; This is so you can link your test target against your main target, and then you don't have to manually include source files in both targets.
- If your main target is an application, you will need to include these source files to the `Test` project manually.

- Now create a test (either by subclassing `SenTestCase` or `GHTestCase`), adding it to your test target. (See example test case below.)
- By default, the Tests-Info.plist file includes `MainWindow` for `Main nib file base name`. You should clear this field.
- Now you can [create and run tests](guide_testing.html)!