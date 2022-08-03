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
//  DKDReliableMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDReliableMessage.h"

static id<DKDReliableMessageFactory> s_factory = nil;

id<DKDReliableMessageFactory> DKDReliableMessageGetFactory(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_factory == nil) {
            s_factory = [[DKDReliableMessageFactory alloc] init];
        }
    });
    return s_factory;
}

void DKDReliableMessageSetFactory(id<DKDReliableMessageFactory> factory) {
    s_factory = factory;
}

id<DKDReliableMessage> DKDReliableMessageParse(id msg) {
    if (!msg) {
        return nil;
    } else if ([msg conformsToProtocol:@protocol(DKDReliableMessage)]) {
        return (id<DKDReliableMessage>)msg;
    }
    msg = MKMGetMap(msg);
    id<DKDReliableMessageFactory> factory = DKDReliableMessageGetFactory();
    return [factory parseReliableMessage:msg];
}

#pragma mark Getters

id<MKMMeta> DKDReliableMessageGetMeta(NSDictionary *msg) {
    id dict = [msg objectForKey:@"meta"];
    return MKMMetaFromDictionary(dict);
}

void DKDReliableMessageSetMeta(id<MKMMeta> meta, NSMutableDictionary *msg) {
    if (meta) {
        [msg setObject:[meta dictionary] forKey:@"meta"];
    } else {
        [msg removeObjectForKey:@"meta"];
    }
}

id<MKMVisa> DKDReliableMessageGetVisa(NSDictionary *msg) {
    id dict = [msg objectForKey:@"visa"];
    return MKMDocumentFromDictionary(dict);
}

void DKDReliableMessageSetVisa(id<MKMVisa> visa, NSMutableDictionary *msg) {
    if (visa) {
        [msg setObject:[visa dictionary] forKey:@"visa"];
    } else {
        [msg removeObjectForKey:@"visa"];
    }
}

#pragma mark -

@interface DKDReliableMessage () {
    
    id<MKMMeta> _meta;
    id<MKMVisa> _visa;
}

@property (strong, nonatomic) NSData *signature;

@end

@implementation DKDReliableMessage

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _signature = nil;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DKDReliableMessage *rMsg = [super copyWithZone:zone];
    if (rMsg) {
        rMsg.signature = _signature;
    }
    return rMsg;
}

- (NSData *)signature {
    if (!_signature) {
        NSString *CT = [self objectForKey:@"signature"];
        NSAssert(CT, @"signature cannot be empty");
        _signature = [self.delegate message:self decodeSignature:CT];
    }
    return _signature;
}

- (nullable id<DKDSecureMessage>)verify {
    NSAssert(self.delegate, @"message delegate not set yet");
    // 1. verify data signature with sender's public key
    if ([self.delegate message:self
                    verifyData:self.data
                 withSignature:self.signature
                     forSender:self.sender]) {
        // 2. pack message
        NSMutableDictionary *mDict = [self dictionary:NO];
        [mDict removeObjectForKey:@"signature"];
        return DKDSecureMessageFromDictionary(mDict);
    } else {
        NSAssert(false, @"message signature not match: %@", self);
        return nil;
    }
}

- (id<MKMMeta>)meta {
    if (!_meta) {
        _meta = DKDReliableMessageGetMeta(self.dictionary);
    }
    return _meta;
}

- (void)setMeta:(id<MKMMeta>)meta {
    DKDReliableMessageSetMeta(meta, self.dictionary);
    _meta = meta;
}

- (id<MKMVisa>)visa {
    if (!_visa) {
        _visa = DKDReliableMessageGetVisa(self.dictionary);
    }
    return _visa;
}

- (void)setVisa:(id<MKMVisa>)visa {
    DKDReliableMessageSetVisa(visa, self.dictionary);
    _visa = visa;
}

@end

#pragma mark - Creation

@implementation DKDReliableMessageFactory

- (nullable id<DKDReliableMessage>)parseReliableMessage:(NSDictionary *)msg {
    if ([msg objectForKey:@"sender"] && [msg objectForKey:@"data"] && [msg objectForKey:@"signature"]) {
        return [[DKDReliableMessage alloc] initWithDictionary:msg];
    } else {
        // msg.sender should not be empty
        // msg.data should not be empty
        // msg.signature should not be empty
        return nil;
    }
}

@end
