//
//  ZYDownloadManagement.m
//  DownloadVideoDemo
//
//  Created by chuanglong03 on 2016/11/28.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import "ZYDownloadManagement.h"
#import "ZYDownload.h"
#import "ZYFMDB.h"

@interface ZYDownloadManagement ()

@property (nonatomic, strong) NSMutableDictionary *downloadingDic;

@end

@implementation ZYDownloadManagement

#pragma mark - 单例
+ (ZYDownloadManagement *)sharedManager {
    static ZYDownloadManagement *handle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handle = [[ZYDownloadManagement alloc] init];
    });
    return handle;
}

#pragma mark - 初始化
- (instancetype)init {
    if (self = [super init]) {
        self.downloadingDic = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - 添加下载任务
- (void)addDownloadWithUrl:(NSString *)url {
    self.download = self.downloadingDic[url];
    if (self.download == nil) {
        self.download = [[ZYDownload alloc] initWithUrl:url];
        [self.downloadingDic setObject:self.download forKey:url];
    }
    WS(weakSelf);
    self.download.downloadFinishBlock = ^(NSString *url){
        [weakSelf.downloadingDic removeObjectForKey:url];
        [[ZYFMDB sharedManager] deleteWithTableName:TableNameOfDownloading key:@"url" value:url];
    };
}

#pragma mark - 查找下载任务
// 查找单个
- (ZYDownload *)selectDownloadWithUrl:(NSString *)url {
    return self.downloadingDic[url];
}

// 查找所有
- (NSArray *)selectDownloads {
    return self.downloadingDic.allValues;
}

@end
