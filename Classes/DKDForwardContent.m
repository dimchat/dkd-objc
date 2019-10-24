//
//  DKDForwardContent.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDReliableMessage.h"

#import "DKDForwardContent.h"

@interface DKDForwardContent ()

@property (nonatomic) DKDReliableMessage *forwardMessage;

@end

@implementation DKDForwardContent

- (instancetype)initWithForwardMessage:(DKDReliableMessage *)rMsg {
    NSAssert(rMsg, @"forward message cannot be empty");
    if (self = [self initWithType:DKDContentType_Forward]) {
        // top-secret message
        if (rMsg) {
            [_storeDictionary setObject:rMsg forKey:@"forward"];
        }
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _forwardMessage = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDForwardContent *content = [super copyWithZone:zone];
    if (content) {
        content.forwardMessage = _forwardMessage;
    }
    return content;
}

- (DKDReliableMessage *)forwardMessage {
    if (!_forwardMessage) {
        NSDictionary *forward = [_storeDictionary objectForKey:@"forward"];
        _forwardMessage = DKDReliableMessageFromDictionary(forward);
        
        if (_forwardMessage != forward) {
            // replace the message object
            NSAssert([_forwardMessage isKindOfClass:[DKDReliableMessage class]],
                     @"forward message error: %@", forward);
            [_storeDictionary setObject:_forwardMessage forKey:@"forward"];
        }
    }
    NSAssert(_forwardMessage, @"forward message not found: %@", self);
    return _forwardMessage;
}

@end