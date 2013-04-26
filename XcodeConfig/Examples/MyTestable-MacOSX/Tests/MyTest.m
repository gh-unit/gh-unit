#import <GHUnit/GHUnit.h>

@interface MyTest : GHTestCase { }
@end

@implementation MyTest

- (void)setUpClass {
  // Run at start of all tests in the class
}

- (void)tearDownClass {
  // Run at end of all tests in the class
}

- (void)setUp {
  // Run before each test method
}

- (void)tearDown {
  // Run after each test method
}

- (void)testOK {
  GHAssertTrue(YES, nil);
}

- (void)testFail {
  GHAssertTrue(NO, nil);
}

@end
