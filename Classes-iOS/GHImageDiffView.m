//
//  GHImageDiffView.m
//  GHUnitIOS
//
//  Created by John Boiles on 10/27/11.
//  Copyright (c) 2011. All rights reserved.
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

#import "GHImageDiffView.h"

@implementation GHImageDiffView

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    scrollView_ = [[UIScrollView alloc] initWithFrame:CGRectZero];
    scrollView_.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    scrollView_.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    [self addSubview:scrollView_];

    segmentedControl_ = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
    [segmentedControl_ insertSegmentWithTitle:@"Saved" atIndex:0 animated:NO];
    [segmentedControl_ insertSegmentWithTitle:@"New" atIndex:1 animated:NO];
    [segmentedControl_ insertSegmentWithTitle:@"Diff" atIndex:2 animated:NO];
    [segmentedControl_ addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:segmentedControl_];

    savedImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    [scrollView_ addSubview:savedImageView_];

    renderedImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    [scrollView_ addSubview:renderedImageView_];

    diffImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    [scrollView_ addSubview:diffImageView_];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  scrollView_.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

  segmentedControl_.frame = CGRectMake((self.frame.size.width - 300) / 2, self.frame.size.height - 40, 300, 30);
}

- (void)setSavedImage:(UIImage *)savedImage renderedImage:(UIImage *)renderedImage diffImage:(UIImage *)diffImage {
  savedImageView_.image = savedImage;
  [savedImageView_ sizeToFit];
  [segmentedControl_ setEnabled:!!savedImage forSegmentAtIndex:0];
  renderedImageView_.image = renderedImage;
  [renderedImageView_ sizeToFit];
  [segmentedControl_ setEnabled:!!renderedImage forSegmentAtIndex:1];
  diffImageView_.image = diffImage;
  [diffImageView_ sizeToFit];
  [segmentedControl_ setEnabled:!!diffImage forSegmentAtIndex:2];
  scrollView_.contentSize = CGSizeMake(MAX(savedImage.size.width, renderedImage.size.width), MAX(savedImage.size.height, renderedImage.size.height));
}

- (void)showSavedImage {
  savedImageView_.hidden = NO;
  renderedImageView_.hidden = YES;
  diffImageView_.hidden = YES;
  segmentedControl_.selectedSegmentIndex = 0;
}

- (void)showRenderedImage {
  savedImageView_.hidden = YES;
  renderedImageView_.hidden = NO;
  diffImageView_.hidden = YES;
  segmentedControl_.selectedSegmentIndex = 1;
}

- (void)showDiffImage {
  savedImageView_.hidden = YES;
  renderedImageView_.hidden = YES;
  diffImageView_.hidden = NO;
  segmentedControl_.selectedSegmentIndex = 2;
}

#pragma mark UISegmentedControl

- (void)segmentedControlDidChange:(UISegmentedControl *)segmentedControl {
  if (segmentedControl.selectedSegmentIndex == 0) [self showSavedImage];
  else if (segmentedControl.selectedSegmentIndex == 1) [self showRenderedImage];
  else if (segmentedControl.selectedSegmentIndex == 2) [self showDiffImage];
}

@end
