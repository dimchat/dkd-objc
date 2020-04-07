//
//  DaoKeDaoTests.m
//  DaoKeDaoTests
//
//  Created by Albert Moky on 2018/12/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <DaoKeDao/DaoKeDao.h>
#import "DKDTextContent.h"

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

- (void)testEnvelope {
    NSMutableDictionary *dict = nil;
    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] initWithDictionary:dict1];
    [dict1 setObject:@"value1" forKey:@"key1"];
    [dict2 setObject:@"value2" forKey:@"key2"];
    NSLog(@"dict: %@", dict);
    NSLog(@"dict1: %@", dict1);
    NSLog(@"dict2: %@", dict2);
}

@end
