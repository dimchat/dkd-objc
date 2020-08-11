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
//  DKDInstantMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDEnvelope.h"
#import "DKDContent.h"
#import "DKDMessage+Transform.h"

#import "DKDInstantMessage.h"

@interface DKDInstantMessage ()

@property (strong, nonatomic) DKDContent *content;

@end

@implementation DKDInstantMessage

- (instancetype)initWithEnvelope:(DKDEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    DKDContent *content = nil;
    return [self initWithContent:content envelope:env];
}

- (instancetype)initWithContent:(DKDContent *)content
                         sender:(id)from
                       receiver:(id)to
                           time:(nullable NSDate *)time {
    DKDEnvelope *env = DKDEnvelopeCreate(from, to, time);
    return [self initWithContent:content envelope:env];
}

/* designated initializer */
- (instancetype)initWithContent:(DKDContent *)content
                       envelope:(DKDEnvelope *)env {
    NSAssert(content, @"content cannot be empty");
    NSAssert(env, @"envelope cannot be empty");
    
    if (self = [super initWithEnvelope:env]) {
        // content
        if (content) {
            [_storeDictionary setObject:content forKey:@"content"];
        }
        _content = content;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _content = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDInstantMessage *iMsg = [super copyWithZone:zone];
    if (iMsg) {
        iMsg.content = _content;
    }
    return iMsg;
}

- (__kindof DKDContent *)content {
    if (!_content) {
        NSDictionary *dict = [_storeDictionary objectForKey:@"content"];
        id<DKDInstantMessageDelegate> delegate = self.delegate;
        _content = [delegate parseContent:dict];
        
        if (_content != dict) {
            // replace the content object
            NSAssert([_content isKindOfClass:[DKDContent class]],
                     @"content error: %@", dict);
            [_storeDictionary setObject:_content forKey:@"content"];
        }
    }
    return _content;
}

- (__kindof id<DKDMessageDelegate>) delegate {
    return self.envelope.delegate;
}

- (void)setDelegate:(__kindof id<DKDMessageDelegate>)delegate {
    self.envelope.delegate = delegate;
    self.content.delegate = delegate;
}

@end
