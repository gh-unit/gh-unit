#!/bin/sh
#
# Script to copy saved UI test images to the product. Needs to be run as
# part of the build process.
#
# Created by John Boiles on 10/19/10.

UI_TEST_IMAGES_DIR="$PWD/TestImages"

if [ "$(ls -A $UI_TEST_IMAGES_DIR)" ]; then
	echo "Copying images from $UI_TEST_IMAGES_DIR to $TARGET_BUILD_DIR/$PRODUCT_NAME.app"
    cp -v "$UI_TEST_IMAGES_DIR"/*.png "$TARGET_BUILD_DIR/$PRODUCT_NAME.app/"
else
	echo "No test images found in $UI_TEST_IMAGES_DIR"
fi
