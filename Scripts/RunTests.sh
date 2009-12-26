#!/bin/sh

# If we aren't running from the command line, then exit
if [ "$GHUNIT_CLI" = "" ]; then
  exit 0
fi

export DYLD_ROOT_PATH="$SDKROOT"
export DYLD_FRAMEWORK_PATH="$CONFIGURATION_BUILD_DIR"
export IPHONE_SIMULATOR_ROOT="$SDKROOT"

export MallocScribble=YES
export MallocPreScribble=YES
export MallocGuardEdges=YES
export MallocStackLogging=YES
export MallocStackLoggingNoCompact=YES

export NSDebugEnabled=YES
export NSZombieEnabled=YES
export NSDeallocateZombies=NO
export NSHangOnUncaughtException=YES
export NSAutoreleaseFreedObjectCheckEnabled=YES

"$TARGET_BUILD_DIR/$EXECUTABLE_PATH" -RegisterForSystemEvents
RETVAL=$?

exit $RETVAL
	


