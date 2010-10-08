//
//  GHUnitIPhoneGradientView.m
//  GHUnitIPhone
//
//  Created by Christian Scheid on 10/7/10.
//  Copyright 2010. All rights reserved.
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

#import "GHUnitIPhoneGradientView.h"


@implementation GHUnitIPhoneGradientView
@synthesize isSelected;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[UIColor clearColor]];
		isSelected = NO;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	CGGradientRef glossGradient;
	CGColorSpaceRef rgbColorspace;
	
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat grayComponents[8] = { 0.9, 0.9, 0.9, 1.0, 
		0.8, 0.8, 0.8, 1.0 };
	
	CGFloat blueComponents[8] = { 0.0, 0.5, 1.0, 1.0, 
		0.1, 0.6, 1.0, 1.0 };
	
	rgbColorspace = CGColorSpaceCreateDeviceRGB();
	glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, isSelected ? blueComponents : grayComponents, locations, 2);
	
	CGRect currentBounds = self.bounds;
	CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
	CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetHeight(currentBounds));
	CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);	
	CGGradientRelease(glossGradient);
	CGColorSpaceRelease(rgbColorspace);	
}

@end
