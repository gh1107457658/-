//
//  ZYFMDB.m
//  DownloadVideoDemo
//
//  Created by chuanglong03 on 2016/11/28.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import "ZYFMDB.h"
#import "ZYDownloadModel.h"
#import <FMDatabase.h>

@interface ZYFMDB ()

@property (nonatomic, strong) FMDatabase *database;

@end

@implementation ZYFMDB

#pragma mark - 单例
+ (ZYFMDB *)sharedManager {
    static ZYFMDB *handle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handle = [[ZYFMDB alloc] init];
    });
    return handle;
}

#pragma mark - 初始化
- (instancetype)init {
    if (self = [super init]) {
        [self createDatabase];
    }
    return self;
}

#pragma mark - 创建数据库和表
- (void)createDatabase {
    NSString *documentPath = PathOfDocument;
    NSString *sqPath = [documentPath stringByAppendingPathComponent:@"DownloadVideo.sqlite"];
    NSLog(@"%@", sqPath);
    self.database = [FMDatabase databaseWithPath:sqPath];
    if ([self.database open]) {
        // 创建下载未完成表
        [self createTableWithTableName:TableNameOfDownloading];
        // 创建下载完成表
        [self createTableWithTableName:TableNameOfDownloadFinish];
        [self.database close];
    } else {
        NSLog(@"数据库打开失败！");
    }
}

#pragma mark - 创建表
- (void)createTableWithTableName:(NSString *)tableName {
    NSString *createTableSql = nil;
    if ([tableName isEqualToString:TableNameOfDownloading]) {
        createTableSql = [NSString stringWithFormat:@"create table if not exists '%@' ('ID' integer primary key autoincrement, 'url' text, 'filePath' text, 'fileSize' text, 'resumeDataString' text);", tableName];
    } else {
        createTableSql = [NSString stringWithFormat:@"create table if not exists '%@' ('ID' integer primary key autoincrement, 'url' text, 'filePath' text);", tableName];
    }
    BOOL result = [self.database executeUpdate:createTableSql];
    if (result) {
        NSLog(@"%@ 表创建成功！", tableName);
    } else {
        NSLog(@"%@ 表创建失败！", tableName);
    }
}

#pragma mark - 增
- (void)insertWithTableName:(NSString *)tableName downloadModel:(ZYDownloadModel *)downloadModel {
    if ([self.database open]) {
        NSString *insertSql = nil;
        if ([tableName isEqualToString:TableNameOfDownloading]) {
            insertSql = [NSString stringWithFormat:@"insert into '%@' ('url', 'filePath', 'fileSize', 'resumeDataString') values ('%@', '%@', '%@', '%@');", tableName, downloadModel.url, downloadModel.filePath, downloadModel.fileSize, downloadModel.resumeDataString];
        } else {
            insertSql = [NSString stringWithFormat:@"insert into '%@' ('url', 'filePath') values ('%@', '%@');", tableName, downloadModel.url, downloadModel.filePath];
        }
        BOOL result = [self.database executeUpdate:insertSql];
        if (result) {
            NSLog(@"%@ 表插入数据成功！", tableName);
        } else {
            NSLog(@"%@ 表插入数据失败！", tableName);
        }
        [self.database close];
    } else {
        NSLog(@"数据库打开失败！");
    }
}

#pragma mark - 删
// 删除单个
- (void)deleteWithTableName:(NSString *)tableName key:(NSString *)key value:(NSString *)value {
    if ([self.database open]) {
        NSString *deleteSql = [NSString stringWithFormat:@"delete from '%@' where '%@' = '%@';", tableName, key, value];
        BOOL result = [self.database executeUpdate:deleteSql];
        if (result) {
            NSLog(@"%@ 表删除单个数据成功！", tableName);
        } else {
            NSLog(@"%@ 表删除单个数据失败！", tableName);
        }
        [self.database close];
    } else {
        NSLog(@"数据库打开失败！");
    }
}

// 删除所有
- (void)deleteWithTableName:(NSString *)tableName {
    if ([self.database open]) {
        NSString *deleteSql = [NSString stringWithFormat:@"delete from '%@';", tableName];
        BOOL result = [self.database executeUpdate:deleteSql];
        if (result) {
            NSLog(@"%@ 表删除所有数据成功！", tableName);
        } else {
            NSLog(@"%@ 表删除所有数据失败！", tableName);
        }
        [self.database close];
    } else {
        NSLog(@"数据库打开失败！");
    }
}

#pragma mark - 查
// 查单个
- (ZYDownloadModel *)selectWithTableName:(NSString *)tableName key:(NSString *)key value:(NSString *)value {
    ZYDownloadModel *downloadModel = nil;
    if ([self.database open]) {
        NSString *selectSql = [NSString stringWithFormat:@"select * from '%@' where %@ = '%@';", tableName, key, value];
        FMResultSet *resultSet = [self.database executeQuery:selectSql];
        while ([resultSet next]) {
            downloadModel = [[ZYDownloadModel alloc] init];
            downloadModel.url = [resultSet stringForColumn:@"url"];
            downloadModel.filePath = [resultSet stringForColumn:@"filePath"];
            if ([tableName isEqualToString:TableNameOfDownloading]) {
                downloadModel.fileSize = [resultSet stringForColumn:@"fileSize"];
                downloadModel.resumeDataString = [resultSet stringForColumn:@"resumeDataString"];
            }
        }
        [self.database close];
    } else {
        NSLog(@"数据库打开失败！");
    }
    return downloadModel;
}

// 查所有
- (NSArray *)selectWithTableName:(NSString *)tableName {
    NSMutableArray *array = nil;
    if ([self.database open]) {
        NSString *selectSql = [NSString stringWithFormat:@"select * from '%@';", tableName];
        FMResultSet *resultSet = [self.database executeQuery:selectSql];
        while ([resultSet next]) {
            if (array == nil) {
                array = [NSMutableArray array];
            }
            ZYDownloadModel *downloadModel = [[ZYDownloadModel alloc] init];
            downloadModel.url = [resultSet stringForColumn:@"url"];
            downloadModel.filePath = [resultSet stringForColumn:@"filePath"];
            if ([tableName isEqualToString:TableNameOfDownloading]) {
                downloadModel.fileSize = [resultSet stringForColumn:@"fileSize"];
                downloadModel.resumeDataString = [resultSet stringForColumn:@"resumeDataString"];
            }
            [array addObject:downloadModel];
        }
        [self.database close];
    } else {
        NSLog(@"数据库打开失败！");
    }
    return array;
}

@end
