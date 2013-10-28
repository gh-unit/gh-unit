default:
	xcodebuild \
	-target "GHUnitIOS (Device)" \
	-configuration 'Release' \
	build \
	ARCHS='armv7' \
	VALID_ARCH='arm7' \
	IPHONEOS_DEPLOYMENT_TARGET='5.1.1' \
	TARGET_BUILD_DIR='./build/build-arm7' \
	BUILT_PRODUCTS_DIR='./build/build-arm7'

	xcodebuild \
	-target "GHUnitIOS (Device)" \
	-configuration 'Release' \
	build \
	ARCHS='armv7s' \
	VALID_ARCH='arm7s' \
	IPHONEOS_DEPLOYMENT_TARGET='5.1.1' \
	TARGET_BUILD_DIR='./build/build-arm7s' \
	BUILT_PRODUCTS_DIR='./build/build-arm7s' 

	xcodebuild \
	-target "GHUnitIOS (Device)" \
	-configuration 'Release' \
	build \
	ARCHS='arm64' \
	VALID_ARCH='arm64' \
	IPHONEOS_DEPLOYMENT_TARGET='7.0' \
	TARGET_BUILD_DIR='./build/build-arm64' \
	BUILT_PRODUCTS_DIR='./build/build-arm64' 

	xcodebuild \
	-target "GHUnitIOS (Simulator)" \
	-configuration 'Release' \
	-sdk 'iphonesimulator' \
	build \
	ARCHS='i386' \
	VALID_ARCH='i386' \
	IPHONEOS_DEPLOYMENT_TARGET='5.1.1' \
	TARGET_BUILD_DIR='./build/build-i386' \
	BUILT_PRODUCTS_DIR='./build/build-i386'

	BUILD_DIR="build" sh ../Scripts/CombineLibs.sh
	BUILD_DIR="build" sh ../Scripts/iOSFramework.sh

# If you need to clean a specific target/configuration: $(COMMAND) -target $(TARGET) -configuration DebugOrRelease -sdk $(SDK) clean
clean:
	-rm -rf build/*

test:
	GHUNIT_CLI=1 xcodebuild -target Tests -configuration Debug -sdk iphonesimulator build
