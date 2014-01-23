
## Installing in Mac OS X (Xcode 4)

To use GHUnit in your project, you'll need to create and configure a test target.

- Add a `New Target`. Select `Application -> Cocoa Application`. Name it `Tests` (or something similar).
 - Copy and add `GHUnit.framework` into your project: Add Files to 'App'..., select `GHUnit.framework`, and select only the "Tests" target.
 - In the "Tests" target, in Build Settings, add `@loader_path/../Frameworks` to `Runpath Search Paths`.
 - In the "Tests" target, in Build Phases, select `Add Build Phase` and then `Add Copy Files`. 
    - Change the Destination to `Frameworks`.
    - Drag `GHUnit.framework` from the project file view into the the Copy Files build phase.
    - Make sure the copy phase appears before any `Run Script` phases.
- Copy [GHUnitTestMain.m](http://github.com/gabriel/gh-unit/tree/master/Classes-MacOSX/GHUnitTestMain.m) into your project and include in the Test target. You should delete the existing main.m file (or replace the contents of the existing main.m with GHUnitTestMain.m).
- By default, the Tests-Info.plist file includes `MainMenu` for `Main nib file base name`. You should clear this field. You can also delete the existing MainMenu.xib and files like TestsAppDelegate.*.
- Now you can [create and run tests](guide_testing)!