//
//  DKDEnvelope.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDDictionary.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Envelope for message
 *
 *      data format: {
 *          sender   : "moki@xxx",
 *          receiver : "hulk@yyy",
 *          time     : 123
 *      }
 */
@interface DKDEnvelope : DKDDictionary

@property (readonly, strong, nonatomic) NSString *sender;
@property (readonly, strong, nonatomic) NSString *receiver;

@property (readonly, strong, nonatomic) NSDate *time;

- (instancetype)initWithSender:(NSString *)from
                      receiver:(NSString *)to
                          time:(nullable NSDate *)time;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

@interface DKDEnvelope (Content)

/**
 *  Group ID
 *      when a group message was split/trimmed to a single message
 *      the 'receiver' will be changed to a member ID, and
 *      the group ID will be saved as 'group'.
 */
@property (strong, nonatomic, nullable) NSString *group;

@end

// convert Dictionary to Envelope
#define DKDEnvelopeFromDictionary(env)                                         \
            [DKDEnvelope getInstance:(env)]                                    \
                                      /* EOF 'DKDEnvelopeFromDictionary(env)' */

// create Envelope
#define DKDEnvelopeCreate(from, to, when)                                      \
            [[DKDEnvelope alloc] initWithSender:(from) receiver:(to) time:(when)]\
                                   /* EOF 'DKDEnvelopeCreate(from, to, when)' */

@interface DKDEnvelope (Runtime)

+ (nullable instancetype)getInstance:(id)env;

@end

NS_ASSUME_NONNULL_END