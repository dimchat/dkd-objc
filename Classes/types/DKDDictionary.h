// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DKDDictionary.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DKDDictionary<__covariant KeyType, __covariant ObjectType> : NSDictionary<KeyType, ObjectType> {
    
    // inner dictionary
    NSMutableDictionary<KeyType, ObjectType> *_storeDictionary;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)init
NS_DESIGNATED_INITIALIZER;

//- (instancetype)init
//NS_DESIGNATED_INITIALIZER;
//- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects
//                        forKeys:(const id <NSCopying> _Nonnull [_Nullable])keys
//                          count:(NSUInteger)cnt
//NS_DESIGNATED_INITIALIZER;
//- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
//NS_DESIGNATED_INITIALIZER;

@property (readonly) NSUInteger count;
- (nullable ObjectType)objectForKey:(KeyType)aKey;

- (NSEnumerator<KeyType> *)keyEnumerator;
- (NSEnumerator<ObjectType> *)objectEnumerator;

@end

@interface DKDDictionary<KeyType, ObjectType> (Mutable)

- (instancetype)initWithCapacity:(NSUInteger)numItems
/* NS_DESIGNATED_INITIALIZER */;

- (void)removeObjectForKey:(KeyType)aKey;
- (void)setObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)aKey;

@end

NS_ASSUME_NONNULL_END
