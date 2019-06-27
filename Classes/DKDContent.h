//
//  DKDContent.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDDictionary.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Message Content
 *
 *      data format: {
 *          'type'    : 0x00,            // message type
 *          'sn'      : 1234567890,      // serial number
 *
 *          'group'   : 'Group ID',      // for group message
 *
 *          // payload
 *          // ...
 *      }
 */
@interface DKDContent : DKDDictionary

// message type: text, image, ...
@property (readonly, nonatomic) UInt8 type;

// random number to identify message content
@property (readonly, nonatomic) NSUInteger serialNumber;

// Group ID for group message
@property (strong, nonatomic, nullable) NSString *group;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithType:(UInt8)type
NS_DESIGNATED_INITIALIZER;

@end

// convert Dictionary to Content
#define DKDContentFromDictionary(content)                                      \
            [DKDContent getInstance:(content)]                                 \
                                   /* EOF 'DKDContentFromDictionary(content)' */

@interface DKDContent (Runtime)

+ (void)registerClass:(nullable Class)contentClass forType:(NSUInteger)type;

+ (nullable instancetype)getInstance:(id)content;

@end

NS_ASSUME_NONNULL_END
