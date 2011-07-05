
default:
  # Set default target here

# If you need to clean a specific target/configuration: $(COMMAND) -target $(TARGET) -configuration DebugOrRelease -sdk $(SDK) clean
clean:
	-rm -rf build/*

test:
	GHUNIT_CLI=1 xcodebuild -target Tests -configuration Debug -sdk iphonesimulator build

test-ui:
	GHUNIT_AUTORUN=1 GHUNIT_AUTOEXIT=1 GHUNIT_IPHONE_SIMULATOR=1 xcodebuild -target Tests -configuration Debug -sdk iphonesimulator build