//
//  GHUNSObject+Swizzle.m
//  GHUnit
//
//  Created by Gabriel Handford on 4/13/09.
//  Copyright 2009. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

//! @cond DEV

#import "GHUNSObject+Swizzle.h"

#import <objc/runtime.h>

BOOL GHU_PerformSwizzle(Class klass, SEL origSel, SEL altSel, BOOL forInstance);

@implementation NSObject(GHUSwizzle)

+ (void)ghu_swizzleMethod:(SEL)original withMethod:(SEL)alternate {
	GHU_PerformSwizzle([self class], original, alternate, YES);
}

+ (void)ghu_swizzleClassMethod:(SEL)original withClassMethod:(SEL)alternate {
	GHU_PerformSwizzle([self class], original, alternate, NO);
}

@end

// @see http://www.cocoadev.com/index.pl?MethodSwizzling
BOOL GHU_PerformSwizzle(Class klass, SEL origSel, SEL altSel, BOOL forInstance) {
	
	// Make sure the class isn't nil
	if (klass == nil)
		return NO;
	
	// Look for the methods in the implementation of the immediate class
	Class iterKlass = (forInstance ? klass : klass->isa);
	Method origMethod = NULL, altMethod = NULL;
	unsigned int methodCount = 0;
	Method *mlist = class_copyMethodList(iterKlass, &methodCount);
	if ( mlist != NULL ) {
		int i;
		for (i = 0; i < methodCount; ++i) {
			if ( method_getName(mlist[i]) == origSel )
				origMethod = mlist[i];
			if (method_getName(mlist[i]) == altSel)
				altMethod = mlist[i];
		}
	}
	
	// if origMethod was not found, that means it is not in the immediate class
	// try searching the entire class hierarchy with class_getInstanceMethod
	// if not found or not added, bail out
	if ( origMethod == NULL ) {
		origMethod = class_getInstanceMethod(iterKlass, origSel);
		if ( origMethod == NULL )
			return NO;
		if ( class_addMethod(iterKlass, method_getName(origMethod), method_getImplementation(origMethod), method_getTypeEncoding(origMethod)) == NO )
			return NO;
	}
	
	// same thing with altMethod
	if ( altMethod == NULL ) {
		altMethod = class_getInstanceMethod(iterKlass, altSel);
		if ( altMethod == NULL ) 
			return NO;
		if ( class_addMethod(iterKlass, method_getName(altMethod), method_getImplementation(altMethod), method_getTypeEncoding(altMethod)) == NO )
			return NO;
	}
	
	//clean up
	free(mlist);
	
	// we now have to look up again for the methods in case they were not in the class implementation,
	//but in one of the superclasses. In the latter, that means we added the method to the class,
	//but the Leopard APIs is only 'class_addMethod', in which case we need to have the pointer
	//to the Method objects actually stored in the Class structure (in the Tiger implementation, 
	//a new mlist was explicitely created with the added methods and directly added to the class; 
	//thus we were able to add a new Method AND get the pointer to it)
	
	// for simplicity, just use the same code as in the first step
	origMethod = NULL;
	altMethod = NULL;
	methodCount = 0;
	mlist = class_copyMethodList(iterKlass, &methodCount);
	if ( mlist != NULL ) {
		int i;
		for (i = 0; i < methodCount; ++i) {
			if ( method_getName(mlist[i]) == origSel )
				origMethod = mlist[i];
			if (method_getName(mlist[i]) == altSel)
				altMethod = mlist[i];
		}
	}
	
	// bail if one of the methods doesn't exist anywhere
	// with all we did, this should not happen, though
	if (origMethod == NULL || altMethod == NULL)
		return NO;
	
	// now swizzle
	method_exchangeImplementations(origMethod, altMethod);
	
	//clean up
	free(mlist);
	
	return YES;
}

//! @endcond
