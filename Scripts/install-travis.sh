#!/bin/sh

echo "Update CocoaPods"
pod --version
gem update cocoapods
pod --version

echo "Install appledoc"
brew install appledoc