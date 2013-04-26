#!/bin/sh

# If we aren't running from the command line, then exit
if [ "$GHUNIT_CLI" = "" ] && [ "$GHUNIT_AUTORUN" = "" ]; then
  exit 0
fi

export DYLD_ROOT_PATH="$SDKROOT"
export DYLD_FRAMEWORK_PATH="$CONFIGURATION_BUILD_DIR"
export IPHONE_SIMULATOR_ROOT="$SDKROOT"
#export CFFIXED_USER_HOME="$TEMP_FILES_DIR/iPhone Simulator User Dir" # Be compatible with google-toolbox-for-mac

#if [ -d $"CFFIXED_USER_HOME" ]; then
#  rm -rf "$CFFIXED_USER_HOME"
#fi
#mkdir -p "$CFFIXED_USER_HOME"

export NSDebugEnabled=YES
export NSZombieEnabled=YES
export NSDeallocateZombies=NO
export NSHangOnUncaughtException=YES
export NSAutoreleaseFreedObjectCheckEnabled=YES

export DYLD_FRAMEWORK_PATH="$CONFIGURATION_BUILD_DIR"

TEST_TARGET_EXECUTABLE_PATH="$TARGET_BUILD_DIR/$EXECUTABLE_PATH"

if [ ! -e "$TEST_TARGET_EXECUTABLE_PATH" ]; then
  echo ""
  echo "  ------------------------------------------------------------------------"
  echo "  Missing executable path: "
  echo "     $TEST_TARGET_EXECUTABLE_PATH."
  echo "  The product may have failed to build or could have an old xcodebuild in your path (from 3.x instead of 4.x)."
  echo "  ------------------------------------------------------------------------"
  echo ""
  exit 1
fi

# If trapping fails, make sure we kill any running securityd
launchctl list | grep GHUNIT_RunIPhoneSecurityd && launchctl remove GHUNIT_RunIPhoneSecurityd
SCRIPTS_PATH=`cd $(dirname $0); pwd`
launchctl submit -l GHUNIT_RunIPhoneSecurityd -- "$SCRIPTS_PATH"/RunIPhoneSecurityd.sh $IPHONE_SIMULATOR_ROOT $CFFIXED_USER_HOME
trap "launchctl remove GHUNIT_RunIPhoneSecurityd" EXIT TERM INT

RUN_CMD="\"$TEST_TARGET_EXECUTABLE_PATH\" -RegisterForSystemEvents"

echo "Running: $RUN_CMD"
set +o errexit # Disable exiting on error so script continues if tests fail
eval $RUN_CMD
RETVAL=$?
set -o errexit

unset DYLD_ROOT_PATH
unset DYLD_FRAMEWORK_PATH
unset IPHONE_SIMULATOR_ROOT

if [ -n "$WRITE_JUNIT_XML" ]; then
  MY_TMPDIR=`/usr/bin/getconf DARWIN_USER_TEMP_DIR`
  RESULTS_DIR="${MY_TMPDIR}test-results"

  if [ -d "$RESULTS_DIR" ]; then
	`$CP -r "$RESULTS_DIR" "$BUILD_DIR" && rm -r "$RESULTS_DIR"`
  fi
fi

exit $RETVAL
