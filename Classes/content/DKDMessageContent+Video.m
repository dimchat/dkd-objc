//
//  DKDMessageContent+Video.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"

#import "DKDMessageContent+File.h"

#import "DKDMessageContent+Video.h"

@interface DKDMessageContent (Hacking)

@property (nonatomic) DKDMessageType type;

@end

@implementation DKDMessageContent (Video)

- (instancetype)initWithVideoData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:nil]) {
        // type
        self.type = DKDMessageType_Video;
        
        // TODO: snapshot
    }
    return self;
}

- (const NSData *)videoData {
    return [self fileData];
}

- (void)setVideoData:(const NSData *)videoData {
    self.fileData = videoData;
}

- (nullable const NSData *)snapshot {
    NSString *ss = [_storeDictionary objectForKey:@"snapshot"];
    return [ss base64Decode];
}

@end
