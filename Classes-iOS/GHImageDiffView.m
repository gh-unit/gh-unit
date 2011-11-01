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
    [scrollView_ release];

    segmentedControl_ = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
    [segmentedControl_ insertSegmentWithTitle:@"Original" atIndex:0 animated:NO];
    [segmentedControl_ insertSegmentWithTitle:@"New" atIndex:1 animated:NO];
    [segmentedControl_ insertSegmentWithTitle:@"Diff" atIndex:2 animated:NO];
    [segmentedControl_ addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:segmentedControl_];
    [segmentedControl_ release];

    originalImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    [scrollView_ addSubview:originalImageView_];
    [originalImageView_ release];

    newImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    [scrollView_ addSubview:newImageView_];
    [newImageView_ release];

    diffImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    [scrollView_ addSubview:diffImageView_];
    [diffImageView_ release];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  scrollView_.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

  segmentedControl_.frame = CGRectMake((self.frame.size.width - 300) / 2, self.frame.size.height - 40, 300, 30);
}

- (void)setOriginalImage:(UIImage *)originalImage newImage:(UIImage *)newImage diffImage:(UIImage *)diffImage {
  originalImageView_.image = originalImage;
  [originalImageView_ sizeToFit];
  [segmentedControl_ setEnabled:!!originalImage forSegmentAtIndex:0];
  newImageView_.image = newImage;
  [newImageView_ sizeToFit];
  [segmentedControl_ setEnabled:!!newImage forSegmentAtIndex:1];
  diffImageView_.image = diffImage;
  [diffImageView_ sizeToFit];
  [segmentedControl_ setEnabled:!!diffImage forSegmentAtIndex:2];
  scrollView_.contentSize = CGSizeMake(MAX(originalImage.size.width, newImage.size.width), MAX(originalImage.size.height, newImage.size.height));
}

- (void)showOriginalImage {
  originalImageView_.hidden = NO;
  newImageView_.hidden = YES;
  diffImageView_.hidden = YES;
  segmentedControl_.selectedSegmentIndex = 0;
}

- (void)showNewImage {
  originalImageView_.hidden = YES;
  newImageView_.hidden = NO;
  diffImageView_.hidden = YES;
  segmentedControl_.selectedSegmentIndex = 1;
}

- (void)showDiffImage {
  originalImageView_.hidden = YES;
  newImageView_.hidden = YES;
  diffImageView_.hidden = NO;
  segmentedControl_.selectedSegmentIndex = 2;
}

#pragma mark UISegmentedControl

- (void)segmentedControlDidChange:(UISegmentedControl *)segmentedControl {
  if (segmentedControl.selectedSegmentIndex == 0) [self showOriginalImage];
  else if (segmentedControl.selectedSegmentIndex == 1) [self showNewImage];
  else if (segmentedControl.selectedSegmentIndex == 2) [self showDiffImage];
}

@end
