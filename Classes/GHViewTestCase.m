//
//  GHViewTestCase.m
//  GHUnitIOS
//
//  Created by John Boiles on 10/20/11.
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

#import "GHViewTestCase.h"
#import <QuartzCore/QuartzCore.h>

@interface GHViewTestCase ()
+ (NSString *)imagesDirectory;
+ (NSString *)pathForFilename:(NSString *)filename;
+ (void)createImagesDirectory;
+ (UIImage *)imageWithView:(UIView *)view;
+ (UIImage *)readImageWithFilename:(NSString *)name;
+ (BOOL)compareImage:(UIImage *)image withNewImage:(UIImage *)newImage;
@end

@implementation GHViewTestCase

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
  if (image) NSLog(@"Found image in documents directory");
  if (!image) {
    image = [UIImage imageNamed:filename];
    if (image) NSLog(@"Found image in app bundle");
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
  CFDataRef imageData = (CFDataRef)UIImagePNGRepresentation(image);
  CFDataRef newImageData = (CFDataRef)UIImagePNGRepresentation(newImage);
  const UInt32 *imagePixels = (const UInt32*)CFDataGetBytePtr(imageData);
  const UInt32 *newImagePixels = (const UInt32*)CFDataGetBytePtr(newImageData);
  if (CFDataGetLength(imageData) != CFDataGetLength(newImageData)) NSLog(@"WARNING: images are different lengths");
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


typedef struct {
  unsigned char r, g, b, a;
} pixel;

+ (BOOL)compareImage2:(UIImage *)image withNewImage:(UIImage *)newImage {
  // If the images are different sizes, just fail
  if ((image.size.width != newImage.size.width) || (image.size.height != newImage.size.height)) {
    NSLog(@"Images are differnt sizes");
    return NO;
  }
  // Allocate a buffer big enough to hold all the pixels
  pixel *imagePixels = (pixel *) calloc(1, image.size.width * image.size.height * sizeof(pixel));
  pixel *newImagePixels = (pixel *) calloc(1, image.size.width * image.size.height * sizeof(pixel));
  
  if (!imagePixels || !newImagePixels) {
    NSLog(@"Unable to create pixel array for image comparieson.");
    return NO;
  }
  CGContextRef imageContext = CGBitmapContextCreate((void *)imagePixels,
                                                    image.size.width,
                                                    image.size.height,
                                                    8,
                                                    image.size.width * 4,
                                                    CGImageGetColorSpace(image.CGImage),
                                                    kCGImageAlphaPremultipliedLast
                                                    );
  CGContextRef newImageContext = CGBitmapContextCreate((void *)newImagePixels,
                                                       newImage.size.width,
                                                       newImage.size.height,
                                                       8,
                                                       newImage.size.width * 4,
                                                       CGImageGetColorSpace(newImage.CGImage),
                                                       kCGImageAlphaPremultipliedLast
                                                       );
  if (!imageContext || !imageContext) {
    NSLog(@"Unable to create image contexts for image comparison");
    return NO;
  }
  // Draw the image in the bitmap
  CGContextDrawImage(imageContext, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);
  CGContextDrawImage(newImageContext, CGRectMake(0.0f, 0.0f, newImage.size.width, newImage.size.height), newImage.CGImage);

  for (int x = 0; x < image.size.width; x++) {
    for (int y = 0; y < image.size.height; y++) {
      NSInteger pixelIndex = x * y;
      if ((imagePixels[pixelIndex].r != newImagePixels[pixelIndex].r)
          || (imagePixels[pixelIndex].g != newImagePixels[pixelIndex].g)
          || (imagePixels[pixelIndex].b != newImagePixels[pixelIndex].b)) {
        NSLog(@"Image was different at pixel (%d, %d). Old was (r%d, g%d, b%d), new was (r%d, g%d, b%d)", x, y,
              imagePixels[pixelIndex].r, imagePixels[pixelIndex].g, imagePixels[pixelIndex].b,
              newImagePixels[pixelIndex].r, newImagePixels[pixelIndex].g, newImagePixels[pixelIndex].b);
        CGContextRelease(imageContext);
        CGContextRelease(newImageContext);
        free(imagePixels);
        free(newImagePixels);
        return NO;
      }
    }
  }
  
  CGContextRelease(imageContext);
  CGContextRelease(newImageContext);
  free(imagePixels);
  free(newImagePixels);
  
  return YES;
}

- (void)_setUp {
  imageVerifyCount_ = 0;
}

- (BOOL)isCLIDisabled {
  // There seem to be some weird text rendering inconsistencies when views are rendered
  // when run from the command line, vs when views are rendered in the simulator. For now
  // We're only supporting tests in the simulator.
  return YES;
}

- (void)verifyView:(UIView *)view inFilename:(NSString *)filename atLineNumber:(int)lineNumber {
  // Fail if the view is nil
  if (!view) [[NSException ghu_failureInFile:filename atLine:lineNumber withDescription:@"View cannot be nil in GHVerifyView"] raise];
  // Fail if the view has CGSizeZero
  if (CGSizeEqualToSize(view.frame.size, CGSizeZero)) [[NSException ghu_failureInFile:filename atLine:lineNumber withDescription:@"View must have a nonzero size in GHVerifyView"] raise];
  // View testing file names have the format [test class name]-[test selector name]-[# of verify in selector]-[view class name]
  NSString *imageFilename = [NSString stringWithFormat:@"%@-%@-%d-%@.png", NSStringFromClass([self class]), NSStringFromSelector(currentSelector_), imageVerifyCount_, NSStringFromClass([view class])];
  UIImage *originalViewImage = [[self class] readImageWithFilename:imageFilename];

  // If the view is a UIScrollView, size it to the content size
  if ([view isKindOfClass:[UIScrollView class]]) {
    UIScrollView *scrollView = (UIScrollView *)view;
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, scrollView.contentSize.width, scrollView.contentSize.height);
  }

  UIImage *newViewImage = [[self class] imageWithView:view];
  NSMutableDictionary *exceptionDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              newViewImage, @"NewImage",
                                              imageFilename, @"ImageFilename",
                                              [NSNumber numberWithInteger:lineNumber], GHTestLineNumberKey,
                                              filename, GHTestFilenameKey,
                                              nil];
  if (!originalViewImage) {
    NSLog(@"No image available for filename %@", filename);
    [[NSException exceptionWithName:@"GHViewUnavailableException" reason:@"No image saved for view" userInfo:exceptionDictionary] raise];
  } else if (![[self class] compareImage2:originalViewImage withNewImage:newViewImage]) {
    [exceptionDictionary setObject:originalViewImage forKey:@"OriginalImage"];
    [[NSException exceptionWithName:@"GHViewChangeException" reason:@"View has changed" userInfo:exceptionDictionary] raise];
  }
  imageVerifyCount_++;
}

@end
