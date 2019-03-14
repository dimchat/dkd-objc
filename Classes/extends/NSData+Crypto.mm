//
//  NSData+Crypto.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"

@implementation NSData (Encode)

- (NSString *)base64Encode {
    NSDataBase64EncodingOptions opt;
    opt = NSDataBase64EncodingEndLineWithCarriageReturn;
    return [self base64EncodedStringWithOptions:opt];
}

@end
