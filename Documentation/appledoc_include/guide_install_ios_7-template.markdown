## Installing in iOS (Xcode 5)

To use GHUnit in your project, you'll need to create and configure a test target.

## Create Test Target

- You'll want to create a separate Test target. Select the project file for your app in the Project Navigator. From there, select the "Add Target..." button in the right window.

![Add Target](images/1_add_target_xcode5.png)

- Select iOS, Application, Empty Application. Select Next.

![Select Application](images/2_select_application_xcode5.png)

- Name it Tests or something similar. Select Finish.

![Name it](images/3_name_it_xcode5.png)


## Configure the Test Target

- Select the created Test target and select the tab "Build Phases". Open the "Link Binary With Libraries" option and click on the "+" button. 

![Add QuartzCore](images/4_add_framework_quartzcore.png)

- Select `QuartzCore.framework` and click "Add".

- Download [GHUnitIOS.framework](https://github.com/gh-unit/gh-unit/releases) and unzip it in your Test Target directory (a subdirectory of your project directory). 

- Select the created Test target and select the tab "Build Phases". Open the "Link Binary With Libraries" option and click on the "+" button. 

![Add Framework](images/6_add_framework_xcode5.png)

- Click "Add Other...".

![Add Framework Dialog](images/7_add_framework_dialog_xcode5.png)

- Select the `GHUnitIOS.framework` from your Test Target directory.

- We want to enable use of Objective-C categories, which isn't enabled for static libraries by default. In the Tests target, Build Settings, under Other Linker Flags, add `-ObjC`.

![Other Linker Flags](images/8_other_linker_flags_xcode5.png)

- Select and delete the files from the existing Tests folder. Leave the Supporting Files folder. GHUnit will provide the application delegate below.

![Remove Test Files](images/9_remove_test_files_xcode5.png)

- In Tests folder, in Supporting Files, main.m, replace the last argument of UIApplicationMain with `@"GHUnitIOSAppDelegate"`. Remove the `#import "AppDelegate.h"` if present.

![Main Method](images/10_main_xcode5.png)

- Select the Tests target, iPhone Simulator configuration:

![Select Target](images/11_select_target_xcode5.png)

- Hit Run, and you'll hopefully see the test application running (but without any tests).

![Run It](images/12_running_xcode5.png)

Now you can [create and run tests](guide_testing)!
