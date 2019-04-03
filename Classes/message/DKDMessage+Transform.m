//
//  DKDMessage+Transform.m
//  DaoKeDao
//
//  Created by Albert Moky on 2019/3/15.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"

#import "DKDEnvelope.h"
#import "DKDMessageContent+File.h"

#import "DKDMessage+Transform.h"

@implementation DKDInstantMessage (ToSecureMessage)

- (nullable NSMutableDictionary *)_prepareDataWithKey:(NSDictionary *)PW {
    DKDMessageContent *content = self.content;
    // 1. check file data
    NSData *fileData = content.fileData;
    if (fileData != nil/* && content.URL == nil*/) {
        //NSAssert(false, @"should encrypt message content with file data, replace it with a URL first");
        NSString *filename = content.filename;
        NSURL *url = [_delegate message:self upload:fileData filename:filename withKey:PW];
        if (url) {
            // replace 'data' with 'URL'
            [content setObject:[url absoluteString] forKey:@"URL"];
            [content removeObjectForKey:@"data"];
        }
    }
    // 2. encrypt message content
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
                                   forMembers:(const NSArray *)members {
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
        // group ID
        const NSString *group = self.content.group;
        if (group) {
            [mDict setObject:group forKey:@"group"];
        } else {
            NSAssert(false, @"group message error: %@", self);
        }
    }
    
    // 3. pack message
    return [[DKDSecureMessage alloc] initWithDictionary:mDict];
}

@end

@implementation DKDSecureMessage (ToInstantMessage)

- (nullable DKDInstantMessage *)_decryptWithKeyData:(const NSData *)key
                                               from:(const NSString *)sender
                                                 to:(const NSString *)receiver
                                              group:(nullable const NSString *)grp {
    NSAssert(_delegate, @"message delegate not set yet");
    // 1. decrypt 'key' to symmetric key
    NSDictionary *PW = [_delegate message:self
                           decryptKeyData:key
                               fromSender:sender
                               toReceiver:receiver
                                  inGroup:grp];
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
    DKDInstantMessage *iMsg = [[DKDInstantMessage alloc] initWithDictionary:mDict];
    
    // 4. check file data
    NSURL *url = content.URL;
    if (url != nil && content.fileData == nil) {
        NSData *fileData = [_delegate message:iMsg download:url withKey:PW];
        if (fileData) {
            [content setObject:[fileData base64Encode] forKey:@"data"];
            [content removeObjectForKey:@"URL"];
        }
    }
    
    return iMsg;
}

- (nullable DKDInstantMessage *)decrypt {
    const NSString *sender = self.envelope.sender;
    const NSString *receiver = self.envelope.receiver;
    const NSString *grp = [self objectForKey:@"group"];
    NSAssert(!grp, @"group message must be decrypted with member ID");
    NSData *key = self.encryptedKey;
    // decrypt
    return [self _decryptWithKeyData:key from:sender to:receiver group:grp];
}

- (nullable DKDInstantMessage *)decryptForMember:(const NSString *)member {
    const NSString *sender = self.envelope.sender;
    const NSString *receiver = self.envelope.receiver;
    const NSString *grp = [self objectForKey:@"group"];
    // check group
    if (grp) {
        // if 'group' exists and the 'receiver' is a group ID too,
        // they must be equal; or the 'receiver' must equal to member
        NSAssert([grp isEqual:receiver] || [receiver isEqual:member],
                 @"receiver error: %@", receiver);
        // and the 'group' must not equal to member of course
        NSAssert(![grp isEqual:member],
                 @"member error: %@", member);
    } else {
        // if 'group' not exists, the 'receiver' must be a group ID, and
        // it is not equal to the member of course
        NSAssert(![receiver isEqual:member],
                 @"group error: %@, %@", member, self);
        grp = receiver;
    }
    // check key(s)
    NSData *key = [self.encryptedKeys encryptedKeyForID:member];
    if (!key) {
        // trimmed?
        key = self.encryptedKey;
    }
    // decrypt
    return [self _decryptWithKeyData:key from:sender to:member group:grp];
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
