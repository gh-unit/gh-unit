//
//  DCRoundSwitchOutlineLayer.m
//
//  Created by Patrick Richards on 29/06/11.
//  MIT License.
//
//  http://twitter.com/patr
//  http://domesticcat.com.au/projects
//  http://github.com/domesticcatsoftware/DCRoundSwitch
//

#import "DCRoundSwitchOutlineLayer.h"
#import <UIKit/UIKit.h>
@implementation DCRoundSwitchOutlineLayer

- (void)drawInContext:(CGContextRef)context
{
	// calculate the outline clip
	CGContextSaveGState(context);
	UIBezierPath *switchOutline = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bounds.size.height / 2.0];
	CGContextAddPath(context, switchOutline.CGPath);
	CGContextClip(context);

	// inner gloss
	CGContextSaveGState(context);
	CGRect innerGlossPathRect = CGRectMake(self.frame.size.width * 0.05,
										   self.frame.size.height / 2.0,
										   self.bounds.size.width  - (self.frame.size.width * 0.1),
										   self.bounds.size.height / 2.0);
	UIBezierPath *innerGlossPath = [UIBezierPath bezierPathWithRoundedRect:innerGlossPathRect
														 byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
															   cornerRadii:CGSizeMake(self.bounds.size.height * 0.3, self.bounds.size.height * 0.3)];
	CGContextAddPath(context, innerGlossPath.CGPath);
	CGContextClip(context);

	CGFloat colorStops[2] = {0.0, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat innerGlossStartColorComponents[] = {1.0, 1.0, 1.0, 0.14};
	CGFloat innerGlossEndColorComponents[] = {1.0, 1.0, 1.0, 0.50};
	CGColorRef topColor = CGColorCreate(colorSpace, innerGlossStartColorComponents);
	CGColorRef bottomColor = CGColorCreate(colorSpace, innerGlossEndColorComponents);
	CGColorRef colors[] = { topColor, bottomColor };
	CFArrayRef colorsArray = CFArrayCreate(NULL, (const void**)colors, sizeof(colors) / sizeof(CGColorRef), &kCFTypeArrayCallBacks);
	CGGradientRef innerGlossGradient = CGGradientCreateWithColors(colorSpace, colorsArray, colorStops);
	CFRelease(colorsArray);

	CGContextDrawLinearGradient(context, innerGlossGradient, CGPointMake(0, CGRectGetMinY(innerGlossPathRect)), CGPointMake(0, CGRectGetMaxY(innerGlossPathRect)), 0);
	CGContextRestoreGState(context);
	CGColorSpaceRelease(colorSpace);
	CGColorRelease(topColor);
	CGColorRelease(bottomColor);
	CGGradientRelease(innerGlossGradient);

	// outline and inner shadow
	CGContextSetShadowWithColor(context, CGSizeMake(0.0, 1), 2.0, [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor);
	CGContextSetLineWidth(context, 0.5);
	UIBezierPath *outlinePath = [UIBezierPath bezierPathWithRoundedRect:CGRectOffset(self.bounds, -0.5, 0.0) cornerRadius:self.bounds.size.height / 2.0];
	CGContextAddPath(context, outlinePath.CGPath);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.60 alpha:1.0].CGColor);
	CGContextStrokePath(context);

	CGContextAddPath(context, outlinePath.CGPath);
	CGContextStrokePath(context);
}

@end
