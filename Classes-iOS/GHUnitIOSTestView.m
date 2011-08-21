//
//  GHUnitIOSTestView.m
//  GHUnitIOS
//
//  Created by John Boiles on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GHUnitIOSTestView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GHUnitIOSTestView

@synthesize controlDelegate=controlDelegate_;

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor whiteColor];

    textLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 100)];
    textLabel_.font = [UIFont systemFontOfSize:12];
    textLabel_.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    textLabel_.textColor = [UIColor blackColor];
    textLabel_.numberOfLines = 0;
    [self addSubview:textLabel_];
    [textLabel_ release];

    originalImageView_ = [[YKUIImageViewControl alloc] initWithFrame:CGRectMake(10, 10, 145, 100)];
    [originalImageView_ addTarget:self action:@selector(_selectOriginalImage) forControlEvents:UIControlEventTouchUpInside];
    [originalImageView_.layer setBorderWidth:2.0];
    [originalImageView_.layer setBorderColor:[UIColor blackColor].CGColor];
    originalImageView_.hidden = YES;
    [self addSubview:originalImageView_];
    [originalImageView_ release];

    newImageView_ = [[YKUIImageViewControl alloc] initWithFrame:CGRectMake(165, 10, 145, 100)];
    [newImageView_ addTarget:self action:@selector(_selectNewImage) forControlEvents:UIControlEventTouchUpInside];
    [newImageView_.layer setBorderWidth:2.0];
    [newImageView_.layer setBorderColor:[UIColor blackColor].CGColor];
    newImageView_.hidden = YES;
    [self addSubview:newImageView_];
    [newImageView_ release];
  }
  return self;
}

/*
 Real layout is not in layoutSubviews since scrollviews call layoutSubviews on every frame
 */
- (void)_layout {
  CGFloat y = 10;
  CGRect originalImageFrame = CGRectZero;
  CGRect newImageFrame = CGRectZero;

  CGRect textLabelFrame = textLabel_.frame;
  textLabelFrame.size.height = [textLabel_.text sizeWithFont:textLabel_.font constrainedToSize:CGSizeMake(textLabel_.frame.size.width, 10000) lineBreakMode:UILineBreakModeWordWrap].height;
  textLabel_.frame = textLabelFrame;

  if (originalImageView_.image && !originalImageView_.hidden) {
    // Adjust image views to their sizes, maintaining constant width
    CGFloat aspectRatio = originalImageView_.image.size.height / originalImageView_.image.size.width;
    originalImageFrame = originalImageView_.frame;
    originalImageFrame.size.height = aspectRatio * originalImageFrame.size.width;
    originalImageView_.frame = originalImageFrame;
  }
  
  if (newImageView_.image && !newImageView_.hidden) {
    CGFloat aspectRatio = newImageView_.image.size.height / newImageView_.image.size.width;
    newImageFrame = newImageView_.frame;
    newImageFrame.size.height = aspectRatio * newImageFrame.size.width;
    newImageView_.frame = newImageFrame;
  }
  
  CGRect textViewFrame = textLabel_.frame;
  textViewFrame.origin.y = y + MAX(originalImageFrame.size.height, newImageFrame.size.height) + 10;
  textLabel_.frame = textViewFrame;
  
  self.contentSize = CGSizeMake(self.frame.size.width, textViewFrame.origin.y + textViewFrame.size.height + 10);
}

- (void)_selectOriginalImage {
  [controlDelegate_ testViewDidSelectOriginalImage:self];
}

- (void)_selectNewImage {
  [controlDelegate_ testViewDidSelectNewImage:self];  
}

- (void)setOriginalImage:(UIImage *)originalImage newImage:(UIImage *)newImage text:(NSString *)text {
  originalImageView_.image = originalImage;
  originalImageView_.hidden = NO;
  newImageView_.image = newImage;
  newImageView_.hidden = NO;
  textLabel_.text = text;
  [self _layout];
}

- (void)setText:(NSString *)text {
  originalImageView_.hidden = YES;
  newImageView_.hidden = YES;
  textLabel_.text = text;
  [self _layout];
}

@end
