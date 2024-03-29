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
//  DKDFactoryManager.m
//  DaoKeDao
//
//  Created by Albert Moky on 2023/2/1.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DKDFactoryManager.h"

@implementation DKDFactoryManager

static DKDFactoryManager *s_manager = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [super allocWithZone:zone];
        s_manager.generalFactory = [[DKDGeneralFactory alloc] init];
    });
    return s_manager;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[self alloc] init];
    });
    return s_manager;
}

@end

#pragma mark -

@interface DKDGeneralFactory () {
    
    NSMutableDictionary<NSNumber *, id<DKDContentFactory>> *_contentFactories;
    
    id<DKDEnvelopeFactory> _envelopeFactory;
    
    id<DKDInstantMessageFactory>  _instantFactory;
    id<DKDSecureMessageFactory>   _secureFactory;
    id<DKDReliableMessageFactory> _reliableFactory;
}

@end

@implementation DKDGeneralFactory

- (instancetype)init {
    if ([super init]) {
        _contentFactories = [[NSMutableDictionary alloc] init];
        _envelopeFactory  = nil;
        _instantFactory   = nil;
        _secureFactory    = nil;
        _reliableFactory  = nil;
    }
    return self;
}

#pragma mark Content

- (void)setContentFactory:(id<DKDContentFactory>)factory forType:(DKDContentType)type {
    [_contentFactories setObject:factory forKey:@(type)];
}

- (nullable id<DKDContentFactory>)contentFactoryForType:(DKDContentType)type {
    return [_contentFactories objectForKey:@(type)];
}

- (DKDContentType)contentType:(NSDictionary<NSString *,id> *)content
                 defaultValue:(DKDContentType)aValue {
    id number = [content objectForKey:@"type"];
    NSAssert(number, @"content type not found: %@", content);
    return MKMConverterGetUnsignedChar(number, aValue);
}

- (nullable id<DKDContent>)parseContent:(id)content {
    if (!content) {
        return nil;
    } else if ([content conformsToProtocol:@protocol(DKDContent)]) {
        return content;
    }
    NSDictionary<NSString *, id> *info = MKMGetMap(content);
    if (!info) {
        NSAssert(false, @"content error: %@", content);
        return nil;
    }
    DKDContentType type = [self contentType:info defaultValue:0];
    NSAssert(type > 0, @"content type error: %@", content);
    id<DKDContentFactory> factory = [self contentFactoryForType:type];
    if (!factory) {
        factory = [self contentFactoryForType:0];  // unknown
        NSAssert(factory, @"default content factory not found");
    }
    return [factory parseContent:info];
}

#pragma mark Envelope

- (void)setEnvelopeFactory:(id<DKDEnvelopeFactory>)factory {
    _envelopeFactory = factory;
}

- (nullable id<DKDEnvelopeFactory>)envelopeFactory {
    return _envelopeFactory;
}

- (id<DKDEnvelope>)createEnvelopeWithSender:(id<MKMID>)from
                                   receiver:(id<MKMID>)to
                                       time:(nullable NSDate *)when {
    return [_envelopeFactory createEnvelopeWithSender:from
                                             receiver:to
                                                 time:when];
}

- (nullable id<DKDEnvelope>)parseEnvelope:(id)env {
    if (!env) {
        return nil;
    } else if ([env conformsToProtocol:@protocol(DKDEnvelope)]) {
        return env;
    }
    NSDictionary<NSString *, id> *info = MKMGetMap(env);
    if (!info) {
        NSAssert(false, @"envelope error: %@", env);
        return nil;
    }
    id<DKDEnvelopeFactory> factory = [self envelopeFactory];
    NSAssert(factory, @"envelope factory not set");
    return [factory parseEnvelope:info];
}

#pragma mark InstantMessage

- (void)setInstantMessageFactory:(id<DKDInstantMessageFactory>)factory {
    _instantFactory = factory;
}

- (nullable id<DKDInstantMessageFactory>)instantMessageFactory {
    return _instantFactory;
}

- (id<DKDInstantMessage>)createInstantMessageWithEnvelope:(id<DKDEnvelope>)head
                                                  content:(id<DKDContent>)body {
    id<DKDInstantMessageFactory> factory = [self instantMessageFactory];
    NSAssert(factory, @"instant message factory not set");
    return [factory createInstantMessageWithEnvelope:head content:body];
}

- (nullable id<DKDInstantMessage>)parseInstantMessage:(id)msg {
    if (!msg) {
        return nil;
    } else if ([msg conformsToProtocol:@protocol(DKDInstantMessage)]) {
        return msg;
    }
    NSDictionary<NSString *, id> *info = MKMGetMap(msg);
    if (!info) {
        NSAssert(false, @"instant message error: %@", msg);
        return nil;
    }
    id<DKDInstantMessageFactory> factory = [self instantMessageFactory];
    NSAssert(factory, @"instant message factory not set");
    return [factory parseInstantMessage:info];
}

- (NSUInteger)generateSerialNumber:(DKDContentType)type time:(NSDate *)now {
    id<DKDInstantMessageFactory> factory = [self instantMessageFactory];
    NSAssert(factory, @"instant message factory not set");
    return [factory generateSerialNumber:type time:now];
}

#pragma mark SecureMessage

- (void)setSecureMessageFactory:(id<DKDSecureMessageFactory>)factory {
    _secureFactory = factory;
}

- (nullable id<DKDSecureMessageFactory>)secureMessageFactory {
    return _secureFactory;
}

- (nullable id<DKDSecureMessage>)parseSecureMessage:(id)msg {
    if (!msg) {
        return nil;
    } else if ([msg conformsToProtocol:@protocol(DKDSecureMessage)]) {
        return msg;
    }
    NSDictionary<NSString *, id> *info = MKMGetMap(msg);
    if (!info) {
        NSAssert(false, @"secure message error: %@", msg);
        return nil;
    }
    id<DKDSecureMessageFactory> factory = [self secureMessageFactory];
    NSAssert(factory, @"secure message factory not set");
    return [factory parseSecureMessage:info];
}

#pragma mark ReliableMessage

- (void)setReliableMessageFactory:(id<DKDReliableMessageFactory>)factory {
    _reliableFactory = factory;
}

- (nullable id<DKDReliableMessageFactory>)reliableMessageFactory {
    return _reliableFactory;
}

- (nullable id<DKDReliableMessage>)parseReliableMessage:(id)msg {
    if (!msg) {
        return nil;
    } else if ([msg conformsToProtocol:@protocol(DKDReliableMessage)]) {
        return msg;
    }
    NSDictionary<NSString *, id> *info = MKMGetMap(msg);
    if (!info) {
        NSAssert(false, @"reliable message error: %@", msg);
        return nil;
    }
    id<DKDReliableMessageFactory> factory = [self reliableMessageFactory];
    NSAssert(factory, @"reliable message factory not set");
    return [factory parseReliableMessage:info];
}

@end
