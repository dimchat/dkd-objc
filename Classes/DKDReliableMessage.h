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
//  DKDReliableMessage.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DaoKeDao/DKDSecureMessage.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Instant Message signed by an asymmetric key
 *
 *      data format: {
 *          //-- envelope
 *          sender   : "moki@xxx",
 *          receiver : "hulk@yyy",
 *          time     : 123,
 *          //-- content data & key/keys
 *          data     : "...",  // base64_encode(symmetric)
 *          key      : "...",  // base64_encode(asymmetric)
 *          keys     : {
 *              "ID1": "key1", // base64_encode(asymmetric)
 *          },
 *          //-- signature
 *          signature: "..."   // base64_encode()
 *      }
 */
@protocol DKDReliableMessage <DKDSecureMessage>

@property (readonly, strong, nonatomic) NSData *signature;

/**
 *  Sender's Meta
 *  ~~~~~~~~~~~~~
 *  Extends for the first message package of 'Handshake' protocol.
 */
@property (strong, nonatomic, nullable) id<MKMMeta> meta;

/**
 *  Sender's Visa
 *  ~~~~~~~~~~~~~
 *  Extends for the first message package of 'Handshake' protocol.
*/
@property (strong, nonatomic, nullable) id<MKMVisa> visa;

/*
 *  Verify the Reliable Message to Secure Message
 *
 *    +----------+      +----------+
 *    | sender   |      | sender   |
 *    | receiver |      | receiver |
 *    | time     |  ->  | time     |
 *    |          |      |          |
 *    | data     |      | data     |  1. verify(data, signature, sender.PK)
 *    | key/keys |      | key/keys |
 *    | signature|      +----------+
 *    +----------+
 */

/**
 *  Verify 'data' and 'signature' field with sender's public key
 *
 * @return SecureMessage object
 */
- (nullable id<DKDSecureMessage>)verify;

@end

@protocol DKDReliableMessageFactory <NSObject>

- (nullable id<DKDReliableMessage>)parseReliableMessage:(NSDictionary *)msg;

@end

#ifdef __cplusplus
extern "C" {
#endif

id<DKDReliableMessageFactory> DKDReliableMessageGetFactory(void);
void DKDReliableMessageSetFactory(id<DKDReliableMessageFactory> factory);

id<DKDReliableMessage> DKDReliableMessageParse(id msg);

_Nullable id<MKMMeta> DKDReliableMessageGetMeta(NSDictionary *msg);
void DKDReliableMessageSetMeta(id<MKMMeta> meta, NSMutableDictionary *msg);

_Nullable id<MKMVisa> DKDReliableMessageGetVisa(NSDictionary *msg);
void DKDReliableMessageSetVisa(id<MKMVisa> visa, NSMutableDictionary *msg);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

#define DKDReliableMessageFromDictionary(dict) DKDReliableMessageParse(dict)

#pragma mark -

@interface DKDReliableMessage : DKDSecureMessage <DKDReliableMessage>

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

@interface DKDReliableMessageFactory : NSObject <DKDReliableMessageFactory>

@end

NS_ASSUME_NONNULL_END
