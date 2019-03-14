//
//  DKDReliableMessage+Meta.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/12/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDReliableMessage+Meta.h"

@implementation DKDReliableMessage (Meta)

- (const NSDictionary *)meta {
    return [_storeDictionary objectForKey:@"meta"];
}

- (void)setMeta:(const NSDictionary *)meta {
    if (meta) {
        [_storeDictionary setObject:meta forKey:@"meta"];
    } else {
        [_storeDictionary removeObjectForKey:@"meta"];
    }
}

@end
