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
    NSData *data = [_delegate message:self encryptContent:content withKey:PW];
    NSAssert(data, @"failed to encrypt content with key: %@", PW);
    
    // 3. encode encrypted data
    NSObject *base64 = [_delegate message:self encodeData:data];
    if (!base64) {
        NSAssert(false, @"failed to encode data: %@", data);
        return nil;
    }
    
    // 4. replace 'content' with encrypted 'data'
    NSMutableDictionary *msg = [self mutableCopy];
    [msg removeObjectForKey:@"content"];
    [msg setObject:base64 forKey:@"data"];
    return msg;
}

- (nullable DKDSecureMessage *)encryptWithKey:(NSDictionary *)password {
    NSAssert(_delegate, @"message delegate not set yet");
    
    // 1. encrypt 'message.content' to 'message.data'
    NSMutableDictionary *msg = [self _prepareWithKey:password];
    
    // 2. encrypt symmetric key(password) to 'message.key'
    
    // 2.1. encode & encrypt symmetric key
    NSString *receiver = self.envelope.receiver;
    NSData *key = [_delegate message:self encryptKey:password forReceiver:receiver];
    if (key) {
        // 2.2. encode encrypted key data
        NSObject *base64 = [_delegate message:self encodeKey:key];
        if (base64) {
            // 2.3. insert as 'key'
            [msg setObject:base64 forKey:@"key"];
        }
    }
    
    // 3. pack message
    return [[DKDSecureMessage alloc] initWithDictionary:msg];
}

- (nullable DKDSecureMessage *)encryptWithKey:(NSDictionary *)password
                                   forMembers:(NSArray *)members {
    NSAssert(_delegate, @"message delegate not set yet");
    
    // 1. encrypt 'content' to 'data'
    NSMutableDictionary *msg = [self _prepareWithKey:password];
    
    // 2. encrypt symmetric key(password) to 'message.keys'
    
    NSMutableDictionary *keyMap;
    keyMap = [[NSMutableDictionary alloc] initWithCapacity:members.count];
    NSData *key;
    NSObject *base64;
    for (NSString *ID in members) {
        // 2.1. encode & encrypt symmetric key
        key = [_delegate message:self encryptKey:password forReceiver:ID];
        if (key) {
            // 2.2. encode encrypted key data
            base64 = [_delegate message:self encodeKey:key];
            if (base64) {
                // 2.3. insert to 'message.keys' with member ID
                [keyMap setObject:base64 forKey:ID];
            }
        }
    }
    if (keyMap.count > 0) {
        [msg setObject:keyMap forKey:@"keys"];
    }
    // group ID
    NSString *group = self.content.group;
    if (group) {
        // NOTICE: this help the receiver knows the group ID
        //         when the group message separated to multi-messages,
        //         if don't want the others know you are the group members,
        //         remove it.
        [msg setObject:group forKey:@"group"];
    } else {
        NSAssert(false, @"group message error: %@", self);
    }
    
    // 3. pack message
    return [[DKDSecureMessage alloc] initWithDictionary:msg];
}

@end

@implementation DKDSecureMessage (ToInstantMessage)

- (nullable DKDInstantMessage *)decrypt {
    NSString *sender = self.envelope.sender;
    NSString *receiver = self.envelope.receiver;
    NSString *group = self.group;

    // 1. decrypt 'message.key' to symmetric key
    
    // 1.1. decode encrypted key data
    NSData *key = self.encryptedKey;
    NSDictionary *password;
    // 1.2. decrypt key data
    //      if key is empty, means it should be reused, get it from key cache
    if (group) {
        // group message
        password = [_delegate message:self decryptKey:key from:sender to:group];
    } else {
        // personal message?
        password = [_delegate message:self decryptKey:key from:sender to:receiver];
    }
    //NSAssert(password, @"failed to get symmetric key for msg: %@", self);
    
    // 2. decrypt 'message.data' to 'message.content'
    
    // 2.1. decode encrypted content data
    NSData *data = self.data;
    DKDContent *content;
    // 2.2. decrypt content data
    content = [_delegate message:self decryptContent:data withKey:password];
    // 2.3. check attachment for File/Image/Audio/Video message content
    //      if file data not download yet,
    //          decrypt file data with password;
    //      else,
    //          save password to 'message.content.password'.
    //      (do it in 'core' nmodule)
    if (!content) {
        NSLog(@"failed to decrypt message data: %@", self);
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
    NSAssert(_delegate, @"message delegate not set yet");
    // 1. sign with sender's private key
    NSData *signature = [_delegate message:self
                                  signData:self.data
                                 forSender:self.envelope.sender];
    if (!signature) {
        NSAssert(false, @"failed to sign message: %@", self);
        return nil;
    }
    NSObject *base64 = [_delegate message:self encodeSignature:signature];
    // 2. pack message
    NSMutableDictionary *mDict = [self mutableCopy];
    [mDict setObject:base64 forKey:@"signature"];
    return [[DKDReliableMessage alloc] initWithDictionary:mDict];
}

@end

@implementation DKDReliableMessage (ToSecureMessage)

- (nullable DKDSecureMessage *)verify {
    NSAssert(_delegate, @"message delegate not set yet");
    // 1. verify data signature with sender's public key
    if ([_delegate message:self
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
