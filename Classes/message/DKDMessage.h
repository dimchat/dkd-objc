//
//  DKDMessage.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@class DKDEnvelope;

@protocol DKDMessageDelegate;

/**
 *  Instant Message
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
@interface DKDMessage : DKDDictionary

@property (readonly, strong, nonatomic) DKDEnvelope *envelope;

// delegate to transform message
@property (weak, nonatomic, nullable) id<DKDMessageDelegate> delegate;

+ (instancetype)messageWithMessage:(id)msg;

- (instancetype)initWithSender:(const NSString *)from
                      receiver:(const NSString *)to
                          time:(nullable const NSDate *)time;

- (instancetype)initWithEnvelope:(const DKDEnvelope *)env
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - Delegate

@class DKDInstantMessage;
@class DKDSecureMessage;
@class DKDReliableMessage;

/**
 
 Message Transforming
 ~~~~~~~~~~~~~~~~~~~~
 
 Instant Message <-> Secure Message <-> Reliable Message
 +-------------+     +------------+     +--------------+
 |  sender     |     |  sender    |     |  sender      |
 |  receiver   |     |  receiver  |     |  receiver    |
 |  time       |     |  time      |     |  time        |
 |             |     |            |     |              |
 |  content    |     |  data      |     |  data        |
 +-------------+     |  key/keys  |     |  key/keys    |
                     +------------+     |  signature   |
                                        +--------------+
 Algorithm:
 data      = password.encrypt(content)
 key       = public_key.encrypt(password)
 signature = private_key.sign(data)
 
 */

@protocol DKDMessageDelegate <NSObject>

// Instant Message -> Secure Message

//    1. use the symmetric key(PW) to encrypt message.content to message.data;
//    2. if public key(PK) is not found, it means PW is a reused key,
//           do nothing;
//       else,
//           use PK to encrypt PW and save the result in message.key
- (DKDSecureMessage *)message:(const DKDInstantMessage *)iMsg
      encryptWithSymmetricKey:(const NSDictionary *)PW
                    publicKey:(nullable const NSDictionary *)PK;

- (DKDSecureMessage *)message:(const DKDInstantMessage *)iMsg
      encryptWithSymmetricKey:(const NSDictionary *)PW
                   publicKeys:(nullable const NSDictionary<const NSString *, const NSDictionary *> *)keys;

// Secure Message -> Instant Message

//    1. if message.key exists, check it with the given symmetric key(PW)
//           if message.key equals to PW(same tag), it means it's a reused key,
//           else, decrypt message.key to PW with the private key(SK)
//    2. use PW to decrypt message.data to message.content
- (DKDInstantMessage *)message:(const DKDSecureMessage *)sMsg
       decryptWitySymmetricKey:(nullable const NSDictionary *)PW
                    privateKey:(nullable const NSDictionary *)SK;

// Secure Message -> Reliable Message

- (DKDReliableMessage *)message:(const DKDSecureMessage *)sMsg
             signWithPrivateKey:(const NSDictionary *)SK;

// Reliable Message -> Secure Message

- (DKDSecureMessage *)message:(const DKDReliableMessage *)rMsg
          verifyWithPublicKey:(const NSDictionary *)PK;

@end

NS_ASSUME_NONNULL_END
