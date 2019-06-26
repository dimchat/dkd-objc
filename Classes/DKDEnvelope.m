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

@end

@implementation DKDEnvelope

/* designated initializer */
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
    if (self = [super initWithDictionary:dict]) {
        _sender = from;
        _receiver = to;
        _time = time;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _sender = nil;
        _receiver = nil;
        _time = nil;
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
