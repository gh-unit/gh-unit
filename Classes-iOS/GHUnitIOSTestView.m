//
//  GHUnitIOSTestView.m
//  GHUnitIOS
//
//  Created by John Boiles on 8/8/11.
//  Copyright 2011. All rights reserved.
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

#import "GHUnitIOSTestView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GHUnitIOSTestView

@synthesize controlDelegate=controlDelegate_;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = [UIColor whiteColor];

    textLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 100)];
    textLabel_.font = [UIFont systemFontOfSize:12];
    textLabel_.textColor = [UIColor blackColor];
    textLabel_.numberOfLines = 0;
    [self addSubview:textLabel_];
    [textLabel_ release];

    originalImageView_ = [[YKUIImageViewControl alloc] initWithFrame:CGRectMake(10, 10, 145, 100)];
    [originalImageView_ addTarget:self action:@selector(_selectOriginalImage) forControlEvents:UIControlEventTouchUpInside];
    [originalImageView_.layer setBorderWidth:2.0f];
    [originalImageView_.layer setBorderColor:[UIColor blackColor].CGColor];
    originalImageView_.hidden = YES;
    [self addSubview:originalImageView_];
    [originalImageView_ release];

    newImageView_ = [[YKUIImageViewControl alloc] initWithFrame:CGRectMake(165, 10, 145, 100)];
    [newImageView_ addTarget:self action:@selector(_selectNewImage) forControlEvents:UIControlEventTouchUpInside];
    [newImageView_.layer setBorderWidth:2.0f];
    [newImageView_.layer setBorderColor:[UIColor blackColor].CGColor];
    newImageView_.hidden = YES;
    [self addSubview:newImageView_];
    [newImageView_ release];

    approveButton_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [approveButton_ addTarget:self action:@selector(_approveChange) forControlEvents:UIControlEventTouchUpInside];
    approveButton_.hidden = YES;
    [approveButton_ setTitle:@"Approve this change" forState:UIControlStateNormal];
    [approveButton_ setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    approveButton_.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    [self addSubview:approveButton_];
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

  y += MAX(originalImageFrame.size.height, newImageFrame.size.height) + 10;

  if (!approveButton_.hidden) {
    approveButton_.frame = CGRectMake(10, y, 300, 30);
    y += 40;
  }

  CGRect textViewFrame = textLabel_.frame;
  textViewFrame.origin.y = y;
  textLabel_.frame = textViewFrame;
  
  self.contentSize = CGSizeMake(self.frame.size.width, textViewFrame.origin.y + textViewFrame.size.height + 10);
}

- (void)_selectOriginalImage {
  [controlDelegate_ testViewDidSelectOriginalImage:self];
}

- (void)_selectNewImage {
  [controlDelegate_ testViewDidSelectNewImage:self];  
}

- (void)_approveChange {
  [controlDelegate_ testViewDidApproveChange:self];
}

- (void)setOriginalImage:(UIImage *)originalImage newImage:(UIImage *)newImage text:(NSString *)text {
  originalImageView_.image = originalImage;
  originalImageView_.hidden = originalImage ? NO : YES;
  newImageView_.image = newImage;
  newImageView_.hidden = NO;
  approveButton_.hidden = NO;
  textLabel_.text = text;
  [self _layout];
}

- (void)setText:(NSString *)text {
  originalImageView_.hidden = YES;
  newImageView_.hidden = YES;
  approveButton_.hidden = YES;
  textLabel_.text = text;
  [self _layout];
}

@end
