//
//  DaoKeDaoTests.m
//  DaoKeDaoTests
//
//  Created by Albert Moky on 2018/12/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <DaoKeDao/DaoKeDao.h>

#import "NSObject+JsON.h"

@interface DaoKeDaoTests : XCTestCase

@end

@implementation DaoKeDaoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testMessage {
    
    DKDMessageContent *text;
    text = [[DKDMessageContent alloc] initWithText:@"Hey guy!"];
    NSLog(@"text: %@", text);
    NSLog(@"json: %@", [text jsonString]);
    
    MKMID *ID1 = [MKMID IDWithID:MKM_IMMORTAL_HULK_ID];
    MKMID *ID2 = [MKMID IDWithID:MKM_MONKEY_KING_ID];
    
    DKDInstantMessage *iMsg;
    iMsg = [[DKDInstantMessage alloc] initWithContent:text
                                               sender:ID1
                                             receiver:ID2
                                                 time:nil];
    NSLog(@"instant msg: %@", iMsg);
    NSLog(@"json: %@", [iMsg jsonString]);
    
}

@end
