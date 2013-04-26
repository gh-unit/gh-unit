//
//  DCRoundSwitch.m
//
//  Created by Patrick Richards on 28/06/11.
//  MIT License.
//
//  http://twitter.com/patr
//  http://domesticcat.com.au/projects
//  http://github.com/domesticcatsoftware/DCRoundSwitch
//

#import "DCRoundSwitch.h"
#import "DCRoundSwitchToggleLayer.h"
#import "DCRoundSwitchOutlineLayer.h"
#import "DCRoundSwitchKnobLayer.h"

@interface DCRoundSwitch () <UIGestureRecognizerDelegate>

@property (nonatomic, retain) DCRoundSwitchOutlineLayer *outlineLayer;
@property (nonatomic, retain) DCRoundSwitchToggleLayer *toggleLayer;
@property (nonatomic, retain) DCRoundSwitchKnobLayer *knobLayer;
@property (nonatomic, retain) CAShapeLayer *clipLayer;
@property (nonatomic, assign) BOOL ignoreTap;

- (void)setup;
- (void)useLayerMasking;
- (void)removeLayerMask;
- (void)positionLayersAndMask;

@end

@implementation DCRoundSwitch
@synthesize outlineLayer, toggleLayer, knobLayer, clipLayer, ignoreTap;
@synthesize on, onText, offText;
@synthesize onTintColor;

#pragma mark -
#pragma mark Init & Memory Managment

- (void)dealloc
{
	//[outlineLayer release];
	//[toggleLayer release];
	//[knobLayer release];
	//[clipLayer release];

	//[onTintColor release];
    outlineLayer = nil;
    toggleLayer = nil;
    knobLayer = nil;
    clipLayer = nil;
	//[onText release];
	//[offText release];
    onText = nil;
    offText = nil;
	//[super dealloc];
}

- (id)init
{
	if ((self = [super init]))
	{
		self.frame = CGRectMake(0, 0, 77, 27);
		[self setup];
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self setup];
	}

	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self setup];
	}

	return self;
}

+ (Class)knobLayerClass {
    return [DCRoundSwitchKnobLayer class];
}

+ (Class)outlineLayerClass {
    return [DCRoundSwitchOutlineLayer class];
}

+ (Class)toggleLayerClass {
    return [DCRoundSwitchToggleLayer class];
}

- (void)setup
{
	// this way you can set the background color to black or something similar so it can be seen in IB
	self.backgroundColor = [UIColor clearColor];

	// remove the flexible width/height autoresizing masks if they have been set
	UIViewAutoresizing mask = (int)self.autoresizingMask;
	if (mask & UIViewAutoresizingFlexibleHeight)
		self.autoresizingMask ^= UIViewAutoresizingFlexibleHeight;

	if (mask & UIViewAutoresizingFlexibleWidth)
		self.autoresizingMask ^= UIViewAutoresizingFlexibleWidth;

	// setup default texts
	NSBundle *uiKitBundle = [NSBundle bundleWithIdentifier:@"com.apple.UIKit"];
	self.onText = uiKitBundle ? [uiKitBundle localizedStringForKey:@"ON" value:nil table:nil] : @"ON";
	self.offText = uiKitBundle ? [uiKitBundle localizedStringForKey:@"OFF" value:nil table:nil] : @"OFF";

	// the switch has three layers, (ordered from bottom to top):
	//
	// * toggleLayer * (bottom of the layer stack)
	// this layer contains the onTintColor (blue by default), the text, and the shadown for the knob.  the knob shadow is
	// on this layer because it needs to go under the outlineLayer so it doesn't bleed out over the edge of the control.
	// this layer moves when the switch moves

	// * outlineLayer * (middle of the layer stack)
	// this is the outline of the control, it's inner shadow, and the inner gloss.  the inner shadow is on this layer
	// because it must stay still while the switch animates.  the inner gloss is also here because it doesn't move, and also
	// because it needs to go uner the knobLayer.
	// this layer appears to always stay in the same spot.

	// * knobLayer * (top of the layer stack)
	// this is the knob, and sits on top of the layer stack. note that the knob shadow is NOT drawn here, it is drawn on the
	// toggleLayer so it doesn't bleed out over the outlineLayer.

	self.toggleLayer = [[[[self class] toggleLayerClass] alloc] initWithOnString:self.onText offString:self.offText onTintColor:[UIColor colorWithRed:0.000 green:0.478 blue:0.882 alpha:1.0]] ;
	self.toggleLayer.drawOnTint = NO;
	self.toggleLayer.clip = YES;
	[self.layer addSublayer:self.toggleLayer];
	[self.toggleLayer setNeedsDisplay];

	self.outlineLayer = [[[self class] outlineLayerClass] layer];
	[self.toggleLayer addSublayer:self.outlineLayer];
	[self.outlineLayer setNeedsDisplay];

	self.knobLayer = [[[self class] knobLayerClass] layer];
	[self.layer addSublayer:self.knobLayer];
	[self.knobLayer setNeedsDisplay];

	self.toggleLayer.contentsScale = self.outlineLayer.contentsScale = self.knobLayer.contentsScale = [[UIScreen mainScreen] scale];

	// tap gesture for toggling the switch
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																						   action:@selector(tapped:)] ;
	[tapGestureRecognizer setDelegate:self];
	[self addGestureRecognizer:tapGestureRecognizer];

	// pan gesture for moving the switch knob manually
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
																				 action:@selector(toggleDragged:)] ;
	[panGestureRecognizer setDelegate:self];
	[self addGestureRecognizer:panGestureRecognizer];

	[self setNeedsLayout];

	// setup the layer positions
	[self positionLayersAndMask];
}

#pragma mark -
#pragma mark Setup Frame/Layout

- (void)sizeToFit
{
	[super sizeToFit];
	
	NSString *onString = self.toggleLayer.onString;
	NSString *offString = self.toggleLayer.offString;

	CGFloat width = [onString sizeWithFont:self.toggleLayer.labelFont].width;
	CGFloat offWidth = [offString sizeWithFont:self.toggleLayer.labelFont].width;
	
	if(offWidth > width)
		width = offWidth;
	
	width += self.toggleLayer.bounds.size.width * 2.;//add 2x the knob for padding
	
	CGRect newFrame = self.frame;
	CGFloat currentWidth = newFrame.size.width;
	newFrame.size.width = width;
	newFrame.origin.x += currentWidth - width;
	self.frame = newFrame;

	//old values for sizeToFit; keep these around for reference
//	newFrame.size.width = 77.0;
//	newFrame.size.height = 27.0;
}

- (void)useLayerMasking
{
	// turn of the manual clipping (done in toggleLayer's drawInContext:)
	self.toggleLayer.clip = NO;
	self.toggleLayer.drawOnTint = YES;
	[self.toggleLayer setNeedsDisplay];

	// create the layer mask and add that to the toggleLayer
	self.clipLayer = [CAShapeLayer layer];
	UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
														cornerRadius:self.bounds.size.height / 2.0];
	self.clipLayer.path = clipPath.CGPath;
	self.toggleLayer.mask = self.clipLayer;
}

- (void)removeLayerMask
{
	// turn off the animations so the user doesn't see the changing of mask/clipping
	[CATransaction setValue:(__bridge id)kCFBooleanTrue forKey:kCATransactionDisableActions];

	// remove the layer mask (put on in useLayerMasking)
	self.toggleLayer.mask = nil;

	// renable manual clipping (done in toggleLayer's drawInContext:)
	self.toggleLayer.clip = YES;
	self.toggleLayer.drawOnTint = self.on;
	[self.toggleLayer setNeedsDisplay];
}

- (void)positionLayersAndMask
{
	// repositions the underlying toggle and the layer mask, plus the knob
	self.toggleLayer.mask.position = CGPointMake(-self.toggleLayer.frame.origin.x, 0.0);
	self.outlineLayer.frame = CGRectMake(-self.toggleLayer.frame.origin.x, 0, self.bounds.size.width, self.bounds.size.height);
	self.knobLayer.frame = CGRectMake(self.toggleLayer.frame.origin.x + self.toggleLayer.frame.size.width / 2.0 - self.knobLayer.frame.size.width / 2.0,
								 -1,
								 self.knobLayer.frame.size.width,
								 self.knobLayer.frame.size.height);
}

#pragma mark -
#pragma mark Interaction

- (void)tapped:(UITapGestureRecognizer *)gesture
{
	if (self.ignoreTap) return;
	
	if (gesture.state == UIGestureRecognizerStateEnded)
		[self setOn:!self.on animated:YES];
}

- (void)toggleDragged:(UIPanGestureRecognizer *)gesture
{
	CGFloat minToggleX = -self.toggleLayer.frame.size.width / 2.0 + self.toggleLayer.frame.size.height / 2.0;
	CGFloat maxToggleX = -1;

	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// setup by turning off the manual clipping of the toggleLayer and setting up a layer mask.
		[CATransaction setValue:(__bridge id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		[self useLayerMasking];
		[self positionLayersAndMask];
		self.knobLayer.gripped = YES;
	}
	else if (gesture.state == UIGestureRecognizerStateChanged)
	{
		CGPoint translation = [gesture translationInView:self];

		// disable the animations before moving the layers
		[CATransaction setValue:(__bridge id)kCFBooleanTrue forKey:kCATransactionDisableActions];

		// darken the knob
		if (!self.knobLayer.gripped)
			self.knobLayer.gripped = YES;

		// move the toggleLayer using the translation of the gesture, keeping it inside the outline.
		CGFloat newX = self.toggleLayer.frame.origin.x + translation.x;
		if (newX < minToggleX) newX = minToggleX;
		if (newX > maxToggleX) newX = maxToggleX;
		self.toggleLayer.frame = CGRectMake(newX,
									   self.toggleLayer.frame.origin.y,
									   self.toggleLayer.frame.size.width,
									   self.toggleLayer.frame.size.height);

		// this will re-position the layer mask and knob
		[self positionLayersAndMask];

		[gesture setTranslation:CGPointZero inView:self];
	}
	else if (gesture.state == UIGestureRecognizerStateEnded)
	{
		// flip the switch to on or off depending on which half it ends at
		CGFloat toggleCenter = CGRectGetMidX(self.toggleLayer.frame);
		[self setOn:(toggleCenter > CGRectGetMidX(self.bounds)) animated:YES];
	}

	// send off the appropriate actions (not fully tested yet)
	CGPoint locationOfTouch = [gesture locationInView:self];
	if (CGRectContainsPoint(self.bounds, locationOfTouch))
		[self sendActionsForControlEvents:UIControlEventTouchDragInside];
	else
		[self sendActionsForControlEvents:UIControlEventTouchDragOutside];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.ignoreTap) return;

	[super touchesBegan:touches withEvent:event];

	self.knobLayer.gripped = YES;
	[self sendActionsForControlEvents:UIControlEventTouchDown];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];

	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];

	[self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
{
	return !self.ignoreTap;
}

#pragma mark Setters/Getters

- (void)setOn:(BOOL)newOn
{
	[self setOn:newOn animated:NO];
}

- (void)setOn:(BOOL)newOn animated:(BOOL)animated
{
	[self setOn:newOn animated:animated ignoreControlEvents:NO];
}

- (void)setOn:(BOOL)newOn animated:(BOOL)animated ignoreControlEvents:(BOOL)ignoreControlEvents
{
	BOOL previousOn = self.on;
	on = newOn;
	self.ignoreTap = YES;

	[CATransaction setAnimationDuration:0.014];
	self.knobLayer.gripped = YES;

	// setup by turning off the manual clipping of the toggleLayer and setting up a layer mask.
	[self useLayerMasking];
	[self positionLayersAndMask];

	// retain all our targets so they don't disappear before the actions get sent at the end of the animation
	//[[self allTargets] makeObjectsPerformSelector:@selector(retain)];

	[CATransaction setCompletionBlock:^{
		[CATransaction begin];
		if (!animated)
			[CATransaction setValue:(__bridge id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		else
			[CATransaction setValue:(__bridge id)kCFBooleanFalse forKey:kCATransactionDisableActions];

		CGFloat minToggleX = -self.toggleLayer.frame.size.width / 2.0 + self.toggleLayer.frame.size.height / 2.0;
		CGFloat maxToggleX = -1;


		if (self.on)
		{
			self.toggleLayer.frame = CGRectMake(maxToggleX,
										   self.toggleLayer.frame.origin.y,
										   self.toggleLayer.frame.size.width,
										   self.toggleLayer.frame.size.height);
		}
		else
		{
			self.toggleLayer.frame = CGRectMake(minToggleX,
										   self.toggleLayer.frame.origin.y,
										   self.toggleLayer.frame.size.width,
										   self.toggleLayer.frame.size.height);
		}

		if (!self.toggleLayer.mask)
		{
			[self useLayerMasking];
			[self.toggleLayer setNeedsDisplay];
		}

		[self positionLayersAndMask];

		self.knobLayer.gripped = NO;

		[CATransaction setCompletionBlock:^{
			[self removeLayerMask];
			self.ignoreTap = NO;

			// send the action here so it get's sent at the end of the animations
			if (previousOn != on && !ignoreControlEvents)
				[self sendActionsForControlEvents:UIControlEventValueChanged];

			//[[self allTargets] makeObjectsPerformSelector:@selector(release)];
		}];

		[CATransaction commit];
	}];
}

- (void)setOnTintColor:(UIColor *)anOnTintColor
{
	if (anOnTintColor != onTintColor)
	{
		onTintColor = nil;//];
		onTintColor = anOnTintColor ;
		self.toggleLayer.onTintColor = anOnTintColor;
		[self.toggleLayer setNeedsDisplay];
	}
}

- (void)layoutSubviews;
{
	CGFloat knobRadius = self.bounds.size.height + 2.0;
	self.knobLayer.frame = CGRectMake(0, 0, knobRadius, knobRadius);
	CGSize toggleSize = CGSizeMake(self.bounds.size.width * 2 - (knobRadius - 4), self.bounds.size.height);
	CGFloat minToggleX = -toggleSize.width / 2.0 + knobRadius / 2.0 - 1;
	CGFloat maxToggleX = -1;

	if (self.on)
	{
		self.toggleLayer.frame = CGRectMake(maxToggleX,
									   self.toggleLayer.frame.origin.y,
									   toggleSize.width,
									   toggleSize.height);
	}
	else
	{
		self.toggleLayer.frame = CGRectMake(minToggleX,
									   self.toggleLayer.frame.origin.y,
									   toggleSize.width,
									   toggleSize.height);
	}

	[self positionLayersAndMask];
}

- (void)setOnText:(NSString *)newOnText
{
	if (newOnText != onText)
	{
		//[onText release];
        onText = nil;
		onText = [newOnText copy];
		self.toggleLayer.onString = onText;
		[self.toggleLayer setNeedsDisplay];
	}
}

- (void)setOffText:(NSString *)newOffText
{
	if (newOffText != offText)
	{
		//[offText release];
        offText = nil;
		offText = [newOffText copy];
		self.toggleLayer.offString = offText;
		[self.toggleLayer setNeedsDisplay];
	}
}

@end
