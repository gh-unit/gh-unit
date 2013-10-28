#!/bin/sh

set -e

GHUNIT_VERSION=`cat ../XcodeConfig/Shared.xcconfig | grep "GHUNIT_VERSION =" | cut -d '=' -f 2 | tr -d " "`

NAME=libGHUnitIOS
OUTPUT_DIR=${BUILD_DIR}/Combined
OUTPUT_FILE=${NAME}.a

if [ ! -d ${OUTPUT_DIR} ]; then
  echo "INFO: making output directory ${OUTPUT_DIR}"
  mkdir ${OUTPUT_DIR}
else
  echo "INFO: found output directory ${OUTPUT_DIR}"
fi


BUILD_ARM7="${BUILD_DIR}/build-arm7/${NAME}Device.a"
BUILD_ARM7s="${BUILD_DIR}/build-arm7s/${NAME}Device.a"
BUILD_ARM_64="${BUILD_DIR}/build-arm64/${NAME}Device.a"
BUILD_i386="${BUILD_DIR}/build-i386/${NAME}Simulator.a"

echo "INFO: making static library from:"
echo "INFO:    arm7 ${BUILD_ARM7}"
echo "INFO:   arm7s ${BUILD_ARM7s}"
echo "INFO:   arm64 ${BUILD_ARM_64}"
echo "INFO:    i386 ${BUILD_i386}"


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
  -o ${OUTPUT_DIR}/${OUTPUT_FILE}  

echo "INFO: created static lib: ${OUTPUT_DIR}/${OUTPUT_FILE}"

ZIP_LIB_NAME=${NAME}-${GHUNIT_VERSION}.zip
echo "INFO: zipping library to ${ZIP_LIB_NAME}"
zip -j ${BUILD_DIR}/${ZIP_LIB_NAME} ${OUTPUT_DIR}/${OUTPUT_FILE}

SLICES=`xcrun lipo -info ${OUTPUT_DIR}/${OUTPUT_FILE}`
echo "INFO: ${SLICES}" 
echo ""