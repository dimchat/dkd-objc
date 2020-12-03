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

#import "DKDMessage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DKDInstantMessage;
@protocol DKDReliableMessage;

/*
 *  Secure Message
 *      Instant Message encrypted by a symmetric key
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

/*
 *  Decrypt the Secure Message to Instant Message
 *
 *    +----------+      +----------+
 *    | sender   |      | sender   |
 *    | receiver |      | receiver |
 *    | time     |  ->  | time     |
 *    |          |      |          |  1. PW      = decrypt(key, receiver.SK)
 *    | data     |      | content  |  2. content = decrypt(data, PW)
 *    | key/keys |      +----------+
 *    +----------+
 */

/**
 *  Decrypt message, replace encrypted 'data' with 'content' field
 *
 * @return InstantMessage object
 */
- (nullable id<DKDInstantMessage>)decrypt;

/*
 *  Sign the Secure Message to Reliable Message
 *
 *    +----------+      +----------+
 *    | sender   |      | sender   |
 *    | receiver |      | receiver |
 *    | time     |  ->  | time     |
 *    |          |      |          |
 *    | data     |      | data     |
 *    | key/keys |      | key/keys |
 *    +----------+      | signature|  1. signature = sign(data, sender.SK)
 *                      +----------+
 */

/**
 *  Sign message.data, add 'signature' field
 *
 * @return ReliableMessage object
 */
- (nullable id<DKDReliableMessage>)sign;

/**
 *  Split the group message to single person messages
 *
 *  @param members - group members
 *  @return secure/reliable message(s)
 */
- (NSArray *)splitForMembers:(NSArray<id<MKMID>> *)members;

/**
 *  Trim the group message for a member
 *
 * @param member - group member ID
 * @return SecureMessage/ReliableMessage
 */
- (instancetype)trimForMember:(id<MKMID>)member;

@end

@interface DKDSecureMessage : DKDMessage <DKDSecureMessage>

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

// convert Dictionary to SecureMessage
#define DKDSecureMessageFromDictionary(msg)                                    \
            [DKDSecureMessage parse:(msg)]                                     \
                                 /* EOF 'DKDSecureMessageFromDictionary(msg)' */

#pragma mark - Creation

@protocol DKDSecureMessageFactory <NSObject>

- (nullable __kindof id<DKDSecureMessage>)parseSecureMessage:(NSDictionary *)msg;

@end

@interface DKDSecureMessageFactory : NSObject <DKDSecureMessageFactory>

@end

@interface DKDSecureMessage (Creation)

+ (void)setFactory:(id<DKDSecureMessageFactory>)factory;

+ (nullable __kindof id<DKDSecureMessage>)parse:(NSDictionary *)msg;

@end

NS_ASSUME_NONNULL_END
