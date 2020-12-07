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
//  DKDSecureMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDInstantMessage.h"
#import "DKDReliableMessage.h"

#import "DKDSecureMessage.h"

@interface DKDSecureMessage ()

@property (strong, nonatomic) NSData *data;

@property (strong, nonatomic, nullable) NSData *encryptedKey;
@property (strong, nonatomic, nullable) NSDictionary *encryptedKeys;

@end

@implementation DKDSecureMessage

- (instancetype)initWithEnvelope:(id<DKDEnvelope>)env {
    NSAssert(false, @"DON'T call me");
    return [self initWithDictionary:env.dictionary];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _data = nil;
        _encryptedKey = nil;
        _encryptedKeys = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDSecureMessage *sMsg = [super copyWithZone:zone];
    if (sMsg) {
        sMsg.data = _data;
        sMsg.encryptedKey = _encryptedKey;
        sMsg.encryptedKeys = _encryptedKeys;
    }
    return sMsg;
}

- (NSData *)data {
    if (!_data) {
        NSString *content = [self objectForKey:@"data"];
        NSAssert(content, @"content data cannot be empty");
        _data = [self.delegate message:self decodeData:content];
    }
    return _data;
}

- (NSData *)encryptedKey {
    if (!_encryptedKey) {
        NSString *key = [self objectForKey:@"key"];
        if (!key) {
            // check 'keys'
            NSDictionary *keys = self.encryptedKeys;
            key = [keys objectForKey:self.envelope.receiver];
        }
        if (key) {
            _encryptedKey = [self.delegate message:self decodeKey:key];
        }
    }
    return _encryptedKey;
}

- (NSDictionary *)encryptedKeys {
    if (!_encryptedKeys) {
        _encryptedKeys = [self objectForKey:@"keys"];
    }
    return _encryptedKeys;
}

- (nullable id<DKDInstantMessage>)decrypt {
    id<MKMID> sender = [self.envelope sender];
    id<MKMID> receiver = [self.envelope receiver];
    id<MKMID> group = [self.envelope group];

    // 1. decrypt 'message.key' to symmetric key
    // 1.1. decode encrypted key data
    NSData *key = self.encryptedKey;
    id<MKMSymmetricKey> password;
    // 1.2. decrypt key data
    //      if key is empty, means it should be reused, get it from key cache
    if (group) {
        // group message
        key = [self.delegate message:self decryptKey:key from:sender to:group];
        password = [self.delegate message:self deserializeKey:key from:sender to:group];
    } else {
        // personal message?
        key = [self.delegate message:self decryptKey:key from:sender to:receiver];
        password = [self.delegate message:self deserializeKey:key from:sender to:receiver];
    }
    //NSAssert(password, @"failed to get symmetric key for msg: %@", self);
    
    // 2. decrypt 'message.data' to 'message.content'
    // 2.1. decrypt content data
    NSData *data = [self.delegate message:self decryptContent:self.data withKey:password];
    // 2.2. deserialize content
    id<DKDContent> content = [self.delegate message:self deserializeContent:data withKey:password];
    // 2.3. check attachment for File/Image/Audio/Video message content
    //      if file data not download yet,
    //          decrypt file data with password;
    //      else,
    //          save password to 'message.content.password'.
    //      (do it in 'core' module)
    if (!content) {
        NSAssert(false, @"failed to decrypt message data: %@", self);
        return nil;
    }
    
    // 3. pack message
    NSMutableDictionary *mDict = [self dictionary:YES];
    [mDict removeObjectForKey:@"key"];
    [mDict removeObjectForKey:@"keys"];
    [mDict removeObjectForKey:@"data"];
    [mDict setObject:content forKey:@"content"];
    return DKDInstantMessageFromDictionary(mDict);
}

- (nullable id<DKDReliableMessage>)sign {
    NSAssert(self.delegate, @"message delegate not set yet");
    // 1. sign with sender's private key
    NSData *signature = [self.delegate message:self
                                  signData:self.data
                                 forSender:self.envelope.sender];
    NSAssert(signature, @"failed to sign message: %@", self);
    NSObject *base64 = [self.delegate message:self encodeSignature:signature];
    if (!base64) {
        NSAssert(false, @"failed to encode signature: %@", signature);
        return nil;
    }
    // 2. pack message
    NSMutableDictionary *mDict = [self mutableCopy];
    [mDict setObject:base64 forKey:@"signature"];
    return [[DKDReliableMessage alloc] initWithDictionary:mDict];
}

- (NSArray *)splitForMembers:(NSArray<id<MKMID>> *)members {
    NSMutableDictionary *msg;
    msg = [[NSMutableDictionary alloc] initWithDictionary:self];
    // check 'keys'
    NSDictionary *keyMap = self.encryptedKeys;
    if (keyMap) {
        [msg removeObjectForKey:@"keys"];
    }
    
    // 1. move the receiver(group ID) to 'group'
    //    this will help the receiver knows the group ID
    //    when the group message separated to multi-messages;
    //    if don't want the others know your membership,
    //    DON'T do this.
    [msg setObject:self.envelope.receiver forKey:@"group"];
    
    NSMutableArray *messages;
    messages = [[NSMutableArray alloc] initWithCapacity:members.count];
    NSString *base64;
    for (id<MKMID> member in members) {
        // 2. change receiver to each group member
        [msg setObject:member forKey:@"receiver"];
        // 3. get encrypted key
        base64 = [keyMap objectForKey:member];
        if (base64) {
            [msg setObject:base64 forKey:@"key"];
        } else {
            [msg removeObjectForKey:@"key"];
        }
        // 4. repack message
        [messages addObject:[[[self class] alloc] initWithDictionary:msg]];
    }
    return messages;
}

- (instancetype)trimForMember:(id<MKMID>)member {
    NSMutableDictionary *mDict = [self mutableCopy];
    // check 'keys'
    NSDictionary *keys = [mDict objectForKey:@"keys"];
    if (keys) {
        NSString *base64 = [keys objectForKey:member];
        if (base64) {
            [mDict setObject:base64 forKey:@"key"];
        }
        [mDict removeObjectForKey:@"keys"];
    }
    // check 'group'
    id<MKMID> group = self.envelope.group;
    if (!group) {
        // if 'group' not exists, the 'receiver' must be a group ID here, and
        // it will not be equal to the member of course,
        // so move 'receiver' to 'group'
        [mDict setObject:self.envelope.receiver forKey:@"group"];
    }
    // replace receiver
    [mDict setObject:member forKey:@"receiver"];
    // repack
    return [[[self class] alloc] initWithDictionary:mDict];
}

@end

#pragma mark - Creation

@implementation DKDSecureMessageFactory

- (nullable __kindof id<DKDSecureMessage>)parseSecureMessage:(NSDictionary *)msg {
    return [[DKDSecureMessage alloc] initWithDictionary:msg];
}

@end

@implementation DKDSecureMessage (Creation)

static id<DKDSecureMessageFactory> s_factory = nil;

+ (id<DKDSecureMessageFactory>)factory {
    if (s_factory == nil) {
        s_factory = [[DKDSecureMessageFactory alloc] init];
    }
    return s_factory;
}

+ (void)setFactory:(id<DKDSecureMessageFactory>)factory {
    s_factory = factory;
}

+ (nullable __kindof id<DKDSecureMessage>)parse:(NSDictionary *)msg {
    if (msg.count == 0) {
        return nil;
    } else if ([msg conformsToProtocol:@protocol(DKDSecureMessage)]) {
        return (id<DKDSecureMessage>)msg;
    } else if ([msg conformsToProtocol:@protocol(MKMDictionary)]) {
        msg = [(id<MKMDictionary>)msg dictionary];
    }
    return [[self factory] parseSecureMessage:msg];
}

@end
