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

static const CGFloat kOverlayViewVerticalMargin = 10.0;

@interface GHUnitIOSTestOverlayView : UIView

@property (strong, nonatomic) UIButton *runButton;
@property (strong, nonatomic) UILabel *passLabel;
@property (strong, nonatomic) NSAttributedString *passString;
@property (strong, nonatomic) NSAttributedString *failString;

- (void)setPasses:(BOOL)passes;

@end


@interface GHUnitIOSTestView ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) GHUnitIOSTestOverlayView *overlayView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) GHUIImageViewControl *savedImageView;
@property (strong, nonatomic) GHUIImageViewControl *renderedImageView;
@property (strong, nonatomic) UIButton *approveButton;
@property (strong, nonatomic) UILabel *textLabel;

@property (strong, nonatomic) NSMutableArray *updateableConstraints;

@end

@implementation GHUnitIOSTestView

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_scrollView];
    
    _overlayView = [[GHUnitIOSTestOverlayView alloc] init];
    [_overlayView.runButton addTarget:self action:@selector(_runTest) forControlEvents:UIControlEventTouchUpInside];
    _overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_overlayView];
    
    _contentView = [[UIView alloc] init];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_contentView];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.font = [UIFont systemFontOfSize:12];
    _textLabel.textColor = [UIColor blackColor];
    _textLabel.numberOfLines = 0;
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_textLabel];
    
    _savedImageView = [[GHUIImageViewControl alloc] init];
    [_savedImageView addTarget:self action:@selector(_selectSavedImage) forControlEvents:UIControlEventTouchUpInside];
    [_savedImageView.layer setBorderWidth:2.0];
    [_savedImageView.layer setBorderColor:[UIColor blackColor].CGColor];
    _savedImageView.hidden = YES;
    _savedImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_savedImageView];
    
    _renderedImageView = [[GHUIImageViewControl alloc] init];
    [_renderedImageView addTarget:self action:@selector(_selectRenderedImage) forControlEvents:UIControlEventTouchUpInside];
    [_renderedImageView.layer setBorderWidth:2.0];
    [_renderedImageView.layer setBorderColor:[UIColor blackColor].CGColor];
    _renderedImageView.hidden = YES;
    _renderedImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_renderedImageView];
    
    _approveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_approveButton addTarget:self action:@selector(_approveChange) forControlEvents:UIControlEventTouchUpInside];
    _approveButton.hidden = YES;
    [_approveButton setTitle:@"Approve this change" forState:UIControlStateNormal];
    _approveButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    _approveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_approveButton];
    
    _updateableConstraints = [[NSMutableArray alloc] init];
    [self _installConstraints];
    
    [_scrollView bringSubviewToFront:_overlayView];
  }
  return self;
}

- (void)_installConstraints {
  NSDictionary *views = NSDictionaryOfVariableBindings(self, _overlayView, _scrollView, _contentView, _textLabel, _savedImageView, _renderedImageView, _approveButton);
  
  // Pin the overlay view to self so that it doesn't scroll with the scroll view
  NSArray *overlayViewConstraints = @[
                                      [NSLayoutConstraint constraintWithItem:_overlayView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                                      [NSLayoutConstraint constraintWithItem:_overlayView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                                      [NSLayoutConstraint constraintWithItem:_overlayView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]
                                      ];
  [self addConstraints:overlayViewConstraints];
  
  // Fill up self with the scroll view
  NSMutableArray *scrollViewConstraints = [NSMutableArray array];
  [scrollViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:views]];
  [scrollViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:views]];
  [self addConstraints:scrollViewConstraints];
  
  // Pin the content view to the scrollview, leaving space for the overlay view, and set the width of the content view
  NSMutableArray *contentViewConstraints = [NSMutableArray array];
  [contentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(overlayHeight)-[_contentView]|" options:0
                                                                                     metrics:@{
                                                                                               @"overlayHeight": @([_overlayView intrinsicContentSize].height)
                                                                                               }
                                                                                        views:views]];
  [contentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView(320)]|" options:0 metrics:nil views:views]];
  [_scrollView addConstraints:contentViewConstraints];
  
  // Pin the text label to the bottom of the content view
  NSMutableArray *textLabelConstraints = [NSMutableArray array];
  [textLabelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_textLabel]-10-|" options:0 metrics:nil views:views]];
  [textLabelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textLabel]-10-|" options:0 metrics:nil views:views]];
  [_contentView addConstraints:textLabelConstraints];
  
  // Pin the approve button horizontally over the content view
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_approveButton]-10-|" options:0 metrics:nil views:views]];
  
  // Pin the saved image view to the left of the rendered image view inside the content view, top align them
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_savedImageView]-[_renderedImageView]" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
}

- (void)updateConstraints {
  NSDictionary *views = NSDictionaryOfVariableBindings(self, _contentView, _textLabel, _savedImageView, _renderedImageView, _approveButton);
  
  [self.contentView removeConstraints:self.updateableConstraints];
  [self.updateableConstraints removeAllObjects];
  
  if (self.savedImageView.hidden && self.renderedImageView.hidden) {
    // No images to show, the text label goes at the top
    [self.updateableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textLabel]" options:0 metrics:nil views:views]];
  } else {
    if (self.approveButton.hidden) {
      // Approve button hidden, so the image views get pinned to the top
      [self.updateableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_savedImageView]" options:0 metrics:nil views:views]];
    } else {
      // The approve button is showing so it's on top, then the image views
      [self.updateableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_approveButton]-10-[_savedImageView]" options:0 metrics:nil views:views]];
    }
    
    // Ensure the text label is spaced away from the larger of the two image views
    [self.updateableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_savedImageView]-(>=10)-[_textLabel]" options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    [self.updateableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_renderedImageView]-(>=10)-[_textLabel]" options:0 metrics:nil views:views]];
    
    // Size the image views based on the image aspect ratio - if there is only a saved image view showing (passed test) render it full width of the content view
    if (!self.savedImageView.hidden) {
      CGFloat width = self.renderedImageView.hidden ? 300.0 : 145.0;
      CGFloat aspectRatio = self.savedImageView.image.size.height / self.savedImageView.image.size.width;
      CGFloat height = aspectRatio * width;
      [self.updateableConstraints addObject:[NSLayoutConstraint constraintWithItem:self.savedImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:height]];
      [self.updateableConstraints addObject:[NSLayoutConstraint constraintWithItem:self.savedImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:width]];
    }
    
    if (!self.renderedImageView.hidden) {
      CGFloat width = 145.0;
      CGFloat aspectRatio = self.renderedImageView.image.size.height / self.renderedImageView.image.size.width;
      CGFloat height = aspectRatio * width;
      [self.updateableConstraints addObject:[NSLayoutConstraint constraintWithItem:self.renderedImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:height]];
      [self.updateableConstraints addObject:[NSLayoutConstraint constraintWithItem:self.renderedImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:width]];
    }
  }
  
  [_contentView addConstraints:self.updateableConstraints];
  [super updateConstraints];
}

- (void)_selectSavedImage {
  [self.controlDelegate testViewDidSelectSavedImage:self];
}

- (void)_selectRenderedImage {
  [self.controlDelegate testViewDidSelectRenderedImage:self];
}

- (void)_approveChange {
  [self.controlDelegate testViewDidApproveChange:self];
}

- (void)_runTest {
  [self.controlDelegate testViewDidRunTest:self];
}

- (void)setSavedImage:(UIImage *)savedImage renderedImage:(UIImage *)renderedImage text:(NSString *)text {
  self.savedImageView.image = savedImage;
  self.savedImageView.hidden = savedImage ? NO : YES;
  self.savedImageView.userInteractionEnabled = YES;
  self.renderedImageView.image = renderedImage;
  self.renderedImageView.hidden = NO;
  self.approveButton.hidden = NO;
  self.textLabel.text = text;
  [self setNeedsUpdateConstraints];
}

- (void)setText:(NSString *)text {
  self.savedImageView.hidden = YES;
  self.renderedImageView.hidden = YES;
  self.approveButton.hidden = YES;
  self.textLabel.text = text;
  [self setNeedsUpdateConstraints];
}

- (void)setPassingImage:(UIImage *)passingImage {
  self.savedImageView.image = passingImage;
  self.savedImageView.hidden = NO;
  self.savedImageView.userInteractionEnabled = NO;
  [self setNeedsUpdateConstraints];
}

- (void)setPasses:(BOOL)passes {
  [self.overlayView setPasses:passes];
}

@end


@implementation GHUnitIOSTestOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    
    _passLabel = [[UILabel alloc] init];
    _passLabel.textAlignment = NSTextAlignmentCenter;
    _passLabel.backgroundColor = [UIColor clearColor];
    _passLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_passLabel];
    _passString = [[NSAttributedString alloc] initWithString:@"PASS" attributes:@{
                                                                                  NSFontAttributeName: [UIFont boldSystemFontOfSize:20],
                                                                                  NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.7 blue:0.0 alpha:1.0]
                                                                                  }];
    _failString = [[NSAttributedString alloc] initWithString:@"FAIL" attributes:@{
                                                                                  NSFontAttributeName: [UIFont boldSystemFontOfSize:20],
                                                                                  NSForegroundColorAttributeName: [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0]
                                                                                  }];
    _runButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_runButton setTitle:@"Re-run" forState:UIControlStateNormal];
    _runButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    _runButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_runButton];
    
    [self _installConstraints];
  }
  return self;
}

- (void)_installConstraints {
  NSDictionary *views = NSDictionaryOfVariableBindings(_passLabel, _runButton);
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_passLabel]-[_runButton]-10-|" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalMargin-[_passLabel(==_runButton)]-verticalMargin-|"
                                                               options:0
                                                               metrics:@{
                                                                         @"verticalMargin": @(kOverlayViewVerticalMargin)
                                                                         }
                                                                 views:views]];
}

- (CGSize)intrinsicContentSize {
  return CGSizeMake(UIViewNoIntrinsicMetric, _runButton.intrinsicContentSize.height + kOverlayViewVerticalMargin*2);
}

- (void)setPasses:(BOOL)passes {
  self.passLabel.attributedText = passes ? self.passString : self.failString;
}

@end
