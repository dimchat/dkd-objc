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
//  DKDEnvelope.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDDictionary.h"
#import "DKDContent.h"

NS_ASSUME_NONNULL_BEGIN

/*
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

/**
 *  Message Type
 *      because the message content will be encrypted, so
 *      the intermediate nodes(station) cannot recognize what kind of it.
 *      we pick out the content type and set it in envelope
 *      to let the station do its job.
 */
@property (nonatomic) DKDContentType type;

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
