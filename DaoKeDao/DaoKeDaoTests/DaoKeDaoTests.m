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

- (void)testContent {
    NSDictionary *dict = @{@"type": @(1),
                           @"sn"  : @(3069910943),
                           @"text": @"Hey guy!",
                           };
    DKDMessageContent *text;
    text = [[DKDMessageContent alloc] initWithDictionary:dict];
    NSLog(@"text: %@", text);
    NSLog(@"json: %@", [text jsonString]);
    
    NSString *json = @"{\"type\":1,\"sn\":3069910943,\"text\":\"Hey guy!\"}";
    NSLog(@"string: %@", json);
    text = [[DKDMessageContent alloc] initWithJSONString:json];
    NSLog(@"text: %@", text);
    NSLog(@"json: %@", [text jsonString]);
}

- (void)testMessage {
    
    DKDMessageContent *text;
    text = [[DKDMessageContent alloc] initWithText:@"Hey guy!"];
    NSLog(@"text: %@", text);
    NSLog(@"json: %@", [text jsonString]);
    NSAssert(text.type == DKDMessageType_Text, @"msg type error");
    
    NSString *ID1 = @"hulk@4YeVEN3aUnvC1DNUufCq1bs9zoBSJTzVEj";
    NSString *ID2 = @"moki@4WDfe3zZ4T7opFSi3iDAKiuTnUHjxmXekk";
    
    DKDInstantMessage *iMsg;
    iMsg = [[DKDInstantMessage alloc] initWithContent:text
                                               sender:ID1
                                             receiver:ID2
                                                 time:nil];
    NSLog(@"instant msg: %@", iMsg);
    NSLog(@"json: %@", [iMsg jsonString]);
}

@end
