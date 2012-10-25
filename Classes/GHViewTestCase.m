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
#import "GHUnit.h"
#import <QuartzCore/QuartzCore.h>

typedef struct {
  unsigned char r, g, b, a;
} GHPixel;

@implementation GHViewTestCase

#pragma mark File Operations

+ (NSString *)approvedTestImagesDirectory {
  return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TestImages"];
}

+ (NSString *)failedTestImagesDirectory {
  return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/FailedTestImages"];
}

+ (NSString *)approvedTestImagePathForFilename:(NSString *)filename {
  return [NSString stringWithFormat:@"%@/%@", [self approvedTestImagesDirectory], filename];
}

+ (NSString *)failedTestImagePathForFilename:(NSString *)filename {
  return [NSString stringWithFormat:@"%@/%@", [self failedTestImagesDirectory], filename];
}

+ (void)createDirectory:(NSString *)directory {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error = nil;
  [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
  if (error) GHUDebug(@"Unable to create directory %@", directory);
}

+ (void)saveImage:(UIImage *)image filePath:(NSString *)filePath {
  GHUDebug(@"Saving image to %@", filePath);
  // Save image as PNG
  BOOL saved = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
  if (!saved) GHUDebug(@"Unable to save image to %@", filePath);
}

+ (void)saveApprovedViewTestImage:(UIImage *)image filename:(NSString *)filename {
  [self createDirectory:[self approvedTestImagesDirectory]];
  NSString *filePath = [self approvedTestImagePathForFilename:filename];
  [self saveImage:image filePath:filePath];
}

+ (void)saveFailedViewTestImage:(UIImage *)image filename:(NSString *)filename {
  [self createDirectory:[self failedTestImagesDirectory]];
  NSString *filePath = [self failedTestImagePathForFilename:filename];
  [self saveImage:image filePath:filePath];
}

+ (UIImage *)readSavedTestImageWithFilename:(NSString *)filename {
  NSString *filePath = [self approvedTestImagePathForFilename:filename];
  GHUDebug(@"Trying to load image at path %@", filePath);
  // First look in the documents directory for the image
  UIImage *image = [GHViewTestCase _imageFromFilePath:filePath];
  // Otherwise look in the app bundle
  if (image) GHUDebug(@"Found image in documents directory");
  if (!image) {
    NSString* extension = [filename pathExtension];
    filePath = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:extension];
    image = [GHViewTestCase _imageFromFilePath:filePath];
    if (image) GHUDebug(@"Found image in app bundle");
  }
  return image;
}

+ (void)deleteFilesAtPath:(NSString *)path {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error = nil;
  for (NSString *file in [fileManager contentsOfDirectoryAtPath:path error:&error]) {
    BOOL success = [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", path, file] error:&error];
    if (!success || error) {
      GHUDebug(@"Unable to delete file %@%@", path, file);
    }
  }
}

+ (void)clearTestImages {
  [self deleteFilesAtPath:[self approvedTestImagesDirectory]];
  [self deleteFilesAtPath:[self failedTestImagesDirectory]];
}

#pragma mark Image Operations

+ (UIImage *)imageWithView:(UIView *)view {
  [view setNeedsDisplay];
  UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
  CALayer *layer = view.layer;
  CGContextRef context = UIGraphicsGetCurrentContext();
  [layer renderInContext:context];
  UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return viewImage;
}

+ (BOOL)compareImage:(UIImage *)image withRenderedImage:(UIImage *)renderedImage {
  if (!image || !renderedImage) return NO;
  // If the images are different sizes, just fail
  if ((image.size.width != renderedImage.size.width) || (image.size.height != renderedImage.size.height)) {
    GHUDebug(@"Images are differnt sizes");
    return NO;
  }
  // Allocate a buffer big enough to hold all the pixels
  GHPixel *imagePixels = (GHPixel *) calloc(1, image.size.width * image.size.height * sizeof(GHPixel));
  GHPixel *renderedImagePixels = (GHPixel *) calloc(1, image.size.width * image.size.height * sizeof(GHPixel));
  
  if (!imagePixels || !renderedImagePixels) {
    GHUDebug(@"Unable to create pixel array for image comparison.");
    if (imagePixels) free(imagePixels);
    if (renderedImagePixels) free(renderedImagePixels);
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
  CGContextRef renderedImageContext = CGBitmapContextCreate((void *)renderedImagePixels,
                                                       renderedImage.size.width,
                                                       renderedImage.size.height,
                                                       8,
                                                       renderedImage.size.width * 4,
                                                       CGImageGetColorSpace(renderedImage.CGImage),
                                                       kCGImageAlphaPremultipliedLast
                                                       );
  if (!imageContext || !renderedImageContext) {
    GHUDebug(@"Unable to create image contexts for image comparison");
    CGContextRelease(imageContext);
    CGContextRelease(renderedImageContext);
    free(imagePixels);
    free(renderedImagePixels);
    return NO;
  }
  // Draw the image in the bitmap
  CGContextDrawImage(imageContext, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);
  CGContextDrawImage(renderedImageContext, CGRectMake(0.0f, 0.0f, renderedImage.size.width, renderedImage.size.height), renderedImage.CGImage);

  for (int x = 0; x < image.size.width; x++) {
    for (int y = 0; y < image.size.height; y++) {
      NSInteger pixelIndex = x * y;
      if ((imagePixels[pixelIndex].r != renderedImagePixels[pixelIndex].r)
          || (imagePixels[pixelIndex].g != renderedImagePixels[pixelIndex].g)
          || (imagePixels[pixelIndex].b != renderedImagePixels[pixelIndex].b)) {
        NSLog(@"Image was different at pixel (%d, %d). Old was (r%d, g%d, b%d), new was (r%d, g%d, b%d)", x, y,
              imagePixels[pixelIndex].r, imagePixels[pixelIndex].g, imagePixels[pixelIndex].b,
              renderedImagePixels[pixelIndex].r, renderedImagePixels[pixelIndex].g, renderedImagePixels[pixelIndex].b);
        CGContextRelease(imageContext);
        CGContextRelease(renderedImageContext);
        free(imagePixels);
        free(renderedImagePixels);
        return NO;
      }
    }
  }
  
  CGContextRelease(imageContext);
  CGContextRelease(renderedImageContext);
  free(imagePixels);
  free(renderedImagePixels);
  
  return YES;
}

+ (UIImage *)diffWithImage:(UIImage *)image renderedImage:(UIImage *)renderedImage {
  if (!image || !renderedImage) return nil;
  // Use the largest size and width
  CGSize imageSize = CGSizeMake(MAX(image.size.width, renderedImage.size.width), MAX(image.size.height, renderedImage.size.height));

  UIGraphicsBeginImageContext(imageSize);
  CGContextRef context = UIGraphicsGetCurrentContext();
  // Draw the original image
  [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
  // Overlay the new image inverted and at half alpha
  CGContextSetAlpha(context, 0.5f);
  CGContextBeginTransparencyLayer(context, NULL);
  [renderedImage drawInRect:CGRectMake(0, 0, renderedImage.size.width, renderedImage.size.height)];
  CGContextSetBlendMode(context, kCGBlendModeDifference);
  CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
  CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
  CGContextEndTransparencyLayer(context);
  UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return returnImage;
}

#pragma mark Private

- (void)_setUp {
  imageVerifyCount_ = 0;
}

+ (UIImage *)_imageFromFilePath:(NSString *)filePath {
  UIImage *image;
    
  NSData *imageData = [NSData dataWithContentsOfFile:filePath];
  CGFloat scale = [UIScreen mainScreen].scale;
  if ([UIImage respondsToSelector:@selector(imageWithData:scale:)]) {
    image = [UIImage imageWithData:imageData scale:scale];
  }
  else {
    UIImage *imageWithoutScale = [UIImage imageWithData:imageData];
    image = [UIImage imageWithCGImage:imageWithoutScale.CGImage scale:scale orientation:UIImageOrientationUp];
  }
  return image;
}

#pragma mark Public

- (CGSize)sizeForView:(UIView *)view {
  // If the view is a UIScrollView, return the contentSize
  if ([view isKindOfClass:[UIScrollView class]]) {
    UIScrollView *scrollView = (UIScrollView *)view;
    return scrollView.contentSize;
  }
  return view.frame.size;
}

- (void)verifyView:(UIView *)view filename:(NSString *)filename lineNumber:(int)lineNumber {
  // Fail if the view is nil
  if (!view) [[NSException ghu_failureInFile:filename atLine:lineNumber withDescription:@"View cannot be nil in GHVerifyView"] raise];

  CGSize viewSize = [self sizeForView:view];
  view.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);

  // Fail if the view has width == 0 or height == 0
  if (CGRectIsEmpty(view.frame)) {
    NSString *description = [NSString stringWithFormat:@"View must have a nonzero size in GHVerifyView (view.frame was %@)", NSStringFromCGRect(view.frame)];
    [[NSException ghu_failureInFile:filename atLine:lineNumber withDescription:description] raise];
  }

  // View testing file names have the format [test class name]-[test selector name]-[UIScreen scale]-[# of verify in selector]-[view class name]
  NSString *imageFilenamePrefix = [NSString stringWithFormat:@"%@-%@-%1.0f-%d-%@",
                                   NSStringFromClass([self class]),
                                   NSStringFromSelector(currentSelector_),
                                   [[UIScreen mainScreen] scale],
                                   imageVerifyCount_,
                                   NSStringFromClass([view class])];
  NSString *imageFilename = [imageFilenamePrefix stringByAppendingString:@".png"];
  UIImage *originalViewImage = [[self class] readSavedTestImageWithFilename:imageFilename];
  UIImage *newViewImage = [[self class] imageWithView:view];
  NSMutableDictionary *exceptionDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              newViewImage, @"RenderedImage",
                                              imageFilename, @"ImageFilename",
                                              [NSNumber numberWithInteger:lineNumber], GHTestLineNumberKey,
                                              filename, GHTestFilenameKey,
                                              nil];
  if (!originalViewImage) {
    GHUDebug(@"No image available for filename %@", filename);
    [[NSException exceptionWithName:@"GHViewUnavailableException" reason:@"No image saved for view" userInfo:exceptionDictionary] raise];
  } else if (![[self class] compareImage:originalViewImage withRenderedImage:newViewImage]) {
    UIImage *diffImage = [[self class] diffWithImage:originalViewImage renderedImage:newViewImage];
    if (diffImage) [exceptionDictionary setObject:diffImage forKey:@"DiffImage"];
    if (originalViewImage) [exceptionDictionary setObject:originalViewImage forKey:@"SavedImage"];
    // Save new and diff images
    [[self class] saveFailedViewTestImage:diffImage filename:[imageFilenamePrefix stringByAppendingString:@"-diff.png"]];
    [[self class] saveFailedViewTestImage:newViewImage filename:[imageFilenamePrefix stringByAppendingString:@"-new.png"]];
    [[NSException exceptionWithName:@"GHViewChangeException" reason:@"View has changed" userInfo:exceptionDictionary] raise];
  }
  imageVerifyCount_++;
}

@end
