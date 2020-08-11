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
#import "DKDMessage+Transform.h"

#import "DKDEnvelope.h"

@interface DKDEnvelope ()

@property (strong, nonatomic) id sender;
@property (strong, nonatomic) id receiver;
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

- (instancetype)initWithSender:(id)from
                      receiver:(id)to
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
            _delegate = nil;
        }
    } else {
        if (self = [super initWithDictionary:dict]) {
            // lazy
            _sender = nil;
            _receiver = nil;
            _time = nil;
            _delegate = nil;
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
        envelope.delegate = _delegate;
    }
    return envelope;
}

- (id)sender {
    if (!_sender) {
        id sender = [_storeDictionary objectForKey:@"sender"];
        _sender = [self.delegate parseID:sender];
    }
    return _sender;
}

- (id)receiver {
    if (!_receiver) {
        id receiver = [_storeDictionary objectForKey:@"receiver"];
        _receiver = [self.delegate parseID:receiver];
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

- (nullable id)group {
    id group = [_storeDictionary objectForKey:@"group"];
    return [self.delegate parseID:group];
}

- (void)setGroup:(nullable id)group {
    if (group) {
        [_storeDictionary setObject:group forKey:@"group"];
    } else {
        [_storeDictionary removeObjectForKey:@"group"];
    }
}

- (UInt8)type {
    NSNumber *number = [_storeDictionary objectForKey:@"type"];
    return [number unsignedCharValue];
}

- (void)setType:(UInt8)type {
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
