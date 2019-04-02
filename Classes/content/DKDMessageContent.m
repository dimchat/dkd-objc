//
//  DKDMessageContent.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessageContent.h"

static inline NSUInteger serial_number(void) {
    // because we must make sure all messages in a same chat box won't have
    // same serial numbers, so we can't use time-related numbers, therefore
    // the best choice is a totally random number, maybe.
    uint32_t sn = 0;
    while (sn == 0) {
        sn = arc4random();
    }
    return sn;
}

@interface DKDMessageContent () {
    
    DKDMessageType _type;
    NSUInteger _serialNumber;
    
    const NSString *_group;
}

@property (nonatomic) DKDMessageType type;
@property (nonatomic) NSUInteger serialNumber;

@end

@implementation DKDMessageContent

+ (instancetype)contentWithContent:(id)content {
    if ([content isKindOfClass:[DKDMessageContent class]]) {
        return content;
    } else if ([content isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:content];
    } else if ([content isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:content];
    } else {
        NSAssert(!content, @"unexpected message content: %@", content);
        return nil;
    }
}

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    self = [self initWithType:DKDMessageType_Unknown];
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _type = DKDMessageType_Unknown;
        _serialNumber = 0;
        _group = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(DKDMessageType)type {
    NSUInteger sn = serial_number();
    NSDictionary *dict = @{@"type":@(type),
                           @"sn"  :@(sn),
                           };
    if (self = [super initWithDictionary:dict]) {
        _type = type;
        _serialNumber = sn;
        _group = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDMessageContent *content = [super copyWithZone:zone];
    if (content) {
        //content.type = _type;
        //content.serialNumber = _serialNumber;
        //content.group = _group;
    }
    return content;
}

- (DKDMessageType)type {
    if (_type == DKDMessageType_Unknown) {
        NSNumber *type = [_storeDictionary objectForKey:@"type"];
        _type = [type unsignedIntegerValue];
    }
    return _type;
}

- (void)setType:(DKDMessageType)type {
    [_storeDictionary setObject:@(type) forKey:@"type"];
    _type = type;
}

- (NSUInteger)serialNumber {
    if (_serialNumber == 0) {
        NSNumber *sn = [_storeDictionary objectForKey:@"sn"];
        _serialNumber = [sn unsignedIntegerValue];
        NSAssert(_serialNumber > 0, @"sn cannot be empty");
    }
    return _serialNumber;
}

- (void)setSerialNumber:(NSUInteger)serialNumber {
    NSAssert(serialNumber != 0, @"serian number cannot be ZERO");
    [_storeDictionary setObject:@(serialNumber) forKey:@"sn"];
    _serialNumber = serialNumber;
}

- (const NSString *)group {
    if (!_group) {
        _group = [_storeDictionary objectForKey:@"group"];
    }
    return _group;
}

- (void)setGroup:(const NSString *)group {
    if (![_group isEqual:group]) {
        if (group) {
            [_storeDictionary setObject:group forKey:@"group"];
        } else {
            [_storeDictionary removeObjectForKey:@"group"];
        }
        _group = group;
    }
}

@end
