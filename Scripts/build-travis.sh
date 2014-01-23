#!/bin/sh

echo "Build iOS"
make -C Project-iOS

echo "Build OSX"
make -C Project-MacOSX

echo "Validate PodSpec"
pod --version
pod spec lint Podspecs/GHUnit.podspec
pod spec lint Podspecs/GHUnitIOS.podspec
pod spec lint Podspecs/GHUnitOSX.podspec
