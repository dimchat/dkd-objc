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
//  DKDSharedExtensions.h
//  DaoKeDao
//
//  Created by Albert Moky on 2023/2/1.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DaoKeDao/DKDMessageHelpers.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DKDGeneralMessageHelper <NSObject/*,
                                            DKDContentHelper,
                                            DKDEnvelopeHelper,
                                            DKDInstantMessageHelper,
                                            DKDSecureMessageHelper,
                                            DKDReliableMessageHelper
                                            */>

//
//  Algorithm
//
- (nullable NSString *)getContentType:(NSDictionary<NSString *, id> *)content
                         defaultValue:(nullable NSString *)aValue;

@end

#pragma mark Message FactoryManager

@interface DKDSharedMessageExtensions : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic, nullable) id<DKDContentHelper> contentHelper;
@property (strong, nonatomic, nullable) id<DKDEnvelopeHelper> envelopeHelper;

@property (strong, nonatomic, nullable) id<DKDInstantMessageHelper> instantHelper;
@property (strong, nonatomic, nullable) id<DKDSecureMessageHelper> secureHelper;
@property (strong, nonatomic, nullable) id<DKDReliableMessageHelper> reliableHelper;

@property (strong, nonatomic, nullable) id<DKDGeneralMessageHelper> helper;

@end

NS_ASSUME_NONNULL_END
