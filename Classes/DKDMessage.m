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
//  DKDMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDInstantMessage.h"
#import "DKDSecureMessage.h"
#import "DKDReliableMessage.h"

#import "DKDMessage.h"

@interface DKDMessage ()

@property (strong, nonatomic) id<DKDEnvelope> envelope;

@end

@implementation DKDMessage

@synthesize delegate;

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

/* designated initializer */
- (instancetype)initWithEnvelope:(id<DKDEnvelope>)env {
    NSAssert(env, @"envelope cannot be empty");
    // share the same inner dictionary with envelope object
    if (self = [super initWithDictionary:env.dictionary]) {
        _envelope = env;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        _envelope = nil; // lazy
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DKDMessage *msg = [super copyWithZone:zone];
    if (msg) {
        msg.envelope = _envelope;
        msg.delegate = self.delegate;
    }
    return self;
}

+ (id<DKDEnvelope>)envelope:(NSDictionary *)msg {
    return DKDEnvelopeFromDictionary(msg);
}

- (id<DKDEnvelope>)envelope {
    if (!_envelope) {
        _envelope = [DKDMessage envelope:self.dictionary];
    }
    return _envelope;
}

- (id<MKMID>)sender {
    return [self.envelope sender];
}

- (id<MKMID>)receiver {
    return [self.envelope receiver];
}

- (NSDate *)time {
    return [self.envelope time];
}

- (id<MKMID>)group {
    return [self.envelope group];
}

- (DKDContentType)type {
    return [self.envelope type];
}

@end
