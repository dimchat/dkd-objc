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

/**
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
 *  Encrypt 'message.key' with receiver's public key
 *
 * @param iMsg - instant message object
 * @param password - symmetric key to be encrypted
 * @param receiver - receiver ID string
 * @return encrypted key data
 */
- (nullable NSData *)message:(DKDInstantMessage *)iMsg
                  encryptKey:(NSDictionary *)password
                 forReceiver:(NSString *)receiver;

/**
 *  Encode 'message.data'/'message.key' to String(Base64)
 *
 * @param iMsg - instant message object
 * @param data - encrypted content/key data
 * @return String object
 */
- (nullable NSObject *)message:(DKDInstantMessage *)iMsg
                    encodeData:(NSData *)data;

@end

@protocol DKDSecureMessageDelegate <DKDMessageDelegate>

/**
 *  Decrypt 'message.key' with receiver's private key
 *
 * @param sMsg - secure message object
 * @param key - encrypted key data
 * @param sender - sender/member ID string
 * @param receiver - receiver/group ID string
 * @return symmetric key
 */
- (nullable NSDictionary *)message:(DKDSecureMessage *)sMsg
                        decryptKey:(nullable NSData *)key
                              from:(NSString *)sender
                                to:(NSString *)receiver;

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
 *  Decode 'message.data' from String(Base64)
 *
 * @param sMsg - secure message object
 * @param dataString - String object
 * @return encrypted content data
 */
- (nullable NSData *)message:(DKDSecureMessage *)sMsg
                  decodeData:(NSObject *)dataString;

/**
 *  Sign 'message.data' with sender's private key
 *
 * @param sMsg - secure message object
 * @param data - encrypted message data
 * @param sender - sender ID string
 * @return signature
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
 *  Verify the message data and signature with sender's public key
 *
 * @param rMsg - reliable message object
 * @param data - message data
 * @param signature - signature for message data
 * @param sender - sender ID string
 * @return YES on signature match
 */
- (BOOL)message:(DKDReliableMessage *)rMsg
     verifyData:(NSData *)data
  withSignature:(NSData *)signature
      forSender:(NSString *)sender;

/**
 *  Decode 'message.signature' from String(Base64)
 *
 * @param rMsg - reliable message object
 * @param signatureString - String object
 * @return signature data
 */
- (nullable NSData *)message:(DKDReliableMessage *)rMsg
             decodeSignature:(NSObject *)signatureString;

@end

#pragma mark - Transform

/**
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

/**
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

/**
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

/**
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
