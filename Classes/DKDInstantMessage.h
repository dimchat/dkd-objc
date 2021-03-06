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
//  DKDInstantMessage.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DaoKeDao/DKDMessage.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DKDContent;
@protocol DKDSecureMessage;

/*
 *  Instant Message
 *
 *      data format: {
 *          //-- envelope
 *          sender   : "moki@xxx",
 *          receiver : "hulk@yyy",
 *          time     : 123,
 *          //-- content
 *          content  : {...}
 *      }
 */
@protocol DKDInstantMessage <DKDMessage>

@property (readonly, strong, nonatomic) __kindof id<DKDContent> content;

/*
 *  Encrypt the Instant Message to Secure Message
 *
 *    +----------+      +----------+
 *    | sender   |      | sender   |
 *    | receiver |      | receiver |
 *    | time     |  ->  | time     |
 *    |          |      |          |
 *    | content  |      | data     |  1. data = encrypt(content, PW)
 *    +----------+      | key/keys |  2. key  = encrypt(PW, receiver.PK)
 *                      +----------+
 */

/**
 *  Encrypt message, replace 'content' field with encrypted 'data'
 *
 * @param password - symmetric key
 * @return SecureMessage object
 */
- (nullable id<DKDSecureMessage>)encryptWithKey:(id<MKMSymmetricKey>)password;

/**
 *  Encrypt group message, replace 'content' field with encrypted 'data'
 *
 * @param password - symmetric key
 * @param members - group members
 * @return SecureMessage object
 */
- (nullable id<DKDSecureMessage>)encryptWithKey:(id<MKMSymmetricKey>)password
                                     forMembers:(NSArray<id<MKMID>> *)members;

@end

@interface DKDInstantMessage : DKDMessage <DKDInstantMessage>

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithEnvelope:(id<DKDEnvelope>)env
                         content:(id<DKDContent>)content
NS_DESIGNATED_INITIALIZER;

+ (__kindof id<DKDContent>)content:(NSDictionary *)msg;

@end

// convert Dictionary to InstantMessage
#define DKDInstantMessageFromDictionary(msg)                                   \
            [DKDInstantMessage parse:(msg)]                                    \
                                /* EOF 'DKDInstantMessageFromDictionary(msg)' */

// create InstantMessage
#define DKDInstantMessageCreate(head, body)                                    \
            [DKDInstantMessage createWithEnvelope:(head) content:(body)]       \
                    /* EOF 'DKDInstantMessageCreate(content, from, to, when)' */

#pragma mark - Creation

@protocol DKDInstantMessageFactory <NSObject>

/**
 *  Create instant message with envelope & content
 *
 * @param head - message envelope
 * @param body - message content
 * @return InstantMessage
 */
- (id<DKDInstantMessage>)createInstantMessageWithEnvelope:(id<DKDEnvelope>)head
                                                  content:(id<DKDContent>)body;

- (nullable id<DKDInstantMessage>)parseInstantMessage:(NSDictionary *)msg;

@end

@interface DKDInstantMessageFactory : NSObject <DKDInstantMessageFactory>

@end

@interface DKDInstantMessage (Creation)

+ (void)setFactory:(id<DKDInstantMessageFactory>)factory;

+ (id<DKDInstantMessage>)createWithEnvelope:(id<DKDEnvelope>)head
                                    content:(id<DKDContent>)body;

+ (nullable id<DKDInstantMessage>)parse:(NSDictionary *)msg;

@end

NS_ASSUME_NONNULL_END
