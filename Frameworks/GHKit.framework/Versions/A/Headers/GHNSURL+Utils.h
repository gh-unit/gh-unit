//
//  GHNSURL+Utils.h
//
//  Created by Gabe on 3/19/08.
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

@interface NSURL (GHUtils)

/*!
 Get parameters (dictionary).
 */
- (NSDictionary *)gh_parameters;

/*!
 @method gh_paramsToString
 @abstract Dictionary to params string. Escapes any url specific characters.
 @param params Dictionary of key value params
 @result Param string, key1=value1&key2=value2
 */
+ (NSString *)gh_paramsToString:(NSDictionary *)params;

/*!
 @method gh_paramsToString
 @abstract Dictionary to params string. Escapes any url specific characters.
 @param params Dictionary of key value params
 @param sort Sort
 @result Param string, key1=value1&key2=value2
 */
+ (NSString *)gh_paramsToString:(NSDictionary *)params sort:(BOOL)sort;

/*!
 Convert url params to dictionary.
 @method gh_stringToParams
 @param string URL params string, key1=value1&key2=value2
 @result Dictionary
 */
+ (NSDictionary *)gh_stringToParams:(NSString *)string;

/*!
 Encode URL string.
 
  "~!@#$%^&*(){}[]=:/,;?+'\"\\" => ~!@#$%25%5E&*()%7B%7D%5B%5D=:/,;?+'%22%5C
 
 Doesn't encode: ~!@#$&*()=:/,;?+'
 Does encode: %^{}[]"\
 
 Should be the same as javascript's encodeURI().
 See http://xkr.us/articles/javascript/encode-compare/
 
 @method gh_encode
 @param s String to escape
 @result Encode string
 */
+ (NSString *)gh_encode:(NSString *)s;

/*!
 Encode URL string (for escaping url key/value params).
 
 "~!@#$%^&*(){}[]=:/,;?+'\"\\" => ~!%40%23%24%25%5E%26*()%7B%7D%5B%5D%3D%3A%2F%2C%3B%3F%2B'%22%5C
 
 Doesn't encode: ~!*()'
 Does encode: @#$%^&{}[]=:/,;?+"\
 
 Should be the same as javascript's encodeURIComponent().
 See http://xkr.us/articles/javascript/encode-compare/
 
 @method escapeAll
 @param s String to escape
 @result Encode string
 */
+ (NSString *)gh_encodeAll:(NSString *)s;

/*!
 Decode URL string.
 @param url URL string
 @result Decoded URL string
 */
+ (NSString *)gh_decode:(NSString *)url;

#ifndef TARGET_OS_IPHONE

/*!
 @method copyLinkToPasteboard
 @abstract Copy url to pasteboard
 */
- (void)gh_copyLinkToPasteboard;

/*!
 @method openFile
 @param path Path to open
 @abstract Open file path
 */
+ (void)gh_openFile:(NSString *)path;

/*!
 @method openContaingFolder
 @param path
 @abstract Open folder (in Finder probably) for file path.
 */
+ (void)gh_openContainingFolder:(NSString *)path;
#endif

@end
