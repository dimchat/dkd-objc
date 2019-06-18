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

static NSMutableDictionary<NSNumber *, Class> *content_classes(void) {
    static NSMutableDictionary<NSNumber *, Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [[NSMutableDictionary alloc] init];
        // Text
        // Image
        // Command
        // ...
    });
    return classes;
}

@implementation DKDContent (Runtime)

+ (void)registerClass:(nullable Class)contentClass forType:(NSUInteger)type {
    NSAssert(![contentClass isEqual:self], @"only subclass");
    NSAssert([contentClass isSubclassOfClass:self], @"class error: %@", contentClass);
    if (contentClass) {
        [content_classes() setObject:contentClass forKey:@(type)];
    } else {
        [content_classes() removeObjectForKey:@(type)];
    }
}

+ (nullable instancetype)getInstance:(id)content {
    if (!content) {
        return nil;
    }
    if ([content isKindOfClass:[DKDContent class]]) {
        // return Content object directly
        return content;
    }
    NSAssert([content isKindOfClass:[NSDictionary class]],
             @"content should be a dictionary: %@", content);
    if (![self isEqual:[DKDContent class]]) {
        // subclass
        NSAssert([self isSubclassOfClass:[DKDContent class]], @"content class error");
        return [[self alloc] initWithDictionary:content];
    }
    // create instance by subclass with meta version
    NSNumber *type = [content objectForKey:@"type"];
    Class clazz = [content_classes() objectForKey:type];
    if (clazz) {
        return [clazz getInstance:content];
    } else {
        return [[self alloc] initWithDictionary:content];
    }
}

@end
