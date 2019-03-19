//
//  NSData+Crypto.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "NSData+Crypto.h"

@implementation NSData (Encode)

- (NSString *)base64Encode {
    NSDataBase64EncodingOptions opt;
    opt = NSDataBase64EncodingEndLineWithCarriageReturn;
    return [self base64EncodedStringWithOptions:opt];
}

@end

@implementation NSData (Hash)

- (NSData *)sha256 {
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([self bytes], (CC_LONG)[self length], digest);
    return [[NSData alloc] initWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

@end
