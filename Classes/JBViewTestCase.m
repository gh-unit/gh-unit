//
//  JBViewTestCase.m
//  GHUnitIOS
//
//  Created by John Boiles on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "JBViewTestCase.h"
#import <QuartzCore/QuartzCore.h>

@interface JBViewTestCase ()
+ (NSString *)imagesDirectory;
+ (NSString *)pathForFilename:(NSString *)filename;
+ (void)createImagesDirectory;
+ (UIImage *)imageWithView:(UIView *)view;
+ (UIImage *)readImageWithFilename:(NSString *)name;
+ (BOOL)compareImage:(UIImage *)image withNewImage:(UIImage *)newImage;
@end

@implementation JBViewTestCase

+ (NSString *)imagesDirectory {
  return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TestImages"];
}

+ (NSString *)pathForFilename:(NSString *)filename {
  return [NSString stringWithFormat:@"%@/%@", [self imagesDirectory], filename];
}

+ (void)createImagesDirectory {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error = nil;
  [fileManager createDirectoryAtPath:[self imagesDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
  if (error) NSLog(@"Unable to create directory %@", [self imagesDirectory]);
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

+ (void)saveToDocumentsWithImage:(UIImage *)image filename:(NSString *)filename {
  NSString *filePath = [self pathForFilename:filename];
  NSLog(@"Saving test image to %@", filePath);
  // Save image as PNG
  [self createImagesDirectory];
  BOOL saved = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
  if (!saved) NSLog(@"Unable to save image to %@", filePath);
}

+ (UIImage *)readImageWithFilename:(NSString *)filename {
  NSString* filePath = [self pathForFilename:filename];
  NSLog(@"Trying to load image at path %@", filePath);
  // First look in the documents directory for the image
  UIImage *image = [UIImage imageWithContentsOfFile:filePath];
  // Otherwise look in the app bundle
  if (!image) {
    image = [UIImage imageNamed:filename];
  }
  return image;
}


// Delete all test images from the documents directory
+ (void)clearTestImages {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *directory = [self imagesDirectory];
  NSError *error = nil;
  for (NSString *file in [fileManager contentsOfDirectoryAtPath:directory error:&error]) {
    BOOL success = [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, file] error:&error];
    if (!success || error) {
      NSLog(@"Unable to delete file %@%@", directory, file);
    }
  }
}

 //! Super ghetto image comparison
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
    // XOR the pixels here?
    if (imagePixels[j] != newImagePixels[j])
    {
      NSLog(@"imagePixels[%d]: %x newImagePixels[%d]: %x", j, imagePixels[j], j, newImagePixels[j]);
      return NO;
    }
  }
  return YES;
}

- (void)_setUp {
  imageVerifyCount_ = 0;
}

// Check if a view is the same as it was last time
// If it isn't, raise an exception with both the new and old images
- (BOOL)verifyView:(UIView *)view {
  // View testing file names have the format [test class name]-[test selector name]-[# of verify in selector]-[view class name]
  NSString *filename = [NSString stringWithFormat:@"%@-%@-%d-%@.png", NSStringFromClass([self class]), NSStringFromSelector(currentSelector_), imageVerifyCount_, NSStringFromClass([view class])];
  NSLog(@"Filename will be %@", filename);
  UIImage *originalViewImage = [[self class] readImageWithFilename:filename];

  // If the view is a UIScrollView, size it to the content size
  if ([view isKindOfClass:[UIScrollView class]]) {
    UIScrollView *scrollView = (UIScrollView *)view;
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, scrollView.contentSize.width, scrollView.contentSize.height);
  }
  UIImage *newViewImage = [[self class] imageWithView:view];
  NSMutableDictionary *exceptionDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              newViewImage, @"NewImage",
                                              filename, @"ImageFilename",
                                              nil];
  if (!originalViewImage) {
    NSLog(@"No image available for filename %@", filename);
    //[[self class] saveToDocumentsWithImage:newViewImage filename:filename];
    [[NSException exceptionWithName:@"GHViewUnavailableException" reason:@"No image saved for view" userInfo:exceptionDictionary] raise];
    return NO;
  } else if (![[self class] compareImage:originalViewImage withNewImage:newViewImage]) {
    [exceptionDictionary setObject:originalViewImage forKey:@"OriginalImage"];
    [[NSException exceptionWithName:@"GHViewChangeException" reason:@"View has changed" userInfo:exceptionDictionary] raise];
    return NO;
  }
  imageVerifyCount_++;
  return YES;
}

@end
