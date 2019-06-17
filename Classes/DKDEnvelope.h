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

@property (readonly, strong, nonatomic) const NSString *sender;
@property (readonly, strong, nonatomic) const NSString *receiver;

@property (readonly, strong, nonatomic) NSDate *time;

+ (instancetype)envelopeWithEnvelope:(id)env;

- (instancetype)initWithSender:(const NSString *)from
                      receiver:(const NSString *)to
                          time:(nullable const NSDate *)time
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
