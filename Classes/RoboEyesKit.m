//
//  RoboEyesKit.m
//  RoboEyesExample
//
//  Created by John Boiles on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RoboEyesKit.h"

@implementation RoboEyesKit

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (UIImage *)imageWithView:(UIView *)view {
  [view setNeedsDisplay];
  UIGraphicsBeginImageContext(view.frame.size);
  CALayer *layer = view.layer;
  CGContextRef context = UIGraphicsGetCurrentContext();
  [layer renderInContext:context];
  UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return viewImage;
}

- (void)saveToPhotoAlbumWithImage:(UIImage *)image {
  UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

+ (void)saveToDocumentsWithImage:(UIImage *)image name:(NSString *)name {
  // Create paths to output images
  NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.png", name]];
  NSLog(@"Saving test image to %@", pngPath);

  // Write image to PNG
  [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
}

+ (UIImage *)readImageWithName:(NSString *)name {
  // Create file manager
  NSError *error;
  NSFileManager *fileMgr = [NSFileManager defaultManager];

  // Point to Document directory
  NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
  
  // Write out the contents of home directory to console
  NSLog(@"Documents directory: %@\n%@", documentsDirectory, [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);

  NSString* fileName = [documentsDirectory stringByAppendingFormat:@"/%@.png", name];
  
  return [UIImage imageWithContentsOfFile:fileName];
}

/*
 Super ghetto image comparison
 */
+ (BOOL)compareImage:(UIImage *)image withNewImage:(UIImage *)newImage {
  if (!image || !newImage) return NO;
  if ((image.size.width != newImage.size.width) || (image.size.height != newImage.size.height)) return NO;
  // For some reason the CGImages weren't consistent when loading from png. Perhaps some transparency issue or something?
  // Possibly colorspace? Anyways, if you make them both pngs you can compare them
  //CFDataRef imageData = (__bridge CFDataRef)UIImagePNGRepresentation(image);
  //CFDataRef newImageData = (__bridge CFDataRef)UIImagePNGRepresentation(newImage);
  CFDataRef imageData = (CFDataRef)UIImagePNGRepresentation(image);
  CFDataRef newImageData = (CFDataRef)UIImagePNGRepresentation(newImage);
  const UInt32 *imagePixels = (const UInt32*)CFDataGetBytePtr(imageData);
  const UInt32 *newImagePixels = (const UInt32*)CFDataGetBytePtr(newImageData);
  for (int j = 0; j < CFDataGetLength(imageData) / 4; j++)
  {
    if (imagePixels[j] != newImagePixels[j])
    {
      NSLog(@"imagePixels[%d]: %x newImagePixels[%d]: %x", j, imagePixels[j], j, newImagePixels[j]);
      return NO;
    }
  }
  return YES;
  
}

@end
