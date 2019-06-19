//
//  DKDTextContent.h
//  DaoKeDaoTests
//
//  Created by Albert Moky on 2019/6/17.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DaoKeDao/DaoKeDao.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, DKDMessageType) {
    DKDMessageType_Unknown = 0x00,
    DKDMessageType_Text    = 0x01, // 0000 0001
    
    DKDMessageType_File    = 0x10, // 0001 0000
    DKDMessageType_Image   = 0x12, // 0001 0010
    DKDMessageType_Audio   = 0x14, // 0001 0100
    DKDMessageType_Video   = 0x16, // 0001 0110
    
    DKDMessageType_Page    = 0x20, // 0010 0000
    
    // quote a message before and reply it with text
    DKDMessageType_Quote   = 0x37, // 0011 0111
    
    DKDMessageType_Command = 0x88, // 1000 1000
    DKDMessageType_History = 0x89, // 1000 1001 (Entity history command)
    
    // top-secret message forward by proxy (Service Provider)
    DKDMessageType_Forward = 0xFF  // 1111 1111
};

@interface DKDTextContent : DKDContent

@property (readonly, strong, nonatomic) NSString *text;

/**
 *  Text message: {
 *      type : 0x01,
 *      sn   : 123,
 *
 *      text : "..."
 *  }
 */
- (instancetype)initWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
