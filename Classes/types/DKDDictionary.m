//
//  DKDDictionary.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDDictionary.h"

@implementation DKDDictionary

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:dict];
    }
    return self;
}

- (instancetype)init {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    return [self initWithDictionary:dict];
}

- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects
                        forKeys:(const id <NSCopying> _Nonnull [_Nullable])keys
                          count:(NSUInteger)cnt {
    NSMutableDictionary *dict;
    dict = [[NSMutableDictionary alloc] initWithObjects:objects
                                                forKeys:keys
                                                  count:cnt];
    return [self initWithDictionary:dict];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSMutableDictionary *dict;
    dict = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    return [self initWithDictionary:dict];
}

- (id)copyWithZone:(NSZone *)zone {
    id dict = [[self class] allocWithZone:zone];
    dict = [dict initWithDictionary:_storeDictionary];
    return dict;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    return self == object || [_storeDictionary isEqualToDictionary:object];
}

- (NSUInteger)count {
    return [_storeDictionary count];
}

- (id)objectForKey:(NSString *)aKey {
    return [_storeDictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
    return [_storeDictionary keyEnumerator];
}

- (NSEnumerator *)objectEnumerator {
    return [_storeDictionary objectEnumerator];
}

@end

@implementation DKDDictionary (Mutable)

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    if (self = [self init]) {
        _storeDictionary = [[NSMutableDictionary alloc] initWithCapacity:numItems];
    }
    return self;
}

// NOTICE: no need to implements mutable copy here
//- (id)mutableCopy {
//    return [self copy];
//}

- (void)removeObjectForKey:(NSString *)aKey {
    [_storeDictionary removeObjectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(NSString *)aKey {
    [_storeDictionary setObject:anObject forKey:aKey];
}

@end
