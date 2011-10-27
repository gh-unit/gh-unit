#!/bin/sh
#
# Script to copy approved images from GHViewTestCases back to the project
#
# This script should be run at the command line after approving
# any UI changes from the simulator
#
# Created by John Boiles on 10/19/10.

TEST_APP_NAME="Tests"
UI_TEST_IMAGES_DIR="$PWD/TestImages"

# Find the most recent simulator install of the app
SIM_INSTANCE_DIR=`find "/Users/$USER/Library/Application Support/iPhone Simulator" -type d -name "$TEST_APP_NAME.app" -print0 | xargs -0 ls -td | head -1`
# Find the location of the documents for the app
SIM_DOCUMENTS_DIR=`dirname "$SIM_INSTANCE_DIR"`/Documents/TestImages
echo "Found simulator documents dir at $SIM_DOCUMENTS_DIR"

# Create the images directory if not already created
mkdir -p "$UI_TEST_IMAGES_DIR"

if [[ -d "$SIM_DOCUMENTS_DIR" && $(ls -1A "$SIM_DOCUMENTS_DIR") ]]; then
	echo "Found the following files:"
	ls "$SIM_DOCUMENTS_DIR"/*.png
	# Copy any saved images from the app's documents to the test images folder
	echo "Saving images to $UI_TEST_IMAGES_DIR"
	cp "$SIM_DOCUMENTS_DIR"/*.png "$UI_TEST_IMAGES_DIR"
else
	echo "No saved test images found"
fi