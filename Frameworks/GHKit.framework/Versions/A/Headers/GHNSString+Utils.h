//
//  GHNSString+Utils.h
//
//  Copyright 2008 Gabriel Handford
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

@interface NSString (GHUtils)

- (BOOL)gh_isBlank;
- (NSString *)gh_strip;
+ (BOOL)gh_isBlank:(NSString *)s;

#ifndef TARGET_OS_IPHONE
- (NSAttributedString *)gh_truncateMiddle;
- (NSString *)gh_mimeTypeForExtension;
#endif

- (BOOL)gh_containsCharacters:(NSString *)characters;
- (BOOL)gh_containsAny:(NSCharacterSet *)charSet;
- (BOOL)gh_only:(NSCharacterSet *)charSet;
- (BOOL)gh_startsWithAny:(NSCharacterSet *)charSet;
- (BOOL)gh_startsWith:(NSString *)startsWith;
- (BOOL)gh_startsWith:(NSString *)startsWith options:(NSStringCompareOptions)options;
- (BOOL)gh_endsWith:(NSString *)endsWith options:(NSStringCompareOptions)options;
- (BOOL)gh_contains:(NSString *)contains options:(NSStringCompareOptions)options;

- (NSString *)gh_attributize;

- (NSString *)gh_fullPathExtension;

+ (NSMutableCharacterSet *)gh_characterSetsUnion:(NSArray *)characterSets;
+ (NSString *)gh_uuid;

/*!
 @method gh_lastSplitWithString
 @abstract 
   Get last part of string separated by the specified string. For example, [@"foo:bar" gh_splitWithString:@":"] => bar
   If no string is found, returns self.
 
 @param s String to split on
 @param options Options
 @result Last part of string split by string. 
*/
- (NSString *)gh_lastSplitWithString:(NSString *)s options:(NSStringCompareOptions)options;

/*!
 @method gh_cutWithString
 @abstract Cuts the word up. Like split, but all the characters are kept.
   For example, [@"foo:bar" gh_cutWithString:@":"] => [ "foo:", "bar" ]
 @param s String to cut on
 @param options Options
 @result String cut up into array
*/
- (NSArray *)gh_cutWithString:(NSString *)cutWith options:(NSStringCompareOptions)options;

/*!
 @method gh_subStringSegmentsWithinStart
 @param start Start token
 @param end End token
 @result Array of GHStringSegment's
 
 Use a regex engine if you can. 
 Note: This exists because regex.h is posix only and does not support non-greedy expressions.
 Why Apple must you not give us objc regex library?
 
 Get string segments, within start and end tokens.
 For example,
	[@"This is <START>a test<END> string" subStringSegmentsWithinStart:@"<START>" end:@"<END>"] => [@"This is ", @"a test", @" string"]
 
 */
- (NSArray *)gh_substringSegmentsWithinStart:(NSString *)start end:(NSString *)end;

@end

/*!
 Class used by gh_substringSegmentsWithinStart:end:
 */
@interface GHStringSegment : NSObject {
	NSString *string_;
	BOOL isMatch_;
}


@property (readonly) NSString *string;
@property (readonly, getter=isMatch) BOOL match;

- (id)initWithString:(NSString *)string isMatch:(BOOL)isMatch;

+ (GHStringSegment *)string:(NSString *)string isMatch:(BOOL)isMatch;

@end
