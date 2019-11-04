//
//  DKDContent.m
//  DaoKeDao
//
//  Created by Albert Moky on 2019/6/17.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DKDForwardContent.h"

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
}

@property (nonatomic) UInt8 type;
@property (nonatomic) NSUInteger serialNumber;

@end

@implementation DKDContent

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    return [self initWithType:0];
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
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // content type
        NSNumber *type = [_storeDictionary objectForKey:@"type"];
        _type = [type unsignedCharValue];
        // serial number
        NSNumber *sn = [_storeDictionary objectForKey:@"sn"];
        _serialNumber = [sn unsignedIntegerValue];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDContent *content = [super copyWithZone:zone];
    if (content) {
        //content.type = _type;
        content.serialNumber = _serialNumber;
    }
    return content;
}

- (void)setType:(UInt8)type {
    if (_type != type) {
        [_storeDictionary setObject:@(type) forKey:@"type"];
        _type = type;
    }
}

@end

@implementation DKDContent (Group)

- (nullable NSString *)group {
    return [_storeDictionary objectForKey:@"group"];
}

- (void)setGroup:(nullable NSString *)group {
    if (group) {
        [_storeDictionary setObject:group forKey:@"group"];
    } else {
        [_storeDictionary removeObjectForKey:@"group"];
    }
}

@end

static NSMutableDictionary<NSNumber *, Class> *content_classes(void) {
    static NSMutableDictionary<NSNumber *, Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [[NSMutableDictionary alloc] init];
        // Forward (Top-Secret)
        [classes setObject:[DKDForwardContent class] forKey:@(DKDContentType_Forward)];
        // Text
        // File
        // Command
        // ...
    });
    return classes;
}

@implementation DKDContent (Runtime)

+ (void)registerClass:(nullable Class)clazz forType:(NSUInteger)type {
    NSAssert(![clazz isEqual:self], @"only subclass");
    if (clazz) {
        NSAssert([clazz isSubclassOfClass:self], @"error: %@", clazz);
        [content_classes() setObject:clazz forKey:@(type)];
    } else {
        [content_classes() removeObjectForKey:@(type)];
    }
}

+ (nullable instancetype)getInstance:(id)content {
    if (!content) {
        return nil;
    }
    NSAssert([content isKindOfClass:[NSDictionary class]], @"content error: %@", content);
    if ([self isEqual:[DKDContent class]]) {
        if ([content isKindOfClass:[DKDContent class]]) {
            // return Content object directly
            return content;
        }
        // create instance by subclass with content type
        NSNumber *type = [content objectForKey:@"type"];
        Class clazz = [content_classes() objectForKey:type];
        if (clazz) {
            return [clazz getInstance:content];
        }
    }
    // custom message content
    return [[self alloc] initWithDictionary:content];
}

@end
