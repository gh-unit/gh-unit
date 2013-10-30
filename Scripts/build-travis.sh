#!/bin/sh

echo "Build iOS"
$(MAKE) -C Project-iOS

echo "Validate PodSpec"
pod --version
pod spec lint GHUnitIOS.podspec
pod spec lint GHUnitOSX.podspec