
## Installing in iOS (Xcode 4)

To use GHUnit in your project, you'll need to create and configure a test target.

## Create Test Target

- You'll want to create a separate Test target. Select the project file for your app in the Project Navigator. From there, select the Add Target + symbol at the bottom of the window.

![Add Target](images/1_add_target.png)

- Select iOS, Application, Window-based Application. Select Next.

![Select Application](images/2_select_application.png)

- Name it Tests or something similar. Select Finish.

![Name it](images/3_name_it.png)


## Configure the Test Target

- Download and copy the GHUnitIOS.framework to your project. Command click on Frameworks in the Project Navigator and select: Add Files to "MyTestable". (This should automatically add GHUnitIOS.framework to your Link Binary With Libraries Build Phase for the Tests target.)

![Add Framework](images/6_add_framework.png)

- Select GHUnitIOS.framework and make sure the only the Tests target is selected.

![Add Framework Dialog](images/7_add_framework_dialog.png)

- We want to enable use of Objective-C categories, which isn't enabled for static libraries by default. In the Tests target, Build Settings, under Other Linker Flags, add -ObjC and -all_load.

![Other Linker Flags](images/8_other_linker_flags.png)

- Select and delete the files from the existing Tests folder. Leave the Supporting Files folder. GHUnit will provide the application delegate below.

![Remove Test Files](images/9_remove_test_files.png)

- In Tests folder, in Supporting Files, main.m, replace the last argument of UIApplicationMain with `@"GHUnitIOSAppDelegate"`. Remove the #import "AppDelegate.h" if present.

![Main Method](images/10_main.png)

- Select the Tests target, iPhone Simulator configuration:

![Select Target](images/11_select_target.png)

- Hit Run, and you'll hopefully see the test application running (but without any tests).

![Run It](images/12_running.png)

Now you can [create and run tests](guide_testing)!
