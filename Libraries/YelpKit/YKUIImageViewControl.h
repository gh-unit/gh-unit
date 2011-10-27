//
//  YKUIImageViewControl.h
//  YelpIPhone
//
//  Created by Gabriel Handford on 4/1/11.
//  Copyright 2011 Yelp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YKUIImageViewControl : UIControl { 
  UIImageView *_imageView;
}

@property (readonly, nonatomic) UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image highlightedImage:(UIImage *)highlightedImage;

@end