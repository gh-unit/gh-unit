//
//  GHUnitIOSTestView.h
//  GHUnitIOS
//
//  Created by John Boiles on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YKUIImageViewControl.h"

@class GHUnitIOSTestView;

@protocol GHUnitIOSTestViewDelegate <NSObject>
- (void)testViewDidSelectOriginalImage:(GHUnitIOSTestView *)testView;
- (void)testViewDidSelectNewImage:(GHUnitIOSTestView *)testView;
@end

@interface GHUnitIOSTestView : UIScrollView {
  id<GHUnitIOSTestViewDelegate> controlDelegate_;

  UILabel *textLabel_;
  YKUIImageViewControl *originalImageView_;
  YKUIImageViewControl *newImageView_;
}
@property(assign, nonatomic) id<GHUnitIOSTestViewDelegate> controlDelegate;

- (void)setOriginalImage:(UIImage *)originalImage newImage:(UIImage *)newImage text:(NSString *)text;

- (void)setText:(NSString *)text;

@end
