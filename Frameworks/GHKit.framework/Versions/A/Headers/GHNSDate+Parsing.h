//
//  GHNSDate+Parsing.h
//
//  Created by Gabe on 3/18/08.
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

@interface NSDate (GHParsing)

+ (NSDate *)gh_parseISO8601:(NSString *)dateString;

/*!
 @method gh_parseRFC822
 @abstract Parse RFC822 encoded date
 @param dateString Date string to parse, eg. 'Wed, 01 Mar 2006 12:00:00 -0400'
 @result Date
*/
+ (NSDate *)gh_parseRFC822:(NSString *)dateString;

/*!
 @method gh_parseHTTP
 @abstract Parse http date, currently only handles RFC1123 date
 @param dateString Date string to parse
 
 HTTP-date    = rfc1123-date | rfc850-date | asctime-date
 
 Sun, 06 Nov 1994 08:49:37 GMT  ; RFC 822, updated by RFC 1123
 Sunday, 06-Nov-94 08:49:37 GMT ; RFC 850, obsoleted by RFC 1036
 Sun Nov  6 08:49:37 1994       ; ANSI C's asctime() format 
 */
+ (NSDate *)gh_parseHTTP:(NSString *)dateString;

/*!
  @method gh_formatRFC822
  @abstract Get date formatted for RFC822
  @result The date string, like "Wed, 01 Mar 2006 12:00:00 -0400"
*/
- (NSString *)gh_formatRFC822;

/*!
 @method gh_formatHTTP
 @abstract Get date formatted for RFC1123 (HTTP date)
 @result The date string, like "Sun, 06 Nov 1994 08:49:37 GMT"
*/
- (NSString *)gh_formatHTTP;

/*!
 @method gh_iso8601DateFormatter
 @abstract For example, '2007-10-18T16:05:10.000Z'. Returns a new autoreleased formatter since NSDateFormatter is not thread-safe.
 @result Date formatter for ISO8601
*/
+ (NSDateFormatter *)gh_iso8601DateFormatter;

/*! 
 @method gh_rfc822DateFormatter
 @abstract For example, 'Wed, 01 Mar 2006 12:00:00 -0400'. Returns a new autoreleased formatter since NSDateFormatter is not thread-safe.
 @result Date formatter for RFC822
*/
+ (NSDateFormatter *)gh_rfc822DateFormatter;

/*!
 @method gh_rfc1123DateFormatter
 @abstract For example, 'Wed, 01 Mar 2006 12:00:00 GMT'. Returns a new autoreleased formatter since NSDateFormatter is not thread-safe.
 @result Date formatter for RFC1123
 */
+ (NSDateFormatter *)gh_rfc1123DateFormatter;

/*!
 @method gh_rfc850DateFormatter
 @abstract For example, 'Sunday, 06-Nov-94 08:49:37 GMT'. Returns a new autoreleased formatter since NSDateFormatter is not thread-safe.
 @result Date formatter for RFC850
 */
+ (NSDateFormatter *)gh_rfc850DateFormatter;

/*!
 @method gh_ascTimeDateFormatter
 @abstract For example, 'Sun Nov  6 08:49:37 1994'. Returns a new autoreleased formatter since NSDateFormatter is not thread-safe.
 @result Date formatter for asctime
 */
+ (NSDateFormatter *)gh_ascTimeDateFormatter;

@end
