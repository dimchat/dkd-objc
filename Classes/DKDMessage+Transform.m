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

- (nullable NSMutableDictionary *)_prepareDataWithKey:(NSDictionary *)PW {
    DKDContent *content = self.content;
    // 1. check attachment for File/Image/Audio/Video message content
    //    (do it in 'core' module)
    
    // 2. encrypt message content
    NSData *data = [_delegate message:self encryptContent:content withKey:PW];
    NSAssert(data, @"failed to encrypt content with key: %@", PW);
    
    // 3. encode encrypted data
    NSObject *base64 = [_delegate message:self encodeData:data];
    NSAssert(base64, @"failed to encode data: %@", data);
    
    // 4. replace 'content' with encrypted 'data'
    NSMutableDictionary *mDict = [self mutableCopy];
    [mDict removeObjectForKey:@"content"];
    if (base64) {
        [mDict setObject:base64 forKey:@"data"];
    }
    return mDict;
}

- (nullable DKDSecureMessage *)encryptWithKey:(NSDictionary *)password {
    NSAssert(_delegate, @"message delegate not set yet");
    // 1. encrypt 'content' to 'data'
    NSMutableDictionary *mDict = [self _prepareDataWithKey:password];
    
    NSString *ID = self.envelope.receiver;
    // 2. encrypt password to 'key'
    NSData *key = [_delegate message:self encryptKey:password forReceiver:ID];
    if (key) {
        NSObject *base64 = [_delegate message:self encodeData:key];
        if (base64) {
            [mDict setObject:base64 forKey:@"key"];
        }
    } else {
        NSLog(@"reused key: %@", password);
    }
    
    // 3. pack message
    return [[DKDSecureMessage alloc] initWithDictionary:mDict];
}

- (nullable DKDSecureMessage *)encryptWithKey:(NSDictionary *)password
                                   forMembers:(NSArray *)members {
    NSAssert(_delegate, @"message delegate not set yet");
    // 1. encrypt 'content' to 'data'
    NSMutableDictionary *mDict = [self _prepareDataWithKey:password];
    
    // 2. encrypt password to 'keys'
    NSMutableDictionary *keyMap;
    keyMap = [[NSMutableDictionary alloc] initWithCapacity:members.count];
    NSData *key;
    NSObject *base64;
    for (NSString *ID in members) {
        key = [_delegate message:self encryptKey:password forReceiver:ID];
        if (key) {
            base64 = [_delegate message:self encodeData:key];
            if (base64) {
                [keyMap setObject:base64 forKey:ID];
            }
        } else {
            NSLog(@"reused key: %@", password);
        }
    }
    if (keyMap.count > 0) {
        [mDict setObject:keyMap forKey:@"keys"];
    }
    // group ID
    NSString *group = self.content.group;
    if (group) {
        // NOTICE: this help the receiver knows the group ID
        //         when the group message separated to multi-messages,
        //         if don't want the others know you are the group members,
        //         remove it.
        [mDict setObject:group forKey:@"group"];
    } else {
        NSAssert(false, @"group message error: %@", self);
    }
    
    // 3. pack message
    return [[DKDSecureMessage alloc] initWithDictionary:mDict];
}

@end

@implementation DKDSecureMessage (ToInstantMessage)

- (nullable DKDInstantMessage *)decrypt {
    NSString *sender = self.envelope.sender;
    NSString *receiver = self.envelope.receiver;
    NSString *group = self.group;
    // 1. decrypt 'key' to symmetric key
    NSData *key = self.encryptedKey;
    NSDictionary *password;
    if (!group) {
        // personal message
        password = [_delegate message:self
                           decryptKey:key
                                 from:sender
                                   to:receiver];
    } else {
        password = [_delegate message:self
                           decryptKey:key
                                 from:sender
                                   to:group];
    }
    // 2. decrypt 'data' to 'content'
    //    (remember to save password for decrypted File/Image/Audio/Video data)
    DKDContent *content = [_delegate message:self
                              decryptContent:self.data
                                     withKey:password];
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
