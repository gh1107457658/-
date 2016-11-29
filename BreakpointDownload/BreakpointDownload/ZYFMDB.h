//
//  ZYFMDB.h
//  DownloadVideoDemo
//
//  Created by chuanglong03 on 2016/11/28.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZYDownloadModel;

@interface ZYFMDB : NSObject

// 单例
+ (ZYFMDB *)sharedManager;
// 增
- (void)insertWithTableName:(NSString *)tableName downloadModel:(ZYDownloadModel *)downloadModel;
// 删除单个
- (void)deleteWithTableName:(NSString *)tableName key:(NSString *)key value:(NSString *)value;
// 删除所有
- (void)deleteWithTableName:(NSString *)tableName;
// 查单个
- (ZYDownloadModel *)selectWithTableName:(NSString *)tableName key:(NSString *)key value:(NSString *)value;
// 查所有
- (NSArray *)selectWithTableName:(NSString *)tableName;

@end
