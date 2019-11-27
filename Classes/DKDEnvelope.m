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
//  DKDEnvelope.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DKDEnvelope.h"

@interface DKDEnvelope ()

@property (strong, nonatomic) NSString *sender;
@property (strong, nonatomic) NSString *receiver;
@property (strong, nonatomic) NSDate *time;

// get inner dictionary (for Message)
@property (readonly, strong, nonatomic) NSMutableDictionary *dictionary;

@end

@implementation DKDEnvelope

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

- (instancetype)initWithSender:(NSString *)from
                      receiver:(NSString *)to
                          time:(nullable NSDate *)time {
    if (!time) {
        // now()
        time = [[NSDate alloc] init];
    }
    NSDictionary *dict = @{@"sender"  :from,
                           @"receiver":to,
                           @"time"    :NSNumberFromDate(time),
                           };
    if (self = [self initWithDictionary:dict]) {
        _sender = from;
        _receiver = to;
        _time = time;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSMutableDictionary class]]) {
        // share the same inner dictionary with message object
        if (self = [super init]) {
            _storeDictionary = (NSMutableDictionary *)dict;
            // lazy
            _sender = nil;
            _receiver = nil;
            _time = nil;
        }
    } else {
        if (self = [super initWithDictionary:dict]) {
            // lazy
            _sender = nil;
            _receiver = nil;
            _time = nil;
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDEnvelope *envelope = [super copyWithZone:zone];
    if (envelope) {
        envelope.sender = _sender;
        envelope.receiver = _receiver;
        envelope.time = _time;
    }
    return envelope;
}

- (NSString *)sender {
    if (!_sender) {
        _sender = [_storeDictionary objectForKey:@"sender"];
    }
    return _sender;
}

- (NSString *)receiver {
    if (!_receiver) {
        _receiver = [_storeDictionary objectForKey:@"receiver"];
    }
    return _receiver;
}

- (NSDate *)time {
    if (!_time) {
        NSNumber *timestamp = [_storeDictionary objectForKey:@"time"];
        _time = NSDateFromNumber(timestamp);
    }
    return _time;
}

- (NSMutableDictionary *)dictionary {
    return _storeDictionary;
}

@end

@implementation DKDEnvelope (Content)

- (nullable NSString *)group {
    return [_storeDictionary objectForKey:@"group"];
}

- (void)setGroup:(nullable NSString *)group {
    if ([group length] > 0) {
        [_storeDictionary setObject:group forKey:@"group"];
    } else {
        [_storeDictionary removeObjectForKey:@"group"];
    }
}

- (DKDContentType)type {
    NSNumber *number = [_storeDictionary objectForKey:@"type"];
    return [number unsignedCharValue];
}

- (void)setType:(DKDContentType)type {
    [_storeDictionary setObject:@(type) forKey:@"type"];
}

@end

@implementation DKDEnvelope (Runtime)

+ (nullable instancetype)getInstance:(id)env {
    if (!env) {
        return nil;
    }
    if ([env isKindOfClass:[DKDEnvelope class]]) {
        // return Envelope object directly
        return env;
    }
    NSAssert([env isKindOfClass:[NSDictionary class]],
             @"envelope should be a dictionary: %@", env);
    // create instance
    return [[self alloc] initWithDictionary:env];
}

@end
