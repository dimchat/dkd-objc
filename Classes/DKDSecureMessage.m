//
//  DKDSecureMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DKDEnvelope.h"

#import "DKDSecureMessage.h"

@interface DKDSecureMessage ()

@property (strong, nonatomic) NSData *data;

@property (strong, nonatomic, nullable) NSData *encryptedKey;
@property (strong, nonatomic, nullable) DKDEncryptedKeyMap *encryptedKeys;

@end

@implementation DKDSecureMessage

- (instancetype)initWithEnvelope:(DKDEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    NSData *data = nil;
    NSData *key = nil;
    return [self initWithData:data encryptedKey:key envelope:env];
}

/* designated initializer */
- (instancetype)initWithData:(NSData *)content
                encryptedKey:(nullable NSData *)key
                    envelope:(DKDEnvelope *)env {
    NSAssert(content, @"content cannot be empty");
    if (self = [super initWithEnvelope:env]) {
        // content data
        if (content) {
            [_storeDictionary setObject:[content base64Encode] forKey:@"data"];
        }
        _data = content;
        
        // encrypted key
        if (key) {
            [_storeDictionary setObject:[key base64Encode] forKey:@"key"];
        }
        _encryptedKey = key;
        
        _encryptedKeys = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithData:(NSData *)content
               encryptedKeys:(nullable DKDEncryptedKeyMap *)keys
                    envelope:(DKDEnvelope *)env {
    NSAssert(content, @"content cannot be empty");
    if (self = [super initWithEnvelope:env]) {
        // content data
        if (content) {
            [_storeDictionary setObject:[content base64Encode] forKey:@"data"];
        }
        _data = content;
        
        _encryptedKey = nil;
        
        // encrypted keys
        if (keys.count > 0) {
            [_storeDictionary setObject:_encryptedKeys forKey:@"keys"];
        }
        _encryptedKeys = keys;
    }
    return self;
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
        NSString *content = [_storeDictionary objectForKey:@"data"];
        NSAssert(content, @"content data cannot be empty");
        _data = [content base64Decode];
    }
    return _data;
}

- (NSData *)encryptedKey {
    if (!_encryptedKey) {
        NSString *key = [_storeDictionary objectForKey:@"key"];
        if (key) {
            _encryptedKey = [key base64Decode];
        } else {
            // get from the key map
            NSString *ID = self.envelope.receiver;
            DKDEncryptedKeyMap *keyMap = self.encryptedKeys;
            return [keyMap encryptedKeyForID:ID];
        }
    }
    return _encryptedKey;
}

- (DKDEncryptedKeyMap *)encryptedKeys {
    if (!_encryptedKeys) {
        NSDictionary *keys = [_storeDictionary objectForKey:@"keys"];
        _encryptedKeys = DKDEncryptedKeyMapFromDictionary(keys);
        
        if (_encryptedKeys != keys) {
            // replace the encrypted keys object
            NSAssert(_encryptedKeys, @"encrypted keys error: %@", keys);
            [_storeDictionary setObject:_encryptedKeys forKey:@"keys"];
        }
    }
    return _encryptedKeys;
}

@end

#pragma mark -

@implementation DKDEncryptedKeyMap

- (void)setObject:(id)anObject forKey:(NSString *)aKey {
    NSAssert(false, @"DON'T call me");
    //[super setObject:anObject forKey:aKey];
}

- (NSData *)encryptedKeyForID:(NSString *)ID {
    NSString *encode = [_storeDictionary objectForKey:ID];
    return [encode base64Decode];
}

- (void)setEncryptedKey:(NSData *)key forID:(NSString *)ID {
    if (key) {
        NSString *encode = [key base64Encode];
        [_storeDictionary setObject:encode forKey:ID];
    } else {
        [_storeDictionary removeObjectForKey:ID];
    }
}

@end

@implementation DKDEncryptedKeyMap (Runtime)

+ (nullable instancetype)getInstance:(id)map {
    if (!map) {
        return nil;
    }
    if ([map isKindOfClass:[DKDEncryptedKeyMap class]]) {
        return map;
    }
    NSAssert([map isKindOfClass:[NSDictionary class]],
             @"key map should be a dictionary: %@", map);
    // create instance
    return [[self alloc] initWithDictionary:map];
}

@end
