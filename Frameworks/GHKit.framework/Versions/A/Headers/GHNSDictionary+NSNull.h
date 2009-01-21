//
//  GHNSDictionary+NSNull.h
//  Created by Jae Kwon on 5/12/08.
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

@interface NSDictionary (GHNSNull)

/*!
 Create dictionary which supports nil values.
 Key is first (instead of value then key). If the value is nil it is stored internally as NSNull,
 and when calling objectMaybeNilForKey will return nil.
 
 For example,
	[NSDictionary gh_dictionaryWithKeysAndObjectsMaybeNil:@"key1", nil, @"key2", @"value2", @"key3", nil, nil];
 
 @param firstObject... Alternating key, value pairs. Terminated when key is nil. 
 */
+ (id)gh_dictionaryWithKeysAndObjectsMaybeNil:(id)firstObject, ...;

/*!
 Use this method instead of objectForKey if you want nil (and not the internal NSNull).
 */
- (id)gh_objectMaybeNilForKey:(id)key;

@end

@interface NSMutableDictionary (GHNSNull)

- (void)gh_setObjectMaybeNil:(id)object forKey:(id)key;

@end
