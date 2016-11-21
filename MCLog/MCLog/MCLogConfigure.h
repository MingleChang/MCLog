//
//  MCLogConfigure.h
//  MCLog
//
//  Created by 常峻玮 on 16/11/16.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#ifndef MCLogConfigure_h
#define MCLogConfigure_h

#define MCLOGWEAK(weakobject,object) __weak typeof(object) weakobject = object
#define MCLOGSTRONG(strongobject,object) __strong typeof(object) strongobject = object;

typedef void (^mc_errorBlock)(NSError *error);
typedef void (^mc_selectCompleteBlock)(NSError *error, NSArray *array);

typedef NS_ENUM(NSUInteger,MCLogType){
    MCLogTypeDebug=0,
    MCLogTypeEvent,
    MCLogTypeInfo,
    MCLogTypeWarn,
    MCLogTypeError,
};

#define MCLogMacro(s,t,st,ui,frmt, ...)                           \
        [MCLogManager logIsSynchronize:s                          \
                                  type:t                          \
                               subType:st                         \
                              userInfo:ui                         \
                                  line:__LINE__                   \
                              function:__PRETTY_FUNCTION__        \
                                  file:__FILE__                   \
                               content:(frmt), ## __VA_ARGS__]

#define MCLogDebug(frmt, ...)   MCLogMacro(NO,MCLogTypeDebug,0,nil,frmt, ##__VA_ARGS__)
#define MCLogEvent(frmt, ...)   MCLogMacro(NO,MCLogTypeEvent,0,nil,frmt, ##__VA_ARGS__)
#define MCLogInfo(frmt, ...)    MCLogMacro(NO,MCLogTypeInfo,0,nil,frmt, ##__VA_ARGS__)
#define MCLogWarn(frmt, ...)    MCLogMacro(NO,MCLogTypeWarn,0,nil,frmt, ##__VA_ARGS__)
#define MCLogError(frmt, ...)   MCLogMacro(YES,MCLogTypeWarn,0,nil,frmt, ##__VA_ARGS__)

#endif /* MCLogConfigure_h */
