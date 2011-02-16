#!/bin/sh

# If we aren't running from the command line, then exit
if [ "$GHUNIT_CLI" = "" ] && [ "$GHUNIT_AUTORUN" = "" ]; then
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

export DYLD_FRAMEWORK_PATH="$CONFIGURATION_BUILD_DIR"
RUN_CMD="$TARGET_BUILD_DIR/$EXECUTABLE_PATH"

echo "Running: $RUN_CMD"
$RUN_CMD -RegisterForSystemEvents
RETVAL=$?

unset DYLD_ROOT_PATH
unset DYLD_FRAMEWORK_PATH
unset IPHONE_SIMULATOR_ROOT

if [ -n "$WRITE_JUNIT_XML" ]; then
  MY_TMPDIR=`/usr/bin/getconf DARWIN_USER_TEMP_DIR`
  RESULTS_DIR="${MY_TMPDIR}test-results"

  if [ -d "$RESULTS_DIR" ]; then
	`cp -r "$RESULTS_DIR" "$BUILD_DIR" && rm -r "$RESULTS_DIR/"`
  fi
fi

exit $RETVAL
