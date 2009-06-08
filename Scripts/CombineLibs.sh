#!/bin/sh

# Should define FLAVOR=2_1,2_1CL,3_0,3_0CL

OUTPUT_DIR=${BUILD_DIR}/Combined${BUILD_STYLE}${FLAVOR}
OUTPUT_FILE=libGHUnitIPhone${FLAVOR}.a
ZIP_DIR=${BUILD_DIR}/Zip

mkdir ${OUTPUT_DIR}

# Combine lib files
lipo -create "${BUILD_DIR}/${BUILD_STYLE}-iphoneos/libGHUnitIPhoneDevice${FLAVOR}.a" "${BUILD_DIR}/${BUILD_STYLE}-iphonesimulator/libGHUnitIPhoneSimulator${FLAVOR}.a" -output ${OUTPUT_DIR}/${OUTPUT_FILE}

# Copy to direcory for zipping 
mkdir ${ZIP_DIR}
cp ${OUTPUT_DIR}/${OUTPUT_FILE} ${ZIP_DIR}
cp ${BUILD_DIR}/${BUILD_STYLE}-iphoneos/*.h ${ZIP_DIR}
cp ${BUILD_DIR}/${BUILD_STYLE}-iphoneos/*.m ${ZIP_DIR}
cp ${BUILD_DIR}/${BUILD_STYLE}-iphoneos/*.sh ${ZIP_DIR}

cd ${ZIP_DIR}
zip -m libGHUnitIPhone${FLAVOR}-${GHUNIT_VERSION}.zip *
mv libGHUnitIPhone${FLAVOR}-${GHUNIT_VERSION}.zip ..
rm -rf ${ZIP_DIR}
