//
//  MCLogCrash.m
//  MCLog
//
//  Created by 常峻玮 on 16/11/19.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import "MCLogCrash.h"
#import "MCLogExtern.h"
#import "MCLog.h"
#include <execinfo.h>



static BOOL isCrash = NO;

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;


@implementation MCLogCrash

/**
 获取函数调用栈

 @return <#return value description#>
 */
+ (NSArray *)backTrace {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for ( i = 0; i < frames; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

+ (void)handleException:(NSException *)exception {
    MCLogMacro(YES, MCLogTypeError, 0, exception.userInfo, @"%@", exception);
    isCrash = YES;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        isCrash = YES;
//    });
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!isCrash) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }

    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:MCLogCrashSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:MCLogCrashSignalExceptionKey] intValue]);
    }else {
        [exception raise];
    }
}

static void mcLogUncaughtExceptionHandle(NSException *exception) {
    //这里可以取到 NSException 信息
    NSArray *lBacktrace = [MCLogCrash backTrace];
    NSMutableDictionary *lUserInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [lUserInfo setObject:lBacktrace forKey:MCLogCrashBackTraceKey];
    if (exception.callStackSymbols) {
        [lUserInfo setObject:exception.callStackSymbols forKey:MCLogCrashCallStackSymbolsKey];
    }
    NSException *lException = [NSException exceptionWithName:exception.name reason:exception.reason userInfo:lUserInfo];
    [MCLogCrash handleException:lException];
}

static void mcLogSignalHandler(int signal) {
    NSArray *lBacktrace = [MCLogCrash backTrace];
    NSMutableDictionary *lUserInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(signal), MCLogCrashSignalExceptionKey, nil];
    [lUserInfo setObject:lBacktrace forKey:MCLogCrashBackTraceKey];
    NSString *lName = [NSString stringWithFormat:@"%@", MCLogCrashSignalExceptionName];
    NSString *lReason = [NSString stringWithFormat:@"Signal %d was raised.", signal];
    NSException *lException = [NSException exceptionWithName:lName reason:lReason userInfo:lUserInfo];
    [MCLogCrash handleException:lException];
}

+ (void)configureLogCrash {
    NSSetUncaughtExceptionHandler(&mcLogUncaughtExceptionHandle);
    signal(SIGABRT, mcLogSignalHandler);
    signal(SIGILL, mcLogSignalHandler);
    signal(SIGSEGV, mcLogSignalHandler);
    signal(SIGFPE, mcLogSignalHandler);
    signal(SIGBUS, mcLogSignalHandler);
    signal(SIGPIPE, mcLogSignalHandler);
}

@end
