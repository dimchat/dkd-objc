// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DKDContent.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  @enum DKDContentType
 *
 *  @abstract A flag to indicate what kind of message content this is.
 *
 *  @discussion A message is something send from one place to another one,
 *      it can be an instant message, a system command, or something else.
 *
 *      DKDContentType_Text indicates this is a normal message with plaintext.
 *
 *      DKDContentType_File indicates this is a file, it may include filename
 *      and file data, but usually the file data will encrypted and upload to
 *      somewhere and here is just a URL to retrieve it.
 *
 *      DKDContentType_Image indicates this is an image, it may send the image
 *      data directly(encrypt the image data with Base64), but we suggest to
 *      include a URL for this image just like the 'File' message, of course
 *      you can get a thumbnail of this image here.
 *
 *      DKDContentType_Audio indicates this is a voice message, you can get
 *      a URL to retrieve the voice data just like the 'File' message.
 *
 *      DKDContentType_Video indicates this is a video file.
 *
 *      DKDContentType_Page indicates this is a web page.
 *
 *      DKDContentType_Quote indicates this message has quoted another message
 *      and the message content should be a plaintext.
 *
 *      DKDContentType_Command indicates this is a command message.
 *
 *      DKDContentType_Forward indicates here contains a TOP-SECRET message
 *      which needs your help to redirect it to the true receiver.
 *
 *  Bits:
 *      0000 0001 - this message contains plaintext you can read.
 *      0000 0010 - this is a message you can see.
 *      0000 0100 - this is a message you can hear.
 *      0000 1000 - this is a message for the bot, not for human.
 *
 *      0001 0000 - this message's main part is in somewhere else.
 *      0010 0000 - this message contains the 3rd party content.
 *      0100 0000 - this message contains digital assets
 *      1000 0000 - this is a message send by the system, not human.
 *
 *      (All above are just some advices to help choosing numbers :P)
 */
typedef NS_ENUM(UInt8, DKDMessageType) {
    
    DKDContentType_Text       = 0x01, // 0000 0001
    
    DKDContentType_File       = 0x10, // 0001 0000
    DKDContentType_Image      = 0x12, // 0001 0010
    DKDContentType_Audio      = 0x14, // 0001 0100
    DKDContentType_Video      = 0x16, // 0001 0110
    
    // Web Page
    DKDContentType_Page       = 0x20, // 0010 0000
    
    // Name Card
    DKDContentType_NameCard   = 0x33, // 0011 0011

    // Quote a message before and reply it with text
    DKDContentType_Quote      = 0x37, // 0011 0111
    
    DKDContentType_Money        = 0x40, // 0100 0000
    DKDContentType_Transfer     = 0x41, // 0100 0001
    DKDContentType_LuckyMoney   = 0x42, // 0100 0010
    DKDContentType_ClaimPayment = 0x48, // 0100 1000 (Claim for Payment)
    DKDContentType_SplitBill    = 0x49, // 0100 1001 (Split the Bill)

    DKDContentType_Command    = 0x88, // 1000 1000
    DKDContentType_History    = 0x89, // 1000 1001 (Entity History Command)
    
    // Application Customized
    DKDContentType_Application     = 0xA0, // 1010 0000 (Aoplication 0nly, Reserved)
    //DKDContentType_Application1  = 0xA1, // 1010 0001 (Reserved)
                                           // 1010 ???? (Reserved)
    //DKDContentType_Application15 = 0xA1, // 1010 0001 (Reserved)
    
    //DKDContentType_Customized0   = 0xC0, // 1100 0000 (Reserved)
    //DKDContentType_Customized1   = 0xC1, // 1100 0001 (Reserved)
                                           // 1100 ???? (Reserved)
    DKDContentType_Array           = 0xCA, // 1100 1010 (Content Array)
                                           // 1100 ???? (Reserved)
    DKDContentType_Customized      = 0xCC, // 1100 1100 (Customized Content)
                                           // 1100 ???? (Reserved)
    //DKDContentType_Customized15  = 0xCF, // 1100 1111 (Reserved)

    // Top-Secret message forward by proxy (MTA)
    DKDContentType_Forward    = 0xFF  // 1111 1111
};
typedef UInt8 DKDContentType;
typedef unsigned long DKDSerialNumber;

/*
 *  Message Content
 *  ~~~~~~~~~~~~~~~
 *  This class is for creating message content
 *
 *      data format: {
 *          'type'    : 0x00,        // message type
 *          'sn'      : 0,           // serial number
 *
 *          'time'    : 123,         // message time
 *          'group'   : 'Group ID',  // for group message
 *
 *          //-- message info
 *          'text'    : 'text',         // for text message
 *          'command' : 'Command Name'  // for system command
 *          //...
 *      }
 */
@protocol DKDContent <MKMDictionary>

// message type: text, image, ...
@property (readonly, nonatomic) DKDContentType type;

// serial number as message id
@property (readonly, nonatomic) DKDSerialNumber serialNumber;

// message time
@property (readonly, strong, nonatomic, nullable) NSDate *time;

// Group ID/string for group message
//    if field 'group' exists, it means this is a group message
@property (strong, nonatomic, nullable) id<MKMID> group;

@end

@protocol DKDContentFactory <NSObject>

/**
 *  Parse map object to content
 *
 * @param content - content info
 * @return Content
 */
- (nullable id<DKDContent>)parseContent:(NSDictionary *)content;

@end

#ifdef __cplusplus
extern "C" {
#endif

_Nullable id<DKDContentFactory> DKDContentGetFactory(DKDContentType type);
void DKDContentSetFactory(DKDContentType type, id<DKDContentFactory> factory);

_Nullable id<DKDContent> DKDContentParse(id content);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
