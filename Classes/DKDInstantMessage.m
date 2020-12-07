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
//  DKDInstantMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDSecureMessage.h"

#import "DKDInstantMessage.h"

@interface DKDInstantMessage ()

@property (strong, nonatomic) __kindof id<DKDContent> content;

@end

@implementation DKDInstantMessage

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _content = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithEnvelope:(id<DKDEnvelope>)env
                         content:(id<DKDContent>)content {
    NSAssert(content, @"content cannot be empty");
    NSAssert(env, @"envelope cannot be empty");
    
    if (self = [super initWithEnvelope:env]) {
        // content
        if (content) {
            [self setObject:content forKey:@"content"];
        }
        _content = content;
    }
    return self;
}

- (instancetype)initWithEnvelope:(id<DKDEnvelope>)env {
    NSAssert(false, @"DON'T call me");
    id content = nil;
    return [self initWithEnvelope:env content:content];
}

- (id)copyWithZone:(NSZone *)zone {
    DKDInstantMessage *iMsg = [super copyWithZone:zone];
    if (iMsg) {
        iMsg.content = _content;
    }
    return iMsg;
}

- (__kindof id<DKDContent>)content {
    if (!_content) {
        NSDictionary *dict = [self objectForKey:@"content"];
        _content = DKDContentFromDictionary(dict);
    }
    return _content;
}

- (nullable NSMutableDictionary *)_prepareWithKey:(id<MKMSymmetricKey>)PW {
    // 1. serialize content
    NSData *data = [self.delegate message:self serializeContent:self.content withKey:PW];
    
    // 2. encrypt content data
    data = [self.delegate message:self encryptContent:data withKey:PW];
    NSAssert(data, @"failed to encrypt content with key: %@", PW);
    
    // 3. encode encrypted data
    NSObject *base64 = [self.delegate message:self encodeData:data];
    NSAssert(base64, @"failed to encode data: %@", data);
    
    // 4. replace 'content' with encrypted 'data'
    NSMutableDictionary *msg = [self mutableCopy];
    [msg removeObjectForKey:@"content"];
    [msg setObject:base64 forKey:@"data"];
    return msg;
}

- (nullable id<DKDSecureMessage>)encryptWithKey:(id<MKMSymmetricKey>)password {
    NSAssert(self.delegate, @"message delegate not set yet");
    // 0. check attachment for File/Image/Audio/Video message content
    //    (do it in 'core' module)

    // 1. encrypt 'message.content' to 'message.data'
    NSMutableDictionary *msg = [self _prepareWithKey:password];
    
    // 2. encrypt symmetric key(password) to 'message.key'
    id<MKMID> receiver = self.envelope.receiver;
    // 2.1. serialize symmetric key
    NSData *key = [self.delegate message:self serializeKey:password];
    if (key) {
        // 2.2. encrypt symmetric key data
        key = [self.delegate message:self encryptKey:key forReceiver:receiver];
        if (key) {
            // 2.3. encode encrypted key data
            NSObject *base64 = [self.delegate message:self encodeKey:key];
            NSAssert(base64, @"failed to encode key data: %@", key);
            // 2.4. insert as 'key'
            [msg setObject:base64 forKey:@"key"];
        }
    }
    
    // 3. pack message
    return [[DKDSecureMessage alloc] initWithDictionary:msg];
}

- (nullable id<DKDSecureMessage>)encryptWithKey:(id<MKMSymmetricKey>)password
                                     forMembers:(NSArray<id<MKMID>> *)members {
    NSAssert(self.delegate, @"message delegate not set yet");
    // 0. check attachment for File/Image/Audio/Video message content
    //    (do it in 'core' module)

    // 1. encrypt 'message.content' to 'message.data'
    NSMutableDictionary *msg = [self _prepareWithKey:password];
    
    // 2. serialize symmetric key
    NSData *key = [self.delegate message:self serializeKey:password];
    if (key) {
        // encrypt key data to 'message.keys'
        NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithCapacity:members.count];
        NSData *data;
        NSObject *base64;
        for (id<MKMID> ID in members) {
            // 2.1. encrypt symmetric key data
            data = [self.delegate message:self encryptKey:key forReceiver:ID];
            if (data) {
                // 2.2. encode encrypted key data
                base64 = [self.delegate message:self encodeKey:data];
                NSAssert(base64, @"failed to encode key data: %@", data);
                // 2.3. insert to 'message.keys' with member ID
                [map setObject:base64 forKey:ID.string];
            }
        }
        if (map.count > 0) {
            [msg setObject:map forKey:@"keys"];
        }
    }
    
    // 3. pack message
    return [[DKDSecureMessage alloc] initWithDictionary:msg];
}

@end

#pragma mark - Creation

@implementation DKDInstantMessageFactory

- (id<DKDInstantMessage>)createInstantMessageWithEnvelope:(id<DKDEnvelope>)env
                                                  content:(id<DKDContent>)content {
    return [[DKDInstantMessage alloc] initWithEnvelope:env content:content];
}

- (nullable id<DKDInstantMessage>)parseInstantMessage:(NSDictionary *)msg {
    return [[DKDInstantMessage alloc] initWithDictionary:msg];
}

@end

@implementation DKDInstantMessage (Creation)

static id<DKDInstantMessageFactory> s_factory = nil;

+ (id<DKDInstantMessageFactory>)factory {
    if (s_factory == nil) {
        s_factory = [[DKDInstantMessageFactory alloc] init];
    }
    return s_factory;
}

+ (void)setFactory:(id<DKDInstantMessageFactory>)factory {
    s_factory = factory;
}

+ (id<DKDInstantMessage>)createWithEnvelope:(id<DKDEnvelope>)env
                                    content:(id<DKDContent>)content {
    return [[self factory] createInstantMessageWithEnvelope:env content:content];
}

+ (nullable id<DKDInstantMessage>)parse:(NSDictionary *)msg {
    if (msg.count == 0) {
        return nil;
    } else if ([msg conformsToProtocol:@protocol(DKDInstantMessage)]) {
        return (id<DKDInstantMessage>)msg;
    } else if ([msg conformsToProtocol:@protocol(MKMDictionary)]) {
        msg = [(id<MKMDictionary>)msg dictionary];
    }
    return [[self factory] parseInstantMessage:msg];
}

@end
