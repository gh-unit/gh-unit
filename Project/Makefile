
TEST_TARGET=Tests
SDK=macosx10.5
COMMAND=xcodebuild

default:
	# Set default make action here

docs:
	cd .. && /Applications/Doxygen.app/Contents/Resources/doxygen

# If you need to clean a specific target/configuration: $(COMMAND) -target $(TARGET) -configuration DebugOrRelease -sdk $(SDK) clean
clean:
	-rm -rf build/*

test:
	GHUNIT_CLI=1 $(COMMAND) -target $(TEST_TARGET) -configuration Debug -sdk $(SDK) build
	
