//
//  DKDReliableMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DKDReliableMessage.h"

@interface DKDReliableMessage ()

@property (strong, nonatomic) NSData *signature;

@end

@implementation DKDReliableMessage

- (instancetype)initWithData:(NSData *)content
                encryptedKey:(nullable NSData *)key
                    envelope:(DKDEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    NSData *CT = nil;
    return [self initWithData:content
                    signature:CT
                 encryptedKey:key
                     envelope:env];
}

- (instancetype)initWithData:(NSData *)content
               encryptedKeys:(nullable DKDEncryptedKeyMap *)keys
                    envelope:(DKDEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    NSData *CT = nil;
    return [self initWithData:content
                    signature:CT
                encryptedKeys:keys
                     envelope:env];
}

/* designated initializer */
- (instancetype)initWithData:(NSData *)content
                   signature:(NSData *)CT
                encryptedKey:(nullable NSData *)key
                    envelope:(DKDEnvelope *)env {
    NSAssert(CT, @"signature cannot be empty");
    if (self = [super initWithData:content
                      encryptedKey:key
                          envelope:env]) {
        // signature
        if (CT) {
            [_storeDictionary setObject:[CT base64Encode] forKey:@"signature"];
        }
        _signature = CT;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithData:(NSData *)content
                   signature:(NSData *)CT
               encryptedKeys:(nullable DKDEncryptedKeyMap *)keys
                    envelope:(DKDEnvelope *)env {
    NSAssert(CT, @"signature cannot be empty");
    if (self = [super initWithData:content
                     encryptedKeys:keys
                          envelope:env]) {
        // signature
        if (CT) {
            [_storeDictionary setObject:[CT base64Encode] forKey:@"signature"];
        }
        _signature = CT;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _signature = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDReliableMessage *rMsg = [super copyWithZone:zone];
    if (rMsg) {
        rMsg.signature = _signature;
    }
    return rMsg;
}

- (NSData *)signature {
    if (!_signature) {
        NSString *CT = [_storeDictionary objectForKey:@"signature"];
        NSAssert(CT, @"signature cannot be empty");
        _signature = [CT base64Decode];
    }
    return _signature;
}

@end

#pragma mark -

@implementation DKDReliableMessage (Meta)

- (NSDictionary *)meta {
    return [_storeDictionary objectForKey:@"meta"];
}

- (void)setMeta:(NSDictionary *)meta {
    if (meta) {
        [_storeDictionary setObject:meta forKey:@"meta"];
    } else {
        [_storeDictionary removeObjectForKey:@"meta"];
    }
}

@end
