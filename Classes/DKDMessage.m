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

- (instancetype)initWithSender:(NSString *)from
                      receiver:(NSString *)to
                          time:(nullable NSDate *)time {
    DKDEnvelope *env = DKDEnvelopeCreate(from, to, time);
    return [self initWithEnvelope:env];
}

/* designated initializer */
- (instancetype)initWithEnvelope:(DKDEnvelope *)env {
    NSAssert(env, @"envelope cannot be empty");
    NSDictionary *dict;
    if (env.time) {
        dict = @{@"sender": env.sender,
                 @"receiver": env.receiver,
                 @"time": [env objectForKey:@"time"],
                 };
    } else {
        dict = @{@"sender": env.sender,
                 @"receiver": env.receiver,
                 };
    }
    if (self = [super initWithDictionary:dict]) {
        _delegate = nil;
        _envelope = env;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        _delegate = nil;
        _envelope = nil; // lazy
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDMessage *msg = [super copyWithZone:zone];
    if (msg) {
        msg.delegate = _delegate;
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
    return [[self alloc] initWithDictionary:msg];
}

@end
