//
//  PGRunLoop.m
//  GHUnitIOS
//
//  Created by lipa on 1/24/14.
//
//

#import "PGMockRunLoop.h"
#import "GHAsyncTestCase.h"
#import "GHArgumentKeyConstants.h"
#import <objc/runtime.h>




@interface PGRunLoopExecutionElement : NSObject
@property (readwrite,assign) double executionTime;
@property (readwrite,retain) id target;
@property (readwrite,assign) SEL selector;
@property (readwrite, retain) NSArray* arguments;
@property (readwrite, assign) BOOL isTimeout;
@property (readwrite,assign) int status;
@property (readwrite, retain) GHAsyncTestCase* testCase;
@end

@implementation PGRunLoopExecutionElement
@end


@interface PGMockRunLoop ()
@property (readwrite, assign) BOOL started;
@property (readwrite, retain) NSMutableArray* queue;
@property (readwrite, retain) NSMutableArray* postExecutionQueue;
@property (readwrite, assign) BOOL methodsSwizzled;
@property (readwrite, retain) id callbackTarget;
@property (readwrite, assign) SEL callbackSelector;
@property (readwrite, retain) NSDictionary* callbackArgument;
@property (readwrite, retain) NSException* testException;
@property (readwrite, retain) NSMutableSet* testCases;
@property (readwrite,assign) IMP cancel_implementation1;
@property (readwrite,assign) IMP cancel_implementation2;
@end

@implementation PGMockRunLoop


static PGMockRunLoop* pgrunloopSingleton = nil;

+(void) initialize {
    pgrunloopSingleton = [[PGMockRunLoop alloc] init];
    [pgrunloopSingleton initialize];
}

-(void) initialize {
    Class nsObjectClass = objc_getClass("NSObject");

    Method cancel1 = class_getClassMethod(nsObjectClass, @selector(cancelPreviousPerformRequestsWithTarget:));
    Method cancel2 = class_getClassMethod(nsObjectClass, @selector(cancelPreviousPerformRequestsWithTarget:selector:object:));

    self.cancel_implementation1 =  method_getImplementation(cancel1);
    self.cancel_implementation2 =  method_getImplementation(cancel2);




    Method dummy_cancel1 = class_getClassMethod(nsObjectClass, @selector(dummyMethodToBeReplacedWithRealCancelFunction1:));
    Method dummy_cancel2 = class_getClassMethod(nsObjectClass, @selector(dummyMethodToBeReplacedWithRealCancelFunction2:selector:object:));

    method_setImplementation(dummy_cancel1, self.cancel_implementation1);
    method_setImplementation(dummy_cancel2, self.cancel_implementation2);
}

+(PGMockRunLoop*) singleton {
    return pgrunloopSingleton;
}

-(id) init {
    if ((self = [super init])) {
        self.testCases = [NSMutableSet set];
        self.queue = [NSMutableArray array];
        self.postExecutionQueue  = [NSMutableArray array];
    }
    return self;
}

-(void) addElementToQueue:(PGRunLoopExecutionElement*) element {
    @synchronized(self) {
        int index = 0;
        while (YES) {
            if (index >= self.queue.count ||
                element.executionTime < ((PGRunLoopExecutionElement*)(self.queue[index])).executionTime) {
                [self.queue insertObject:element atIndex:index];
                return;
            }
            index++;
        }
    }
}
-(void) addElementToPostExecutionQueue:(PGRunLoopExecutionElement*) element {
    @synchronized(self) {
        [self.postExecutionQueue addObject:element];
    }
}

-(void) executeElement:(PGRunLoopExecutionElement*) element {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    @try {
        @autoreleasepool {
            [self swizzleMethods];
            @try {


                if (element.arguments.count == 0) {
                    [element.target performSelector:element.selector] ;
                } else if (element.arguments.count == 1) {
                    [element.target performSelector:element.selector withObject:element.arguments[0]] ;
                } else if (element.arguments.count == 2) {

                }
            }
            @catch (NSException* exception) {
                if (!self.testException) self.testException = exception;
            }@finally {

            }
            [self unswizzleMethods];
        }

    } @catch (NSException *exception) {
        if (!self.testException) self.testException = exception;
    } @finally {
        
    }
    
#pragma clang diagnostic pop
    
}

-(void) fake_performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay {
    PGRunLoopExecutionElement* new_element = [[PGRunLoopExecutionElement alloc] init];
    new_element.executionTime = delay + CFAbsoluteTimeGetCurrent();
    new_element.target = self;
    new_element.selector = aSelector;
    if (anArgument != nil) {
        new_element.arguments = [NSArray arrayWithObject:anArgument];
    }

    [[PGMockRunLoop singleton] addElementToQueue:new_element];
}

-(void) fake_performSelector:(SEL)aSelector withObject:(id)anArgument1 withObject:(id)anArgument2  afterDelay:(NSTimeInterval)delay {
    PGRunLoopExecutionElement* new_element = [[PGRunLoopExecutionElement alloc] init];
    new_element.executionTime = delay + CFAbsoluteTimeGetCurrent();
    new_element.target = self;
    new_element.selector = aSelector;
    new_element.arguments = [NSArray arrayWithObjects:anArgument1, anArgument2, nil];
    [[PGMockRunLoop singleton] addElementToQueue:new_element];
}

-(void) removePerformRequestsWithTarget:(id) aTarget {
    NSMutableArray* elementsToRemove = [NSMutableArray array];
    @synchronized(self) {
        for (PGRunLoopExecutionElement* element in self.queue) {
            if (element.target == aTarget) {
                [elementsToRemove addObject:element];
            }
        }
        for (PGRunLoopExecutionElement* element in elementsToRemove) {
            [self.queue removeObject:element];
        }
    }
}

-(void) removePerformRequestsWithTarget:(id) aTarget selector:(SEL)aSelector object:(id)anArgument {
    NSMutableArray* elementsToRemove = [NSMutableArray array];
    @synchronized(self) {
        for (PGRunLoopExecutionElement* element in self.queue) {
            if (element.target == aTarget &&
                element.selector == aSelector &&
                (((element.arguments == nil || element.arguments.count == 0) && anArgument == nil) ||
                 (element.arguments.count == 1 && [anArgument isEqual:element.arguments[0]]))
                ) {
                [elementsToRemove addObject:element];
            }
        }
        for (PGRunLoopExecutionElement* element in elementsToRemove) {
            [self.queue removeObject:element];
        }
    }
}

+(void) fake_cancelPreviousPerformRequestsWithTarget:(id)aTarget {
    [[PGMockRunLoop singleton] removePerformRequestsWithTarget:aTarget];
}

+(void) cancelPreviousPerformRequestsWithTarget:(id)aTarget {
    [[PGMockRunLoop singleton] removePerformRequestsWithTarget:aTarget];
}

+(void) fake_cancelPreviousPerformRequestsWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)anArgument {
    [[PGMockRunLoop singleton] removePerformRequestsWithTarget:aTarget selector:aSelector object:anArgument];
}

+(void) cancelPreviousPerformRequestsWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)anArgument {
    [[PGMockRunLoop singleton] removePerformRequestsWithTarget:aTarget selector:aSelector object:anArgument];
}

void swizzleMethod(Class classA, SEL selectorA, Class classB, SEL selectorB) {
    Method methodA = class_getInstanceMethod(classA, selectorA);
    Method methodB = class_getInstanceMethod(classB, selectorB);
    method_exchangeImplementations(methodA, methodB);
}



-(void) overrideCancelPreviousPerformSelector {


    Class nsObjectClass = objc_getClass("NSObject");

    Method cancel1 = class_getClassMethod(nsObjectClass, @selector(cancelPreviousPerformRequestsWithTarget:));
    Method cancel2 = class_getClassMethod(nsObjectClass, @selector(cancelPreviousPerformRequestsWithTarget:selector:object:));



    method_setImplementation(cancel1, imp_implementationWithBlock(^(Class self, id target) {
        [[PGMockRunLoop singleton] removePerformRequestsWithTarget:target];
    }));
    method_setImplementation(cancel2, imp_implementationWithBlock(^(Class self, id target, SEL selector, id object) {
        [[PGMockRunLoop singleton] removePerformRequestsWithTarget:target selector:selector object:object];
    }));
}

-(void) undoOverrideCancelPreviousPerformSelector {
    Class nsObjectClass = objc_getClass("NSObject");

    Method cancel1 = class_getClassMethod(nsObjectClass, @selector(cancelPreviousPerformRequestsWithTarget:));
    Method cancel2 = class_getClassMethod(nsObjectClass, @selector(cancelPreviousPerformRequestsWithTarget:selector:object:));

    method_setImplementation(cancel1, self.cancel_implementation1);
    method_setImplementation(cancel2, self.cancel_implementation2);
}
void swizzleClassMethod(Class classA, SEL selectorA, Class classB,  SEL selectorB) {
    Method methodA = class_getClassMethod(classA, selectorA);
    Method methodB = class_getClassMethod(classB, selectorB);
    method_exchangeImplementations(methodA, methodB);
}

+(void) dummyMethodToBeReplacedWithRealCancelFunction1:(id) target {

}
+(void) dummyMethodToBeReplacedWithRealCancelFunction2:(id) target selector:(SEL) sel object:(id) arg {

}

+(void) performRealCancelPreviousPerformRequestsWithTarget:(id) target {
    [self dummyMethodToBeReplacedWithRealCancelFunction1:target];
}
+(void) performRealCancelPreviousPerformRequestsWithTarget:(id) target  selector:(SEL) selector object:(id) arg {
    [self dummyMethodToBeReplacedWithRealCancelFunction2:target selector:selector object:arg];
}


-(void) __swizzleMethods_internal {
    swizzleMethod([PGMockRunLoop class], @selector(fake_performSelector:withObject:afterDelay:),
                  [NSObject class], @selector(performSelector:withObject:afterDelay:));
    swizzleMethod([PGMockRunLoop class], @selector(fake_performSelector:withObject:withObject:afterDelay:),
                  [NSObject class], @selector(performSelector:withObject:withObject:afterDelay:));
    swizzleClassMethod([PGMockRunLoop class], @selector(fake_cancelPreviousPerformRequestsWithTarget:), [NSObject class], @selector(cancelPreviousPerformRequestsWithTarget:));
    swizzleClassMethod([PGMockRunLoop class], @selector(fake_cancelPreviousPerformRequestsWithTarget:), [NSObject class], @selector(cancelPreviousPerformRequestsWithTarget:));

    [PGMockRunLoop performRealCancelPreviousPerformRequestsWithTarget:self];

}

-(void) swizzleMethods {
    @synchronized(self) {
        if (!self.methodsSwizzled) {
            self.methodsSwizzled = YES;
            [self __swizzleMethods_internal];
            [self overrideCancelPreviousPerformSelector];
        }
    }
}

-(void) unswizzleMethods {
    @synchronized(self) {
        if (self.methodsSwizzled) {
            self.methodsSwizzled = NO;
            [self __swizzleMethods_internal];
            [self undoOverrideCancelPreviousPerformSelector];
        }
    }
}



-(BOOL) hasExecutionElementsRemaining {
    BOOL r;
    @synchronized(self) {
        r = self.queue.count > 0;
    }
    return r;
}
-(BOOL) hasPostExecutionElementsRemaining {
    BOOL r;
    @synchronized(self) {
        r = self.postExecutionQueue.count > 0;
    }
    return r;
}
-(PGRunLoopExecutionElement*) popExecutionElement {
    PGRunLoopExecutionElement* e;
    @synchronized(self) {
        e = self.queue[0];
        [self.queue removeObjectAtIndex:0];
    }
    return e;
}
-(PGRunLoopExecutionElement*) peekExecutionElement {
    PGRunLoopExecutionElement* e;
    @synchronized(self) {
        e = self.queue[0];
    }
    return e;
}
-(PGRunLoopExecutionElement*) popPostExecutionElement {
    PGRunLoopExecutionElement* e;
    @synchronized(self) {
        e = self.postExecutionQueue[0];
        [self.postExecutionQueue removeObjectAtIndex:0];
    }
    return e;
}
-(PGRunLoopExecutionElement*) peekPostExecutionElement {
    PGRunLoopExecutionElement* e;
    @synchronized(self) {
        e = self.postExecutionQueue[0];

    }
    return e;
}

+(void) requestCallbackAfterCurrentRunLoopCompleteTarget:(id) target selector:(SEL) selector argument:(id) argument {
    PGRunLoopExecutionElement* e = [[PGRunLoopExecutionElement alloc] init];
    e.target = target;
    e.selector = selector;
    e.arguments = [NSArray arrayWithObject:argument];
    [[self singleton] addElementToPostExecutionQueue:e];
}

+(void) addTimeoutTarget:(id) target selector:(SEL) selector argument:(id) argument timeout:(CFTimeInterval) timeout  status:(NSInteger) status testCase:(GHAsyncTestCase*)testCase {
    PGRunLoopExecutionElement* e = [[PGRunLoopExecutionElement alloc] init];
    e.target = target;
    e.selector = selector;
    e.executionTime = timeout + CFAbsoluteTimeGetCurrent();
    e.isTimeout = YES;
    e.arguments = [NSArray arrayWithObject:argument];
    e.status = status;
    e.testCase = testCase;
    [[self singleton] addElementToPostExecutionQueue:e];
}


+(void) runInFakeRunLoopTarget:(id) target selector:(SEL) selector withCallbackTarget:(id) callbacktarget callbackSelector:(SEL) callbackselctor callBackArguments:(NSDictionary*) arg {
    if ([PGMockRunLoop singleton].started) {
        @throw [NSException exceptionWithName:nil reason:nil userInfo:nil];
    }
    [PGMockRunLoop singleton].started = YES;
    [PGMockRunLoop singleton].testException = nil;
    [PGMockRunLoop singleton].callbackSelector = callbackselctor;
    [PGMockRunLoop singleton].callbackTarget = callbacktarget;
    [PGMockRunLoop singleton].callbackArgument = arg;

    PGRunLoopExecutionElement* new_element = [[PGRunLoopExecutionElement alloc] init];
    new_element.target = target;
    new_element.selector = selector;
    [[PGMockRunLoop singleton] addElementToQueue:new_element];

    [[self singleton] performSelectorInBackground:@selector(_internal_runFakeRunLoopLoop) withObject:nil];
}
-(void) _internal_runFakeRunLoopLoop {


    if ([self hasExecutionElementsRemaining]) {
        PGRunLoopExecutionElement* e = [self  peekExecutionElement];
        CFTimeInterval time_to_wait = MAX(0,[e executionTime] - CFAbsoluteTimeGetCurrent());
        if (time_to_wait > 0 && !e.isTimeout) {
            [self performSelectorInBackground:@selector(_internal_runFakeRunLoopLoop) withObject:nil];
            return;
        }
        [self popExecutionElement];
        [self performSelectorOnMainThread:@selector(executeElement:) withObject:e waitUntilDone:YES];

        [self performSelectorInBackground:@selector(_internal_runFakeRunLoopLoop) withObject:nil];
        return;
    }
    if ([self hasPostExecutionElementsRemaining]) {
        PGRunLoopExecutionElement* e = [self peekPostExecutionElement];

        CFTimeInterval time_to_wait = MAX(0,[e executionTime] - CFAbsoluteTimeGetCurrent());
        if (time_to_wait > 0 && (!e.isTimeout || e.testCase.notifiedStatus !=e.status)) {
            [self performSelectorInBackground:@selector(_internal_runFakeRunLoopLoop) withObject:nil];
            return;
        }
        [self popPostExecutionElement];
        if (e.testCase) {
            [self.testCases addObject:e.testCase];
        }
        [self performSelectorOnMainThread:@selector(executeElement:) withObject:e waitUntilDone:YES];

        [self performSelectorInBackground:@selector(_internal_runFakeRunLoopLoop) withObject:nil];
        return;
    }
    if (self.testException) {
        NSMutableDictionary* callbackArgumentMutableDictCopy = [NSMutableDictionary dictionaryWithDictionary:self.callbackArgument];
        callbackArgumentMutableDictCopy[kGHArgKeyTestException] = self.testException;
        self.callbackArgument = callbackArgumentMutableDictCopy;
    } else {
        for (GHTestCase* testCase in self.testCases) {
            if (testCase.failedWithException) {
                NSMutableDictionary* callbackArgumentMutableDictCopy = [NSMutableDictionary dictionaryWithDictionary:self.callbackArgument];
                callbackArgumentMutableDictCopy[kGHArgKeyTestException] = self.testException;
                self.callbackArgument = callbackArgumentMutableDictCopy;
                break;
            }
        }

    }
    self.testCases = [NSMutableSet set];
    self.started = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.callbackTarget performSelectorInBackground:self.callbackSelector withObject:self.callbackArgument];
#pragma clang diagnostic pop

}

@end
