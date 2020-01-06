// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
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
//  DKDMessage+Transform.m
//  DaoKeDao
//
//  Created by Albert Moky on 2019/3/15.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DKDEnvelope.h"
#import "DKDContent.h"

#import "DKDMessage+Transform.h"

@implementation DKDInstantMessage (ToSecureMessage)

- (nullable NSMutableDictionary *)_prepareWithKey:(NSDictionary *)PW {
    DKDContent *content = self.content;
    // 1. check attachment for File/Image/Audio/Video message content
    //    (do it in 'core' module)
    
    // 2. encrypt message content
    NSData *data = [self.delegate message:self encryptContent:content withKey:PW];
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

- (nullable DKDSecureMessage *)encryptWithKey:(NSDictionary *)password {
    NSAssert(self.delegate, @"message delegate not set yet");
    
    // 1. encrypt 'message.content' to 'message.data'
    NSMutableDictionary *msg = [self _prepareWithKey:password];
    
    // 2. encrypt symmetric key(password) to 'message.key'
    
    // 2.1. serialize & encrypt symmetric key
    NSString *receiver = self.envelope.receiver;
    NSData *key = [self.delegate message:self encryptKey:password forReceiver:receiver];
    if (key) {
        // 2.2. encode encrypted key data
        NSObject *base64 = [self.delegate message:self encodeKey:key];
        NSAssert(base64, @"failed to encode key data: %@", key);
        // 2.3. insert as 'key'
        [msg setObject:base64 forKey:@"key"];
    }
    
    // 3. pack message
    return [[DKDSecureMessage alloc] initWithDictionary:msg];
}

- (nullable DKDSecureMessage *)encryptWithKey:(NSDictionary *)password
                                   forMembers:(NSArray *)members {
    NSAssert(self.delegate, @"message delegate not set yet");
    
    // 1. encrypt 'message.content' to 'message.data'
    NSMutableDictionary *msg = [self _prepareWithKey:password];
    
    // 2. encrypt symmetric key(password) to 'message.keys'
    
    NSMutableDictionary *keyMap;
    keyMap = [[NSMutableDictionary alloc] initWithCapacity:members.count];
    NSData *key;
    NSObject *base64;
    for (NSString *ID in members) {
        // 2.1. serialize & encrypt symmetric key
        key = [self.delegate message:self encryptKey:password forReceiver:ID];
        if (key) {
            // 2.2. encode encrypted key data
            base64 = [self.delegate message:self encodeKey:key];
            NSAssert(base64, @"failed to encode key data: %@", key);
            // 2.3. insert to 'message.keys' with member ID
            [keyMap setObject:base64 forKey:ID];
        }
    }
    if (keyMap.count > 0) {
        [msg setObject:keyMap forKey:@"keys"];
    }
    // group ID
    NSString *group = [self.content group];
    NSAssert(group, @"group message error: %@", self);
    // NOTICE: this help the receiver knows the group ID
    //         when the group message separated to multi-messages,
    //         if don't want the others know you are the group members,
    //         remove it.
    [msg setObject:group forKey:@"group"];
    
    // 3. pack message
    return [[DKDSecureMessage alloc] initWithDictionary:msg];
}

@end

@implementation DKDSecureMessage (ToInstantMessage)

- (nullable DKDInstantMessage *)decrypt {
    NSString *sender = self.envelope.sender;
    NSString *receiver = self.envelope.receiver;
    NSString *group = self.envelope.group;

    // 1. decrypt 'message.key' to symmetric key
    // 1.1. decode encrypted key data
    NSData *key = self.encryptedKey;
    NSDictionary *password;
    // 1.2. decrypt key data
    //      if key is empty, means it should be reused, get it from key cache
    if (group) {
        // group message
        password = [self.delegate message:self decryptKey:key from:sender to:group];
    } else {
        // personal message?
        password = [self.delegate message:self decryptKey:key from:sender to:receiver];
    }
    //NSAssert(password, @"failed to get symmetric key for msg: %@", self);
    
    // 2. decrypt 'message.data' to 'message.content'
    // 2.1. decode encrypted content data
    NSData *data = self.data;
    DKDContent *content;
    // 2.2. decrypt & deserialize content data
    content = [self.delegate message:self decryptContent:data withKey:password];
    // 2.3. check attachment for File/Image/Audio/Video message content
    //      if file data not download yet,
    //          decrypt file data with password;
    //      else,
    //          save password to 'message.content.password'.
    //      (do it in 'core' module)
    if (!content) {
        //NSAssert(false, @"failed to decrypt message data: %@", self);
        return nil;
    }
    
    // 3. pack message
    NSMutableDictionary *mDict = [self mutableCopy];
    [mDict removeObjectForKey:@"key"];
    [mDict removeObjectForKey:@"data"];
    [mDict setObject:content forKey:@"content"];
    return [[DKDInstantMessage alloc] initWithDictionary:mDict];
}

@end

@implementation DKDSecureMessage (ToReliableMessage)

- (nullable DKDReliableMessage *)sign {
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

@end

@implementation DKDReliableMessage (ToSecureMessage)

- (nullable DKDSecureMessage *)verify {
    NSAssert(self.delegate, @"message delegate not set yet");
    // 1. verify data signature with sender's public key
    if ([self.delegate message:self
                verifyData:self.data
             withSignature:self.signature
                 forSender:self.envelope.sender]) {
        // 2. pack message
        NSMutableDictionary *mDict = [self mutableCopy];
        [mDict removeObjectForKey:@"signature"];
        return [[DKDSecureMessage alloc] initWithDictionary:mDict];
    } else {
        NSAssert(false, @"message signature not match: %@", self);
        return nil;
    }
}

@end
