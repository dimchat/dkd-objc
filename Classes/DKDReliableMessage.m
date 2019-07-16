//
//  DKDReliableMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessage+Transform.h"

#import "DKDReliableMessage.h"

@interface DKDReliableMessage ()

@property (strong, nonatomic) NSData *signature;

@end

@implementation DKDReliableMessage

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
        _signature = [_delegate message:self decodeSignature:CT];
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
