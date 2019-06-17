//
//  DKDContent.m
//  DaoKeDao
//
//  Created by Albert Moky on 2019/6/17.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DKDContent.h"

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

@interface DKDContent () {
    
    UInt8 _type;
    NSUInteger _serialNumber;
    
    const NSString *_group;
}

@property (nonatomic) UInt8 type;

@end

@implementation DKDContent

typedef NSMutableDictionary<const NSNumber *, Class> MKMContentClassMap;

static MKMContentClassMap *s_contentClasses = nil;

+ (MKMContentClassMap *)contentClasses {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_contentClasses = [[NSMutableDictionary alloc] init];
    });
    return s_contentClasses;
}

+ (void)registerClass:(nullable Class)clazz forType:(NSUInteger)type {
    NSAssert([clazz isSubclassOfClass:self], @"class error: %@", clazz);
    if (clazz) {
        [[self contentClasses] setObject:clazz forKey:@(type)];
    } else {
        [[self contentClasses] removeObjectForKey:@(type)];
    }
}

+ (nullable Class)classForType:(const NSNumber *)type {
    return [[self contentClasses] objectForKey:type];
}

+ (instancetype)contentWithContent:(id)content {
    if ([content isKindOfClass:[DKDContent class]]) {
        return content;
    } else if ([content isKindOfClass:[NSDictionary class]]) {
        // get class by content type
        NSNumber *type = [content objectForKey:@"type"];
        Class clazz = [[self class] classForType:type];
        if (clazz) {
            return [[clazz alloc] initWithDictionary:content];
        } else {
            return [[self alloc] initWithDictionary:content];
        }
    } else {
        NSAssert(!content, @"unexpected message content: %@", content);
        return nil;
    }
}

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    self = [self initWithType:0];
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // content type
        _type = [[dict objectForKey:@"type"] unsignedIntegerValue];
        _serialNumber = [[dict objectForKey:@"sn"] unsignedIntegerValue];
        _group = [dict objectForKey:@"group"];
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(UInt8)type {
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

- (const NSString *)group {
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
