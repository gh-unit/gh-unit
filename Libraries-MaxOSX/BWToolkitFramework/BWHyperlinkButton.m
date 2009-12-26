//
//  BWHyperlinkButton.m
//  BWToolkit
//
//  Created by Brandon Walkin (www.brandonwalkin.com)
//  All code is provided under the New BSD license.
//

#import "BWHyperlinkButton.h"
#import "BWHyperlinkButtonCell.h"

@implementation BWHyperlinkButton

-(void)awakeFromNib
{
}

- (void)resetCursorRects 
{
	[self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
}

@end
