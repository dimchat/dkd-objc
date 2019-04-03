//
//  DKDMessageContent+File.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DKDMessageContent+File.h"

@implementation DKDMessageContent (File)

- (instancetype)initWithFileData:(const NSData *)data
                        filename:(nullable const NSString *)name {
    //NSAssert(data.length > 0, @"file data cannot be empty");
    if (self = [self initWithType:DKDMessageType_File]) {
        // file data
        if (data) {
            NSString *content = [data base64Encode];
            [_storeDictionary setObject:content forKey:@"data"];
        }
        
        // filename
        if (name) {
            [_storeDictionary setObject:name forKey:@"filename"];
        }
    }
    return self;
}

- (nullable NSURL *)URL {
    id url = [_storeDictionary objectForKey:@"URL"];
    if ([url isKindOfClass:[NSURL class]]) {
        return url;
    } else if ([url isKindOfClass:[NSString class]]) {
        return [NSURL URLWithString:url];
    } else {
        NSAssert(!url, @"URL error: %@", url);
        return nil;
    }
}

- (nullable NSData *)fileData {
    NSString *content = [_storeDictionary objectForKey:@"data"];
    if (content) {
        // decode file data
        return [content base64Decode];
    }
    return nil;
}

- (nullable NSString *)filename {
    return [_storeDictionary objectForKey:@"filename"];
}

@end
