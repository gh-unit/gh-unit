//
//  PGRunLoop.m
//  GHUnitIOS
//
//  Created by lipa on 1/24/14.
//
//

#import "PGMockRunLoop.h"
#import "GHAsyncTestCase.h"
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
@property (readwrite, retain) NSMutableArray* callbackArgument;
@property (readwrite, retain) NSException* testException;

@end

@implementation PGMockRunLoop


static PGMockRunLoop* pgrunloopSingleton = nil;

+(void) initialize {
    pgrunloopSingleton = [[PGMockRunLoop alloc] init];

}

+(PGMockRunLoop*) singleton {
    return pgrunloopSingleton;
}

-(id) init {
    if ((self = [super init])) {

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

void swizzleMethod(Class classA, SEL selectorA, Class classB, SEL selectorB) {
    Method methodA = class_getInstanceMethod(classA, selectorA);
    Method methodB = class_getInstanceMethod(classB, selectorB);
    method_exchangeImplementations(methodA, methodB);
}

-(void) __swizzleMethods_internal {
    swizzleMethod([PGMockRunLoop class], @selector(fake_performSelector:withObject:afterDelay:),
                  [NSObject class], @selector(performSelector:withObject:afterDelay:));
    swizzleMethod([PGMockRunLoop class], @selector(fake_performSelector:withObject:withObject:afterDelay:),
                  [NSObject class], @selector(performSelector:withObject:withObject:afterDelay:));

}

-(void) swizzleMethods {
    @synchronized(self) {
        if (!self.methodsSwizzled) {
            self.methodsSwizzled = YES;
            [self __swizzleMethods_internal];
        }
    }
}

-(void) unswizzleMethods {
    @synchronized(self) {
        if (self.methodsSwizzled) {
            self.methodsSwizzled = NO;
            [self __swizzleMethods_internal];
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


+(void) runInFakeRunLoopTarget:(id) target selector:(SEL) selector withCallbackTarget:(id) callbacktarget callbackSelector:(SEL) callbackselctor callBackArguments:(NSMutableArray*) arg {
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


    if ([self hasExecutionElementsRemaining] && self.testException == nil) {
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
    if ([self hasPostExecutionElementsRemaining] && self.testException == nil) {
        PGRunLoopExecutionElement* e = [self peekPostExecutionElement];

        CFTimeInterval time_to_wait = MAX(0,[e executionTime] - CFAbsoluteTimeGetCurrent());
        if (time_to_wait > 0 && (!e.isTimeout || e.testCase.notifiedStatus !=e.status)) {
            [self performSelectorInBackground:@selector(_internal_runFakeRunLoopLoop) withObject:nil];
            return;
        }
        [self popPostExecutionElement];
        [self performSelectorOnMainThread:@selector(executeElement:) withObject:e waitUntilDone:YES];

        [self performSelectorInBackground:@selector(_internal_runFakeRunLoopLoop) withObject:nil];
        return;
    }
    if (self.testException) {
        [self.callbackArgument addObject:self.testException];
    }
    self.started = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.callbackTarget performSelectorInBackground:self.callbackSelector withObject:self.callbackArgument];
#pragma clang diagnostic pop

}

@end
