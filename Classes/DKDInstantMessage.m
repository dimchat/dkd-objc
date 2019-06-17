//
//  DKDInstantMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDEnvelope.h"
#import "DKDContent.h"

#import "DKDInstantMessage.h"

@interface DKDInstantMessage ()

@property (strong, nonatomic) DKDContent *content;

@end

@implementation DKDInstantMessage

- (instancetype)initWithEnvelope:(const DKDEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    DKDContent *content = nil;
    self = [self initWithContent:content envelope:env];
    return self;
}

- (instancetype)initWithContent:(const DKDContent *)content
                         sender:(const NSString *)from
                       receiver:(const NSString *)to
                           time:(nullable const NSDate *)time {
    DKDEnvelope *env = [[DKDEnvelope alloc] initWithSender:from
                                                  receiver:to
                                                      time:time];
    self = [self initWithContent:content envelope:env];
    return self;
}

/* designated initializer */
- (instancetype)initWithContent:(const DKDContent *)content
                       envelope:(const DKDEnvelope *)env {
    NSAssert(content, @"content cannot be empty");
    NSAssert(env, @"envelope cannot be empty");
    
    if (self = [super initWithEnvelope:env]) {
        // content
        if (content) {
            _content = [content copy];
            [_storeDictionary setObject:_content forKey:@"content"];
        } else {
            _content = nil;
        }
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // content
        _content = nil; // lazy
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDInstantMessage *iMsg = [super copyWithZone:zone];
    if (iMsg) {
        iMsg.content = _content;
    }
    return iMsg;
}

- (DKDContent *)content {
    if (!_content) {
        NSDictionary *dict = [_storeDictionary objectForKey:@"content"];
        _content = [DKDContent contentWithContent:dict];
        if (_content != dict) {
            if (_content) {
                // replace the content object
                [_storeDictionary setObject:_content forKey:@"content"];
            } else {
                NSAssert(false, @"content error: %@", dict);
                //[_storeDictionary removeObjectForKey:@"content"];
            }
        }
    }
    return _content;
}

@end
