//
//  DCRoundSwitchKnobLayer.m
//
//  Created by Patrick Richards on 29/06/11.
//  MIT License.
//
//  http://twitter.com/patr
//  http://domesticcat.com.au/projects
//  http://github.com/domesticcatsoftware/DCRoundSwitch
//

#import "DCRoundSwitchKnobLayer.h"
#import <UIKit/UIKit.h>

CGGradientRef CreateGradientRefWithColors(CGColorSpaceRef colorSpace, UIColor* startColor, UIColor* endColor);

@implementation DCRoundSwitchKnobLayer
@synthesize gripped;

- (void)drawInContext:(CGContextRef)context
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGRect knobRect = CGRectInset(self.bounds, 2, 2);
	CGFloat knobRadius = self.bounds.size.height - 2;
    
	// knob outline (shadow is drawn in the toggle layer)
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.62 alpha:1.0].CGColor);
	CGContextSetLineWidth(context, 1.5);
	CGContextStrokeEllipseInRect(context, knobRect);
	CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 0, NULL);
    
	// knob inner gradient
	CGContextAddEllipseInRect(context, knobRect);
	CGContextClip(context);
	UIColor *knobStartColor = [UIColor colorWithWhite:0.82 alpha:1.0];
	UIColor *knobEndColor = (self.gripped) ? [UIColor colorWithWhite:0.894 alpha:1.0] : [UIColor colorWithWhite:0.996 alpha:1.0];
	CGPoint topPoint = CGPointMake(0, 0);
	CGPoint bottomPoint = CGPointMake(0, knobRadius + 2);
	CGGradientRef knobGradient = CreateGradientRefWithColors(colorSpace, knobStartColor, knobEndColor);
	CGContextDrawLinearGradient(context, knobGradient, topPoint, bottomPoint, 0);
	CGGradientRelease(knobGradient);
    
	// knob inner highlight
	CGContextAddEllipseInRect(context, CGRectInset(knobRect, 0.5, 0.5));
	CGContextAddEllipseInRect(context, CGRectInset(knobRect, 1.5, 1.5));
	CGContextEOClip(context);
	CGGradientRef knobHighlightGradient = CreateGradientRefWithColors(colorSpace, [UIColor whiteColor], [UIColor colorWithWhite:1.0 alpha:0.5]);
	CGContextDrawLinearGradient(context, knobHighlightGradient, topPoint, bottomPoint, 0);
	CGGradientRelease(knobHighlightGradient);
    
	CGColorSpaceRelease(colorSpace);
}

CGGradientRef CreateGradientRefWithColors(CGColorSpaceRef colorSpace, UIColor* startColor, UIColor* endColor)
{
    CGFloat colorStops[2] = {0.0, 1.0};
    NSArray *colors =
    [NSArray arrayWithObjects:(__bridge id)startColor.CGColor, (__bridge id) endColor.CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, colorStops);
    return gradient;
}





- (void)setGripped:(BOOL)newGripped
{
	gripped = newGripped;
	[self setNeedsDisplay];
}

@end
