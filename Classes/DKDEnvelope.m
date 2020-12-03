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
//  DKDEnvelope.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DKDEnvelope.h"

@interface DKDEnvelope () {
    
    id<MKMID> _group;
    DKDContentType _type;
}

@property (strong, nonatomic) id<MKMID> sender;
@property (strong, nonatomic) id<MKMID> receiver;
@property (strong, nonatomic) NSDate *time;

@end

@implementation DKDEnvelope

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _sender = nil;
        _receiver = nil;
        _time = nil;
        
        _group = nil;
        _type = 0;
    }
    return self;
}

- (instancetype)initWithSender:(id<MKMID>)from receiver:(id<MKMID>)to time:(NSDate *)when {
    NSDictionary *dict = @{@"sender"  :from,
                           @"receiver":to,
                           @"time"    :NSNumberFromDate(when),
                           };
    if (self = [super initWithDictionary:dict]) {
        _sender = from;
        _receiver = to;
        _time = when;
        
        _group = nil;
        _type = 0;
    }
    return self;
}

- (instancetype)initWithSender:(id<MKMID>)from receiver:(id<MKMID>)to timestamp:(NSNumber *)time {
    return [self initWithSender:from receiver:to time:NSDateFromNumber(time)];
}

- (id)copyWithZone:(NSZone *)zone {
    DKDEnvelope *envelope = [super copyWithZone:zone];
    if (envelope) {
        envelope.sender = _sender;
        envelope.receiver = _receiver;
        envelope.time = _time;
        //envelope.group = _group;
        //envelope.type = _type;
    }
    return envelope;
}

- (id)sender {
    if (!_sender) {
        id sender = [self objectForKey:@"sender"];
        _sender = MKMIDFromString(sender);
    }
    return _sender;
}

- (id)receiver {
    if (!_receiver) {
        id receiver = [self objectForKey:@"receiver"];
        _receiver = MKMIDFromString(receiver);
    }
    return _receiver;
}

- (NSDate *)time {
    if (!_time) {
        NSNumber *timestamp = [self objectForKey:@"time"];
        _time = NSDateFromNumber(timestamp);
    }
    return _time;
}

- (nullable id)group {
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

@end

#pragma mark -

@implementation DKDEnvelopeFactory

- (nonnull id<DKDEnvelope>)createEnvelopeWithSender:(id<MKMID>)from
                                           receiver:(id<MKMID>)to
                                               time:(nullable NSDate *)when {
    if (!when) {
        // now()
        when = [[NSDate alloc] init];
    }
    return [[DKDEnvelope alloc] initWithSender:from receiver:to time:when];
}

- (nonnull id<DKDEnvelope>)createEnvelopeWithSender:(id<MKMID>)from
                                           receiver:(id<MKMID>)to
                                          timestamp:(nullable NSNumber *)time {
    if (time) {
        return [[DKDEnvelope alloc] initWithSender:from receiver:to timestamp:time];
    } else {
        return [self createEnvelopeWithSender:from receiver:to time:nil];
    }
}

- (nullable id<DKDEnvelope>)parseEnvelope:(nonnull NSDictionary *)env {
    return [[DKDEnvelope alloc] initWithDictionary:env];
}

@end

@implementation DKDEnvelope (Creation)

static id<DKDEnvelopeFactory> s_factory = nil;

+ (id<DKDEnvelopeFactory>)factory {
    if (s_factory == nil) {
        s_factory = [[DKDEnvelopeFactory alloc] init];
    }
    return s_factory;
}

+ (void)setFactory:(id<DKDEnvelopeFactory>)factory {
    s_factory = factory;
}

+ (id<DKDEnvelope>)createWithSender:(id<MKMID>)from
                           receiver:(id<MKMID>)to
                               time:(nullable NSDate *)when {
    return [[self factory] createEnvelopeWithSender:from receiver:to time:when];
}

+ (id<DKDEnvelope>)createWithSender:(id<MKMID>)from
                           receiver:(id<MKMID>)to
                          timestamp:(nullable NSNumber *)time {
    return [[self factory] createEnvelopeWithSender:from receiver:to timestamp:time];
}

+ (nullable id<DKDEnvelope>)parse:(NSDictionary *)env {
    if (env.count == 0) {
        return nil;
    } else if ([env conformsToProtocol:@protocol(DKDEnvelope)]) {
        return (id<DKDEnvelope>)env;
    }
    return [[self factory] parseEnvelope:env];
}

@end
