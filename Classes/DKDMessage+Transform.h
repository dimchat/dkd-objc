// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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
//  DKDMessage+Transform.h
//  DaoKeDao
//
//  Created by Albert Moky on 2019/3/15.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DKDInstantMessage.h"
#import "DKDSecureMessage.h"
#import "DKDReliableMessage.h"

NS_ASSUME_NONNULL_BEGIN

/*
 *  Message Transforming
 *  ~~~~~~~~~~~~~~~~~~~~
 *
 *  Instant Message <-> Secure Message <-> Reliable Message
 *  +-------------+     +------------+     +--------------+
 *  |  sender     |     |  sender    |     |  sender      |
 *  |  receiver   |     |  receiver  |     |  receiver    |
 *  |  time       |     |  time      |     |  time        |
 *  |             |     |            |     |              |
 *  |  content    |     |  data      |     |  data        |
 *  +-------------+     |  key/keys  |     |  key/keys    |
 *                      +------------+     |  signature   |
 *                                         +--------------+
 *
 *  Algorithm:
 *  data      = password.encrypt(content)
 *  key       = receiver.public_key.encrypt(password)
 *  signature = sender.private_key.sign(data)
 */

@class DKDContent;

@protocol DKDInstantMessageDelegate <DKDMessageDelegate>

/**
 *  Encrypt 'message.content' to 'message.data' with symmetric key
 *
 * @param iMsg - instant message object
 * @param content - message.content
 * @param password - symmetric key
 * @return encrypted message content data
 */
- (nullable NSData *)message:(DKDInstantMessage *)iMsg
              encryptContent:(DKDContent *)content
                     withKey:(NSDictionary *)password;

/**
 *  Encode 'message.data' to String(Base64)
 *
 * @param iMsg - instant message object
 * @param data - encrypted content data
 * @return String object
 */
- (nullable NSObject *)message:(DKDInstantMessage *)iMsg
                    encodeData:(NSData *)data;

/**
 *  Encrypt 'message.key' with receiver's public key
 *
 * @param iMsg - instant message object
 * @param password - symmetric key to be encrypted
 * @param receiver - receiver ID string
 * @return encrypted symmetric key data
 */
- (nullable NSData *)message:(DKDInstantMessage *)iMsg
                  encryptKey:(NSDictionary *)password
                 forReceiver:(NSString *)receiver;

/**
 *  Encode 'message.key' to String(Base64)
 *
 * @param iMsg - instant message object
 * @param data - encrypted symmetric key data
 * @return String object
 */
- (nullable NSObject *)message:(DKDInstantMessage *)iMsg
                     encodeKey:(NSData *)data;

@end

@protocol DKDSecureMessageDelegate <DKDMessageDelegate>

/**
 *  Decode 'message.key' to encrypted symmetric key data
 *
 * @param sMsg - secure message object
 * @param dataString - base64 string object
 * @return encrypted symmetric key data
 */
- (nullable NSData *)message:(DKDSecureMessage *)sMsg
                   decodeKey:(NSObject *)dataString;

/**
 *  Decrypt 'message.key' with receiver's private key
 *
 * @param sMsg - secure message object
 * @param key - encrypted symmetric key data
 * @param sender - sender/member ID string
 * @param receiver - receiver/group ID string
 * @return symmetric key
 */
- (nullable NSDictionary *)message:(DKDSecureMessage *)sMsg
                        decryptKey:(nullable NSData *)key
                              from:(NSString *)sender
                                to:(NSString *)receiver;

/**
 *  Decode 'message.data' to encrypted content data
 *
 * @param sMsg - secure message object
 * @param dataString - base64 string object
 * @return encrypted content data
 */
- (nullable NSData *)message:(DKDSecureMessage *)sMsg
                  decodeData:(NSObject *)dataString;

/**
 *  Decrypt 'message.data' with symmetric key
 *
 * @param sMsg - secure message object
 * @param data - encrypt content data
 * @param password - symmetric key
 * @return message content
 */
- (nullable DKDContent *)message:(DKDSecureMessage *)sMsg
                  decryptContent:(NSData *)data
                         withKey:(NSDictionary *)password;

/**
 *  Sign 'message.data' with sender's private key
 *
 * @param sMsg - secure message object
 * @param data - encrypted message data
 * @param sender - sender ID string
 * @return signature of encrypted message data
 */
- (nullable NSData *)message:(DKDSecureMessage *)sMsg
                    signData:(NSData *)data
                   forSender:(NSString *)sender;

/**
 *  Encode 'message.signature' to String(Base64)
 *
 * @param sMsg - secure message object
 * @param signature - signature of message.data
 * @return String object
 */
- (nullable NSObject *)message:(DKDSecureMessage *)sMsg
               encodeSignature:(NSData *)signature;

@end

@protocol DKDReliableMessageDelegate <DKDSecureMessageDelegate>

/**
 *  Decode 'message.signature' from String(Base64)
 *
 * @param rMsg - reliable message object
 * @param signatureString - base64 string object
 * @return signature data
 */
- (nullable NSData *)message:(DKDReliableMessage *)rMsg
             decodeSignature:(NSObject *)signatureString;

/**
 *  Verify the message data and signature with sender's public key
 *
 * @param rMsg - reliable message object
 * @param data - message content(encrypted) data
 * @param signature - signature for message content(encrypted) data
 * @param sender - sender ID string
 * @return YES on signature match
 */
- (BOOL)message:(DKDReliableMessage *)rMsg
     verifyData:(NSData *)data
  withSignature:(NSData *)signature
      forSender:(NSString *)sender;

@end

#pragma mark - Transform

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
@interface DKDInstantMessage (ToSecureMessage)

// personal message
- (nullable DKDSecureMessage *)encryptWithKey:(NSDictionary *)password;

// group message
- (nullable DKDSecureMessage *)encryptWithKey:(NSDictionary *)password
                                   forMembers:(NSArray<NSString *> *)members;

@end

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
@interface DKDSecureMessage (ToInstantMessage)

- (nullable DKDInstantMessage *)decrypt;

@end

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
@interface DKDSecureMessage (ToReliableMessage)

- (nullable DKDReliableMessage *)sign;

@end

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
@interface DKDReliableMessage (ToSecureMessage)

- (nullable DKDSecureMessage *)verify;

@end

NS_ASSUME_NONNULL_END
