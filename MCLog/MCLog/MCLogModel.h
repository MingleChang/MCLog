//
//  MCLogModel.h
//  MCLog
//
//  Created by 常峻玮 on 16/11/16.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCLogConfigure.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCLogModel : NSObject

@property (nonatomic, assign)BOOL isSynchronize;
/**
 唯一标识
 */
@property (nonatomic, copy)NSString *uuid;

/**
 内容
 */
@property (nonatomic, copy)NSString *content;

/**
 类型
 */
@property (nonatomic, assign)MCLogType type;

/**
 子类型
 */
@property (nonatomic, assign)NSUInteger subType;

/**
 其它信息
 */
@property (nonatomic, copy)NSDictionary *userInfo;
/**
 __LINE__
 */
@property (nonatomic, assign)NSUInteger line;

/**
 __FUNCTION__,__PRETTY_FUNCTION__
 */
@property (nonatomic, copy)NSString *function;

/**
 __FILE__
 */
@property (nonatomic, copy)NSString *file;

@property (nonatomic, copy)NSDate *createTime;

@end

@interface MCLogModel (SQL)

/**
 创建Log表的SQL语句的字符串

 @return 用于创建Log表的SQL语句
 */
+ (NSString *)createTableSql;

/**
 向数据库插入或者替换同一uuid的数据的SQL语句的字符串

 @return 插入或替换的SQL语句
 */
- (NSString *)insertOrReplaceSql;
+ (NSString *)selectedlAllSql;

@end

NS_ASSUME_NONNULL_END
