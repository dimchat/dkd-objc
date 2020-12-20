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

+ (DKDContentType)type:(NSDictionary *)content {
    NSNumber *number = [content objectForKey:@"type"];
    NSAssert(number, @"content type not found: %@", content);
    return [number unsignedCharValue];
}

- (DKDContentType)type {
    if (_type == 0) {
        _type = [DKDContent type:self.dictionary];
    }
    return _type;
}

+ (void)setType:(DKDContentType)type inContent:(NSMutableDictionary *)content {
    [content setObject:@(type) forKey:@"type"];
}

- (void)setType:(DKDContentType)type {
    [DKDContent setType:type inContent:self.dictionary];
    _type = type;
}

+ (NSUInteger)serialNumber:(NSDictionary *)content {
    NSNumber *number = [content objectForKey:@"sn"];
    NSAssert(number, @"serial number not found: %@", content);
    return [number unsignedIntegerValue];
}

- (NSUInteger)serialNumber {
    if (_serialNumber == 0) {
        _serialNumber = [DKDContent serialNumber:self.dictionary];
    }
    return _serialNumber;
}

+ (nullable NSDate *)time:(NSDictionary *)content {
    NSNumber *timestamp = [content objectForKey:@"time"];
    if (!timestamp) {
        return nil;
    }
    return [[NSDate alloc] initWithTimeIntervalSince1970:[timestamp doubleValue]];
}

- (nullable NSDate *)time {
    if (!_time) {
        _time = [DKDContent time:self.dictionary];
    }
    return _time;
}

+ (nullable id<MKMID>)group:(NSDictionary *)content {
    return MKMIDFromString([content objectForKey:@"group"]);
}

- (nullable id<MKMID>)group {
    if (!_group) {
        return [DKDContent group:self.dictionary];
    }
    return _group;
}

+ (void)setGroup:(id<MKMID>)group inContent:(NSMutableDictionary *)content {
    if (group) {
        [content setObject:group forKey:@"group"];
    } else {
        [content removeObjectForKey:@"group"];
    }
}

- (void)setGroup:(nullable id)group {
    [DKDContent setGroup:group inContent:self.dictionary];
    _group = group;
}

@end

#pragma mark -

@implementation DKDContent (Creation)

static NSMutableDictionary<NSNumber *, id<DKDContentFactory>> *s_factories = nil;

+ (void)setFactory:(id<DKDContentFactory>)factory forType:(DKDContentType)type {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //if (!s_factories) {
            s_factories = [[NSMutableDictionary alloc] init];
        //}
    });
    [s_factories setObject:factory forKey:@(type)];
}

+ (id<DKDContentFactory>)factoryForType:(DKDContentType)type {
    NSAssert(s_factories, @"content factories not set yet");
    return [s_factories objectForKey:@(type)];
}

+ (nullable __kindof id<DKDContent>)parse:(NSDictionary *)content {
    if (content.count == 0) {
        return nil;
    } else if ([content conformsToProtocol:@protocol(DKDContent)]) {
        return (id<DKDContent>)content;
    } else if ([content conformsToProtocol:@protocol(MKMDictionary)]) {
        content = [(id<MKMDictionary>)content dictionary];
    }
    DKDContentType type = [self type:content];
    id<DKDContentFactory> factory = [self factoryForType:type];
    if (!factory) {
        factory = [self factoryForType:0];  // unknown
        NSAssert(factory, @"cannot parse content: %@", content);
    }
    return [factory parseContent:content];
}

@end
