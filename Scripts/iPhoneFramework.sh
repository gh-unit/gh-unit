# Original Script by  Pete Goodliffe
# from http://accu.org/index.php/journals/1594

# Modified by Juan Batiz-Benet to fit GHUnitIPhone

# Should define FLAVOR=2_1,2_1CL,3_0,3_0CL
# Define these to suit your nefarious purposes
                 FRAMEWORK_NAME=GHUnitIPhone${FLAVOR}
                       LIB_NAME=libGHUnitIPhone
              FRAMEWORK_VERSION=A
      FRAMEWORK_CURRENT_VERSION=${FLAVOR}
FRAMEWORK_COMPATIBILITY_VERSION=${FLAVOR}
                     BUILD_TYPE=Release

# Where we'll put the build framework.
# The script presumes we're in the project root
# directory. Xcode builds in "build" by default
FRAMEWORK_BUILD_PATH="build/Framework"

# Clean any existing framework that might be there
# already
echo "Framework: Cleaning framework..."
[ -d "$FRAMEWORK_BUILD_PATH" ] && \
  rm -rf "$FRAMEWORK_BUILD_PATH"

# This is the full name of the framework we'll
# build
FRAMEWORK_DIR=$FRAMEWORK_BUILD_PATH/$FRAMEWORK_NAME.framework

# Build the canonical Framework bundle directory
# structure
echo "Framework: Setting up directories..."
mkdir -p $FRAMEWORK_DIR
mkdir -p $FRAMEWORK_DIR/Versions
mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION
mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION/Resources
mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION/Headers

echo "Framework: Creating symlinks..."
ln -s $FRAMEWORK_VERSION $FRAMEWORK_DIR/Versions/Current
ln -s Versions/Current/Headers $FRAMEWORK_DIR/Headers
ln -s Versions/Current/Resources $FRAMEWORK_DIR/Resources
ln -s Versions/Current/$FRAMEWORK_NAME $FRAMEWORK_DIR/$FRAMEWORK_NAME

# Check that this is what your static libraries
# are called
ARM_FILES="build/$BUILD_TYPE-iphoneos/${LIB_NAME}Device${FLAVOR}.a"
I386_FILES="build/$BUILD_TYPE-iphonesimulator/${LIB_NAME}Simulator${FLAVOR}.a"

# The trick for creating a fully usable library is
# to use lipo to glue the different library
# versions together into one file. When an
# application is linked to this library, the
# linker will extract the appropriate platform
# version and use that.
# The library file is given the same name as the
# framework with no .a extension.
echo "Framework: Creating library..."
lipo \
  -create \
  -arch armv6 "$ARM_FILES" \
  -arch i386 "$I386_FILES" \
  -o "$FRAMEWORK_DIR/Versions/Current/$FRAMEWORK_NAME"

# Now copy the final assets over: your library
# header files and the plist file
echo "Framework: Copying assets into current version..."
cp ../Classes-IPhone/*.h $FRAMEWORK_DIR/Headers/
cp Framework.plist $FRAMEWORK_DIR/Resources/Info.plist
