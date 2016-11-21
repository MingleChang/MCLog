//
//  MCLogManager.m
//  MCLog
//
//  Created by 常峻玮 on 16/11/16.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import "MCLogManager.h"
#import "MCLogExtern.h"
#import "MCLogModel.h"
#import "MCLogCrash.h"
#import <sqlite3.h>

@interface MCLogManager () {
    sqlite3 *_db;
}
@property (nonatomic, copy)NSString *sqlitePath;

//@property (nonatomic, assign) sqlite3 db;
@property (nonatomic, strong)dispatch_queue_t dbOperateQueue;

@end

@implementation MCLogManager

+ (MCLogManager *)manager {
    static MCLogManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MCLogManager alloc]init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configureSqlite];
    }
    return self;
}
+ (void)lauch {
    [MCLogManager manager];
    [MCLogCrash configureLogCrash];
}
#pragma mark - Database SQL
- (void)configureSqlite {
    int result = sqlite3_open([self.sqlitePath UTF8String], &_db);
    if (result != SQLITE_OK) {
        sqlite3_close(_db);
        NSAssert(0, @"数据库打开失败");
    }
    NSString *lCreateSql = [MCLogModel createTableSql];
    char *error;
    result = sqlite3_exec(_db, [lCreateSql UTF8String], NULL, NULL, &error);
    if (result != SQLITE_OK) {
        sqlite3_close(_db);
        NSAssert(0, @"日志表创建失败");
    }
}

- (void)insertOrReplaceLogModel:(MCLogModel *)model complete:(mc_errorBlock)complete{
    NSString *lSql = [model insertOrReplaceSql];
    if (model.isSynchronize) {
        char *error;
        int result = sqlite3_exec(_db, [lSql UTF8String], NULL, NULL, &error);
        NSError *lError=nil;
        if (result != SQLITE_OK) {
            lError = [NSError errorWithDomain:[NSString stringWithUTF8String:error] code:result userInfo:nil];
        }
        if (complete) {
            complete(lError);
        }
    }else{
        dispatch_async(self.dbOperateQueue, ^{
            char *error;
            int result = sqlite3_exec(_db, [lSql UTF8String], NULL, NULL, &error);
            NSError *lError=nil;
            if (result != SQLITE_OK) {
                lError = [NSError errorWithDomain:[NSString stringWithUTF8String:error] code:result userInfo:nil];
            }
            if (complete) {
                complete(lError);
            }
        });
    }
}
- (void)selectAllLogModelComplete:(mc_selectCompleteBlock)complete{
    NSString *lSql = [MCLogModel selectedlAllSql];
    dispatch_async(self.dbOperateQueue, ^{
        sqlite3_stmt *stmt;
        int result = sqlite3_prepare_v2(_db, [lSql UTF8String], -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            sqlite3_finalize(stmt);
            NSError *lError=[NSError errorWithDomain:@"" code:result userInfo:nil];
            if (complete) {
                complete(lError, nil);
            }
            return;
        }
        NSMutableArray *lArray = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            MCLogModel *lModel = [[MCLogModel alloc] init];
            char *uuid = (char *)sqlite3_column_text(stmt, 0);
            NSString *lUUID = [NSString stringWithUTF8String:uuid];
            lModel.uuid = lUUID;
            
            char *content = (char *)sqlite3_column_text(stmt, 1);
            NSString *lContent = [NSString stringWithUTF8String:content];
            lModel.content = lContent;
            
            int type = sqlite3_column_int(stmt, 2);
            lModel.type = type;
            
            int subType = sqlite3_column_int(stmt, 3);
            lModel.subType = subType;
            
            char *info = (char *)sqlite3_column_text(stmt, 4);
            NSString *lInfo = [NSString stringWithUTF8String:info];
            NSError *lError = nil;
            NSDictionary *lInfoDic = [NSJSONSerialization JSONObjectWithData:[lInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&lError];
            lModel.userInfo = lInfoDic;
            
            int line = sqlite3_column_int(stmt, 5);
            lModel.line = line;
            
            char *function = (char *)sqlite3_column_text(stmt, 6);
            NSString *lFunction = [NSString stringWithUTF8String:function];
            lModel.function = lFunction;
            
            char *file = (char *)sqlite3_column_text(stmt, 7);
            NSString *lFile = [NSString stringWithUTF8String:file];
            lModel.file = lFile;
            
            char *date = (char *)sqlite3_column_text(stmt, 8);
            NSString *lDateString = [NSString stringWithUTF8String:date];
            static NSDateFormatter *formatter = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            });
            NSDate *lCreateTime =  [formatter dateFromString:lDateString];
            lModel.createTime =lCreateTime;
            
            [lArray addObject:lModel];
        }
        sqlite3_finalize(stmt);
        if (complete) {
            complete(nil,[lArray copy]);
        }
    });
}

#pragma mark - Log
+ (void)logIsSynchronize:(BOOL)isSynchronize
                 content:(NSString *)content
                    type:(MCLogType)type
                 subType:(NSUInteger)subType
                userInfo:(NSDictionary *)userInfo
                    line:(NSUInteger)line
                function:(const char *)function
                    file:(const char *)file{
    MCLogModel *lModel = [[MCLogModel alloc]init];
    lModel.isSynchronize=isSynchronize;
    lModel.content = content;
    lModel.type = type;
    lModel.subType = subType;
    lModel.userInfo = userInfo;
    lModel.line = line;
    lModel.function = [NSString stringWithUTF8String:function];
    lModel.file = [NSString stringWithUTF8String:file];
#ifdef DEBUG
    NSLog(@"%@",content);
#endif
    [[MCLogManager manager]insertOrReplaceLogModel:lModel complete:nil];
}
+ (void)logIsSynchronize:(BOOL)isSynchronize
                    type:(MCLogType)type
                subType:(NSUInteger)subType
                userInfo:(nullable NSDictionary *)userInfo
                    line:(NSUInteger)line
                function:(const char *)function
                    file:(const char *)file
                 content:(NSString *)format, ...{
    va_list args;
    if (format) {
        va_start(args, format);
        NSString *lContent = [[NSString alloc] initWithFormat:format arguments:args];
        [self logIsSynchronize:isSynchronize
                       content:lContent
                          type:type
                       subType:subType
                      userInfo:userInfo
                          line:line
                      function:function
                          file:file];
        va_end(args);
    }
}
#pragma mark - Setter And Getter
- (NSString *)sqlitePath {
    if (_sqlitePath) {
        return _sqlitePath;
    }
    NSString *lDocumentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES)[0];
    _sqlitePath = [NSString stringWithFormat:@"%@/%@",lDocumentPath,MCLogDatabaseName];
    return _sqlitePath;
}

- (dispatch_queue_t)dbOperateQueue{
    if (_dbOperateQueue) {
        return _dbOperateQueue;
    }
    _dbOperateQueue = dispatch_queue_create([MCLogDatabaseQueueName UTF8String], NULL);
    return _dbOperateQueue;
}

@end
