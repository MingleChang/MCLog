//
//  MCLogManager.h
//  MCLog
//
//  Created by 常峻玮 on 16/11/16.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCLogConfigure.h"
@class MCLogModel;

NS_ASSUME_NONNULL_BEGIN

@interface MCLogManager : NSObject

+ (void)lauch;

- (void)selectAllLogModelComplete:(nullable mc_selectCompleteBlock)complete;

+ (void)logIsSynchronize:(BOOL)isSynchronize
                    type:(MCLogType)type
                 subType:(NSUInteger)subType
                userInfo:(nullable NSDictionary *)userInfo
                    line:(NSUInteger)line
                function:(const char *)function
                    file:(const char *)file
                 content:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
