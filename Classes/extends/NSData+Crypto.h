//
//  NSData+Crypto.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Encode)

- (NSString *)base64Encode;

@end

@interface NSData (Hash)

- (NSData *)sha256;

@end

NS_ASSUME_NONNULL_END
