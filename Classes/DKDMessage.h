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
//  DKDMessage.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDEnvelope.h"

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

@protocol DKDContent;
@protocol DKDInstantMessage;
@protocol DKDSecureMessage;
@protocol DKDReliableMessage;

@protocol DKDMessageDelegate <NSObject>

/**
 *  Get group ID which should be exposed to public network
 *
 * @param content - message content
 * @return exposed group ID
 */
- (id<MKMID>)overtGroupForContent:(id<DKDContent>)content;

@end

@protocol DKDInstantMessageDelegate <DKDMessageDelegate>

#pragma mark Encrypt Content

/**
 *  1. Serialize 'message.content' to data (JsON / ProtoBuf / ...)
 *
 * @param iMsg - instant message object
 * @param content - message.content
 * @param password - symmetric key
 * @return serialized content data
 */
- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
            serializeContent:(id<DKDContent>)content
                     withKey:(id<MKMSymmetricKey>)password;

/**
 *  2. Encrypt content data to 'message.data' with symmetric key
 *
 * @param iMsg - instant message object
 * @param data - serialized data of message.content
 * @param password - symmetric key
 * @return encrypted message content data
 */
- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
              encryptContent:(NSData *)data
                     withKey:(id<MKMSymmetricKey>)password;

/**
 *  3. Encode 'message.data' to String (Base64)
 *
 * @param iMsg - instant message object
 * @param data - encrypted content data
 * @return String object
 */
- (nullable NSObject *)message:(id<DKDInstantMessage>)iMsg
                    encodeData:(NSData *)data;

#pragma mark Encrypt Key

/**
 *  4. Serialize message key to data (JsON / ProtoBuf / ...)
 *
 * @param iMsg - instant message object
 * @param password - symmetric key
 * @return serialized key data
 */
- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                serializeKey:(id<MKMSymmetricKey>)password;

/**
 *  5. Encrypt key data to 'message.key' with receiver's public key
 *
 * @param iMsg - instant message object
 * @param data - serialized data of symmetric key
 * @param receiver - receiver ID string
 * @return encrypted symmetric key data
 */
- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                  encryptKey:(NSData *)data
                 forReceiver:(id<MKMID>)receiver;

/**
 *  6. Encode 'message.key' to String (Base64)
 *
 * @param iMsg - instant message object
 * @param data - encrypted symmetric key data
 * @return String object
 */
- (nullable NSObject *)message:(id<DKDInstantMessage>)iMsg
                     encodeKey:(NSData *)data;

@end

@protocol DKDSecureMessageDelegate <DKDMessageDelegate>

#pragma mark Decrypt Key

/**
 *  1. Decode 'message.key' to encrypted symmetric key data
 *
 * @param sMsg - secure message object
 * @param dataString - base64 string object
 * @return encrypted symmetric key data
 */
- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                   decodeKey:(NSObject *)dataString;

/**
 *  2. Decrypt 'message.key' with receiver's private key
 *
 * @param sMsg - secure message object
 * @param key - encrypted symmetric key data
 * @param sender - sender/member ID string
 * @param receiver - receiver/group ID string
 * @return serialized data of symmetric key
 */
- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                  decryptKey:(NSData *)key
                        from:(id<MKMID>)sender
                          to:(id<MKMID>)receiver;

/**
 *  3. Deserialize message key from data (JsON / ProtoBuf / ...)
 *
 * @param sMsg - secure message object
 * @param data - serialized key data
 * @param sender - sender/member ID string
 * @param receiver - receiver/group ID string
 * @return symmetric key
 */
- (nullable id<MKMSymmetricKey>)message:(id<DKDSecureMessage>)sMsg
                         deserializeKey:(nullable NSData *)data
                                   from:(id<MKMID>)sender
                                     to:(id<MKMID>)receiver;

#pragma mark Decrypt Content

/**
 *  4. Decode 'message.data' to encrypted content data
 *
 * @param sMsg - secure message object
 * @param dataString - base64 string object
 * @return encrypted content data
 */
- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                  decodeData:(NSObject *)dataString;

/**
 *  5. Decrypt 'message.data' with symmetric key
 *
 * @param sMsg - secure message object
 * @param data - encrypt content data
 * @param password - symmetric key
 * @return serialized data of message content
 */
- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
              decryptContent:(NSData *)data
                     withKey:(id<MKMSymmetricKey>)password;

/**
 *  6. Deserialize message content from data (JsON / ProtoBuf / ...)
 *
 * @param sMsg - secure message object
 * @param data - serialized content data
 * @param password - symmetric key
 * @return message content
 */
- (nullable __kindof id<DKDContent>)message:(id<DKDSecureMessage>)sMsg
                         deserializeContent:(NSData *)data
                                    withKey:(id<MKMSymmetricKey>)password;

#pragma mark Signature

/**
 *  1. Sign 'message.data' with sender's private key
 *
 * @param sMsg - secure message object
 * @param data - encrypted message data
 * @param sender - sender ID string
 * @return signature of encrypted message data
 */
- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                    signData:(NSData *)data
                   forSender:(id<MKMID>)sender;

/**
 *  2. Encode 'message.signature' to String (Base64)
 *
 * @param sMsg - secure message object
 * @param signature - signature of message.data
 * @return String object
 */
- (nullable NSObject *)message:(id<DKDSecureMessage>)sMsg
               encodeSignature:(NSData *)signature;

@end

@protocol DKDReliableMessageDelegate <DKDSecureMessageDelegate>

/**
 *  1. Decode 'message.signature' from String (Base64)
 *
 * @param rMsg - reliable message object
 * @param signatureString - base64 string object
 * @return signature data
 */
- (nullable NSData *)message:(id<DKDReliableMessage>)rMsg
             decodeSignature:(NSObject *)signatureString;

/**
 *  2. Verify the message data and signature with sender's public key
 *
 * @param rMsg - reliable message object
 * @param data - message content(encrypted) data
 * @param signature - signature for message content(encrypted) data
 * @param sender - sender ID string
 * @return YES on signature match
 */
- (BOOL)message:(id<DKDReliableMessage>)rMsg
     verifyData:(NSData *)data
  withSignature:(NSData *)signature
      forSender:(id<MKMID>)sender;

@end

/*
 *  Common Message
 *
 *      data format: {
 *          //-- envelope
 *          sender   : "moki@xxx",
 *          receiver : "hulk@yyy",
 *          time     : 123,
 *          //-- others
 *          ...
 *      }
 */
@protocol DKDMessage <MKMDictionary>

// delegate to transform message
@property (weak, nonatomic) __kindof id<DKDMessageDelegate> delegate;

@property (readonly, strong, nonatomic) id<DKDEnvelope> envelope;

@property (readonly, strong, nonatomic) id<MKMID> sender;
@property (readonly, strong, nonatomic) id<MKMID> receiver;
@property (readonly, strong, nonatomic) NSDate *time;

@property (readonly, strong, nonatomic) id<MKMID> group;
@property (readonly, nonatomic) DKDContentType type;

@end

@interface DKDMessage : MKMDictionary <DKDMessage>

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithEnvelope:(id<DKDEnvelope>)env
NS_DESIGNATED_INITIALIZER;

+ (id<DKDEnvelope>)envelope:(NSDictionary *)msg;

@end

NS_ASSUME_NONNULL_END
