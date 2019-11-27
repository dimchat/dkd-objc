//
//  DKDTextContent.h
//  DaoKeDaoTests
//
//  Created by Albert Moky on 2019/6/17.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DaoKeDao/DaoKeDao.h>

NS_ASSUME_NONNULL_BEGIN

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
