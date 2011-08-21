//
//  RoboEyesKit.h
//  RoboEyesExample
//
//  Created by John Boiles on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RoboEyesKit : NSObject

+ (UIImage *)imageWithView:(UIView *)view;

- (void)saveToPhotoAlbumWithImage:(UIImage *)image;

+ (void)saveToDocumentsWithImage:(UIImage *)image name:(NSString *)name;

+ (UIImage *)readImageWithName:(NSString *)name;

+ (BOOL)compareImage:(UIImage *)image withNewImage:(UIImage *)newImage;

@end
