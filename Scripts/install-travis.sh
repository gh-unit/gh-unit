#!/bin/sh

echo "Update CocoaPods"
pod --version
gem update cocoapods
pod --version