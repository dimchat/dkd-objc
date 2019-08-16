//
//  DKDSecureMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDEnvelope.h"
#import "DKDMessage+Transform.h"

#import "DKDSecureMessage.h"

@interface DKDSecureMessage ()

@property (strong, nonatomic) NSData *data;

@property (strong, nonatomic, nullable) NSData *encryptedKey;
@property (strong, nonatomic, nullable) NSDictionary *encryptedKeys;

@end

@implementation DKDSecureMessage

- (instancetype)initWithEnvelope:(DKDEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    return [self initWithDictionary:env];
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
        _data = [_delegate message:self decodeData:content];
    }
    return _data;
}

- (NSData *)encryptedKey {
    if (!_encryptedKey) {
        NSString *key = [_storeDictionary objectForKey:@"key"];
        if (!key) {
            // check 'keys'
            NSDictionary *keys = self.encryptedKeys;
            key = [keys objectForKey:self.envelope.receiver];
        }
        if (key) {
            _encryptedKey = [_delegate message:self decodeData:key];
        }
    }
    return _encryptedKey;
}

- (NSDictionary *)encryptedKeys {
    if (!_encryptedKeys) {
        _encryptedKeys = [_storeDictionary objectForKey:@"keys"];
    }
    return _encryptedKeys;
}

@end
