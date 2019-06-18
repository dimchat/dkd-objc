//
//  DKDMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DKDEnvelope.h"
#import "DKDInstantMessage.h"
#import "DKDSecureMessage.h"
#import "DKDReliableMessage.h"

#import "DKDMessage.h"

@interface DKDMessage ()

@property (strong, nonatomic) DKDEnvelope *envelope;

@end

@implementation DKDMessage

+ (instancetype)messageWithMessage:(id)msg {
    if ([msg isKindOfClass:[DKDMessage class]]) {
        return msg;
    } else if ([msg isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:msg];
    } else {
        NSAssert(!msg, @"unexpected message: %@", msg);
        return nil;
    }
}

- (instancetype)initWithSender:(const NSString *)from
                      receiver:(const NSString *)to
                          time:(nullable const NSDate *)time {
    DKDEnvelope *env = DKDEnvelopeCreate(from, to, time);
    self = [self initWithEnvelope:env];
    return self;
}

/* designated initializer */
- (instancetype)initWithEnvelope:(const DKDEnvelope *)env {
    NSAssert(env, @"envelope cannot be empty");
    DKDEnvelope *envelope = DKDEnvelopeFromDictionary(env);
    if (self = [super initWithDictionary:envelope]) {
        // envelope
        _envelope = envelope;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // envelope
        _envelope = nil; // lazy
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDMessage *msg = [super copyWithZone:zone];
    if (msg) {
        msg.envelope = _envelope;
    }
    return self;
}

- (DKDEnvelope *)envelope {
    if (!_envelope) {
        // sender
        NSString *sender = [_storeDictionary objectForKey:@"sender"];
        
        // receiver
        NSString *receier = [_storeDictionary objectForKey:@"receiver"];
        
        // time
        NSNumber *timestamp = [_storeDictionary objectForKey:@"time"];
        //NSAssert(timestamp.doubleValue > 0, @"time error");
        NSDate *time = NSDateFromNumber(timestamp);
        
        if (sender.length > 0 && receier.length > 0) {
            _envelope = DKDEnvelopeCreate(sender, receier, time);
        } else {
            NSAssert(false, @"envelope error: %@", self);
        }
    }
    return _envelope;
}

@end

@implementation DKDMessage (Runtime)

+ (nullable instancetype)getInstance:(id)msg {
    if (!msg) {
        return nil;
    }
    if ([msg isKindOfClass:[DKDMessage class]]) {
        // return Message object directly
        return msg;
    }
    // create instance by subclass
    NSDictionary *content = [msg objectForKey:@"content"];
    if (content) {
        return [[DKDInstantMessage alloc] initWithDictionary:msg];
    }
    NSString *signature = [msg objectForKey:@"signature"];
    if (signature) {
        return [[DKDReliableMessage alloc] initWithDictionary:msg];
    }
    NSString *data = [msg objectForKey:@"data"];
    if (data) {
        return [[DKDSecureMessage alloc] initWithDictionary:msg];
    }
    NSAssert(false, @"message error: %@", msg);
    return [[DKDMessage alloc] initWithDictionary:msg];
}

@end
