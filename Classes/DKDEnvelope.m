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

@property (strong, nonatomic) const NSString *sender;
@property (strong, nonatomic) const NSString *receiver;

@property (strong, nonatomic) const NSDate *time;

@end

@implementation DKDEnvelope

/* designated initializer */
- (instancetype)initWithSender:(const NSString *)from
                      receiver:(const NSString *)to
                          time:(nullable const NSDate *)time {
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
        _sender = [_storeDictionary objectForKey:@"sender"];
        _receiver = [_storeDictionary objectForKey:@"receiver"];
        NSNumber *timestamp = [_storeDictionary objectForKey:@"time"];
        _time = NSDateFromNumber(timestamp);
    }
    return self;
}

@end

@implementation DKDEnvelope (Runtime)

+ (nullable instancetype)getInstance:(id)env {
    if (!env) {
        return nil;
    }
    if ([env isKindOfClass:[DKDEnvelope class]]) {
        return env;
    }
    NSAssert([env isKindOfClass:[NSDictionary class]],
             @"envelope should be a dictionary: %@", env);
    // create instance
    return [[self alloc] initWithDictionary:env];
}

@end
