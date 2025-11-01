// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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

#import "DKDSharedExtensions.h"

#import "DKDInstantMessage.h"

id<DKDInstantMessageFactory> DKDInstantMessageGetFactory(void) {
    DKDMessageExtensions * ext = [DKDMessageExtensions sharedInstance];
    return [ext.instantHelper getInstantMessageFactory];
}

void DKDInstantMessageSetFactory(id<DKDInstantMessageFactory> factory) {
    DKDMessageExtensions * ext = [DKDMessageExtensions sharedInstance];
    [ext.instantHelper setInstantMessageFactory:factory];
}

DKDSerialNumber DKDInstantMessageGenerateSerialNumber(NSString *type, NSDate *now) {
    DKDMessageExtensions * ext = [DKDMessageExtensions sharedInstance];
    return [ext.instantHelper generateSerialNumberForType:type time:now];
}

id<DKDInstantMessage> DKDInstantMessageCreate(id<DKDEnvelope> head, id<DKDContent> body) {
    DKDMessageExtensions * ext = [DKDMessageExtensions sharedInstance];
    return [ext.instantHelper createInstantMessageWithEnvelope:head content:body];
}

id<DKDInstantMessage> DKDInstantMessageParse(id msg) {
    DKDMessageExtensions * ext = [DKDMessageExtensions sharedInstance];
    return [ext.instantHelper parseInstantMessage:msg];
}

#pragma mark Conveniences

NSMutableArray<id<DKDInstantMessage>> *DKDInstantMessageConvert(NSArray<id> *array) {
    NSMutableArray<id<DKDInstantMessage>> *messages;
    messages = [[NSMutableArray alloc] initWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id<DKDInstantMessage> msg = DKDInstantMessageParse(obj);
        if (msg) {
            [messages addObject:msg];
        }
    }];
    return messages;
}

NSMutableArray<NSDictionary *> *DKDInstantMessageRevert(NSArray<id<DKDInstantMessage>> *messages) {
    NSMutableArray<NSDictionary *> *array;
    array = [[NSMutableArray alloc] initWithCapacity:messages.count];
    [messages enumerateObjectsUsingBlock:^(id<DKDInstantMessage> obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = [obj dictionary];
        if (dict) {
            [array addObject:dict];
        }
    }];
    return array;
}
