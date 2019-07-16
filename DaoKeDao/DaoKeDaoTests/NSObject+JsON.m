//
//  NSObject+JsON.m
//  DaoKeDaoTests
//
//  Created by Albert Moky on 2019/7/16.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

@implementation NSObject (JsON)

- (NSData *)jsonData {
    NSData *data = nil;
    
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error = nil;
        data = [NSJSONSerialization dataWithJSONObject:self
                                               options:NSJSONWritingSortedKeys
                                                 error:&error];
        NSAssert(!error, @"json error: %@", error);
    } else {
        NSAssert(false, @"object format not support for json: %@", self);
    }
    
    return data;
}

- (NSString *)jsonString {
    return [[self jsonData] UTF8String];
}

@end

@implementation NSString (Convert)

- (NSData *)data {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@implementation NSData (Convert)

- (NSString *)UTF8String {
    const unsigned char * bytes = self.bytes;
    NSUInteger length = self.length;
    while (length > 0) {
        if (bytes[length-1] == 0) {
            --length;
        } else {
            break;
        }
    }
    return [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
}

@end

@implementation NSData (JsON)

- (id)jsonObject {
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingAllowFragments error:&error];
    NSAssert(!error, @"json error: %@", error);
    return obj;
}

- (id)jsonMutableContainer {
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:&error];
    NSAssert(!error, @"json error: %@", error);
    return obj;
}

- (NSString *)jsonString {
    return [self jsonObject];
}

- (NSArray *)jsonArray {
    return [self jsonObject];
}

- (NSDictionary *)jsonDictionary {
    return [self jsonObject];
}

- (NSMutableArray *)jsonMutableArray {
    return [self jsonMutableContainer];
}

- (NSMutableDictionary *)jsonMutableDictionary {
    return [self jsonMutableContainer];
}

@end
