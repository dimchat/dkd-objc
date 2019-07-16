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

- (instancetype)initWithEnvelope:(DKDEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    DKDContent *content = nil;
    return [self initWithContent:content envelope:env];
}

- (instancetype)initWithContent:(DKDContent *)content
                         sender:(NSString *)from
                       receiver:(NSString *)to
                           time:(nullable NSDate *)time {
    DKDEnvelope *env = DKDEnvelopeCreate(from, to, time);
    return [self initWithContent:content envelope:env];
}

/* designated initializer */
- (instancetype)initWithContent:(DKDContent *)content
                       envelope:(DKDEnvelope *)env {
    NSAssert(content, @"content cannot be empty");
    NSAssert(env, @"envelope cannot be empty");
    
    if (self = [super initWithEnvelope:env]) {
        // content
        if (content) {
            [_storeDictionary setObject:content forKey:@"content"];
        }
        _content = content;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _content = nil;
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
        _content = DKDContentFromDictionary(dict);
        
        if (_content != dict) {
            // replace the content object
            NSAssert([_content isKindOfClass:[DKDContent class]],
                     @"content error: %@", dict);
            [_storeDictionary setObject:_content forKey:@"content"];
        }
    }
    return _content;
}

- (nullable NSString *)group {
    return [_content group];
}

- (void)setGroup:(NSString *)group {
    [_content setGroup:group];
}

@end
