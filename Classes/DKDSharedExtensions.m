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
//  DKDSharedExtensions.m
//  DaoKeDao
//
//  Created by Albert Moky on 2023/2/1.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DKDSharedExtensions.h"

@implementation DKDSharedMessageExtensions

static DKDSharedMessageExtensions *s_msg_extension = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_msg_extension = [[self alloc] init];
    });
    return s_msg_extension;
}

#pragma mark Content Helper

- (id<DKDContentHelper>)contentHelper {
    DKDMessageExtensions *ext = [DKDMessageExtensions sharedInstance];
    return [ext contentHelper];
}

- (void)setContentHelper:(id<DKDContentHelper>)contentHelper {
    DKDMessageExtensions *ext = [DKDMessageExtensions sharedInstance];
    [ext setContentHelper:contentHelper];
}

#pragma mark Envelope Helper

- (id<DKDEnvelopeHelper>)envelopeHelper {
    DKDMessageExtensions *ext = [DKDMessageExtensions sharedInstance];
    return [ext envelopeHelper];
}

- (void)setEnvelopeHelper:(id<DKDEnvelopeHelper>)envelopeHelper {
    DKDMessageExtensions *ext = [DKDMessageExtensions sharedInstance];
    [ext setEnvelopeHelper:envelopeHelper];
}

#pragma mark Instant Message Helper

- (id<DKDInstantMessageHelper>)instantHelper {
    DKDMessageExtensions *ext = [DKDMessageExtensions sharedInstance];
    return [ext instantHelper];
}

- (void)setInstantHelper:(id<DKDInstantMessageHelper>)instantHelper {
    DKDMessageExtensions *ext = [DKDMessageExtensions sharedInstance];
    [ext setInstantHelper:instantHelper];
}

#pragma mark Secure Message Helper

- (id<DKDSecureMessageHelper>)secureHelper {
    DKDMessageExtensions *ext = [DKDMessageExtensions sharedInstance];
    return [ext secureHelper];
}

- (void)setSecureHelper:(id<DKDSecureMessageHelper>)secureHelper {
    DKDMessageExtensions *ext = [DKDMessageExtensions sharedInstance];
    [ext setSecureHelper:secureHelper];
}

#pragma mark Reliable Message Helper

- (id<DKDReliableMessageHelper>)reliableHelper {
    DKDMessageExtensions *ext = [DKDMessageExtensions sharedInstance];
    return [ext reliableHelper];
}

- (void)setReliableHelper:(id<DKDReliableMessageHelper>)reliableHelper {
    DKDMessageExtensions *ext = [DKDMessageExtensions sharedInstance];
    [ext setReliableHelper:reliableHelper];
}

@end
