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
//  DKDContent.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DKDForwardContent.h"

#import "DKDContent.h"

static inline NSUInteger serial_number(void) {
    // because we must make sure all messages in a same chat box won't have
    // same serial numbers, so we can't use time-related numbers, therefore
    // the best choice is a totally random number, maybe.
    uint32_t sn = 0;
    while (sn == 0) {
        sn = arc4random();
    }
    return sn;
}

@interface DKDContent () {
    
    UInt8 _type;
    NSUInteger _serialNumber;
}

@property (nonatomic) UInt8 type;
@property (nonatomic) NSUInteger serialNumber;

@end

@implementation DKDContent

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    return [self initWithType:DKDContentType_Unknown];
}

/* designated initializer */
- (instancetype)initWithType:(UInt8)type {
    NSUInteger sn = serial_number();
    NSDictionary *dict = @{@"type":@(type),
                           @"sn"  :@(sn),
                           };
    if (self = [super initWithDictionary:dict]) {
        _type = type;
        _serialNumber = sn;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // content type
        NSNumber *type = [_storeDictionary objectForKey:@"type"];
        _type = [type unsignedCharValue];
        // serial number
        NSNumber *sn = [_storeDictionary objectForKey:@"sn"];
        _serialNumber = [sn unsignedIntegerValue];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDContent *content = [super copyWithZone:zone];
    if (content) {
        //content.type = _type;
        content.serialNumber = _serialNumber;
    }
    return content;
}

- (void)setType:(UInt8)type {
    if (_type != type) {
        [_storeDictionary setObject:@(type) forKey:@"type"];
        _type = type;
    }
}

@end

@implementation DKDContent (Group)

- (nullable NSString *)group {
    return [_storeDictionary objectForKey:@"group"];
}

- (void)setGroup:(nullable NSString *)group {
    if (group) {
        [_storeDictionary setObject:group forKey:@"group"];
    } else {
        [_storeDictionary removeObjectForKey:@"group"];
    }
}

@end

static NSMutableDictionary<NSNumber *, Class> *content_classes(void) {
    static NSMutableDictionary<NSNumber *, Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [[NSMutableDictionary alloc] init];
        // Forward (Top-Secret)
        [classes setObject:[DKDForwardContent class] forKey:@(DKDContentType_Forward)];
        // Text
        // File
        // Command
        // ...
    });
    return classes;
}

@implementation DKDContent (Runtime)

+ (void)registerClass:(nullable Class)clazz forType:(UInt8)type {
    NSAssert(![clazz isEqual:self], @"only subclass");
    if (clazz) {
        NSAssert([clazz isSubclassOfClass:self], @"error: %@", clazz);
        [content_classes() setObject:clazz forKey:@(type)];
    } else {
        [content_classes() removeObjectForKey:@(type)];
    }
}

+ (nullable instancetype)getInstance:(id)content {
    if (!content) {
        return nil;
    }
    NSAssert([content isKindOfClass:[NSDictionary class]], @"content error: %@", content);
    if ([self isEqual:[DKDContent class]]) {
        if ([content isKindOfClass:[DKDContent class]]) {
            // return Content object directly
            return content;
        }
        // create instance by subclass with content type
        NSNumber *type = [content objectForKey:@"type"];
        Class clazz = [content_classes() objectForKey:type];
        if (clazz) {
            return [clazz getInstance:content];
        }
    }
    // custom message content
    return [[self alloc] initWithDictionary:content];
}

@end
