// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
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
//  DKDInstantMessage.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class DKDContent<__covariant ID>;

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
@interface DKDInstantMessage<__covariant ID> : DKDMessage<ID>

@property (readonly, strong, nonatomic) __kindof DKDContent<ID> *content;

- (instancetype)initWithContent:(DKDContent<ID> *)content
                         sender:(ID)from
                       receiver:(ID)to
                           time:(nullable NSDate *)time;

- (instancetype)initWithContent:(DKDContent<ID> *)content
                       envelope:(DKDEnvelope<ID> *)env
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

// convert Dictionary to InstantMessage
#define DKDInstantMessageFromDictionary(msg)                                   \
            [DKDInstantMessage getInstance:(msg)]                              \
                                /* EOF 'DKDInstantMessageFromDictionary(msg)' */

// create InstantMessage
#define DKDInstantMessageCreate(content, from, to, when)                       \
            [[DKDInstantMessage alloc] initWithContent:(content)               \
                                                sender:(from)                  \
                                              receiver:(to)                    \
                                                  time:(when)]                 \
                    /* EOF 'DKDInstantMessageCreate(content, from, to, when)' */

NS_ASSUME_NONNULL_END
