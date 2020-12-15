// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
    
    DKDContentType _type;
    id<MKMID> _group;
}

@property (nonatomic) NSUInteger serialNumber;
@property (strong, nonatomic, nullable) NSDate *time;

@end

@implementation DKDContent

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    return [self initWithType:DKDContentType_Unknown];
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    NSUInteger sn = serial_number();
    NSDate *now = [[NSDate alloc] init];
    NSDictionary *dict = @{@"type":@(type),
                           @"sn"  :@(sn),
                           @"time":@([now timeIntervalSince1970]),
                           };
    if (self = [super initWithDictionary:dict]) {
        _type = type;
        _serialNumber = sn;
        _time = now;
        
        _group = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy load
        _type = 0;
        _serialNumber = 0;
        _time = nil;
        _group = nil;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DKDContent *content = [super copyWithZone:zone];
    if (content) {
        //content.type = _type;
        content.serialNumber = _serialNumber;
        content.time = _time;
        //content.group = _group;
    }
    return content;
}

- (DKDContentType)type {
    if (_type == 0) {
        NSNumber *number = [self objectForKey:@"type"];
        _type = [number unsignedCharValue];
    }
    return _type;
}

- (void)setType:(DKDContentType)type {
    [self setObject:@(type) forKey:@"type"];
    _type = type;
}

- (NSUInteger)serialNumber {
    if (_serialNumber == 0) {
        NSNumber *number = [self objectForKey:@"sn"];
        _serialNumber = [number unsignedIntegerValue];
    }
    return _serialNumber;
}

- (nullable NSDate *)time {
    if (!_time) {
        NSNumber *timestamp = [self objectForKey:@"time"];
        if (timestamp) {
            _time = [[NSDate alloc] initWithTimeIntervalSince1970:[timestamp doubleValue]];
        }
    }
    return _time;
}

- (nullable id<MKMID>)group {
    if (!_group) {
        id group = [self objectForKey:@"group"];
        _group = MKMIDFromString(group);
    }
    return _group;
}

- (void)setGroup:(nullable id)group {
    if (group) {
        [self setObject:group forKey:@"group"];
    } else {
        [self removeObjectForKey:@"group"];
    }
    _group = group;
}

@end

#pragma mark -

@implementation DKDContentFactory

static NSMutableDictionary *s_parsers = nil;

+ (void)registerParser:(id<DKDContentParser>)parser forType:(DKDContentType)type {
    @synchronized (self) {
        if (!s_parsers) {
            s_parsers = [[NSMutableDictionary alloc] init];
        }
        [s_parsers setObject:parser forKey:@(type)];
    }
}

- (nullable __kindof id<DKDContent>)parseContent:(NSDictionary *)content {
    NSNumber *type = [content objectForKey:@"type"];
    id<DKDContentParser> parser = [s_parsers objectForKey:type];
    if (parser) {
        return [parser parse:content];
    }
    return [[DKDContent alloc] initWithDictionary:content];
}

@end

@implementation DKDContent (Creation)

static id<DKDContentFactory> s_factory = nil;

+ (id<DKDContentFactory>)factory {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!s_factory) {
            s_factory = [[DKDContentFactory alloc] init];
        }
    });
    return s_factory;
}

+ (void)setFactory:(id<DKDContentFactory>)factory {
    s_factory = factory;
}

+ (nullable __kindof id<DKDContent>)parse:(NSDictionary *)content {
    if (content.count == 0) {
        return nil;
    } else if ([content conformsToProtocol:@protocol(DKDContent)]) {
        return (id<DKDContent>)content;
    } else if ([content conformsToProtocol:@protocol(MKMDictionary)]) {
        content = [(id<MKMDictionary>)content dictionary];
    }
    return [[self factory] parseContent:content];
}

@end
