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
//  DKDMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DKDEnvelope.h"
#import "DKDInstantMessage.h"
#import "DKDSecureMessage.h"
#import "DKDReliableMessage.h"

#import "DKDMessage.h"

@interface DKDEnvelope (Hacking)

@property (readonly, strong, nonatomic) NSMutableDictionary *dictionary;

@end

@interface DKDMessage ()

@property (strong, nonatomic) DKDEnvelope *envelope;

@end

@implementation DKDMessage

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

- (instancetype)initWithSender:(id)from
                      receiver:(id)to
                          time:(nullable NSDate *)time {
    DKDEnvelope *env = DKDEnvelopeCreate(from, to, time);
    return [self initWithEnvelope:env];
}

/* designated initializer */
- (instancetype)initWithEnvelope:(DKDEnvelope *)env {
    NSAssert(env, @"envelope cannot be empty");
    // share the same inner dictionary with envelope object
    if (self = [super init]) {
        _storeDictionary = env.dictionary;
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

- (id)copyWithZone:(NSZone *)zone {
    DKDMessage *msg = [super copyWithZone:zone];
    if (msg) {
        msg.envelope = _envelope;
    }
    return self;
}

- (DKDEnvelope *)envelope {
    if (!_envelope) {
        _envelope = DKDEnvelopeFromDictionary(_storeDictionary);
    }
    return _envelope;
}

- (__kindof id<DKDMessageDelegate>) delegate {
    return self.envelope.delegate;
}

- (void)setDelegate:(__kindof id<DKDMessageDelegate>)delegate {
    self.envelope.delegate = delegate;
}

@end

@implementation DKDMessage (Runtime)

+ (nullable instancetype)getInstance:(id)msg {
    if (!msg) {
        return nil;
    }
    if ([msg isKindOfClass:[DKDMessage class]]) {
        // return Message object directly
        return msg;
    }
    // create instance by subclass
    NSDictionary *content = [msg objectForKey:@"content"];
    if (content) {
        return [[DKDInstantMessage alloc] initWithDictionary:msg];
    }
    NSString *signature = [msg objectForKey:@"signature"];
    if (signature) {
        return [[DKDReliableMessage alloc] initWithDictionary:msg];
    }
    NSString *data = [msg objectForKey:@"data"];
    if (data) {
        return [[DKDSecureMessage alloc] initWithDictionary:msg];
    }
    NSAssert(false, @"message error: %@", msg);
    return [[self alloc] initWithDictionary:msg];
}

@end
