// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DKDFactoryManager.h
//  DaoKeDao
//
//  Created by Albert Moky on 2023/2/1.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DaoKeDao/DKDEnvelope.h>
#import <DaoKeDao/DKDInstantMessage.h>
#import <DaoKeDao/DKDReliableMessage.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  General Factory for Messages
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 */
@protocol DKDGeneralFactory <NSObject>

#pragma mark Content

- (void)setContentFactory:(id<DKDContentFactory>)factory forType:(DKDContentType)type;
- (nullable id<DKDContentFactory>)contentFactoryForType:(DKDContentType)type;

- (DKDContentType)contentType:(NSDictionary<NSString *, id> *)content
                 defaultValue:(DKDContentType)aValue;

- (nullable __kindof id<DKDContent>)parseContent:(nullable id)content;

#pragma mark Envelope

- (void)setEnvelopeFactory:(id<DKDEnvelopeFactory>)factory;
- (nullable id<DKDEnvelopeFactory>)envelopeFactory;

- (id<DKDEnvelope>)createEnvelopeWithSender:(id<MKMID>)from
                                   receiver:(id<MKMID>)to
                                       time:(nullable NSDate *)when;

- (nullable id<DKDEnvelope>)parseEnvelope:(nullable id)env;

#pragma mark InstantMessage

- (void)setInstantMessageFactory:(id<DKDInstantMessageFactory>)factory;
- (nullable id<DKDInstantMessageFactory>)instantMessageFactory;

- (id<DKDInstantMessage>)createInstantMessageWithEnvelope:(id<DKDEnvelope>)head
                                                  content:(__kindof id<DKDContent>)body;

- (nullable id<DKDInstantMessage>)parseInstantMessage:(nullable id)msg;

- (NSUInteger)generateSerialNumber:(DKDContentType)type time:(NSDate *)now;

#pragma mark SecureMessage

- (void)setSecureMessageFactory:(id<DKDSecureMessageFactory>)factory;
- (nullable id<DKDSecureMessageFactory>)secureMessageFactory;

- (nullable id<DKDSecureMessage>)parseSecureMessage:(nullable id)msg;

#pragma mark ReliableMessage

- (void)setReliableMessageFactory:(id<DKDReliableMessageFactory>)factory;
- (nullable id<DKDReliableMessageFactory>)reliableMessageFactory;

- (nullable id<DKDReliableMessage>)parseReliableMessage:(nullable id)msg;

@end

#pragma mark -

@interface DKDGeneralFactory : NSObject <DKDGeneralFactory>

@end

@interface DKDFactoryManager : NSObject

@property(strong, nonatomic) id<DKDGeneralFactory> generalFactory;

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
