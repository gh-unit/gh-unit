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
  if (error) GHUDebug(@"Unable to create directory %@", [self imagesDirectory]);
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
  GHUDebug(@"Saving view test image to %@", filePath);
  // Save image as PNG
  [self createImagesDirectory];
  BOOL saved = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
  if (!saved) GHUDebug(@"Unable to save image to %@", filePath);
}

+ (UIImage *)readImageWithFilename:(NSString *)filename {
  NSString* filePath = [self pathForFilename:filename];
  GHUDebug(@"Trying to load image at path %@", filePath);
  // First look in the documents directory for the image
  UIImage *image = [UIImage imageWithContentsOfFile:filePath];
  // Otherwise look in the app bundle
  if (image) GHUDebug(@"Found image in documents directory");
  if (!image) {
    image = [UIImage imageNamed:filename];
    if (image) GHUDebug(@"Found image in app bundle");
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
      GHUDebug(@"Unable to delete file %@%@", directory, file);
    }
  }
}

+ (BOOL)compareImage:(UIImage *)image withNewImage:(UIImage *)newImage {
  if (!image || !newImage) return NO;
  // If the images are different sizes, just fail
  if ((image.size.width != newImage.size.width) || (image.size.height != newImage.size.height)) {
    GHUDebug(@"Images are differnt sizes");
    return NO;
  }
  // Allocate a buffer big enough to hold all the pixels
  GHPixel *imagePixels = (GHPixel *) calloc(1, image.size.width * image.size.height * sizeof(GHPixel));
  GHPixel *newImagePixels = (GHPixel *) calloc(1, image.size.width * image.size.height * sizeof(GHPixel));
  
  if (!imagePixels || !newImagePixels) {
    GHUDebug(@"Unable to create pixel array for image comparieson.");
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
  if (!imageContext || !newImageContext) {
    GHUDebug(@"Unable to create image contexts for image comparison");
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

+ (UIImage *)diffWithImage:(UIImage *)image newImage:(UIImage *)newImage {
  if (!image || !newImage) return nil;
  // Use the largest size and width
  CGSize imageSize = CGSizeMake(MAX(image.size.width, newImage.size.width), MAX(image.size.height, newImage.size.height));

  UIGraphicsBeginImageContext(imageSize);
  CGContextRef context = UIGraphicsGetCurrentContext();
  // Draw the original image
  [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
  // Overlay the new image inverted and at half alpha
  CGContextSetAlpha(context, 0.5);
  CGContextBeginTransparencyLayer(context, NULL);
  [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
  CGContextSetBlendMode(context, kCGBlendModeDifference);
  CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
  CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
  CGContextEndTransparencyLayer(context);
  UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return returnImage;
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
  // Fail if the view has CGSizeZero
  if (CGSizeEqualToSize(view.frame.size, CGSizeZero)) [[NSException ghu_failureInFile:filename atLine:lineNumber withDescription:@"View must have a nonzero size in GHVerifyView"] raise];

  // View testing file names have the format [test class name]-[test selector name]-[# of verify in selector]-[view class name]
  NSString *imageFilename = [NSString stringWithFormat:@"%@-%@-%d-%@.png", NSStringFromClass([self class]), NSStringFromSelector(currentSelector_), imageVerifyCount_, NSStringFromClass([view class])];
  UIImage *originalViewImage = [[self class] readImageWithFilename:imageFilename];

  CGSize viewSize = [self sizeForView:view];
  view.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);

  UIImage *newViewImage = [[self class] imageWithView:view];
  NSMutableDictionary *exceptionDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              newViewImage, @"NewImage",
                                              imageFilename, @"ImageFilename",
                                              [NSNumber numberWithInteger:lineNumber], GHTestLineNumberKey,
                                              filename, GHTestFilenameKey,
                                              nil];
  if (!originalViewImage) {
    GHUDebug(@"No image available for filename %@", filename);
    [[NSException exceptionWithName:@"GHViewUnavailableException" reason:@"No image saved for view" userInfo:exceptionDictionary] raise];
  } else if (![[self class] compareImage:originalViewImage withNewImage:newViewImage]) {
    UIImage *diffImage = [[self class] diffWithImage:originalViewImage newImage:newViewImage];
    [exceptionDictionary setObject:diffImage forKey:@"DiffImage"];
    [exceptionDictionary setObject:originalViewImage forKey:@"OriginalImage"];
    [[NSException exceptionWithName:@"GHViewChangeException" reason:@"View has changed" userInfo:exceptionDictionary] raise];
  }
  imageVerifyCount_++;
}

@end
