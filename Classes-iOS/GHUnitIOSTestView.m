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

    savedImageView_ = [[GHUIImageViewControl alloc] initWithFrame:CGRectMake(10, 10, 145, 100)];
    [savedImageView_ addTarget:self action:@selector(_selectSavedImage) forControlEvents:UIControlEventTouchUpInside];
    [savedImageView_.layer setBorderWidth:2.0];
    [savedImageView_.layer setBorderColor:[UIColor blackColor].CGColor];
    savedImageView_.hidden = YES;
    [self addSubview:savedImageView_];

    renderedImageView_ = [[GHUIImageViewControl alloc] initWithFrame:CGRectMake(165, 10, 145, 100)];
    [renderedImageView_ addTarget:self action:@selector(_selectRenderedImage) forControlEvents:UIControlEventTouchUpInside];
    [renderedImageView_.layer setBorderWidth:2.0];
    [renderedImageView_.layer setBorderColor:[UIColor blackColor].CGColor];
    renderedImageView_.hidden = YES;
    [self addSubview:renderedImageView_];

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
  CGRect savedImageFrame = CGRectZero;
  CGRect renderedImageFrame = CGRectZero;

  CGRect textLabelFrame = textLabel_.frame;
  textLabelFrame.size.height = [textLabel_.text sizeWithFont:textLabel_.font constrainedToSize:CGSizeMake(textLabel_.frame.size.width, 10000) lineBreakMode:UILineBreakModeWordWrap].height;
  textLabel_.frame = textLabelFrame;

  if (savedImageView_.image && !savedImageView_.hidden) {
    // Adjust image views to their sizes, maintaining constant width
    CGFloat aspectRatio = savedImageView_.image.size.height / savedImageView_.image.size.width;
    savedImageFrame = savedImageView_.frame;
    savedImageFrame.size.height = aspectRatio * savedImageFrame.size.width;
    savedImageView_.frame = savedImageFrame;
  }
  
  if (renderedImageView_.image && !renderedImageView_.hidden) {
    CGFloat aspectRatio = renderedImageView_.image.size.height / renderedImageView_.image.size.width;
    renderedImageFrame = renderedImageView_.frame;
    renderedImageFrame.size.height = aspectRatio * renderedImageFrame.size.width;
    renderedImageView_.frame = renderedImageFrame;
  }

  y += roundf(MAX(savedImageFrame.size.height, renderedImageFrame.size.height) + 10);

  if (!approveButton_.hidden) {
    approveButton_.frame = CGRectMake(10, y, 300, 30);
    y += 40;
  }

  CGRect textViewFrame = textLabel_.frame;
  textViewFrame.origin.y = y;
  textLabel_.frame = textViewFrame;
  
  self.contentSize = CGSizeMake(self.frame.size.width, textViewFrame.origin.y + textViewFrame.size.height + 10);
}

- (void)_selectSavedImage {
  [controlDelegate_ testViewDidSelectSavedImage:self];
}

- (void)_selectRenderedImage {
  [controlDelegate_ testViewDidSelectRenderedImage:self];  
}

- (void)_approveChange {
  [controlDelegate_ testViewDidApproveChange:self];
}

- (void)setSavedImage:(UIImage *)savedImage renderedImage:(UIImage *)renderedImage text:(NSString *)text {
  savedImageView_.image = savedImage;
  savedImageView_.hidden = savedImage ? NO : YES;
  renderedImageView_.image = renderedImage;
  renderedImageView_.hidden = NO;
  approveButton_.hidden = NO;
  textLabel_.text = text;
  [self _layout];
}

- (void)setText:(NSString *)text {
  savedImageView_.hidden = YES;
  renderedImageView_.hidden = YES;
  approveButton_.hidden = YES;
  textLabel_.text = text;
  [self _layout];
}

@end
