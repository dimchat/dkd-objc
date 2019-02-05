//
//  DKDMessageContent+History.m
//  DaoKeDao
//
//  Created by Albert Moky on 2019/2/5.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DKDMessageContent+History.h"

@implementation DKDMessageContent (HistoryCommand)

- (instancetype)initWithHistoryCommand:(const NSString *)cmd {
    NSAssert(cmd, @"command name cannot be empty");
    if (self = [self initWithType:DKDMessageType_History]) {
        // command
        if (cmd) {
            [_storeDictionary setObject:cmd forKey:@"command"];
        }
        // time
        NSDate *time = [[NSDate alloc] init];
        NSNumber *timestemp = NSNumberFromDate(time);
        [_storeDictionary setObject:timestemp forKey:@"time"];
    }
    return self;
}

- (NSDate *)time {
    NSNumber *timestamp = [_storeDictionary objectForKey:@"time"];
    NSAssert(timestamp, @"error: %@", _storeDictionary);
    return NSDateFromNumber(timestamp);
}

@end
