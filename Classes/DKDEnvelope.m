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
//  DKDEnvelope.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDSharedExtensions.h"

#import "DKDEnvelope.h"

id<DKDEnvelopeFactory> DKDEnvelopeGetFactory(void) {
    DKDSharedExtensions * man = [DKDSharedExtensions sharedManager];
    return [man.generalFactory envelopeFactory];
}

void DKDEnvelopeSetFactory(id<DKDEnvelopeFactory> factory) {
    DKDSharedExtensions * man = [DKDSharedExtensions sharedManager];
    [man.generalFactory setEnvelopeFactory:factory];
}

id<DKDEnvelope> DKDEnvelopeCreate(id<MKMID> sender,
                                  id<MKMID> receiver,
                                  NSDate * _Nullable time) {
    DKDSharedExtensions * man = [DKDSharedExtensions sharedManager];
    return [man.generalFactory createEnvelopeWithSender:sender
                                               receiver:receiver
                                                   time:time];
}

id<DKDEnvelope> DKDEnvelopeParse(id env) {
    DKDSharedExtensions * man = [DKDSharedExtensions sharedManager];
    return [man.generalFactory parseEnvelope:env];
}
