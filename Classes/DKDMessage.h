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

@protocol DKDMessageDelegate <NSObject>
@end

/**
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
@interface DKDMessage : DKDDictionary {
    
    __weak __kindof id<DKDMessageDelegate> _delegate;
}

@property (readonly, strong, nonatomic) DKDEnvelope *envelope;

// delegate to transform message
@property (weak, nonatomic, nullable) __kindof id<DKDMessageDelegate> delegate;

- (instancetype)initWithSender:(const NSString *)from
                      receiver:(const NSString *)to
                          time:(nullable const NSDate *)time;

- (instancetype)initWithEnvelope:(const DKDEnvelope *)env
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

// convert Dictionary to Message
#define DKDMessageFromDictionary(message)  [DKDMessage getInstance:(message)]

@interface DKDMessage (Runtime)

+ (nullable instancetype)getInstance:(id)msg;

@end

NS_ASSUME_NONNULL_END
