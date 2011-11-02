//
//  YKUIImageViewControl.m
//  YelpIPhone
//
//  Created by Gabriel Handford on 4/1/11.
//  Copyright 2011 Yelp. All rights reserved.
//

#import "YKUIImageViewControl.h"


@implementation YKUIImageViewControl

@dynamic image;
@synthesize imageView=_imageView;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _imageView = [[UIImageView alloc] init];
    [self addSubview:_imageView];
    [_imageView release];  
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
  if ((self = [super initWithFrame:frame])) {
    _imageView = [[UIImageView alloc] initWithImage:image highlightedImage:highlightedImage];
    [self addSubview:_imageView];
    [_imageView release];  
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _imageView.frame = self.bounds;
}

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  _imageView.highlighted = highlighted;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
  return _imageView;
}

@end
