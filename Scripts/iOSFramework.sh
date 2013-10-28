# Original Script by  Pete Goodliffe
# from http://accu.org/index.php/journals/1594

# Modified by Juan Batiz-Benet to fit GHUnit
# Modified by Gabriel Handford for GHUnit

set -e

# Define these to suit your nefarious purposes
                 FRAMEWORK_NAME=GHUnitIOS
                       LIB_NAME=libGHUnitIOS
              FRAMEWORK_VERSION=A
                     BUILD_TYPE=Release

# Where we'll put the build framework.
# The script presumes we're in the project root
# directory. Xcode builds in "build" by default
FRAMEWORK_BUILD_PATH="build/Framework"

# Clean any existing framework that might be there
# already
echo "INFO: Framework: Cleaning framework..."
[ -d "$FRAMEWORK_BUILD_PATH" ] && \
  rm -rf "$FRAMEWORK_BUILD_PATH"

# This is the full name of the framework we'll
# build
FRAMEWORK_DIR=$FRAMEWORK_BUILD_PATH/$FRAMEWORK_NAME.framework

# Build the canonical Framework bundle directory
# structure
echo "INFO: Framework: Setting up directories..."
mkdir -p $FRAMEWORK_DIR
mkdir -p $FRAMEWORK_DIR/Versions
mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION
mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION/Resources
mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION/Headers

echo "INFO: Framework: Creating symlinks..."
ln -s $FRAMEWORK_VERSION $FRAMEWORK_DIR/Versions/Current
ln -s Versions/Current/Headers $FRAMEWORK_DIR/Headers
ln -s Versions/Current/Resources $FRAMEWORK_DIR/Resources
ln -s Versions/Current/$FRAMEWORK_NAME $FRAMEWORK_DIR/$FRAMEWORK_NAME

# i am not sure where LIB_NAME comes from
#ARM_FILES="${BUILD_DIR}/$BUILD_TYPE-iphoneos/${LIB_NAME}Device.a"
#I386_FILES="{BUILD_DIR}/$BUILD_TYPE-iphonesimulator/${LIB_NAME}Simulator.a"


BUILD_ARM7="${BUILD_DIR}/build-arm7/${LIB_NAME}Device.a"
BUILD_ARM7s="${BUILD_DIR}/build-arm7s/${LIB_NAME}Device.a"
BUILD_ARM_64="${BUILD_DIR}/build-arm64/${LIB_NAME}Device.a"
BUILD_i386="${BUILD_DIR}/build-i386/${LIB_NAME}Simulator.a"
BUILD_x86_64="${BUILD_DIR}/build-x86_64/${LIB_NAME}Simulator.a"

echo "INFO: making static library from:"
echo "INFO:    arm7 ${BUILD_ARM7}"
echo "INFO:   arm7s ${BUILD_ARM7s}"
echo "INFO:   arm64 ${BUILD_ARM_64}"
echo "INFO:    i386 ${BUILD_i386}"

# The trick for creating a fully usable library is to use lipo to glue 
# the different library versions together into one file. When an 
# application is linked to this library, the linker will extract the 
# appropriate platform version and use that. The library file is given 
# the same name as the framework with no .a extension.
echo "INFO: Framework: Creating library..."

# Combine lib files
# *** UNEXPECTED ****
# it pays to be pedantic about specifying the arch because
# if you have a typo in a variable (eg. BUILD_i386 vs BUILD_i368)
# lipo will not tell you about it and your framework/library
# will not include the architecture
#
# use xcrun to help lipo identify arm64
# *******************

xcrun lipo -create \
  -arch armv7 ${BUILD_ARM7} \
  -arch armv7s ${BUILD_ARM7s} \
  -arch arm64 ${BUILD_ARM_64} \
  -arch i386 ${BUILD_i386} \
  -o "$FRAMEWORK_DIR/Versions/Current/$FRAMEWORK_NAME"
 
# Now copy the final assets over: your library
# header files and the plist file
echo "INFO: Framework: Copying assets into current version..."
cp ../Classes/*.h $FRAMEWORK_DIR/Headers/
cp ../Classes/Mock/*.h $FRAMEWORK_DIR/Headers/
cp ../Classes/GHTest/*.h $FRAMEWORK_DIR/Headers/
cp ../Classes/SharedUI/*.h $FRAMEWORK_DIR/Headers/
cp ../Classes-iOS/*.h $FRAMEWORK_DIR/Headers/
cp ../Classes/Mock/*.h $FRAMEWORK_DIR/Headers/
cp Framework.plist $FRAMEWORK_DIR/Resources/Info.plist

echo "INFO: The framework was built at: $FRAMEWORK_DIR"
SLICES=`xcrun lipo -info "$FRAMEWORK_DIR/Versions/Current/$FRAMEWORK_NAME"`
echo "INFO: ${SLICES}" 
echo ""
open "$FRAMEWORK_BUILD_PATH"

