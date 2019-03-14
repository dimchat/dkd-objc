//
//  NString+Crypto.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"

@implementation NSString (Decode)

- (NSData *)base64Decode {
    NSDataBase64DecodingOptions opt;
    opt = NSDataBase64DecodingIgnoreUnknownCharacters;
    return [[NSData alloc] initWithBase64EncodedString:self options:opt];
}

@end
