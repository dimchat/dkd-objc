//
//  DKDReliableMessage+Transform.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/12/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDEnvelope.h"

#import "DKDSecureMessage+Packing.h"
#import "DKDReliableMessage+Meta.h"

#import "DKDReliableMessage+Transform.h"

@implementation DKDReliableMessage (Transform)

- (DKDSecureMessage *)verify {
    MKMID *sender = self.envelope.sender;
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"sender error");
    
    // 1. verify the signature with public key
    MKMPublicKey *PK = MKMPublicKeyForID(sender);
    if (!PK) {
        // first contact, try meta in message package
        MKMMeta *meta = self.meta;
        if ([meta matchID:sender]) {
            PK = meta.key;
        }
    }
    if (![PK verify:self.data withSignature:self.signature]) {
        //NSAssert(false, @"signature error: %@", self);
        return nil;
    }
    
    // 2. create secure message
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:self];
    [mDict removeObjectForKey:@"signature"];
    return [[DKDSecureMessage alloc] initWithDictionary:mDict];
}

@end
