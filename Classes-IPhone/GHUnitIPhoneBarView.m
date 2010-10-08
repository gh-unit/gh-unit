//
//  GHUnitIPhoneBarView.m
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
#import "GHUnitIPhoneBarView.h"


@implementation GHUnitIPhoneBarView
@synthesize status;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGSize size = self.frame.size;

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
	
	CGColorRef color;
	if (GHTestStatusIsRunning(status)) {
		color = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
	}
	else if (status == GHTestStatusErrored) {
		color = [UIColor colorWithRed:137.0/255.0 green:10/255.0 blue:0 alpha:1.0].CGColor;
	}
	else if (status == GHTestStatusSucceeded) {
		color = [UIColor colorWithRed:0 green:163.0/255.0 blue:0 alpha:1.0].CGColor;	
	}
	else {
		color = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
	}
	
	// make the bar
	int margin = 1;
	CGRect outlineRect = CGRectMake(0, 0, size.width, size.height);
	CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.45].CGColor);	
	CGContextFillRect(context, outlineRect);
	
	CGRect barRect = CGRectMake(margin, margin, size.width - margin * 2, size.height - margin * 2);
	CGContextSetFillColorWithColor(context, color);	
	CGContextFillRect(context, barRect);
}



@end
