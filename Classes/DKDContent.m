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

#import "DKDInstantMessage.h"

#import "DKDContent.h"

static NSMutableDictionary<NSNumber *, id<DKDContentFactory>> *s_factories = nil;

id<DKDContentFactory> DKDContentGetFactory(DKDContentType type) {
    return [s_factories objectForKey:@(type)];
}

void DKDContentSetFactory(DKDContentType type, id<DKDContentFactory> factory) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //if (!s_factories) {
            s_factories = [[NSMutableDictionary alloc] init];
        //}
    });
    [s_factories setObject:factory forKey:@(type)];
}

id<DKDContent> DKDContentParse(id content) {
    if (!content) {
        return nil;
    } else if ([content conformsToProtocol:@protocol(DKDContent)]) {
        return (id<DKDContent>)content;
    } else if ([content conformsToProtocol:@protocol(MKMDictionary)]) {
        content = [(id<MKMDictionary>)content dictionary];
    }
    DKDContentType type = DKDContentGetType(content);
    id<DKDContentFactory> factory = DKDContentGetFactory(type);
    if (!factory) {
        factory = DKDContentGetFactory(0);  // unknown
    }
    return [factory parseContent:content];
}

#pragma mark Getters

DKDContentType DKDContentGetType(NSDictionary *content) {
    NSNumber *number = [content objectForKey:@"type"];
    return [number unsignedCharValue];
}

void DKDContentSetType(DKDContentType type, NSMutableDictionary *content) {
    [content setObject:@(type) forKey:@"type"];
}

NSUInteger DKDContentGetSN(NSDictionary *content) {
    NSNumber *number = [content objectForKey:@"sn"];
    return [number unsignedIntegerValue];
}

NSDate *DKDContentGetTime(NSDictionary *content) {
    NSNumber *timestamp = [content objectForKey:@"time"];
    if (!timestamp) {
        return nil;
    }
    return [[NSDate alloc] initWithTimeIntervalSince1970:[timestamp doubleValue]];
}

id<MKMID> DKDContentGetGroup(NSDictionary *content) {
    return MKMIDFromString([content objectForKey:@"group"]);
}

void DKDContentSetGroup(id<MKMID> group, NSMutableDictionary *content) {
    if (group) {
        [content setObject:[group string] forKey:@"group"];
    } else {
        [content removeObjectForKey:@"group"];
    }
}

#pragma mark - Base Content

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
    return [self initWithType:0];
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    NSDate *now = [[NSDate alloc] init];
    NSUInteger sn = DKDInstantMessageGenerateSerialNumber(type, now);
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
        _type = DKDContentGetType(self.dictionary);
    }
    return _type;
}

- (void)setType:(DKDContentType)type {
    DKDContentSetType(type, self.dictionary);
    _type = type;
}

- (NSUInteger)serialNumber {
    if (_serialNumber == 0) {
        _serialNumber = DKDContentGetSN(self.dictionary);
    }
    return _serialNumber;
}

- (nullable NSDate *)time {
    if (!_time) {
        _time = DKDContentGetTime(self.dictionary);
    }
    return _time;
}

- (nullable id<MKMID>)group {
    if (!_group) {
        _group = DKDContentGetGroup(self.dictionary);
    }
    return _group;
}

- (void)setGroup:(nullable id<MKMID>)group {
    DKDContentSetGroup(group, self.dictionary);
    _group = group;
}

@end
