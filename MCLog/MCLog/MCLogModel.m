//
//  MCLogModel.m
//  MCLog
//
//  Created by 常峻玮 on 16/11/16.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import "MCLogModel.h"
#import "MCLogExtern.h"

@implementation MCLogModel

- (NSString *)userInfoString {
    if (![self.userInfo isKindOfClass:[NSDictionary class]]) {
        return @"";
    }
    NSError *lError=nil;
    NSData *lData = [NSJSONSerialization dataWithJSONObject:self.userInfo options:NSJSONWritingPrettyPrinted error:&lError];
    if (lError) {
        return @"";
    }
    NSString *lString = [[NSString alloc] initWithData:lData encoding:NSUTF8StringEncoding];
    if (lString.length > 0) {
        return lString;
    }else{
        return @"";
    }
}

#pragma mark - Setter And Getter
- (NSString *)uuid {
    if (_uuid) {
        return _uuid;
    }
    _uuid = [NSUUID UUID].UUIDString;
    return _uuid;
}

- (NSString *)content {
    if (_content) {
        return _content;
    }
    return @"";
}

- (NSString *)function {
    if (_function) {
        return _function;
    }
    return @"";
}

- (NSString *)file {
    if (_file) {
        return _file;
    }
    return @"";
}

@end

@implementation MCLogModel (SQL)

+ (NSString *)createTableSql {
    NSString *lSql = [NSString stringWithFormat:
                      @"CREATE TABLE IF NOT EXISTS %@("
                      "uuid TEXT PRIMARY KEY,"
                      "content TEXT,"
                      "type INTEGER,"
                      "subType INTEGER,"
                      "info TEXT,"
                      "line INTEGER,"
                      "function TEXT,"
                      "file TEXT,"
                      "ctime DATETIME DEFAULT CURRENT_TIMESTAMP"
                      ")",
                      MCLogTableName];
    return lSql;
}

- (NSString *)insertOrReplaceSql {
    NSString *lSql = [NSString stringWithFormat:
                      @"INSERT OR REPLACE INTO %@("
                      "uuid,"
                      "content,"
                      "type,"
                      "subType,"
                      "info,"
                      "line,"
                      "function,"
                      "file"
                      ")"
                      "VALUES("
                      "'%@','%@',%ld,%ld,'%@',%ld,'%@','%@'"
                      ")",
                      MCLogTableName,self.uuid,self.content,self.type,self.subType,[self userInfoString],self.line,self.function,self.file];
    return lSql;
}

+ (NSString *)selectedlAllSql {
    NSString *lSql = [NSString stringWithFormat:@"SELECT * FROM %@",MCLogTableName];
    return lSql;
}

@end
