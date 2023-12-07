// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DKDSecureMessage.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DaoKeDao/DKDMessage.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Secure Message
 *  ~~~~~~~~~~~~~~
 *  Instant Message encrypted by a symmetric key
 *
 *      data format: {
 *          //-- envelope
 *          sender   : "moki@xxx",
 *          receiver : "hulk@yyy",
 *          time     : 123,
 *          //-- content data & key/keys
 *          data     : "...",  // base64_encode( symmetric_encrypt(content))
 *          key      : "...",  // base64_encode(asymmetric_encrypt(password))
 *          keys     : {
 *              "ID1": "key1", // base64_encode(asymmetric_encrypt(password))
 *          }
 *      }
 */
@protocol DKDSecureMessage <DKDMessage>

@property (readonly, strong, nonatomic) NSData *data;

/**
 * Password to decode the content, which encrypted by contact.PK
 *
 *   secureMessage.content = symmetricKey.encrypt(instantMessage.content);
 *   encryptedKey = receiver.publicKey.encrypt(symmetricKey);
 */
@property (readonly, strong, nonatomic, nullable) NSData *encryptedKey;
@property (readonly, strong, nonatomic, nullable) NSDictionary *encryptedKeys;

@end

@protocol DKDSecureMessageFactory <NSObject>

- (nullable id<DKDSecureMessage>)parseSecureMessage:(NSDictionary *)msg;

@end

#ifdef __cplusplus
extern "C" {
#endif

_Nullable id<DKDSecureMessageFactory> DKDSecureMessageGetFactory(void);
void DKDSecureMessageSetFactory(id<DKDSecureMessageFactory> factory);

_Nullable id<DKDSecureMessage> DKDSecureMessageParse(id msg);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
