// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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
//  DaoKeDao.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for DaoKeDao.
FOUNDATION_EXPORT double DaoKeDaoVersionNumber;

//! Project version string for DaoKeDao.
FOUNDATION_EXPORT const unsigned char DaoKeDaoVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DaoKeDao/PublicHeader.h>

#if !defined(__DAO_KE_DAO__)
#define __DAO_KE_DAO__ 1

// Types
//#import <DaoKeDao/DKDDictionary.h>

//#import <DaoKeDao/DKDEnvelope.h>
//#import <DaoKeDao/DKDContent.h>
//#import <DaoKeDao/DKDForwardContent.h>
//
//// Message
//#import <DaoKeDao/DKDMessage.h>
//#import <DaoKeDao/DKDInstantMessage.h>
//#import <DaoKeDao/DKDSecureMessage.h>
//#import <DaoKeDao/DKDReliableMessage.h>
//
//#import <DaoKeDao/DKDMessage+Transform.h>
//#import <DaoKeDao/DKDSecureMessage+Packing.h>

#import "DKDEnvelope.h"
#import "DKDContent.h"
#import "DKDForwardContent.h"

// Message
#import "DKDMessage.h"
#import "DKDInstantMessage.h"
#import "DKDSecureMessage.h"
#import "DKDReliableMessage.h"

#import "DKDMessage+Transform.h"
#import "DKDSecureMessage+Packing.h"

#endif /* ! __DAO_KE_DAO__ */
