//
//  DKDTextContent.m
//  DaoKeDaoTests
//
//  Created by Albert Moky on 2019/6/17.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DKDTextContent.h"

@implementation DKDTextContent

- (instancetype)initWithText:(NSString *)text {
    NSAssert(text, @"text cannot be empty");
    if (self = [self initWithType:DKDContentType_Text]) {
        // text
        if (text) {
            [_storeDictionary setObject:text forKey:@"text"];
        }
    }
    return self;
}

- (NSString *)text {
    return [_storeDictionary objectForKey:@"text"];
}

@end
