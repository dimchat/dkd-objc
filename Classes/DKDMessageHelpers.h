// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
//
//                               Written in 2025 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2025 Albert Moky
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
//  DKDMessageHelpers.h
//  DaoKeDao
//
//  Created by Albert Moky on 2025/10/2.
//  Copyright © 2025 DIM Group. All rights reserved.
//

#import <DaoKeDao/DKDContent.h>
#import <DaoKeDao/DKDEnvelope.h>
#import <DaoKeDao/DKDInstantMessage.h>
#import <DaoKeDao/DKDSecureMessage.h>
#import <DaoKeDao/DKDReliableMessage.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DKDContentHelper <NSObject>

- (void)setContentFactory:(id<DKDContentFactory>)factory
                  forType:(NSString *)type;
- (nullable id<DKDContentFactory>)getContentFactory:(NSString *)type;

- (__kindof id<DKDContent>)parseContent:(nullable id)content;

@end

@protocol DKDEnvelopeHelper <NSObject>

- (void)setEnvelopeFactory:(id<DKDEnvelopeFactory>)factory;
- (nullable id<DKDEnvelopeFactory>)getEnvelopeFactory;

- (id<DKDEnvelope>)createEnvelopeWithSender:(id<MKMID>)from
                                   receiver:(id<MKMID>)to
                                       time:(nullable NSDate *)when;

- (nullable id<DKDEnvelope>)parseEnvelope:(nullable id)env;

@end

@protocol DKDInstantMessageHelper <NSObject>

- (void)setInstantMessageFactory:(id<DKDInstantMessageFactory>)factory;
- (nullable id<DKDInstantMessageFactory>)getInstantMessageFactory;

- (id<DKDInstantMessage>)createInstantMessageWithEnvelope:(id<DKDEnvelope>)head
                                                  content:(id<DKDContent>)body;

- (nullable id<DKDInstantMessage>)parseInstantMessage:(nullable id)msg;

- (DKDSerialNumber)generateSerialNumberForType:(nullable NSString *)type
                                          time:(nullable NSDate *)now;

@end

@protocol DKDSecureMessageHelper <NSObject>

- (void)setSecureMessageFactory:(id<DKDSecureMessageFactory>)factory;
- (nullable id<DKDSecureMessageFactory>)getSecureMessageFactory;

- (nullable id<DKDSecureMessage>)parseSecureMessage:(nullable id)msg;

@end

@protocol DKDReliableMessageHelper <NSObject>

- (void)setReliableMessageFactory:(id<DKDReliableMessageFactory>)factory;
- (nullable id<DKDReliableMessageFactory>)getReliableMessageFactory;

- (nullable id<DKDReliableMessage>)parseReliableMessage:(nullable id)msg;

@end

#pragma mark - Message FactoryManager

@interface DKDMessageExtensions : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic, nullable) id<DKDContentHelper> contentHelper;
@property (strong, nonatomic, nullable) id<DKDEnvelopeHelper> envelopeHelper;

@property (strong, nonatomic, nullable) id<DKDInstantMessageHelper> instantHelper;
@property (strong, nonatomic, nullable) id<DKDSecureMessageHelper> secureHelper;
@property (strong, nonatomic, nullable) id<DKDReliableMessageHelper> reliableHelper;

@end

NS_ASSUME_NONNULL_END
