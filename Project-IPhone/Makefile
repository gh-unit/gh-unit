

default:
	xcodebuild -target "CombineLibs (3.0)" -configuration Release build

4_0:
	xcodebuild -target "GHUnitIPhone (Simulator-4.0)" -configuration Release build
	xcodebuild -target "GHUnitIPhone (Device-4.0)" -configuration Release build
	BUILD_DIR="build" BUILD_STYLE="Release" FLAVOR="4_0" GHUNIT_VERSION="0.4.22" sh ../Scripts/CombineLibs.sh

# If you need to clean a specific target/configuration: $(COMMAND) -target $(TARGET) -configuration DebugOrRelease -sdk $(SDK) clean
clean:
	-rm -rf build/*

test:
	GHUNIT_CLI=1 xcodebuild -target Tests -configuration Debug -sdk iphonesimulator3.0 build
