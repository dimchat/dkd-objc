//
//  DKDInstantMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDEnvelope.h"
#import "DKDMessageContent.h"

#import "DKDInstantMessage.h"

@interface DKDInstantMessage ()

@property (strong, nonatomic) DKDMessageContent *content;

@end

static inline BOOL check_group(const MKMID *group, const MKMID *receiver) {
    if (MKMNetwork_IsCommunicator(receiver.type)) {
        if (group) {
            // if content.group exists,
            // the envelope.receiver should be a member of the group
            return [MKMGroupWithID(group) existsMember:receiver];
        } else {
            return YES;
        }
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        // if envelope.receiver is a group, it must equal to content.group,
        // and it means that content.group cannot be empty
        return [group isEqual:receiver];
    } else {
        assert(false);
        return NO;
    }
}

@implementation DKDInstantMessage

- (instancetype)initWithEnvelope:(const DKDEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    DKDMessageContent *content = nil;
    self = [self initWithContent:content envelope:env];
    return self;
}

- (instancetype)initWithContent:(const DKDMessageContent *)content
                         sender:(const MKMID *)from
                       receiver:(const MKMID *)to
                           time:(nullable const NSDate *)time {
    DKDEnvelope *env = [[DKDEnvelope alloc] initWithSender:from
                                                  receiver:to
                                                      time:time];
    self = [self initWithContent:content envelope:env];
    return self;
}

/* designated initializer */
- (instancetype)initWithContent:(const DKDMessageContent *)content
                       envelope:(const DKDEnvelope *)env {
    NSAssert(content, @"content cannot be empty");
    NSAssert(env, @"envelope cannot be empty");
    NSAssert([[content objectForKey:@"command"] isEqualToString:@"invite"] ||
             check_group(content.group, env.receiver),
             @"group message error: %@ not in %@", env.receiver, content.group);
    
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

- (DKDMessageContent *)content {
    if (!_content) {
        NSDictionary *dict = [_storeDictionary objectForKey:@"content"];
        _content = [DKDMessageContent contentWithContent:dict];
        
//        NSAssert([[dict objectForKey:@"command"] isEqualToString:@"invite"] ||
//                 check_group(_content.group, self.envelope.receiver),
//                 @"group message content error: %@", self);
        
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
