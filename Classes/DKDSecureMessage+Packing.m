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
//  DKDSecureMessage+Packing.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/12/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDEnvelope.h"

#import "DKDSecureMessage+Packing.h"

@implementation DKDSecureMessage (Packing)

- (NSArray *)splitForMembers:(NSArray<NSString *> *)members {
    NSMutableDictionary *msg;
    msg = [[NSMutableDictionary alloc] initWithDictionary:self];
    // check 'keys'
    NSDictionary *keyMap = self.encryptedKeys;
    if (keyMap) {
        [msg removeObjectForKey:@"keys"];
    }
    
    // 1. move the receiver(group ID) to 'group'
    //    this will help the receiver knows the group ID
    //    when the group message separated to multi-messages;
    //    if don't want the others know your membership,
    //    DON'T do this.
    [msg setObject:self.envelope.receiver forKey:@"group"];
    
    NSMutableArray *messages;
    messages = [[NSMutableArray alloc] initWithCapacity:members.count];
    NSString *base64;
    for (NSString *member in members) {
        // 2. change receiver to each group member
        [msg setObject:member forKey:@"receiver"];
        // 3. get encrypted key
        base64 = [keyMap objectForKey:member];
        if (base64) {
            [msg setObject:base64 forKey:@"key"];
        } else {
            [msg removeObjectForKey:@"key"];
        }
        // 4. repack message
        [messages addObject:[[[self class] alloc] initWithDictionary:msg]];
    }
    return messages;
}

- (instancetype)trimForMember:(NSString *)member {
    NSMutableDictionary *mDict = [self mutableCopy];
    // check 'keys'
    NSDictionary *keys = [mDict objectForKey:@"keys"];
    if (keys) {
        NSString *base64 = [keys objectForKey:member];
        if (base64) {
            [mDict setObject:base64 forKey:@"key"];
        }
        [mDict removeObjectForKey:@"keys"];
    }
    // check 'group'
    NSString *group = self.envelope.group;
    if (!group) {
        // if 'group' not exists, the 'receiver' must be a group ID here, and
        // it will not be equal to the member of course,
        // so move 'receiver' to 'group'
        [mDict setObject:self.envelope.receiver forKey:@"group"];
    }
    // replace receiver
    [mDict setObject:member forKey:@"receiver"];
    // repack
    return [[[self class] alloc] initWithDictionary:mDict];
}

@end
