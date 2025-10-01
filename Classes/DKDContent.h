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

typedef unsigned long DKDSerialNumber;

/*
 *  Message Content
 *  ~~~~~~~~~~~~~~~
 *  This class is for creating message content
 *
 *      data format: {
 *          'type'    : i2s(0),         // message type
 *          'sn'      : 0,              // serial number
 *
 *          'time'    : 123,            // message time
 *          'group'   : '{GroupID}',    // for group message
 *
 *          //-- message info
 *          'text'    : 'text',         // for text message
 *          'command' : 'Command Name'  // for system command
 *          //...
 *      }
 */
@protocol DKDContent <MKDictionary>

// message type: text, image, ...
@property (readonly, nonatomic) NSString *type;

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
- (nullable __kindof id<DKDContent>)parseContent:(NSDictionary *)content;

@end

#ifdef __cplusplus
extern "C" {
#endif

_Nullable id<DKDContentFactory> DKDContentGetFactory(NSString *type);
void DKDContentSetFactory(NSString *type, id<DKDContentFactory> factory);

_Nullable __kindof id<DKDContent> DKDContentParse(id content);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
