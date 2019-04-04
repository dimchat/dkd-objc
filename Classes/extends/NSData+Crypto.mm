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

- (NSString *)hexEncode {
    NSMutableString *output = nil;
    
    const char *bytes = (const char *)[self bytes];
    NSUInteger len = [self length];
    output = [[NSMutableString alloc] initWithCapacity:(len*2)];
    for (int i = 0; i < len; ++i) {
        [output appendFormat:@"%02x", (unsigned char)bytes[i]];
    }
    
    return output;
}

- (NSString *)base64Encode {
    NSDataBase64EncodingOptions opt;
    opt = NSDataBase64EncodingEndLineWithCarriageReturn;
    return [self base64EncodedStringWithOptions:opt];
}

@end

@implementation NSData (Hash)

- (NSData *)md5 {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5([self bytes], (CC_LONG)[self length], digest);
    return [[NSData alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
}

- (NSData *)sha256 {
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([self bytes], (CC_LONG)[self length], digest);
    return [[NSData alloc] initWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

@end
