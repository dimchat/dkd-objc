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

static id<DKDInstantMessageFactory> s_factory = nil;

id<DKDInstantMessageFactory> DKDInstantMessageGetFactory(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_factory == nil) {
            s_factory = [[DKDInstantMessageFactory alloc] init];
        }
    });
    return s_factory;
}

void DKDInstantMessageSetFactory(id<DKDInstantMessageFactory> factory) {
    s_factory = factory;
}

NSUInteger DKDInstantMessageGenerateSerialNumber(DKDContentType type, NSDate *now) {
    id<DKDInstantMessageFactory> factory = DKDInstantMessageGetFactory();
    return [factory generateSerialNumber:type time:now];
}

id<DKDInstantMessage> DKDInstantMessageCreate(id<DKDEnvelope> head, id<DKDContent> body) {
    id<DKDInstantMessageFactory> factory = DKDInstantMessageGetFactory();
    return [factory createInstantMessageWithEnvelope:head content:body];
}

id<DKDInstantMessage> DKDInstantMessageParse(id msg) {
    if (!msg) {
        return nil;
    } else if ([msg conformsToProtocol:@protocol(DKDInstantMessage)]) {
        return (id<DKDInstantMessage>)msg;
    }
    msg = MKMGetMap(msg);
    id<DKDInstantMessageFactory> factory = DKDInstantMessageGetFactory();
    return [factory parseInstantMessage:msg];
}

id<DKDContent> DKDInstantMessageGetContent(NSDictionary *msg) {
    id dict = [msg objectForKey:@"content"];
    return DKDContentFromDictionary(dict);
}

#pragma mark -

@interface DKDInstantMessage ()

@property (strong, nonatomic) id<DKDContent> content;

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
            [self setObject:[content dictionary] forKey:@"content"];
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

- (id)copyWithZone:(nullable NSZone *)zone {
    DKDInstantMessage *iMsg = [super copyWithZone:zone];
    if (iMsg) {
        iMsg.content = _content;
    }
    return iMsg;
}

- (id<DKDContent>)content {
    if (!_content) {
        _content = DKDInstantMessageGetContent(self.dictionary);
    }
    return _content;
}

- (NSDate *)time {
    id<DKDContent> content = [self content];
    NSDate *when = [content time];
    if (when) {
        return when;
    }
    return [super time];
}

- (id<MKMID>)group {
    id<DKDContent> content = [self content];
    return [content group];
}

- (DKDContentType)type {
    id<DKDContent> content = [self content];
    return [content type];
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
    NSMutableDictionary *msg = [self dictionary:NO];
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
    id<MKMID> receiver = self.receiver;
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
    return DKDSecureMessageFromDictionary(msg);
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
                [map setObject:base64 forKey:[ID string]];
            }
        }
        if (map.count > 0) {
            [msg setObject:map forKey:@"keys"];
        }
    }
    
    // 3. pack message
    return DKDSecureMessageFromDictionary(msg);
}

@end

#pragma mark -

@implementation DKDInstantMessageFactory

- (NSUInteger)generateSerialNumber:(DKDContentType)type time:(NSDate *)now {
    // because we must make sure all messages in a same chat box won't have
    // same serial numbers, so we can't use time-related numbers, therefore
    // the best choice is a totally random number, maybe.
    uint32_t sn = arc4random();
    if (sn == 0) {
        // ZERO? do it again!
        sn = 9527 + 9394;
    }
    return sn;
}

- (id<DKDInstantMessage>)createInstantMessageWithEnvelope:(id<DKDEnvelope>)head
                                                  content:(id<DKDContent>)body {
    return [[DKDInstantMessage alloc] initWithEnvelope:head content:body];
}

- (nullable id<DKDInstantMessage>)parseInstantMessage:(NSDictionary *)msg {
    // check 'sender', 'content'
    id sender = [msg objectForKey:@"sender"];
    id content = [msg objectForKey:@"content"];
    if (!sender || !content) {
        // msg.sender should not be empty
        // msg.content should not be empty
        return nil;
    }
    return [[DKDInstantMessage alloc] initWithDictionary:msg];
}

@end
