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

#import "DKDEnvelope.h"

static id<DKDEnvelopeFactory> s_factory = nil;

id<DKDEnvelopeFactory> DKDEnvelopeGetFactory(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_factory == nil) {
            s_factory = [[DKDEnvelopeFactory alloc] init];
        }
    });
    return s_factory;
}

void DKDEnvelopeSetFactory(id<DKDEnvelopeFactory> factory) {
    s_factory = factory;
}

id<DKDEnvelope> DKDEnvelopeCreate(id<MKMID> sender, id<MKMID> receiver, NSDate * _Nullable time) {
    id<DKDEnvelopeFactory> factory = DKDEnvelopeGetFactory();
    return [factory createEnvelopeWithSender:sender receiver:receiver time:time];
}

id<DKDEnvelope> DKDEnvelopeParse(id env) {
    if (!env) {
        return nil;
    } else if ([env conformsToProtocol:@protocol(DKDEnvelope)]) {
        return (id<DKDEnvelope>)env;
    } else if ([env conformsToProtocol:@protocol(MKMDictionary)]) {
        env = [(id<MKMDictionary>)env dictionary];
    }
    id<DKDEnvelopeFactory> factory = DKDEnvelopeGetFactory();
    return [factory parseEnvelope:env];
}

#pragma mark Getters

id<MKMID> DKDEnvelopeGetSender(NSDictionary *env) {
    return MKMIDFromString([env objectForKey:@"sender"]);
}

id<MKMID> DKDEnvelopeGetReceiver(NSDictionary *env) {
    return MKMIDFromString([env objectForKey:@"receiver"]);
}

NSDate *DKDEnvelopeGetTime(NSDictionary *env) {
    NSNumber *timestamp = [env objectForKey:@"time"];
    if (!timestamp) {
        //NSAssert(false, @"message time not found: %@", env);
        return nil;
    }
    return [[NSDate alloc] initWithTimeIntervalSince1970:[timestamp doubleValue]];
}

id<MKMID> DKDEnvelopeGetGroup(NSDictionary *env) {
    return MKMIDFromString([env objectForKey:@"group"]);
}

void DKDEnvelopeSetGroup(id<MKMID> group, NSMutableDictionary *env) {
    if (group) {
        [env setObject:group forKey:@"group"];
    } else {
        [env removeObjectForKey:@"group"];
    }
}

DKDContentType DKDEnvelopeGetType(NSDictionary *env) {
    NSNumber *number = [env objectForKey:@"type"];
    return [number unsignedCharValue];
}

void DKDEnvelopeSetType(DKDContentType type, NSMutableDictionary *env) {
    [env setObject:@(type) forKey:@"type"];
}

#pragma mark -

@interface DKDEnvelope ()

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
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithSender:(id<MKMID>)from receiver:(id<MKMID>)to time:(NSDate *)when {
    NSDictionary *dict = @{
        @"sender":from,
        @"receiver":to,
        @"time":@([when timeIntervalSince1970])
    };
    if (self = [super initWithDictionary:dict]) {
        _sender = from;
        _receiver = to;
        _time = when;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DKDEnvelope *envelope = [super copyWithZone:zone];
    if (envelope) {
        envelope.sender = _sender;
        envelope.receiver = _receiver;
        envelope.time = _time;
    }
    return envelope;
}

- (id<MKMID>)sender {
    if (!_sender) {
        _sender = DKDEnvelopeGetSender(self.dictionary);
    }
    return _sender;
}

- (id<MKMID>)receiver {
    if (!_receiver) {
        _receiver = DKDEnvelopeGetReceiver(self.dictionary);
        if (!_receiver) {
            _receiver = MKMAnyone();
        }
    }
    return _receiver;
}

- (NSDate *)time {
    if (!_time) {
        _time = DKDEnvelopeGetTime(self.dictionary);
    }
    return _time;
}

- (nullable id<MKMID>)group {
    return DKDEnvelopeGetGroup(self.dictionary);
}

- (void)setGroup:(id<MKMID>)group {
    DKDEnvelopeSetGroup(group, self.dictionary);
}

- (DKDContentType)type {
    return DKDEnvelopeGetType(self.dictionary);
}

- (void)setType:(DKDContentType)type {
    DKDEnvelopeSetType(type, self.dictionary);
}

@end

#pragma mark -

@implementation DKDEnvelopeFactory

- (id<DKDEnvelope>)createEnvelopeWithSender:(id<MKMID>)from
                                   receiver:(id<MKMID>)to
                                       time:(nullable NSDate *)when {
    if (!when) {
        // now()
        when = [[NSDate alloc] init];
    }
    return [[DKDEnvelope alloc] initWithSender:from receiver:to time:when];
}

- (nullable id<DKDEnvelope>)parseEnvelope:(NSDictionary *)env {
    if ([env objectForKey:@"sender"]) {
        return [[DKDEnvelope alloc] initWithDictionary:env];
    } else {
        // env.sender should not be empty
        return nil;
    }
}

@end
