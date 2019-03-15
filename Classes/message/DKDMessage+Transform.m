//
//  DKDMessage+Transform.m
//  DaoKeDao
//
//  Created by Albert Moky on 2019/3/15.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"

#import "DKDEnvelope.h"

#import "DKDMessage+Transform.h"

@implementation DKDInstantMessage (ToSecureMessage)

- (nullable NSMutableDictionary *)_prepareDataWithKey:(NSDictionary *)PW {
    DKDMessageContent *content = self.content;
    NSData *data = [_delegate message:self encryptContent:content withKey:PW];
    if (!data) {
        NSAssert(false, @"failed to encrypt content with key: %@", PW);
        return nil;
    }
    NSMutableDictionary *mDict = [self mutableCopy];
    [mDict removeObjectForKey:@"content"];
    [mDict setObject:[data base64Encode] forKey:@"data"];
    return mDict;
}

- (nullable DKDSecureMessage *)encryptWithKey:(NSDictionary *)password {
    NSAssert(_delegate, @"message delegate not set yet");
    // 1. encrypt 'content' to 'data'
    NSMutableDictionary *mDict;
    mDict = [self _prepareDataWithKey:password];
    if (!mDict) {
        return nil;
    }
    
    // 2. encrypt password to 'key'
    const NSString *ID = self.envelope.receiver;
    NSData *key;
    key = [_delegate message:self encryptKey:password forReceiver:ID];
    if (key) {
        [mDict setObject:[key base64Encode] forKey:@"key"];
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
    NSMutableDictionary *mDict;
    mDict = [self _prepareDataWithKey:password];
    if (!mDict) {
        return nil;
    }
    
    // 2. encrypt password to 'keys'
    NSMutableDictionary *keyMap;
    keyMap = [[NSMutableDictionary alloc] initWithCapacity:members.count];
    NSData *key;
    for (NSString *ID in members) {
        key = [_delegate message:self encryptKey:password forReceiver:ID];
        if (key) {
            [keyMap setObject:[key base64Encode] forKey:ID];
        }
    }
    if (keyMap.count > 0) {
        [mDict setObject:keyMap forKey:@"keys"];
    }
    
    // 3. pack message
    return [[DKDSecureMessage alloc] initWithDictionary:mDict];
}

@end

@implementation DKDSecureMessage (ToInstantMessage)

- (nullable NSMutableDictionary *)_prepareDataWithKeyData:(const NSData *)key
                                                 receiver:(const NSString *)ID {
    NSAssert(_delegate, @"message delegate not set yet");
    // 1. decrypt 'key' to symmetric key
    NSDictionary *PW;
    PW = [_delegate message:self decryptKeyData:key forReceiver:ID];
    if (!PW) {
        NSLog(@"failed to decrypt symmetric key: %@", self);
        return nil;
    }
    
    // 2. decrypt 'data' to 'content'
    DKDMessageContent *content;
    content = [_delegate message:self decryptData:self.data withKey:PW];
    if (!content) {
        NSLog(@"failed to decrypt message data: %@", self);
        return nil;
    }
    
    // 3. pack message
    NSMutableDictionary *mDict = [self mutableCopy];
    [mDict removeObjectForKey:@"key"];
    [mDict removeObjectForKey:@"data"];
    [mDict setObject:content forKey:@"content"];
    return mDict;
}

- (nullable DKDInstantMessage *)decrypt {
    NSData *key = self.encryptedKey;
    const NSString *ID = self.envelope.receiver;
    // decrypt
    NSDictionary *dict = [self _prepareDataWithKeyData:key receiver:ID];
    if (!dict) {
        NSAssert(false, @"failed to decrypt message: %@", self);
        return nil;
    }
    // pack message
    return [[DKDInstantMessage alloc] initWithDictionary:dict];
}

- (nullable DKDInstantMessage *)decryptForMember:(const NSString *)ID {
    NSData *key = [self.encryptedKeys encryptedKeyForID:ID];
    // decrypt
    NSDictionary *dict = [self _prepareDataWithKeyData:key receiver:ID];
    if (!dict) {
        NSAssert(false, @"failed to decrypt message: %@", self);
        return nil;
    }
    // pack message
    return [[DKDInstantMessage alloc] initWithDictionary:dict];
}

@end

@implementation DKDSecureMessage (ToReliableMessage)

- (nullable DKDReliableMessage *)sign {
    const NSString *sender = self.envelope.sender;
    NSData *data = self.data;
    NSAssert(_delegate, @"message delegate not set yet");
    NSData *signature;
    // sign
    signature = [_delegate message:self signData:data forSender:sender];
    if (!signature) {
        NSAssert(false, @"failed to sign message: %@", self);
        return nil;
    }
    // pack message
    NSMutableDictionary *mDict = [self mutableCopy];
    [mDict setObject:[signature base64Encode] forKey:@"signature"];
    return [[DKDReliableMessage alloc] initWithDictionary:mDict];
}

@end

@implementation DKDReliableMessage (ToSecureMessage)

- (nullable DKDSecureMessage *)verify {
    const NSString *sender = self.envelope.sender;
    NSData *data = self.data;
    NSData *signature = self.signature;
    NSAssert(_delegate, @"message delegate not set yet");
    BOOL correct = [_delegate message:self
                           verifyData:data
                        withSignature:signature
                            forSender:sender];
    if (!correct) {
        NSAssert(false, @"message signature not match: %@", self);
        return nil;
    }
    NSMutableDictionary *mDict = [self mutableCopy];
    [mDict removeObjectForKey:@"signature"];
    return [[DKDSecureMessage alloc] initWithDictionary:mDict];
}

@end
